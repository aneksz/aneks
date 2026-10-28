// components/Cava.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io 

Item {
    id: root

    height: 40
    clip: true

    property var levels: []
    property bool playing: false

    // Widget visibility now tracks whether a player is actually running,
    // not the current loudness — quiet passages no longer hide it.
    readonly property bool active: playing

    readonly property int visualWidth: active ? (levels.length * 3) + ((levels.length - 1) * 3) : 0

    width: visualWidth
    implicitWidth: visualWidth

    Behavior on width {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        NumberAnimation { duration: 180 }
    }

    opacity: active ? 1.0 : 0.0

    Process {
        command: ["bash", "/home/igor/.config/waybar/scripts/cava.sh"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: (lineText) => {
                var cleanLine = lineText.trim();
                if (!cleanLine) return;

                try {
                    var data = JSON.parse(cleanLine);
                    if (data && data.values) {
                        root.levels = data.values;
                    }
                    if (data && typeof data.playing === "boolean") {
                        root.playing = data.playing;
                    }
                } catch (e) {
                    // Fail silently for fractional stream buffering splits
                }
            }
        }
    }

    Row {
        id: cavaRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 1
        spacing: 3

        Repeater {
            model: root.levels ? root.levels.length : 0

            delegate: Rectangle {
                width: 3
                anchors.verticalCenter: parent.verticalCenter

                height: {
                    var val = root.levels[index] || 0;
                    return Math.max(3, (val / 100) * 18);
                }

                radius: 1.5
                color: theme.accent

                Behavior on height {
                    NumberAnimation { duration: 70 }
                }
            }
        }
    }
}