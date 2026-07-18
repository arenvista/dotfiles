"""
pacman.py — export the currently installed package list.

Writes two plain lists (one package name per line, sorted) so they're
diffable in git and easy to skim later:

  explicit.txt  — `pacman -Qqe`   explicitly installed packages (native + AUR)
  foreign.txt   — `pacman -Qqem`  foreign packages (AUR / manually built)

`explicit.txt` is the one you'd feed back into `pacman -S --needed -` to
rebuild a machine; `foreign.txt` is the subset of that which pacman can't
fetch itself (useful to know you need an AUR helper for those).

Nothing here is stow-related — this is a standalone snapshot utility, kept
separate from linker.py on purpose.
"""

from __future__ import annotations

import shutil
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


class PacmanError(RuntimeError):
    """Raised when pacman isn't available or a query fails."""


@dataclass
class ExportResult:
    explicit_path: Path
    foreign_path: Path
    explicit_count: int
    foreign_count: int


def _run_pacman(args: list[str]) -> list[str]:
    if shutil.which("pacman") is None:
        raise PacmanError("`pacman` is not installed / not on PATH")
    result = subprocess.run(["pacman", *args], capture_output=True, text=True)
    if result.returncode != 0:
        raise PacmanError(result.stderr.strip() or f"pacman failed: {' '.join(args)}")
    return sorted(line.strip() for line in result.stdout.splitlines() if line.strip())


def list_explicit() -> list[str]:
    """`pacman -Qqe` — explicitly installed packages (native + foreign)."""
    return _run_pacman(["-Qqe"])


def list_foreign() -> list[str]:
    """`pacman -Qqem` — foreign packages (not in a configured repo, e.g. AUR)."""
    return _run_pacman(["-Qqem"])


def export(out_dir: Path) -> ExportResult:
    """
    Write explicit.txt and foreign.txt into out_dir (created if needed).
    Each file starts with a `# generated <UTC timestamp>` comment line so you
    can tell at a glance how stale a snapshot is.
    """
    out_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%SZ")

    explicit = list_explicit()
    foreign = list_foreign()

    explicit_path = out_dir / "explicit.txt"
    foreign_path = out_dir / "foreign.txt"

    explicit_path.write_text(f"# generated {stamp}\n" + "\n".join(explicit) + "\n")
    foreign_path.write_text(f"# generated {stamp}\n" + "\n".join(foreign) + "\n")

    return ExportResult(
        explicit_path=explicit_path,
        foreign_path=foreign_path,
        explicit_count=len(explicit),
        foreign_count=len(foreign),
    )
