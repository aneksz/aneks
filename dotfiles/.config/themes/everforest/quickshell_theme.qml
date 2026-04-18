import QtQuick

QtObject {
    // ================= BACKGROUNDS =================
    readonly property color bg0: "#2b3339"
    readonly property color bg1: "#323c41"
    readonly property color bg2: "#3a454a"
    readonly property color bg3: "#445055"
    readonly property color bg4: "#4c555b"

    // ================= FOREGROUND =================
    readonly property color fg0: "#d3c6aa"
    readonly property color fg1: "#d3c6aa"
    readonly property color fg2: "#a7c080"
    readonly property color fg3: "#859289"

    // ================= BASE =================
    readonly property color red: "#e67e80"
    readonly property color green: "#a7c080"
    readonly property color yellow: "#dbbc7f"
    readonly property color blue: "#7fbbb3"
    readonly property color purple: "#d699b6"
    readonly property color aqua: "#83c092"
    readonly property color orange: "#e69875"

    // ================= SEMANTIC =================
    readonly property color accent: blue
    readonly property color accentHover: aqua
    readonly property color border: yellow

    readonly property color success: green
    readonly property color warning: yellow
    readonly property color error: red

    // ================= TEXT ROLES =================
    readonly property color textPrimary: fg0
    readonly property color textSecondary: fg2   // 👈 green-tinted text
    readonly property color textMuted: fg3

    // ================= SURFACES =================
    readonly property color bg: "#2b3339"
    readonly property color surface: bg2
    readonly property color surfaceAlt: bg1

    // ================= WORKSPACES =================
    readonly property color activeWs: green      // 👈 signature Everforest look
    readonly property color inactive: fg1
}
