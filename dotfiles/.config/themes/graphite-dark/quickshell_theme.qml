import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#1e1e1e"
    readonly property color bg1: "#242424"
    readonly property color bg2: "#2c2c2c"
    readonly property color bg3: "#343434"
    readonly property color bg4: "#3d3d3d"

    // ================= FOREGROUND =================
    readonly property color fg0: "#e6e6e6"
    readonly property color fg1: "#d4d4d4"
    readonly property color fg2: "#bfbfbf"
    readonly property color fg3: "#a6a6a6"
    readonly property color fg: fg0

    // ================= SEMANTIC (MONOCHROME) =================
    readonly property color accent: fg3
    readonly property color accentHover: "#b5b5b5"
    readonly property color border: "#3a3a3a"

    // ⚠️ Override ALL semantic colors to greys
    readonly property color success: fg3
    readonly property color warning: fg3
    readonly property color error: fg3

    // ================= TEXT ROLES =================
    readonly property color textPrimary: fg3
    readonly property color textSecondary: fg3
    readonly property color textMuted: fg3

    // ================= SURFACES =================
    readonly property color bg: "#1e1e1e"
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: "#cfcfcf"
    readonly property color inactive: fg3
}
