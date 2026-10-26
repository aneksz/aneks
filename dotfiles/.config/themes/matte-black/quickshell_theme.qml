pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#0d0d0d"
    readonly property color bg1:           "#141414"
    readonly property color fg0:           "#f5f5f5"
    readonly property color fg1:           "#d4d4d4"
    readonly property color fg2:           "#d4d4d4"
    readonly property color fg3:           "#3a3a3a"
    readonly property color textPrimary:   "#f5f5f5"
    readonly property color textSecondary: "#d4d4d4"

    readonly property color accent:      "#e68e0d"
    readonly property color accentHover: "#0d0d0d"
    readonly property color border:      "#e68e0d"
    readonly property color activeWs:    "#e68e0d"
    readonly property color inactive:    "#3a3a3a"

    readonly property color surface:    "#0d0d0d"
    readonly property color surfaceAlt: "#0d0d0d"

    readonly property color green:   "#8a8a8d"
    readonly property color red:     "#c25a3a"
    readonly property color warning: "#e68e0d"
    readonly property color success: "#a0a0a3"
    readonly property color error:   "#c25a3a"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#0d0d0d"
    readonly property color foreground: "#d4d4d4"
    readonly property color cursor:     "#e68e0d"

    readonly property color color0:  "#0d0d0d"
    readonly property color color1:  "#c25a3a"
    readonly property color color2:  "#8a8a8d"
    readonly property color color3:  "#e68e0d"
    readonly property color color4:  "#6b6b6e"
    readonly property color color5:  "#9a9a9d"
    readonly property color color6:  "#7a7a7d"
    readonly property color color7:  "#d4d4d4"
    readonly property color color8:  "#3a3a3a"
    readonly property color color9:  "#d9704a"
    readonly property color color10: "#a0a0a3"
    readonly property color color11: "#f2a52e"
    readonly property color color12: "#8f8f92"
    readonly property color color13: "#b0b0b3"
    readonly property color color14: "#9a9a9d"
    readonly property color color15: "#f5f5f5"
}
