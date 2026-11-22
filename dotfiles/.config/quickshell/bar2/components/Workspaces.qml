import QtQuick
import Quickshell.Hyprland

Item {
    id: root

    property var theme
    property var detector

    property int activeWs: Hyprland.focusedWorkspace?.id ?? 1
    property int hoveredIdx: -1

    // ---- look ----
    readonly property int count: 6
    readonly property int dotSize: 16 // inactive dot
    readonly property int pillWidth: 30 // active pill
    readonly property int gap: 8
    readonly property int animMs: 160

    implicitWidth: wsRow.implicitWidth + 16
    implicitHeight: 30
    width: implicitWidth
    height: implicitHeight

    // Workspaces Hyprland currently knows about (open windows, or the focused one)
    function isOccupied(id) {
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++)
            if (list[i].id === id)
                return true;
        return false;
    }

    // Which dot is under the pointer; each dot gets half the gap on both sides,
    // so the small targets are still easy to hit.
    function indexAt(x, y) {
        for (let i = 0; i < dots.count; i++) {
            const item = dots.itemAt(i);
            if (!item)
                continue;
            const p = item.mapFromItem(wsMouse, x, y);
            if (p.x >= -root.gap / 2 && p.x <= item.width + root.gap / 2)
                return i;
        }
        return -1;
    }

    // ============================================================
    // MOUSE: one area for the whole widget (keeps the bar's hover handoff)
    // ============================================================
    MouseArea {
        id: wsMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.hoveredIdx >= 0 ? Qt.PointingHandCursor : Qt.ArrowCursor

        onEntered: {
            if (typeof hoverDebounceTimer !== "undefined")
                hoverDebounceTimer.stop();
            if (root.detector)
                root.detector.activeHover = true;
        }

        onExited: {
            root.hoveredIdx = -1;
            // let the bar's debounce decide when to collapse
            if (typeof hoverDebounceTimer !== "undefined")
                hoverDebounceTimer.start();
        }

        onPositionChanged: mouse => {
            if (typeof hoverDebounceTimer !== "undefined" && hoverDebounceTimer.running)
                hoverDebounceTimer.stop();
            if (root.detector && !root.detector.activeHover)
                root.detector.activeHover = true;
            root.hoveredIdx = root.indexAt(mouse.x, mouse.y);
        }

        onClicked: mouse => {
            const i = root.indexAt(mouse.x, mouse.y);
            if (i >= 0)
                Hyprland.dispatch(`hl.dsp.focus({ workspace = "${i + 1}" })`);
        }
    }

    // ============================================================
    // DOTS
    // ============================================================
    Row {
        id: wsRow
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 1
        spacing: root.gap

        Repeater {
            id: dots
            model: root.count

            delegate: Rectangle {
                id: dot
                required property int index
                readonly property int wsId: index + 1
                readonly property bool isActive: root.activeWs === wsId
                readonly property bool isHovered: root.hoveredIdx === index && !isActive
                readonly property bool occupied: root.isOccupied(wsId)

                anchors.verticalCenter: parent.verticalCenter
                width: isActive ? root.pillWidth : root.dotSize
                height: root.dotSize
                radius: height / 2

                color: isActive ? root.theme.accent : root.theme.fg
                // empty workspaces fade back; hover brings a dot forward
                opacity: isActive ? 1.0 : isHovered ? 0.9 : occupied ? 0.55 : 0.25
                scale: isHovered ? 1.25 : 1.0

                Behavior on width {
                    NumberAnimation {
                        duration: root.animMs
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: root.animMs
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animMs
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
