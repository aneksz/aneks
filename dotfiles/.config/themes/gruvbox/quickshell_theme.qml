import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#1d2021"
    readonly property color bg1: "#282828"
    readonly property color bg2: "#32302f"
    readonly property color bg3: "#3c3836"
    readonly property color bg4: "#504945"

    // ================= FOREGROUND =================
    readonly property color fg0: "#fbf1c7"
    readonly property color fg1: "#ebdbb2"
    readonly property color fg2: "#d5c4a1"
    readonly property color fg3: "#bdae93"

    // ================= BASE =================
    readonly property color red: "#cc241d"
    readonly property color redBright: "#fb4934"

    readonly property color green: "#98971a"
    readonly property color greenBright: "#b8bb26"

    readonly property color yellow: "#d79921"
    readonly property color yellowBright: "#fabd2f"

    readonly property color blue: "#458588"
    readonly property color blueBright: "#83a598"

    readonly property color purple: "#b16286"
    readonly property color aqua: "#689d6a"
    readonly property color orange: "#d65d0e"
    readonly property color gray: "#928374"

    // ================= SEMANTIC =================
    readonly property color accent: blue
    readonly property color accentHover: aqua
    readonly property color border: yellow

    readonly property color success: greenBright
    readonly property color warning: yellowBright
    readonly property color error: redBright

    // ================= TEXT ROLES =================
    readonly property color textPrimary: fg1
    readonly property color textSecondary: fg2
    readonly property color textMuted: fg3

    // ================= SURFACES =================
    readonly property color bg: "#1d2021"
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: blueBright     // 👈 nice Gruvbox highlight
    readonly property color inactive: fg3
}
