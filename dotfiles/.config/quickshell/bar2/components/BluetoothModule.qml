// components/BluetoothModule.qml
// Bluetooth panel: on/off switch, paired devices and nearby devices.
// Click a device (or its button) to connect / disconnect / pair.
// Opened over IPC:  qs ipc -c ~/.config/quickshell/bar2 call bluetooth open
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

Item {
    id: root

    required property var theme

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter && adapter.enabled
    readonly property var allDevices: adapter ? adapter.devices.values : []

    // Devices without a real name show up as their address ("AA-BB-CC-…"), hide those
    function hasName(d) {
        const n = d.name || d.deviceName || ""
        return n.length > 0 && !/^([0-9A-F]{2}[:-]){5}[0-9A-F]{2}$/i.test(n)
    }

    readonly property var pairedDevices: allDevices
        .filter(d => d.paired || d.bonded)
        .sort((a, b) => (b.connected - a.connected) || (a.name || "").localeCompare(b.name || ""))
    readonly property var availableDevices: allDevices
        .filter(d => !(d.paired || d.bonded) && hasName(d))
        .sort((a, b) => (a.name || "").localeCompare(b.name || ""))
    readonly property int connectedCount: pairedDevices.filter(d => d.connected).length

    // Device the user just asked to connect/pair, for the "Connecting…" label
    property string busyAddress: ""
    Timer { id: busyTimeout; interval: 15000; onTriggered: root.busyAddress = "" }

    // Scan while the panel is open and Bluetooth is on
    onVisibleChanged: if (adapter) adapter.discovering = visible && powered
    onPoweredChanged: if (adapter && visible) adapter.discovering = powered

    function activate(d) {
        if (!d) return
        busyAddress = d.address
        busyTimeout.restart()
        if (d.connected) {
            d.disconnect()
        } else if (d.paired || d.bonded) {
            d.connect()
        } else {
            d.trusted = true          // reconnect automatically in future
            d.pair()                  // connects once pairing finishes (see onPairedChanged below)
        }
    }

    function iconFor(d) {
        const i = (d.icon || "").toLowerCase()
        if ((d.name || "").toLowerCase().includes("airpods")) return "󱡏"
        if (i.includes("headset") || i.includes("headphone")) return "headphones"
        if (i.includes("audio") || i.includes("speaker")) return "speaker"
        if (i.includes("mouse")) return "mouse"
        if (i.includes("keyboard")) return "keyboard"
        if (i.includes("phone")) return "smartphone"
        if (i.includes("gaming") || i.includes("joystick")) return "sports_esports"
        if (i.includes("computer")) return "computer"
        if (i.includes("video") || i.includes("display")) return "tv"
        return "bluetooth"
    }

    function statusFor(d) {
        if (d.pairing) return "Pairing…"
        if (busyAddress === d.address && !d.connected && (d.paired || d.bonded)) return "Connecting…"
        if (d.connected) return d.batteryAvailable ? "Connected  ·  " + Math.round(d.battery * 100) + "%" : "Connected"
        return (d.paired || d.bonded) ? "Not connected" : ""
    }

    // ============================================================
    // UI
    // ============================================================

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // ---------- header ----------
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: root.powered ? "bluetooth" : "bluetooth_disabled"
                color: root.powered ? root.theme.accent : root.theme.fg3
                font { family: "Material Symbols Outlined"; pixelSize: 30 }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Bluetooth"
                    color: root.theme.fg
                    font { family: root.theme.font; pixelSize: 20; bold: true }
                }
                Text {
                    text: !root.adapter ? "NO ADAPTER FOUND"
                        : !root.powered ? "OFF"
                        : root.adapter.discovering
                            ? (root.connectedCount ? root.connectedCount + " CONNECTED  ·  SCANNING…" : "SCANNING…")
                            : (root.connectedCount ? root.connectedCount + " CONNECTED" : "ON")
                    color: root.theme.fg3
                    font { family: root.theme.font; pixelSize: 11; bold: true; letterSpacing: 1.5 }
                }
            }

            Item { Layout.fillWidth: true }

            // on/off switch
            Rectangle {
                id: power
                Layout.preferredWidth: 44
                Layout.preferredHeight: 24
                radius: 12
                enabled: !!root.adapter
                color: root.powered ? root.theme.accent : Qt.rgba(root.theme.fg.r, root.theme.fg.g, root.theme.fg.b, 0.15)
                Behavior on color { ColorAnimation { duration: 150 } }

                Rectangle {
                    width: 18; height: 18; radius: 9
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.powered ? parent.width - width - 3 : 3
                    color: root.powered ? root.theme.bg : root.theme.fg
                    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(root.theme.fg.r, root.theme.fg.g, root.theme.fg.b, 0.1)
        }

        // ---------- off state ----------
        Text {
            visible: !root.powered
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "Bluetooth is off"
            color: root.theme.fg3
            font { family: root.theme.font; pixelSize: 13 }
        }

        // ---------- device lists ----------
        Flickable {
            visible: root.powered
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: lists.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: lists
                width: parent.width
                spacing: 4

                SectionLabel { text: "PAIRED"; visible: root.pairedDevices.length > 0 }
                Repeater {
                    model: root.pairedDevices
                    delegate: DeviceRow { required property var modelData; device: modelData }
                }

                Item { Layout.preferredHeight: 6; visible: root.pairedDevices.length > 0 }

                SectionLabel { text: "AVAILABLE" }
                Repeater {
                    model: root.availableDevices
                    delegate: DeviceRow { required property var modelData; device: modelData }
                }
                Text {
                    visible: root.availableDevices.length === 0
                    Layout.leftMargin: 4
                    text: root.adapter && root.adapter.discovering ? "Looking for devices…" : "No devices found"
                    color: root.theme.fg3
                    font { family: root.theme.font; pixelSize: 12 }
                }
            }
        }
    }

    // ============================================================
    // PIECES
    // ============================================================

    component SectionLabel: Text {
        Layout.topMargin: 2
        Layout.bottomMargin: 2
        color: root.theme.fg3
        font { family: root.theme.font; pixelSize: 11; bold: true; letterSpacing: 1.5 }
    }

    component DeviceRow: Rectangle {
        id: row
        property var device
        readonly property bool known: device && (device.paired || device.bonded)
        readonly property bool busy: device && (device.pairing || (root.busyAddress === device.address && !device.connected))

        Layout.fillWidth: true
        Layout.preferredHeight: 48
        radius: 10
        color: rowMouse.containsMouse ? Qt.rgba(root.theme.fg.r, root.theme.fg.g, root.theme.fg.b, 0.06) : "transparent"
        Behavior on color { ColorAnimation { duration: 100 } }

        // After a successful pair, connect straight away
        Connections {
            target: row.device
            function onPairedChanged() { if (row.device.paired && !row.device.connected) row.device.connect() }
            function onConnectedChanged() { if (root.busyAddress === row.device.address) root.busyAddress = "" }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activate(row.device)
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 12

        Text {
            text: root.iconFor(row.device)
            color: row.device.connected ? root.theme.accent : root.theme.fg3
            font {
                family: text.codePointAt(0) >= 0xE000 ? root.theme.font : "Material Symbols Outlined"
                pixelSize: 20
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text {
                    Layout.fillWidth: true
                    text: row.device.name
                    elide: Text.ElideRight
                    color: root.theme.fg
                    font { family: root.theme.font; pixelSize: 13; bold: row.device.connected }
                }
                Text {
                    visible: text.length > 0
                    text: root.statusFor(row.device)
                    color: row.device.connected ? root.theme.accent : root.theme.fg3
                    font { family: root.theme.font; pixelSize: 11 }
                }
            }

            // forget (paired devices only, on hover)
            MouseArea {
                id: forgetBtn
                visible: row.known && (rowMouse.containsMouse || forgetBtn.containsMouse)
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: row.device.forget()

                Text {
                    anchors.centerIn: parent
                    text: "delete"
                    color: forgetBtn.containsMouse ? root.theme.error : root.theme.fg3
                    font { family: "Material Symbols Outlined"; pixelSize: 17 }
                    scale: forgetBtn.containsMouse ? 1.1 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                }
            }

            // main action button
            Rectangle {
                Layout.preferredWidth: actionText.implicitWidth + 20
                Layout.preferredHeight: 26
                radius: 8
                opacity: row.busy ? 0.5 : 1
                color: row.device.connected
                    ? "transparent"
                    : Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, actionMouse.containsMouse ? 0.25 : 0.15)
                border.width: 1
                border.color: row.device.connected ? Qt.rgba(root.theme.fg.r, root.theme.fg.g, root.theme.fg.b, 0.2) : root.theme.accent

                Text {
                    id: actionText
                    anchors.centerIn: parent
                    text: row.busy ? "…" : row.device.connected ? "Disconnect" : row.known ? "Connect" : "Pair"
                    color: row.device.connected ? root.theme.fg : root.theme.accent
                    font { family: root.theme.font; pixelSize: 11; bold: true }
                }

                MouseArea {
                    id: actionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !row.busy
                    onClicked: root.activate(row.device)
                }
            }
        }
    }
}
