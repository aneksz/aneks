pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "#111c18"
    readonly property color bg1:           "#23372B"
    readonly property color fg0:           "#F6F5DD"
    readonly property color fg1:           "#C1C497"
    readonly property color fg2:           "#F6F5DD"
    readonly property color fg3:           "#53685B"
    readonly property color textPrimary:   "#F6F5DD"
    readonly property color textSecondary: "#C1C497"

    readonly property color accent:      "#509475"
    readonly property color accentHover: "#111c18"
    readonly property color border:      "#509475"
    readonly property color activeWs:    "#509475"
    readonly property color inactive:    "#53685B"

    readonly property color surface:    "#23372B"
    readonly property color surfaceAlt: "#111c18"

    readonly property color green:   "#549e6a"
    readonly property color red:     "#FF5345"
    readonly property color warning: "#E5C736"
    readonly property color success: "#549e6a"
    readonly property color error:   "#FF5345"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "#111c18"
    readonly property color foreground: "#C1C497"
    readonly property color cursor:     "#D7C995"

    readonly property color color0:  "#23372B"
    readonly property color color1:  "#FF5345"
    readonly property color color2:  "#549e6a"
    readonly property color color3:  "#459451"
    readonly property color color4:  "#509475"
    readonly property color color5:  "#D2689C"
    readonly property color color6:  "#2DD5B7"
    readonly property color color7:  "#F6F5DD"
    readonly property color color8:  "#53685B"
    readonly property color color9:  "#db9f9c"
    readonly property color color10: "#63b07a"
    readonly property color color11: "#E5C736"
    readonly property color color12: "#ACD4CF"
    readonly property color color13: "#75bbb3"
    readonly property color color14: "#8CD3CB"
    readonly property color color15: "#9eebb3"
}
