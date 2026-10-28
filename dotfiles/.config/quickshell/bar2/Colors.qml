pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#2d353b"
    readonly property color bg1:           "#343f44"
    readonly property color fg0:           "#d3c6aa"
    readonly property color fg1:           "#9da9a0"
    readonly property color fg2:           "#9da9a0"
    readonly property color fg3:           "#7a8478"
    readonly property color textPrimary:   "#d3c6aa"
    readonly property color textSecondary: "#9da9a0"

    readonly property color accent:      "#a7c080"
    readonly property color accentHover: "#445055"
    readonly property color border:      "#a7c080"
    readonly property color activeWs:    "#a7c080"
    readonly property color inactive:    "#7a8478"

    readonly property color surface:    "#343f44"
    readonly property color surfaceAlt: "#3a454a"

    readonly property color green:   "#a7c080"
    readonly property color red:     "#e67e80"
    readonly property color warning: "#dbbc7f"
    readonly property color success: "#a7c080"
    readonly property color error:   "#e67e80"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#2d353b"
    readonly property color foreground: "#d3c6aa"
    readonly property color cursor:     "#d3c6aa"

    readonly property color color0:  "#343f44"
    readonly property color color1:  "#e67e80"
    readonly property color color2:  "#a7c080"
    readonly property color color3:  "#dbbc7f"
    readonly property color color4:  "#7fbbb3"
    readonly property color color5:  "#d699b6"
    readonly property color color6:  "#83c092"
    readonly property color color7:  "#9da9a0"
    readonly property color color8:  "#7a8478"
    readonly property color color9:  "#e67e80"
    readonly property color color10: "#a7c080"
    readonly property color color11: "#dbbc7f"
    readonly property color color12: "#7fbbb3"
    readonly property color color13: "#d699b6"
    readonly property color color14: "#83c092"
    readonly property color color15: "#d3c6aa"
}
