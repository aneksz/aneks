pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#faf4ed"
    readonly property color bg1:           "#fffaf3"
    readonly property color fg0:           "#575279"
    readonly property color fg1:           "#797593"
    readonly property color fg2:           "#797593"
    readonly property color fg3:           "#9893a5"
    readonly property color textPrimary:   "#575279"
    readonly property color textSecondary: "#797593"

    readonly property color accent:      "#907aa9"
    readonly property color accentHover: "#faf4ed"
    readonly property color border:      "#907aa9"
    readonly property color activeWs:    "#907aa9"
    readonly property color inactive:    "#9893a5"

    readonly property color surface:    "#f2e9e1"
    readonly property color surfaceAlt: "#faf4ed"

    readonly property color green:   "#56949f"
    readonly property color red:     "#b4637a"
    readonly property color warning: "#ea9d34"
    readonly property color success: "#56949f"
    readonly property color error:   "#b4637a"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#faf4ed"
    readonly property color foreground: "#575279"
    readonly property color cursor:     "#575279"

    readonly property color color0:  "#f2e9e1"
    readonly property color color1:  "#b4637a"
    readonly property color color2:  "#56949f"
    readonly property color color3:  "#ea9d34"
    readonly property color color4:  "#286983"
    readonly property color color5:  "#907aa9"
    readonly property color color6:  "#56949f"
    readonly property color color7:  "#797593"
    readonly property color color8:  "#9893a5"
    readonly property color color9:  "#c9728a"
    readonly property color color10: "#6aa4ae"
    readonly property color color11: "#f0ae52"
    readonly property color color12: "#3a7d98"
    readonly property color color13: "#a08bb8"
    readonly property color color14: "#6aa4ae"
    readonly property color color15: "#575279"
}
