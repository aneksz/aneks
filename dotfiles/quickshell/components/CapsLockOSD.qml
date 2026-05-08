import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root
    required property var theme
    
    // Window logic: Stay alive, but allow click-through when not active
    visible: active
    property bool active: false
    
    

    property string state: "OFF"
    property bool isOn: false

    onStateChanged: {
        isOn = state === "ON"
    }   

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "notifications"
    

    anchors { top: true; right: true }
    // Offset top margin slightly if you want it to sit below the volume OSD
    margins { top: 50; right: 10 } 

    implicitWidth: 200
    implicitHeight: 50
    color: "transparent"

    IpcHandler {
        target: "caps_osd"

        function updateState(newState: string) {
            let cleaned = newState.trim().toUpperCase()
            root.state = cleaned
            root.active = true // 👈 Trigger the slide-in
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 1200
        onTriggered: root.active = false // 👈 Trigger the slide-out
    }

    Rectangle {
        anchors.fill: parent
        visible: true
        color: theme.surface
        radius: 12
        border { 
            color: root.isOn ? theme.accent : theme.inactive
            width: 1 
        }

        // 🎬 Animation Logic
        opacity: root.active ? 1 : 0
        transform: Translate { 
            x: root.active ? 0 : 50 
            Behavior on x { 
                NumberAnimation { duration: 400; easing.type: Easing.OutCubic } 
            }
        }
        Behavior on opacity { 
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            // ICON
            Item {
                width: 28
                height: 28
                Text {
                    anchors.centerIn: parent

                    text: "󰪛"
                    font.pixelSize: 24
                    font.family: theme.font
                    color: root.isOn ? theme.accent : theme.inactive
                    opacity: root.isOn ? 1.0 : 0.3
                    
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
            }

            // TEXT
            Item {
                width: 120
                height: 28
                Text {
                    anchors.centerIn: parent
                    text: "Caps Lock " + (root.isOn ? "On" : "Off")
                    font.family: theme.font
                    font.pixelSize: 14
                    font.bold: true
                    color: theme.fg1
                }
            } 
        }
    }
}
