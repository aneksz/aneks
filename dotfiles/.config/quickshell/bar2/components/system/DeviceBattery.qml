import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // ============================================================
    // PUBLIC API
    // ============================================================

    property int keyboardBattery: -1
    property int mouseBattery: -1

    property string scriptPath:
        "/home/igor/.config/quickshell/scripts/battery.sh"

    // Tracks if we already sent a low battery warning (prevents spamming)
    property bool keyboardWarned: false
    property bool mouseWarned: false


    // ============================================================
    // BATTERY STATE WATCHERS (Alert Triggers)
    // ============================================================
    onKeyboardBatteryChanged: {
        // Skips the -1 uninitialized boot value
        if (keyboardBattery > 0 && keyboardBattery <= 20) {
            if (!keyboardWarned) {
                notificationProcess.command = ["notify-send", "-u", "critical", "-i", "input-keyboard", "Keyboard Battery Low", "Your MX Keys is at " + keyboardBattery + "%"]
                notificationProcess.running = true
                keyboardWarned = true
            }
        } else if (keyboardBattery > 20) {
            keyboardWarned = false // Reset toggle when charged back up
        }
    }

    onMouseBatteryChanged: {
        // Skips the -1 uninitialized boot value
        if (mouseBattery > 0 && mouseBattery <= 20) {
            if (!mouseWarned) {
                notificationProcess.command = ["notify-send", "-u", "critical", "-i", "input-mouse", "Mouse Battery Low", "Your MX Master 2S is at " + mouseBattery + "%"]
                notificationProcess.running = true
                mouseWarned = true
            }
        } else if (mouseBattery > 20) {
            mouseWarned = false // Reset toggle when charged back up
        }
    }


    // ============================================================
    // NOTIFICATION PROCESS
    // ============================================================
    Process {
        id: notificationProcess
    }


    // ============================================================
    // INITIAL BOOT LOAD
    // ============================================================
    Component.onCompleted: {
        if (!batteryProcess.running) {
            batteryProcess.running = true
        }
    }


    // ============================================================
    // BATTERY POLL TIMER
    // ============================================================
    Timer {
        interval: 60000
        running: true
        repeat: true

        onTriggered: {
            if (!batteryProcess.running)
                batteryProcess.running = true
        }
    }


    // ============================================================
    // BATTERY SCRIPT PROCESS
    // ============================================================
    Process {
        id: batteryProcess

        command: [ scriptPath ]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim()
                if (!output) return

                try {
                    const data = JSON.parse(output)

                    // Only update if the value is a valid number and not null
                    // This preserves the last known battery level while the device sleeps
                    if (data.keyboard !== null && data.keyboard !== undefined) {
                        root.keyboardBattery = Number(data.keyboard)
                    }

                    if (data.mouse !== null && data.mouse !== undefined) {
                        root.mouseBattery = Number(data.mouse)
                    }

                } catch(e) {
                    console.log("BATTERY JSON ERROR:", e, output)
                }
            }
        }
    }
}
