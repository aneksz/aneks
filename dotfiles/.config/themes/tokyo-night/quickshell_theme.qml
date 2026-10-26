pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#1a1b26"
    readonly property color bg1:           "#1f2335"
    readonly property color fg0:           "#c0caf5"
    readonly property color fg1:           "#9aa5ce"
    readonly property color fg2:           "#9aa5ce"
    readonly property color fg3:           "#565f89"
    readonly property color textPrimary:   "#c0caf5"
    readonly property color textSecondary: "#9aa5ce"

    readonly property color accent:      "#7aa2f7"
    readonly property color accentHover: "#1a1b26"
    readonly property color border:      "#7aa2f7"
    readonly property color activeWs:    "#7aa2f7"
    readonly property color inactive:    "#565f89"

    readonly property color surface:    "#1f2335"
    readonly property color surfaceAlt: "#1a1b26"

    readonly property color green:   "#9ece6a"
    readonly property color red:     "#f7768e"
    readonly property color warning: "#e0af68"
    readonly property color success: "#9ece6a"
    readonly property color error:   "#f7768e"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#1a1b26"
    readonly property color foreground: "#a9b1d6"
    readonly property color cursor:     "#a9b1d6"

    readonly property color color0:  "#1f2335"
    readonly property color color1:  "#f7768e"
    readonly property color color2:  "#9ece6a"
    readonly property color color3:  "#e0af68"
    readonly property color color4:  "#7aa2f7"
    readonly property color color5:  "#bb9af7"
    readonly property color color6:  "#7dcfff"
    readonly property color color7:  "#9aa5ce"
    readonly property color color8:  "#565f89"
    readonly property color color9:  "#ff8da1"
    readonly property color color10: "#b9f27c"
    readonly property color color11: "#f5c178"
    readonly property color color12: "#9ab8ff"
    readonly property color color13: "#d2b3ff"
    readonly property color color14: "#7dcfff"
    readonly property color color15: "#c0caf5"
}
