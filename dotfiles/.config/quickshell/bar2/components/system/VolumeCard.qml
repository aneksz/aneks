// components/VolumeCard.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Item {
id: volumeCard

// ============================================================
// SIZE
// ============================================================

width: parent ? parent.width : 0
height: 40

// ============================================================
// API
// ============================================================

property var theme
property bool hovered: false

// ============================================================
// AUDIO STATE
// ============================================================

visible:
    Pipewire.defaultAudioSink !== null

readonly property var sink:
    Pipewire.defaultAudioSink

readonly property real currentVol:
    sink && sink.audio
    ? Math.min(sink.audio.volume, 1.0)
    : 0.0

readonly property bool isAirPods:
    sink &&
    sink.description &&
    sink.description.includes("AirPods Pro")

// ============================================================
// BACKGROUND
// ============================================================

Rectangle {
    id: background

    anchors.fill:
        parent

    radius:
        8

    color:
        volumeCard.hovered
        ? Qt.rgba(
            volumeCard.theme.accent.r,
            volumeCard.theme.accent.g,
            volumeCard.theme.accent.b,
            0.08
        )
        : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
}

// ============================================================
// CONTENT
// ============================================================

RowLayout {
    id: contentRow

    anchors {
        fill: parent

        leftMargin: 12
        rightMargin: 12
    }

    spacing:
        12

    // --------------------------------------------------------
    // LEFT: ICON + LABEL
    // --------------------------------------------------------

    RowLayout {
        Layout.alignment:
            Qt.AlignVCenter

        spacing:
            8

        Text {
            Layout.alignment:
                Qt.AlignVCenter

            text: {

                if (
                    volumeCard.isAirPods
                ) {
                    return "󱡏"
                }

                if (
                    volumeCard.sink &&
                    volumeCard.sink.audio &&
                    volumeCard.sink.audio.muted
                ) {
                    return ""
                }

                if (
                    volumeCard.currentVol > 0.6
                ) {
                    return ""
                }

                if (
                    volumeCard.currentVol > 0.2
                ) {
                    return ""
                }

                if (
                    volumeCard.currentVol > 0
                ) {
                    return ""
                }

                return ""
            }

            color:
                volumeCard.theme.accent

            font {
                family:
                    volumeCard.theme.font

                pixelSize:
                    13
            }

            opacity:
                volumeCard.hovered
                ? 1.0
                : 0.85
        }

        Text {
            Layout.alignment:
                Qt.AlignVCenter

            text:
                "Volume"

            color:
                volumeCard.theme.fg1

            font {
                family:
                    volumeCard.theme.font

                pixelSize:
                    12

                weight:
                    volumeCard.theme.fontWeight
            }
        }
    }

    // --------------------------------------------------------
    // CENTER: VOLUME SLIDER
    // --------------------------------------------------------

    MouseArea {
        id: sliderArea

        Layout.fillWidth:
            true

        Layout.alignment:
            Qt.AlignVCenter

        height:
            6

        hoverEnabled:
            true

        cursorShape:
            Qt.PointingHandCursor

        onEntered:
            volumeCard.hovered = true

        onExited:
            volumeCard.hovered = false

        onClicked: mouse => {

            if (
                volumeCard.sink &&
                volumeCard.sink.audio
            ) {
                volumeCard.sink.audio.volume =
                    Math.min(
                        Math.max(
                            mouse.x / width,
                            0
                        ),
                        1
                    )
            }
        }

        onWheel: wheel => {

            if (
                volumeCard.sink &&
                volumeCard.sink.audio
            ) {
                const step =
                    wheel.angleDelta.y > 0
                    ? 0.05
                    : -0.05

                volumeCard.sink.audio.volume =
                    Math.min(
                        Math.max(
                            volumeCard.sink.audio.volume +
                            step,
                            0
                        ),
                        1
                    )
            }
        }

        Rectangle {
            anchors.fill:
                parent

            radius:
                height / 2

            color:
                volumeCard.theme.bg

            Rectangle {
                width:
                    parent.width *
                    volumeCard.currentVol

                height:
                    parent.height

                radius:
                    height / 2

                color:
                    volumeCard.theme.accent

                Behavior on width {
                    NumberAnimation {
                        duration:
                            160

                        easing.type:
                            Easing.OutCubic
                    }
                }
            }
        }
    }

    // --------------------------------------------------------
    // RIGHT: PERCENTAGE
    // --------------------------------------------------------

    Text {
        Layout.alignment:
            Qt.AlignVCenter

        Layout.preferredWidth:
            38

        text:
            Math.round(
                volumeCard.currentVol *
                100
            ) + "%"

        color:
            volumeCard.theme.inactive

        font {
            family:
                volumeCard.theme.font

            pixelSize:
                11

            weight:
                volumeCard.theme.fontWeight
        }
    }
}
}
