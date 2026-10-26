// components/Cpu.qml
import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property string temp
    required property var theme
    property string usage: "--"
    property string frequency: "--"

    // ================= VALUES =================
    property real tempValue: parseFloat(temp) || 0

    property real progress: Math.min(tempValue / 100, 1)

    // ================= ANIMATION =================
    property real animatedProgress: progress

    Behavior on animatedProgress {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    // ================= COLORS =================
    property color baseColor: theme.warning

    property color ringColor: {
        if (tempValue > 80)
            return theme.error

        if (tempValue > 60)
            return baseColor

        return Qt.lighter(baseColor, 1.2)
    }

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    property bool hovered: mouseArea.containsMouse

    scale: hovered ? 1.03 : 1.0

    Behavior on scale {
    NumberAnimation {
        duration: 120
        easing.type: Easing.OutCubic
    }
}

   // ================= MAIN MODULE =================
Flow {
    id: row
    flow: theme.vertical ? Flow.TopToBottom : Flow.LeftToRight
    spacing: 6

    readonly property real maxTextWidth: Math.max(iconText.implicitWidth, valueText.implicitWidth)

    Item {
        width: row.maxTextWidth
        height: iconText.implicitHeight

        Text {
            id: iconText
            anchors.centerIn: parent
            text: ""

            color: hovered
                ? Qt.lighter(root.ringColor, 1.15)
                : root.ringColor

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            font {
                family: theme.font
                pointSize: theme.fontSize - 1
            }
        }
    }

    // ================= TEMP VALUE =================
    Item {
        width: row.maxTextWidth
        height: valueText.implicitHeight

        Text {
            id: valueText
            anchors.centerIn: parent
            text: temp

            color: hovered
                ? Qt.lighter(root.ringColor, 1.15)
                : root.ringColor

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            font {
                family: theme.font
                pointSize: theme.vertical ? theme.fontSize - 2 : theme.fontSize
            }
        }
    }
}
    // ================= HOVER =================
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
    }

    // ================= POPUP CARD =================
    PopupWindow {
        id: popup

        visible: mouseArea.containsMouse &&
                 root.Window.window !== null

        anchor.item: root
        anchor.edges: theme.vertical ? Edges.Right : Edges.Bottom
        anchor.gravity: theme.vertical ? Edges.Right : Edges.Bottom

        anchor.margins {
            top: theme.vertical ? 0 : 56
            left: theme.vertical ? 40 : 0
        }
        color: "transparent"

        implicitWidth: card.implicitWidth + 2
        implicitHeight: card.implicitHeight + 2

        Rectangle {
            id: card

            anchors.centerIn: parent

            antialiasing: true

            radius: 16
            color: theme.bg

            implicitWidth: content.implicitWidth + 28
            implicitHeight: content.implicitHeight + 26

            // ================= ANIMATION =================
            opacity: mouseArea.containsMouse ? 1 : 0
            scale: mouseArea.containsMouse ? 1 : 0.96

            transform: Translate {
                y: mouseArea.containsMouse ? 0 : -4
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            // ================= CONTENT =================
            Column {
                id: content

                anchors.centerIn: parent
                spacing: 10

                // ================= TITLE =================
                Text {
                    text: " CPU Temperature"

                    color: root.ringColor

                    font {
                        family: theme.font
                        pixelSize: 15
                        bold: true
                    }
                }

                // ================= TEMP BAR =================
                Rectangle {
                    width: 180
                    height: 6
                    radius: 3

                    color: Qt.rgba(1, 1, 1, 0.08)

                    Rectangle {
                        width: parent.width * root.progress
                        height: parent.height

                        radius: 3
                        color: root.ringColor
                    }
                }

                // ================= STATS =================
               Column {
    spacing: 6

    Flow {
        spacing: 50

        Text {
            text: "Temperature"
            color: theme.inactive
            width: 80
        }

        Text {
            text: temp
            color: theme.fg1
        }
    }

    Flow {
        spacing: 50

        Text {
            text: "Usage"
            color: theme.inactive
            width: 80
        }

        Text {
            text: usage
            color: theme.fg1
        }
    }

    Flow {
        spacing: 50

        Text {
            text: "Frequency"
            color: theme.inactive
            width: 80
        }

        Text {
            text: frequency
            color: theme.fg1
        }
    }

    Flow {
        spacing: 50

        Text {
            text: "Status"
            color: theme.inactive
            width: 80
        }

        Text {
            text: tempValue > 80
                ? "Hot"
                : tempValue > 60
                    ? "Warm"
                    : "Normal"

            color: theme.fg1
        }
    }
}
            }
        }
    }
}