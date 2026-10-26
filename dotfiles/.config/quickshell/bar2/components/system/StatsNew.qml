import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    id: root

    implicitWidth: parent ? parent.width : 0
    implicitHeight: 220
    width: parent ? parent.width : implicitWidth
    height: implicitHeight

    property var theme

    property string cpuTemp: ""
    property string gpuTemp: ""
    property string cpuUsage: ""
    property string ramUsage: ""
    property string ramTotal: ""

    function parseValue(str) {
    if (!str) return 0
    var pctMatch = String(str).match(/(\d+(?:\.\d+)?)%/)
    if (pctMatch) return parseFloat(pctMatch[1])
    var num = parseFloat(String(str).replace(/[^\d.]/g, ""))
    return isNaN(num) ? 0 : num
}

function parseSize(str) {
    if (!str) return 0
    var n = parseFloat(str)
    if (isNaN(n)) return 0
    if (str.includes("T")) return n * 1024 * 1024
    if (str.includes("G")) return n * 1024
    if (str.includes("M")) return n
    if (str.includes("K")) return n / 1024
    return n
}

readonly property real ramProgress: root.ramTotal
    ? parseSize(root.ramUsage) / parseSize(root.ramTotal)
    : 0


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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 16
        spacing: 16

            // Row 1: CPU Temp & CPU Usage
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 48

                HalfCircleStat {
                    theme: root.theme
                    icon: ""
                    value: root.cpuTemp || "—"
                    accent: theme.error
                    progress: parseValue(root.cpuTemp) / 100
                    ringSize: 96
                }

                HalfCircleStat {
                    theme: root.theme
                    icon: ""
                    value: root.cpuUsage || "—"
                    accent: theme.success
                    progress: parseValue(root.cpuUsage) / 100
                    ringSize: 96
                }
            }

            // Row 2: GPU Temp & RAM Usage
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 48

                HalfCircleStat {
                    theme: root.theme
                    icon: ""
                    value: root.gpuTemp || "—"
                    accent: theme.accent
                    progress: parseValue(root.gpuTemp) / 100
                    ringSize: 96
                }

                HalfCircleStat {
                   theme: root.theme
                   icon: ""
                   value: root.ramUsage || "—"
                   accent: theme.warning
                   progress: root.ramProgress
                   ringSize: 96
                }
            }
        }
    }
}
