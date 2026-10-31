import QtQuick
import ".." as Comp

Rectangle {
    id: root

    required property var theme
    required property var detector

    // Set from shell.qml: uncommitted changes and commits not yet pushed
    property int changes: 0
    property int ahead: 0
    readonly property bool dirty: changes > 0 || ahead > 0

    signal clicked
    signal hoverEntered
    signal hoverExited

    width: 30
    height: 30
    radius: height / 2
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 2

    color: gitMouse.containsMouse
        ? "transparent"
        : "transparent"

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Comp.Icon {
        anchors.centerIn: parent
        name: "commit"
        size: 18

        color: gitMouse.containsMouse || root.dirty ? root.theme.accent : root.theme.fg
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    // Small dot when there is something to commit or push
    Rectangle {
        width: 6
        height: 6
        radius: 3
        anchors { top: parent.top; right: parent.right; topMargin: 4; rightMargin: 4 }
        color: root.theme.accent
        visible: root.dirty
    }

    MouseArea {
        id: gitMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            root.detector.childHovered = true
            root.hoverEntered()
        }

        onExited: {
            root.detector.childHovered = false
            root.hoverExited()
        }

        onClicked: root.clicked()
    }

    // Grow slightly on hover
    scale: gitMouse.containsMouse ? 1.1 : 1.0
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
}
