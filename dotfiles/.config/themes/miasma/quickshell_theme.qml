pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#222222"
    readonly property color bg1:           "#2a2a2a"
    readonly property color fg0:           "#d7c483"
    readonly property color fg1:           "#c2c2b0"
    readonly property color fg2:           "#d7c483"
    readonly property color fg3:           "#666666"
    readonly property color textPrimary:   "#d7c483"
    readonly property color textSecondary: "#c2c2b0"

    readonly property color accent:      "#78824b"
    readonly property color accentHover: "#3d3d3d"
    readonly property color border:      "#78824b"
    readonly property color activeWs:    "#78824b"
    readonly property color inactive:    "#666666"

    readonly property color surface:    "#000000"
    readonly property color surfaceAlt: "#333333"

    readonly property color green:   "#5f875f"
    readonly property color red:     "#685742"
    readonly property color warning: "#b36d43"
    readonly property color success: "#5f875f"
    readonly property color error:   "#685742"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#222222"
    readonly property color foreground: "#c2c2b0"
    readonly property color cursor:     "#c7c7c7"

    readonly property color color0:  "#000000"
    readonly property color color1:  "#685742"
    readonly property color color2:  "#5f875f"
    readonly property color color3:  "#b36d43"
    readonly property color color4:  "#78824b"
    readonly property color color5:  "#bb7744"
    readonly property color color6:  "#c9a554"
    readonly property color color7:  "#d7c483"
    readonly property color color8:  "#666666"
    readonly property color color9:  "#685742"
    readonly property color color10: "#5f875f"
    readonly property color color11: "#b36d43"
    readonly property color color12: "#78824b"
    readonly property color color13: "#bb7744"
    readonly property color color14: "#c9a554"
    readonly property color color15: "#d7c483"
}
