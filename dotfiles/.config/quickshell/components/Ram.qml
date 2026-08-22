// components/Ram.qml
import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property string ramUsage
    required property string ramTotal
    required property var theme
    property string ramAvailable: "--"
    property string ramCached: "--"
    property string ramSwap: "--"

    // ================= VALUES =================
    function toNumber(val) {
        if (!val)
            return 0

        return parseFloat(val)
    }

    property real used: toNumber(ramUsage)
    property real total: toNumber(ramTotal)

    property real progress: total > 0
        ? Math.min(used / total, 1)
        : 0

    // ================= ANIMATION =================
    property real animatedProgress: progress

    Behavior on animatedProgress {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    // ================= COLORS =================
    property color baseColor: theme.accent

    property color ringColor: {
        if (progress > 0.85)
            return theme.error

        if (progress > 0.65)
            return theme.warning

        return baseColor
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

                width: 54
                height: 54

                scale: 0.5

                anchors.centerIn: parent

                antialiasing: true

                property real p: root.animatedProgress
                property color c: root.ringColor

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()

                    const center = width / 2
                    const radius = width / 2 - 4

                    ctx.lineWidth = 6

                    // Background ring
                    ctx.beginPath()
                    ctx.arc(center, center, radius, 0, 2 * Math.PI)
                    ctx.strokeStyle = Qt.lighter(theme.surface, 1.4)
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
                    ctx.lineCap = "round"
                    ctx.stroke()
                }

                Component.onCompleted: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPChanged: requestPaint()
                onCChanged: requestPaint()
            }

            // ================= ICON =================
            Text {
                anchors.centerIn: parent

                text: ""

                color: root.ringColor

                font {
                    family: theme.font
                    pointSize: theme.fontSize - 3
                }
            }
        }

        // ================= VALUE =================
        Text {
            text: ramUsage

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
                    text: " Memory"

                    color: root.ringColor

                    font {
                        family: theme.font
                        pixelSize: 15
                        bold: true
                    }
                }

                // ================= USAGE BAR =================
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
            text: "Used"
            color: theme.inactive
            width: 90
        }

        Text {
            text: ramUsage + " GB"
            color: theme.fg1
        }
    }

    Row {
        spacing: 50

        Text {
            text: "Total"
            color: theme.inactive
            width: 90
        }

        Text {
            text: ramTotal + " GB"
            color: theme.fg1
        }
    }

    Row {
        spacing: 50

        Text {
            text: "Available"
            color: theme.inactive
            width: 90
        }

        Text {
            text: ramAvailable
            color: theme.fg1
        }
    }

    Row {
        spacing: 50

        Text {
            text: "Cached"
            color: theme.inactive
            width: 90
        }

        Text {
            text: ramCached
            color: theme.fg1
        }
    }

    Row {
        spacing: 50

        Text {
            text: "Swap"
            color: theme.inactive
            width: 90
        }

        Text {
            text: ramSwap
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
            text: Math.round(root.progress * 100) + "%"
            color: theme.fg1
        }
    }
  } 
}
        }
    }
}