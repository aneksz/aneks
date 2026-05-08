// components/Spotify.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

// ================= SPOTIFY =================
Item {
    id: root

    width: root.track !== "" ? 320 : 0
    height: 30
    visible: root.track !== ""

    required property string track
    required property string artUrl
    required property var theme
    required property var spotifyControl

    // --- ALBUM ART ---
    Image {
        id: albumArt
        source: root.artUrl
        width: 22
        height: 22
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectCrop

        layer.enabled: false
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: 20
                height: 20
                radius: 10
            }
        }
    }

    // --- TRACK TEXT ---
    Text {
        id: spotifyText
        anchors.left: albumArt.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.track
        color: theme.success
        font { family: theme.font; pointSize: theme.fontSize }
        elide: Text.ElideRight
    }

    // --- CONTROLS ---
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.spotifyControl.command = [
                "sh","-c","playerctl --player=spotify play-pause"
            ]
            root.spotifyControl.running = true
        }

        onWheel: e => {
            root.spotifyControl.command = [
                "sh","-c",
                e.angleDelta.y > 0
                    ? "playerctl --player=spotify next"
                    : "playerctl --player=spotify previous"
            ]
            root.spotifyControl.running = true
        }
    }
}