// components/MediaPlayer.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // ================= EXTERNAL API =================
    property string track: ""
property string artUrl: ""
property real position: 0
property real length: 0
property var theme
property var spotifyControl
property string status: "Paused"

    // Ensure it references dimensions relative to the container frame width
    width: parent.width
    height: contentColumn.implicitHeight + 40

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

    // ================= CONTENT COLUMN =================
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
                color: theme.fg || theme.fg1
                font { family: theme.font; pixelSize: 16; bold: true }
                wrapMode: Text.WordWrap
            }

            Text {
                text: root.artist
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: theme.textMuted || theme.inactive
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
                    color: theme.accent || theme.success
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
                color: theme.textMuted || theme.inactive
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
                // PREV
Item {
    width: 56
    height: 56

    HoverItem {
        anchors.centerIn: parent

        iconSize: 22
        textValue: "󰙣"

        hovered:
            prevMouse.containsMouse

        theme:
            root.theme

        overrideColor:
            prevMouse.containsMouse
            ? root.theme.accent
            : root.theme.fg

        hoverScale:
            1.12
    }

    MouseArea {
        id: prevMouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        onClicked: {
            root.spotifyControl.command =
                ["sh", "-c", "playerctl previous"]

            root.spotifyControl.running =
                true
        }
    }
}

                // PLAY / PAUSE
                // PLAY / PAUSE
Item {
    width: 56
    height: 56

    HoverItem {
        anchors.centerIn: parent

        iconSize: 22

        textValue:
            root.status === "Playing"
            ? ""
            : ""

        hovered:
            playMouse.containsMouse

        theme:
            root.theme

        overrideColor:
            playMouse.containsMouse
            ? root.theme.accent
            : root.theme.accent

        hoverScale:
            1.15
    }

    MouseArea {
        id: playMouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        onClicked: {
            root.spotifyControl.command =
                ["sh", "-c", "playerctl play-pause"]

            root.spotifyControl.running =
                true
        }
    }
}

                // NEXT
                // NEXT
Item {
    width: 56
    height: 56

    HoverItem {
        anchors.centerIn: parent

        iconSize: 22
        textValue: "󰙡"

        hovered:
            nextMouse.containsMouse

        theme:
            root.theme

        overrideColor:
            nextMouse.containsMouse
            ? root.theme.accent
            : root.theme.fg

        hoverScale:
            1.12
    }

    MouseArea {
        id: nextMouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        onClicked: {
            root.spotifyControl.command =
                ["sh", "-c", "playerctl next"]

            root.spotifyControl.running =
                true
        }
    }
}
            }
        }
    }
}
