// components/PowerModule.qml
// Quick power menu, opened with SUPER+P (IPC: qs ipc -c ~/.config/quickshell/bar2 call power toggle)
// Keys: Left/Right or Tab to move, Enter to run, 1-5 to run directly, Escape to close.
import QtQuick
import Quickshell

Item {
    id: root

    required property var theme
    signal closeRequested()

    property int selected: 0

    readonly property var actions: [
        { label: "Lock",      icon: "lock",               cmd: ["quickshell", "-p", Quickshell.env("HOME") + "/.config/quickshell/lock/shell.qml"] },
        { label: "Suspend",   icon: "bedtime",            cmd: ["systemctl", "suspend"] },
        { label: "Log Out",   icon: "logout",             cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
        { label: "Reboot",    icon: "restart_alt",        cmd: ["systemctl", "reboot"] },
        { label: "Power Off", icon: "power_settings_new", cmd: ["systemctl", "poweroff"] }
    ]

    function run(i) {
        const a = actions[i]
        if (!a) return
        root.closeRequested()                 // close the menu first so the lock screen etc. isn't covered
        Quickshell.execDetached(a.cmd)
    }

    // Every time the menu opens: start on Lock (the harmless one) and grab the keyboard
        onVisibleChanged: {
        if (visible) {
            selected = 0
            Qt.callLater(() => root.forceActiveFocus())
        }
    }

    focus: visible
    Keys.onLeftPressed:    selected = (selected + actions.length - 1) % actions.length
    Keys.onRightPressed:   selected = (selected + 1) % actions.length
    Keys.onTabPressed:     selected = (selected + 1) % actions.length
    Keys.onBacktabPressed: selected = (selected + actions.length - 1) % actions.length
    Keys.onReturnPressed:  run(selected)
    Keys.onEnterPressed:   run(selected)
    Keys.onEscapePressed:  closeRequested()
    Keys.onPressed: function(event) {
        const n = event.key - Qt.Key_1
        if (n >= 0 && n < actions.length) {
            run(n)
            event.accepted = true
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: root.actions

            delegate: Rectangle {
                id: tile
                required property var modelData
                required property int index
                readonly property bool isSelected: root.selected === index

                width: 104
                height: 96
                radius: 16
                color: isSelected ? root.theme.accent : root.theme.bgAlt
                border.width: 1
                border.color: isSelected ? "transparent" : Qt.rgba(1, 1, 1, 0.06)
                scale: tileMouse.pressed ? 0.96 : 1.0

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: tile.modelData.icon
                        color: tile.isSelected ? root.theme.bg : root.theme.fg
                        font { family: "Material Symbols Outlined"; pixelSize: 26 }
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: tile.modelData.label
                        color: tile.isSelected ? root.theme.bg : root.theme.fg
                        font { family: root.theme.font; pixelSize: 13; bold: true }
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }

                MouseArea {
                    id: tileMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.selected = tile.index
                    onClicked: root.run(tile.index)
                }
            }
        }
    }
}
