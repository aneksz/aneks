// components/Cpu.qml
import QtQuick

Item {
    id: root
    required property string temp
    required property var theme

    // --- Values ---
    property real tempValue: parseFloat(temp) || 0
    property real progress: Math.min(tempValue / 100, 1)

    // --- Smooth animation ---
    property real animatedProgress: progress
    Behavior on animatedProgress {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    // --- Color (identity + state) ---
    property color baseColor: theme.warning
    property color ringColor: {
        if (tempValue > 80) return theme.error
        if (tempValue > 60) return baseColor
        return Qt.lighter(baseColor, 1.2)
    }

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        // --- Ring ---
        Item {
            width: 26
            height: 26

            Canvas {
                id: canvas
                anchors.fill: parent

                property real p: root.animatedProgress
                property color c: root.ringColor

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()

                    const center = width / 2
                    const radius = width / 2 - 2

                    // background ring
                    ctx.beginPath()
                    ctx.arc(center, center, radius, 0, 2 * Math.PI)
                    ctx.strokeStyle = Qt.lighter(theme.surface, 1.4)
                    ctx.lineWidth = 3
                    ctx.stroke()

                    // progress ring
                    ctx.beginPath()
                    ctx.arc(center, center, radius,
                            -Math.PI / 2,
                            -Math.PI / 2 + (2 * Math.PI * p))
                    ctx.strokeStyle = c
                    ctx.lineWidth = 3
                    ctx.lineCap = "round"
                    ctx.stroke()
                }

                onPChanged: requestPaint()
                onCChanged: requestPaint()
            }

            // icon
            Text {
                anchors.centerIn: parent
                text: ""
                color: root.ringColor
                font.family: theme.font
                font.pointSize: theme.fontSize - 2
            }
        }

        // value
        Text {
            text: temp
            color: root.ringColor
            font.family: theme.font
            font.pointSize: theme.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}