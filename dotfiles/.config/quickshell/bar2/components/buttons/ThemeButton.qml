import QtQuick
import ".." as Comp

Rectangle {
id: root


required property var theme
required property var detector

property bool osdActive: false
property bool mediaVisible: false
property bool themeVisible: false

signal clicked
signal hoverEntered
signal hoverExited

width: 30
height: 30

radius:
    height / 2

anchors.verticalCenter:
    parent.verticalCenter

visible:
    !root.osdActive &&
    !root.mediaVisible

color:
    themeMouse.containsMouse
    ? root.theme.surfaceAlt
    : root.theme.bg

Comp.Icon {
    anchors.centerIn: parent
    anchors.verticalCenterOffset: 2
    name: "palette"
    size: 18

    color: root.themeVisible ? root.theme.accent
         : themeMouse.containsMouse ? root.theme.accent
         : root.theme.fg
    Behavior on color { ColorAnimation { duration: 120 } }
}

MouseArea {
    id: themeMouse

    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onEntered: {
        root.hoverEntered()
    }

    onExited: {
        root.hoverExited()
    }

    onClicked: {
        root.clicked()
    }
}
}
