// components/system/VolumeCard.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root

    // ============================================================
    // SIZE
    // ============================================================

    width: parent ? parent.width : 0
    height: 52
    implicitHeight: 52

    // ============================================================
    // API
    // ============================================================

    property var theme

    // ============================================================
    // AUDIO STATE
    // ============================================================

    visible: Pipewire.defaultAudioSink !== null

    readonly property var sink: Pipewire.defaultAudioSink

    readonly property real currentVol: sink && sink.audio
        ? Math.min(sink.audio.volume, 1.0)
        : 0.0

    readonly property bool isMuted: sink && sink.audio && sink.audio.muted

    readonly property bool isAirPods: sink && sink.description &&
        (sink.description.includes("AirPods") || sink.description.includes("Airpods"))

    // ============================================================
    // MAIN CARD
    // ============================================================

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root.theme.bgAlt
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12

            // ----------------------------------------------------
            // ICON
            // ----------------------------------------------------

            Text {
                Layout.alignment: Qt.AlignVCenter

                text: {
                    if (root.isAirPods)
                        return "󱡏"
                    if (root.isMuted || root.currentVol === 0)
                        return "󰖁"
                    if (root.currentVol > 0.66)
                        return "󰕾"
                    if (root.currentVol > 0.33)
                        return "󰖀"
                    return "󰕿"
                }
                
                color: theme.accent
                font {
                    family: theme.font
                    pixelSize: 18
                }
            }

            // ----------------------------------------------------
            // LABEL + SLIDER
            // ----------------------------------------------------

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                // Label + percentage
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.isAirPods ? "AirPods" : "Volume"
                        color: theme.fg
                        font {
                            family: theme.font
                            pixelSize: 12
                            weight: Font.Bold
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: Math.round(root.currentVol * 100) + "%"
                        color: theme.inactive
                        font {
                            family: theme.font
                            pixelSize: 12
                        }
                    }
                }

                // Slider
                MouseArea {
    id: sliderArea

    Layout.fillWidth: true
    height: 6

    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    function setVolume(mouseX) {
        if (root.sink && root.sink.audio) {
            root.sink.audio.volume =
                Math.min(Math.max(mouseX / width, 0), 1)
        }
    }

    onClicked: (mouse) => {
        setVolume(mouse.x)
    }

    onPositionChanged: (mouse) => {
        if (pressed)
            setVolume(mouse.x)
    }

    onWheel: (wheel) => {
        if (root.sink && root.sink.audio) {
            const step = wheel.angleDelta.y > 0 ? 0.04 : -0.04
            root.sink.audio.volume =
                Math.min(
                    Math.max(root.sink.audio.volume + step, 0),
                    1
                )
        }
    }

                    // Track
                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)

                        // Fill
                        Rectangle {
                            width: parent.width * root.currentVol
                            height: parent.height
                            radius: height / 2
                            color: root.theme.accent

                            Behavior on width {
                                NumberAnimation {
                                    duration: 140
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        // Thumb
                        Rectangle {
                            x: Math.max(0, Math.min(parent.width * root.currentVol - width/2, parent.width - width))
                            anchors.verticalCenter: parent.verticalCenter
                            width: 12
                            height: 12
                            radius: 6
                            color: root.theme.fg
                            border.width: 2
                            border.color: theme.accent
                            visible: sliderArea.containsMouse || sliderArea.pressed

                            Behavior on x {
                                NumberAnimation {
                                    duration: 140
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}