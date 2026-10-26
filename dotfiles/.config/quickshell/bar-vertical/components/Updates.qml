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
    visible: true
    required property string updateCount
    required property var theme
    required property var themeRunner
    required property var updateCheck

    property string icon: ""

    property int count: parseInt(root.updateCount)
    property color textColor:
        count > 50 ? theme.error :
        count > 10 ? theme.warning :
        count > 0  ? theme.activeWs :
                     theme.inactive

    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight

    Grid {
        id: grid
        anchors.centerIn: parent
        columns: theme.vertical ? 1 : 2
        spacing: 4

        readonly property real maxTextWidth: Math.max(iconText.implicitWidth, countText.implicitWidth)

        Item {
            width: grid.maxTextWidth
            height: iconText.implicitHeight

            Text {
                id: iconText
                anchors.centerIn: parent
                text: root.icon
                color: mouseArea.containsMouse ? theme.error : root.textColor
                font { family: theme.font; pointSize: theme.fontSize }
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }

        Item {
            width: grid.maxTextWidth
            height: countText.implicitHeight

            Text {
                id: countText
                anchors.centerIn: parent
                text: root.updateCount
                color: mouseArea.containsMouse ? theme.error : root.textColor
                font { family: theme.font; pointSize: theme.vertical ? theme.fontSize - 2 : theme.fontSize }
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            Hyprland.dispatch(`hl.exec_cmd("kitty -e sudo pacman -Syyu")`);
            root.updateCount = "0";
            if (!root.updateCheck.running)
                root.updateCheck.running = true;
        }
    }
}