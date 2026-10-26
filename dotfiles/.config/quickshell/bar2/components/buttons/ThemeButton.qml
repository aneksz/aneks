import QtQuick

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

Text {
    anchors.centerIn:
        parent

    text:
        "󰏘"

    color:
        root.themeVisible
        ? root.theme.accent
        : themeMouse.containsMouse
        ? root.theme.accent
        : root.theme.fg

    font {
        family:
            root.theme.font

        pixelSize:
            18
    }

    Behavior on color {
        ColorAnimation {
            duration:
                120
        }
    }
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
