import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root

    // ============================================================
    // API
    // ============================================================
    property var theme
    signal osdTriggered()

    // ============================================================
    // STATE
    // ============================================================
    property bool active: false
    property bool audioReady: false

    // ============================================================
    // AUDIO
    // ============================================================
    property var sink: Pipewire.defaultAudioSink
    readonly property var audio:
        sink
        ? sink.audio
        : null
    property real volume: 0
    // ============================================================
    // SIZE
    // ============================================================
    anchors.fill: parent

    // ============================================================
    // STARTUP INITIALISATION
    // ============================================================

    Component.onCompleted: {
        if (root.audio) {
            root.volume =
                Math.min(
                    root.audio.volume,
                    1.0
                )
        }

        startupGuard.start()
    }
    // ============================================================
    // STARTUP GUARD
    //
    // PipeWire can emit initial volume/mute changes while the
    // shell is reconnecting. Ignore those changes until the
    // audio state has settled.
    // ============================================================

    Timer {id: startupGuard; interval: 500; repeat: false; onTriggered: { root.audioReady = true }}

    // ============================================================
    // AUDIO MONITOR
    // ============================================================

    Connections {
        target: root.audio
        ignoreUnknownSignals: true
        // ========================================================
        // VOLUME CHANGED
        // ========================================================

        function onVolumeChanged() {

            if (!root.audio)
                return

            root.volume =
                Math.min(
                    root.audio.volume,
                    1.0
                )

            if (!root.audioReady)
                return
            root.active = true
            root.osdTriggered()
            hideTimer.restart()
        }
        // ========================================================
        // MUTE CHANGED
        // ========================================================

        function onMutedChanged() {

            if (!root.audioReady)
                return
            root.active = true
            root.osdTriggered()
            hideTimer.restart()
        }
    }
    // ============================================================
    // AUTO HIDE
    // ============================================================

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false

        onTriggered: {
            root.active = false
        }
    }
    // ============================================================
    // OSD CONTENT
    // ============================================================

    Rectangle {
        id: mainRect
        anchors.fill: parent
        radius: 16
        color: root.theme.bg

// ========================================================
// ANIMATION
// ========================================================

opacity: root.active ? 1.0 : 0.0


Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic }}


        // ========================================================
        // CONTENT
        // ========================================================

        Row {
            anchors.centerIn: parent
            spacing: 12

            // ====================================================
            // VOLUME ICON
            // ====================================================

            Text {
                width: 24
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter

                color:
                    root.audio &&
                    root.audio.muted
                    ? root.theme.fg3
                    : root.theme.accent

                text: {
                    if (
                        !root.audio ||
                        root.audio.muted
                    ) {
                        return ""
                    }

                    if (
                        root.volume >
                        0.6
                    ) {

                        return ""
                    }

                    if (
                        root.volume >
                        0.2
                    ) {

                        return ""
                    }

                    if (
                        root.volume >
                        0
                    ) {

                        return ""
                    }

                    return ""
                }

                font {
                    family: root.theme.font
                    pixelSize: 14
                }
            }

            // ====================================================
            // VOLUME BAR
            // ====================================================

            Rectangle {
                width: 140
                height: 12
                radius: 8
                anchors.verticalCenter: parent.verticalCenter

                color: Qt.rgba(root.theme.accent.r,root.theme.accent.g,root.theme.accent.b,0.2)

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * Math.min(root.volume,1.0)
                    height: parent.height
                    radius: 8

                    color:
                        root.audio &&
                        root.audio.muted
                        ? root.theme.fg3
                        : root.theme.accent
                }
            }
            // ====================================================
            // PERCENTAGE
            // ====================================================

            Text {
                width: 30
                horizontalAlignment: Text.AlignLeft
                anchors.verticalCenter: parent.verticalCenter

                text: Math.round(Math.min(root.volume,1.0) * 100) + "%"

                color:
                    root.audio &&
                    root.audio.muted
                    ? root.theme.fg3
                    : root.theme.fg

                font {
                    family: root.theme.font
                    pixelSize: 12
                    bold:true
                }
            }
        }
    }
}