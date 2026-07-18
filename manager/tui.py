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
  Export= pacman.export()          (snapshot installed packages)

Note on progress bars: tqdm draws straight to the real terminal with carriage
returns, which corrupts a full-screen Textual app. So the CLI path in main.py
uses tqdm, and the TUI uses Textual's native ProgressBar for the same work
(both consume the same linker.Step generators). Per-package results still stream
into the log here, so you get the tqdm-style running feedback either way.

Theme: a dark palette modeled on the "Posting" API client's UI — deep navy
background, a bright green GET/success accent, coral red for destructive
actions, amber/orange for the middle actions, and lavender/cyan for
structural chrome (borders, tab labels, tree text). Registered as a real
Textual Theme so built-in widgets pick it up too, not just the custom CSS.
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "src"))
from textual.app import App, ComposeResult
from textual.containers import Horizontal, Vertical
from textual.theme import Theme
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

import linker  # noqa: E402
import pacman  # noqa: E402

# --------------------------------------------------------------------------- #
# "Posting"-inspired dark palette
# Deep navy base with a bright green/cyan/coral/amber/lavender accent set,
# sampled from a reference screenshot of the Posting API client.
# --------------------------------------------------------------------------- #
POSTING = {
    # backgrounds, darkest to lightest
    "crust": "#020D1A",
    "base": "#041B31",
    "mantle": "#0A2540",
    "surface0": "#123152",
    "surface1": "#1B4066",
    "surface2": "#28577F",
    # text
    "text": "#E8EDF2",
    "subtext1": "#9FB3C8",
    "subtext0": "#7189A0",
    "overlay0": "#5A7186",
    # accents (method / verb colors, matching the reference)
    "green": "#3DDC97",  # GET
    "green_bright": "#00E5A0",
    "red": "#FF6B7A",  # DELETE
    "orange": "#FFA45B",  # POST
    "yellow": "#F5D76E",  # PUT
    "purple": "#B39DDB",  # collection tree text
    "purple_bright": "#C792EA",  # JSON keys
    "cyan": "#4FD8E8",  # active tab / headers
    "sky": "#5AC8E8",
}

POSTING_DARK = Theme(
    name="posting-dark",
    primary=POSTING["cyan"],
    secondary=POSTING["purple"],
    accent=POSTING["green"],
    warning=POSTING["yellow"],
    error=POSTING["red"],
    success=POSTING["green"],
    background=POSTING["base"],
    surface=POSTING["mantle"],
    panel=POSTING["surface0"],
    boost=POSTING["surface1"],
    dark=True,
    variables={
        "foreground": POSTING["text"],
        "block-cursor-foreground": POSTING["base"],
        "block-cursor-background": POSTING["green"],
        "input-selection-background": f"{POSTING['cyan']} 35%",
        "footer-key-foreground": POSTING["green"],
        "footer-description-foreground": POSTING["subtext1"],
        "scrollbar": POSTING["surface1"],
        "scrollbar-hover": POSTING["surface2"],
        "scrollbar-active": POSTING["cyan"],
        "border": POSTING["surface1"],
    },
)


