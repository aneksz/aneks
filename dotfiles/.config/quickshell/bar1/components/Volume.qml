// components/Volume.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire
import "."

Item {
    id: root

    // =========================
    // CONFIGURATION & THEME
    // =========================
    required property var theme
    required property var volumeProc

    height: 30
    anchors.verticalCenter: parent.verticalCenter

    // =========================
    // PIPEWIRE STATE
    // =========================
    property var sink: Pipewire.defaultAudioSink
    property bool hasSink: sink && sink.audio

    property real vol: hasSink ? sink.audio.volume : 0
    property bool muted: hasSink ? sink.audio.muted : false

    property int volumePercent: Math.round(vol * 100)

    property bool isAirPods: sink &&
        sink.description &&
        sink.description.includes("AirPods Pro")

    // =========================
    // UI STYLE BINDINGS
    // =========================
    property string icon: {
        if (muted) return ""
        if (isAirPods) return "󱡏"
        return ""
    }

    property color fgColor: {
        if (muted) return theme.fg
        if (isAirPods) return theme.accent
        return theme.success
    }

    property string label: icon + " " + volumePercent + "%"

    implicitWidth: 60
    implicitHeight: 30
    width: implicitWidth

    // =========================
    // VISUAL INTERFACE
    // =========================
    HoverItem {
        id: hoverItem
        anchors.fill: parent

        textValue: root.label
        theme: root.theme
        hovered: mouseArea.containsMouse
        overrideColor: root.fgColor
    }

    // =========================
    // INPUT HANDLING
    // =========================
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        // WHEEL SCROLL LOGIC
        onWheel: (wheel) => {
            if (!root.hasSink) return;

            // Determine direction: up is positive, down is negative
            let step = (wheel.angleDelta.y > 0) ? 0.05 : -0.05;
            
            // Calculate new volume and clamp it strictly between 0.0 and 1.0
            let newVol = Math.max(0.0, Math.min(1.0, root.sink.audio.volume + step));
            
            // Apply the change to your Pipewire sink
            root.volumeProc.command = [
                          "wpctl",
                          "set-volume",
                          "@DEFAULT_AUDIO_SINK@",
                          newVol.toFixed(2)
                                     ]
             root.volumeProc.running = true
        }
     onClicked: {
    if (!root.hasSink)
        return

    root.sink.audio.muted = !root.sink.audio.muted
}
    
    }
}
