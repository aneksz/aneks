// components/Spotify.qml

import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects


Item {
    id: root


    signal clicked()


    // ============================================================
    // PROPERTIES
    // ============================================================
    height: 30

    property string track: ""
    property string artUrl: ""

    property var theme: null
    property var spotifyControl



    // ============================================================
    // NATURAL SIZE
    // ============================================================
    implicitWidth:
        spotifyRow.width



    // ============================================================
    // SPOTIFY CONTENT
    // ============================================================
    Row {

        id: spotifyRow


        spacing: 8


        anchors {
            verticalCenter: parent.verticalCenter
        }



        // --------------------------------------------------------
        // ALBUM ART
        // --------------------------------------------------------
        Image {

            id: albumArt


            width: 14
            height: 14


            anchors.verticalCenter:
                parent.verticalCenter


            source:
                root.artUrl !== ""
                ? root.artUrl
                : ""


            fillMode:
                Image.PreserveAspectCrop


            smooth: true

            asynchronous: true



            layer.enabled: true

            layer.effect:
                OpacityMask {

                    maskSource:

                        Rectangle {

                            width: 18
                            height: 18

                            radius: 9
                        }
                }
        }



        // --------------------------------------------------------
        // TRACK TITLE
        // --------------------------------------------------------
        Text {

            id: spotifyText


            anchors.verticalCenter:
                parent.verticalCenter


            text:
                root.track


            color:
                root.theme && root.theme.success
                ? root.theme.success
                : "#a3be8c"



            font {

                family:
                    root.theme && root.theme.font
                    ? root.theme.font
                    : "JetBrainsMono Nerd Font Propo"


                pixelSize: 16

                weight: theme.fontWeight
            }



            width:
                Math.min(
                    implicitWidth,
                    180
                )


            elide:
                Text.ElideRight
        }
    }



    // ============================================================
    // MOUSE CONTROLS
    // ============================================================
    MouseArea {

        id: interactionZone


        anchors.fill:
            parent


        hoverEnabled: true


        cursorShape:
            Qt.PointingHandCursor


        acceptedButtons:
            Qt.LeftButton |
            Qt.RightButton



        onClicked: function(mouse) {

    if (mouse.button === Qt.RightButton) {

        if (!root.spotifyControl) {
            return
        }

        root.spotifyControl.command = [
            "sh",
            "-c",
            "playerctl --player=spotify play-pause"
        ]

        root.spotifyControl.running = true
    }

    if (mouse.button === Qt.LeftButton)
        root.clicked()
}


        onWheel: function(event) {


            if (!root.spotifyControl)
                return



            root.spotifyControl.command =
            [
                "sh",
                "-c",

                event.angleDelta.y > 0
                ?
                "playerctl --player=spotify next"
                :
                "playerctl --player=spotify previous"
            ]



            root.spotifyControl.running = true
        }
    }
}