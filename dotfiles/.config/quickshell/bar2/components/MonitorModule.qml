// components/MonitorModule.qml
// External monitor controls over DDC/CI (ddcutil): brightness, contrast,
// picture mode and colour preset, with a switcher between monitors.
// Needs: ddcutil, the i2c-dev module, and your user in the i2c group.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property var theme

    // [{ bus, connector, model, presets: [{code,label}], modes: [{code,label}] }]
    property var monitors: []
    property int current: 0
    readonly property var mon: monitors.length ? monitors[current] : null

    // Current values of the selected monitor (-1 = not read yet)
    property int brightness: -1
    property int contrast: -1
    property string preset: ""        // hex code, e.g. "05"
    property string mode: ""
    property bool reading: false
    property string error: ""

    // Friendlier names for the codes ddcutil reports
    readonly property var presetNames: ({ "01": "sRGB", "04": "5000K", "05": "6500K", "06": "7500K",
                                          "08": "9300K", "09": "10000K", "0b": "User 1", "0c": "User 2" })
    readonly property var modeNames: ({ "00": "Standard", "03": "Movie", "05": "Games" })

    onVisibleChanged: {
        if (!visible) return
        if (!monitors.length) detectProc.running = true
        else loadCurrent()
    }
    onCurrentChanged: loadCurrent()

    function loadCurrent() {
        if (!mon) return
        brightness = -1; contrast = -1; preset = ""; mode = ""
        if (!mon.presets) { capsProc.command = ["ddcutil", "--bus", String(mon.bus), "capabilities"]; capsProc.running = true }
        else readValues()
    }

    function readValues() {
        if (!mon) return
        reading = true
        readProc.command = ["ddcutil", "--bus", String(mon.bus), "getvcp", "10", "12", "14", "DC", "--brief"]
        readProc.running = true
    }

    // ---------- writes: one at a time, newest value per feature wins ----------
    property var queue: []
    function setVcp(feature, value) {
        if (!mon) return
        const q = queue.filter(e => !(e.bus === mon.bus && e.feature === feature))
        q.push({ bus: mon.bus, feature: feature, value: String(value) })
        queue = q
        runQueue()
    }
    function runQueue() {
        if (writeProc.running || !queue.length) return
        const e = queue[0]
        queue = queue.slice(1)
        writeProc.command = ["ddcutil", "--bus", String(e.bus), "--noverify", "setvcp", e.feature, e.value]
        writeProc.running = true
    }

    // ============================================================
    // PROCESSES
    // ============================================================

    Process {
        id: detectProc
        command: ["ddcutil", "detect"]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = []
                let m = null
                for (const line of text.split("\n")) {
                    if (/^Display \d+/.test(line)) { m = { bus: -1, connector: "", model: "" }; list.push(m); continue }
                    if (!m) continue
                    let r
                    if ((r = line.match(/I2C bus:\s+\/dev\/i2c-(\d+)/))) m.bus = parseInt(r[1])
                    else if ((r = line.match(/DRM_connector:\s+(?:card\d+-)?(\S+)/))) m.connector = r[1]
                    else if ((r = line.match(/^\s+Model:\s+(.+)$/))) m.model = r[1].trim()
                }
                root.monitors = list.filter(x => x.bus >= 0)
                root.error = root.monitors.length ? "" : "No DDC/CI monitors found"
                root.current = 0
                root.loadCurrent()
            }
        }
    }

    // Which presets / picture modes this monitor offers
    Process {
        id: capsProc
        stdout: StdioCollector {
            onStreamFinished: {
                function valuesFor(feature) {
                    const out = []
                    let inside = false
                    for (const line of text.split("\n")) {
                        const f = line.match(/^\s*Feature:\s*([0-9A-Fa-f]{2})/)
                        if (f) { inside = f[1].toUpperCase() === feature; continue }
                        const v = inside && line.match(/^\s+([0-9a-f]{2}):\s+(.+)$/i)
                        if (v) out.push({ code: v[1].toLowerCase(), label: v[2].trim() })
                    }
                    return out
                }
                const list = root.monitors.slice()
                const m = Object.assign({}, list[root.current])
                m.presets = valuesFor("14").map(p => ({ code: p.code, label: root.presetNames[p.code] || p.label }))
                m.modes = valuesFor("DC").map(p => ({ code: p.code, label: root.modeNames[p.code] || p.label }))
                list[root.current] = m
                root.monitors = list
                root.readValues()
            }
        }
    }

    // "VCP 10 C 94 100" (slider) / "VCP 14 SNC x05" (choice)
    Process {
        id: readProc
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.split("\n")) {
                    const p = line.trim().split(/\s+/)
                    if (p[0] !== "VCP") continue
                    const f = p[1].toUpperCase()
                    if (p[2] === "C") {
                        const pct = Math.round(parseInt(p[3]) * 100 / Math.max(1, parseInt(p[4])))
                        if (f === "10") root.brightness = pct
                        if (f === "12") root.contrast = pct
                    } else if (p[2] === "SNC") {
                        const code = (p[3] || "").replace(/^x/, "").toLowerCase()
                        if (f === "14") root.preset = code
                        if (f === "DC") root.mode = code
                    }
                }
                root.reading = false
            }
        }
        onExited: function(code) {
            root.reading = false
            if (code !== 0) root.error = "Couldn't read monitor settings"
        }
    }

    Process {
        id: writeProc
        onExited: root.runQueue()
    }

    // ============================================================
    // UI
    // ============================================================

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        // ---------- header ----------
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "desktop_windows"
                color: root.theme.accent
                font { family: "Material Symbols Outlined"; pixelSize: 30 }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: root.mon ? root.mon.model : "Monitors"
                    color: root.theme.fg
                    font { family: root.theme.font; pixelSize: 20; bold: true }
                }
                Text {
                    text: root.error ? root.error.toUpperCase()
                        : root.mon ? root.mon.connector + (root.reading ? "  ·  READING…" : "")
                        : "DETECTING…"
                    color: root.error ? root.theme.error : root.theme.fg3
                    font { family: root.theme.font; pixelSize: 11; bold: true; letterSpacing: 1.5 }
                }
            }

            Item { Layout.fillWidth: true }
        }

        // ---------- monitor switcher ----------
        Row {
            visible: root.monitors.length > 1
            spacing: 8
            Repeater {
                model: root.monitors
                delegate: Chip {
                    required property var modelData
                    required property int index
                    label: modelData.model.replace(/^DELL\s+/i, "") + "  ·  " + modelData.connector
                    selected: root.current === index
                    onActivated: root.current = index
                }
            }
        }

        // ---------- sliders ----------
        DdcSlider {
            Layout.fillWidth: true
            label: "BRIGHTNESS"
            value: root.brightness
            onCommitted: v => { root.brightness = v; root.setVcp("10", v) }
        }

        DdcSlider {
            Layout.fillWidth: true
            label: "CONTRAST"
            value: root.contrast
            onCommitted: v => { root.contrast = v; root.setVcp("12", v) }
        }

        // ---------- picture mode ----------
        Text {
            visible: root.mon && root.mon.modes && root.mon.modes.length > 0
            text: "PICTURE MODE"
            color: root.theme.fg3
            font { family: root.theme.font; pixelSize: 11; bold: true; letterSpacing: 1.5 }
        }
        Flow {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: root.mon && root.mon.modes ? root.mon.modes : []
                delegate: Chip {
                    required property var modelData
                    label: modelData.label
                    selected: root.mode === modelData.code
                    onActivated: { root.mode = modelData.code; root.setVcp("DC", "0x" + modelData.code) }
                }
            }
        }

        // ---------- colour preset ----------
        Text {
            visible: root.mon && root.mon.presets && root.mon.presets.length > 0
            text: "COLOR PRESET"
            color: root.theme.fg3
            font { family: root.theme.font; pixelSize: 11; bold: true; letterSpacing: 1.5 }
        }
        Flow {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: root.mon && root.mon.presets ? root.mon.presets : []
                delegate: Chip {
                    required property var modelData
                    label: modelData.label
                    selected: root.preset === modelData.code
                    onActivated: { root.preset = modelData.code; root.setVcp("14", "0x" + modelData.code) }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    // ============================================================
    // PIECES
    // ============================================================

    // Toggle-style button
    component Chip: Rectangle {
        id: chip
        property string label: ""
        property bool selected: false
        signal activated()

        width: chipText.implicitWidth + 24
        height: 32
        radius: 8
        color: selected
            ? Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.2)
            : (chipMouse.containsMouse ? Qt.rgba(root.theme.fg.r, root.theme.fg.g, root.theme.fg.b, 0.06) : "transparent")
        border.width: 1
        border.color: selected ? root.theme.accent : Qt.rgba(root.theme.fg.r, root.theme.fg.g, root.theme.fg.b, 0.15)
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            id: chipText
            anchors.centerIn: parent
            text: chip.label
            color: chip.selected ? root.theme.accent : root.theme.fg
            font { family: root.theme.font; pixelSize: 13; bold: chip.selected }
        }

        MouseArea {
            id: chipMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.activated()
        }
    }

    // Slider that shows the value while dragging and applies it on release
    // (DDC is slow, so only the final value is sent to the monitor)
    component DdcSlider: ColumnLayout {
        id: slider
        property string label: ""
        property int value: -1                 // -1 = unknown yet
        signal committed(int v)

        property int dragValue: -1
        readonly property int shown: dragValue >= 0 ? dragValue : value
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: slider.label
                color: root.theme.fg3
                font { family: root.theme.font; pixelSize: 11; bold: true; letterSpacing: 1.5 }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: slider.shown >= 0 ? slider.shown + "%" : "—"
                color: root.theme.fg
                font { family: root.theme.font; pixelSize: 12 }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            opacity: slider.value >= 0 ? 1 : 0.4

            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 6
                radius: 3
                color: Qt.rgba(root.theme.fg.r, root.theme.fg.g, root.theme.fg.b, 0.12)

                Rectangle {
                    width: Math.max(0, slider.shown) / 100 * parent.width
                    height: parent.height
                    radius: 3
                    color: root.theme.accent
                }
            }

            Rectangle {
                width: 16; height: 16; radius: 8
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, slider.shown) / 100 * (parent.width - width)
                color: root.theme.accent
                scale: sliderMouse.pressed || sliderMouse.containsMouse ? 1.15 : 1.0
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                id: sliderMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: slider.value >= 0
                cursorShape: Qt.PointingHandCursor
                function pick(mx) { return Math.round(Math.max(0, Math.min(1, mx / width)) * 100) }
                onPressed: mouse => slider.dragValue = pick(mouse.x)
                onPositionChanged: mouse => { if (pressed) slider.dragValue = pick(mouse.x) }
                onReleased: { slider.committed(slider.dragValue); slider.dragValue = -1 }
                onWheel: wheel => {
                    const v = Math.max(0, Math.min(100, slider.value + (wheel.angleDelta.y > 0 ? 5 : -5)))
                    if (v !== slider.value) slider.committed(v)
                }
            }
        }
    }
}
