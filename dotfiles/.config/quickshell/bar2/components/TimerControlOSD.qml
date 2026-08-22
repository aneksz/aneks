import QtQuick

Item {
    id: root

    // ============================================================
    // API
    // ============================================================

    property var theme

    property int remainingSeconds: 0
    property bool running: false

    signal pauseRequested()
    signal resumeRequested()
    signal dismissRequested()
    signal cancelRequested()

    // ============================================================
    // SIZE
    // ============================================================

    implicitWidth: 300
    implicitHeight: 70

    width: implicitWidth
    height: implicitHeight

    // ============================================================
    // TIME FORMAT
    // ============================================================

    function formatTime(seconds) {
        var minutes = Math.floor(seconds / 60)
        var secs = seconds % 60

        return minutes.toString().padStart(2, "0")
             + ":"
             + secs.toString().padStart(2, "0")
    }

    // ============================================================
    // CARD
    // ============================================================

    Rectangle {
        anchors.fill: parent

        radius: 16
        antialiasing: true

        color: root.theme.bg

        // ========================================================
        // MAIN CONTENT
        // ========================================================

        Row {
            anchors.centerIn: parent

            spacing: 12

            // ====================================================
            // TIMER ICON
            // ====================================================

            Item {
                width: 34
                height: 34

                Text {
                    anchors.centerIn: parent

                    text:
                        root.running
                            ? "󱎫"
                            : "󱫞"

                    color:
                        root.remainingSeconds > 0 &&
                        root.remainingSeconds <= 10
                            ? root.theme.error
                            : root.theme.accent

                    font {
                        family: root.theme.font
                        pixelSize: 26
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                        }
                    }
                }
            }

            // ====================================================
            // REMAINING TIME
            // ====================================================

            Column {
                anchors.verticalCenter: parent.verticalCenter

                spacing: 2

                Text {
                    text:
                        root.formatTime(
                            root.remainingSeconds
                        )

                    color:
                        root.remainingSeconds > 0 &&
                        root.remainingSeconds <= 10
                            ? root.theme.error
                            : root.theme.fg1

                    font {
                        family: root.theme.font
                        pixelSize: 16
                        bold: true
                    }
                }

                Text {
                    text:
                        root.running
                            ? "Running"
                            : "Paused"

                    color:
                        root.running
                            ? root.theme.accent
                            : root.theme.inactive

                    font {
                        family: root.theme.font
                        pixelSize: 10
                    }
                }
            }

            // ====================================================
            // PLAY / PAUSE
            // ====================================================

            Item {
                width: 34
                height: 34

                Text {
                    anchors.centerIn: parent

                    text:
                        root.running
                            ? "󰏥"
                            : "󰐌"

                    color: root.theme.fg1

                    font {
                        family: root.theme.font
                        pixelSize: 26
                    }

                    scale:
                        pauseMouse.containsMouse
                            ? 1.1
                            : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }

                MouseArea {
                    id: pauseMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (root.running)
                            root.pauseRequested()
                        else
                            root.resumeRequested()
                    }
                }
            }

            // ====================================================
            // DISMISS OSD
            // ====================================================

            Item {
                width: 34
                height: 34

                Text {
                    anchors.centerIn: parent

                    text: "󰅙"

                    color: root.theme.inactive

                    font {
                        family: root.theme.font
                        pixelSize: 26
                    }

                    scale:
                        dismissMouse.containsMouse
                            ? 1.1
                            : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }

                MouseArea {
                    id: dismissMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked:
                        root.dismissRequested()
                }
            }

            // ====================================================
            // CANCEL TIMER
            // ====================================================

            Item {
                width: 34
                height: 34

                Text {
                    anchors.centerIn: parent

                    text: ""

                    color: root.theme.error

                    font {
                        family: root.theme.font
                        pixelSize: 24
                    }

                    scale:
                        cancelMouse.containsMouse
                            ? 1.1
                            : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }

                MouseArea {
                    id: cancelMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked:
                        root.cancelRequested()
                }
            }
        }
    }
}