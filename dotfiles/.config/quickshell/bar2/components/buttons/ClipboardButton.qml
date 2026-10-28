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

    color: sysMouse.containsMouse
        ? root.theme.surfaceAlt
        : root.theme.bg

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Comp.Icon {
    anchors.centerIn: parent
    name: "content_paste"
    size: 18

    color: sysMouse.containsMouse ? root.theme.accent : root.theme.fg
    Behavior on color { ColorAnimation { duration: 120 } }
}

    MouseArea {
        id: sysMouse

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
}
