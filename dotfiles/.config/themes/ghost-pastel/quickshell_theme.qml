pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#070506"
    readonly property color bg1:           "#100c10"
    readonly property color fg0:           "#ffffff"
    readonly property color fg1:           "#d9b6fd"
    readonly property color fg2:           "#d9b6fd"
    readonly property color fg3:           "#836f79"
    readonly property color textPrimary:   "#ffffff"
    readonly property color textSecondary: "#d9b6fd"

    readonly property color accent:      "#979fec"
    readonly property color accentHover: "#070506"
    readonly property color border:      "#979fec"
    readonly property color activeWs:    "#979fec"
    readonly property color inactive:    "#836f79"

    readonly property color surface:    "#070506"
    readonly property color surfaceAlt: "#070506"

    readonly property color green:   "#648ed0"
    readonly property color red:     "#b37580"
    readonly property color warning: "#e095b5"
    readonly property color success: "#a7c1e8"
    readonly property color error:   "#b37580"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#070506"
    readonly property color foreground: "#ffffff"
    readonly property color cursor:     "#ffffff"

    readonly property color color0:  "#070506"
    readonly property color color1:  "#b37580"
    readonly property color color2:  "#648ed0"
    readonly property color color3:  "#e095b5"
    readonly property color color4:  "#979fec"
    readonly property color color5:  "#cd9dcf"
    readonly property color color6:  "#7c93dd"
    readonly property color color7:  "#d9b6fd"
    readonly property color color8:  "#836f79"
    readonly property color color9:  "#d5aeb5"
    readonly property color color10: "#a7c1e8"
    readonly property color color11: "#f6dbe6"
    readonly property color color12: "#e4e6fb"
    readonly property color color13: "#eddaee"
    readonly property color color14: "#c3cef2"
    readonly property color color15: "#ffffff"
}
