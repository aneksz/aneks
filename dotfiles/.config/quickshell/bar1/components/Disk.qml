import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property var theme
    required property string icon
    required property string label

    required property string free
    required property string total

    signal clicked()

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // ================= HOVER =================
    property bool hovered: mouseArea.containsMouse

    scale: hovered ? 1.03 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    // ================= SAFE PARSING =================
    function safeNum(v) {
        var n = parseFloat(v)
        return isNaN(n) ? 0 : n
    }

    property real freeValue: safeNum(free)
    property real totalValue: safeNum(total)

    property real usedValue: Math.max(totalValue - freeValue, 0)

    property real usedPercent: totalValue > 0
        ? (usedValue / totalValue) * 100
        : 0

    property real progress: usedPercent / 100

    // ================= COLOR (FIXED) =================
    property color diskColor: {
        if (isNaN(usedPercent))
            return theme.inactive

        if (usedPercent > 90)
            return theme.error

        if (usedPercent > 75)
            return theme.warning

        return theme.success
    }

    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    // ================= MAIN ROW =================
    Row {
        id: row
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: root.icon

            color: hovered
                ? Qt.lighter(theme.fg1, 1.15)
                : theme.fg1

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            font {
                family: theme.font
                pointSize: theme.fontSize - 1
            }

            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: root.free + "|" + root.total

            color: hovered
                ? Qt.lighter(theme.fg1, 1.15)
                : theme.fg1

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            font {
                family: theme.font
                pointSize: theme.fontSize
            }

            verticalAlignment: Text.AlignVCenter
        }
    }

    // ================= CLICK HANDLING =================
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    // ================= POPUP =================
    PopupWindow {
        visible: mouseArea.containsMouse && root.Window.window !== null

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 38

        color: "transparent"

        implicitWidth: card.implicitWidth + 2
        implicitHeight: card.implicitHeight + 2

        Rectangle {
            id: card

            anchors.centerIn: parent

            radius: 16
            color: theme.bg

            implicitWidth: 220
            implicitHeight: content.implicitHeight + 24

            opacity: mouseArea.containsMouse ? 1 : 0
            scale: mouseArea.containsMouse ? 1 : 0.96

            Behavior on opacity {
                NumberAnimation { duration: 160 }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Column {
    id: content
    anchors.centerIn: parent
    spacing: 10

    
    

    Text {
        text: root.icon + " " + root.label
        color: theme.fg1

        font {
            family: theme.font
            pixelSize: 15
            bold: true
        }
    }
    Rectangle {
        width: 180
        height: 6
        radius: 3
        color: Qt.rgba(1, 1, 1, 0.08)

        Rectangle {
            width: parent.width * root.progress
            height: parent.height
            radius: 4
            color: root.diskColor
        }
    }
    Column {
        spacing: 6

        Row {
            spacing: 50
            Text { text: "Free"; color: theme.inactive; width: 80 }
            Text { text: root.free; color: theme.fg1 }
        }

        Row {
            spacing: 50
            Text { text: "Total"; color: theme.inactive; width: 80 }
            Text { text: root.total; color: theme.fg1 }
        }
    }

    

 }

           
        }
    }
}