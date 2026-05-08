// components/Workspaces.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects
import "."

// =========== WORKSPACES ==============
Item {
    id: root
    height: 30
    width: wsRow.width
    anchors.verticalCenter: parent.verticalCenter
  

    Process {
        id: wsProc
    }

    // IMPORTANT: make sure theme is available
    required property var theme

    property int activeWs: Hyprland.focusedWorkspace?.id ?? -1
    property bool showIndicator: activeWs >= 1 && activeWs <= 6

    // ================= INDICATOR =================
    Rectangle {
        id: animatedIndicator
        height: 4
        width: 20
        radius: 6
        color: theme.accent 

        anchors.bottom: parent.bottom
        anchors.bottomMargin: -1

        visible: root.showIndicator

        x: (root.activeWs - 1) * (28 + wsRow.spacing) + 4

        Behavior on x {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutQuint
            }
        }
    }

    // ================= WORKSPACES =================
    Row {
        id: wsRow
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: [1, 2, 3, 4, 5, 6]

            delegate: Item {
    width: 28
    height: 28

    property int wsId: modelData
    property bool isActive: root.activeWs === wsId

    property var icons: ({
        1: "",
        2: "",
        3: "",
        4: "",
        5: "",
        6: ""
    })

    // ===== VISUAL =====
    HoverItem {
    anchors.fill: parent
    textValue: icons[wsId]
    theme: root.theme
    hovered: mouseArea.containsMouse

    overrideColor: isActive
        ? theme.accent
        : (mouseArea.containsMouse
            ? theme.activeWs
            : theme.inactive)
    }

    // ===== INPUT (TOP LAYER) =====
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (!wsProc.running) {
                wsProc.command = ["hyprctl", "dispatch", "workspace", wsId.toString()]
                wsProc.running = true
            }
        }
    }

            }
        }
    }
}