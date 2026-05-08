import Quickshell
import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var theme
    
    color: "transparent"
    
    visible: active || mainRect.opacity > 0
    property bool active: false


    property var sink: Pipewire.defaultAudioSink
    property var audio: sink ? sink.audio : null
    property real volume: 0
    property bool initialized: false

    implicitWidth: 250
    implicitHeight: 30

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "notifications"

    anchors { top: true; right: true }
    margins { top: 10; right: 10 }

    onSinkChanged: { if (sink) root.audio = sink.audio }

    // ===== LOGIC ENGINE =====
    Connections {
        target: root.audio
        ignoreUnknownSignals: true

        function onVolumeChanged() {
            let rawVol = root.audio ? root.audio.volume : 0
            
            if (rawVol > 1.0) {
                root.audio.volume = 1.0
                root.volume = 1.0
            } else {
                root.volume = rawVol
            }

            if (!root.initialized) {
                root.initialized = true
                return 
            }

            root.active = true // 👈 Show the UI
            hideTimer.restart()
        }

        function onMutedChanged() {
            if (!root.initialized) {
                root.initialized = true
                return
            }
            root.active = true
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: root.active = false // 👈 Hide the UI
    }

     // ===== UI =====
    Rectangle {
        id: mainRect // Added ID to reference in 'visible' check above
        anchors.fill: parent
        color: theme.surface
        radius: 12
        border { color: theme.accent; width: 1 }

        // 🎬 Animation Logic
        opacity: root.active ? 1 : 0
        
        transform: Translate { 
            // Slides 50px right when inactive
            x: root.active ? 0 : 50 
            
            Behavior on x { 
                NumberAnimation { duration: 800; easing.type: Easing.OutCubic } 
            }
        }

        Behavior on opacity { 
            NumberAnimation { duration: 800; easing.type: Easing.OutCubic } 
        }

        Row {
            anchors.centerIn: parent
            spacing: 12

            Text {
                width: 24 
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
                font.family: theme.font
                color: (root.audio && root.audio.muted) ? theme.inactive : theme.accent
                text: {
                    if (!root.audio || root.audio.muted) return ""
                    if (root.volume > 0.6) return ""
                    if (root.volume > 0.2) return ""
                    if (root.volume > 0) return ""
                    return ""
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 140; height: 4; radius: 2
                color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.2)

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height; radius: 2
                    color: (root.audio && root.audio.muted) ? theme.inactive : theme.accent
                    width: parent.width * Math.min(root.volume, 1.0)
                }
            }

            Text {
                width: 38 
                horizontalAlignment: Text.AlignLeft
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 12
                font.family: theme.font
                font.bold: true
                color: theme.fg1
                text: Math.round(Math.min(root.volume, 1.0) * 100) + "%"
            }
        }
    }
}
