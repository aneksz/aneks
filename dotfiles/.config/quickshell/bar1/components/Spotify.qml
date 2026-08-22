// components/Spotify.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    signal clicked()
    anchors.verticalCenter: parent.verticalCenter

    // FIX 1: Lock the sub-component layout box size. 
    // This breaks the width dependency loop and allows your text node to draw properly!
    width: 260
    height: 30

    property string track: ""
    property string artUrl: ""
    property var theme
    property var spotifyControl

    // ============================================================
    // DYNAMIC LAYOUT GROUP
    // ============================================================
    Row {
        id: mainRow
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        
        // This ensures the row handles clipping if text exceeds 260px boundaries
        width: parent.width

        // ALBUM ART ROUND CAPSULE
        Image {
            id: albumArt
            source: root.artUrl !== "" ? root.artUrl : ""

            width: 18
            height: 18
            anchors.verticalCenter: parent.verticalCenter

            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true 

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: 14
                    height: 14
                    radius: 9
                }
            }
        }

        // TRACK TITLES (Completely independent of layout loops!)
        Text {
            id: spotifyText
            anchors.verticalCenter: parent.verticalCenter
            
            // Constrain width relative to parent envelope box allocations
            width: 232
            elide: Text.ElideRight
            
            text: root.track
            color: (theme && theme.success) ? theme.success : "#a3be8c" 

            font {
                family: (theme && theme.font) ? theme.font : "sans-serif"
                pixelSize: 14
                weight: fontWeight
            }
        }
    }

    // ============================================================
    // INTERACTION MOUSE CONTROLS
    // ============================================================
    MouseArea {
        id: interactionZone
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                if (root.spotifyControl) {
                    root.spotifyControl.command = ["sh", "-c", "playerctl --player=spotify play-pause"];
                    root.spotifyControl.running = true;
                }
            }
            if (mouse.button === Qt.LeftButton) {
                root.clicked();
            }
        }

        onWheel: function(e) {
            if (root.spotifyControl) {
                root.spotifyControl.command = [
                    "sh", "-c",
                    e.angleDelta.y > 0 ? "playerctl --player=spotify next" : "playerctl --player=spotify previous"
                ];
                root.spotifyControl.running = true;
            }
        }
    }
}
