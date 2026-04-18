import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#1e1e2e"
    readonly property color bg1: "#181825"
    readonly property color bg2: "#313244"
    readonly property color bg3: "#45475a"
    readonly property color bg4: "#585b70"

    // ================= FOREGROUND =================
    readonly property color fg0: "#cdd6f4"
    readonly property color fg1: "#bac2de"
    readonly property color fg2: "#a6adc8"
    readonly property color fg3: "#9399b2"

    // ================= BASE =================
    readonly property color red: "#f38ba8"
    readonly property color green: "#a6e3a1"
    readonly property color yellow: "#f9e2af"
    readonly property color blue: "#89b4fa"
    readonly property color purple: "#cba6f7"
    readonly property color aqua: "#94e2d5"
    readonly property color orange: "#fab387"

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
    readonly property color bg: "#1e1e2e"  
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: purple
    readonly property color inactive: blue
}
