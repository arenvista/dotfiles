# Quickshell Config Improvement Plan

## Context

The quickshell config (`stowables/quickshell/.config/quickshell/`, stow-linked to `~/.config/quickshell`) works, but nearly everything is driven by shelling out to CLI tools (`playerctl`, `wpctl`, `nmcli`, `bluetoothctl`, `top`) on 1–2s polling timers, with `sleep`-based hacks for async operations. Quickshell 0.3.0 (installed) ships native, event-driven modules for all of these — verified present under `/usr/lib/qt6/qml/Quickshell/`: `Quickshell.Services.Mpris`, `Pipewire`, `UPower`, `Quickshell.Networking` (WifiDevice/WifiNetwork/`connectWithPsk`), `Quickshell.Bluetooth` (pair/connect/trust/forget), plus core `DesktopEntries`, `SystemClock`, `FileView`/`JsonAdapter`, and `Quickshell.Widgets` (`ClippingRectangle`, `IconImage`).

There are also concrete bugs: a `bash`+`md5sum` process spawned **per wallpaper thumbnail delegate** with a string-interpolated path (LauncherPanel.qml:499–511), command injection risk in the blur step (shell.qml:254–265), runtime state `app_usage.json` committed to the git repo (dirties the tree on every app launch), dashboard polling every 2s even while hidden, and dead/broken scripts.

Goal: migrate to native services (fewer processes, instant updates, ~large net code deletion), fix the bugs, extract shared UI components, and clean up the scripts — in phases, each independently verifiable via hot-reload.

**User approved all four scope areas.**

## Working rules (from memory)

- Editing repo files edits the live config (stow symlink); quickshell hot-reloads on save and keeps last-good on error.
- Validate: `qmllint -I /usr/lib/qt6/qml <file>` (exit 0 = clean); `QT_QPA_PLATFORM=offscreen timeout 4 qs -p shell.qml` ("No PanelWindow backend loaded" is EXPECTED; anything else is real); `qs log` grep `Reloading|reloadFailed|Failed to load`.
- Never string-interpolate dynamic values into `bash -c`; pass positional args.
- Commit per phase.

## Phase 1 — Bug & perf fixes (small, independent)

1. **Per-delegate md5 processes** — `components/LauncherPanel.qml:499–511`: delete `hashProc` entirely; set `property string thumbHash: Qt.md5(modelData.path)` on `wallThumbImage`. (Matches `create_thumbs.sh` hashing: md5 of the full path.) Also fixes the interpolation-into-bash violation.
2. **Blur-step injection** — `shell.qml` `walStepBlur` (~line 254): pass `wp` as a positional arg (`["bash","-c","convert \"$1\"... ","_", wp]`); handle the `[0]` gif-frame suffix inside the quoted arg (`\"$1\"'[0]'`).
3. **app_usage.json out of the repo** — add `state: home + "/.local/state/quickshell"` to `Common/Paths.qml`; point load/save in `shell.qml` (lines 151, 275) at `Paths.state + "/app_usage.json"` (mkdir -p on save). `git rm --cached stowables/quickshell/.config/quickshell/app_usage.json`, add to `.gitignore`, and migrate the existing file with a one-time `mv`.
4. **Dashboard polls while hidden** — `components/Dashboard.qml:623`: gate the 2s stats timer on `root.dashboardVisible`. Keep battery monitoring alive when hidden (low-battery notify must still fire): until Phase 3 replaces it with UPower, run `batProc`/`batStatusProc` from a separate always-on 30s timer.
5. **Hardcoded username** — `Dashboard.qml:146` `text: "Sybil"` → `Quickshell.env("USER")`.
6. **CPU poll uses `top -bn1`** (heavy) — `Dashboard.qml:642`: replace with `/proc/stat` delta: keep prev total/idle in QML properties, read via a cheap `Process` (`head -1 /proc/stat`) or FileView; compute usage % from deltas.

## Phase 2 — Shared UI components (Common/)

New components in `Common/`, registered in `Common/qmldir` (non-singleton entries: `StyledText 1.0 StyledText.qml` etc.):

- **`StyledText.qml`** — `Text { color: Theme.foreground; font.family: Theme.fontFamily; font.pixelSize: 13 }`. Replaces ~80 Text blocks that all repeat `font.family: Theme.fontFamily`.
- **`Card.qml`** — `Rectangle { color: Qt.rgba(0,0,0,0.3); radius: 15 }` (radius overridable). Used ~15× across Dashboard/Launcher/Wifi/Bt panels.
- **`ToggleSwitch.qml`** — the 44×24 iOS-style toggle currently duplicated verbatim in `WifiPanel.qml:45–65` and `BluetoothPanel.qml:45–70`. API: `property bool checked; signal toggled()`.
- **`ValueSlider.qml`** — the icon + bar + % row duplicated for volume and brightness in `Dashboard.qml:350–477`. API: `icon`, `barColor`, `value`, `signal moved(int percent)` (single MouseArea handling click+drag — also de-dupes the copy-pasted onClicked/onPositionChanged bodies).
- **`HintBar.qml`** (optional, low priority) — the keyboard-hint footer duplicated at `LauncherPanel.qml:317–334` and `590–607`.

