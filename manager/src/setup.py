from __future__ import annotations

import atexit
import os
import shutil
import subprocess
import threading
from typing import Sequence


class DependencyMissing(RuntimeError):
    """A required program is absent and could not be installed."""


class CommandFailed(RuntimeError):
    """A subprocess exited with an unexpected status."""


SUDO_KEEPALIVE_SECONDS = 60
NOTHING_TO_DO = 2  # fwupdmgr's "no updates / already current" status

_keepalive_stop = threading.Event()


def _run(
    cmd: Sequence[str],
    *,
    ok: tuple[int, ...] = (0,),
    capture: bool = True,
) -> subprocess.CompletedProcess:
    proc = subprocess.run(list(cmd), capture_output=capture, text=True)
    if proc.returncode not in ok:
        detail = (proc.stderr or proc.stdout or "").strip() if capture else ""
        raise CommandFailed(
            f"{' '.join(cmd)} exited {proc.returncode}"
            + (f"\n{detail}" if detail else "")
        )
    return proc


def _start_sudo_keepalive() -> None:
    def loop() -> None:
        while not _keepalive_stop.wait(SUDO_KEEPALIVE_SECONDS):
            subprocess.run(["sudo", "-n", "-v"], capture_output=True)

    threading.Thread(target=loop, daemon=True).start()
    atexit.register(_keepalive_stop.set)


def ensure_sudo() -> list[str]:
    """Authenticate once, up front. Returns the prefix for privileged commands."""
    if os.geteuid() == 0:
        return []
    if shutil.which("sudo") is None:
        raise DependencyMissing("sudo not found and not running as root")

    if subprocess.run(["sudo", "-n", "-v"], capture_output=True).returncode != 0:
        print("[*] Root is needed for firmware updates; authenticating once.")
        # Deliberately uncaptured: the password prompt must reach the terminal.
        if subprocess.run(["sudo", "-v"]).returncode != 0:
            raise DependencyMissing("could not obtain sudo credentials")

    _start_sudo_keepalive()
    return ["sudo", "-n"]


def _ensure_fwupd(sudo: Sequence[str]) -> None:
    if shutil.which("fwupdmgr"):
        return
    print("[warn] fwupdmgr not on PATH; installing fwupd")
    try:
        _run([*sudo, "pacman", "-S", "--needed", "--noconfirm", "fwupd"], capture=False)
    except CommandFailed as err:
        raise DependencyMissing(
            f"could not install fwupd ({err}). "
            "If the package database is stale, run 'sudo pacman -Syu' first."
        ) from err
    if shutil.which("fwupdmgr") is None:
        raise DependencyMissing("fwupd installed but fwupdmgr is still not on PATH")


def update_firmware(sudo: Sequence[str] | None = None) -> None:
    sudo = ensure_sudo() if sudo is None else sudo
    _ensure_fwupd(sudo)

    _run(["fwupdmgr", "refresh", "--force"], ok=(0, NOTHING_TO_DO), capture=False)

    pending = _run(["fwupdmgr", "get-updates"], ok=(0, NOTHING_TO_DO))
    if pending.returncode == NOTHING_TO_DO:
        print("[*] firmware is current")
        return
    print(pending.stdout.strip())

    _run(
        [*sudo, "fwupdmgr", "update", "--assume-yes", "--no-reboot-check"],
        ok=(0, NOTHING_TO_DO),
        capture=False,  # stream progress; these runs take minutes
    )
    print("[*] firmware updated — some devices apply changes on next reboot")