class ManagerApp(App):
    CSS = f"""
    Screen {{
        layout: vertical;
        background: $background;
    }}

    Header {{
        background: {POSTING["crust"]};
        color: {POSTING["text"]};
    }}
    Header .header--title {{
        color: {POSTING["green"]};
        text-style: bold;
    }}

    Footer {{
        background: {POSTING["crust"]};
    }}

    #body {{ height: 1fr; padding: 1 1 0 1; }}

    #left {{
        width: 42%;
        border: round {POSTING["surface1"]};
        border-title-color: {POSTING["purple"]};
        border-title-style: bold;
        background: {POSTING["mantle"]};
        padding: 0 1;
        margin-right: 1;
    }}

    #right {{
        width: 1fr;
        border: round {POSTING["surface1"]};
        border-title-color: {POSTING["cyan"]};
        border-title-style: bold;
        background: {POSTING["mantle"]};
        padding: 0 1;
    }}

    #left > Label, #right > Label {{
        color: {POSTING["subtext1"]};
        text-style: bold;
        padding: 0 0 1 0;
    }}

    SelectionList {{
        height: 1fr;
        background: {POSTING["mantle"]};
        scrollbar-color: {POSTING["surface1"]};
        scrollbar-color-hover: {POSTING["surface2"]};
        scrollbar-color-active: {POSTING["cyan"]};
    }}

    SelectionList > .selection-list--option-highlighted {{
        background: {POSTING["surface0"]};
        color: {POSTING["text"]};
    }}

    SelectionList > .selection-list--button-selected {{
        color: {POSTING["green"]};
    }}

    RichLog {{
        height: 1fr;
        background: {POSTING["mantle"]};
        color: {POSTING["text"]};
        scrollbar-color: {POSTING["surface1"]};
        scrollbar-color-hover: {POSTING["surface2"]};
        scrollbar-color-active: {POSTING["cyan"]};
    }}

    #controls {{
        height: auto;
        padding: 1 2;
        margin: 1;
        border: round {POSTING["surface1"]};
        background: {POSTING["mantle"]};
    }}

    #bar {{
        height: 1;
        margin-bottom: 1;
    }}

    #bar Bar {{
        color: {POSTING["green"]};
        background: {POSTING["surface0"]};
    }}

    #bar PercentageStatus {{
        color: {POSTING["subtext0"]};
    }}

    .row {{
        height: auto;
        align: left middle;
    }}

    Button {{
        margin: 0 1 0 0;
        min-width: 12;
        border: none;
        text-style: bold;
        background: {POSTING["surface0"]};
        color: {POSTING["text"]};
    }}

    Button:focus {{
        text-style: bold reverse;
    }}

    /* Method-colored buttons, matching GET/POST/PUT/DELETE verb coloring
       from the reference UI. */
    #link {{
        background: {POSTING["green"]};
        color: {POSTING["crust"]};
    }}
    #link:hover {{ background: {POSTING["green_bright"]}; }}

    #break {{
        background: {POSTING["red"]};
        color: {POSTING["crust"]};
    }}
    #break:hover {{ background: #FF8B96; }}

    #copy {{
        background: {POSTING["cyan"]};
        color: {POSTING["crust"]};
    }}
    #copy:hover {{ background: {POSTING["sky"]}; }}

    #export {{
        background: {POSTING["orange"]};
        color: {POSTING["crust"]};
    }}
    #export:hover {{ background: {POSTING["yellow"]}; }}

    #toggle, #refresh {{
        background: {POSTING["surface1"]};
        color: {POSTING["text"]};
    }}
    #toggle:hover, #refresh:hover {{
        background: {POSTING["surface2"]};
    }}

    #dry {{
        width: auto;
        color: {POSTING["subtext1"]};
        padding: 0 1;
        content-align: center middle;
    }}

    Switch {{
        background: {POSTING["surface0"]};
    }}
    Switch > .switch--slider {{
        color: {POSTING["surface1"]};
        background: {POSTING["crust"]};
    }}
    """

    BINDINGS = [
        ("l", "link", "Link"),
        ("b", "break_", "Break"),
        ("c", "copy", "Copy"),
        ("e", "export", "Export pkgs"),
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
                yield Button("Link", id="link")
                yield Button("Break", id="break")
                yield Button("Copy", id="copy")
                yield Button("Export", id="export")
                yield Button("All/None", id="toggle")
                yield Button("Refresh", id="refresh")
                yield Label("  Dry run", id="dry")
                yield Switch(id="dry_switch")
        yield Footer()

    def on_mount(self) -> None:
        self.register_theme(POSTING_DARK)
        self.theme = "posting-dark"

        left = self.query_one("#left", Vertical)
        left.border_title = "packages"
        right = self.query_one("#right", Vertical)
        right.border_title = "log"

        self.refresh_packages()
        self.log_line(f"[{POSTING['overlay0']}]stow-dir:[/] {self.paths.stow_dir}")
        self.log_line(f"[{POSTING['overlay0']}]target:  [/] {self.paths.target}")

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
            self.log_line(f"[{POSTING['red']}]{exc}[/]")
            return
        previously = set(sel.selected)
        sel.clear_options()
        for pkg in pkgs:
            linked = linker.is_stowed(pkg, self.paths)
            tag = (
                f"[{POSTING['green']}]●[/]"
                if linked
                else f"[{POSTING['overlay0']}]○[/]"
            )
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
            "export": self.action_export,
            "toggle": self.action_toggle_all,
            "refresh": self.action_refresh,
        }[event.button.id]()

    def action_refresh(self) -> None:
        self.refresh_packages()
        self.log_line(f"[{POSTING['overlay0']}]refreshed[/]")

    def action_toggle_all(self) -> None:
        sel = self.query_one("#packages", SelectionList)
        if sel.selected:
            sel.deselect_all()
        else:
            sel.select_all()

    def action_link(self) -> None:
        pkgs = self.selected_pkgs()
        if not pkgs:
            self.log_line(f"[{POSTING['yellow']}]nothing selected[/]")
            return
        self._run(
            "link",
            lambda: linker.restow_all(
                self.paths, pkgs, adopt=True, dry_run=self.dry_run
            ),
        )

    def action_break_(self) -> None:
        pkgs = self.selected_pkgs()
        if not pkgs:
            self.log_line(f"[{POSTING['yellow']}]nothing selected[/]")
            return
        self._run(
            "break", lambda: linker.break_all(self.paths, pkgs, dry_run=self.dry_run)
        )

    def action_copy(self) -> None:
        pkgs = self.selected_pkgs()
        if len(pkgs) != 1:
            self.log_line(
                f"[{POSTING['yellow']}]select exactly one package for copy[/]"
            )
            return
        pkg = pkgs[0]

        def gen():
            try:
                dest = linker.direct_symlink(pkg, self.paths, dry_run=self.dry_run)
                yield linker.Step(pkg, 1, 1, "copy", ok=True, message=str(dest))
            except linker.LinkerError as exc:
                yield linker.Step(pkg, 1, 1, "copy", ok=False, message=str(exc))

        self._run("copy", gen)

    def action_export(self) -> None:
        out_dir = self.paths.stow_dir.parent / "packages"

        def gen():
            if self.dry_run:
                yield linker.Step(
                    "pacman",
                    1,
                    1,
                    "export",
                    ok=True,
                    message=f"(dry run) would write to {out_dir}",
                )
                return
            try:
                result = pacman.export(out_dir)
                msg = (
                    f"{result.explicit_count} explicit, "
                    f"{result.foreign_count} foreign -> {out_dir}"
                )
                yield linker.Step("pacman", 1, 1, "export", ok=True, message=msg)
            except pacman.PacmanError as exc:
                yield linker.Step("pacman", 1, 1, "export", ok=False, message=str(exc))

        self._run("export", gen)

    # ------------------------------------------------------------------ #
    # worker plumbing
    # ------------------------------------------------------------------ #
    def _run(self, name: str, make_generator) -> None:
        if self.dry_run:
            self.log_line(f"[bold {POSTING['sky']}]— {name} (dry run) —[/]")
        else:
            self.log_line(f"[bold {POSTING['purple']}]— {name} —[/]")
        self._disable(True)
        self.run_worker(
            lambda: self._work(make_generator()),
            name=name,
            thread=True,
            exclusive=True,
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
        mark = f"[{POSTING['green']}]✓[/]" if step.ok else f"[{POSTING['red']}]✗[/]"
        line = f"{mark} {step.action:<7} {step.pkg}"
        if step.message:
            line += f"  [{POSTING['overlay0']}]{step.message}[/]"
        self.log_line(line)
        bar.advance(1)

    def on_worker_state_changed(self, event: Worker.StateChanged) -> None:
        if event.state in (
            WorkerState.SUCCESS,
            WorkerState.ERROR,
            WorkerState.CANCELLED,
        ):
            self._disable(False)
            if event.state == WorkerState.SUCCESS:
                self.log_line(f"[bold {POSTING['green']}]done[/]")
                self.refresh_packages()
            elif event.state == WorkerState.ERROR:
                self.log_line(
                    f"[{POSTING['red']}]worker error: {event.worker.error}[/]"
                )

    def _disable(self, busy: bool) -> None:
        for bid in ("link", "break", "copy", "export", "toggle", "refresh"):
            self.query_one(f"#{bid}", Button).disabled = busy


if __name__ == "__main__":
    ManagerApp(linker.Paths.default()).run()
