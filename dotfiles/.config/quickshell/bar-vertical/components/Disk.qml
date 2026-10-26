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

 // ================= MAIN ROW =================
Grid {
    id: row
    columns: theme.vertical ? 1 : 3
    spacing: 6
    anchors.verticalCenter: parent.verticalCenter

    readonly property real maxTextWidth: Math.max(iconText.implicitWidth, freeText.implicitWidth, totalText.implicitWidth)

    Item {
        width: row.maxTextWidth
        height: iconText.implicitHeight

        Text {
            id: iconText
            anchors.centerIn: parent
            text: root.icon
            color: hovered ? Qt.lighter(theme.fg1, 1.15) : theme.fg1
            Behavior on color { ColorAnimation { duration: 120 } }
            font { family: theme.font; pointSize: theme.fontSize - 1 }
        }
    }

    Item {
        width: row.maxTextWidth
        height: freeText.implicitHeight

        Text {
            id: freeText
            anchors.centerIn: parent
            text: root.free
            color: hovered ? Qt.lighter(theme.fg1, 1.15) : theme.fg1
            Behavior on color { ColorAnimation { duration: 120 } }
            font { family: theme.font; pointSize: theme.vertical ? theme.fontSize - 2 : theme.fontSize }
        }
    }

    Rectangle {
        width: row.maxTextWidth
        height: 1
        color: theme.inactive
        opacity: 0.4
    }

    Item {
        width: row.maxTextWidth
        height: totalText.implicitHeight

        Text {
            id: totalText
            anchors.centerIn: parent
            text: root.total
            color: hovered ? Qt.lighter(theme.fg1, 1.15) : theme.fg1
            Behavior on color { ColorAnimation { duration: 120 } }
            font { family: theme.font; pointSize: theme.vertical ? theme.fontSize - 2 : theme.fontSize }
        }
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
        anchor.edges: theme.vertical ? Edges.Right : Edges.Bottom
        anchor.gravity: theme.vertical ? Edges.Right : Edges.Bottom
        anchor.margins.top: theme.vertical ? 0 : 38
        anchor.margins.left: theme.vertical ? 40 : 0

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