import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#1c1e26"
    readonly property color bg1: "#232530"
    readonly property color bg2: "#2e303e"
    readonly property color bg3: "#3b3e51"
    readonly property color bg4: "#4a4f6a"

    // ================= FOREGROUND =================
    readonly property color fg0: "#d5c1ac"
    readonly property color fg1: "#c7b9a8"
    readonly property color fg2: "#a8a8b3"
    readonly property color fg3: "#6e6e7e"

    // ================= BASE =================
    readonly property color red: "#e95678"
    readonly property color redBright: "#ff6e92"

    readonly property color green: "#29d398"
    readonly property color greenBright: "#3be6aa"

    readonly property color yellow: "#fab795"
    readonly property color yellowBright: "#ffc7a8"

    readonly property color blue: "#26bbd9"
    readonly property color blueBright: "#3fd4f2"

    readonly property color purple: "#ee64ac"
    readonly property color purpleBright: "#ff7cc6"

    readonly property color aqua: "#59e1e3"
    readonly property color orange: "#f09383"
    readonly property color gray: "#6e6e7e"

    // ================= SEMANTIC =================
    readonly property color accent: purple          // 👈 Horizon identity
    readonly property color accentHover: aqua
    readonly property color border: purple

    readonly property color success: green
    readonly property color warning: yellow
    readonly property color error: red

    // ================= TEXT ROLES =================
    readonly property color textPrimary: fg1
    readonly property color textSecondary: fg2
    readonly property color textMuted: fg3

    // ================= SURFACES =================
    readonly property color bg: "#1c1e26"
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: purpleBright   // 👈 nice pop
    readonly property color inactive: blue
}
