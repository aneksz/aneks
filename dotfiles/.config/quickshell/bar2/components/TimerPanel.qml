// components/TimerPanel.qml
// One panel for the whole timer, laid out like a phone timer: a ring that
// empties as time runs out, the time in the middle, and round buttons below.
// Set it up, control it while it runs, and dismiss or snooze it when done.
//
// Keys: Enter start · Space pause/resume · ↑/↓ ±1 min · Esc close
import QtQuick
import QtQuick.Shapes

FocusScope {
    id: root

    // ── API ─────────────────────────────────────────────────────
    property var theme
    property var timer               // TimerService
    signal closeRequested()

    implicitWidth: 380
    implicitHeight: 380
    focus: true

    property int selectedSeconds: 300
    readonly property var presets: [5, 10, 25, 45]   // minutes

    readonly property string mode: !timer || !timer.active ? "setup"
                                  : timer.finished ? "finished"
                                  : "active"
    readonly property bool paused: mode === "active" && !timer.running
    readonly property color ringColor: mode === "finished" || (timer && timer.warning) ? theme.error : theme.accent

    function tint(c, a) { return Qt.rgba(c.r, c.g, c.b, a); }

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
    // Inline components can't see this file's ids, so each is given the theme.
    component Icon: Text {
        property string name
        text: name
        font { family: "Material Symbols Outlined"; pixelSize: 22 }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // Big round button, like the phone timer's: grey for cancel, tinted for go
    component RoundButton: Rectangle {
        id: rb
        property var theme
        property string icon
        property color tone: theme ? theme.fg : "white"
        property bool tinted: false
        signal clicked()

        implicitWidth: 58
        implicitHeight: 58
        radius: width / 2
        color: tinted ? Qt.rgba(tone.r, tone.g, tone.b, rbMouse.containsMouse ? 0.32 : 0.22)
                      : rbMouse.containsMouse ? Qt.lighter(theme.surfaceAlt, 1.3) : theme.surfaceAlt
        scale: rbMouse.pressed ? 0.93 : 1.0
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 90 } }

        Text {
            anchors.centerIn: parent
            text: rb.icon
            color: rb.tinted ? rb.tone : rb.theme.fg
            font { family: "Material Symbols Outlined"; pixelSize: 28 }
        }
        MouseArea {
            id: rbMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: rb.clicked()
        }
    }

    // Small chip: presets and ±1 min
    component Chip: Rectangle {
        id: chip
        property var theme
        property string label
        property bool selected: false
        signal clicked()

        implicitWidth: chipText.implicitWidth + 20
        implicitHeight: 30
        radius: height / 2
        color: selected ? Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.22)
             : chipMouse.containsMouse ? Qt.lighter(theme.surfaceAlt, 1.3) : theme.surfaceAlt
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            id: chipText
            anchors.centerIn: parent
            text: chip.label
            color: chip.selected ? chip.theme.accent : chip.theme.fg1
            font { family: chip.theme.font; pixelSize: 12; weight: Font.DemiBold; features: { "tnum": 1 } }
        }
        MouseArea {
            id: chipMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    // ── Ring ────────────────────────────────────────────────────
    Item {
        id: dial
        width: 250
        height: 250
        anchors { top: parent.top; topMargin: 20; horizontalCenter: parent.horizontalCenter }

        readonly property real stroke: 8
        readonly property real r: width / 2 - stroke / 2
        // Fraction of the ring still lit: full while setting up and when done
        readonly property real fraction: root.mode === "active" ? (root.timer ? root.timer.progress : 0) : 1

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            // Track
            ShapePath {
                fillColor: "transparent"
                strokeColor: root.theme.surfaceAlt
                strokeWidth: dial.stroke
                PathAngleArc {
                    centerX: dial.width / 2; centerY: dial.height / 2
                    radiusX: dial.r; radiusY: dial.r
                    startAngle: 0; sweepAngle: 360
                }
            }

            // Time left: from 12 o'clock clockwise; the end retreats towards 12 as time runs out
            ShapePath {
                fillColor: "transparent"
                strokeColor: root.mode === "setup" ? root.tint(root.theme.accent, 0.35)
                           : root.paused ? root.tint(root.ringColor, 0.55) : root.ringColor
                strokeWidth: dial.stroke
                capStyle: ShapePath.RoundCap
                PathAngleArc {
                    id: arc
                    centerX: dial.width / 2; centerY: dial.height / 2
                    radiusX: dial.r; radiusY: dial.r
                    startAngle: -90
                    sweepAngle: 360 * dial.fraction
                    Behavior on sweepAngle { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                }
            }
        }

        // Centre: end time · time · total
        Column {
            anchors.centerIn: parent
            spacing: 4

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4
                Icon {
                    name: root.mode === "setup" ? "timer" : root.mode === "finished" ? "alarm" : root.paused ? "pause" : "notifications"
                    font.pixelSize: 15
                    color: root.theme.fg1
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: root.mode === "setup" ? "Set timer"
                        : root.mode === "finished" ? "Time's up"
                        : root.paused ? "Paused" : root.timer.endsAtText
                    color: root.theme.fg1
                    font { family: root.theme.font; pixelSize: 14; features: { "tnum": 1 } }
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 200
                height: 66

                TextInput {
                    id: timeInput
                    anchors.centerIn: parent
                    visible: root.mode === "setup"
                    color: root.theme.fg
                    selectionColor: root.tint(root.theme.accent, 0.35)
                    selectedTextColor: root.theme.fg
                    selectByMouse: true
                    horizontalAlignment: TextInput.AlignHCenter
                    font { family: root.theme.font; pixelSize: 58; weight: Font.Light; features: { "tnum": 1 } }
                    validator: RegularExpressionValidator { regularExpression: /^[0-9:]{0,8}$/ }
                    onAccepted: root.startSelected()
                    onEditingFinished: root.commitInput()
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.mode !== "setup"
                    text: root.timer ? root.timer.format(root.timer.remaining) : ""
                    color: root.mode === "finished" || (root.timer && root.timer.warning) ? root.theme.error
                         : root.paused ? root.theme.fg1 : root.theme.fg
                    font { family: root.theme.font; pixelSize: root.timer && root.timer.remaining >= 3600 ? 46 : 58; weight: Font.Light; features: { "tnum": 1 } }
                    Behavior on color { ColorAnimation { duration: 200 } }

                    SequentialAnimation on opacity {
                        running: root.mode === "finished"
                        loops: Animation.Infinite
                        alwaysRunToEnd: true
                        NumberAnimation { to: 0.35; duration: 700; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                    }
                }

                // Scroll on the time to change it by a minute
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: wheel => root.nudge(wheel.angleDelta.y > 0 ? 60 : -60)
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.mode === "setup" ? "type or scroll" : root.timer.formatLong(root.timer.duration)
                color: root.mode === "setup" ? root.theme.inactive : root.theme.fg
                font { family: root.theme.font; pixelSize: 14 }
            }
        }
    }

    // ── Controls ────────────────────────────────────────────────
    Item {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 20 }
        height: 58

        // Left: close (setup) / cancel (running) / dismiss (finished)
        RoundButton {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            theme: root.theme
            icon: "close"
            onClicked: {
                if (root.mode === "setup") {
                    root.closeRequested();
                } else if (root.mode === "finished") {
                    root.timer.cancel();
                    root.closeRequested();
                } else {
                    root.timer.cancel();
                }
            }
        }

        // Middle: presets while setting up, ±1 min while running
        Row {
            anchors.centerIn: parent
            spacing: 6
            visible: root.mode === "setup"
            Repeater {
                model: root.presets
                Chip {
                    theme: root.theme
                    label: modelData + "m"
                    selected: root.selectedSeconds === modelData * 60
                    onClicked: {
                        root.selectedSeconds = modelData * 60;
                        timeInput.text = root.timer.format(root.selectedSeconds);
                    }
                }
            }
        }
        Row {
            anchors.centerIn: parent
            spacing: 6
            visible: root.mode !== "setup"
            Chip { theme: root.theme; label: "−1 min"; visible: root.mode === "active"; onClicked: root.timer.adjust(-60) }
            Chip { theme: root.theme; label: "+1 min"; onClicked: root.mode === "finished" ? root.timer.snooze(60) : root.timer.adjust(60) }
        }

        // Right: start / pause / resume / snooze
        RoundButton {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            theme: root.theme
            tinted: true
            tone: root.mode === "finished" ? root.theme.error : root.theme.accent
            icon: root.mode === "finished" ? "replay"
                : root.mode === "setup" || root.paused ? "play_arrow" : "pause"
            onClicked: {
                if (root.mode === "setup")
                    root.startSelected();
                else if (root.mode === "finished")
                    root.timer.start(root.timer.duration);   // same timer again
                else
                    root.timer.toggle();
            }
        }
    }
}
