import QtQuick
import ".." as Comp

Rectangle {
    id: root

    required property var theme
    required property var detector

    signal clicked
    signal hoverEntered
    signal hoverExited

    width: 30
    height: 30
    radius: height / 2
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 2

    color: monMouse.containsMouse
        ? "transparent"
        : "transparent"

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Comp.Icon {
        anchors.centerIn: parent
        name: "desktop_windows"
        size: 18

        color: monMouse.containsMouse ? root.theme.accent : root.theme.fg
        Behavior on color { ColorAnimation { duration: 120 } }
    }


    MouseArea {
        id: monMouse

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
    scale: monMouse.containsMouse ? 1.1 : 1.0
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
}
