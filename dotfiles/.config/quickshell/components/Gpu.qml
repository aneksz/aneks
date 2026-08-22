// components/Gpu.qml
import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property string temp
    required property var theme
    property string usage: "--"
    property string memory: "--"
    property string clock: "--"

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
    property color baseColor: theme.error

    property color ringColor: {
        if (tempValue > 85)
            return baseColor

        if (tempValue > 65)
            return theme.warning

        return Qt.lighter(baseColor, 1.4)
    }

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // ================= MAIN MODULE =================
    Row {
        id: row

        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        // ================= RING =================
        Item {
            width: 26
            height: 26

            Canvas {
                id: canvas

                anchors.fill: parent

                antialiasing: true

                property real p: root.animatedProgress
                property color c: root.ringColor

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()

                    const center = width / 2
                    const radius = width / 2 - 2

                    // Background ring
                    ctx.beginPath()
                    ctx.arc(center, center, radius, 0, 2 * Math.PI)

                    ctx.strokeStyle = Qt.lighter(theme.surface, 1.4)
                    ctx.lineWidth = 3
                    ctx.stroke()

                    // Progress ring
                    ctx.beginPath()
                    ctx.arc(
                        center,
                        center,
                        radius,
                        -Math.PI / 2,
                        -Math.PI / 2 + (2 * Math.PI * p)
                    )

                    ctx.strokeStyle = c
                    ctx.lineWidth = 3
                    ctx.lineCap = "round"
                    ctx.stroke()
                }

                onPChanged: requestPaint()
                onCChanged: requestPaint()
            }

            // ================= ICON =================
            Text {
                anchors.centerIn: parent

                text: ""

                color: root.ringColor

                font {
                    family: theme.font
                    pointSize: theme.fontSize - 1
                }
            }
        }

        // ================= TEMP VALUE =================
        Text {
            text: temp

            color: root.ringColor

            font {
                family: theme.font
                pointSize: theme.fontSize
            }

            anchors.verticalCenter: parent.verticalCenter
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
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom

        anchor.margins {
            top: 38
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
                    text: " GPU Temperature"

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

    Row {
        spacing: 50

        Text {
            text: "Temperature"
            color: theme.inactive
            width: 90
        }

        Text {
            text: temp
            color: theme.fg1
        }
    }

    Row {
        spacing: 50

        Text {
            text: "Usage"
            color: theme.inactive
            width: 90
        }

        Text {
            text: usage
            color: theme.fg1
        }
    }

    Row {
        spacing: 50

        Text {
            text: "VRAM"
            color: theme.inactive
            width: 90
        }

        Text {
            text: memory
            color: theme.fg1
        }
    }

    Row {
        spacing: 50

        Text {
            text: "Clock"
            color: theme.inactive
            width: 90
        }

        Text {
            text: clock
            color: theme.fg1
        }
    }

    Row {
        spacing: 50

        Text {
            text: "Status"
            color: theme.inactive
            width: 90
        }

        Text {
            text: tempValue > 85
                ? "Hot"
                : tempValue > 65
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