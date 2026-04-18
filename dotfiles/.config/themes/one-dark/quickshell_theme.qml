import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#1e2127"
    readonly property color bg1: "#282c34"
    readonly property color bg2: "#2c313c"
    readonly property color bg3: "#353b45"
    readonly property color bg4: "#3e4451"

    // ================= FOREGROUND =================
    readonly property color fg0: "#abb2bf"
    readonly property color fg1: "#9da5b4"
    readonly property color fg2: "#7f848e"
    readonly property color fg3: "#5c6370"

    // ================= BASE =================
    readonly property color red: "#e06c75"
    readonly property color redBright: "#ff7a84"

    readonly property color green: "#98c379"
    readonly property color greenBright: "#b6e08a"

    readonly property color yellow: "#e5c07b"
    readonly property color yellowBright: "#ffd68a"

    readonly property color blue: "#61afef"
    readonly property color blueBright: "#7bc3ff"

    readonly property color purple: "#c678dd"
    readonly property color purpleBright: "#d891f0"

    readonly property color aqua: "#56b6c2"
    readonly property color orange: "#d19a66"
    readonly property color gray: "#5c6370"

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
    readonly property color bg: "#1e2127"
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: fg3
    readonly property color inactive: blueBright
}
