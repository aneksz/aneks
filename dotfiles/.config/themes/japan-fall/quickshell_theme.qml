pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#0c111d"
    readonly property color bg1:           "#181d29"
    readonly property color fg0:           "#d6c9b1"
    readonly property color fg1:           "#a19785"
    readonly property color fg2:           "#d6c9b1"
    readonly property color fg3:           "#63666c"
    readonly property color textPrimary:   "#d6c9b1"
    readonly property color textSecondary: "#a19785"

    readonly property color accent:      "#94a7ba"
    readonly property color accentHover: "#2f3946"
    readonly property color border:      "#94a7ba"
    readonly property color activeWs:    "#94a7ba"
    readonly property color inactive:    "#63666c"

    readonly property color surface:    "#0c111d"
    readonly property color surfaceAlt: "#242934"

    readonly property color green:   "#727f6a"
    readonly property color red:     "#eb5e3f"
    readonly property color warning: "#c3b798"
    readonly property color success: "#94a489"
    readonly property color error:   "#eb5e3f"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#0c111d"
    readonly property color foreground: "#d6c9b1"
    readonly property color cursor:     "#d6c9b1"

    readonly property color color0:  "#0c111d"
    readonly property color color1:  "#eb5e3f"
    readonly property color color2:  "#727f6a"
    readonly property color color3:  "#9d917a"
    readonly property color color4:  "#94a7ba"
    readonly property color color5:  "#a67665"
    readonly property color color6:  "#83a2a3"
    readonly property color color7:  "#d6c9b1"
    readonly property color color8:  "#63666c"
    readonly property color color9:  "#ef7f66"
    readonly property color color10: "#94a489"
    readonly property color color11: "#c3b798"
    readonly property color color12: "#b8cde5"
    readonly property color color13: "#d09983"
    readonly property color color14: "#a5c9ca"
    readonly property color color15: "#e0d7c5"
}
