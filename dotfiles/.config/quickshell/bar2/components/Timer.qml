// components/Timer.qml
import QtQuick
import QtQuick.Controls

Item {
    id: root

    // ============================================================
    // SIZE
    // ============================================================

    width: 90
    height: 30

    implicitWidth: 70
    implicitHeight: 30

    // ============================================================
    // PUBLIC API
    // ============================================================

    property var theme

    property bool running: false
    property bool finished: false
    property bool hovered: timerButton.containsMouse
    property int remainingSeconds: 0

    signal clicked()
    signal adjustRequested(int seconds)
    signal dismissRequested()

    // ============================================================
    // DISPLAY STATE
    // ============================================================

    readonly property bool warning:
        remainingSeconds > 0 &&
        remainingSeconds <= 10

    readonly property string displayTime:
        formatTime(remainingSeconds)

    // ============================================================
    // TIME FORMAT
    // ============================================================

    function formatTime(seconds) {
        var minutes =
            Math.floor(seconds / 60)

        var secs =
            seconds % 60

        return minutes.toString().padStart(2, "0")
             + ":"
             + secs.toString().padStart(2, "0")
    }

    // ============================================================
    // MAIN TIMER INTERACTION
    // ============================================================

    MouseArea {
        id: timerButton

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        onClicked: {
            if (root.finished) {
                root.dismissRequested()
                return
            }

            root.clicked()
        }

        onWheel: function(event) {
            if (root.finished)
                return

            if (event.angleDelta.y > 0)
                root.adjustRequested(60)
            else
                root.adjustRequested(-60)
        }

        // --------------------------------------------------------
        // BACKGROUND
        // --------------------------------------------------------

        Rectangle {
            anchors.fill: parent

            radius: width / 2

            color:
                timerButton.containsMouse
                    ? root.theme.surfaceAlt
                    : "transparent"
        }

        // --------------------------------------------------------
        // CONTENT
        // --------------------------------------------------------

        Row {
            anchors.centerIn: parent

            spacing: 5

            Text {
                text:
                    root.finished
                        ? "󰂚"
                        : root.running
                            ? "󱎫"
                            : "󱫞"

                color:
                    root.finished
                        ? root.theme.error
                        : root.warning
                            ? root.theme.error
                            : root.theme.accent

                font {
                    family: root.theme.font
                    pixelSize: 16
                }

                scale:
                    timerButton.pressed
                        ? 0.9
                        : timerButton.containsMouse
                            ? 1.1
                            : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 120
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }

            Text {
                text:
                    root.finished
                        ? "Done"
                        : root.displayTime

                color:
                    root.finished
                        ? root.theme.error
                        : root.warning
                            ? root.theme.error
                            : root.theme.fg1

                font {
                    family: root.theme.font
                    pixelSize: 16
                    weight: root.theme.fontWeight
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }
        }
    }
}
