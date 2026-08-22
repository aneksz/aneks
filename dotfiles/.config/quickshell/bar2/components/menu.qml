import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io

Item {
    id: root

    width: 30
    height: 30

    Process { id: proc }

    property bool hovered: mouseArea.containsMouse

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            proc.command = [
                "qs",
                "ipc",
                "call",
                "launcher",
                "toggle"
            ]
            proc.running = true
        }
    }
    
    
    Rectangle {
        anchors.fill: parent
        radius: width / 2

        color: hovered ? "#313244" : "#1e1e2e"
        border.width: 1
        border.color: hovered ? "#89b4fa" : "transparent"

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Text {
            anchors.centerIn: parent
            text: "󰣇"
            color: hovered ? "#89b4fa" : "#cdd6f4"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
        }
    }
}