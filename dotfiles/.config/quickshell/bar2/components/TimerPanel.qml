// components/TimerPanel.qml
// One panel for the whole timer: set it up, control it while it runs, and
// dismiss or snooze it when it finishes. Replaces TimerOSD + TimerControlOSD.
//
// Keys: Enter start · Space pause/resume · ↑/↓ ±1 min · Esc close
import QtQuick
import QtQuick.Layouts

FocusScope {
    id: root

    // ── API ─────────────────────────────────────────────────────
    property var theme
    property var timer               // TimerService
    signal closeRequested()

    implicitWidth: 460
    implicitHeight: 250
    focus: true

    property int selectedSeconds: 300
    readonly property var presets: [5, 10, 25, 45]   // minutes

    readonly property string mode: !timer || !timer.active ? "setup"
                                  : timer.finished ? "finished"
                                  : "active"
    readonly property color alertColor: timer && (timer.warning || timer.finished) ? theme.error : theme.accent

    // "5", "5:30", "1:05:00" -> seconds; a bare number means minutes
    function parseTime(text) {
        const parts = text.trim().split(":").map(p => parseInt(p, 10));
        if (parts.some(isNaN) || parts.some(p => p < 0))
            return 0;
        if (parts.length === 1)
            return parts[0] * 60;
        if (parts.length === 2)
            return parts[1] < 60 ? parts[0] * 60 + parts[1] : 0;
        if (parts.length === 3)
            return parts[1] < 60 && parts[2] < 60 ? parts[0] * 3600 + parts[1] * 60 + parts[2] : 0;
        return 0;
    }

    function commitInput() {
        const s = parseTime(timeInput.text);
        if (s > 0)
            selectedSeconds = s;
        timeInput.text = timer.format(selectedSeconds);
    }

    function startSelected() {
        commitInput();
        timer.start(selectedSeconds);
        root.forceActiveFocus();
    }

    function nudge(seconds) {
        if (mode === "setup") {
            selectedSeconds = Math.max(60, selectedSeconds + seconds);
            timeInput.text = timer.format(selectedSeconds);
        } else {
            timer.adjust(seconds);
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.closeRequested();
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (mode === "setup")
                startSelected();
            else if (mode === "finished")
                timer.cancel();
            else
                timer.toggle();
        } else if (event.key === Qt.Key_Space && mode === "active") {
            timer.toggle();
        } else if (event.key === Qt.Key_Up) {
            nudge(60);
        } else if (event.key === Qt.Key_Down) {
            nudge(-60);
        } else {
            return;
        }
        event.accepted = true;
    }

    onModeChanged: {
        if (mode === "setup") {
            timeInput.text = timer.format(selectedSeconds);
            Qt.callLater(() => { timeInput.forceActiveFocus(); timeInput.selectAll(); });
        } else {
            root.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        timeInput.text = timer ? timer.format(selectedSeconds) : "05:00";
        if (mode === "setup")
            Qt.callLater(() => { timeInput.forceActiveFocus(); timeInput.selectAll(); });
    }

    // ── Building blocks ─────────────────────────────────────────
    component Icon: Text {
        property string name
        text: name
        font { family: "Material Symbols Outlined"; pixelSize: 22 }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // Pill button: tonal by default, filled when `primary`.
    // Inline components can't see this file's ids, so each one is given the theme.
    component Pill: Rectangle {
        id: pill
        property var theme
        property string label
        property string icon
        property bool primary: false
        property bool selected: false
        signal clicked()

        implicitWidth: label === "" ? implicitHeight : row.implicitWidth + 26
        implicitHeight: 38
        radius: height / 2
        color: primary ? pill.theme.accent
             : selected ? Qt.rgba(pill.theme.accent.r, pill.theme.accent.g, pill.theme.accent.b, 0.22)
             : pillMouse.containsMouse ? Qt.lighter(pill.theme.surfaceAlt, 1.25) : pill.theme.surfaceAlt
        border.width: selected ? 1 : 0
        border.color: pill.theme.accent
        scale: pillMouse.pressed ? 0.96 : 1.0
        opacity: primary && pillMouse.containsMouse ? 0.9 : 1.0
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 90 } }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6
            Icon {
                visible: pill.icon !== ""
                name: pill.icon
                font.pixelSize: 18
                color: pill.primary ? pill.theme.bg : pill.selected ? pill.theme.accent : pill.theme.fg1
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                visible: pill.label !== ""
                text: pill.label
                color: pill.primary ? pill.theme.bg : pill.selected ? pill.theme.accent : pill.theme.fg
                font { family: pill.theme.font; pixelSize: 13; weight: Font.DemiBold }
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.clicked()
        }
    }

    // ── Layout ──────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 14

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                implicitWidth: 38
                implicitHeight: 38
                radius: 19
                color: Qt.rgba(root.alertColor.r, root.alertColor.g, root.alertColor.b, 0.16)
                Behavior on color { ColorAnimation { duration: 200 } }
                Icon {
                    anchors.centerIn: parent
                    name: root.mode === "finished" ? "alarm" : root.mode === "active" && !root.timer.running ? "timer_pause" : "timer"
                    color: root.alertColor
                }
            }

            ColumnLayout {
                spacing: 0
                Text {
                    text: "Timer"
                    color: root.theme.fg
                    font { family: root.theme.font; pixelSize: 18; bold: true }
                }
                Text {
                    text: root.mode === "setup" ? "Set a countdown"
                        : root.mode === "finished" ? root.timer.formatLong(root.timer.duration) + " timer finished"
                        : root.timer.running ? "Ends at " + root.timer.endsAtText
                        : "Paused"
                    color: root.theme.fg1
                    font { family: root.theme.font; pixelSize: 12 }
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                radius: 15
                color: closeMouse.containsMouse ? root.theme.surfaceAlt : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                Icon { anchors.centerIn: parent; name: "close"; font.pixelSize: 18; color: root.theme.fg1 }
                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeRequested()
                }
            }
        }

        // Big time: editable in setup, live countdown otherwise
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 60

            TextInput {
                id: timeInput
                anchors.centerIn: parent
                visible: root.mode === "setup"
                color: root.theme.fg
                selectionColor: Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.35)
                selectedTextColor: root.theme.fg
                selectByMouse: true
                horizontalAlignment: TextInput.AlignHCenter
                font { family: root.theme.font; pixelSize: 52; weight: Font.DemiBold; features: { "tnum": 1 } }
                validator: RegularExpressionValidator { regularExpression: /^[0-9:]{0,8}$/ }
                onAccepted: root.startSelected()
                onEditingFinished: root.commitInput()
            }

            Text {
                id: countdown
                anchors.centerIn: parent
                visible: root.mode !== "setup"
                text: root.mode === "finished" ? "Time's up" : root.timer ? root.timer.format(root.timer.remaining) : ""
                color: root.mode === "finished" || (root.timer && root.timer.warning) ? root.theme.error
                     : root.timer && !root.timer.running ? root.theme.fg1 : root.theme.fg
                font { family: root.theme.font; pixelSize: root.mode === "finished" ? 40 : 52; weight: Font.DemiBold; features: { "tnum": 1 } }
                Behavior on color { ColorAnimation { duration: 200 } }

                // Gentle pulse once finished
                SequentialAnimation on opacity {
                    running: root.mode === "finished"
                    loops: Animation.Infinite
                    alwaysRunToEnd: true
                    NumberAnimation { to: 0.45; duration: 700; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                }
            }

            // Scroll anywhere on the time to change it by a minute
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: wheel => root.nudge(wheel.angleDelta.y > 0 ? 60 : -60)
            }
        }

        // Progress (hidden while setting up, so presets sit in its place)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            visible: root.mode !== "setup"
            radius: 3
            color: root.theme.surfaceAlt
            Rectangle {
                width: parent.width * (root.timer ? root.timer.progress : 0)
                height: parent.height
                radius: 3
                color: root.alertColor
                Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        Item { Layout.fillHeight: true }

        // Setup: presets + start
        RowLayout {
            Layout.fillWidth: true
            visible: root.mode === "setup"
            spacing: 6
            Repeater {
                model: root.presets
                Pill {
                    theme: root.theme
                    label: modelData + " min"
                    selected: root.selectedSeconds === modelData * 60
                    onClicked: {
                        root.selectedSeconds = modelData * 60;
                        timeInput.text = root.timer.format(root.selectedSeconds);
                    }
                }
            }
            Item { Layout.fillWidth: true }
            Pill {
                theme: root.theme
                primary: true
                icon: "play_arrow"
                label: "Start"
                onClicked: root.startSelected()
            }
        }

        // Running / paused: −1 · play/pause · +1 · stop
        RowLayout {
            Layout.fillWidth: true
            visible: root.mode === "active"
            spacing: 8
            Pill {
                theme: root.theme; icon: "remove"; label: "1 min"; onClicked: root.timer.adjust(-60) }
            Pill {
                theme: root.theme; icon: "add"; label: "1 min"; onClicked: root.timer.adjust(60) }
            Item { Layout.fillWidth: true }
            Pill {
                theme: root.theme; icon: "stop"; onClicked: root.timer.cancel() }   // cancel
            Pill {
                theme: root.theme
                primary: true
                icon: root.timer && root.timer.running ? "pause" : "play_arrow"
                label: root.timer && root.timer.running ? "Pause" : "Resume"
                onClicked: root.timer.toggle()
            }
        }

        // Finished: snooze or dismiss
        RowLayout {
            Layout.fillWidth: true
            visible: root.mode === "finished"
            spacing: 8
            Pill {
                theme: root.theme; icon: "snooze"; label: "1 more min"; onClicked: root.timer.snooze(60) }
            Item { Layout.fillWidth: true }
            Pill {
                theme: root.theme
                primary: true
                icon: "check"
                label: "Dismiss"
                onClicked: { root.timer.cancel(); root.closeRequested(); }
            }
        }
    }
}
