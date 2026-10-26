import QtQuick
import Quickshell.Hyprland

Item {
    id: root

    property var theme
    property var detector

    property int activeWs: Hyprland.focusedWorkspace?.id ?? 1
    property int hoveredIdx: -1

    // Workspace labels, indexed by (workspace id - 1)
    readonly property var kanji: ["一", "二", "三", "四", "五", "六"]

    width: 184
    height: 30

    // ============================================================
    // GLOBAL MOUSE ZONE
    // ============================================================
    MouseArea {
        id: masterWorkspaceMouse

        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true

        // --------------------------------------------------------
        // ENTER ZONE
        // --------------------------------------------------------
        onEntered: {
            // Instantly kill the countdown so the bar stays warm and open
            if (typeof hoverDebounceTimer !== "undefined") {
                hoverDebounceTimer.stop()
            }
            if (detector) detector.activeHover = true
        }

        // --------------------------------------------------------
        // EXIT ZONE (FIXED: Stops Edge Collapse & Launcher Flickering)
        // --------------------------------------------------------
        onExited: {
            root.hoveredIdx = -1

            // CRITICAL FIX: Do NOT set detector.activeHover = false here!
            // Instead, start the central debounce timer so transitioning to the
            // launcher button or empty space gives a smooth 200ms handoff.
            if (typeof hoverDebounceTimer !== "undefined") {
                hoverDebounceTimer.start()
            }
        }

        // --------------------------------------------------------
        // POSITION TRACKING (Perfect Coordinate Clamping)
        // --------------------------------------------------------
        onPositionChanged: function(mouse) {
            // Secure the bar open while actively moving anywhere inside the 184px box
            if (typeof hoverDebounceTimer !== "undefined" && hoverDebounceTimer.running) {
                hoverDebounceTimer.stop()
            }

            if (detector && !detector.activeHover) {
                detector.activeHover = true
            }

            const localX = mouse.x - wsRow.x
            const itemWidthPlusSpacing = 32
            const targetIndex = Math.floor(localX / itemWidthPlusSpacing)

            if (targetIndex >= 0 && targetIndex < 6) {
                const internalX = localX % itemWidthPlusSpacing
                if (internalX >= 0 && internalX <= 24) {
                    root.hoveredIdx = targetIndex
                    return
                }
            }
            root.hoveredIdx = -1
        }

        // --------------------------------------------------------
        // PRESS STREAM MONITOR
        // --------------------------------------------------------
        onPressedChanged: {
            if (detector && !detector.activeHover) {
                detector.activeHover = true
            }

            if (pressed) {
                const localX = mouseX - wsRow.x
                const itemWidthPlusSpacing = 32
                const targetIndex = Math.floor(localX / itemWidthPlusSpacing)

                if (targetIndex >= 0 && targetIndex < 6) {
                    const internalX = localX % itemWidthPlusSpacing
                    if (internalX >= 0 && internalX <= 24) {
                        const wsId = targetIndex + 1
                        Hyprland.dispatch(`hl.dsp.focus({ workspace = "${wsId}" })`)
                    }
                }
            }
        }
    }

    // ============================================================
    // VISUAL ROW (Centered & Stable)
    // ============================================================
    Row {
        id: wsRow

        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: [1, 2, 3, 4, 5, 6]

            delegate: Item {
                id: wsItem
                width: 24
                height: 24

                property int wsId: modelData
                property bool isActive: root.activeWs === wsId
                property bool isHovered: root.hoveredIdx === index

                Rectangle {
                    id: circle
                    anchors.fill: parent
                    radius: width / 2

                    color: wsItem.isActive   ? root.theme.accent
                         : wsItem.isHovered  ? root.theme.surfaceAlt
                         : root.theme.inactive

                    opacity: wsItem.isActive  ? 1.0
                           : wsItem.isHovered ? 0.9
                           : 0.6

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on opacity { NumberAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: root.kanji[wsItem.wsId - 1]
                        color: wsItem.isActive ? root.theme.bg : root.theme.fg

                        font {
                            family: root.theme.font
                            pixelSize: 12
                            bold: false
                        }
                    }
                }
            }
        }
    }
}
