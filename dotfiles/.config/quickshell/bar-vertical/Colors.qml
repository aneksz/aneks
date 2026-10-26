pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#101315"
    readonly property color bg1:           "#343d41"
    readonly property color fg0:           "#d9dbdc"
    readonly property color fg1:           "#cbc2be"
    readonly property color fg2:           "#cbc2be"
    readonly property color fg3:           "#4b4e55"
    readonly property color textPrimary:   "#d9dbdc"
    readonly property color textSecondary: "#cbc2be"

    readonly property color accent:      "#798186"
    readonly property color accentHover: "#101315"
    readonly property color border:      "#798186"
    readonly property color activeWs:    "#798186"
    readonly property color inactive:    "#4b4e55"

    readonly property color surface:    "#101315"
    readonly property color surfaceAlt: "#101315"

    readonly property color green:   "#9fa5a9"
    readonly property color red:     "#565d60"
    readonly property color warning: "#c9c2b4"
    readonly property color success: "#9fa5a9"
    readonly property color error:   "#de6145"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#101315"
    readonly property color foreground: "#cacccc"
    readonly property color cursor:     "#cacccc"

    readonly property color color0:  "#101315"
    readonly property color color1:  "#565d60"
    readonly property color color2:  "#9fa5a9"
    readonly property color color3:  "#d9dbdc"
    readonly property color color4:  "#798186"
    readonly property color color5:  "#aeaeae"
    readonly property color color6:  "#707070"
    readonly property color color7:  "#cbc2be"
    readonly property color color8:  "#4b4e55"
    readonly property color color9:  "#de6145"
    readonly property color color10: "#343d41"
    readonly property color color11: "#c9c2b4"
    readonly property color color12: "#5d6367"
    readonly property color color13: "#9a9a9a"
    readonly property color color14: "#707070"
    readonly property color color15: "#a5aeb4"
}
