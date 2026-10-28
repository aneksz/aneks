// components/system/Storage.qml
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    width: parent ? parent.width : 0
    implicitHeight: 140
    height: implicitHeight

    property var theme
    property string dataUsage: ""
    property string homeUsage: ""

    function usageProgress(usage) {
        if (!usage) return 0
        var parts = usage.split(" / ")
        if (parts.length < 2) return 0

        function toMB(val) {
            var n = parseFloat(val)
            if (isNaN(n)) return 0
            if (val.includes("T")) return n * 1024 * 1024
            if (val.includes("G")) return n * 1024
            if (val.includes("M")) return n
            return n
        }

        var used  = toMB(parts[0])
        var total = toMB(parts[1])
        if (!total) return 0
        return Math.min(used / total, 1)
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: theme.surface
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        Column {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: 14
                rightMargin: 14
            }
            spacing: 20

            // ====================================================
            // /home/igor
            // ====================================================
            Column {
                width: parent.width
                spacing: 5

                Text {
                    text: "/home/igor"
                    color: theme.fg
                    font {
                        family: theme.font
                        pixelSize: 12
                        weight: Font.Bold
                    }
                }

                // Progress bar
                Rectangle {
                    width: parent.width
                    height: 8
                    radius: 4
                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.10)

                    Rectangle {
                        height: parent.height
                        radius: 4
                        color: theme.success
                        width: parent.width * usageProgress(root.homeUsage)

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                    }
                }

                // Used / Total under the bar
                Text {
                    text: root.homeUsage || "—"
                    color: theme.fg0
                    font {
                        family: theme.font
                        pixelSize: 11
                    }
                }
            }

            // ====================================================
            // /mnt/data
            // ====================================================
            Column {
                width: parent.width
                spacing: 5

                Text {
                    text: "/mnt/data"
                    color: theme.fg
                    font {
                        family: theme.font
                        pixelSize: 12
                        weight: Font.Bold
                    }
                }

                // Progress bar
                Rectangle {
                    width: parent.width
                    height: 8
                    radius: 4
                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.10)

                    Rectangle {
                        height: parent.height
                        radius: 4
                        color: theme.accent
                        width: parent.width * usageProgress(root.dataUsage)

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                    }
                }

                // Used / Total under the bar
                Text {
                    text: root.dataUsage || "—"
                    color: theme.fg0
                    font {
                        family: theme.font
                        pixelSize: 11
                    }
                }
            }

            
        }
    }
}