Mechanical replacement across the five components; no behavior change. Verify with qmllint + hot-reload after each file.

## Phase 3 — Native services migration (per-panel, one commit each)

Order: least → most invasive. After each panel, the corresponding `Process`/`Timer` blocks and root state in `shell.qml` are deleted.

### 3a. Theme / pywal colors (self-contained Theme)
Move wal-color loading into `Common/Theme.qml`: a `FileView` on `Paths.home + "/.cache/wal/colors.json"` with `watchChanges: true`; parse in `onLoaded`/`onFileChanged` and set all palette colors (load **all 16** colors0–15 via loop into a `property var palette` while keeping the existing named aliases). Delete `walColorsProc` from shell.qml. Bonus: colors now live-update even when pywal runs outside the shell.

### 3b. Dashboard internals
- **Clock**: `SystemClock { precision: SystemClock.Seconds }` + `Qt.formatTime(clock.date, "hh:mm:ss AP")` / `Qt.formatDate` — delete the manual-formatting 1s Timer (Dashboard.qml:602–621).
- **Battery**: `Quickshell.Services.UPower` — `UPower.displayDevice.percentage`, `.state` (charging/discharging), `.timeToEmpty`. Event-driven; low-battery notify logic keeps `checkLowBattery()` but triggers on property change, no polling. Delete `batProc`/`batStatusProc` + icon-threshold chain (compute icon from percentage in a small function).
- **Volume**: `Quickshell.Services.Pipewire` — `Pipewire.defaultAudioSink` + `PwObjectTracker`; bind slider to `sink.audio.volume`, mute via `sink.audio.muted = !muted`. Delete `volProc`/`volSetProc`/`volMuteProc` and polling.
- **Brightness**: no native service — keep `brightnessctl`, but poll only while dashboard visible (done in Phase 1).
- **Uptime**: read `/proc/uptime` via FileView on the visible-gated timer instead of spawning `uptime -p`; format in QML.
- CPU/RAM/disk stay as (cheap) processes on the visible-gated timer.

### 3c. MusicPanel
`Quickshell.Services.Mpris`: `property var player: Mpris.players.values[0] ?? null` (or track active player). Bind title/artist/length/`isPlaying` directly; controls call `player.togglePlaying()`, `.next()`, `.previous()`, `player.position = x` for seek. Position: `player.position` with a 1s `FrameAnimation`-free refresh (`positionChanged` + small visible-gated timer calling `player.positionChanged()` if needed). Delete all 8 playerctl Processes + `playerPollTimer`. Gif selector logic unchanged. Optionally show `player.trackArtUrl` later (out of scope).

