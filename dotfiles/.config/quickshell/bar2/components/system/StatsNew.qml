// components/system/Stats.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    id: root

    width: parent ? parent.width : 0
    height: 150
    implicitHeight: 150

    property var theme

    property string cpuTemp: ""
    property string gpuTemp: ""
    property string cpuUsage: ""
    property string ramUsage: ""
    property string keyboardBattery: ""
    property string mouseBattery: ""

    function parseValue(str) {
        if (!str) return 0
        var pctMatch = String(str).match(/(\d+(?:\.\d+)?)%/)
        if (pctMatch) return parseFloat(pctMatch[1])
        var num = parseFloat(String(str).replace(/[^\d.]/g, ""))
        return isNaN(num) ? 0 : num
    }

        // HALF-CIRCLE STAT
    // ============================================================

    component HalfCircleStat: Item {
        id: circle

        property string icon: ""
        property string value: ""
        property color accent: theme.accent
        property real progress: 0
        property bool show: true

        width: 72
        height: 68
        visible: show

        // Background half-circle track
        Shape {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: 64
            height: 40
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true

            ShapePath {
                strokeWidth: 5
                strokeColor: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: 32
                    centerY: 32
                    radiusX: 26
                    radiusY: 26
                    startAngle: 160        // left side
                    sweepAngle: 220          // half circle
                }
            }
        }

        // Progress half-circle
        Shape {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: 64
            height: 40
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true

            ShapePath {
                strokeWidth: 5
                strokeColor: circle.accent
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: 32
                    centerY: 32
                    radiusX: 26
                    radiusY: 26
                    startAngle: 160
                    sweepAngle: Math.min(Math.max(circle.progress, 0), 1) * 220
                }
            }
        }

        // Value + Icon centered inside the arc
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20 
            spacing: -1         

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: circle.value
                color: theme.fg
                font {
                    family: theme.font
                    pixelSize: 13
                    weight: Font.Medium
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: circle.icon
                color: circle.accent
                font {
                    family: theme.font
                    pixelSize: 13
                }
            }
        }
    }


    // ============================================================
    // MAIN CARD
    // ============================================================

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: theme.bgAlt
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        Column {
            anchors.centerIn: parent
            spacing: 12

            // Row 1
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                HalfCircleStat {
                    icon: ""
                    value: root.cpuTemp || "—"
                    accent: theme.error
                    progress: parseValue(root.cpuTemp) / 100
                }

                HalfCircleStat {
                    icon: "󰍛"
                    value: root.cpuUsage || "—"
                    accent: theme.success
                    progress: parseValue(root.cpuUsage) / 100
                }

                HalfCircleStat {
                    icon: ""
                    value: root.gpuTemp || "—"
                    accent: theme.accent
                    progress: parseValue(root.gpuTemp) / 100
                }

                
            }

            // Row 2
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                HalfCircleStat {
                    icon: ""
                    value: root.ramUsage || "—"
                    accent: theme.warning
                    progress: parseValue(root.ramUsage) / 100
                }

                HalfCircleStat {
                    show: root.keyboardBattery !== "" && root.keyboardBattery >= 0
                    icon: "󰌌"
                    value: root.keyboardBattery + "%"
                    accent: theme.fg
                    progress: parseValue(root.keyboardBattery) / 100
                }

                HalfCircleStat {
                    show: root.mouseBattery !== "" && root.mouseBattery >= 0
                    icon: "󰍽"
                    value: root.mouseBattery + "%"
                    accent: theme.fg
                    progress: parseValue(root.mouseBattery) / 100
                }
            }
        }
    }
}