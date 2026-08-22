import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#191724"
    readonly property color bg1: "#1f1d2e"
    readonly property color bg2: "#26233a"
    readonly property color bg3: "#403d52"
    readonly property color bg4: "#524f67"

    // ================= FOREGROUND =================
    readonly property color fg0: "#e0def4"
    readonly property color fg1: "#908caa"
    readonly property color fg2: "#6e6a86"
    readonly property color fg3: "#524f67"

    // ================= BASE =================
    readonly property color red: "#eb6f92"
    readonly property color redBright: "#ff8fab"

    readonly property color green: "#9ccfd8"
    readonly property color greenBright: "#b5e3ec"

    readonly property color yellow: "#f6c177"
    readonly property color yellowBright: "#ffd79a"

    readonly property color blue: "#31748f"
    readonly property color blueBright: "#4a8fa8"

    readonly property color purple: "#c4a7e7"
    readonly property color purpleBright: "#d7baff"

    readonly property color aqua: "#9ccfd8"
    readonly property color orange: "#ea9a97"
    readonly property color gray: "#6e6a86"

    // ================= SEMANTIC =================
    readonly property color accent: purple
    readonly property color accentHover: aqua
    readonly property color border: purple

    readonly property color success: green
    readonly property color warning: yellow
    readonly property color error: red

    // ================= TEXT ROLES =================
    readonly property color textPrimary: fg0      // 👈 slightly brighter works here
    readonly property color textSecondary: fg1
    readonly property color textMuted: fg2

    // ================= SURFACES =================
    readonly property color bg: "#191724"
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: blueBright
    readonly property color inactive: purpleBright
}
