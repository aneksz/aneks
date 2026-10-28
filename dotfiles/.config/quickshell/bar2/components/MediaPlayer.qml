import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

// Replaces the media player content file you attached.
// Same external API as before, plus two optional cava inputs:
//   cavaValues  - array of 0..100 values (the bar's cava, any length)
//   cavaPlaying - bool, true while audio is actually playing
Item {
    id: root

    // ============================================================
    // EXTERNAL API (unchanged)
    // ============================================================
    property string track: ""
    property string artUrl: ""
    property real position: 0
    property real length: 0
    property real closeProgress: 1.0
    property var theme
    property var spotifyControl

    property string status: "Paused"
    readonly property int islandStateCollapsed: 0
    readonly property int islandStateExpanded: 1
    readonly property int islandStateClosing: 2
    property int islandState: islandStateCollapsed
    signal closingFinished()

    // New: shared cava data from the bar
    property var cavaValues: []
    property bool cavaPlaying: false

    // ============================================================
    // ANIMATION STATE
    // ============================================================
    property bool contentVisible: false
    property bool textVisible: false
    property bool controlsVisible: false
    property bool labelVisible: false
    property bool progressVisible: false
    property bool progressHovered: false
    property bool progressDragging: false
    property real seekPreview: 0
    property bool seeking: false
    property bool seekLock: false

    // Local player state (polled with playerctl while visible)
    property bool shuffleOn: false
    property string loopMode: "None"      // None | Track | Playlist
    readonly property string player: "spotify"   // only Spotify is controlled
    readonly property string sourceName: "󰓇 Spotify"

    property int artSize: 160            // the hub's Media tab uses a bigger cover
    property real textScale: 1.0         // scales title + artist text
    property int infoSpacing: 4          // gap between the rows next to the cover
    property real controlScale: 1.0      // scales controls, timestamps, seek bar, source pill, cava

    width: parent.width
    height: body.height + 24
    implicitWidth: 360
    implicitHeight: body.height + 24   // wrapper can bind its height to this

    // ============================================================
    // VISIBILITY / REVEAL SEQUENCE (same behaviour as before)
    // ============================================================
    onIslandStateChanged: {
        if (root.islandState === root.islandStateExpanded) {
            if (root.contentVisible) return
            root.contentVisible = false
            root.textVisible = false
            root.progressVisible = false
            root.controlsVisible = false
            root.labelVisible = false
            contentRevealTimer.restart()
            textRevealTimer.restart()
            progressRevealTimer.restart()
            controlsRevealTimer.restart()
            labelRevealTimer.restart()
            stateTimer.restart()
        }
        if (root.islandState === root.islandStateClosing) {
            labelCloseTimer.restart()
            controlsCloseTimer.restart()
            progressCloseTimer.restart()
            textCloseTimer.restart()
            contentCloseTimer.restart()
        }
    }

    Timer { id: seekReleaseTimer; interval: 900; repeat: false; onTriggered: root.seekLock = false }

    Timer { id: contentRevealTimer;  interval: 300; repeat: false; onTriggered: root.contentVisible = true }
    Timer { id: textRevealTimer;     interval: 400; repeat: false; onTriggered: root.textVisible = true }
    Timer { id: progressRevealTimer; interval: 520; repeat: false; onTriggered: root.progressVisible = true }
    Timer { id: controlsRevealTimer; interval: 600; repeat: false; onTriggered: root.controlsVisible = true }
    Timer { id: labelRevealTimer;    interval: 700; repeat: false; onTriggered: root.labelVisible = true }

    Timer { id: labelCloseTimer;     interval: 120; repeat: false; onTriggered: root.labelVisible = false }
    Timer { id: controlsCloseTimer;  interval: 200; repeat: false; onTriggered: root.controlsVisible = false }
    Timer { id: progressCloseTimer;  interval: 280; repeat: false; onTriggered: root.progressVisible = false }
    Timer { id: textCloseTimer;      interval: 360; repeat: false; onTriggered: root.textVisible = false }
    Timer { id: contentCloseTimer;   interval: 500; repeat: false; onTriggered: { root.contentVisible = false; root.closingFinished() } }

    // ============================================================
    // PLAYER STATE POLLING (shuffle / loop / source)
    // ============================================================
    Timer {
        id: stateTimer
        interval: 2000
        repeat: true
        running: root.contentVisible
        triggeredOnStart: true
        onTriggered: {
            shuffleProc.running = true
            loopProc.running = true
        }
    }

    Process {
        id: shuffleProc
        command: ["playerctl", "--player=spotify", "shuffle"]
        stdout: StdioCollector { onStreamFinished: root.shuffleOn = text.trim() === "On" }
    }
    Process {
        id: loopProc
        command: ["playerctl", "--player=spotify", "loop"]
        stdout: StdioCollector { onStreamFinished: root.loopMode = text.trim() || "None" }
    }
    // One-shot commands (shuffle / loop); refresh state shortly after
    Process { id: ctrlProc }
    Timer { id: refreshTimer; interval: 250; onTriggered: { shuffleProc.running = true; loopProc.running = true } }

    function ctrl(cmd) {
        ctrlProc.command = cmd
        ctrlProc.running = true
        refreshTimer.restart()
    }

    function cycleLoop() {
        const next = root.loopMode === "None" ? "Playlist"
                   : root.loopMode === "Playlist" ? "Track" : "None"
        ctrl(["playerctl", "--player=spotify", "loop", next])
    }

    // ============================================================
    // DERIVED DATA
    // ============================================================
    property string artist: {
        let parts = track.split(" - ")
        return parts.length > 1 ? parts[0] : ""
    }
    property string title: {
        let parts = track.split(" - ")
        return parts.length > 1 ? parts.slice(1).join(" - ") : track
    }
    property real progress: length > 0 ? position / length : 0

    function formatTime(sec) {
        let s = Math.floor(sec % 60)
        let m = Math.floor(sec / 60)
        return m + ":" + (s < 10 ? "0" + s : s)
    }

    function glyph(code) { return String.fromCodePoint(code) }

    // Linear-interpolate the bar's cava values up/down to n bars (0..1)
    function barValue(i, n) {
        const v = root.cavaValues
        if (!root.cavaPlaying || root.status !== "Playing" || !v || v.length === 0)
            return 0
        const p = n > 1 ? i * (v.length - 1) / (n - 1) : 0
        const a = Math.floor(p)
        const b = Math.min(a + 1, v.length - 1)
        const f = p - a
        return Math.max(0, Math.min(1, (v[a] * (1 - f) + v[b] * f) / 100))
    }

    // ============================================================
    // CONTENT
    // ============================================================
    Item {
        id: body
        x: 12
        y: 12
        width: parent.width - 24
        height: Math.max(root.artSize, info.implicitHeight)

        scale: root.closeProgress
        opacity: root.closeProgress
        transformOrigin: Item.Top
        Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        // ---- Album art ----
        Item {
            id: artBox
            width: root.artSize
            height: root.artSize
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: 16
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            Image {
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: root.artSize
                        height: root.artSize
                        radius: 16
                    }
                }

                opacity: root.contentVisible ? 1 : 0
                scale: root.contentVisible ? 1 : 0.96
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
            }
        }

        // ---- Info column ----
        Column {
            id: info
            x: root.artSize + 14
            width: parent.width - x
            anchors.verticalCenter: parent.verticalCenter
            spacing: root.infoSpacing

        // Source pill
        Rectangle {
           readonly property int pad: 8

            visible: root.sourceName !== ""
            x: -pad     
            height: Math.round(18 * root.controlScale)
            width: sourceText.implicitWidth + pad * 2
            radius: height / 2
            color: Qt.rgba(1, 1, 1, 0.08)
            opacity: root.labelVisible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        Text {
            id: sourceText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.pad
            text: root.sourceName
            color: root.theme.fg
            font { family: root.theme.font; pixelSize: Math.round(10 * root.controlScale); bold: true }
            }
        }

            // Title
            Text {
                width: parent.width
                text: root.title
                elide: Text.ElideRight
                color: root.theme.fg0 || root.theme.fg
                font { family: root.theme.font; pixelSize: Math.round(15 * root.textScale); bold: true }
                opacity: root.textVisible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }

            // Artist
            Text {
                width: parent.width
                text: root.artist !== "" ? root.artist : "Unknown Artist"
                elide: Text.ElideRight
                color: root.theme.success || root.theme.accent
                font { family: root.theme.font; pixelSize: Math.round(12 * root.textScale); weight: root.theme.fontWeight }
                opacity: root.textVisible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }

            // Progress bar (thin, with a bigger hit area)
            Item {
                width: parent.width
                height: Math.round(12 * root.controlScale)
                opacity: root.progressVisible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 220 } }

                readonly property real shown: root.seeking || root.seekLock ? root.seekPreview : root.progress

                Rectangle {
                    id: barTrack
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: root.progressHovered || root.progressDragging ? Math.round(6 * root.controlScale) : Math.round(4 * root.controlScale)
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.10)
                    Behavior on height { NumberAnimation { duration: 120 } }

                    Rectangle {
                        width: barTrack.width * parent.parent.shown
                        height: parent.height
                        radius: parent.radius
                        color: root.theme.accent
                        Behavior on width {
                            NumberAnimation {
                                duration: root.progressDragging ? 1 : 180
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: root.progressHovered = true
                    onExited: if (!pressed) root.progressHovered = false
                    onPressed: mouse => {
                        root.progressDragging = true
                        root.seeking = true
                        root.seekPreview = Math.max(0, Math.min(1, mouse.x / width))
                    }
                    onPositionChanged: mouse => {
                        if (pressed) root.seekPreview = Math.max(0, Math.min(1, mouse.x / width))
                    }
                    onReleased: {
                        const target = root.seekPreview * root.length
                        root.seekLock = true
                        root.spotifyControl.command = ["playerctl", "--player=spotify", "position", String(target)]
                        root.spotifyControl.running = true
                        seekReleaseTimer.restart()
                        root.progressDragging = false
                        root.progressHovered = containsMouse
                        root.seeking = false
                    }
                }
            }

            // Timestamps
            Item {
                width: parent.width
                height: Math.round(14 * root.controlScale)
                opacity: root.progressVisible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 220 } }

                Text {
                    anchors.left: parent.left
                    text: root.formatTime(root.seeking || root.seekLock ? root.seekPreview * root.length : root.position)
                    color: root.theme.textMuted || root.theme.inactive
                    font { family: root.theme.font; pixelSize: Math.round(10 * root.controlScale) }
                }
                Text {
                    anchors.right: parent.right
                    text: root.formatTime(root.length)
                    color: root.theme.textMuted || root.theme.inactive
                    font { family: root.theme.font; pixelSize: Math.round(10 * root.controlScale) }
                }
            }

            // Controls: shuffle · prev · play · next · repeat
            RowLayout {
                width: parent.width
                height: Math.round(36 * root.controlScale)
                opacity: root.controlsVisible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 250 } }

                // Shuffle
                Item {
                    Layout.preferredWidth: Math.round(28 * root.controlScale); Layout.preferredHeight: Math.round(28 * root.controlScale)
                    Text {
                        anchors.centerIn: parent
                        text: root.glyph(0xF049F)
                        font { family: root.theme.font; pixelSize: Math.round(16 * root.controlScale) }
                        color: root.shuffleOn ? root.theme.accent
                             : shuffleMouse.containsMouse ? root.theme.fg : root.theme.textMuted
                    }
                    MouseArea {
                        id: shuffleMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.ctrl(["playerctl", "--player=spotify", "shuffle", "Toggle"])
                    }
                }

                Item { Layout.fillWidth: true }

                // Previous
                Item {
                    Layout.preferredWidth: Math.round(32 * root.controlScale); Layout.preferredHeight: Math.round(32 * root.controlScale)
                    Text {
                        anchors.centerIn: parent
                        text: root.glyph(0xF04AE)
                        font { family: root.theme.font; pixelSize: Math.round(22 * root.controlScale) }
                        color: prevMouse.containsMouse ? root.theme.accent : root.theme.fg
                        scale: prevMouse.containsMouse ? 1.12 : 1
                        Behavior on scale { NumberAnimation { duration: 120 } }
                    }
                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.spotifyControl.command = ["playerctl", "--player=spotify", "previous"]
                            root.spotifyControl.running = true
                        }
                    }
                }

                // Play / pause
                Rectangle {
                    Layout.preferredWidth: Math.round(36 * root.controlScale); Layout.preferredHeight: Math.round(36 * root.controlScale)
                    radius: width / 2
                    color: root.theme.accent
                    scale: playMouse.containsMouse ? 1.08 : 1
                    Behavior on scale { NumberAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: root.glyph(root.status === "Playing" ? 0xF03E4 : 0xF040A)
                        font { family: root.theme.font; pixelSize: Math.round(20 * root.controlScale) }
                        color: root.theme.bg
                    }
                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.spotifyControl.command = ["playerctl", "--player=spotify", "play-pause"]
                            root.spotifyControl.running = true
                        }
                    }
                }

                // Next
                Item {
                    Layout.preferredWidth: Math.round(32 * root.controlScale); Layout.preferredHeight: Math.round(32 * root.controlScale)
                    Text {
                        anchors.centerIn: parent
                        text: root.glyph(0xF04AD)
                        font { family: root.theme.font; pixelSize: Math.round(22 * root.controlScale) }
                        color: nextMouse.containsMouse ? root.theme.accent : root.theme.fg
                        scale: nextMouse.containsMouse ? 1.12 : 1
                        Behavior on scale { NumberAnimation { duration: 120 } }
                    }
                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.spotifyControl.command = ["playerctl", "--player=spotify", "next"]
                            root.spotifyControl.running = true
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Repeat (None -> Playlist -> Track)
                Item {
                    Layout.preferredWidth: Math.round(28 * root.controlScale); Layout.preferredHeight: Math.round(28 * root.controlScale)
                    Text {
                        anchors.centerIn: parent
                        text: root.glyph(root.loopMode === "Track" ? 0xF0458 : 0xF0456)
                        font { family: root.theme.font; pixelSize: Math.round(16 * root.controlScale) }
                        color: root.loopMode !== "None" ? root.theme.accent
                             : repeatMouse.containsMouse ? root.theme.fg : root.theme.textMuted
                    }
                    MouseArea {
                        id: repeatMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cycleLoop()
                    }
                }
            }

            // Cava strip (driven by the bar's cava values)
            Item {
                id: cavaStrip
                width: Math.round(parent.width * 0.6)   // narrower, centred under the controls
                x: Math.round((parent.width - width) / 2)
                height: Math.round(20 * root.controlScale)   // breathing room above the bars
                opacity: root.labelVisible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 250 } }

                readonly property int barH: Math.round(14 * root.controlScale)
                readonly property int barW: 2
                readonly property int gap: 2
                readonly property int count: Math.max(8, Math.floor((width + gap) / (barW + gap)))

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    spacing: cavaStrip.gap

                    Repeater {
                        model: cavaStrip.count

                        Item {
                            required property int index
                            width: cavaStrip.barW
                            height: cavaStrip.barH
                            readonly property real v: root.barValue(index, cavaStrip.count)

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width
                                height: 2 + parent.v * (cavaStrip.barH - 2)
                                radius: width / 2
                                color: root.theme.accent
                                opacity: 0.45 + parent.v * 0.55
                                Behavior on height { NumberAnimation { duration: 70 } }
                            }
                        }
                    }
                }
            }
        }
    }
}
