// components/Updates.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

Item {
    id: root
    height: 32
    anchors.verticalCenter: parent.verticalCenter
    visible: true
    required property string updateCount
    required property var theme
    required property var themeRunner
    required property var updateCheck
    property bool hovered: false

    signal clicked
    signal hoverEntered
    signal hoverExited

    property string label: "󰅢 " + root.updateCount

    property int count: parseInt(root.updateCount)
    property color textColor:
        count > 50 ? theme.error :
        count > 10 ? theme.warning :
        count > 0  ? theme.activeWs :
                     theme.inactive

   

    width: hoverItem.contentWidth + 10

HoverItem {
    id: hoverItem
    anchors.fill: parent
    textValue: root.label
    theme: root.theme
    hovered: mouseArea.containsMouse
    overrideColor: root.textColor
    iconSize: 22
    textSize: 18
}

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onContainsMouseChanged: {
            root.hovered = containsMouse
            if (containsMouse) root.hoverEntered()
            else root.hoverExited()
        }

        onClicked: root.clicked()
    }
}