import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#2e3440"
    readonly property color bg1: "#3b4252"
    readonly property color bg2: "#434c5e"
    readonly property color bg3: "#4c566a"
    readonly property color bg4: "#616e88"

    // ================= FOREGROUND =================
    readonly property color fg0: "#eceff4"
    readonly property color fg1: "#e5e9f0"
    readonly property color fg2: "#d8dee9"
    readonly property color fg3: "#c0c5ce"

    // ================= BASE COLORS =================
    readonly property color red: "#bf616a"
    readonly property color green: "#a3be8c"
    readonly property color yellow: "#ebcb8b"
    readonly property color blue: "#81a1c1"
    readonly property color purple: "#b48ead"
    readonly property color aqua: "#88c0d0"
    readonly property color orange: "#d08770"

    // ================= SEMANTIC =================
    readonly property color accent: blue
    readonly property color accentHover: aqua
    readonly property color border: blue

    readonly property color success: green
    readonly property color warning: yellow
    readonly property color error: red

    // ================= TEXT ROLES =================
    readonly property color textPrimary: fg0
    readonly property color textSecondary: fg2
    readonly property color textMuted: fg3

    // ================= SURFACES =================
    readonly property color bg: "#2e3440"
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: fg3
    readonly property color inactive: blue
}
