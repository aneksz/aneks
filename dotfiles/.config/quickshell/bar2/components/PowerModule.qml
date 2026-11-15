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

    // size the host can use for the power panel
    implicitWidth: content.implicitWidth + 64
    implicitHeight: content.implicitHeight + 48

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

    Column {
        id: content
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 3       // nudge down: the label line has empty space below the letters
        spacing: 4

        // round icon buttons
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 18

            Repeater {
                model: root.actions

                delegate: Rectangle {
                    id: btn
                    required property var modelData
                    required property int index
                    readonly property bool isSelected: root.selected === index

                    width: 48
                    height: 48
                    radius: width / 2
                    color: isSelected ? root.theme.accent : root.theme.bgAlt
                    border.width: 1
                    border.color: isSelected ? "transparent" : Qt.rgba(1, 1, 1, 0.06)
                    scale: btnMouse.pressed ? 0.94 : 1.0

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                    Icon {
                        anchors.centerIn: parent
                        name: btn.modelData.icon
                        size: 24
                        color: btn.isSelected ? root.theme.bg : root.theme.fg
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        id: btnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selected = btn.index
                        onClicked: root.run(btn.index)
                    }
                }
            }
        }

        // name of the selected action: slides up when it changes
        Item {
            id: labelBox
            anchors.horizontalCenter: parent.horizontalCenter
            width: 160
            height: 22
            clip: true

            Text {
                id: labelText
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: root.theme.fg
                font { family: root.theme.font; pixelSize: 15; bold: true }
                Component.onCompleted: text = root.actions[root.selected].label
            }

            Connections {
                target: root
                function onSelectedChanged() { labelAnim.restart() }
            }

            SequentialAnimation {
                id: labelAnim
                ParallelAnimation {
                    NumberAnimation { target: labelText; property: "y"; to: -10; duration: 90; easing.type: Easing.InCubic }
                    NumberAnimation { target: labelText; property: "opacity"; to: 0; duration: 90 }
                }
                ScriptAction { script: labelText.text = root.actions[root.selected].label }
                PropertyAction { target: labelText; property: "y"; value: 10 }
                ParallelAnimation {
                    NumberAnimation { target: labelText; property: "y"; to: 0; duration: 150; easing.type: Easing.OutCubic }
                    NumberAnimation { target: labelText; property: "opacity"; to: 1; duration: 150 }
                }
            }
        }
    }
}