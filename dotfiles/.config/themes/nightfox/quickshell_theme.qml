pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#192330"
    readonly property color bg1:           "#1d2b3a"
    readonly property color fg0:           "#cdcecf"
    readonly property color fg1:           "#9da9ba"
    readonly property color fg2:           "#9da9ba"
    readonly property color fg3:           "#738091"
    readonly property color textPrimary:   "#cdcecf"
    readonly property color textSecondary: "#9da9ba"

    readonly property color accent:      "#719cd6"
    readonly property color accentHover: "#192330"
    readonly property color border:      "#719cd6"
    readonly property color activeWs:    "#719cd6"
    readonly property color inactive:    "#738091"

    readonly property color surface:    "#1d2b3a"
    readonly property color surfaceAlt: "#192330"

    readonly property color green:   "#81b29a"
    readonly property color red:     "#c94f6d"
    readonly property color warning: "#dbc074"
    readonly property color success: "#81b29a"
    readonly property color error:   "#c94f6d"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#192330"
    readonly property color foreground: "#b8c0cc"
    readonly property color cursor:     "#b8c0cc"

    readonly property color color0:  "#1d2b3a"
    readonly property color color1:  "#c94f6d"
    readonly property color color2:  "#81b29a"
    readonly property color color3:  "#dbc074"
    readonly property color color4:  "#719cd6"
    readonly property color color5:  "#9d79d6"
    readonly property color color6:  "#63cdcf"
    readonly property color color7:  "#9da9ba"
    readonly property color color8:  "#738091"
    readonly property color color9:  "#d16983"
    readonly property color color10: "#9ccfb8"
    readonly property color color11: "#e6cf86"
    readonly property color color12: "#86abdc"
    readonly property color color13: "#b08ae6"
    readonly property color color14: "#63cdcf"
    readonly property color color15: "#cdcecf"
}
