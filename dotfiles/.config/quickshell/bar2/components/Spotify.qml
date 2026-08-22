// components/Spotify.qml
import Quickshell
import QtQuick
import QtQuick.Controls

Item {
    id: root
    signal clicked()

    height: 30
    property string track: ""
    property string artUrl: "" // Kept property intact so your main loaders don't throw binding errors
    property var theme: null
    property var spotifyControl
    readonly property bool hovered: interactionZone.containsMouse
    
    // Fixed: Measure only the text footprint to match left-side module edge-spacing perfectly
    implicitWidth: Math.max(22, spotifyText.width)

    Text {
        id: spotifyText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.track
        color: root.theme && root.theme.success ? root.theme.success : "#a3be8c"
        
        font {
            family: root.theme && root.theme.font ? root.theme.font : "JetBrainsMono Nerd Font Propo"
            pixelSize: 16
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
            if (!root.spotifyControl) return;
            if (mouse.button === Qt.RightButton) {
                root.spotifyControl.command = ["playerctl", "--player=spotify", "play-pause"];
                root.spotifyControl.running = true;
            } else if (mouse.button === Qt.LeftButton) {
                root.clicked();
            }
        }

        onWheel: function(event) {
            if (!root.spotifyControl) return;
            root.spotifyControl.command = ["playerctl", "--player=spotify", event.angleDelta.y > 0 ? "next" : "previous"];
            root.spotifyControl.running = true;
        }
    }
}
