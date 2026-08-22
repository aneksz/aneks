import QtQuick
import Quickshell

Item {
id: root


// ============================================================
// API
// ============================================================

property string currentTheme

property var checkCurrent
property var getThemes
property var themeLoader
property var theme
property var themes

// ============================================================
// THEME PREVIEW PALETTES
// ============================================================

property var themePreviews: ({

    "catppuccin": {
        bg: "#1e1e2e",
        accent: "#cba6f7",
        fg: "#cdd6f4"
    },

    "dracula": {
        bg: "#282a36",
        accent: "#bd93f9",
        fg: "#f8f8f2"
    },

    "everforest": {
        bg: "#2d353b",
        accent: "#a7c080",
        fg: "#d3c6aa"
    },

    "graphite-dark": {
        bg: "#1c1c1c",
        accent: "#3a3a3a",
        fg: "#e0e0e0"
    },

    "gruvbox": {
        bg: "#282828",
        accent: "#fabd2f",
        fg: "#ebdbb2"
    },

    "horizon": {
        bg: "#1c1e26",
        accent: "#e95678",
        fg: "#d5d8da"
    },

    "kanagawa": {
        bg: "#1f1f28",
        accent: "#7e9cd8",
        fg: "#dcd7ba"
    },

    "nightfox": {
        bg: "#192330",
        accent: "#719cd6",
        fg: "#cdcecf"
    },

    "nord": {
        bg: "#2e3440",
        accent: "#88c0d0",
        fg: "#eceff4"
    },

    "one-dark": {
        bg: "#282c34",
        accent: "#61afef",
        fg: "#abb2bf"
    },

    "rose-pine": {
        bg: "#191724",
        accent: "#c4a7e7",
        fg: "#e0def4"
    },

    "tokyo-night": {
        bg: "#1a1b26",
        accent: "#7aa2f7",
        fg: "#c0caf5"
    }
})

// ============================================================
// SIZE
// ============================================================

anchors.fill: parent

// ============================================================
// THEME GRID
// ============================================================

Grid {
    id: themeGrid

    anchors.centerIn: parent

    columns: 4
    columnSpacing: 12
    rowSpacing: 12

    Repeater {
        model: root.themes

        delegate: Rectangle {
            id: themeCard

            width: 120
            height: 110

            radius: 16

            property var preview:
                root.themePreviews[modelData]

            // ====================================================
            // CARD STYLE
            // ====================================================

            color:
                preview
                ? preview.bg
                : root.theme.bg

            border.width:
                modelData === root.currentTheme
                ? 2
                : 0

            border.color:
                preview
                ? preview.accent
                : root.theme.accent

            scale:
                themeMouse.containsMouse
                ? 1.04
                : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 140
                }
            }

            // ====================================================
            // CARD CONTENT
            // ====================================================

            Column {
                anchors.centerIn: parent

                spacing: 10

                // ------------------------------------------------
                // ACCENT PILL
                // ------------------------------------------------

                Rectangle {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    width: 64
                    height: 10

                    radius:
                        height / 2

                    color:
                        preview
                        ? preview.accent
                        : root.theme.accent
                }

                // ------------------------------------------------
                // THEME NAME
                // ------------------------------------------------

                Text {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        modelData

                    color:
                        preview
                        ? preview.fg
                        : root.theme.fg

                    font {
                        family:
                            root.theme.font

                        pixelSize:
                            12

                        weight:
                            Font.Bold
                    }
                }
            }

            // ====================================================
            // CLICK
            // ====================================================

            MouseArea {
                id: themeMouse

                anchors.fill: parent

                hoverEnabled: true

                cursorShape:
                    Qt.PointingHandCursor

                onClicked: {
                    root.currentTheme =
                        modelData

                    Quickshell.execDetached([
                        "sh",
                        "-c",
                        "/home/igor/.config/themes/" +
                        modelData +
                        ".sh"
                    ])

                    Qt.callLater(() => {
                        root.themeLoader.source = ""

                        root.themeLoader.source =
                            "file:///home/igor/.config/quickshell/bar2/Colors.qml?v=" +
                            Date.now()
                    })
                }
            }
        }
    }
}
}
