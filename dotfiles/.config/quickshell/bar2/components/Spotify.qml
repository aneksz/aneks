// components/Spotify.qml
import Quickshell
import QtQuick
import QtQuick.Controls

Item {
    id: root
    signal clicked()

    height: 30
    property string track: ""
    property string icon: ""          
    property string artUrl: ""
    property var theme: null
    property var spotifyControl
    readonly property bool hovered: interactionZone.containsMouse

    // Icon size you can tweak independently
    property int iconSize: 16
    // Text size
    property int textSize: 15

    implicitWidth: Math.max(22, iconText.width + spotifyText.width + (iconText.visible ? 6 : 0))

    // Icon
    Text {
        id: iconText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 1
        visible: root.icon !== ""
        text: root.icon
        color: root.theme && root.theme.success ? root.theme.success : "#a3be8c"

        font {
            family: root.theme && root.theme.font ? root.theme.font : "JetBrainsMono Nerd Font Propo"
            pixelSize: root.iconSize
            weight: theme ? theme.fontWeight : Font.Normal
        }
    }

    // Track text
    Text {
        id: spotifyText
        anchors.left: iconText.visible ? iconText.right : parent.left
        anchors.leftMargin: iconText.visible ? 6 : 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 1
        text: root.track
        color: root.theme && root.theme.success ? root.theme.success : "#a3be8c"

        font {
            family: root.theme && root.theme.font ? root.theme.font : "JetBrainsMono Nerd Font Propo"
            pixelSize: root.textSize
            weight: theme ? theme.fontWeight : Font.Normal
        }

        width: Math.min(implicitWidth, 240)
        elide: Text.ElideRight
    }

    MouseArea {
        id: interactionZone
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (!root.spotifyControl) return
            if (mouse.button === Qt.RightButton) {
                root.spotifyControl.command = ["playerctl", "--player=spotify", "play-pause"]
                root.spotifyControl.running = true
            } else if (mouse.button === Qt.LeftButton) {
                root.clicked()
            }
        }

        onWheel: function(event) {
            if (!root.spotifyControl) return
            root.spotifyControl.command = [
                "playerctl", "--player=spotify",
                event.angleDelta.y > 0 ? "next" : "previous"
            ]
            root.spotifyControl.running = true
        }
    }
}