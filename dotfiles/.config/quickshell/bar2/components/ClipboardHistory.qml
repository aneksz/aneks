import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme

    // ============================================================
    // CLIPBOARD DATA
    // ============================================================

    property var entries: []       // [{ id, preview }]
    property var filteredEntries: []
    property int selectedIndex: 0
    property string filterText: ""

    Process {
        id: getClipboard
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onTextChanged: {
                const lines = text.split("\n").filter(l => l.length > 0)
                root.entries = lines.map(line => {
                    const tabIdx = line.indexOf("\t")
                    return {
                        id: tabIdx >= 0 ? line.substring(0, tabIdx) : line,
                        preview: tabIdx >= 0 ? line.substring(tabIdx + 1) : line
                    }
                })
                root.applyFilter()
            }
        }
    }

    function applyFilter() {
        const q = filterText.toLowerCase()
        filteredEntries = q === ""
            ? entries
            : entries.filter(e => e.preview.toLowerCase().includes(q))
        selectedIndex = 0
    }

    onFilterTextChanged: applyFilter()

    // Refresh every time the panel becomes visible - clipboard changes
    // constantly, so a cached list from last time it was open is stale.
    onVisibleChanged: {
        if (visible) {
            filterText = ""
            searchInput.text = ""
            getClipboard.running = true
        }
    }

    property bool clearConfirming: false

    Timer {
        id: clearConfirmTimer
        interval: 2500
        onTriggered: root.clearConfirming = false
    }

    function clearHistory() {
        if (!clearConfirming) {
            clearConfirming = true
            clearConfirmTimer.restart()
            return
        }
        clearConfirming = false
        clearConfirmTimer.stop()
        Quickshell.execDetached(["sh", "-c", "cliphist wipe"])
        entries = []
        filteredEntries = []
    }

    function copyEntry(entryId) {
        Quickshell.execDetached([
            "sh", "-c",
            "cliphist decode " + entryId + " | wl-copy"
        ])
    }

    // ============================================================
    // LAYOUT
    // ============================================================

    anchors.fill: parent

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 670
        height: 480
        radius: 24
        color: "transparent"
    
        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // ---------------- Header ----------------
            Item {
                width: parent.width
                height: 44

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    Rectangle {
                        width: 44
                        height: 44
                        radius: 12
                        color: root.theme.surfaceAlt

                        Text {
                            anchors.centerIn: parent
                            text: "󰅍"
                            color: root.theme.accent
                            font {
                                family: root.theme.font
                                pixelSize: 32
                            }
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "Clipboard history"
                            color: root.theme.fg0
                            font {
                                family: root.theme.font
                                pixelSize: 20
                                weight: Font.Bold
                            }
                        }

                        Text {
                            text: root.entries.length + " item" + (root.entries.length === 1 ? "" : "s")
                            color: root.theme.textMuted
                            font {
                                family: root.theme.font
                                pixelSize: 13
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: clearLabel.width + 24
                    height: 32
                    radius: 16
                    color: clearMouse.containsMouse
                        ? root.theme.error
                        : "transparent"
                    border.width: 1
                    border.color: root.theme.error

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Text {
                        id: clearLabel
                        anchors.centerIn: parent
                        text: root.clearConfirming ? "Confirm?" : "Clear"
                        color: clearMouse.containsMouse ? root.theme.bg : root.theme.error
                        font {
                            family: root.theme.font
                            pixelSize: 12
                            weight: Font.Bold
                        }

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.clearHistory()
                    }
                }
            }

            // ---------------- Search ----------------
            Rectangle {
                width: parent.width
                height: 46
                radius: 12
                color: root.theme.surface
                border.width: 1
                border.color: root.theme.border

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf002" // search glyph
                        color: root.theme.textMuted
                        font {
                            family: root.theme.font
                            pixelSize: 15
                        }
                    }

                    TextInput {
                        id: searchInput
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 30
                        color: root.theme.fg0
                        font {
                            family: root.theme.font
                            pixelSize: 15
                        }
                        focus: root.visible

                        Text {
                            text: "Type to filter clipboard history..."
                            color: root.theme.textMuted
                            visible: searchInput.text.length === 0
                            font: searchInput.font
                        }

                        onTextChanged: root.filterText = text

                        Keys.onDownPressed: {
                            if (root.selectedIndex < root.filteredEntries.length - 1)
                                root.selectedIndex++
                        }
                        Keys.onUpPressed: {
                            if (root.selectedIndex > 0)
                                root.selectedIndex--
                        }
                        Keys.onReturnPressed: {
                            if (root.filteredEntries.length > 0) {
                                root.copyEntry(root.filteredEntries[root.selectedIndex].id)
                                root.visible = false
                            }
                        }
                        Keys.onEscapePressed: root.visible = false
                    }
                }
            }

            // ---------------- List ----------------
            ListView {
                width: parent.width
                height: parent.height - 160
                clip: true
                spacing: 8
                model: root.filteredEntries
                currentIndex: root.selectedIndex

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 58
                    radius: 12
                    color: index === root.selectedIndex
                        ? root.theme.surfaceAlt
                        : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        spacing: 3

                        Text {
                            width: parent.width
                            text: modelData.preview
                            color: root.theme.fg0
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            font {
                                family: root.theme.font
                                pixelSize: 14
                                weight: index === root.selectedIndex ? Font.Bold : Font.Normal
                            }
                        }

                        Text {
                            text: "Text"
                            color: root.theme.textMuted
                            font {
                                family: root.theme.font
                                pixelSize: 12
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: root.selectedIndex = index
                        onClicked: {
                            root.copyEntry(modelData.id)
                            root.visible = false
                        }
                    }
                }
            }

            // ---------------- Footer ----------------
            Text {
                text: "Enter/Click copy · Esc close"
                color: root.theme.textMuted
                font {
                    family: root.theme.font
                    pixelSize: 12
                }
            }
        }
    }
}
