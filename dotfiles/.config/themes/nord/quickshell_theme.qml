pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#2E3440"
    readonly property color bg1:           "#3B4252"
    readonly property color fg0:           "#ECEFF4"
    readonly property color fg1:           "#E5E9F0"
    readonly property color fg2:           "#E5E9F0"
    readonly property color fg3:           "#4C566A"
    readonly property color textPrimary:   "#ECEFF4"
    readonly property color textSecondary: "#E5E9F0"

    readonly property color accent:      "#81A1C1"
    readonly property color accentHover: "#2E3440"
    readonly property color border:      "#81A1C1"
    readonly property color activeWs:    "#81A1C1"
    readonly property color inactive:    "#4C566A"

    readonly property color surface:    "#3B4252"
    readonly property color surfaceAlt: "#2E3440"

    readonly property color green:   "#A3BE8C"
    readonly property color red:     "#BF616A"
    readonly property color warning: "#EBCB8B"
    readonly property color success: "#A3BE8C"
    readonly property color error:   "#BF616A"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#2E3440"
    readonly property color foreground: "#D8DEE9"
    readonly property color cursor:     "#D8DEE9"

    readonly property color color0:  "#3B4252"
    readonly property color color1:  "#BF616A"
    readonly property color color2:  "#A3BE8C"
    readonly property color color3:  "#EBCB8B"
    readonly property color color4:  "#81A1C1"
    readonly property color color5:  "#B48EAD"
    readonly property color color6:  "#8FBCBB"
    readonly property color color7:  "#E5E9F0"
    readonly property color color8:  "#4C566A"
    readonly property color color9:  "#BF616A"
    readonly property color color10: "#A3BE8C"
    readonly property color color11: "#EBCB8B"
    readonly property color color12: "#81A1C1"
    readonly property color color13: "#B48EAD"
    readonly property color color14: "#8FBCBB"
    readonly property color color15: "#ECEFF4"
}
