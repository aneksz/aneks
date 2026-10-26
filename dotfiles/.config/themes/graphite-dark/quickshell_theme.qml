pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#1e1e1e"
    readonly property color bg1:           "#242424"
    readonly property color fg0:           "#e6e6e6"
    readonly property color fg1:           "#bfbfbf"
    readonly property color fg2:           "#d4d4d4"
    readonly property color fg3:           "#262626"
    readonly property color textPrimary:   "#e6e6e6"
    readonly property color textSecondary: "#bfbfbf"

    readonly property color accent:      "#a6a6a6"
    readonly property color accentHover: "#1e1e1e"
    readonly property color border:      "#a6a6a6"
    readonly property color activeWs:    "#a6a6a6"
    readonly property color inactive:    "#262626"

    readonly property color surface:    "#262626"
    readonly property color surfaceAlt: "#1e1e1e"

    readonly property color green:   "#8e8e8e"
    readonly property color red:     "#646464"
    readonly property color warning: "#a6a6a6"
    readonly property color success: "#a6a6a6"
    readonly property color error:   "#a6a6a6"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#1e1e1e"
    readonly property color foreground: "#d4d4d4"
    readonly property color cursor:     "#e6e6e6"

    readonly property color color0:  "#262626"
    readonly property color color1:  "#646464"
    readonly property color color2:  "#8e8e8e"
    readonly property color color3:  "#b9b9b9"
    readonly property color color4:  "#989898"
    readonly property color color5:  "#747474"
    readonly property color color6:  "#585858"
    readonly property color color7:  "#d4d4d4"
    readonly property color color8:  "#262626"
    readonly property color color9:  "#646464"
    readonly property color color10: "#8e8e8e"
    readonly property color color11: "#b9b9b9"
    readonly property color color12: "#989898"
    readonly property color color13: "#747474"
    readonly property color color14: "#585858"
    readonly property color color15: "#d4d4d4"
}
