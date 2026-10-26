// components/Spotify.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    signal clicked()

    property string track: ""
    property string artUrl: ""
    property var theme
    property var spotifyControl

    implicitWidth: theme && theme.vertical ? verticalLayout.implicitWidth : horizontalLayout.implicitWidth
    implicitHeight: theme && theme.vertical ? verticalLayout.implicitHeight : horizontalLayout.implicitHeight
    width: implicitWidth
    height: implicitHeight

    // ============================================================
    // HORIZONTAL: icon + elided title, side by side
    // ============================================================
    Row {
        id: horizontalLayout
        visible: !(theme && theme.vertical)
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 260

        Image {
            id: albumArtH
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

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 232
            elide: Text.ElideRight
            text: root.track
            color: (theme && theme.success) ? theme.success : "#a3be8c"

            font {
                family: (theme && theme.font) ? theme.font : "sans-serif"
                pixelSize: 14
                weight: (theme && theme.fontWeight) ? theme.fontWeight : Font.Normal
            }
        }
    }

    // ============================================================
    // VERTICAL: rotated title only, no album art - always visible
    // ============================================================
    Column {
        id: verticalLayout
        visible: theme && theme.vertical
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        Item {
            id: textWrapper
            anchors.horizontalCenter: parent.horizontalCenter
            width: rotatedText.contentHeight
            height: 140   // max vertical space the title may take - tune to taste

            Text {
                id: rotatedText
                anchors.centerIn: parent
                width: textWrapper.height
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                rotation: -90
                text: root.track
                color: (theme && theme.success) ? theme.success : "#a3be8c"

                font {
                    family: (theme && theme.font) ? theme.font : "sans-serif"
                    pixelSize: 14
                    weight: (theme && theme.fontWeight) ? theme.fontWeight : Font.Normal
                }
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