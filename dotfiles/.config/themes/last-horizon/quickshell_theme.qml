pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#0c0b0c"
    readonly property color bg1:           "#141314"
    readonly property color fg0:           "#FAFCFB"
    readonly property color fg1:           "#cfd3cd"
    readonly property color fg2:           "#cfd3cd"
    readonly property color fg3:           "#584e51"
    readonly property color textPrimary:   "#FAFCFB"
    readonly property color textSecondary: "#cfd3cd"

    readonly property color accent:      "#b59790"
    readonly property color accentHover: "#0c0b0c"
    readonly property color border:      "#b59790"
    readonly property color activeWs:    "#b59790"
    readonly property color inactive:    "#584e51"

    readonly property color surface:    "#0c0b0c"
    readonly property color surfaceAlt: "#0c0b0c"

    readonly property color green:   "#87a9b0"
    readonly property color red:     "#c38b7b"
    readonly property color warning: "#C86F83"
    readonly property color success: "#87a9b0"
    readonly property color error:   "#E6604F"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#0c0b0c"
    readonly property color foreground: "#FAFCFB"
    readonly property color cursor:     "#e2dddc"

    readonly property color color0:  "#0c0b0c"
    readonly property color color1:  "#c38b7b"
    readonly property color color2:  "#87a9b0"
    readonly property color color3:  "#6B5E73"
    readonly property color color4:  "#b59790"
    readonly property color color5:  "#c4d8e2"
    readonly property color color6:  "#a5a0b6"
    readonly property color color7:  "#cfd3cd"
    readonly property color color8:  "#584e51"
    readonly property color color9:  "#c38b7b"
    readonly property color color10: "#87a9b0"
    readonly property color color11: "#6B5E73"
    readonly property color color12: "#b59790"
    readonly property color color13: "#c4d8e2"
    readonly property color color14: "#a5a0b6"
    readonly property color color15: "#e2dddc"
}
