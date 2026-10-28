import QtQuick

Rectangle {
    id: root

    required property var theme
    required property var detector

    // Bind to the lowest battery percentage (0.0 – 1.0) from the shell
    property real batteryPercent: 1.0

    // Ordered empty -> full. Add or remove entries freely; thresholds adapt.
    readonly property var batteryIcons: [
        "\uf244",   // empty
        "\uf243",   // quarter
        "\uf242",   // half
        "\uf241",   // three quarters
        "\uf240"    // full
    ]

    readonly property int iconIndex: Math.max(0, Math.min(
        batteryIcons.length - 1,
        Math.floor(batteryPercent * batteryIcons.length)
    ))

    readonly property bool critical: batteryPercent <= 0.20

    signal clicked
    signal hoverEntered
    signal hoverExited

    width: 30
    height: 30
    radius: height / 2
    anchors.verticalCenter: parent.verticalCenter

    color: sysMouse.containsMouse ? theme.surfaceAlt : theme.bg
    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        anchors.centerIn: parent
        text: root.batteryIcons[root.iconIndex]

        color: root.critical ? root.theme.error
             : sysMouse.containsMouse ? root.theme.accent
             : root.theme.fg
        Behavior on color { ColorAnimation { duration: 120 } }

        font {
            family: root.theme.font
            pixelSize: 20
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