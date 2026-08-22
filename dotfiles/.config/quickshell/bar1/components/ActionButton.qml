import QtQuick

MouseArea {
    id: root

    // -------- API --------
    property string icon: ""
    property color baseColor: "white"
    property color hoverColor: baseColor
    property var command: []

    width: (parent.width / 3) - 7
    height: 60

    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    // -------- INTERACTION --------
    scale: pressed ? 0.95 : (containsMouse ? 1.08 : 1.0)

    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
    }

    // -------- BACKGROUND --------
    Rectangle {
        anchors.fill: parent
        radius: 12

        color: root.containsMouse ? theme.surfaceAlt : theme.bgAlt

        border.color: root.containsMouse ? root.baseColor : theme.surface
        border.width: 1

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    // -------- ICON --------
    Text {
        anchors.centerIn: parent
        text: root.icon

        color: root.containsMouse ? root.hoverColor : root.baseColor
        scale: root.containsMouse ? 1.1 : 1.0

        font.pointSize: 18
        font.family: theme.font

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 120 } }
    }

    // -------- ACTION --------
    onClicked: {
        vpnRunner.command = root.command
        vpnRunner.running = true
    }
}