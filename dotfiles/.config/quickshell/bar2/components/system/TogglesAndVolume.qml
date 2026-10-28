// components/system/TogglesAndVolume.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects
import "../singletons"

Item {
    id: root

    property var theme
    property bool dndEnabled: false

    signal dndToggled(bool enabled)

    implicitWidth: content.implicitWidth + 28
    implicitHeight: Math.max(content.implicitHeight + 28, 140)   // same height as Storage
    width: parent ? parent.width : implicitWidth
    height: implicitHeight
    
    

    // ============================================================
    // AUDIO STATE (from VolumeCard)
    // ============================================================

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool isHomePod: sink && (sink.name === "study_combined" || sink.description === "Study")
    readonly property real currentVol: sink && sink.audio
        ? Math.min(sink.audio.volume, 1.0)
        : 0.0

    readonly property bool isMuted: sink && sink.audio && sink.audio.muted

    readonly property bool isAirPods: sink && sink.description &&
        (sink.description.includes("AirPods") || sink.description.includes("Airpods"))

    

    // ============================================================
    // TOGGLE BUTTON 
    // ============================================================

    component ToggleButton: MouseArea {
    id: btn

    property string icon: ""
    property string activeIcon: icon
    property bool active: false
    property color accent: theme.accent

    width: 40
    height: 40
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    scale: btn.containsMouse ? 1.08 : 1.0
    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2

        color: btn.active
               ? Qt.rgba(btn.accent.r, btn.accent.g, btn.accent.b, 0.18)
               : (btn.containsMouse ? theme.surfaceAlt : "transparent")

        border.width: 2
        border.color: (btn.active || btn.containsMouse)
                      ? btn.accent
                      : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: btn.active ? btn.activeIcon : btn.icon
        color: (btn.active || btn.containsMouse) ? btn.accent : theme.fg1
        font {
            family: theme.font
            pixelSize: 16
        }
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}

    // ============================================================
    // SHARED CARD
    // ============================================================

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: theme.surface
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        ColumnLayout {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: 14
                rightMargin: 14
            }
            spacing: 16

            // --------------------------------------------------
            // TOGGLES ROW
            // --------------------------------------------------

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                ToggleButton {
                    icon: "󰂯"
                    accent: theme.accent
                    onClicked: {
                        runner.command = ["kitty", "-e", "bluetui"]
                        runner.running = true
                    }
                }

                ToggleButton {
                    icon: "󰖨"
                    activeIcon: "󰖔"
                    active: ToggleState.nightLightEnabled
                    accent: theme.warning
                    onClicked: {
                        ToggleState.nightLightEnabled = !ToggleState.nightLightEnabled
                        runner.command = [
                            "sh", "-c",
                            ToggleState.nightLightEnabled
                                ? "hyprctl hyprsunset temperature 4000 && notify-send 'Night Light' 'On'"
                                : "hyprctl hyprsunset identity && notify-send 'Night Light' 'Off'"
                        ]
                        runner.running = true
                    }
                }

                ToggleButton {
                    icon: "󰂚"
                    activeIcon: "󰂛"
                    active: root.dndEnabled
                    accent: theme.accent
                    onClicked: {
                        root.dndEnabled = !root.dndEnabled
                        root.dndToggled(root.dndEnabled)
                    }
                }

                ToggleButton {
                    icon: "󰅶"
                    activeIcon: "󰾪"
                    active: ToggleState.caffeineEnabled
                    accent: theme.success
                    onClicked: {
                        ToggleState.caffeineEnabled = !ToggleState.caffeineEnabled
                        root.applyCaffeineState()
                        caffeineNotify.command = ["notify-send", "Stay Awake", ToggleState.caffeineEnabled ? "On" : "Off"]
                        caffeineNotify.running = true
                    }
                }

                ToggleButton {
                    icon: "󰕾"
                    accent: theme.accent
                    onClicked: {
                        runner.command = ["kitty", "-e", "wiremix"]
                        runner.running = true
                    }
                }
            }

            // --------------------------------------------------
            // DIVIDER
            // --------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // --------------------------------------------------
            // VOLUME ROW (from VolumeCard.qml, minus its own card)
            // --------------------------------------------------

            RowLayout {
                Layout.fillWidth: true
                visible: root.sink !== null
                spacing: 12

                                Item {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 20
                    implicitHeight: 20

                    readonly property bool showHomePodSvg: root.isHomePod && !root.isMuted

                    // Glyph icon (everything except an unmuted HomePod)
                    Text {
                        anchors.centerIn: parent
                        visible: !parent.showHomePodSvg
                        text: {
                            if (root.isAirPods) return "󱡏"
                            if (root.isMuted || root.currentVol === 0) return "󰖁"
                            if (root.currentVol > 0.66) return "󰕾"
                            if (root.currentVol > 0.33) return "󰖀"
                            return "󰕿"
                        }
                        color: theme.accent
                        font { family: theme.font; pixelSize: 18 }
                    }

                    // HomePod mini SVG, tinted with the theme accent
                    Image {
                        id: homepodImg
                        anchors.fill: parent
                        visible: false
                        source: Qt.resolvedUrl("../../assets/homepod-mini.svg")
                        sourceSize: Qt.size(40, 40)
                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: homepodImg
                        source: homepodImg
                        color: theme.accent
                        visible: parent.showHomePodSvg
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: root.isAirPods ? "AirPods" : "Volume"
                            color: theme.fg
                            font { family: theme.font; pixelSize: 12; weight: Font.Bold }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: Math.round(root.currentVol * 100) + "%"
                            color: theme.inactive
                            font { family: theme.font; pixelSize: 12 }
                        }
                    }

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

                        onClicked: (mouse) => setVolume(mouse.x)
                        onPositionChanged: (mouse) => { if (pressed) setVolume(mouse.x) }
                        onWheel: (wheel) => {
                            if (root.sink && root.sink.audio) {
                                const step = wheel.angleDelta.y > 0 ? 0.04 : -0.04
                                root.sink.audio.volume =
                                    Math.min(Math.max(root.sink.audio.volume + step, 0), 1)
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)

                            Rectangle {
                                width: parent.width * root.currentVol
                                height: parent.height
                                radius: height / 2
                                color: theme.accent
                                Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                            }

                            Rectangle {
                                x: Math.max(0, Math.min(parent.width * root.currentVol - width/2, parent.width - width))
                                anchors.verticalCenter: parent.verticalCenter
                                width: 12
                                height: 12
                                radius: 6
                                color: theme.fg
                                border.width: 2
                                border.color: theme.accent
                                visible: sliderArea.containsMouse || sliderArea.pressed
                                Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                            }
                        }
                    }
                }
            }
        }
    }

    // ============================================================
    // NON-VISUAL: PROCESSES, CAFFEINE LOGIC
    // ============================================================

    Process { id: runner }
    Process { id: caffeineProc }
    Process { id: caffeineNotify }

    function applyCaffeineState() {
        if (ToggleState.caffeineEnabled) {
            caffeineProc.command = [
                "systemd-inhibit",
                "--what=idle:sleep",
                "--who=Quickshell",
                "--why=Caffeine mode enabled",
                "--mode=block",
                "sleep",
                "infinity"
            ]
            caffeineProc.running = true
        } else {
            runner.command = ["pkill", "-f", "Caffeine mode enabled"]
            runner.running = true
            caffeineProc.running = false
        }
    }

    Connections {
        target: ToggleState
        function onBootCheckedChanged() {
            if (ToggleState.bootChecked && ToggleState.caffeineEnabled) {
                root.applyCaffeineState()
            }
        }
    }
}