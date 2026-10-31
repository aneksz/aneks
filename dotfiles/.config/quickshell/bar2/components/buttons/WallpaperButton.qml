import QtQuick

Rectangle {
    id: root

    required property var theme

    property bool wallpaperVisible: false

    signal clicked
    signal hoverEntered
    signal hoverExited

    width: 24
    height: 30

    radius:
        height / 2

    anchors.verticalCenter:
        parent.verticalCenter

    color:
        wallpaperMouse.containsMouse
        ? "transparent"
        : "transparent"

    Text {
        anchors.centerIn:
            parent

        text:
            "󰉔"

        color:
            root.wallpaperVisible
            ? root.theme.accent
            : root.theme.warning

        font {
            family:
                root.theme.font

            pixelSize:
                18
        }
    }

    MouseArea {
        id:
            wallpaperMouse

        anchors.fill:
            parent

        hoverEnabled:
            true

        cursorShape:
            Qt.PointingHandCursor

        onEntered:
            root.hoverEntered()

        onExited:
            root.hoverExited()

        onClicked:
            root.clicked()
    }

    // Grow slightly on hover
    scale: wallpaperMouse.containsMouse ? 1.1 : 1.0
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
}