import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth: 520
    implicitHeight: 400

    required property var theme

    // ============================================================
    // DEVICE MATCH STRINGS
    // Adjust these to match the `model:` field from `upower -d`
    // ============================================================
    // Must match the codename solaar show prints for each device,
    // e.g. "3: Wireless Mouse MX Master 2S" / "4: MX Keys Keyboard"
    readonly property string mouseMatch: "MX Master 2S"
    readonly property string keyboardMatch: "MX Keys"

    // Path to battery-status.sh — adjust if you place it elsewhere.
    // $HOME is expanded by the shell at run time, not by QML.
    readonly property string scriptPath: "$HOME/.config/quickshell/scripts/battery.sh"

    // ============================================================
    // LOW BATTERY NOTIFICATIONS
    // ============================================================
    readonly property real lowBatteryThreshold: 0.20  // 20%

    // Tracks if we already sent a low battery warning (prevents spamming)
    property bool mouseWarned: false
    property bool keyboardWarned: false

    // ============================================================
    // DEVICE RUNTIME STATE
    // ============================================================
    property string mouseName: "MX Master 2S"
    property real mousePercent: 0.0
    property string mouseState: "UNKNOWN"
    property string mouseReported: "never"
    property string mousePath: "unknown"
    property string mouseTimeLeft: "--"
    property string mouseSerial: "unknown"

    property string keyboardName: "MX Keys"
    property real keyboardPercent: 0.0
    property string keyboardState: "UNKNOWN"
    property string keyboardReported: "never"
    property string keyboardPath: "unknown"
    property string keyboardTimeLeft: "--"
    property string keyboardSerial: "unknown"

    // ============================================================
    // LOW BATTERY WATCHERS (Alert Triggers)
    // ============================================================
    onMousePercentChanged: {
        // mousePercent starts at 0.0 before the first poll resolves,
        // so require > 0 to skip that uninitialized boot value
        if (mousePercent > 0 && mousePercent <= lowBatteryThreshold) {
            if (!mouseWarned) {
                notificationProcess.command = ["notify-send", "-u", "critical", "-i", "input-mouse",
                    "Mouse Battery Low", "Your " + mouseName + " is at " + Math.round(mousePercent * 100) + "%"]
                notificationProcess.running = true
                mouseWarned = true
            }
        } else if (mousePercent > lowBatteryThreshold) {
            mouseWarned = false // reset once charged back up
        }
    }

    onKeyboardPercentChanged: {
        if (keyboardPercent > 0 && keyboardPercent <= lowBatteryThreshold) {
            if (!keyboardWarned) {
                notificationProcess.command = ["notify-send", "-u", "critical", "-i", "input-keyboard",
                    "Keyboard Battery Low", "Your " + keyboardName + " is at " + Math.round(keyboardPercent * 100) + "%"]
                notificationProcess.running = true
                keyboardWarned = true
            }
        } else if (keyboardPercent > lowBatteryThreshold) {
            keyboardWarned = false
        }
    }

    Process {
        id: notificationProcess
    }

    // ============================================================
// REFRESH ENGINE — single UPower query, both devices
// ============================================================

Timer {
    id: pollTimer
    interval: 30000   // 30s — battery % doesn't need 5s granularity
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
        if (batteryWorker.running) {
            return
        }
        batteryWorker.running = true
    }
}

