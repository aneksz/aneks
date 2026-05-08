// components/Ram.qml
import QtQuick

Item {
    id: root
    required property string ramUsage
    required property string ramTotal
    required property var theme

    // --- Values ---
    function toNumber(val) {
        if (!val) return 0
        return parseFloat(val)
    }

    property real used: toNumber(ramUsage)
    property real total: toNumber(ramTotal)
    property real progress: total > 0 ? Math.min(used / total, 1) : 0

    // --- Smooth animation ---
    property real animatedProgress: progress
    Behavior on animatedProgress {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    // --- Color (identity + state) ---
    property color baseColor: theme.accent
    property color ringColor: {
        if (progress > 0.85) return theme.error
        if (progress > 0.65) return theme.warning
        return baseColor
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

                    // background ring
                    ctx.beginPath()
                    ctx.arc(center, center, radius, 0, 2 * Math.PI)
                    ctx.strokeStyle = Qt.lighter(theme.surface, 1.4)
                    ctx.stroke()

                    // progress ring
                    ctx.beginPath()
                    ctx.arc(center, center, radius,
                            -Math.PI / 2,
                            -Math.PI / 2 + (2 * Math.PI * p))
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

            // icon
            Text {
                anchors.centerIn: parent
                text: ""
                color: root.ringColor
                font.family: theme.font
                font.pointSize: theme.fontSize - 3
            }
        }

        // value
        Text {
            text: ramUsage
            color: root.ringColor
            font.family: theme.font
            font.pointSize: theme.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}