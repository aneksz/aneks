import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#192330"
    readonly property color bg1: "#1d2b3a"
    readonly property color bg2: "#223249"
    readonly property color bg3: "#2f3f5e"
    readonly property color bg4: "#3b5075"

    // ================= FOREGROUND =================
    readonly property color fg0: "#cdcecf"
    readonly property color fg1: "#b8c0cc"
    readonly property color fg2: "#9da9ba"
    readonly property color fg3: "#738091"

    // ================= BASE =================
    readonly property color red: "#c94f6d"
    readonly property color redBright: "#d16983"

    readonly property color green: "#81b29a"
    readonly property color greenBright: "#9ccfb8"

    readonly property color yellow: "#dbc074"
    readonly property color yellowBright: "#e6cf86"

    readonly property color blue: "#719cd6"
    readonly property color blueBright: "#86abdc"

    readonly property color purple: "#9d79d6"
    readonly property color purpleBright: "#b08ae6"

    readonly property color aqua: "#63cdcf"
    readonly property color orange: "#f4a261"
    readonly property color gray: "#738091"

    // ================= SEMANTIC =================
    readonly property color accent: blue
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
    readonly property color bg: "#192330"
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: purple   // 👈 signature Nightfox
    readonly property color inactive: blueBright
}
