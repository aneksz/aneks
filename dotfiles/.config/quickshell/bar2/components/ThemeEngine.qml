import QtQuick

Item {
    id: root

    // =====================================================
    // PUBLIC API
    // =====================================================

    property int themeUpdateTrigger: 0
    property alias theme: themeObject
    property alias themeLoader: themeLoader

    // =====================================================
    // THEME SOURCE
    // =====================================================

    Loader {
        id: themeLoader

        source: "file:///home/igor/.config/quickshell/bar2/Colors.qml"

        onStatusChanged: {
            if (status === Loader.Ready)
                root.themeUpdateTrigger++
        }
    }

    // =====================================================
    // NORMALISED COLOUR PALETTE
    // =====================================================

    QtObject {
        id: c

        readonly property bool ready: themeLoader.status === Loader.Ready

        property color bg: ready ? (themeLoader.item?.bg ?? "#11111b") : "#11111b"
        property color fg: ready ? (themeLoader.item?.textPrimary ?? themeLoader.item?.fg0 ?? "#cdd6f4") : "#cdd6f4"
        property color accent: ready ? (themeLoader.item?.accent ?? "#89b4fa") : "#89b4fa"
        property color inactive: ready ? (themeLoader.item?.inactive ?? "#6c7086") : "#6c7086"
        property color activeWs: ready ? (themeLoader.item?.activeWs ?? "#89b4fa") : "#89b4fa"

        property color green: ready ? (themeLoader.item?.green ?? "#a6e3a1") : "#a6e3a1"
        property color red: ready ? (themeLoader.item?.red ?? "#f38ba8") : "#f38ba8"

        property color surface: ready ? (themeLoader.item?.surface ?? "#313244") : "#313244"
        property color fg1: ready ? (themeLoader.item?.fg1 ?? "#cdd6f4") : "#cdd6f4"
    

        property color warning: ready ? (themeLoader.item?.warning ?? "#ebcb8b") : "#ebcb8b"
        property color success: ready ? (themeLoader.item?.success ?? "#a6e3a1") : "#a6e3a1"
        property color error: ready ? (themeLoader.item?.error ?? "#f38ba8") : "#f38ba8"

        property color bgAlt: ready ? (themeLoader.item?.bg1 ?? bg) : bg
        property color surfaceAlt: ready ? (themeLoader.item?.surfaceAlt ?? surface) : surface
        property color border: ready ? (themeLoader.item?.border ?? accent) : accent
        property color hover: ready ? (themeLoader.item?.accentHover ?? accent) : accent
        property color textSecondary: ready ? (themeLoader.item?.textSecondary ?? fg1) : fg1
        property color fg0: ready ? (themeLoader.item?.fg0 ?? themeLoader.item?.textPrimary ?? "#cdd6f4") : "#cdd6f4"
        property color fg2: ready ? (themeLoader.item?.fg2 ?? fg1) : fg1
        property color fg3: ready ? (themeLoader.item?.fg3 ?? "#c0c5ce") : "#c0c5ce"
    }

    // =====================================================
    // PUBLIC THEME OBJECT
    // =====================================================

    QtObject {
        id: themeObject

        property string font: "JetBrainsMono Nerd Font Propo"
        property real fontSize: 12
        property int fontWeight: Font.DemiBold

        property color bg: c.bg
        property color fg: c.fg   
        property color fg0: c.fg0
        property color fg1: c.fg1
        property color fg2: c.fg2
        property color fg3: c.fg3
        property color accent: c.accent
        property color hover: c.hover
        property color border: c.border

        property color green: c.green
        property color red: c.red

        property color warning: c.warning
        property color success: c.success
        property color error: c.error

        property color surface: c.surface
        property color surfaceAlt: c.surfaceAlt
        property color bgAlt: c.bgAlt

        property color inactive: c.inactive
        property color activeWs: c.activeWs

        property color textMuted: c.fg3
        property color textSecondary: c.textSecondary
    }
}