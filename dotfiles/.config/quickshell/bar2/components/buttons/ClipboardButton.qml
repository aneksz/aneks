import QtQuick

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
    anchors.verticalCenterOffset: -1

    color: sysMouse.containsMouse
        ? root.theme.surfaceAlt
        : root.theme.bg

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Text {
        anchors.centerIn: parent

        text: "󰅍" 

        color: sysMouse.containsMouse ? root.theme.accent : root.theme.fg

        font {
            family: root.theme.font
            pixelSize: 19
        }

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
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
