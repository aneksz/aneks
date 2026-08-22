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
    signal clicked()
    anchors.verticalCenter: parent.verticalCenter

    width: root.track !== "" ? 260 : 0
    height: 30

    visible: root.track !== ""

    required property string track
    required property string artUrl
    required property var theme
    required property var spotifyControl

    // ================= ANIMATION =================
    Behavior on width {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 180
        }
    }

    // ================= ALBUM ART =================
    Image {
        id: albumArt

        source: root.artUrl

        width: 14
        height: 14

        anchors.verticalCenter: parent.verticalCenter

        fillMode: Image.PreserveAspectCrop
        smooth: true

        layer.enabled: true

        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: 18
                height: 18
                radius: 9
            }
        }
    }

    // ================= TRACK TEXT =================
    Text {
        id: spotifyText

        anchors.left: albumArt.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        text: root.track

        color: theme.success

        font {
            family: theme.font
            pointSize: theme.fontSize
        }

        elide: Text.ElideRight
    }

    // ================= INTERACTION =================
MouseArea {
    anchors.fill: parent

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    // Left click = Play / Pause
    // Right click = Media Player
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            root.spotifyControl.command = [
                "sh", "-c",
                "playerctl --player=spotify play-pause"
            ]

            root.spotifyControl.running = true
        }

        if (mouse.button === Qt.LeftButton) {
            root.clicked()
        }
    }

    // Scroll = Next / Previous
    onWheel: e => {
        root.spotifyControl.command = [
            "sh", "-c",
            e.angleDelta.y > 0
                ? "playerctl --player=spotify next"
                : "playerctl --player=spotify previous"
        ]

        root.spotifyControl.running = true
    }
  }
}