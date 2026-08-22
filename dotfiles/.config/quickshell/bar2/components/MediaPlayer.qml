import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // ============================================================
    // EXTERNAL API
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

    width: parent.width
    height: contentColumn.implicitHeight + 24

    // ============================================================
    // VISIBILITY / REVEAL SEQUENCE
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

    // ============================================================
    // CONTENT
    // ============================================================
    Column {
        id: contentColumn
        width: parent.width - 24
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.top: parent.top
        anchors.topMargin: 12
        spacing: 12

        scale: root.closeProgress
        opacity: root.closeProgress
        transformOrigin: Item.Top

        Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        // ========================================================
        // TOP SECTION – Art + Info side by side
        // ========================================================
        Row {
            width: parent.width
            spacing: 14

            // ---- Album Art ----
            Item {
                width: 100
                height: 100

                Image {
                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: 100
                            height: 100
                            radius: 14
                        }
                    }

                    opacity: root.contentVisible ? 1 : 0
                    scale: root.contentVisible ? 1 : 0.96

                    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
                }
            }

            // ---- Right side: Artist / Title / Controls ----
            Column {
                width: parent.width - 114   // 100 art + 14 spacing
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                // Artist
                Text {
                    width: parent.width
                    text: root.artist !== "" ? root.artist : "Unknown Artist"
                    elide: Text.ElideRight
                    color: root.theme.success || root.theme.inactive
                    font {
                        family: root.theme.font
                        pixelSize: 13
                        weight: root.theme.fontWeight
                    }
                    opacity: root.textVisible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                }

                // Title
                Text {
                    width: parent.width
                    text: root.title
                    elide: Text.ElideRight
                    color: root.theme.fg || root.theme.fg1
                    font {
                        family: root.theme.font
                        pixelSize: 13
                        weight: root.theme.fontWeight
                    }
                    opacity: root.textVisible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                }

    // Controls
Row {
    width: parent.width
    height: 36
    spacing: 4
    anchors.left: parent.left
    anchors.leftMargin: -6        
    opacity: root.controlsVisible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 250 } }

    // Previous
    Item {
        width: 32; height: 32
        HoverItem {
            anchors.centerIn: parent
            iconSize: 22
            textValue: "󰒮"
            hovered: prevMouse.containsMouse
            theme: root.theme
            overrideColor: prevMouse.containsMouse ? root.theme.accent : root.theme.fg
            hoverScale: 1.12
        }
        MouseArea {
            id: prevMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.spotifyControl.command = ["sh", "-c", "playerctl previous"]
                root.spotifyControl.running = true
            }
        }
    }

    // Play / Pause
    Item {
        width: 32; height: 32
        HoverItem {
            anchors.centerIn: parent
            iconSize: 22
            textValue: root.status === "Playing" ? "󰏤" : "󰐊"
            hovered: playMouse.containsMouse
            theme: root.theme
            overrideColor: root.theme.accent
            hoverScale: 1.15
        }
        MouseArea {
            id: playMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.spotifyControl.command = ["sh", "-c", "playerctl play-pause"]
                root.spotifyControl.running = true
            }
        }
    }

    // Next
    Item {
        width: 32; height: 32
        HoverItem {
            anchors.centerIn: parent
            iconSize: 22
            textValue: "󰒭"
            hovered: nextMouse.containsMouse
            theme: root.theme
            overrideColor: nextMouse.containsMouse ? root.theme.accent : root.theme.fg
            hoverScale: 1.12
        }
        MouseArea {
            id: nextMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.spotifyControl.command = ["sh", "-c", "playerctl next"]
                root.spotifyControl.running = true
            }
        }
    }
}
            }
        }
        // ========================================================
        // PROGRESS BAR
        // ========================================================
        Item {
            width: parent.width
            height: 8
            opacity: root.progressVisible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 220 } }

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            Rectangle {
                id: progressFill
                width: parent.width * (root.seeking || root.seekLock ? root.seekPreview : root.progress)
                height: parent.height
                radius: 4
                color: root.progressHovered || root.progressDragging
                       ? root.theme.accent
                       : Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.75)

                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on width {
                    NumberAnimation {
                        duration: root.progressDragging ? 1 : 180
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Rectangle {
                id: seekHandle
                width: root.progressDragging ? 16 : 12
                height: width
                radius: width / 2
                x: (parent.width * (root.seeking || root.seekLock ? root.seekPreview : root.progress)) - width / 2
                y: (parent.height - height) / 2
                visible: root.progressHovered || root.progressDragging
                color: root.progressDragging ? root.theme.accent : root.theme.fg
                opacity: visible ? 1 : 0

                Behavior on width { NumberAnimation { duration: 120 } }
                Behavior on x {
                    NumberAnimation {
                        duration: root.progressDragging ? 1 : 120
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onEntered: root.progressHovered = true
                onExited: if (!pressed) root.progressHovered = false
                onPressed: (mouse) => {
                    root.progressDragging = true
                    root.seeking = true
                    root.seekPreview = Math.max(0, Math.min(1, mouse.x / width))
                }
                onPositionChanged: (mouse) => {
                    if (pressed) root.seekPreview = Math.max(0, Math.min(1, mouse.x / width))
                }
                onReleased: {
                    let target = root.seekPreview * root.length
                    root.seekLock = true
                    root.spotifyControl.command = ["sh", "-c", "playerctl --player=spotify position " + target]
                    root.spotifyControl.running = true
                    seekReleaseTimer.restart()
                    root.progressDragging = false
                    root.seeking = false
                }
            }
        }

        // ========================================================
       // TIMESTAMPS (centered under progress bar)
      // ========================================================
          Text {
             width: parent.width
             horizontalAlignment: Text.AlignHCenter
             text: root.formatTime(root.position) + " / " + root.formatTime(root.length)
             color: root.theme.fg || root.theme.inactive
            font {
                family: root.theme.font
                pixelSize: 12
              }
          opacity: root.progressVisible ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 220 } }
       }
    }
}