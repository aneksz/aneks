pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#303446"
    readonly property color bg1:           "#414559"
    readonly property color fg0:           "#c6d0f5"
    readonly property color fg1:           "#b5bfe2"
    readonly property color fg2:           "#b5bfe2"
    readonly property color fg3:           "#626880"
    readonly property color textPrimary:   "#c6d0f5"
    readonly property color textSecondary: "#b5bfe2"

    readonly property color accent:      "#ca9ee6"
    readonly property color accentHover: "#626880"
    readonly property color border:      "#ca9ee6"
    readonly property color activeWs:    "#ca9ee6"
    readonly property color inactive:    "#626880"

    readonly property color surface:    "#414559"
    readonly property color surfaceAlt: "#51576d"

    readonly property color green:   "#a6d189"
    readonly property color red:     "#e78284"
    readonly property color warning: "#e5c890"
    readonly property color success: "#a6d189"
    readonly property color error:   "#e78284"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#303446"
    readonly property color foreground: "#c6d0f5"
    readonly property color cursor:     "#f2d5cf"

    readonly property color color0:  "#414559"
    readonly property color color1:  "#e78284"
    readonly property color color2:  "#a6d189"
    readonly property color color3:  "#e5c890"
    readonly property color color4:  "#8caaee"
    readonly property color color5:  "#f4b8e4"
    readonly property color color6:  "#81c8be"
    readonly property color color7:  "#b5bfe2"
    readonly property color color8:  "#626880"
    readonly property color color9:  "#e78284"
    readonly property color color10: "#a6d189"
    readonly property color color11: "#e5c890"
    readonly property color color12: "#8caaee"
    readonly property color color13: "#f4b8e4"
    readonly property color color14: "#81c8be"
    readonly property color color15: "#f2d5cf"
}
