"""
linker.py

Core logic for creating and destroying dotfile symlinks.

This wraps GNU `stow` (used by symlinks.sh / breaklinks.sh) and also supports
"direct" symlinks (used by copy.sh) for the rare package you want linked
straight from the repo instead of stow-managed.

Everything operates on a `stow_dir` (the folder full of packages, e.g.
dotfiles/stowables) and a `target` directory (normally $HOME).

The batch operations (`break_all`, `restow_all`) are generators: they yield a
`Step` per package as work happens, so a caller can drive a tqdm bar, a Textual
ProgressBar, or just print. Nothing here imports a UI library.
"""

from __future__ import annotations

import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator, Optional


class LinkerError(RuntimeError):
    """Raised when a stow/link operation fails."""


@dataclass
class Paths:
    stow_dir: Path  # e.g. ~/dotfiles/stowables
    target: Path  # e.g. ~ (HOME)

    @classmethod
    def default(cls) -> "Paths":
        # manager/src/linker.py -> manager -> repo root -> stowables
        repo_root = Path(__file__).resolve().parent.parent.parent
        return cls(stow_dir=repo_root / "stowables", target=Path.home())


@dataclass
class Step:
    """One unit of progress in a batch operation."""

    pkg: str
    index: int  # 1-based
    total: int
    action: str  # "stow", "unstow", "copy"
    ok: bool = True
    message: str = ""


# --------------------------------------------------------------------------- #
# Package discovery / status
# --------------------------------------------------------------------------- #


# Marker files like .tm1/.tm2 and other dotfiles at the top of stowables/ are
# not packages, so we skip anything starting with a dot.
def list_packages(paths: Paths) -> list[str]:
    """Every stowable package = every non-hidden directory directly under stow_dir."""
    if not paths.stow_dir.is_dir():
        raise LinkerError(f"stow dir not found: {paths.stow_dir}")
    return sorted(
        p.name
        for p in paths.stow_dir.iterdir()
        if p.is_dir() and not p.name.startswith(".")
    )


def _config_link(pkg: str, paths: Paths) -> Path:
    """Where a `.config`-style package lands: ~/.config/<pkg>."""
    return paths.target / ".config" / pkg


def is_stowed(pkg: str, paths: Paths) -> bool:
    """
    Heuristic status: True if ~/.config/<pkg> is a symlink pointing back into
    the repo. Covers the common `.config/<pkg>` layout (the majority of your
    packages) plus copy.sh-style direct links. Home-level packages (bash, zsh,
    tmux) don't have a single predictable path, so they report False here.
    """
    dest = _config_link(pkg, paths)
    if not dest.is_symlink():
        return False
    try:
        return paths.stow_dir in dest.resolve().parents
    except OSError:
        return False


# --------------------------------------------------------------------------- #
# stow wrappers
# --------------------------------------------------------------------------- #


def _run_stow(args: list[str], paths: Paths) -> None:
    if shutil.which("stow") is None:
        raise LinkerError("`stow` is not installed / not on PATH")
    cmd = ["stow", *args, "-d", str(paths.stow_dir), "-t", str(paths.target)]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise LinkerError(result.stderr.strip() or f"stow failed: {' '.join(cmd)}")


def unstow(
    pkg: str, paths: Paths, *, quiet: bool = True, dry_run: bool = False
) -> None:
    """`stow -D pkg -t ~`. Swallows errors by default (a package that was never
    stowed shouldn't halt a batch)."""
    if dry_run:
        return
    try:
        _run_stow(["-D", pkg], paths)
    except LinkerError:
        if not quiet:
            raise


def stow_pkg(
    pkg: str, paths: Paths, *, adopt: bool = False, dry_run: bool = False
) -> None:
    """`stow pkg -t ~ [--adopt]`."""
    if dry_run:
        return
    args = ["--adopt", pkg] if adopt else [pkg]
    _run_stow(args, paths)


def _remove_path(path: Path, *, dry_run: bool = False) -> None:
    if dry_run:
        return
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.exists():
        shutil.rmtree(path)


# --------------------------------------------------------------------------- #
# High-level operations (mirror the three shell scripts)
# --------------------------------------------------------------------------- #


def break_link(
    pkg: str, paths: Paths, *, remove_config: bool = True, dry_run: bool = False
) -> None:
    """
    breaklinks.sh for one package:
      1. stow -D pkg -t ~     (remove existing stow symlinks)
      2. rm -rf ~/.config/pkg (clean up whatever's left)
    """
    unstow(pkg, paths, quiet=True, dry_run=dry_run)
    if remove_config:
        _remove_path(_config_link(pkg, paths), dry_run=dry_run)


def break_all(
    paths: Paths,
    packages: Optional[list[str]] = None,
    *,
    dry_run: bool = False,
) -> Iterator[Step]:
    """breaklinks.sh: unstow + clean every (selected) package."""
    pkgs = packages or list_packages(paths)
    total = len(pkgs)
    for i, pkg in enumerate(pkgs, 1):
        try:
            break_link(pkg, paths, dry_run=dry_run)
            yield Step(pkg, i, total, "unstow", ok=True)
        except LinkerError as exc:
            yield Step(pkg, i, total, "unstow", ok=False, message=str(exc))


def restow_all(
    paths: Paths,
    packages: Optional[list[str]] = None,
    *,
    adopt: bool = True,
    dry_run: bool = False,
) -> Iterator[Step]:
    """
    symlinks.sh: for every (selected) package, `stow -D` then `stow [--adopt]`.
    --adopt pulls any pre-existing real files into the repo instead of refusing
    to overwrite them.
    """
    pkgs = packages or list_packages(paths)
    total = len(pkgs)
    for i, pkg in enumerate(pkgs, 1):
        try:
            unstow(pkg, paths, quiet=True, dry_run=dry_run)
            stow_pkg(pkg, paths, adopt=adopt, dry_run=dry_run)
            yield Step(pkg, i, total, "stow", ok=True)
        except LinkerError as exc:
            yield Step(pkg, i, total, "stow", ok=False, message=str(exc))


def direct_symlink(pkg: str, paths: Paths, *, dry_run: bool = False) -> Path:
    """
    copy.sh: bypass stow and point ~/.config/<pkg> straight at the package's
    inner config dir inside the repo.

      1. stow -D pkg -t ~
      2. rm -rf ~/.config/pkg
      3. ln -s <stow_dir>/<pkg>/.config/<pkg>  ~/.config/<pkg>

    (copy.sh linked the *inner* .config/<pkg>, not the package root, so this
    matches your real layout: stowables/nvim/.config/nvim -> ~/.config/nvim.)

    Returns the path of the created symlink.
    """
    inner = paths.stow_dir / pkg / ".config" / pkg
    if not inner.is_dir():
        raise LinkerError(
            f"copy only supports .config-style packages; not found: {inner}"
        )

    unstow(pkg, paths, quiet=True, dry_run=dry_run)

    dest = _config_link(pkg, paths)
    _remove_path(dest, dry_run=dry_run)

    if not dry_run:
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.symlink_to(inner, target_is_directory=True)
    return dest