### 3d. WifiPanel
`Quickshell.Networking`: `Networking.wifiDevice` (or first `WifiDevice` from devices) — `.networks` list model (ssid/signal/security live-updating), `.scanning`/`.scan()`, `network.connect()` / `network.connectWithPsk(password)`, `network.connected`/`active` for current SSID+signal. Radio toggle: check the local qmltypes for an enable/disable API on Networking/WifiDevice during implementation; **keep the `nmcli radio wifi` toggle Process if absent** (it's one process, fine). Delete `wifiStatusProc`/`wifiCurrentProc`/`wifiScanProc`/`wifiConnectProc`/`wifiDisconnectProc`, the scan-delay Timer, and all `wifi*` root state from shell.qml (panel becomes self-contained; only `wifiVisible` stays in root). NOTE: module is new in 0.3.0 — validate every property against `/usr/lib/qt6/qml/Quickshell/Networking/quickshell-network.qmltypes` before use.

### 3e. BluetoothPanel
`Quickshell.Bluetooth`: `Bluetooth.defaultAdapter` — `.enabled` for the toggle, `.discovering` for scan (bind, no sleep chains), `Bluetooth.devices` filtered by `.bonded`/`.paired` for the two lists; `device.connect()`, `.disconnect()`, `.pair()`, `.trusted = true`, `.forget()`, `device.state` for "Connecting…". Delete **all** bluetoothctl Processes (btStatus/btToggleOn/btToggleOff/btDevices/btScan/btAction), both delay Timers, and `bt*` root state (~120 lines of the worst code in the config, incl. the `sleep 2`-in-pipeline pairing hack). Bonus: `device.battery` is available — show it on paired devices.

### 3f. Launcher apps tab
`DesktopEntries.applications` (live model, handles NoDisplay/Hidden/localization) instead of the 15-line bash .desktop parser; launch via `entry.execute()` (proper detachment) instead of `bash -c exec &`. Keep usage-count sorting: key `appUsage` by `entry.id` (migrate: also match old name keys once, or just accept a usage reset — decide at impl time, prefer matching by name fallback). Icons: `Quickshell.iconPath(entry.icon)` or `IconImage`. Delete `appListProc`/`launchProc`.

### 3g. Cosmetic modernization (with 3f)
Replace the 4 `OpacityMask` usages (pfp, pfp thumbnails ×2, wallpaper thumbs) with `ClippingRectangle` from `Quickshell.Widgets`; drop `Qt5Compat.GraphicalEffects` imports where the DropShadow isn't used (MusicPanel keeps its DropShadow).

## Phase 4 — Scripts cleanup

- **`scripts/scale_wallpaper.sh`** — delete. Broken (uses `$WALLPAPER_PATH` which is never set) and nothing references it (verified via grep across ~/dotfiles).
- **`scripts/applwal.sh`** — clean up: remove duplicate `OUTPUT_PATH_*` assignments (lines 17–18 vs 36–37 disagree on `current` vs `current.jpg`), remove debug `echo`/`notify-send` noise, remove unused `ASP_W/ASP_H`. `awww` is correct (it's the installed binary; swww is not installed — do NOT "fix" it). **Consolidate the post-wallpaper chain**: move waybar restart, swaync CSS copy + SIGUSR1, and blurred-wallpaper generation from shell.qml's `walStepWaybar`→`walStepSwaync`→`walStepBlur` Process chain into applwal.sh (it already runs zathura/ghostty colorizers — this puts all "apply theme everywhere" logic in one place). shell.qml's `applyWallProc.onExited` then only clears `walApplying`; Theme reloads itself via the 3a FileView watch.
- **`scripts/create_thumbs.sh`** — rewrite as `scripts/create_thumbs.py` (Python). Rationale: the script is per-file logic, not orchestration — currently it spawns `md5sum` + `convert`/`vipsthumbnail` per wallpaper with uneven `&`/`wait` backgrounding and a nonsensical source-dir fallback (picks a hardcoded dotfiles path when `vipsthumbnail` is missing). Python version: `hashlib.md5` for the path hash (must stay identical to the current scheme — md5 hex of the full path — so existing thumbs in `~/.cache/wallpaper-thumbs` and the QML `Qt.md5()` lookup from Phase 1 keep matching), `os.stat` mtime comparison, Pillow for 180×120 center-crop JPEG thumbnails (handles gif-first-frame natively via `seek(0)`), `concurrent.futures` for parallelism. Zero subprocess spawns. Source dir is always `$HOME/wallpapers/favorites`. Requires Pillow (`python-pillow` on Arch — NOT currently installed, needs `pacman -S python-pillow` first); if the dependency is unwanted, fall back to the shell cleanup (fix SRC logic, consistent backgrounded subshells + `wait`). Update the caller in `shell.qml` (`thumbGenProc`, ~line 203) to the new filename.

## Files touched

- `shell.qml` — shrinks dramatically (wifi/bt/music/app-list Processes and state deleted)
- `components/{Dashboard,MusicPanel,WifiPanel,BluetoothPanel,LauncherPanel}.qml`
- `Common/{Theme.qml,Paths.qml,qmldir}` + new `Common/{StyledText,Card,ToggleSwitch,ValueSlider}.qml`
- `scripts/applwal.sh`; replace `scripts/create_thumbs.sh` with `scripts/create_thumbs.py`; delete `scripts/scale_wallpaper.sh`
- repo: untrack `app_usage.json`, update `.gitignore`

## Verification (per phase)

1. `qmllint -I /usr/lib/qt6/qml` on every touched .qml → exit 0.
2. `QT_QPA_PLATFORM=offscreen timeout 4 qs -p shell.qml` → only the expected "No PanelWindow backend loaded" error.
3. Save → hot-reload; `qs log | grep -E 'Reloading|reloadFailed|Failed to load'` → no failures.
4. Functional smoke per panel via IPC: `qs ipc call launcher toggle` (type to filter, Enter to launch, usage count persists in `~/.local/state`), `qs ipc call wallpaper toggle` (thumbs render, apply re-themes waybar/swaync/ghostty), `qs ipc call music toggle` (play/pause/seek), `qs ipc call wifi toggle` (scan/connect incl. PSK prompt), `qs ipc call bluetooth toggle` (toggle power, scan, connect/disconnect a paired device).
5. `git -C ~/dotfiles status` stays clean after launching apps (app_usage no longer tracked).

## Risks

- `Quickshell.Networking` is brand-new in 0.3.0; property names must be validated against the shipped qmltypes (partially done; `WifiNetwork`, `connectWithPsk`, `WifiDevice`, `scanning` confirmed to exist). If the radio-enable API is missing, keep the one nmcli toggle Process.
- Mpris position reporting varies by player; keep a small visible-gated refresh timer as fallback.
- Each phase is hot-reload-verifiable and committed separately, so any regression is bisectable and the live bar is protected by quickshell's last-good reload behavior.
