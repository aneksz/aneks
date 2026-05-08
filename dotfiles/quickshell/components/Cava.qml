// components/Cava.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

// ============ CAVA WAVE ================
Item {
    id: root
    height: parent.height
    clip: true
    
    property var levels: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    readonly property bool active: {
        if (!levels || levels.length === 0) return false;
        var sum = 0;
        for (var i = 0; i < levels.length; i++) sum += levels[i];
        return sum > 0;
    }

    width: active ? 180 : 0
    opacity: active ? 1 : 0

    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    Behavior on opacity { NumberAnimation { duration: 400 } }

    Process {
        command: ["bash", "/home/igor/.config/waybar/scripts/cava.sh"]
        running: true
        stdout: StdioCollector {
            waitForEnd: false
            onTextChanged: {
                var lines = text.trim().split("\n");
                if (lines.length === 0) return;
                var lastLine = lines[lines.length - 1].trim();
                try {
                    var data = JSON.parse(lastLine);
                    if (data && data.values) {
                        // Re-assigning the whole array to trigger property updates
                        root.levels = data.values;
                    }
                } catch (e) {
                    console.log("Cava QML Parse Error: " + e);
                }
            }
        }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3
        Repeater {
            model: 20
            delegate: Rectangle {
                width: 3
                anchors.verticalCenter: parent.verticalCenter 
                height: {
                    var val = root.levels[index] || 0;
                    return Math.max(4, (val / 100) * (root.height * 0.5));
                }
                radius: 2
                color: theme.accent
                Behavior on height { NumberAnimation { duration: 80 } }
            }
        }
    }
 }
