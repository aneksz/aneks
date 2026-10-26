import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    implicitWidth: 420
    // Grows with torrent count up to a cap, then the ListView below
    // scrolls internally rather than the panel growing off-screen
    implicitHeight: Math.min(560, 140 + Math.max(1, root.torrents.length) * 84)

    required property var theme

    // Path to torrents_helper.py - adjust if you place it elsewhere.
    // $HOME is expanded by the shell at run time, not by QML.
    readonly property string scriptPath: "$HOME/.config/quickshell/scripts/torrents_helper.py"

    property var torrents: []
    property string magnetInput: ""
    property string lastError: ""

    readonly property int activeCount: torrents.length

    // ============================================================
    // REFRESH ENGINE
    // ============================================================

    Timer {
        id: pollTimer
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (listWorker.running) return
            listWorker.running = true
        }
    }

    Process {
        id: listWorker
        command: ["sh", "-c", `timeout 8 python3 "${root.scriptPath}" list`]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text.trim())
                    if (data.error) {
                        root.lastError = data.error
                        root.torrents = []
                    } else {
                        root.lastError = ""
                        root.torrents = data.torrents || []
                    }
                } catch (e) {
                    root.lastError = "failed to parse helper output"
                }
            }
        }

        stderr: SplitParser {
            onRead: line => console.warn("[torrents] stderr:", line)
        }
    }

    Process { id: actionWorker }

    function runAction(action, hash) {
        actionWorker.command = ["sh", "-c", `timeout 8 python3 "${root.scriptPath}" ${action} "${hash}"`]
        actionWorker.running = true
    }

    function addMagnet() {
        if (!root.magnetInput.trim()) return
        const magnet = root.magnetInput.trim()
        actionWorker.command = ["sh", "-c", `timeout 8 python3 "${root.scriptPath}" add "${magnet}"`]
        actionWorker.running = true
        root.magnetInput = ""
        magnetField.text = ""
    }

    // ============================================================
    // SUB-COMPONENTS
    // ============================================================

    component TorrentRow : ColumnLayout {
        property string torrentHash: ""
        property string torrentName: ""
        property string torrentState: ""
        property real torrentProgress: 0
        property string torrentDlSpeed: ""
        property string torrentUpSpeed: ""
        property string torrentEta: ""
        property real torrentRatio: 0

        Layout.fillWidth: true
        spacing: 6

        Rectangle {
            Layout.fillWidth: true
            height: 74
            radius: 8
            color: root.theme.bgAlt
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: torrentName
                        color: root.theme.fg0
                        elide: Text.ElideRight
                        font { family: root.theme.font; pixelSize: 12; bold: true }
                    }

                    Text {
                        text: (torrentState === "pausedDL" || torrentState === "pausedUP") ? "▶" : "⏸"
                        color: root.theme.accent
                        font { family: root.theme.font; pixelSize: 13 }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const isPaused = (torrentState === "pausedDL" || torrentState === "pausedUP")
                                root.runAction(isPaused ? "resume" : "pause", torrentHash)
                            }
                        }
                    }

                    Text {
                        text: "🗑"
                        color: root.theme.error
                        font { family: root.theme.font; pixelSize: 13 }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.runAction("delete", torrentHash)
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: root.theme.bg
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.05)

                    Rectangle {
                        width: parent.width * (torrentProgress / 100)
                        height: parent.height
                        radius: 3
                        color: root.theme.accent

                        Behavior on width { NumberAnimation { duration: 250 } }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: torrentProgress + "%"
                        color: root.theme.fg
                        font { family: root.theme.font; pixelSize: 10 }
                    }
                    Text {
                        text: "↓ " + torrentDlSpeed
                        color: root.theme.success
                        font { family: root.theme.font; pixelSize: 10 }
                    }
                    Text {
                        text: "↑ " + torrentUpSpeed
                        color: root.theme.accent
                        font { family: root.theme.font; pixelSize: 10 }
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "ETA " + torrentEta
                        color: root.theme.fg
                        font { family: root.theme.font; pixelSize: 10 }
                    }
                    Text {
                        text: "ratio " + torrentRatio
                        color: root.theme.fg
                        font { family: root.theme.font; pixelSize: 10 }
                    }
                }
            }
        }
    }

    // ============================================================
    // PANEL LAYOUT
    // ============================================================

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "󰅢 Torrents"
                color: root.theme.fg0
                font { family: root.theme.font; pixelSize: 18; bold: true }
            }

            Text {
                visible: root.activeCount > 0
                text: root.activeCount
                color: root.theme.accent
                font { family: root.theme.font; pixelSize: 14; bold: true }
            }

            Item { Layout.fillWidth: true }

            Text {
                visible: root.lastError !== ""
                text: root.lastError
                color: root.theme.error
                elide: Text.ElideRight
                Layout.maximumWidth: 200
                font { family: root.theme.font; pixelSize: 10 }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                height: 34
                radius: 8
                color: root.theme.bgAlt
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.08)

                TextInput {
                    id: magnetField
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.theme.fg0
                    font { family: root.theme.font; pixelSize: 12 }
                    clip: true

                    onTextChanged: root.magnetInput = text
                    onAccepted: root.addMagnet()

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        visible: magnetField.text.length === 0
                        text: "Magnet link or .torrent URL..."
                        color: root.theme.fg
                        opacity: 0.5
                        font { family: root.theme.font; pixelSize: 12 }
                    }
                }
            }

            Rectangle {
                width: 60
                height: 34
                radius: 8
                color: addMouse.containsMouse
                       ? Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.22)
                       : Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.12)
                border.width: 1
                border.color: root.theme.accent

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "Add"
                    color: root.theme.accent
                    font { family: root.theme.font; pixelSize: 12; bold: true }
                }

                MouseArea {
                    id: addMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addMagnet()
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            model: root.torrents
            boundsBehavior: Flickable.StopAtBounds

            delegate: TorrentRow {
                width: ListView.view.width
                torrentHash: modelData.hash
                torrentName: modelData.name
                torrentState: modelData.state
                torrentProgress: modelData.progress
                torrentDlSpeed: modelData.dlspeed
                torrentUpSpeed: modelData.upspeed
                torrentEta: modelData.eta
                torrentRatio: modelData.ratio
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 12
            visible: root.torrents.length === 0 && root.lastError === ""
            text: "No active torrents"
            color: root.theme.fg
            opacity: 0.5
            font { family: root.theme.font; pixelSize: 12 }
        }
    }
}
