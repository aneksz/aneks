import QtQuick
import QtQuick.Controls

FocusScope {
    id: root

    // ============================================================
    // API
    // ============================================================

    property var theme

    property int selectedSeconds: 300

    signal startRequested(int seconds)
    signal dismissRequested()

    // ============================================================
    // SIZE
    // ============================================================

    implicitWidth: 300
    implicitHeight: 70

    width: implicitWidth
    height: implicitHeight

    focus: true

    // ============================================================
    // TIME FUNCTIONS
    // ============================================================

    function formatTime(seconds) {
        var minutes = Math.floor(seconds / 60)
        var secs = seconds % 60

        return minutes.toString().padStart(2, "0")
             + ":"
             + secs.toString().padStart(2, "0")
    }

    function parseTime(value) {
        var parts = value.split(":")

        if (parts.length !== 2)
            return 0

        var minutes = parseInt(parts[0])
        var seconds = parseInt(parts[1])

        if (isNaN(minutes) || isNaN(seconds))
            return 0

        if (minutes < 0 || seconds < 0 || seconds > 59)
            return 0

        return (minutes * 60) + seconds
    }

    function commitTime() {
        var value = parseTime(timeInput.text)

        if (value > 0)
            selectedSeconds = value

        timeInput.text = formatTime(selectedSeconds)
    }

    // ============================================================
    // CARD
    // ============================================================

    Rectangle {
        id: mainRect

        anchors.fill: parent

        radius: 16
        antialiasing: true

        color: root.theme.bg

        // ========================================================
        // CONTENT
        // ========================================================

        Row {
            id: contentRow

            anchors.centerIn: parent

            spacing: 10

            // ====================================================
            // TIMER ICON
            // ====================================================

            Item {
                width: 34
                height: 34

                Text {
                    anchors.centerIn: parent

                    text: "󱫠"

                    color: root.theme.accent

                    font {
                        family: root.theme.font
                        pixelSize: 26
                    }
                }
            }

            // ====================================================
            // TIME INPUT
            // ====================================================

            TextField {
                id: timeInput

                width: 90
                height: 36

                focus: true
                activeFocusOnTab: true

                text: root.formatTime(root.selectedSeconds)

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                selectByMouse: true

                color: root.theme.fg1
                selectionColor: root.theme.accent

                font {
                    family: root.theme.font
                    pixelSize: 18
                    weight: root.theme.fontWeight
                }

                background: Rectangle {
                    radius: 10

                    color:
                        timeInput.activeFocus
                            ? root.theme.surfaceAlt
                            : "transparent"

                    border.width:
                        timeInput.activeFocus
                            ? 1
                            : 0

                    border.color: root.theme.accent
                }

                onAccepted: {
                    root.commitTime()
                }

                onEditingFinished: {
                    root.commitTime()
                }
            }

            // ====================================================
            // START
            // ====================================================

            Item {
                id: startButton

                width: 34
                height: 34

                Text {
                    anchors.centerIn: parent

                    text: "󰐌"

                    color: root.theme.accent

                    font {
                        family: root.theme.font
                        pixelSize: 26
                    }

                    scale:
                        startMouse.containsMouse
                            ? 1.1
                            : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }

                MouseArea {
                    id: startMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.commitTime()

                        if (root.selectedSeconds > 0)
                            root.startRequested(
                                root.selectedSeconds
                            )
                    }
                }
            }

            // ====================================================
            // CANCEL
            // ====================================================

            Item {
                id: cancelButton

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

                    onClicked: {
                        root.dismissRequested()
                    }
                }
            }
        }
    }

    // ============================================================
    // INITIAL FOCUS
    // ============================================================

    Component.onCompleted: {
        Qt.callLater(function() {
            timeInput.forceActiveFocus()
            timeInput.selectAll()
        })
    }
}