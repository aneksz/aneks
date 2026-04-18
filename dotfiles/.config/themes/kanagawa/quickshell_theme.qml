import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#1f1f28"
    readonly property color bg1: "#2a2a37"
    readonly property color bg2: "#363646"
    readonly property color bg3: "#54546d"
    readonly property color bg4: "#727169"

    // ================= FOREGROUND =================
    readonly property color fg0: "#dcd7ba"
    readonly property color fg1: "#c8c093"
    readonly property color fg2: "#a6a69c"
    readonly property color fg3: "#727169"

    // ================= BASE =================
    readonly property color red: "#c34043"
    readonly property color redBright: "#e82424"

    readonly property color green: "#98bb6c"
    readonly property color greenBright: "#b8d99f"

    readonly property color yellow: "#dca561"
    readonly property color yellowBright: "#e6c384"

    readonly property color blue: "#7e9cd8"
    readonly property color blueBright: "#9cabca"

    readonly property color purple: "#957fb8"
    readonly property color purpleBright: "#b8a0d9"

    readonly property color aqua: "#7aa89f"
    readonly property color orange: "#ffa066"
    readonly property color gray: "#727169"

    // ================= SEMANTIC =================
    readonly property color accent: blue
    readonly property color accentHover: aqua
    readonly property color border: blue

    readonly property color success: green
    readonly property color warning: yellow
    readonly property color error: red

    // ================= TEXT ROLES =================
    readonly property color textPrimary: fg1
    readonly property color textSecondary: fg2
    readonly property color textMuted: fg3

    // ================= SURFACES =================
    readonly property color bg: "#1f1f28"
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: blueBright   // 👈 signature Kanagawa
    readonly property color inactive: blue
}
