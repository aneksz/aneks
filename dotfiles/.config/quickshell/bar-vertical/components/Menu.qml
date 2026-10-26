import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io

Item {
    id: root

    required property var theme

    height: 26
    width: 26

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            Quickshell.execDetached(["qs", "ipc", "-c", "/home/igor/.config/quickshell/bar-vertical", "call", "launcher", "toggle"])
        }
    }

    HoverItem {
        anchors.centerIn: parent

        textValue: "󰣇"
        theme: root.theme

        hovered: mouseArea.containsMouse   

        overrideColor: hovered
            ? theme.error
            : theme.fg

        iconSize: theme.fontSize
    }
}