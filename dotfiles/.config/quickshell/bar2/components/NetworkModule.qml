// components/NetworkModule.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth: 520
    implicitHeight: mainColumn.implicitHeight + 48

    required property var theme

    // Core Properties
    property string interfaceName: ""
    property string connectionName: ""
    property bool connected: false
    property string ipAddress: "0.0.0.0"
    property string gateway: "0.0.0.0"

    // Stats Properties
    property string pingTime: "-- ms"
    property string packetLoss: "0%"
    property string rxSpeed: "0.0 KB/s"
    property string txSpeed: "0.0 KB/s"
    property string totalDownloaded: "0.00 GB"
    property string totalUploaded: "0.00 GB"

    // DNS State
    property string activeDns: "unknown"

    // ============================================================
    // SPEED TEST STATE
    // ============================================================
    property bool speedTestRunning: false
    property bool speedTestHasResult: false
    property string speedTestPing: "-- ms"
    property string speedTestJitter: "-- ms"
    property string speedTestDownload: "-- Mbps"
    property string speedTestUpload: "-- Mbps"
    property string speedTestServer: ""
    property string speedTestError: ""

    function runSpeedTest() {
    if (root.speedTestRunning) return

    root.speedTestRunning = true
    root.speedTestError = ""
    speedTestWorker.command = ["sh", "-c", "timeout 30 speedtest --accept-license --accept-gdpr -f json"]
    speedTestWorker.running = true
}
    Process {
        id: speedTestWorker

        onExited: (exitCode, exitStatus) => {
            root.speedTestRunning = false
            if (exitCode === 124) {
                root.speedTestError = "Timed out"
            } else if (exitCode !== 0 && !root.speedTestHasResult) {
                root.speedTestError = "Test failed"
            }
        }

        stdout: StdioCollector {
    onStreamFinished: {
        try {
            const result = JSON.parse(text.trim())
            if (!result || result.type !== "result") return

            const downloadMbps = (result.download.bandwidth * 8) / 1000000
            const uploadMbps = (result.upload.bandwidth * 8) / 1000000

            root.speedTestPing = result.ping.latency.toFixed(1) + " ms"
            root.speedTestJitter = result.ping.jitter.toFixed(1) + " ms"
            root.speedTestDownload = downloadMbps.toFixed(1) + " Mbps"
            root.speedTestUpload = uploadMbps.toFixed(1) + " Mbps"
            root.speedTestServer = result.server && result.server.name
                ? result.server.name + " — " + result.server.location
                : ""
            root.speedTestHasResult = true
            root.speedTestError = ""
        } catch (e) {
            root.speedTestError = "Couldn't read result"
        }
    }
}
    }

    // ============================================================
    // RECURRING BACKGROUND MONITOR (Speed, Totals, Ping)
    // ============================================================

    Timer {
        id: deviceDetectTimer
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: deviceDetect.running = true
    }

    Process {
        id: deviceDetect
        command: ["sh", "-c",
            "nmcli -t -f DEVICE,TYPE,STATE device status | awk -F: '$2==\"ethernet\" && $3==\"connected\" {print $1; found=1} END {if (!found) print \"DISCONNECTED\"}'"
        ]
        stdout: SplitParser {
            onRead: line => {
                const dev = line.trim()
                if (dev.length > 0 && dev !== "DISCONNECTED") {
                    root.interfaceName = dev
                    root.connected = true
                    connectionDetect.running = true
                    statLoopTimer.start()
                } else {
                    root.connected = false
                    root.connectionName = ""
                    root.ipAddress = "0.0.0.0"
                    root.gateway = "0.0.0.0"
                    statLoopTimer.stop()
                }
            }
        }
    }

    Process {
        id: connectionDetect
        command: ["sh", "-c", "nmcli -t -f NAME,DEVICE connection show --active | awk -F: -v dev=\"" + root.interfaceName + "\" '$2==dev {print $1; exit}'"]
        stdout: SplitParser {
            onRead: line => {
                const name = line.trim()
                if (name.length > 0) root.connectionName = name
            }
        }
    }

    Timer {
        id: statLoopTimer
        interval: 2000
        repeat: true
        running: false
        triggeredOnStart: true
        onTriggered: {
            metricsWorker.running = true
        }
    }

    Process {
        id: metricsWorker
        command: ["sh", "-c", `
            dev="${root.interfaceName}"

            ip_addr=$(ip -4 -o addr show "$dev" | awk '{print $4}' | cut -d/ -f1)
            gw_addr=$(ip route show default dev "$dev" | awk '{print $3}' | head -n1)

            stats=$(awk -v dev="$dev" '$1 ~ dev {print $2, $10}' /proc/net/dev)

            ping_res=$(ping -c 1 -W 1 1.1.1.1 2>/dev/null | awk -F/ '/rtt/ {print $5}')

            echo "$ip_addr|$gw_addr|$stats|$ping_res"
        `]

        property real lastRxBytes: 0
        property real lastTxBytes: 0

        stdout: SplitParser {
            onRead: line => {
                const parts = line.trim().split('|')
                if (parts.length < 4) return

                if (parts[0]) root.ipAddress = parts[0]
                if (parts[1]) root.gateway = parts[1]

                const rawStats = parts[2].split(' ')
                if (rawStats.length >= 2) {
                    const rxBytes = parseFloat(rawStats[0])
                    const txBytes = parseFloat(rawStats[1])

                    if (metricsWorker.lastRxBytes > 0) {
                        const rxDelta = (rxBytes - metricsWorker.lastRxBytes) / 2048
                        const txDelta = (txBytes - metricsWorker.lastTxBytes) / 2048
                        root.rxSpeed = rxDelta.toFixed(1) + " KB/s"
                        root.txSpeed = txDelta.toFixed(1) + " KB/s"
                    }

                    metricsWorker.lastRxBytes = rxBytes
                    metricsWorker.lastTxBytes = txBytes

                    root.totalDownloaded = (rxBytes / (1024 * 1024 * 1024)).toFixed(2) + " GB"
                    root.totalUploaded = (txBytes / (1024 * 1024 * 1024)).toFixed(2) + " GB"
                }

                if (parts[3]) {
                    root.pingTime = Math.round(parseFloat(parts[3])) + " ms"
                    root.packetLoss = "0%"
                } else {
                    root.pingTime = "--"
                    root.packetLoss = "100%"
                }
            }
        }
    }

    Process {
        id: dnsQuery
        running: root.connected
        command: ["sh", "-c", "nmcli -g IP4.DNS device show " + root.interfaceName]
        stdout: SplitParser {
            onRead: line => {
                const dns = line.trim()
                if (dns.includes("1.1.1.1")) root.activeDns = "cloudflare"
                else if (dns.includes("8.8.8.8")) root.activeDns = "google"
                else if (dns.length > 0) root.activeDns = "dhcp"
            }
        }
    }

    function setDns(type) {
        let dnsServers = ""
        if (type === "cloudflare") dnsServers = "1.1.1.1,1.0.0.1"
        else if (type === "google") dnsServers = "8.8.8.8,8.8.4.4"

        dnsModifier.command = type === "dhcp"
            ? ["nmcli", "connection", "modify", root.connectionName, "ipv4.ignore-auto-dns", "no"]
            : ["nmcli", "connection", "modify", root.connectionName, "ipv4.dns", dnsServers, "ipv4.ignore-auto-dns", "yes"]
        dnsModifier.running = true
    }

    Process { id: dnsModifier; onExited: connectionRestart.running = true }
    Process { id: connectionRestart; command: ["nmcli", "connection", "up", root.connectionName]; onExited: dnsQuery.running = true }

    // ============================================================
    // PANEL UI LAYOUT
    // ============================================================
    ColumnLayout {
        id: mainColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 24
        spacing: 20

        // ---- HEADER ROW ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: root.connected ? "󰱓" : "󰅛"
                color: root.connected ? root.theme.accent : root.theme.error
                font { family: root.theme.font; pixelSize: 32 }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: root.connected ? root.connectionName : "Disconnected"
                    color: root.theme.fg
                    font { family: root.theme.font; pixelSize: 20; bold: true }
                }
                Text {
                    text: root.connected ? "ETHERNET CONNECTION ACTIVE" : "CABLE DISCONNECTED"
                    color: root.theme.fg3
                    font { family: root.theme.font; pixelSize: 11; bold: true }
                }
            }
            Item { Layout.fillWidth: true }

            // ---- SPEED TEST BUTTON ----
            // Glyph is a best guess (nerd-font "speedometer") — swap if it
            // doesn't render correctly in your font.
            MouseArea {
                id: speedTestBtn
                width: 36
                height: 36
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: !root.speedTestRunning
                onClicked: root.runSpeedTest()

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: speedTestBtn.containsMouse ? root.theme.surfaceAlt : "transparent"
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰾆"
                    color: root.speedTestRunning ? root.theme.fg3 : root.theme.accent
                    font { family: root.theme.font; pixelSize: 18 }

                    RotationAnimation on rotation {
                        running: root.speedTestRunning
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 900
                    }
                }
            }
        }

        // ---- GRID STATS DISPLAY CARD ----
        Rectangle {
            Layout.fillWidth: true
            height: 160
            radius: 12
            color: root.theme.bgAlt
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)

            GridLayout {
                anchors.fill: parent
                anchors.margins: 16
                columns: 2
                rowSpacing: 12
                columnSpacing: 24

                component StatItem : RowLayout {
                    property string label: ""
                    property string value: ""
                    Layout.fillWidth: true

                    Text { text: label; color: root.theme.fg3; font { family: root.theme.font; pixelSize: 14 } }
                    Item { Layout.fillWidth: true }
                    Text { text: value; color: root.theme.fg; font { family: root.theme.font; pixelSize: 14; bold: true } }
                }

                StatItem { label: "Ping"; value: root.pingTime }
                StatItem { label: "Packet Loss"; value: root.packetLoss }
                StatItem { label: "Receiving"; value: root.rxSpeed }
                StatItem { label: "Sending"; value: root.txSpeed }
                StatItem { label: "Downloaded"; value: root.totalDownloaded }
                StatItem { label: "Uploaded"; value: root.totalUploaded }
                StatItem { label: "IP Address"; value: root.ipAddress }
                StatItem { label: "Gateway"; value: root.gateway }
            }
        }

        // ---- SPEED TEST RESULTS CARD (expands in/out) ----
