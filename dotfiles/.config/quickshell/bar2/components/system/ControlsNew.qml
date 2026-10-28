// components/system/Header.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: root

    width: parent ? parent.width : 0
    height: 64

    property var theme
    required property var globalClock
    property string systemUptime: ""
    property string username: ""
    property string hostname: ""

    Process {
        id: commandRunner
    }

    // Get username & hostname
    Process {
        command: ["whoami"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.username = text.trim()
        }
    }

    Process {
        command: ["hostname"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.hostname = text.trim()
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        spacing: 12

        // ========================================================
        // LEFT SIDE – Avatar + User info
        // ========================================================

        Row {
            spacing: 12
            Layout.alignment: Qt.AlignVCenter

            // Avatar
            Item {
                width: 48
                height: 48

                Rectangle {
                    id: avatarMask
                    anchors.fill: parent
                    radius: width / 2
                    visible: false
                }

                Image {
                    id: avatarImage
                    anchors.fill: parent
                    source: "file:///home/igor/.config/quickshell/avatar1.png"
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                    asynchronous: true
                }

                OpacityMask {
                    anchors.fill: parent
                    source: avatarImage
                    maskSource: avatarMask
                }

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.width: 1.5
                    border.color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.35)
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: root.username + "@" + root.hostname
                    color: theme.accent
                    font {
                        family: theme.font
                        pixelSize: theme.fontSize + 2
                        weight: Font.DemiBold
                    }
                }

                Text {
                    text: "Uptime: " + root.systemUptime
                    color: theme.inactive
                    font {
                        family: theme.font
                        pixelSize: theme.fontSize - 1
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // ========================================================
        // RIGHT SIDE – Power buttons (circular)
        // ========================================================

        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            component CircularButton: MouseArea {
                id: btn
                width: 38
                height: 38
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                property string icon
                property color accent: theme.accent

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: btn.containsMouse
                           ? Qt.rgba(btn.accent.r, btn.accent.g, btn.accent.b, 0.15)
                           : "transparent"
                    border.width: 1.5
                    border.color: btn.containsMouse
                                  ? btn.accent
                                  : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.18)

                    Behavior on color { ColorAnimation { duration: 130 } }
                    Behavior on border.color { ColorAnimation { duration: 130 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: btn.icon
                    color: btn.containsMouse ? btn.accent : theme.inactive
                    font {
                        family: theme.font
                        pixelSize: 16
                    }
                    Behavior on color { ColorAnimation { duration: 130 } }
                }
            }

            // Logout / Exit Hyprland
            CircularButton {
                icon: "󰍃"
                accent: theme.accent
                onClicked: {
                    commandRunner.command = ["hyprctl", "dispatch", "exit"]
                    commandRunner.running = true
                }
            }

            // Reboot
            CircularButton {
                icon: "󰜉"
                accent: theme.warning
                onClicked: {
                    commandRunner.command = ["systemctl", "reboot"]
                    commandRunner.running = true
                }
            }

            // Shutdown
            CircularButton {
                icon: "󰐥"
                accent: theme.error
                onClicked: {
                    commandRunner.command = ["systemctl", "poweroff"]
                    commandRunner.running = true
                }
            }
        }
    }
}