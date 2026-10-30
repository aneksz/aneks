pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#001c2b"
    readonly property color bg1:           "#002437"
    readonly property color fg0:           "#fcf6e3"
    readonly property color fg1:           "#e9e2d0"
    readonly property color fg2:           "#e9e2d0"
    readonly property color fg3:           "#5f6f74"
    readonly property color textPrimary:   "#fcf6e3"
    readonly property color textSecondary: "#e9e2d0"

    readonly property color accent:      "#268bd2"
    readonly property color accentHover: "#073a52"
    readonly property color border:      "#268bd2"
    readonly property color activeWs:    "#268bd2"
    readonly property color inactive:    "#5f6f74"

    readonly property color surface:    "#072a39"
    readonly property color surfaceAlt: "#052e42"

    readonly property color green:   "#809900"
    readonly property color red:     "#d8322f"
    readonly property color warning: "#b38800"
    readonly property color success: "#809900"
    readonly property color error:   "#d8322f"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#001c2b"
    readonly property color foreground: "#e9e2d0"
    readonly property color cursor:     "#fcf6e3"

    readonly property color color0:  "#072a39"
    readonly property color color1:  "#d8322f"
    readonly property color color2:  "#809900"
    readonly property color color3:  "#b38800"
    readonly property color color4:  "#268bd2"
    readonly property color color5:  "#d03682"
    readonly property color color6:  "#2aa198"
    readonly property color color7:  "#e9e2d0"
    readonly property color color8:  "#5f6f74"
    readonly property color color9:  "#d8322f"
    readonly property color color10: "#809900"
    readonly property color color11: "#b38800"
    readonly property color color12: "#268bd2"
    readonly property color color13: "#d03682"
    readonly property color color14: "#2aa198"
    readonly property color color15: "#fcf6e3"
}
