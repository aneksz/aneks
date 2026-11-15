pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#222222"
    readonly property color bg1:           "#292929"
    readonly property color fg0:           "#dbd7ca"
    readonly property color fg1:           "#777777"
    readonly property color fg2:           "#dbd7ca"
    readonly property color fg3:           "#758575"
    readonly property color textPrimary:   "#dbd7ca"
    readonly property color textSecondary: "#777777"

    readonly property color accent:      "#4d9375"
    readonly property color accentHover: "#353535"
    readonly property color border:      "#4d9375"
    readonly property color activeWs:    "#4d9375"
    readonly property color inactive:    "#758575"

    readonly property color surface:    "#222222"
    readonly property color surfaceAlt: "#2f2f2f"

    readonly property color green:   "#4d9375"
    readonly property color red:     "#cb7676"
    readonly property color warning: "#e6cc77"
    readonly property color success: "#4d9375"
    readonly property color error:   "#cb7676"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#222222"
    readonly property color foreground: "#dbd7ca"
    readonly property color cursor:     "#dbd7ca"

    readonly property color color0:  "#222222"
    readonly property color color1:  "#cb7676"
    readonly property color color2:  "#4d9375"
    readonly property color color3:  "#e6cc77"
    readonly property color color4:  "#6394bf"
    readonly property color color5:  "#d9739f"
    readonly property color color6:  "#5eaab5"
    readonly property color color7:  "#dbd7ca"
    readonly property color color8:  "#758575"
    readonly property color color9:  "#cb7676"
    readonly property color color10: "#4d9375"
    readonly property color color11: "#e6cc77"
    readonly property color color12: "#6394bf"
    readonly property color color13: "#d9739f"
    readonly property color color14: "#5eaab5"
    readonly property color color15: "#ffffff"
}
