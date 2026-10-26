pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#282a36"
    readonly property color bg1:           "#44475a"
    readonly property color fg0:           "#f8f8f2"
    readonly property color fg1:           "#6272a4"
    readonly property color fg2:           "#f8f8f2"
    readonly property color fg3:           "#6272a4"
    readonly property color textPrimary:   "#f8f8f2"
    readonly property color textSecondary: "#6272a4"

    readonly property color accent:      "#bd93f9"
    readonly property color accentHover: "#282a36"
    readonly property color border:      "#bd93f9"
    readonly property color activeWs:    "#bd93f9"
    readonly property color inactive:    "#6272a4"

    readonly property color surface:    "#21222c"
    readonly property color surfaceAlt: "#282a36"

    readonly property color green:   "#50fa7b"
    readonly property color red:     "#ff5555"
    readonly property color warning: "#f1fa8c"
    readonly property color success: "#50fa7b"
    readonly property color error:   "#ff5555"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#282a36"
    readonly property color foreground: "#f8f8f2"
    readonly property color cursor:     "#f8f8f2"

    readonly property color color0:  "#21222c"
    readonly property color color1:  "#ff5555"
    readonly property color color2:  "#50fa7b"
    readonly property color color3:  "#f1fa8c"
    readonly property color color4:  "#bd93f9"
    readonly property color color5:  "#ff79c6"
    readonly property color color6:  "#8be9fd"
    readonly property color color7:  "#f8f8f2"
    readonly property color color8:  "#6272a4"
    readonly property color color9:  "#ff6e6e"
    readonly property color color10: "#69ff94"
    readonly property color color11: "#ffffa5"
    readonly property color color12: "#d6acff"
    readonly property color color13: "#ff92df"
    readonly property color color14: "#a4ffff"
    readonly property color color15: "#ffffff"
}
