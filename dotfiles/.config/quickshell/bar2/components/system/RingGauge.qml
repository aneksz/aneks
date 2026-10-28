// components/system/RingGauge.qml
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // ============================================================
    // EXTERNAL API
    // ============================================================

    property var theme
    property real value: 0          // 0-100
    property string icon: ""
    property color ringColor: theme ? theme.accent : "#88c0d0"
    property real ringWidth: 5
    property int size: 64

    width: size
    height: size

    // ============================================================
    // BACKGROUND TRACK (full, dim circle)
    // ============================================================

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeWidth: root.ringWidth
            strokeColor: theme ? theme.inactive : "#4c566a"
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.size / 2
                centerY: root.size / 2
                radiusX: (root.size - root.ringWidth) / 2
                radiusY: (root.size - root.ringWidth) / 2
                startAngle: 0
                sweepAngle: 359.999   // full circle; 360 exactly can render oddly
            }
        }
    }

    // ============================================================
    // PROGRESS ARC
    // ============================================================

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            id: progressPath
            strokeWidth: root.ringWidth
            strokeColor: root.ringColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.size / 2
                centerY: root.size / 2
                radiusX: (root.size - root.ringWidth) / 2
                radiusY: (root.size - root.ringWidth) / 2
                startAngle: -90   // start at 12 o'clock
                sweepAngle: (Math.max(0, Math.min(100, root.value)) / 100) * 360

                Behavior on sweepAngle {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    // ============================================================
    // CENTERED ICON
    // ============================================================

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.ringColor
        font {
            family: theme ? theme.font : "sans-serif"
            pixelSize: root.size * 0.32
        }
    }
}
