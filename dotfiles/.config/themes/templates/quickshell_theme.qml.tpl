pragma Singleton
import QtQuick

QtObject {
    // ---- what the theme-engine (bar2/Colors.qml consumer) actually reads ----
    readonly property color bg:            "{{ background }}"
    readonly property color bg1:           "{{ bg1 }}"
    readonly property color fg0:           "{{ fg0 }}"
    readonly property color fg1:           "{{ fg1 }}"
    readonly property color fg2:           "{{ color7 }}"
    readonly property color fg3:           "{{ color8 }}"
    readonly property color textPrimary:   "{{ fg0 }}"
    readonly property color textSecondary: "{{ fg1 }}"

    readonly property color accent:      "{{ accent }}"
    readonly property color accentHover: "{{ bg3 }}"
    readonly property color border:      "{{ accent }}"
    readonly property color activeWs:    "{{ accent }}"
    readonly property color inactive:    "{{ color8 }}"

    readonly property color surface:    "{{ color0 }}"
    readonly property color surfaceAlt: "{{ bg2 }}"

    readonly property color green:   "{{ color2 }}"
    readonly property color red:     "{{ color1 }}"
    readonly property color warning: "{{ warn }}"
    readonly property color success: "{{ success }}"
    readonly property color error:   "{{ error }}"

    // ---- kept for anything else that reads the plain base16 names directly ----
    readonly property color background: "{{ background }}"
    readonly property color foreground: "{{ foreground }}"
    readonly property color cursor:     "{{ cursor }}"

    readonly property color color0:  "{{ color0 }}"
    readonly property color color1:  "{{ color1 }}"
    readonly property color color2:  "{{ color2 }}"
    readonly property color color3:  "{{ color3 }}"
    readonly property color color4:  "{{ color4 }}"
    readonly property color color5:  "{{ color5 }}"
    readonly property color color6:  "{{ color6 }}"
    readonly property color color7:  "{{ color7 }}"
    readonly property color color8:  "{{ color8 }}"
    readonly property color color9:  "{{ color9 }}"
    readonly property color color10: "{{ color10 }}"
    readonly property color color11: "{{ color11 }}"
    readonly property color color12: "{{ color12 }}"
    readonly property color color13: "{{ color13 }}"
    readonly property color color14: "{{ color14 }}"
    readonly property color color15: "{{ color15 }}"
}
