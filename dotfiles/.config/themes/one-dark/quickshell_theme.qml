pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#1e2127"
    readonly property color bg1:           "#282c34"
    readonly property color fg0:           "#abb2bf"
    readonly property color fg1:           "#7f848e"
    readonly property color fg2:           "#7f848e"
    readonly property color fg3:           "#5c6370"
    readonly property color textPrimary:   "#abb2bf"
    readonly property color textSecondary: "#7f848e"

    readonly property color accent:      "#61afef"
    readonly property color accentHover: "#1e2127"
    readonly property color border:      "#61afef"
    readonly property color activeWs:    "#61afef"
    readonly property color inactive:    "#5c6370"

    readonly property color surface:    "#282c34"
    readonly property color surfaceAlt: "#1e2127"

    readonly property color green:   "#98c379"
    readonly property color red:     "#e06c75"
    readonly property color warning: "#e5c07b"
    readonly property color success: "#98c379"
    readonly property color error:   "#e06c75"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#1e2127"
    readonly property color foreground: "#9da5b4"
    readonly property color cursor:     "#9da5b4"

    readonly property color color0:  "#282c34"
    readonly property color color1:  "#e06c75"
    readonly property color color2:  "#98c379"
    readonly property color color3:  "#e5c07b"
    readonly property color color4:  "#61afef"
    readonly property color color5:  "#c678dd"
    readonly property color color6:  "#56b6c2"
    readonly property color color7:  "#7f848e"
    readonly property color color8:  "#5c6370"
    readonly property color color9:  "#ff7a84"
    readonly property color color10: "#b6e08a"
    readonly property color color11: "#ffd68a"
    readonly property color color12: "#7bc3ff"
    readonly property color color13: "#d891f0"
    readonly property color color14: "#56b6c2"
    readonly property color color15: "#abb2bf"
}
