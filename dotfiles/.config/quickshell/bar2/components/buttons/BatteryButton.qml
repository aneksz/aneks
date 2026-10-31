import QtQuick
import ".." as Comp

Rectangle {
    id: root

    required property var theme
    required property var detector

    // Bind to the lowest battery percentage (0.0 – 1.0) from the shell
    property real batteryPercent: 1.0

    // Ordered empty -> full. Add or remove entries freely; thresholds adapt.
    readonly property var batteryIcons: [
    "battery_0_bar",   // empty
    "battery_2_bar",   // quarter
    "battery_4_bar",   // half
    "battery_6_bar",   // three quarters
    "battery_full"     // full
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
    anchors.verticalCenterOffset: 1

    color: sysMouse.containsMouse ? "transparent" : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }

    Comp.Icon {
    anchors.centerIn: parent
    name: root.batteryIcons[root.iconIndex]
    size: 18

    color: root.critical ? root.theme.error
         : sysMouse.containsMouse ? root.theme.accent
         : root.theme.fg
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

    // Grow slightly on hover
    scale: sysMouse.containsMouse ? 1.1 : 1.0
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
}