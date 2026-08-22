import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io

Item {
    id: root

    required property var theme

    height: 26
    width: 26

    Process { id: launcher }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            launcher.command = [
                "bash",
                "-c",
                "~/.config/quickshell/bar1/toggle-launcher.sh"
            ]
            launcher.running = true
        }
    }

    HoverItem {
        anchors.centerIn: parent

        textValue: ""
        theme: root.theme

        hovered: mouseArea.containsMouse   

        overrideColor: hovered
            ? theme.error
            : theme.fg

        iconSize: theme.fontSize
    }
}