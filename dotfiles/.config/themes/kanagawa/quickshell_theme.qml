pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#1f1f28"
    readonly property color bg1:           "#2a2a37"
    readonly property color fg0:           "#dcd7ba"
    readonly property color fg1:           "#a6a69c"
    readonly property color fg2:           "#a6a69c"
    readonly property color fg3:           "#727169"
    readonly property color textPrimary:   "#dcd7ba"
    readonly property color textSecondary: "#a6a69c"

    readonly property color accent:      "#7e9cd8"
    readonly property color accentHover: "#1f1f28"
    readonly property color border:      "#7e9cd8"
    readonly property color activeWs:    "#7e9cd8"
    readonly property color inactive:    "#727169"

    readonly property color surface:    "#2a2a37"
    readonly property color surfaceAlt: "#1f1f28"

    readonly property color green:   "#98bb6c"
    readonly property color red:     "#c34043"
    readonly property color warning: "#dca561"
    readonly property color success: "#98bb6c"
    readonly property color error:   "#c34043"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#1f1f28"
    readonly property color foreground: "#c8c093"
    readonly property color cursor:     "#c8c093"

    readonly property color color0:  "#2a2a37"
    readonly property color color1:  "#c34043"
    readonly property color color2:  "#98bb6c"
    readonly property color color3:  "#dca561"
    readonly property color color4:  "#7e9cd8"
    readonly property color color5:  "#957fb8"
    readonly property color color6:  "#7aa89f"
    readonly property color color7:  "#a6a69c"
    readonly property color color8:  "#727169"
    readonly property color color9:  "#e82424"
    readonly property color color10: "#b8d99f"
    readonly property color color11: "#e6c384"
    readonly property color color12: "#9cabca"
    readonly property color color13: "#b8a0d9"
    readonly property color color14: "#7aa89f"
    readonly property color color15: "#dcd7ba"
}
