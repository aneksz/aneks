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

// ============= UPDATES ================
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

    // ===== LABEL =====
    property string label: "󰅢 " + root.updateCount

    // ===== COLOR LOGIC =====
property int count: parseInt(root.updateCount)
property color textColor:
    count > 50 ? theme.error :
    count > 10 ? theme.warning :
    count > 0  ? theme.activeWs :
                 theme.inactive 
   
    // ===== WIDTH =====
    Text {
        id: measureText
        text: root.label
        font.family: theme.font
        font.pointSize: theme.fontSize
        visible: false
    }

    width: measureText.implicitWidth + 10

    HoverItem {
    anchors.fill:
        parent

    textValue:
        root.label

    theme:
        root.theme

    hovered:
        mouseArea.containsMouse

    overrideColor:
        root.textColor

    iconSize:
        16
}

    // ===== INPUT =====
    MouseArea {
    id: mouseArea

    anchors.fill:
        parent

    hoverEnabled:
        true

    cursorShape:
        Qt.PointingHandCursor

    onContainsMouseChanged: {
        root.hovered =
            containsMouse
    }

    onClicked: {
    Quickshell.execDetached({
        command: ["kitty", "-e", "pkexec", "bash", "-c", "pacman -Syyu"]
    })


        root.updateCount =
            "0"

        if (
            !root.updateCheck.running
        ) {
            root.updateCheck.running =
                true
        }
    }
}
}