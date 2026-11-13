pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#141b1e"
    readonly property color bg1:           "#1e2528"
    readonly property color fg0:           "#dadada"
    readonly property color fg1:           "#b3b9b8"
    readonly property color fg2:           "#b3b9b8"
    readonly property color fg3:           "#2d3437"
    readonly property color textPrimary:   "#dadada"
    readonly property color textSecondary: "#b3b9b8"

    readonly property color accent:      "#67b0e8"
    readonly property color accentHover: "#2d3437"
    readonly property color border:      "#67b0e8"
    readonly property color activeWs:    "#67b0e8"
    readonly property color inactive:    "#2d3437"

    readonly property color surface:    "#232a2d"
    readonly property color surfaceAlt: "#232a2d"

    readonly property color green:   "#8ccf7e"
    readonly property color red:     "#e57474"
    readonly property color warning: "#e5c76b"
    readonly property color success: "#8ccf7e"
    readonly property color error:   "#e57474"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#141b1e"
    readonly property color foreground: "#dadada"
    readonly property color cursor:     "#dadada"

    readonly property color color0:  "#232a2d"
    readonly property color color1:  "#e57474"
    readonly property color color2:  "#8ccf7e"
    readonly property color color3:  "#e5c76b"
    readonly property color color4:  "#67b0e8"
    readonly property color color5:  "#c47fd5"
    readonly property color color6:  "#6cbfbf"
    readonly property color color7:  "#b3b9b8"
    readonly property color color8:  "#2d3437"
    readonly property color color9:  "#ef7e7e"
    readonly property color color10: "#96d988"
    readonly property color color11: "#f4d67a"
    readonly property color color12: "#71baf2"
    readonly property color color13: "#ce89df"
    readonly property color color14: "#67cbe7"
    readonly property color color15: "#bdc3c2"
}
