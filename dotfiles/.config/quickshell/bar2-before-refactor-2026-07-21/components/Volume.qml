// components/Volume.qml
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root

    // ============================================================
    // PUBLIC API
    // ============================================================

    required property var theme
    required property var volumeProc
    property bool hovered: false

    width: 60
    height: 30

    // ============================================================
    // PIPEWIRE STATE
    // ============================================================

    readonly property var sink:
        Pipewire.defaultAudioSink

    readonly property bool hasSink:
        sink !== null &&
        sink.audio !== null

    readonly property real volume:
        hasSink
        ? sink.audio.volume
        : 0.0

    readonly property bool muted:
        hasSink
        ? sink.audio.muted
        : false

    readonly property bool isAirPods:
        sink !== null &&
        sink.description !== undefined &&
        sink.description.includes("AirPods Pro")

    readonly property int volumePercent:
        Math.round(volume * 100)

    // ============================================================
    // ICON / COLOUR
    // ============================================================

    readonly property string icon: {

        if (muted)
            return ""

        if (isAirPods)
            return "󱡏"

        return ""
    }

    readonly property color iconColor: {

        if (muted)
            return root.theme.inactive

        if (isAirPods)
            return root.theme.accent

        return root.theme.success
    }

    // ============================================================
    // BUTTON BACKGROUND
    // ============================================================

    Rectangle {
        anchors.fill:
            parent

        radius:
            height / 2

        color:
            volumeMouseArea.containsMouse
            ? root.theme.surfaceAlt
            : root.theme.bg

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    // ============================================================
    // VOLUME DISPLAY
    // ============================================================

    Row {
        anchors.centerIn:
            parent

        spacing:
            4

        Text {
            text:
                root.icon

            color:
                root.iconColor

            font {
                family:
                    root.theme.font

                pixelSize:
                    16
            }

            anchors.verticalCenter:
                parent.verticalCenter

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }

        Text {
            text:
                root.volumePercent + "%"

            color:
                root.theme.fg

            font {
                family:
                    root.theme.font

                pixelSize:
                    14

        
            }

            anchors.verticalCenter:
                parent.verticalCenter
        }
    }

    // ============================================================
    // INPUT
    // ============================================================

    MouseArea {
        id:
            volumeMouseArea

        anchors.fill:
            parent

        hoverEnabled:
            true

        cursorShape:
            Qt.PointingHandCursor

            onContainsMouseChanged: {
    root.hovered = containsMouse
}

        // --------------------------------------------------------
        // SCROLL VOLUME
        // --------------------------------------------------------

        onWheel: function(wheel) {

            if (!root.hasSink)
                return

            const step =
                wheel.angleDelta.y > 0
                ? 0.05
                : -0.05

            const newVolume =
                Math.max(
                    0.0,
                    Math.min(
                        1.0,
                        root.volume + step
                    )
                )

            root.volumeProc.command = [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                newVolume.toFixed(2)
            ]

            root.volumeProc.running =
                true
        }

        // --------------------------------------------------------
        // CLICK TO MUTE
        // --------------------------------------------------------

        onClicked: {

            if (!root.hasSink)
                return

            root.sink.audio.muted =
                !root.sink.audio.muted
        }
    }
}
