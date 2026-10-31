import QtQuick
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import ".." as Comp

Rectangle {
    id: root

    required property var theme
    required property var detector

    signal clicked
    signal hoverEntered
    signal hoverExited

    property bool connected: true

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

    // ============================================================
    // CONNECTIVITY CHECK
    // ============================================================

    Process {
    id: connectivityCheck
    command: ["sh", "-c",
        "nmcli -t -f DEVICE,TYPE,STATE device status | awk -F: '$2==\"ethernet\" && $3==\"connected\" {print \"yes\"; found=1} END {if (!found) print \"no\"}'"
    ]
    stdout: SplitParser {
        onRead: line => {
            root.connected = line.trim() === "yes"
        }
    }
}

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: connectivityCheck.running = true
    }

    // ============================================================
    // ICON
    // ============================================================

    // Connected: font icon as before
Comp.Icon {
    anchors.centerIn: parent
    visible: root.connected
    name: "language"
    size: 18
    color: sysMouse.containsMouse ? root.theme.accent : root.theme.fg
    Behavior on color { ColorAnimation { duration: 120 } }
}

// Disconnected: SVG (not in the installed font yet), tinted with the theme's error colour
Image {
    id: offlineIcon
    anchors.centerIn: parent
    visible: false                       // drawn by the overlay below instead
    source: Qt.resolvedUrl("../../assets/globe_2_cancel.svg")
    sourceSize: Qt.size(18, 18)
    width: 18
    height: 18
}
ColorOverlay {
    anchors.fill: offlineIcon
    source: offlineIcon
    color: root.theme.error
    visible: !root.connected
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

        onClicked: {
            root.clicked()
        }
    }
}