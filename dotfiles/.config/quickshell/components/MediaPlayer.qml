// components/MediaPlayer.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

PopupWindow {
    id: root

    required property bool visiblePlayer

    required property string track
    required property string artUrl

    required property real position
    required property real length

    required property var theme
    required property var spotifyControl

    required property Item anchorItem
    required property string status

    visible: visiblePlayer || card.opacity > 0

    color: "transparent"
    mask: null
    grabFocus: false

    implicitWidth: 340
    implicitHeight: card.implicitHeight + 4

    // ================= POSITION =================
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    anchor.margins {
        top: 40
    }

    // ================= HELPERS =================
    property string artist: {
        let parts = root.track.split(" - ")
        return parts.length > 1 ? parts[0] : ""
    }

    property string title: {
        let parts = root.track.split(" - ")
        return parts.length > 1
            ? parts.slice(1).join(" - ")
            : root.track
    }

    property real progress:
        length > 0 ? position / length : 0

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
        color: root.theme.bg

        border.color: Qt.rgba(1,1,1,0.06)
        border.width: 1

      // ================= ANIMATION =================
opacity: visiblePlayer ? 1 : 0
scale: visiblePlayer ? 1 : 0.98

transform: Translate {
    id: slideTransform

    y: visiblePlayer ? 0 : -40

    Behavior on y {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }
}

Behavior on opacity {
    NumberAnimation {
        duration: 300
    }
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

            // ================= ARTWORK =================
            Image {
                id: artwork

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

            // ================= TITLE =================
            Column {
                width: parent.width
                spacing: 4

                Text {
                    text: root.title

                    width: parent.width

                    color: root.theme.fg1

                    horizontalAlignment: Text.AlignHCenter

                    font {
                        family: root.theme.font
                        pixelSize: 16
                        bold: true
                    }

                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                }

                Text {
                    text: root.artist

                    width: parent.width

                    color: root.theme.inactive

                    horizontalAlignment: Text.AlignHCenter

                    font {
                        family: root.theme.font
                        pixelSize: 12
                    }

                    elide: Text.ElideRight
                }
            }

            // ================= PROGRESS =================
            Column {
    width: parent.width
    spacing: 6

    Rectangle {
        width: parent.width
        height: 5

        radius: 3

        color: Qt.rgba(1,1,1,0.08)

        Rectangle {
            width: parent.width * root.progress
            height: parent.height

            radius: parent.radius
            color: root.theme.success

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter

        text:
            root.formatTime(root.position)
            + " / " +
            root.formatTime(root.length)

        color: root.theme.inactive

        font {
            family: root.theme.font
            pixelSize: 12
        }
    }
}

   Row {
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 26

    // Previous
    Item {
        width: 56
        height: 56

        HoverItem {
            anchors.centerIn: parent
            iconSize: 22

            textValue: "󰙣"
            hovered: prevMouse.containsMouse

            theme: root.theme
            overrideColor: root.theme.fg1

            hoverScale: 1.08
        }

        MouseArea {
            id: prevMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.spotifyControl.command = [
                    "sh", "-c",
                    "playerctl --player=spotify previous"
                ]

                root.spotifyControl.running = true
            }
        }
    }

    // Play / Pause
    Item {
        width: 56
        height: 56

        HoverItem {
            anchors.centerIn: parent
            iconSize: 22

            textValue: root.status === "Playing"
                      ? ""
                      : ""
            hovered: playMouse.containsMouse

            theme: root.theme
            overrideColor: root.theme.success

            hoverScale: 1.08
        }

        MouseArea {
            id: playMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.spotifyControl.command = [
                    "sh", "-c",
                    "playerctl --player=spotify play-pause"
                ]

                root.spotifyControl.running = true
            }
        }
    }

    // Next
    Item {
        width: 56
        height: 56

        HoverItem {
            anchors.centerIn: parent
            iconSize: 22

            textValue: "󰙡"
            hovered: nextMouse.containsMouse

            theme: root.theme
            overrideColor: root.theme.fg1

            hoverScale: 1.08
        }

        MouseArea {
            id: nextMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.spotifyControl.command = [
                    "sh", "-c",
                    "playerctl --player=spotify next"
                ]

                root.spotifyControl.running = true
            }
        }
    }
}
            // ================= FOOTER =================
            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "Spotify"

                color: Qt.rgba(1,1,1,0.45)

                font {
                    family: root.theme.font
                    pixelSize: 12
                }
            }
        }
    }
}