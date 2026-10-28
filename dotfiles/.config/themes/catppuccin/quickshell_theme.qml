pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#1e1e2e"
    readonly property color bg1:           "#313244"
    readonly property color fg0:           "#cdd6f4"
    readonly property color fg1:           "#bac2de"
    readonly property color fg2:           "#bac2de"
    readonly property color fg3:           "#585b70"
    readonly property color textPrimary:   "#cdd6f4"
    readonly property color textSecondary: "#bac2de"

    readonly property color accent:      "#cba6f7"
    readonly property color accentHover: "#585b70"
    readonly property color border:      "#cba6f7"
    readonly property color activeWs:    "#cba6f7"
    readonly property color inactive:    "#585b70"

    readonly property color surface:    "#313244"
    readonly property color surfaceAlt: "#45475a"

    readonly property color green:   "#a6e3a1"
    readonly property color red:     "#f38ba8"
    readonly property color warning: "#f9e2af"
    readonly property color success: "#a6e3a1"
    readonly property color error:   "#f38ba8"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#1e1e2e"
    readonly property color foreground: "#cdd6f4"
    readonly property color cursor:     "#f5e0dc"

    readonly property color color0:  "#313244"
    readonly property color color1:  "#f38ba8"
    readonly property color color2:  "#a6e3a1"
    readonly property color color3:  "#f9e2af"
    readonly property color color4:  "#89b4fa"
    readonly property color color5:  "#f5c2e7"
    readonly property color color6:  "#94e2d5"
    readonly property color color7:  "#bac2de"
    readonly property color color8:  "#585b70"
    readonly property color color9:  "#f38ba8"
    readonly property color color10: "#a6e3a1"
    readonly property color color11: "#f9e2af"
    readonly property color color12: "#89b4fa"
    readonly property color color13: "#f5c2e7"
    readonly property color color14: "#94e2d5"
    readonly property color color15: "#f5e0dc"
}
