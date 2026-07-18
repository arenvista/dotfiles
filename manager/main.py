#!/usr/bin/env python3
"""
main.py — front-end for src/linker.py

CLI (tqdm progress bars):
  main.py list                     list packages + stow status
  main.py link  [pkg ...]          stow -D then stow --adopt   (symlinks.sh)
  main.py break [pkg ...]          unstow + rm ~/.config/pkg   (breaklinks.sh)
  main.py copy  [pkg]              direct symlink, no stow      (copy.sh)
  main.py export [--out DIR]       snapshot installed pacman packages to files
  main.py tui                      launch the Textual UI

Global flags: --stow-dir, --target, --dry-run
`link`/`break`: --no-adopt (link only)
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "src"))
import linker  # noqa: E402
import pacman  # noqa: E402

try:
    from tqdm import tqdm
except ImportError:  # pragma: no cover
    tqdm = None


def _bar(iterable, total, desc):
    """Wrap a generator of linker.Step in tqdm if available, else plain."""
    if tqdm is None:
        for step in iterable:
            _echo_step(step)
            yield step
        return
    with tqdm(total=total, desc=desc, unit="pkg", colour="cyan") as pb:
        for step in iterable:
            pb.set_postfix_str(step.pkg, refresh=False)
            _echo_step(step, via=pb)
            pb.update(1)
            yield step


def _echo_step(step: "linker.Step", via=None) -> None:
    mark = "✓" if step.ok else "✗"
    line = f"  {mark} {step.action:<7} {step.pkg}"
    if not step.ok and step.message:
        line += f"  ({step.message})"
    (via.write if via is not None else print)(line)


def pick_package(paths: "linker.Paths") -> str:
    """Interactive picker: fzf if present (like copy.sh), else numbered menu."""
    packages = linker.list_packages(paths)
    if not packages:
        print("No packages found.", file=sys.stderr)
        sys.exit(1)

    if shutil.which("fzf"):
        result = subprocess.run(
            ["fzf"], input="\n".join(packages), capture_output=True, text=True
        )
        choice = result.stdout.strip()
        if not choice:
            print("No package selected.", file=sys.stderr)
            sys.exit(1)
        return choice

    print("Packages:")
    for i, pkg in enumerate(packages, 1):
        print(f"  {i}) {pkg}")
    choice = input("Select a package (number or name): ").strip()
    if choice.isdigit() and 1 <= int(choice) <= len(packages):
        return packages[int(choice) - 1]
    if choice in packages:
        return choice
    print(f"Invalid selection: {choice}", file=sys.stderr)
    sys.exit(1)


# --------------------------------------------------------------------------- #
# subcommands
# --------------------------------------------------------------------------- #


def cmd_list(args, paths):
    for pkg in linker.list_packages(paths):
        status = "linked " if linker.is_stowed(pkg, paths) else "unlinked"
        print(f"  [{status}] {pkg}")


def cmd_break(args, paths):
    pkgs = args.packages or linker.list_packages(paths)
    print("--- Breaking links (unstow + clean) ---")
    fails = [
        s
        for s in _bar(
            linker.break_all(paths, pkgs, dry_run=args.dry_run), len(pkgs), "break"
        )
        if not s.ok
    ]
    _finish(fails, args.dry_run)


def cmd_link(args, paths):
    pkgs = args.packages or linker.list_packages(paths)
    print("--- Stowing packages ---")
    fails = [
        s
        for s in _bar(
            linker.restow_all(
                paths, pkgs, adopt=not args.no_adopt, dry_run=args.dry_run
            ),
            len(pkgs),
            "link",
        )
        if not s.ok
    ]
    _finish(fails, args.dry_run)


def cmd_copy(args, paths):
    pkg = args.package or pick_package(paths)
    print(f"Copying {pkg} (direct symlink)...")
    dest = linker.direct_symlink(pkg, paths, dry_run=args.dry_run)
    print(f"  {dest} -> {paths.stow_dir / pkg / '.config' / pkg}")
    _finish([], args.dry_run)


def cmd_export(args, paths):
    out_dir = args.out or (paths.stow_dir.parent / "packages")
    print(f"--- Exporting installed pacman packages to {out_dir} ---")
    try:
        result = pacman.export(out_dir)
    except pacman.PacmanError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)
    print(f"  {result.explicit_path}  ({result.explicit_count} packages)")
    print(f"  {result.foreign_path}  ({result.foreign_count} foreign/AUR)")
    print("Done!")


def cmd_tui(args, paths):
    try:
        from tui import ManagerApp
    except ImportError as exc:
        print(f"Textual not available: {exc}\nInstall with: uv sync", file=sys.stderr)
        sys.exit(1)
    ManagerApp(paths).run()


def _finish(fails, dry_run):
    if dry_run:
        print("(dry run — nothing changed)")
    if fails:
        print(f"Done with {len(fails)} error(s).")
    else:
        print("Done!")


# --------------------------------------------------------------------------- #


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="main.py", description="Manage dotfile symlinks (stow-based)."
    )
    parser.add_argument(
        "--stow-dir",
        type=Path,
        default=None,
        help="Directory containing packages (default: <repo>/stowables)",
    )
    parser.add_argument(
        "--target",
        type=Path,
        default=None,
        help="Symlink target directory (default: $HOME)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would happen without touching the filesystem",
    )

    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("list", help="List packages and their link status").set_defaults(
        func=cmd_list
    )

    p_break = sub.add_parser("break", help="Unstow & remove links (breaklinks.sh)")
    p_break.add_argument(
        "packages", nargs="*", help="Specific package(s); default: all"
    )
    p_break.set_defaults(func=cmd_break)

    p_link = sub.add_parser("link", help="Stow --adopt every package (symlinks.sh)")
    p_link.add_argument("packages", nargs="*", help="Specific package(s); default: all")
    p_link.add_argument(
        "--no-adopt", action="store_true", help="Plain stow, skip --adopt"
    )
    p_link.set_defaults(func=cmd_link)

    p_copy = sub.add_parser("copy", help="Direct symlink one package (copy.sh)")
    p_copy.add_argument(
        "package", nargs="?", help="Package name; omit to pick interactively"
    )
    p_copy.set_defaults(func=cmd_copy)

    p_export = sub.add_parser(
        "export", help="Snapshot installed pacman packages to text files"
    )
    p_export.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Output directory (default: <repo>/packages)",
    )
    p_export.set_defaults(func=cmd_export)

    sub.add_parser("tui", help="Launch the Textual UI").set_defaults(func=cmd_tui)
    return parser


def main(argv=None):
    args = build_parser().parse_args(argv)

    paths = linker.Paths.default()
    if args.stow_dir:
        paths.stow_dir = args.stow_dir
    if args.target:
        paths.target = args.target

    try:
        args.func(args, paths)
    except linker.LinkerError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
