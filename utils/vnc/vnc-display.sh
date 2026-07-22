#!/usr/bin/env bash
#
# vnc-display.sh — attach a Samsung tablet as a secondary Hyprland display
# over USB (adb reverse + wayvnc).
#
# Usage:
#   ./vnc-display.sh                     # defaults below
#   ./vnc-display.sh -r 1920x1200 -s 1   # override resolution / scale
#   ./vnc-display.sh --no-adb            # skip USB tunnel, loopback only
#   ./vnc-display.sh --cleanup           # remove stray headless outputs, exit
#
# Ctrl-C tears everything down.

set -euo pipefail

RESOLUTION="2560x1600@60"
SCALE="2"
POSITION="auto"
PORT="5900"
MAX_FPS="30"
USE_ADB=1

die() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
log() { printf '\033[36m::\033[0m %s\n' "$*"; }

while [ $# -gt 0 ]; do
    case "$1" in
        -r|--resolution) RESOLUTION="$2"; shift 2 ;;
        -s|--scale)      SCALE="$2";      shift 2 ;;
        -p|--port)       PORT="$2";       shift 2 ;;
        -f|--max-fps)    MAX_FPS="$2";    shift 2 ;;
        --position)      POSITION="$2";   shift 2 ;;
        --no-adb)        USE_ADB=0;       shift ;;
        --cleanup)       CLEANUP_ONLY=1;  shift ;;
        -h|--help)       sed -n '3,10p' "$0" | sed 's/^# \?//'; exit 0 ;;
        *) die "unknown option: $1" ;;
    esac
done

list_headless() {
    hyprctl -j monitors all | jq -r '.[].name' | grep '^HEADLESS-' || true
}

remove_all_headless() {
    local n
    for n in $(list_headless); do
        log "removing $n"
        hyprctl output remove "$n" >/dev/null
    done
}

# ---- preflight -------------------------------------------------------

for cmd in hyprctl jq wayvnc; do
    command -v "$cmd" >/dev/null || die "$cmd not found in PATH"
done

[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || die "not inside a Hyprland session"

if [ "${CLEANUP_ONLY:-0}" = 1 ]; then
    remove_all_headless
    command -v adb >/dev/null && adb reverse --remove-all 2>/dev/null || true
    log "done"; exit 0
fi

if [ "$USE_ADB" = 1 ]; then
    command -v adb >/dev/null || die "adb not found — install android-tools, or pass --no-adb"
    if ! adb devices | awk 'NR>1 && $2=="device" {f=1} END {exit !f}'; then
        adb devices | sed 1d | grep -q unauthorized \
            && die "device unauthorized — accept the RSA prompt on the tablet"
        die "no adb device attached — check cable and USB debugging"
    fi
fi

# ---- create the headless output --------------------------------------

before="$(list_headless)"
log "creating headless output"
hyprctl output create headless >/dev/null

NEW=""
for _ in $(seq 30); do
    after="$(list_headless)"
    NEW="$(comm -13 <(sort <<<"$before") <(sort <<<"$after") | head -n1)"
    [ -n "$NEW" ] && break
    sleep 0.1
done
[ -n "$NEW" ] || die "headless output never appeared"

cleanup() {
    trap - EXIT INT TERM
    echo
    log "tearing down"
    hyprctl output remove "$NEW" >/dev/null 2>&1 || true
    [ "$USE_ADB" = 1 ] && adb reverse --remove "tcp:$PORT" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

log "configuring $NEW at $RESOLUTION scale $SCALE"
hyprctl keyword monitor "$NEW,$RESOLUTION,$POSITION,$SCALE" >/dev/null

# ---- usb tunnel ------------------------------------------------------

if [ "$USE_ADB" = 1 ]; then
    log "forwarding tablet 127.0.0.1:$PORT -> this machine"
    adb reverse "tcp:$PORT" "tcp:$PORT" >/dev/null
    printf '   open AVNC on the tablet, connect to \033[1m127.0.0.1:%s\033[0m\n' "$PORT"
else
    printf '   point a viewer at \033[1m127.0.0.1:%s\033[0m\n' "$PORT"
fi

# ---- serve -----------------------------------------------------------

log "serving $NEW (ctrl-c to stop)"
wayvnc --max-fps="$MAX_FPS" -o "$NEW" 127.0.0.1 "$PORT"
