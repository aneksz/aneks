pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#1d2021"
    readonly property color bg1:           "#282828"
    readonly property color fg0:           "#fbf1c7"
    readonly property color fg1:           "#d5c4a1"
    readonly property color fg2:           "#a89984"
    readonly property color fg3:           "#928374"
    readonly property color textPrimary:   "#fbf1c7"
    readonly property color textSecondary: "#d5c4a1"

    readonly property color accent:      "#458588"
    readonly property color accentHover: "#3c3836"
    readonly property color border:      "#458588"
    readonly property color activeWs:    "#458588"
    readonly property color inactive:    "#928374"

    readonly property color surface:    "#282828"
    readonly property color surfaceAlt: "#32302f"

    readonly property color green:   "#98971a"
    readonly property color red:     "#cc241d"
    readonly property color warning: "#fabd2f"
    readonly property color success: "#b8bb26"
    readonly property color error:   "#fb4934"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#1d2021"
    readonly property color foreground: "#ebdbb2"
    readonly property color cursor:     "#ebdbb2"

    readonly property color color0:  "#282828"
    readonly property color color1:  "#cc241d"
    readonly property color color2:  "#98971a"
    readonly property color color3:  "#d79921"
    readonly property color color4:  "#458588"
    readonly property color color5:  "#b16286"
    readonly property color color6:  "#689d6a"
    readonly property color color7:  "#a89984"
    readonly property color color8:  "#928374"
    readonly property color color9:  "#fb4934"
    readonly property color color10: "#b8bb26"
    readonly property color color11: "#fabd2f"
    readonly property color color12: "#83a598"
    readonly property color color13: "#d3869b"
    readonly property color color14: "#8ec07c"
    readonly property color color15: "#fbf1c7"
}
