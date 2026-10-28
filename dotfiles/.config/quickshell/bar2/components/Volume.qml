// components/Volume.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // ============================================================
    // PROPERTIES
    // ============================================================

    required property var theme

    signal clicked()

    property bool hovered: false

    implicitWidth: volumeRow.implicitWidth + 12
    implicitHeight: 30
    height: 30


    // ============================================================
    // DEFAULT SINK
    // ============================================================

    readonly property var sink:
        Pipewire.defaultAudioSink

    readonly property bool hasSink:
        sink !== null &&
        sink.audio !== null

    readonly property real volume:
        hasSink
            ? sink.audio.volume
            : 0

    readonly property bool muted:
        hasSink
            ? sink.audio.muted
            : false

    readonly property int volumePercent:
        Math.round(volume * 100)


    // ============================================================
    // TRACK CURRENT SINK
    // ============================================================

    PwObjectTracker {
        objects:
            root.sink
                ? [root.sink]
                : []
    }


    // ============================================================
    // AVAILABLE SINKS
    // ============================================================

    readonly property var sinks: {

        const list = []

        for (const node of Pipewire.nodes.values) {

            if (!node)
                continue

            if (!node.isSink)
                continue

            if (!node.audio)
                continue

            if (node.isStream)
                continue

            const name =
                String(node.name || "").toLowerCase()

            // Ignore internal combine-stream outputs
            if (name.startsWith("output.study_combined_"))
                continue

            // Ignore monitor nodes
            if (name.includes(".monitor"))
                continue

            list.push(node)
        }

        return list
    }

    PwObjectTracker {
        objects: root.sinks
    }


    // ============================================================
    // ACTIVE PHYSICAL PORT
    //
    // PipeWire's QML API does not reliably expose the active ALSA
    // port, so pactl is used for this specific piece of information.
    //
    // Examples:
    //
    //   analog-output-headphones
    //   analog-output-lineout
    //
    // AirPods do not have an ALSA port, so this will simply be empty
    // when AirPods are the current output.
    // ============================================================

    property string detectedActivePort: ""


    // ============================================================
    // CHECK ACTIVE PORT
    // ============================================================

    Process {
        id: portCheck

        command: [
            "sh",
            "-c",
            "pactl list sinks | " +
            "sed -n '/Name: '\"$(pactl get-default-sink)\"'/,/^$/p' | " +
            "awk -F': ' '/Active Port:/ {print $2; exit}'"
        ]

        stdout: StdioCollector {

            onTextChanged: {

                const port =
                    text.trim()

                if (root.detectedActivePort !== port) {

                    root.detectedActivePort = port

                    console.log(
                        "DETECTED ACTIVE PORT:",
                        root.detectedActivePort
                    )

                    console.log(
                        "CURRENT ICON:",
                        root.outputIcon
                    )
                }
            }
        }
    }


    // ============================================================
    // REFRESH ACTIVE PORT
    //
    // The short delay is intentional.
    //
    // When switching sinks, PipeWire can update the default sink
    // before pactl has updated the active ALSA port.
    // ============================================================

    Timer {
        id: portRefreshTimer

        interval: 250
        repeat: false

        onTriggered: {
            portCheck.running = false
            portCheck.running = true
        }
    }


    function refreshActivePort() {
        portRefreshTimer.restart()
    }


    // ============================================================
    // OUTPUT ICON
    // ============================================================

    readonly property string outputIcon: {

        if (!root.sink)
            return "󰕾"

        const name =
            String(root.sink.name || "").toLowerCase()

        const description =
            String(root.sink.description || "").toLowerCase()

        const port =
            String(root.detectedActivePort || "").toLowerCase()


        // --------------------------------------------------------
        // AIRPODS
        // --------------------------------------------------------

        if (
            name.startsWith("bluez_output.") ||
            name.includes("airpods") ||
            description.includes("airpods")
        ) {
            return "󱡏"
        }


        // --------------------------------------------------------
        // GENERIC BLUETOOTH HEADPHONES
        // --------------------------------------------------------

        if (
            name.startsWith("bluez_") ||
            name.includes("bluetooth") ||
            description.includes("bluetooth")
        ) {
            return "󰋋"
        }


        // --------------------------------------------------------
        // HOME PODS / AIRPLAY
        // --------------------------------------------------------

        if (
            name.startsWith("raop_sink.") ||
            name.includes("homepod") ||
            description.includes("homepod") ||
            description === "study"
        ) {
            return "󰴸"
        }


        // --------------------------------------------------------
        // STUDY COMBINED
        // --------------------------------------------------------

        if (
            name === "study_combined" ||
            description === "study (combined)"
        ) {
            return "󰴸"
        }


        // --------------------------------------------------------
        // PHYSICAL HEADPHONES
        //
        // The ALSA sink name remains unchanged when headphones
        // are plugged in.
        //
        // Therefore we use the pactl-detected active port.
        // --------------------------------------------------------

        if (
            port.includes("headphone") ||
            port.includes("headset")
        ) {
            return "󰋋"
        }


        // --------------------------------------------------------
        // PHYSICAL SPEAKERS / LINE OUT
        // --------------------------------------------------------

        if (
            port.includes("lineout") ||
            port.includes("line-out") ||
            port.includes("speaker")
        ) {
            return "󰋋"
        }


        // --------------------------------------------------------
        // DEFAULT
        // --------------------------------------------------------

        return "󰕾"
    }

    readonly property bool isHomePod: outputIcon === "󰴸"
    readonly property bool showHomePodSvg: isHomePod && !muted

    // ============================================================
    // LABEL
    // ============================================================

    function sinkLabel(node) {

        if (!node)
            return "No output"

        return (
            node.description ||
            node.nickname ||
            node.name ||
            "Unknown"
        )
    }


    // ============================================================
    // SET DEFAULT
    // ============================================================

    function setDefault(node) {

        if (!node)
            return

        console.log(
            "SWITCHING AUDIO OUTPUT:",
            node.name
        )

        Pipewire.preferredDefaultAudioSink = node

        // Refresh after PipeWire has had time to settle.
        refreshActivePort()
    }


    // ============================================================
    // BACKGROUND
    // ============================================================

    Rectangle {
        anchors.fill: parent

        radius: height / 2

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
    // BAR CONTENT
    // ============================================================

    Row {
        id: volumeRow

        anchors.centerIn: parent

        spacing: 6


// --------------------------------------------------------
// ICON
// --------------------------------------------------------

Item {
    width: 18
    height: 18
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 1

    // Glyph icon (everything except the HomePod)
    Text {
        anchors.centerIn: parent
        visible: !root.showHomePodSvg
        text: root.muted ? "" : root.outputIcon
        color: root.muted ? root.theme.fg3 : root.theme.accent
        font.family: root.theme.font
        font.pixelSize: 18
    }

    // HomePod mini SVG, tinted with the theme accent
    Image {
        id: homepodImg
        anchors.fill: parent
        visible: false
        source: Qt.resolvedUrl("../assets/homepod-mini.svg")
        sourceSize: Qt.size(40, 40)       // 2x for a crisp render
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        anchors.fill: parent
        visible: root.showHomePodSvg
        source: homepodImg
        color: root.theme.accent
    }
}

        // --------------------------------------------------------
        // VOLUME
        // --------------------------------------------------------

        Text {
            text:
                root.volumePercent + "%"

            color:
                root.muted
                    ? root.theme.fg3
                    : root.theme.fg

            font.family: root.theme.font

            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1 
        }
    }


    // ============================================================
    // MOUSE
    // ============================================================

    MouseArea {
        id: volumeMouseArea

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor

        acceptedButtons:
            Qt.LeftButton |
            Qt.RightButton |
            Qt.MiddleButton


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

            root.sink.audio.volume =
                Math.max(
                    0.0,
                    Math.min(
                        1.0,
                        root.volume + step
                    )
                )
        }


        // --------------------------------------------------------
        // CLICK
        // --------------------------------------------------------

        onClicked: function(mouse) {

            // Middle click = mute
            if (mouse.button === Qt.MiddleButton) {

                if (root.hasSink) {
                    root.sink.audio.muted =
                        !root.sink.audio.muted
                }

                return
            }

            // Parent handles the volume panel.
            root.clicked()
        }
    }
}