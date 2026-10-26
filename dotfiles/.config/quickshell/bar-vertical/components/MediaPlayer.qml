// components/MediaPlayer.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

PopupWindow {
    id: root

    // ================= EXTERNAL API =================
    required property bool visiblePlayer
    required property string track
    required property string artUrl
    required property real position
    required property real length
    required property var theme
    required property var spotifyControl
    required property Item anchorItem
    required property string status

    // ================= INTERNAL STATE =================
    property bool open: false

    onVisiblePlayerChanged: {
        if (visiblePlayer) {
            open = true
        } else {
            Qt.callLater(() => open = false)
        }
    }

    // Keep window alive for exit animation
    visible: open || card.opacity > 0

    color: "transparent"
    mask: null
    grabFocus: false

    implicitWidth: 340
    implicitHeight: card.implicitHeight + 4

    // ================= ANCHOR =================
    anchor.item: anchorItem
    anchor.edges: theme.vertical ? Edges.Right : Edges.Bottom
    anchor.gravity: theme.vertical ? Edges.Right : Edges.Bottom
    anchor.margins.top: theme.vertical ? 0 : 40
    anchor.margins.left: theme.vertical ? 40 : 0

    // ================= DERIVED DATA =================
    property string artist: {
        let parts = track.split(" - ")
        return parts.length > 1 ? parts[0] : ""
    }

    property string title: {
        let parts = track.split(" - ")
        return parts.length > 1 ? parts.slice(1).join(" - ") : track
    }

    property real progress: length > 0 ? position / length : 0

    function formatTime(sec) {
        let s = Math.floor(sec % 60)
        let m = Math.floor(sec / 60)
        return m + ":" + (s < 10 ? "0" + s : s)
    }

    // ================= CARD =================
    Rectangle {
        id: card

        width: 340
        implicitHeight: contentColumn.implicitHeight + 40

        radius: 24
        color: theme.bg

        border.color: Qt.rgba(1, 1, 1, 0.06)
        border.width: 1

        // ================= ANIMATION STATE =================
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.98

        transform: Translate {
            y: root.open ? 0 : -40

            Behavior on y {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 260
                easing.type: Easing.OutCubic
            }
        }

        // ================= CONTENT =================
        Column {
            id: contentColumn
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 18

            // ================= ART =================
            Image {
                source: root.artUrl
                width: 300
                height: 300
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectCrop
                smooth: true

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: 300
                        height: 300
                        radius: 22
                    }
                }
            }

            // ================= TEXT =================
            Column {
                width: parent.width
                spacing: 4

                Text {
                    text: root.title
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    color: theme.fg1
                    font { family: theme.font; pixelSize: 16; bold: true }
                    wrapMode: Text.WordWrap
                }

                Text {
                    text: root.artist
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    color: theme.inactive
                    font { family: theme.font; pixelSize: 12 }
                }
            }

            // ================= PROGRESS =================
            Column {
                width: parent.width
                spacing: 6

                Item {
                    id: progressBar
                    width: parent.width
                    height: 6

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: Qt.rgba(1, 1, 1, 0.08)
                    }

                    Rectangle {
                        width: parent.width * root.progress
                        height: parent.height
                        radius: 3
                        color: theme.success
                    }

                    function seekAt(x) {
                        let ratio = Math.max(0, Math.min(1, x / width))
                        let target = ratio * root.length

                        root.spotifyControl.command = [
                            "sh", "-c",
                            "playerctl --player=spotify position " + target
                        ]
                        root.spotifyControl.running = true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onPressed: (mouse) => {
                            progressBar.seekAt(mouse.x)
                        }

                        onPositionChanged: (mouse) => {
                            if (pressed)
                                progressBar.seekAt(mouse.x)
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.formatTime(root.position) + " / " + root.formatTime(root.length)
                    color: theme.inactive
                    font { family: theme.font; pixelSize: 12 }
                }
            }

            // ================= CONTROLS =================
            Item {
                width: parent.width
                height: 56

                Row {
                    anchors.centerIn: parent
                    spacing: 26

                    // PREV
                    Item {
                        width: 56; height: 56

                        HoverItem {
                            anchors.centerIn: parent
                            iconSize: 22
                            textValue: "󰙣"
                            hovered: prevMouse.containsMouse
                            theme: root.theme
                            overrideColor: theme.fg1
                            hoverScale: 1.08
                        }

                        MouseArea {
                            id: prevMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.spotifyControl.command = ["sh","-c","playerctl previous"]
                                root.spotifyControl.running = true
                            }
                        }
                    }

                    // PLAY
                    Item {
                        width: 56; height: 56

                        HoverItem {
                            anchors.centerIn: parent
                            iconSize: 22
                            textValue: root.status === "Playing" ? "" : ""
                            hovered: playMouse.containsMouse
                            theme: root.theme
                            overrideColor: theme.success
                            hoverScale: 1.08
                        }

                        MouseArea {
                            id: playMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.spotifyControl.command = ["sh","-c","playerctl play-pause"]
                                root.spotifyControl.running = true
                            }
                        }
                    }

                    // NEXT
                    Item {
                        width: 56; height: 56

                        HoverItem {
                            anchors.centerIn: parent
                            iconSize: 22
                            textValue: "󰙡"
                            hovered: nextMouse.containsMouse
                            theme: root.theme
                            overrideColor: theme.fg1
                            hoverScale: 1.08
                        }

                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.spotifyControl.command = ["sh","-c","playerctl next"]
                                root.spotifyControl.running = true
                            }
                        }
                    }
                }
            }
        }
    }
}