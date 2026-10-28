import QtQuick

Rectangle {
    id: root

    required property var theme
    required property var detector

    property int activeCount: 0
    property bool hasError: false

    signal clicked
    signal hoverEntered
    signal hoverExited

    width: 30
    height: 30
    radius: height / 2
    anchors.verticalCenter: parent.verticalCenter

    color: sysMouse.containsMouse
        ? root.theme.surfaceAlt
        : root.theme.bg

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Text {
        anchors.centerIn: parent

        text: ""

        color: root.hasError ? root.theme.error
            : root.activeCount > 0 ? root.theme.accent
            : (sysMouse.containsMouse ? root.theme.accent : root.theme.fg)

        font {
            family: root.theme.font
            pixelSize: 18
        }

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    // Active-torrent count badge, only shown when there's something to show
    Rectangle {
        visible: root.activeCount > 0
        width: 14
        height: 14
        radius: 7
        color: root.theme.accent
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -2
        anchors.rightMargin: -2

        Text {
            anchors.centerIn: parent
            text: root.activeCount > 9 ? "9+" : root.activeCount
            color: root.theme.bg
            font {
                family: root.theme.font
                pixelSize: 8
                weight: Font.Bold
            }
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
