import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // ── Interface (unchanged, shell.qml keeps working) ──────────────
    property var theme
    property var themeFolders: []
    property var wallpapers: []
    property var applyWallpaper
    property var wallpaperProc

    property string currentMonitor: "DP-1"
    property string currentResolutionFolder: "4K"
    property string currentThemeFolder: ""

    signal closeRequested()
    signal folderChanged(string folder)
    signal resolutionChanged(string folder)

    readonly property var filteredWallpapers: {
        const all = root.wallpapers || []
        if (root.currentThemeFolder === "")
            return all
        const needle = "/" + root.currentThemeFolder + "/"
        return all.filter(p => p.includes(needle))
    }

    implicitWidth: 920
    implicitHeight: 640
    focus: true

    Keys.onEscapePressed: root.closeRequested()
    onVisibleChanged: if (visible) forceActiveFocus()

    function tint(a) { return Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, a) }

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: "transparent"
      

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 12

            // ── Header ──────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    radius: 12
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "󰸉"
                        font.pixelSize: 22
                        font.family: theme.font
                        color: theme.accent
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Wallpapers"
                        font.family: theme.font
                        font.pixelSize: 20
                        font.bold: true
                        color: theme.fg0
                    }
                    Text {
                        text: root.filteredWallpapers.length + " images · click one to apply it to " + root.currentMonitor
                        font.family: theme.font
                        font.pixelSize: 13
                        color: theme.textMuted
                    }
                }

                Item { Layout.fillWidth: true }

                // Resolution / monitor toggle
                Rectangle {
                    id: resPill
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: resRow.implicitWidth + 28
                    radius: 16
                    color: resMouse.containsMouse ? root.tint(0.22) : root.tint(0.12)
                    border.width: 1
                    border.color: theme.accent
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Row {
                        id: resRow
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "󰍹"
                            font.pixelSize: 14
                            font.family: theme.font
                            color: theme.accent
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: root.currentResolutionFolder
                            font.family: theme.font
                            font.pixelSize: 13
                            font.bold: true
                            color: theme.accent
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: resMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.currentResolutionFolder === "4K") {
                                root.currentResolutionFolder = "HD"
                                root.currentMonitor = "DP-3"
                            } else {
                                root.currentResolutionFolder = "4K"
                                root.currentMonitor = "DP-1"
                            }
                            root.currentThemeFolder = ""
                            root.resolutionChanged(root.currentResolutionFolder)
                        }
                    }
                }

            }

            // ── Theme folder chips ──────────────────────────────────
            Flow {
                Layout.fillWidth: true
                spacing: 8
                visible: (root.themeFolders || []).length > 1

                Repeater {
                    model: root.themeFolders

                    Rectangle {
                        required property var modelData
                        readonly property bool active: root.currentThemeFolder === modelData

                        height: 32
                        width: chipText.implicitWidth + 28
                        radius: 16
                        color: active ? root.tint(0.22)
                             : chipMouse.containsMouse ? theme.surfaceAlt : theme.surface
                        border.width: 1
                        border.color: active ? theme.accent : theme.border
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: modelData === "" ? "All" : modelData
                            font.family: theme.font
                            font.pixelSize: 13
                            font.bold: parent.active
                            color: parent.active ? theme.accent : theme.fg
                        }
                        MouseArea {
                            id: chipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.currentThemeFolder = modelData
                                root.folderChanged(modelData)
                            }
                        }
                    }
                }
            }

            // ── Grid ────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GridView {
                    id: grid
                    anchors.fill: parent
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.filteredWallpapers

                    readonly property int columns: Math.max(2, Math.floor(width / 180))
                    cellWidth: Math.floor(width / columns)
                    cellHeight: Math.round(cellWidth * 0.58)

                    delegate: Item {
                        id: cell
                        required property var modelData
                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            id: tile
                            anchors.fill: parent
                            anchors.margins: 6
                            radius: 12
                            color: theme.surface
                            scale: tileMouse.containsMouse ? 1.03 : 1.0
                            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                            Image {
                                id: img
                                anchors.fill: parent
                                source: "file://" + cell.modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                                sourceSize.width: 400
                                visible: false
                            }
                            Rectangle {
                                id: mask
                                anchors.fill: parent
                                radius: 12
                                visible: false
                            }
                            OpacityMask {
                                anchors.fill: parent
                                source: img
                                maskSource: mask
                                opacity: img.status === Image.Ready ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }

                            // hover border
                            Rectangle {
                                anchors.fill: parent
                                radius: 12
                                color: "transparent"
                                border.width: tileMouse.containsMouse ? 2 : 1
                                border.color: tileMouse.containsMouse ? theme.accent : theme.border
                            }

                            MouseArea {
                                id: tileMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // Apply the wallpaper, and when it is for the primary monitor
                                    // (DP-1) also repoint the lock screen's current.png at it.
                                    root.applyWallpaper.command = [
                                        "sh", "-c",
                                        'awww img "$1" --outputs "$2" --transition-type any && ' +
                                        '{ [ "$2" != "DP-1" ] || ln -sf "$1" "$HOME/.config/hypr/background/current.png"; }',
                                        "sh", cell.modelData, root.currentMonitor
                                    ]
                                    root.applyWallpaper.running = true
                                    root.closeRequested()
                                }
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.filteredWallpapers.length === 0
                    text: "No wallpapers found"
                    font.family: theme.font
                    font.pixelSize: 14
                    color: theme.textMuted
                    opacity: 0.5
                }
            }

        }
    }
}
