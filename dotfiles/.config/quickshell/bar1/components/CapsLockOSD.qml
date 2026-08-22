import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var theme

    // Keep alive while animating out
    visible: active || fadeAnim.running || slideAnim.running

    property bool active: false
    property string state: "OFF"
    property bool isOn: false

    onStateChanged: {
        isOn = state === "ON"
    }

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "notifications"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 50
        right: 10
    }

    implicitWidth: 210
    implicitHeight: 54

    color: "transparent"

    // ================= IPC =================
    IpcHandler {
    target: "caps_osd"

    function toggle() {
        root.isOn = !root.isOn
        root.state = root.isOn ? "ON" : "OFF"
        root.active = true

        hideTimer.restart()
    }
}
    // ================= AUTO HIDE =================
    Timer {
        id: hideTimer

        interval: 1200

        onTriggered: {
            root.active = false
        }
    }

    // ================= MAIN CARD =================
    Rectangle {
        id: mainRect

        anchors.fill: parent

        antialiasing: true

        color: theme.surface
        radius: 14

        border {
            width: 1

            color: root.isOn
                ? theme.accent
                : theme.inactive
        }

        // ================= ANIMATION =================
        opacity: root.active ? 1 : 0

        transform: Translate {
            x: root.active ? 0 : 50

            Behavior on x {
                NumberAnimation {
                    id: slideAnim

                    duration: 420
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                id: fadeAnim

                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        // ================= CONTENT =================
        Row {
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: 18

    spacing: 10

            // ================= ICON =================
            Item {
                width: 28
                height: 28

                Text {
                    anchors.centerIn: parent

                    text: "󰪛"

                    font {
                        family: theme.font
                        pixelSize: 22
                    }

                    color: root.isOn
                        ? theme.accent
                        : theme.inactive

                    opacity: root.isOn ? 1.0 : 0.35

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 140
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                        }
                    }
                }
            }

            // ================= TEXT =================
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "Caps Lock"

                    color: theme.fg1

                    font {
                        family: theme.font
                        pixelSize: 12
                        bold: true
                    }
                }

                Text {
                    text: root.isOn ? "ON" : "OFF"

                    color: root.isOn
                        ? theme.accent
                        : theme.inactive

                    font {
                        family: theme.font
                        pixelSize: 10
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                        }
                    }
                }
            }
        }
    }
}