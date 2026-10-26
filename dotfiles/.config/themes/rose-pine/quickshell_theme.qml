pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#191724"
    readonly property color bg1:           "#1f1d2e"
    readonly property color fg0:           "#e0def4"
    readonly property color fg1:           "#908caa"
    readonly property color fg2:           "#908caa"
    readonly property color fg3:           "#6e6a86"
    readonly property color textPrimary:   "#e0def4"
    readonly property color textSecondary: "#908caa"

    readonly property color accent:      "#c4a7e7"
    readonly property color accentHover: "#191724"
    readonly property color border:      "#c4a7e7"
    readonly property color activeWs:    "#c4a7e7"
    readonly property color inactive:    "#6e6a86"

    readonly property color surface:    "#1f1d2e"
    readonly property color surfaceAlt: "#191724"

    readonly property color green:   "#9ccfd8"
    readonly property color red:     "#eb6f92"
    readonly property color warning: "#f6c177"
    readonly property color success: "#9ccfd8"
    readonly property color error:   "#eb6f92"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#191724"
    readonly property color foreground: "#e0def4"
    readonly property color cursor:     "#e0def4"

    readonly property color color0:  "#1f1d2e"
    readonly property color color1:  "#eb6f92"
    readonly property color color2:  "#9ccfd8"
    readonly property color color3:  "#f6c177"
    readonly property color color4:  "#31748f"
    readonly property color color5:  "#c4a7e7"
    readonly property color color6:  "#9ccfd8"
    readonly property color color7:  "#908caa"
    readonly property color color8:  "#6e6a86"
    readonly property color color9:  "#ff8fab"
    readonly property color color10: "#b5e3ec"
    readonly property color color11: "#ffd79a"
    readonly property color color12: "#4a8fa8"
    readonly property color color13: "#d7baff"
    readonly property color color14: "#9ccfd8"
    readonly property color color15: "#e0def4"
}
