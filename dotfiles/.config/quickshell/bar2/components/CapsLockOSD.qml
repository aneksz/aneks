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
    signal osdClosing()

    // ============================================================
    // STATE
    // ============================================================

    property bool active: false
    property bool closing: false
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
            root.isOn = !root.isOn

            root.active = true
            root.closing = false

            root.osdTriggered()

            progressTimer.restart()
        }
    }

    // ============================================================
    // DISPLAY TIME
    // ============================================================

    Timer {
        id: progressTimer

        interval: 1800
        repeat: false

        onTriggered: {
            root.closing = true
            closeDelay.start()
        }
    }

    // ============================================================
    // FADE CONTENT BEFORE CLOSING
    // ============================================================

    Timer {
        id: closeDelay

        interval: 180
        repeat: false

        onTriggered: {

           root.osdClosing()
           closeDelay.start()
        }
    }
    
    // ============================================================
    // OSD CARD
    // ============================================================

    Rectangle {
        id: mainRect

        anchors.fill: parent

        radius: 16
        antialiasing: true

        color: "transparent"

        opacity: root.active ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        // ========================================================
        // CONTENT
        // ========================================================

        Row {
            id: contentRow

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 18

            spacing: 10

            opacity: root.closing ? 0.0 : 1.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            // ====================================================
            // ICON
            // ====================================================

            Item {
                width: 28
                height: 28

                Text {
                    anchors.centerIn: parent

                    text: "󰪛"

                    color: root.isOn
                           ? root.theme.accent
                           : root.theme.inactive

                    opacity: root.isOn
                             ? 1.0
                             : 0.35

                    font {
                        family: root.theme.font
                        pixelSize: 22
                    }

                    Behavior on color {
                        ColorAnimation { duration: 140 }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 140 }
                    }
                }
            }

            // ====================================================
            // TEXT
            // ====================================================

            Column {
                anchors.verticalCenter: parent.verticalCenter

                spacing: 2

                Text {
                    text: "Caps Lock"

                    color: root.theme.fg1

                    font {
                        family: root.theme.font
                        pixelSize: 12
                        bold: true
                    }
                }

                Text {
                    text: root.isOn ? "ON" : "OFF"

                    color: root.isOn
                           ? root.theme.accent
                           : root.theme.inactive

                    font {
                        family: root.theme.font
                        pixelSize: 10
                    }

                    Behavior on color {
                        ColorAnimation { duration: 140 }
                    }
                }
            }
        }
    }
}