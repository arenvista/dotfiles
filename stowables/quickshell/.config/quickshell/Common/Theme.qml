pragma Singleton

import Quickshell
import QtQuick

// Central theme singleton: shared font + pywal colors.
// The pywal colors are populated at runtime by shell.qml's colors loader
// (walColorsProc); the values below are the fallback palette (Catppuccin
// Mocha) used before the first load / when ~/.cache/wal is missing.
Singleton {
    id: theme

    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    property color background: "#1e1e2e"
    property color foreground: "#cdd6f4"
    property color color1: "#f38ba8"
    property color color2: "#a6e3a1"
    property color color4: "#f9e2af"
    property color color5: "#89b4fa"
    property color color8: "#6c7086"
    property color color13: "#f5c2e7"

    // Return `c` with its alpha replaced by `a` (0..1).
    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a)
    }
}