Process {
    id: batteryWorker
    // battery.sh does the UPower lookup + drain-rate estimation.
    // Keeping it as a standalone script (rather than an inline heredoc)
    // makes it easy to test/tweak from a terminal on its own.
    command: ["sh", "-c", `timeout 25 sh -c '"${root.scriptPath}" "${root.mouseMatch}" "${root.keyboardMatch}"'`]

    onExited: (exitCode, exitStatus) => {
        if (exitCode !== 0) {
            console.warn("[battery] script exited abnormally, code:", exitCode, "status:", exitStatus)
        }
    }

    stdout: SplitParser {
        onRead: line => {
            const trimmed = line.trim()
            const sepIndex = trimmed.indexOf(':')
            if (sepIndex === -1) return

            const tag = trimmed.slice(0, sepIndex)
            const payload = trimmed.slice(sepIndex + 1)
            const parts = payload.split('|')
            if (parts.length < 5) return

            const percent = parseFloat(parts[0]) / 100.0
            const state = parts[1]
            const serial = parts[2]
            const path = parts[3]
            const timeLeft = parts[4]
            const now = new Date().toLocaleTimeString(Qt.locale(), "hh:mm:ss")

            if (tag === "MOUSE") {
                root.mousePercent = percent
                root.mouseState = state
                root.mouseSerial = serial
                root.mousePath = path
                root.mouseTimeLeft = timeLeft
                root.mouseReported = now
            } else if (tag === "KEYBOARD") {
                root.keyboardPercent = percent
                root.keyboardState = state
                root.keyboardSerial = serial
                root.keyboardPath = path
                root.keyboardTimeLeft = timeLeft
                root.keyboardReported = now
            }
        }
    }

    stderr: SplitParser {
        onRead: line => console.warn("[battery] stderr:", line)
    }
}

    // ============================================================
    // SUB-COMPONENTS
    // ============================================================

    component MetaItem : RowLayout {
        property string label: ""
        property string value: ""
        Layout.fillWidth: true

        Text { text: label; color: root.theme.fg0; font { family: root.theme.font; pixelSize: 13 } }
        Item { Layout.fillWidth: true }
        Text { text: value; color: root.theme.fg; font { family: root.theme.font; pixelSize: 13; bold: true } }
    }

    component BatteryDeviceCard : ColumnLayout {
        property string icon: ""
        property string deviceName: ""
        property string deviceStatus: ""
        property real percentValue: 0.0

        property string valReported: ""
        property string valPath: ""
        property string valTimeLeft: ""
        property string valSerial: ""

        Layout.fillWidth: true
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: icon
                color: percentValue <= 0.20 ? root.theme.error : root.theme.accent
                font { family: root.theme.font; pixelSize: 32 }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: deviceName
                    color: root.theme.fg0
                    font { family: root.theme.font; pixelSize: 18; bold: true }
                }
                Text {
                    text: deviceStatus
                    color: deviceStatus === "CHARGING" ? root.theme.success : root.theme.fg0
                    font { family: root.theme.font; pixelSize: 11; bold: true }
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: Math.round(percentValue * 100) + "%"
                color: root.theme.fg0
                font { family: root.theme.font; pixelSize: 24; bold: true }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: root.theme.bgAlt
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)

            Rectangle {
                width: parent.width * percentValue
                height: parent.height
                radius: 3
                color: percentValue <= 0.20 ? root.theme.error : root.theme.accent

                Behavior on width { NumberAnimation { duration: 250 } }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 76
            radius: 8
            color: "transparent"
            border.width: 0
            border.color: Qt.rgba(1, 1, 1, 0.05)

            GridLayout {
                anchors.fill: parent
                anchors.margins: 12
                columns: 2
                rowSpacing: 8
                columnSpacing: 24

                MetaItem { label: "Reported"; value: valReported }
                MetaItem { label: "Device"; value: valPath }
                MetaItem { label: "Time left"; value: valTimeLeft }
                MetaItem { label: "Serial"; value: valSerial }
            }
        }
    }

    // ============================================================
    // PANEL LAYOUT
    // ============================================================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        BatteryDeviceCard {
            icon: "󰍽"
            deviceName: root.mouseName
            deviceStatus: root.mouseState
            percentValue: root.mousePercent
            valReported: root.mouseReported
            valPath: root.mousePath
            valTimeLeft: root.mouseTimeLeft
            valSerial: root.mouseSerial
        }

        Item { height: 4 }

        BatteryDeviceCard {
            icon: "󰌌"
            deviceName: root.keyboardName
            deviceStatus: root.keyboardState
            percentValue: root.keyboardPercent
            valReported: root.keyboardReported
            valPath: root.keyboardPath
            valTimeLeft: root.keyboardTimeLeft
            valSerial: root.keyboardSerial
        }

        Item { Layout.fillHeight: true }
    }
}
