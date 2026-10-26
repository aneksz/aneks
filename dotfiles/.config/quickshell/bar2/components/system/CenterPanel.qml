// components/system/CenterPanel.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property var theme
    required property var globalClock

    Process { id: commandRunner }

    // ============================================================
    // CARD BACKGROUND
    // ============================================================

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: theme.bgAlt
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        Column {
            anchors.centerIn: parent
            spacing: 40

        // ====================================================
       // CLOCK
      // ====================================================

Row {
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 2

    Text {
        text: Qt.formatTime(root.globalClock.date, "hh")
        color: theme.accent
        font {
            family: theme.font
            pixelSize: 76
            weight: Font.Bold
        }
    }

    Text {
        text: ":"
        color: theme.inactive
        font {
            family: theme.font
            pixelSize: 76
            weight: Font.Bold
        }
    }

    Text {
        text: Qt.formatTime(root.globalClock.date, "mm")
        color: theme.fg
        font {
            family: theme.font
            pixelSize: 76
            weight: Font.Bold
        }
    }

    
}

            // ====================================================
            // DATE
            // ====================================================

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(root.globalClock.date, "dddd, d MMMM yyyy")
                color: theme.accent
                font {
                    family: theme.font
                    pixelSize: 14
                }
            }

            // ====================================================
            // AVATAR
            // ====================================================

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 160
                height: 160

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
                    border.color: theme.accent
                }
            }

            // ====================================================
            // POWER BUTTONS
            // ====================================================

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 28

                component CircularButton: MouseArea {
                    id: btn
                    width: 42
                    height: 42
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    property string icon
                    property color accent: theme.accent

                    scale: btn.containsMouse ? 1.08 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }

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
                        color: btn.containsMouse ? btn.accent : theme.fg1
                        font {
                            family: theme.font
                            pixelSize: 18
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
                        commandRunner.command = ["hyprctl", "dispatch", "hl.dispatch(hl.dsp.exit())"]
                        commandRunner.running = true
                    }
                }
            }
        }
    }
}