Rectangle {
    id: speedTestCard
    Layout.fillWidth: true
    Layout.preferredHeight: shown ? 110 : 0
    radius: 12
    color: root.theme.bgAlt
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.05)
    clip: true

    readonly property bool shown: root.speedTestRunning || root.speedTestHasResult || root.speedTestError !== ""

    opacity: shown ? 1.0 : 0.0

    Behavior on Layout.preferredHeight { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 180 } }
            Item {
                anchors.fill: parent
                anchors.margins: 16
                visible: parent.height > 20 // avoid squished text painting mid-collapse

               // ---- Loading state ----
             Text {
    anchors.centerIn: parent
    visible: root.speedTestRunning
    text: "Testing…"
    color: root.theme.fg3
    font { family: root.theme.font; pixelSize: 14; bold: true }
}
                // ---- Error state ----
                Text {
                    anchors.centerIn: parent
                    visible: !root.speedTestRunning && root.speedTestError !== ""
                    text: root.speedTestError
                    color: root.theme.error
                    font { family: root.theme.font; pixelSize: 14; bold: true }
                }

                // ---- Result state ----
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6
                    visible: !root.speedTestRunning && root.speedTestError === "" && root.speedTestHasResult

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 6
                        columnSpacing: 24

                        component ResultItem : RowLayout {
                            property string label: ""
                            property string value: ""
                            Layout.fillWidth: true

                            Text { text: label; color: root.theme.fg3; font { family: root.theme.font; pixelSize: 13 } }
                            Item { Layout.fillWidth: true }
                            Text { text: value; color: root.theme.fg; font { family: root.theme.font; pixelSize: 13; bold: true } }
                        }

                        ResultItem { label: "Ping"; value: root.speedTestPing }
                        ResultItem { label: "Jitter"; value: root.speedTestJitter }
                        ResultItem { label: "Download"; value: root.speedTestDownload }
                        ResultItem { label: "Upload"; value: root.speedTestUpload }
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: root.speedTestServer !== ""
                        text: root.speedTestServer
                        color: root.theme.fg3
                        font { family: root.theme.font; pixelSize: 11 }
                        elide: Text.ElideRight
                    }
                }
            }
        }

        // ---- DNS PROVIDER ROW LAYOUT ----
        Text {
            text: "DNS PROVIDER"
            color: root.theme.fg3
            font { family: root.theme.font; pixelSize: 12; bold: true }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            component DnsBlockButton : MouseArea {
                id: dnsBtn
                property string title: ""
                property bool isActive: false
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: dnsBtn.isActive ? root.theme.accent : (dnsBtn.containsMouse ? root.theme.surfaceAlt : "transparent")
                    border.width: 1
                    border.color: dnsBtn.isActive ? root.theme.accent : Qt.rgba(1, 1, 1, 0.15)

                    Text {
                        anchors.centerIn: parent
                        text: dnsBtn.title
                        color: dnsBtn.isActive ? root.theme.bg : root.theme.fg
                        font {
                            family: root.theme.font
                            pixelSize: 14
                            bold: true
                        }
                    }
                }
            }

            DnsBlockButton {
                title: "DHCP"
                isActive: root.activeDns === "dhcp"
                onClicked: root.setDns("dhcp")
            }

            DnsBlockButton {
                title: "Cloudflare"
                isActive: root.activeDns === "cloudflare"
                onClicked: root.setDns("cloudflare")
            }

            DnsBlockButton {
                title: "Google"
                isActive: root.activeDns === "google"
                onClicked: root.setDns("google")
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}