// components/system/Header.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // ============================================================
    // SIZE
    // ============================================================

    width: parent ? parent.width : 0
    height: 52

    // ============================================================
    // PUBLIC API
    // ============================================================

    property var theme
    required property var globalClock

    property string systemUptime: ""
    property string username: ""
    property string hostname: ""

    // ============================================================
    // COMMAND RUNNER
    // ============================================================

    Process {
        id: commandRunner
    }

    // ============================================================
    // SYSTEM INFORMATION
    // ============================================================

    Process {
        command: ["whoami"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.username = text.trim()
            }
        }
    }

    Process {
        command: ["hostname"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.hostname = text.trim()
            }
        }
    }

    // ============================================================
    // MAIN CONTENT
    // ============================================================

    Row {
        id: content

        anchors.centerIn: parent

        spacing: 80

        // ========================================================
        // USER INFORMATION
        // ========================================================

        Row {
            id: userInfo

            spacing: 10

            anchors.verticalCenter: parent.verticalCenter

            // ----------------------------------------------------
            // AVATAR
            // ----------------------------------------------------

            Item {
                width: 60
                height: 60

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

                    border {
                        width: 1
                        color: root.theme.border
                    }
                }
            }

            // ----------------------------------------------------
            // USERNAME / UPTIME
            // ----------------------------------------------------

            Column {
                spacing: 0

                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: root.username + "@" + root.hostname

                    color: root.theme.accent

                    font {
                        family: root.theme.font
                        pixelSize: root.theme.fontSize + 1
                        bold: true
                    }
                }

                Text {
                    text: "Uptime: " + root.systemUptime

                    color: root.theme.inactive

                    font {
                        family: root.theme.font
                        pixelSize: root.theme.fontSize - 1
                    }
                }
            }
        }

        // ========================================================
        // QUICK SYSTEM ACTIONS
        // ========================================================

        Row {
            id: quickTriggers

            spacing: 4

            anchors.verticalCenter: parent.verticalCenter

            // ----------------------------------------------------
            // BLUETOOTH
            // ----------------------------------------------------

            MouseArea {
                width: 30
                height: 30

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Rectangle {
                    anchors.fill: parent

                    radius: width / 2

                    color: parent.containsMouse
                           ? root.theme.surfaceAlt
                           : "transparent"

                    border {
                        width: 1

                        color: parent.containsMouse
                               ? root.theme.accent
                               : "transparent"
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: ""

                    color: parent.containsMouse
                           ? root.theme.accent
                           : root.theme.textMuted

                    font {
                        family: root.theme.font
                        pixelSize: root.theme.fontSize + 2
                    }
                }

                onClicked: {
                    commandRunner.command = [
                        "kitty",
                        "-e",
                        "bluetui"
                    ]

                    commandRunner.running = true
                
                }
            }

            // ----------------------------------------------------
            // NIGHT LIGHT
            // ----------------------------------------------------

            MouseArea {
                id: nightLightButton

                width: 30
                height: 30

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                property bool enabled: false

                Rectangle {
                    anchors.fill: parent

                    radius: width / 2

                    color: nightLightButton.enabled
                           ? Qt.rgba(1, 0.8, 0, 0.12)
                           : (
                               parent.containsMouse
                               ? root.theme.surfaceAlt
                               : "transparent"
                           )

                    border {
                        width: 1

                        color: nightLightButton.enabled
                               ? root.theme.warning
                               : (
                                   parent.containsMouse
                                   ? root.theme.warning
                                   : "transparent"
                               )
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: nightLightButton.enabled
                          ? ""
                          : ""

                    color: nightLightButton.enabled
                           ? root.theme.warning
                           : (
                               parent.containsMouse
                               ? root.theme.warning
                               : root.theme.textMuted
                           )

                    font {
                        family: root.theme.font
                        pixelSize: root.theme.fontSize + 2
                    }
                }

                onClicked: {
                    nightLightButton.enabled =
                        !nightLightButton.enabled

                    commandRunner.command = [
                        "sh",
                        "-c",
                        nightLightButton.enabled
                        ? "hyprctl hyprsunset temperature 4000 && notify-send 'Night Light' 'On'"
                        : "hyprctl hyprsunset identity && notify-send 'Night Light' 'Off'"
                    ]

                    commandRunner.running = true
                }
            }

            // ----------------------------------------------------
            // VOLUME MIXER
            // ----------------------------------------------------

            MouseArea {
                width: 30
                height: 30

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Rectangle {
                    anchors.fill: parent

                    radius: width / 2

                    color: parent.containsMouse
                           ? root.theme.surfaceAlt
                           : "transparent"

                    border {
                        width: 1

                        color: parent.containsMouse
                               ? root.theme.accent
                               : "transparent"
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: ""

                    color: parent.containsMouse
                           ? root.theme.accent
                           : root.theme.textMuted

                    font {
                        family: root.theme.font
                        pixelSize: root.theme.fontSize + 2
                    }
                }

                onClicked: {
                    commandRunner.command = [
                        "kitty",
                        "-e",
                        "wiremix"
                    ]

                    commandRunner.running = true
                }
            }
        }
    }
}
