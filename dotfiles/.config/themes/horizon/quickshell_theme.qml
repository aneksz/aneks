pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#1c1e26"
    readonly property color bg1:           "#232530"
    readonly property color fg0:           "#d5c1ac"
    readonly property color fg1:           "#a8a8b3"
    readonly property color fg2:           "#a8a8b3"
    readonly property color fg3:           "#6e6e7e"
    readonly property color textPrimary:   "#d5c1ac"
    readonly property color textSecondary: "#a8a8b3"

    readonly property color accent:      "#ee64ac"
    readonly property color accentHover: "#1c1e26"
    readonly property color border:      "#ee64ac"
    readonly property color activeWs:    "#ee64ac"
    readonly property color inactive:    "#6e6e7e"

    readonly property color surface:    "#232530"
    readonly property color surfaceAlt: "#1c1e26"

    readonly property color green:   "#29d398"
    readonly property color red:     "#e95678"
    readonly property color warning: "#fab795"
    readonly property color success: "#29d398"
    readonly property color error:   "#e95678"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#1c1e26"
    readonly property color foreground: "#c7b9a8"
    readonly property color cursor:     "#c7b9a8"

    readonly property color color0:  "#232530"
    readonly property color color1:  "#e95678"
    readonly property color color2:  "#29d398"
    readonly property color color3:  "#fab795"
    readonly property color color4:  "#26bbd9"
    readonly property color color5:  "#ee64ac"
    readonly property color color6:  "#59e1e3"
    readonly property color color7:  "#a8a8b3"
    readonly property color color8:  "#6e6e7e"
    readonly property color color9:  "#ff6e92"
    readonly property color color10: "#3be6aa"
    readonly property color color11: "#ffc7a8"
    readonly property color color12: "#3fd4f2"
    readonly property color color13: "#ff7cc6"
    readonly property color color14: "#59e1e3"
    readonly property color color15: "#d5c1ac"
}
