import QtQuick

Rectangle {
    id: root

    required property var theme
    required property var detector

    property bool osdActive: false
    property bool mediaVisible: false
  
    signal clicked
    signal hoverEntered
    signal hoverExited

    width: 24
    height: 30

    radius:
        height / 2

    anchors.verticalCenter:
        parent.verticalCenter

    visible:
        !root.osdActive &&
        !root.mediaVisible

    color:
        menuMouse.containsMouse
        ? "transparent"
        : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Text {
        anchors.centerIn:
            parent

        text:
            "󰣇"

        color:
            menuMouse.containsMouse
            ? root.theme.error
            : root.theme.fg

        font {
            family:
                root.theme.font

            pixelSize:
                18
        }

        Behavior on color {
            ColorAnimation {
                duration: 120
        }
    }

    MouseArea {
    id: menuMouse

    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onEntered: {
        root.detector.childHovered = true
        root.hoverEntered()          // emit
    }

    onExited: {
        root.detector.childHovered = false
        root.hoverExited()           // emit
    }

    onClicked: root.clicked()
  }
}

    // Grow slightly on hover
    scale: menuMouse.containsMouse ? 1.1 : 1.0
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
}