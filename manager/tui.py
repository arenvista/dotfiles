"""
tui.py — Textual UI for the dotfiles manager.

Layout:
  left   : checkbox list of packages (with live link/unlink status)
  right  : scrolling log of what happened
  bottom : progress bar + action buttons

Actions map 1:1 to the shell scripts / linker ops:
  Link  = restow_all(adopt=True)   (symlinks.sh)
  Break = break_all()              (breaklinks.sh)
  Copy  = direct_symlink()         (copy.sh, selected package)

Note on progress bars: tqdm draws straight to the real terminal with carriage
returns, which corrupts a full-screen Textual app. So the CLI path in main.py
uses tqdm, and the TUI uses Textual's native ProgressBar for the same work
(both consume the same linker.Step generators). Per-package results still stream
into the log here, so you get the tqdm-style running feedback either way.
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "src"))
import linker  # noqa: E402

from textual.app import App, ComposeResult
from textual.containers import Horizontal, Vertical
from textual.widgets import (
    Button,
    Footer,
    Header,
    Label,
    ProgressBar,
    RichLog,
    SelectionList,
    Switch,
)
from textual.widgets.selection_list import Selection
from textual.worker import Worker, WorkerState


class ManagerApp(App):
    CSS = """
    Screen { layout: vertical; }
    #body { height: 1fr; }
    #left { width: 42%; border: round $accent; padding: 0 1; }
    #right { width: 1fr; border: round $primary; padding: 0 1; }
    SelectionList { height: 1fr; }
    RichLog { height: 1fr; }
    #controls { height: auto; padding: 1 1; border: round $secondary; }
    #bar { height: 1; margin-bottom: 1; }
    .row { height: auto; }
    Button { margin: 0 1; min-width: 12; }
    #dry { width: auto; }
    """

    BINDINGS = [
        ("l", "link", "Link"),
        ("b", "break_", "Break"),
        ("c", "copy", "Copy"),
        ("a", "toggle_all", "All/None"),
        ("r", "refresh", "Refresh"),
        ("q", "quit", "Quit"),
    ]

    def __init__(self, paths: linker.Paths):
        super().__init__()
        self.paths = paths

    # ------------------------------------------------------------------ #
    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        with Horizontal(id="body"):
            with Vertical(id="left"):
                yield Label("Packages  (space = toggle)")
                yield SelectionList(id="packages")
            with Vertical(id="right"):
                yield Label("Log")
                yield RichLog(id="log", highlight=True, markup=True, wrap=True)
        with Vertical(id="controls"):
            yield ProgressBar(id="bar", total=100, show_eta=False)
            with Horizontal(classes="row"):
                yield Button("Link", id="link", variant="success")
                yield Button("Break", id="break", variant="error")
                yield Button("Copy", id="copy", variant="primary")
                yield Button("All/None", id="toggle")
                yield Button("Refresh", id="refresh")
                yield Label("  Dry run", id="dry")
                yield Switch(id="dry_switch")
        yield Footer()

    def on_mount(self) -> None:
        self.refresh_packages()
        self.log_line(f"[dim]stow-dir:[/] {self.paths.stow_dir}")
        self.log_line(f"[dim]target:  [/] {self.paths.target}")

    # ------------------------------------------------------------------ #
    # helpers
    # ------------------------------------------------------------------ #
    @property
    def dry_run(self) -> bool:
        return self.query_one("#dry_switch", Switch).value

    def log_line(self, text: str) -> None:
        self.query_one("#log", RichLog).write(text)

    def refresh_packages(self) -> None:
        sel = self.query_one("#packages", SelectionList)
        try:
            pkgs = linker.list_packages(self.paths)
        except linker.LinkerError as exc:
            self.log_line(f"[red]{exc}[/]")
            return
        previously = set(sel.selected)
        sel.clear_options()
        for pkg in pkgs:
            linked = linker.is_stowed(pkg, self.paths)
            tag = "[green]●[/]" if linked else "[dim]○[/]"
            sel.add_option(Selection(f"{tag} {pkg}", pkg, pkg in previously))

    def selected_pkgs(self) -> list[str]:
        return list(self.query_one("#packages", SelectionList).selected)

    # ------------------------------------------------------------------ #
    # buttons / bindings
    # ------------------------------------------------------------------ #
    def on_button_pressed(self, event: Button.Pressed) -> None:
        {
            "link": self.action_link,
            "break": self.action_break_,
            "copy": self.action_copy,
            "toggle": self.action_toggle_all,
            "refresh": self.action_refresh,
        }[event.button.id]()

    def action_refresh(self) -> None:
        self.refresh_packages()
        self.log_line("[dim]refreshed[/]")

    def action_toggle_all(self) -> None:
        sel = self.query_one("#packages", SelectionList)
        if sel.selected:
            sel.deselect_all()
        else:
            sel.select_all()

    def action_link(self) -> None:
        pkgs = self.selected_pkgs()
        if not pkgs:
            self.log_line("[yellow]nothing selected[/]")
            return
        self._run("link", lambda: linker.restow_all(
            self.paths, pkgs, adopt=True, dry_run=self.dry_run))

    def action_break_(self) -> None:
        pkgs = self.selected_pkgs()
        if not pkgs:
            self.log_line("[yellow]nothing selected[/]")
            return
        self._run("break", lambda: linker.break_all(
            self.paths, pkgs, dry_run=self.dry_run))

    def action_copy(self) -> None:
        pkgs = self.selected_pkgs()
        if len(pkgs) != 1:
            self.log_line("[yellow]select exactly one package for copy[/]")
            return
        pkg = pkgs[0]

        def gen():
            try:
                dest = linker.direct_symlink(pkg, self.paths, dry_run=self.dry_run)
                yield linker.Step(pkg, 1, 1, "copy", ok=True, message=str(dest))
            except linker.LinkerError as exc:
                yield linker.Step(pkg, 1, 1, "copy", ok=False, message=str(exc))

        self._run("copy", gen)

    # ------------------------------------------------------------------ #
    # worker plumbing
    # ------------------------------------------------------------------ #
    def _run(self, name: str, make_generator) -> None:
        if self.dry_run:
            self.log_line(f"[bold cyan]— {name} (dry run) —[/]")
        else:
            self.log_line(f"[bold]— {name} —[/]")
        self._disable(True)
        self.run_worker(
            lambda: self._work(make_generator()),
            name=name, thread=True, exclusive=True,
        )

    def _work(self, generator) -> None:
        bar = self.query_one("#bar", ProgressBar)
        first = True
        for step in generator:
            if first:
                self.call_from_thread(bar.update, total=step.total, progress=0)
                first = False
            self.call_from_thread(self._report, step, bar)

    def _report(self, step: "linker.Step", bar: ProgressBar) -> None:
        mark = "[green]✓[/]" if step.ok else "[red]✗[/]"
        line = f"{mark} {step.action:<7} {step.pkg}"
        if step.message:
            line += f"  [dim]{step.message}[/]"
        self.log_line(line)
        bar.advance(1)

    def on_worker_state_changed(self, event: Worker.StateChanged) -> None:
        if event.state in (WorkerState.SUCCESS, WorkerState.ERROR, WorkerState.CANCELLED):
            self._disable(False)
            if event.state == WorkerState.SUCCESS:
                self.log_line("[bold green]done[/]")
                self.refresh_packages()
            elif event.state == WorkerState.ERROR:
                self.log_line(f"[red]worker error: {event.worker.error}[/]")

    def _disable(self, busy: bool) -> None:
        for bid in ("link", "break", "copy", "toggle", "refresh"):
            self.query_one(f"#{bid}", Button).disabled = busy


if __name__ == "__main__":
    ManagerApp(linker.Paths.default()).run()
