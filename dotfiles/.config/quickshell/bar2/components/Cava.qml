// components/Cava.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io 

Item {
    id: root
    
    // Explicitly clamp height to your top row frame size (42px)
    height: 42
    clip: true
    
    property var levels: []
    
    // Checks if any music data is registering above noise floor threshold
    readonly property bool active: {
        if (!levels || levels.length === 0) return false;
        var sum = 0;
        for (var i = 0; i < levels.length; i++) {
            sum += levels[i];
        }
        return sum > 40;
    }

    // FIX 1: Explicit mathematical layout footprint width evaluation!
    // (Levels count * 3px bars) + (Gaps count * 3px spacing)
    readonly property int visualWidth: active ? (levels.length * 3) + ((levels.length - 1) * 3) : 0

    // Bind your main component canvas bounds straight to this safe property
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
                        // Re-assign array references instantly to trigger QML property updates
                        root.levels = data.values;
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
        spacing: 3
        
        Repeater {
            model: root.levels ? root.levels.length : 0
            
            delegate: Rectangle {
                width: 3
                anchors.verticalCenter: parent.verticalCenter 
                
                // Restrict heights elegantly within your sleek top bar layout profile
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
