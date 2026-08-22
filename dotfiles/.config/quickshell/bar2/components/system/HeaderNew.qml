// components/system/Header.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: root

    width: parent ? parent.width : 0
    height: 72
    implicitHeight: 72

    property var theme
    required property var globalClock
    property string systemUptime: ""
    property string username: ""
    property string hostname: ""

    Process {
        id: commandRunner
    }

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

    // ============================================================
    // CARD BACKGROUND
    // ============================================================

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: theme.bgAlt
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12

            // ====================================================
            // LEFT – Avatar + User info
            // ====================================================

            Row {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                // Avatar
                Item {
                    width: 50
                    height: 50

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
                        border.width: 2
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
                            pixelSize: 14
                            weight: Font.Bold
                        }
                    }

                    Text {
                        text: "Uptime: " + root.systemUptime
                        color: theme.inactive
                        font {
                            family: theme.font
                            pixelSize: 11
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // ====================================================
            // RIGHT – Power buttons
            // ====================================================

            Row {
                spacing: 8
                Layout.alignment: Qt.AlignVCenter

                component CircularButton: MouseArea {
                    id: btn
                    width: 36
                    height: 36
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
                                      : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.15)

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: btn.icon
                        color: btn.containsMouse ? btn.accent : theme.inactive
                        font {
                            family: theme.font
                            pixelSize: 15
                        }
                        Behavior on color { ColorAnimation { duration: 120 } }
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

                // Reboot
                CircularButton {
                    icon: ""
                    accent: theme.warning
                    onClicked: {
                        commandRunner.command = ["systemctl", "reboot"]
                        commandRunner.running = true
                    }
                }

                // Logout
                CircularButton {
                    icon: "󰍃"
                    accent: theme.accent
                    onClicked: {
                        commandRunner.command = ["hyprctl", "dispatch", "hl.dsp.exit()"]
                        commandRunner.running = true
                    }
                }

                

                
            }
        }
    }
}