import QtQuick
import Quickshell.Io
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

    Comp.Icon {
    anchors.centerIn: parent
    name: root.connected ? "nest_wifi_pro" : "globe_2_cancel"
    size: 18

    color: {
        if (!root.connected) return root.theme.error
        return sysMouse.containsMouse ? root.theme.accent : root.theme.fg
    }
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

        onClicked: {
            root.clicked()
        }
    }
}