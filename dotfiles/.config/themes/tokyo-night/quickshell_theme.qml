import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#1a1b26"
    readonly property color bg1: "#1f2335"
    readonly property color bg2: "#24283b"
    readonly property color bg3: "#414868"
    readonly property color bg4: "#565f89"

    // ================= FOREGROUND =================
    readonly property color fg0: "#c0caf5"
    readonly property color fg1: "#a9b1d6"
    readonly property color fg2: "#9aa5ce"
    readonly property color fg3: "#565f89"

    // ================= BASE =================
    readonly property color red: "#f7768e"
    readonly property color redBright: "#ff8da1"

    readonly property color green: "#9ece6a"
    readonly property color greenBright: "#b9f27c"

    readonly property color yellow: "#e0af68"
    readonly property color yellowBright: "#f5c178"

    readonly property color blue: "#7aa2f7"
    readonly property color blueBright: "#9ab8ff"

    readonly property color purple: "#bb9af7"
    readonly property color purpleBright: "#d2b3ff"

    readonly property color aqua: "#7dcfff"
    readonly property color orange: "#ff9e64"
    readonly property color gray: "#565f89"

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
    readonly property color bg: "#1a1b26"
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: red
    readonly property color inactive: blue
}
