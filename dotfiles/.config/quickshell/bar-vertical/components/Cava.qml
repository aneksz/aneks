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
    required property var theme
    clip: true

    property var levels: []

    readonly property bool active: {
        if (!levels || levels.length === 0) return false;
        var sum = 0;
        for (var i = 0; i < levels.length; i++) sum += levels[i];
        return sum > 40;
    }

    implicitWidth: theme.vertical ? 30 : cavaRow.implicitWidth
    implicitHeight: theme.vertical ? cavaColumn.implicitHeight : 30

    width: active ? implicitWidth : 0
    height: implicitHeight

    opacity: active ? 1 : 0

    Behavior on width {
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutCubic
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 180
        }
    }

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
                        root.levels = data.values;
                    }
                } catch (e) {
                    console.log("Cava QML Parse Error: " + e);
                }
            }
        }
    }

    // ================= HORIZONTAL: bars grow upward, laid out left-to-right =================
    Row {
        id: cavaRow
        visible: !theme.vertical
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Repeater {
            model: root.levels.length
            delegate: Rectangle {
                width: 3
                anchors.verticalCenter: parent.verticalCenter
                height: {
                    var val = root.levels[index] || 0;
                    return Math.max(4, (val / 100) * (root.width > 0 ? 15 : 15));
                }
                radius: 2
                color: root.theme.accent
                Behavior on height { NumberAnimation { duration: 80 } }
            }
        }
    }

    // ================= VERTICAL: bars grow sideways, laid out top-to-bottom =================
    Column {
        id: cavaColumn
        visible: theme.vertical
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 3

        Repeater {
            model: root.levels.length
            delegate: Rectangle {
                height: 3
                anchors.horizontalCenter: parent.horizontalCenter
                width: {
                    var val = root.levels[index] || 0;
                    return Math.max(4, (val / 100) * 15);
                }
                radius: 2
                color: root.theme.accent
                Behavior on width { NumberAnimation { duration: 80 } }
            }
        }
    }
}
