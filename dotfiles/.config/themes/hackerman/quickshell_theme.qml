pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#0b0c16"
    readonly property color bg1:           "#08080c"
    readonly property color fg0:           "#8ea0a8"
    readonly property color fg1:           "#ddf7ff"
    readonly property color fg2:           "#ddf7ff"
    readonly property color fg3:           "#10d4b0"
    readonly property color textPrimary:   "#8ea0a8"
    readonly property color textSecondary: "#ddf7ff"

    readonly property color accent:      "#00d482"
    readonly property color accentHover: "#0b0c16"
    readonly property color border:      "#00d482"
    readonly property color activeWs:    "#00d482"
    readonly property color inactive:    "#10d4b0"

    readonly property color surface:    "#0b0c16"
    readonly property color surfaceAlt: "#0b0c16"

    readonly property color green:   "#26a269"
    readonly property color red:     "#ff3366"
    readonly property color warning: "#f1c40f"
    readonly property color success: "#00d482"
    readonly property color error:   "#ff3366"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#0b0c16"
    readonly property color foreground: "#ddf7ff"
    readonly property color cursor:     "#00ff9c"

    readonly property color color0:  "#0b0c16"
    readonly property color color1:  "#ff3366"
    readonly property color color2:  "#26a269"
    readonly property color color3:  "#f1c40f"
    readonly property color color4:  "#029790"
    readonly property color color5:  "#8e44ad"
    readonly property color color6:  "#1abc9c"
    readonly property color color7:  "#ddf7ff"
    readonly property color color8:  "#10d4b0"
    readonly property color color9:  "#ff0000"
    readonly property color color10: "#00ff9c"
    readonly property color color11: "#ffdd00"
    readonly property color color12: "#08e1d7"
    readonly property color color13: "#e215d4"
    readonly property color color14: "#5ce6e6"
    readonly property color color15: "#ffffff"
}
