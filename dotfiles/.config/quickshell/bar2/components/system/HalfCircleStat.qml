// components/system/HalfCircleStat.qml
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property var theme
    property string icon: ""
    property string value: ""
    property color accent: theme.accent
    property real progress: 0
    property bool show: true
    property real ringSize: 64   // NEW: drives every other dimension below

    width: ringSize + 8
    height: ringSize * 0.625 + 28   // preserves the original 68/64 ratio
    visible: show

    Shape {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.ringSize
        height: root.ringSize * 0.625
        preferredRendererType: Shape.CurveRenderer
        antialiasing: true

        ShapePath {
            strokeWidth: root.ringSize / 12.8   // preserves original 5/64 ratio
            strokeColor: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.ringSize / 2
                centerY: root.ringSize / 2
                radiusX: root.ringSize * 0.40625   // preserves original 26/64 ratio
                radiusY: root.ringSize * 0.40625
                startAngle: 160
                sweepAngle: 220
            }
        }
    }

    Shape {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.ringSize
        height: root.ringSize * 0.625
        preferredRendererType: Shape.CurveRenderer
        antialiasing: true

        ShapePath {
            strokeWidth: root.ringSize / 12.8
            strokeColor: root.accent
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.ringSize / 2
                centerY: root.ringSize / 2
                radiusX: root.ringSize * 0.40625
                radiusY: root.ringSize * 0.40625
                startAngle: 160
                sweepAngle: Math.min(Math.max(root.progress, 0), 1) * 220

                Behavior on sweepAngle {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.ringSize * 0.3125   // preserves original 20/64 ratio
        spacing: -1

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.value
            color: theme.fg
            font {
                family: theme.font
                pixelSize: root.ringSize * 0.203   // preserves original 13/64 ratio
                weight: Font.Medium
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.icon
            color: root.accent
            font {
                family: theme.font
                pixelSize: root.ringSize * 0.203
            }
        }
    }
}