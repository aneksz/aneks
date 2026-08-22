// components/system/Controls.qml
import QtQuick
import QtQuick.Layouts

import "../"

Item {
    id: root

    // ============================================================
    // PUBLIC API
    // ============================================================

    property var theme
    property bool dndEnabled: false

    // ============================================================
    // SIZE
    // ============================================================

    width: parent ? parent.width : 0
    height: controlsLayout.implicitHeight

    implicitHeight:
        controlsLayout.implicitHeight

    // ============================================================
    // CONTROL BUTTONS
    // ============================================================

    RowLayout {
        id: controlsLayout

        anchors {
            left: parent.left
            right: parent.right
        }

        spacing: 12

        // --------------------------------------------------------
        // REBOOT
        // --------------------------------------------------------

        ActionButton {
            icon: ""

            baseColor:
                root.theme.success

            hoverColor:
                root.theme.accent

            command: [
                "systemctl",
                "reboot"
            ]

            Layout.fillWidth: true
        }

        // --------------------------------------------------------
        // POWER OFF
        // --------------------------------------------------------

        ActionButton {
            icon: "⏻"

            baseColor:
                root.theme.error

            hoverColor:
                root.theme.accent

            command: [
                "systemctl",
                "poweroff"
            ]

            Layout.fillWidth: true
        }

        // --------------------------------------------------------
        // EXIT HYPRLAND
        // --------------------------------------------------------

        ActionButton {
            icon: "󰗽"

            baseColor:
                root.theme.accent

            hoverColor:
                root.theme.accent

            command: [
                "hyprctl",
                "dispatch",
                "exit"
            ]

            Layout.fillWidth: true
        }
    }
}