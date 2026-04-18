import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#282a36"
    readonly property color bg1: "#1e1f29"
    readonly property color bg2: "#44475a"
    readonly property color bg3: "#6272a4"
    readonly property color bg4: "#7082b6"

    // ================= FOREGROUND =================
    readonly property color fg0: "#f8f8f2"
    readonly property color fg1: "#e6e6e0"
    readonly property color fg2: "#bfbfbf"
    readonly property color fg3: "#7f849c"

    // ================= BASE =================
    readonly property color red: "#ff5555"
    readonly property color green: "#50fa7b"
    readonly property color yellow: "#f1fa8c"
    readonly property color blue: "#6272a4"
    readonly property color purple: "#bd93f9"
    readonly property color aqua: "#8be9fd"
    readonly property color orange: "#ffb86c"

    // ================= SEMANTIC =================
    readonly property color accent: purple
    readonly property color accentHover: aqua
    readonly property color border: purple

    readonly property color success: green
    readonly property color warning: yellow
    readonly property color error: red

    // ================= TEXT ROLES =================
    readonly property color textPrimary: fg0
    readonly property color textSecondary: fg2
    readonly property color textMuted: fg3

    // ================= SURFACES =================
    readonly property color bg: "#282a36"   // translucent bg0
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: purple
    readonly property color inactive: aqua
}
