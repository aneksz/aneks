// components/CapsLockOSD.qml

import QtQuick
import Quickshell
import Quickshell.Io

Item {
id: root


// ============================================================
// API
// ============================================================

property var theme

signal osdTriggered()


// ============================================================
// STATE
// ============================================================

property bool active: false
property bool isOn: false


// ============================================================
// SIZE
// ============================================================

anchors.fill: parent


// ============================================================
// IPC
// ============================================================

IpcHandler {
    target: "caps_osd"

    function toggle() {

        root.isOn =
            !root.isOn

        root.active =
            true


        root.osdTriggered()

        hideTimer.restart()
    }
}


// ============================================================
// AUTO HIDE
// ============================================================

Timer {
    id: hideTimer

    interval:
        1200

    repeat:
        false

    onTriggered: {

        root.active =
            false
    }
}


// ============================================================
// OSD CARD
// ============================================================

Rectangle {
    id: mainRect

    anchors.fill:
        parent

    radius:
        14

    antialiasing:
        true

    color:
        root.theme.surface

    border {
        width:
            1

        color:
            root.isOn
            ? root.theme.accent
            : root.theme.inactive
    }


    // ========================================================
    // ANIMATION
    // ========================================================

    opacity:
        root.active
        ? 1.0
        : 0.0

    transform:
        Translate {

            x:
                root.active
                ? 0
                : 50

            Behavior on x {

                NumberAnimation {

                    duration:
                        420

                    easing.type:
                        Easing.OutCubic
                }
            }
        }

    Behavior on opacity {

        NumberAnimation {

            duration:
                300

            easing.type:
                Easing.OutCubic
        }
    }


    // ========================================================
    // CONTENT
    // ========================================================

    Row {

        anchors.verticalCenter:
            parent.verticalCenter

        anchors.left:
            parent.left

        anchors.leftMargin:
            18

        spacing:
            10


        // ====================================================
        // ICON
        // ====================================================

        Item {

            width:
                28

            height:
                28


            Text {

                anchors.centerIn:
                    parent

                text:
                    "󰪛"

                color:
                    root.isOn
                    ? root.theme.accent
                    : root.theme.inactive

                opacity:
                    root.isOn
                    ? 1.0
                    : 0.35

                font {

                    family:
                        root.theme.font

                    pixelSize:
                        22
                }

                Behavior on color {

                    ColorAnimation {

                        duration:
                            140
                    }
                }

                Behavior on opacity {

                    NumberAnimation {

                        duration:
                            140
                    }
                }
            }
        }


        // ====================================================
        // TEXT
        // ====================================================

        Column {

            anchors.verticalCenter:
                parent.verticalCenter

            spacing:
                2


            Text {

                text:
                    "Caps Lock"

                color:
                    root.theme.fg1

                font {

                    family:
                        root.theme.font

                    pixelSize:
                        12

                    bold:
                        true
                }
            }


            Text {

                text:
                    root.isOn
                    ? "ON"
                    : "OFF"

                color:
                    root.isOn
                    ? root.theme.accent
                    : root.theme.inactive

                font {

                    family:
                        root.theme.font

                    pixelSize:
                        10
                }

                Behavior on color {

                    ColorAnimation {

                        duration:
                            140
                    }
                }
            }
        }
    }
  }

}
