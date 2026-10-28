// components/VolumeModule.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

Item {
    id: root

    required property var theme
    required property var volumeButton

    implicitWidth: 280


    readonly property int visibleOutputCount: volumeButton.sinks.filter(function(node) {
    if (!node)
        return false

    const name = String(node.name || "").toLowerCase()
    const description = String(node.description || "").toLowerCase()

    if (
        name === "raop_sink.study.local.192.168.86.174.7000" ||
        name === "raop_sink.study-2.local.192.168.86.175.7000"
    )
        return false

    if (
        name.includes("alsa_output.pci-0000_2b_00.1") ||
        description.includes("tu104 hd audio controller")
    )
        return false

    return true
}).length

readonly property int requiredHeight: 260 + (visibleOutputCount * 72)

    // ============================================================
    // KEEP SINKS LIVE
    // ============================================================

    PwObjectTracker {
        objects: volumeButton.sinks
    }

    // ============================================================
    // ICON LOGIC
    // ============================================================
    function isAppleTv(node) {
    if (!node)
        return false

    const name = String(node.name || "").toLowerCase()
    const description = String(node.description || "").toLowerCase()

    return description.includes("living room") ||
           description.includes("apple tv") ||
           name.includes("living-room") ||
           name.includes("living_room") ||
           name.includes("appletv") ||
           name.includes("apple-tv")
}

    function getSinkIcon(node) {

        if (!node)
            return "󰋋"

        const name =
            String(node.name || "").toLowerCase()

        const description =
            String(node.description || "").toLowerCase()

        // --------------------------------------------------------
        // AIRPODS / BLUETOOTH
        // --------------------------------------------------------

        if (
            name.startsWith("bluez_output.") ||
            name.includes("airpods") ||
            description.includes("airpods")
        ) {
            return "󱡏"
        }

        // --------------------------------------------------------
        // STUDY COMBINED
        // --------------------------------------------------------

        if (
            name === "study_combined" ||
            description.includes("study (combined)")
        ) {
            return "󰴸"
        }

        // --------------------------------------------------------
        // AIRPLAY / HOMEPODS
        // --------------------------------------------------------

        if (
            name.startsWith("raop_sink.") ||
            name.includes("homepod") ||
            description.includes("homepod") ||
            description === "study" ||
            description === "study (2)"
        ) {
            return "󰴸"
        }

// --------------------------------------------------------
// LOCAL ANALOG OUTPUT
// --------------------------------------------------------

if (name.startsWith("alsa_output.")) {

    const port =
        String(root.detectedActivePort || "").toLowerCase()

    if (
        port.includes("headphone") ||
        port.includes("headset")
    ) {
        return "󰋋"
    }

    if (
        port.includes("lineout") ||
        port.includes("speaker")
    ) {
        return "󰋋"
    }
}
        // --------------------------------------------------------
        // GENERIC BLUETOOTH
        // --------------------------------------------------------

        if (
            name.startsWith("bluez_") ||
            name.includes("bluetooth")
        ) {
            return "󰋋"
        }

        // --------------------------------------------------------
        // FALLBACK
        // --------------------------------------------------------

        return ""
    }

    // ============================================================
    // LABEL
    // ============================================================

    function getSinkLabel(node) {

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
    // SWITCH OUTPUT
    // ============================================================

    Process {
        id: setDefaultProc
    }

    Process {
        id: moveStreamsProc
    }

    function switchTo(node) {

        if (!node)
            return

        // --------------------------------------------------------
        // Quickshell / PipeWire default
        // --------------------------------------------------------

        Pipewire.preferredDefaultAudioSink = node

        // --------------------------------------------------------
        // System default
        // --------------------------------------------------------

        setDefaultProc.command = [
            "wpctl",
            "set-default",
            String(node.id)
        ]

        setDefaultProc.running = true

        // --------------------------------------------------------
        // Move application streams.
        //
        // IMPORTANT:
        // Do NOT move the internal outputs belonging to
        // study_combined.
        // --------------------------------------------------------

        moveStreamsProc.command = [
            "sh",
            "-c",

            `
            target="$1"

            pactl list sink-inputs |
            awk '
                /^Sink Input #/ {
                    id=$3
                    gsub("#","",id)
                }

                /node.name = / {
                    node=$0

                    if (
                        node !~ /output.study_combined_/ &&
                        node !~ /study_combined/
                    ) {
                        print id
                    }
                }
            ' |
            sort -u |
            while read -r id; do
                pactl move-sink-input "$id" "$target" 2>/dev/null
            done
            `,

            "shell",
            String(node.name)
        ]

        moveStreamsProc.running = true
    }

    // ============================================================
    // UI
    // ============================================================

    ColumnLayout {

        anchors.fill: parent
        anchors.margins: 24

        spacing: 20

        // ========================================================
        // HEADER
        // ========================================================

        RowLayout {

            Layout.fillWidth: true

            Text {
                text: "󰕾 Audio Output"

                color: root.theme.fg

                font {
                    family: root.theme.font
                    pixelSize: 22
                    bold: true
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text:
                    volumeButton.muted
                    ? "Muted · " + volumeButton.volumePercent + "%"
                    : volumeButton.volumePercent + "%"

                color: root.theme.fg3

                font {
                    family: root.theme.font
                    pixelSize: 14
                }
            }
        }

        // ========================================================
        // DEVICE CARDS
        // ========================================================

        ColumnLayout {

            Layout.fillWidth: true

            spacing: 12

            component DeviceRow: Rectangle {

                id: rowRoot

                required property var node

                readonly property bool isDefault:
                    node === volumeButton.sink

                readonly property real vol:
                    node.audio ? node.audio.volume : 0

                readonly property bool isMuted:
                    node.audio ? node.audio.muted : false

                Layout.fillWidth: true

                height: 88

                radius: 12

                color:
                    root.theme.bgAlt

                border.width: 1

                border.color:
                    isDefault
                    ? root.theme.accent
                    : Qt.rgba(1, 1, 1, 0.06)

                Behavior on border.color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                // =================================================
                // CARD CLICK
                // =================================================

                MouseArea {

                    anchors.fill: parent

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.switchTo(rowRoot.node)
                }

                // =================================================
                // CONTENT
                // =================================================

                ColumnLayout {

                    anchors.fill: parent

                    anchors.margins: 14

                    spacing: 8

                    // =============================================
                    // TOP ROW
                    // =============================================

                    RowLayout {

                        Layout.fillWidth: true

                        spacing: 12

// -----------------------------------------
// ICON
// -----------------------------------------

Item {
    id: iconBox

    readonly property string glyph: getSinkIcon(rowRoot.node)
    readonly property bool isAppleTv: root.isAppleTv(rowRoot.node)
    readonly property bool isHomePod: glyph === "󰴸" && !isAppleTv
    readonly property color tint:
        rowRoot.isDefault ? root.theme.accent : root.theme.fg

    Layout.preferredWidth: 22
    Layout.preferredHeight: 22
    Layout.alignment: Qt.AlignVCenter

    // Glyph icon for everything except HomePods and Apple TV
    Text {
        anchors.centerIn: parent
        visible: !iconBox.isHomePod && !iconBox.isAppleTv
        text: iconBox.glyph
        color: iconBox.tint
        font {
            family: root.theme.font
            pixelSize: 20
        }
    }

    // HomePod mini SVG, tinted to match
    Image {
        id: homepodImg
        anchors.centerIn: parent
        width: 22
        height: 22
        visible: false
        source: Qt.resolvedUrl("../assets/homepod-mini.svg")
        sourceSize: Qt.size(width * 2, height * 2)
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        anchors.fill: homepodImg
        visible: iconBox.isHomePod
        source: homepodImg
        color: iconBox.tint
    }

    // Apple TV SVG, tinted to match
    Image {
        id: appleTvImg
        anchors.centerIn: parent
        width: 30
        height: 30
        visible: false
        source: Qt.resolvedUrl("../assets/appletv-logo.svg")
        sourceSize: Qt.size(width * 2, height * 2)
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        anchors.fill: appleTvImg
        visible: iconBox.isAppleTv
        source: appleTvImg
        color: iconBox.tint
    }
}
                        // -----------------------------------------
                        // NAME
                        // -----------------------------------------

                        ColumnLayout {

                            spacing: 2

                            Layout.fillWidth: true

                            Text {

                                text:
                                    getSinkLabel(rowRoot.node)

                                color:
                                    rowRoot.isDefault
                                    ? root.theme.accent
                                    : root.theme.fg

                                font {
                                    family: root.theme.font
                                    pixelSize: 15
                                    bold: true
                                }

                                elide:
                                    Text.ElideRight

                                Layout.fillWidth: true
                            }

                            Text {

                                text:
                                    rowRoot.isDefault
                                    ? "Current output"
                                    : "Click to switch"

                                color:
                                    root.theme.fg3

                                font {
                                    family: root.theme.font
                                    pixelSize: 12
                                }
                            }
                        }

                        // -----------------------------------------
                        // MUTE BUTTON
                        // -----------------------------------------

                        Rectangle {

                            width: 36
                            height: 36

                            radius: 8

                            color:
                                muteMouse.containsMouse
                                ? Qt.rgba(
                                    root.theme.accent.r,
                                    root.theme.accent.g,
                                    root.theme.accent.b,
                                    0.15
                                  )
                                : "transparent"

                            border.width: 1

                            border.color:
                                Qt.rgba(1, 1, 1, 0.08)

                            Text {

                                anchors.centerIn: parent

                                text:
                                    rowRoot.isMuted
                                    ? ""
                                    : ""

                                color:
                                    rowRoot.isMuted
                                    ? root.theme.fg3
                                    : root.theme.fg

                                font {
                                    family: root.theme.font
                                    pixelSize: 22
                                }
                            }

                            MouseArea {

                                id: muteMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {

                                    if (rowRoot.node.audio) {

                                        rowRoot.node.audio.muted =
                                            !rowRoot.node.audio.muted
                                    }
                                }
                            }
                        }
                    }

                    // =============================================
                    // VOLUME SLIDER
                    // =============================================

                    RowLayout {

                        Layout.fillWidth: true

                        spacing: 12

                        Slider {

                            id: volSlider

                            Layout.fillWidth: true

                            from: 0
                            to: 1
                            stepSize: 0.005
                            snapMode: Slider.NoSnap
                            value: rowRoot.vol

                            onMoved: {

                                if (rowRoot.node.audio)
                                    rowRoot.node.audio.volume =
                                        value
                            }

                            background: Rectangle {

                                x:
                                    volSlider.leftPadding

                                y:
                                    volSlider.topPadding
                                    + volSlider.availableHeight / 2
                                    - height / 2

                                implicitWidth: 200
                                implicitHeight: 10

                                width:
                                    volSlider.availableWidth

                                height:
                                    implicitHeight

                                radius: 6

                                color:
                                    Qt.rgba(1, 1, 1, 0.08)

                                Rectangle {

                                    width:
                                        volSlider.visualPosition
                                        * parent.width

                                    height:
                                        parent.height

                                    radius: 6

                                    color:
                                        root.theme.accent
                                }
                            }

                            handle: Rectangle {

                                x:
                                    volSlider.leftPadding
                                    + volSlider.visualPosition
                                    * (
                                        volSlider.availableWidth
                                        - width
                                    )

                                y:
                                    volSlider.topPadding
                                    + volSlider.availableHeight / 2
                                    - height / 2

                                implicitWidth: 16
                                implicitHeight: 16

                                radius: 8

                                color:
                                    root.theme.accent

                                border.width: 2

                                border.color:
                                    root.theme.bg
                            }
                        }

                        Text {

                            text:
                                Math.round(rowRoot.vol * 100)
                                + "%"

                            color:
                                root.theme.fg3

                            font {
                                family: root.theme.font
                                pixelSize: 13
                                bold: true
                            }

                            Layout.preferredWidth: 40

                            horizontalAlignment:
                                Text.AlignRight
                        }
                    }
                }
            }

            // =====================================================
            // DEVICE LIST
            // =====================================================

            Repeater {
    model: volumeButton.sinks.filter(function(node) {

        if (!node)
            return false

        const name =
            String(node.name || "").toLowerCase()

        const description =
            String(node.description || "").toLowerCase()

        // Hide individual Study HomePods.
        if (
            name === "raop_sink.study.local.192.168.86.174.7000" ||
            name === "raop_sink.study-2.local.192.168.86.175.7000"
        ) {
            return false
        }

        // Hide NVIDIA HDMI output.
        if (
            name.includes("alsa_output.pci-0000_2b_00.1") ||
            description.includes("tu104 hd audio controller")
        ) {
            return false
        }

        return true
    })

    DeviceRow {
        required property var modelData
        node: modelData
    }
}
        }


        // ========================================================
        // FOOTER
        // ========================================================

        Text {

            Layout.alignment:
                Qt.AlignHCenter

            text:
    root.visibleOutputCount
    + " output"
    + (
        root.visibleOutputCount === 1
        ? ""
        : "s"
      )
    + " available"

            color:
                root.theme.fg3

            font {
                family: root.theme.font
                pixelSize: 13
            }
        }
    }
}