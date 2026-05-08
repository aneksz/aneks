// components/Volume.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects
import "."

// =========== VOLUME ==============
Item {
    id: root
    height: 30
    anchors.verticalCenter: parent.verticalCenter
    visible: true

    required property var theme
    required property var volumeProc

    property bool isMuted: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio
        ? Pipewire.defaultAudioSink.audio.muted
        : false

    property real vol: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio
        ? Pipewire.defaultAudioSink.audio.volume
        : 0

    // computed label
    property string label: root.isMuted
        ? " " + Math.round(root.vol * 100) + "%"
        : " " + Math.round(root.vol * 100) + "%"

    width: label.length * theme.fontSize * 0.6 + 20   // simple dynamic width

    // ===== VISUAL =====
    HoverItem {
    anchors.fill: parent
    textValue: root.label
    theme: root.theme
    hovered: mouseArea.containsMouse

    overrideColor: root.isMuted
        ? theme.fg
        : theme.success
}

    // ===== INPUT =====
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
          root.volumeProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
          root.volumeProc.running = true
          }

        onWheel: (e) => {
        let delta = e.angleDelta.y > 0 ? "5%+" : "5%-"
        root.volumeProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", delta]
        root.volumeProc.running = true
      }
    }
}