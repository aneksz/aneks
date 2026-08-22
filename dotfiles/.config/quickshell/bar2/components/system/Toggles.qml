// components/system/Toggles.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    // ============================================================
    // PUBLIC API
    // ============================================================

    property var theme
    property bool dndEnabled: false

    signal dndToggled(bool enabled)

    // ============================================================
    // SIZE
    // ============================================================

    width: parent ? parent.width : 0
    height: 52
    implicitHeight: 52

    // ============================================================
    // INTERNAL STATE
    // ============================================================

    property bool nightLightEnabled: false
    property bool caffeineEnabled: false

    Process {
        id: runner
    }

    // ============================================================
    // TOGGLE BUTTON
    // ============================================================

    component ToggleButton: MouseArea {
        id: btn

        property string icon: ""
        property string activeIcon: icon
        property bool active: false
        property color accent: theme.accent

        width: 40
        height: 40
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            radius: width / 2

            color: btn.active
                   ? Qt.rgba(btn.accent.r, btn.accent.g, btn.accent.b, 0.18)
                   : (btn.containsMouse ? theme.surfaceAlt : "transparent")

            border.width: 1.5
            border.color: (btn.active || btn.containsMouse)
                          ? btn.accent
                          : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)

            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on border.color { ColorAnimation { duration: 120 } }
        }

        Text {
            anchors.centerIn: parent
            text: btn.active ? btn.activeIcon : btn.icon
            color: (btn.active || btn.containsMouse) ? btn.accent : theme.inactive
            font {
                family: theme.font
                pixelSize: 16
            }
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }

    // ============================================================
    // CARD
    // ============================================================

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: theme.bgAlt
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        Row {
            anchors.centerIn: parent
            spacing: 10

            // ----------------------------------------------------
            // BLUETOOTH
            // ----------------------------------------------------
            ToggleButton {
                icon: "󰂯"
                accent: theme.accent

                onClicked: {
                    runner.command = ["kitty", "-e", "bluetui"]
                    runner.running = true
                }
            }

            // ----------------------------------------------------
            // NIGHT LIGHT
            // ----------------------------------------------------
            ToggleButton {
                icon: "󰖨"
                activeIcon: "󰖔"
                active: root.nightLightEnabled
                accent: theme.warning

                onClicked: {
                    root.nightLightEnabled = !root.nightLightEnabled

                    runner.command = [
                        "sh", "-c",
                        root.nightLightEnabled
                            ? "hyprctl hyprsunset temperature 4000 && notify-send 'Night Light' 'On'"
                            : "hyprctl hyprsunset identity && notify-send 'Night Light' 'Off'"
                    ]
                    runner.running = true
                }
            }

            // ----------------------------------------------------
            // DO NOT DISTURB
            // ----------------------------------------------------
            ToggleButton {
                icon: "󰂚"
                activeIcon: "󰂛"
                active: root.dndEnabled
                accent: theme.accent

                onClicked: {
                    // Important: update the property first
                    root.dndEnabled = !root.dndEnabled 
                    // Then notify the parent
                    root.dndToggled(root.dndEnabled)
                }
            }

            // ----------------------------------------------------
           // CAFFEINE
          // ----------------------------------------------------
            ToggleButton {
                 icon: "󰅶"
                 activeIcon: "󰾪"
                 active: root.caffeineEnabled
                 accent: theme.success
                 onClicked: {
                    root.caffeineEnabled = !root.caffeineEnabled

                    if (root.caffeineEnabled) {
                         caffeineProc.command = [
                             "systemd-inhibit",
                             "--what=idle:sleep",
                             "--who=Quickshell",
                             "--why=Caffeine mode enabled",
                             "--mode=block",
                             "sleep",
                            "infinity"
                                                ]
            caffeineProc.running = true
        } else {
            caffeineProc.running = false
        }
    }
}

            // ----------------------------------------------------
            // VOLUME MIXER
            // ----------------------------------------------------
            ToggleButton {
                icon: "󰕾"
                accent: theme.accent

                onClicked: {
                    runner.command = ["kitty", "-e", "wiremix"]
                    runner.running = true
                }
            }
        }
    }
}