// components/UpdatesModule.qml
// Single-card update center: pending updates grouped into System / AUR / Flatpak,
// with package versions, last system upgrade and one "Update now" button.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    focus: false
    signal closePanel()
    signal updatesFinished()

    required property var theme

    // Still passed in by shell.qml (the bar's counter); kept so the wiring there doesn't change
    property int archCount: 0
    property int aurCount: 0
    property int flatpakCount: 0
    property string archChecked: "—"
    property string aurChecked: "—"
    property string flatpakChecked: "—"
    property bool checking: false
    property var checkAll: null

    // Detailed lists: [{ name, from, to }]
    property var systemList: []
    property var aurList: []
    property var flatpakList: []
    property int pendingChecks: 0
    readonly property bool busy: pendingChecks > 0
    readonly property int total: systemList.length + aurList.length + flatpakList.length

    property string lastChecked: "—"
    property var lastUpgrade: null          // Date of the last full system upgrade
    property bool updating: false

    // Which sections are collapsed (sections with updates start open)
    property var collapsed: ({})
    function toggle(key) {
        const c = Object.assign({}, collapsed)
        c[key] = !c[key]
        collapsed = c
    }

    onVisibleChanged: if (visible) refresh()

    function refresh() {
        if (busy) return
        pendingChecks = 3
        systemProc.running = true
        aurProc.running = true
        flatpakProc.running = true
        lastUpgradeProc.running = true
        if (root.checkAll) root.checkAll()      // keep the bar's number in step
    }

    function finishCheck() {
        pendingChecks = Math.max(0, pendingChecks - 1)
        if (pendingChecks === 0) lastChecked = Qt.formatTime(new Date(), "hh:mm")
    }

    // "pkg 1.0-1 -> 1.1-1" lines (checkupdates / yay -Qua)
    function parseArrowList(text) {
        return text.split("\n").map(l => l.trim()).filter(l => l.length > 0).map(function(l) {
            const p = l.split(/\s+/)
            return { name: p[0], from: p[1] || "", to: p[3] || "" }
        })
    }

    function timeAgo(d) {
        if (!d) return "—"
        const s = Math.floor((Date.now() - d.getTime()) / 1000)
        if (s < 3600) return "just now"
        if (s < 86400) { const h = Math.floor(s / 3600); return h + (h === 1 ? " hour ago" : " hours ago") }
        const days = Math.floor(s / 86400)
        return days + (days === 1 ? " day ago" : " days ago")
    }

    // ============================================================
    // CHECKS
    // ============================================================

    Process {
        id: systemProc
        command: ["sh", "-c", "checkupdates 2>/dev/null"]
        stdout: StdioCollector { onStreamFinished: root.systemList = root.parseArrowList(text) }
        onExited: root.finishCheck()
    }

    Process {
        id: aurProc
        command: ["sh", "-c", "yay -Qua 2>/dev/null"]
        stdout: StdioCollector { onStreamFinished: root.aurList = root.parseArrowList(text) }
        onExited: root.finishCheck()
    }

    // Flatpak only reports the new version, so "from" stays empty
    Process {
        id: flatpakProc
        command: ["sh", "-c", "flatpak remote-ls --updates --columns=name,version 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.flatpakList = text.split("\n").filter(l => l.trim().length > 0).map(function(l) {
                    const p = l.split("\t")
                    return { name: (p[0] || "").trim(), from: "", to: (p[1] || "").trim() }
                })
            }
        }
        onExited: root.finishCheck()
    }

    // Time of the last "pacman -Syu" (or yay -Syu), from pacman's log
    Process {
        id: lastUpgradeProc
        command: ["sh", "-c", "grep 'starting full system upgrade' /var/log/pacman.log | tail -n1 | sed -E 's/^\\[([^]]+)\\].*/\\1/'"]
        stdout: StdioCollector {
            onStreamFinished: {
                // pacman writes "+1100"; JavaScript dates need "+11:00"
                const d = new Date(text.trim().replace(/([+-]\d\d)(\d\d)$/, "$1:$2"))
                root.lastUpgrade = isNaN(d.getTime()) ? null : d
            }
        }
    }

    // One terminal for everything: yay does repo + AUR, then Flatpak
    Process {
        id: updateProc
        command: ["kitty", "-e", "bash", "-c",
            "pkexec pacman -Syu; echo; " +
            "yay -Sua --sudo pkexec; echo; " +
            "flatpak update; echo; " +
            "read -n1 -rsp 'Done. Press any key to close…'"]
        onExited: {
            root.updating = false
            root.refresh()
            root.updatesFinished()
        }
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
                id: headerIcon
                text: "sync"
                color: root.theme.accent
                font { family: "Material Symbols Outlined"; pixelSize: 30 }
                RotationAnimation on rotation {
                    running: root.busy
                    loops: Animation.Infinite
                    from: 0; to: 360; duration: 1000
                    onStopped: headerIcon.rotation = 0
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Update Center"
                    color: root.theme.fg
                    font { family: root.theme.font; pixelSize: 20; bold: true }
                }
                Text {
                    text: root.busy ? "CHECKING…"
                        : root.total === 0 ? "UP TO DATE"
                        : root.total + (root.total === 1 ? " UPDATE WAITING" : " UPDATES WAITING")
                    color: root.total > 0 ? root.theme.accent : root.theme.fg3
                    font { family: root.theme.font; pixelSize: 11; bold: true; letterSpacing: 1.5 }
                }
            }

            Item { Layout.fillWidth: true }

            MouseArea {
                id: refreshBtn
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: !root.busy
                onClicked: root.refresh()

                Text {
                    anchors.centerIn: parent
                    text: "refresh"
                    color: refreshBtn.containsMouse ? root.theme.accent : root.theme.fg3
                    font { family: "Material Symbols Outlined"; pixelSize: 20 }
                    scale: refreshBtn.containsMouse ? 1.1 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                }
            }
        }

        // ---------- last upgrade ----------
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Last updated"
                color: root.theme.fg3
                font { family: root.theme.font; pixelSize: 13 }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: root.timeAgo(root.lastUpgrade)
                color: root.theme.fg
                font { family: root.theme.font; pixelSize: 13 }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(root.theme.fg.r, root.theme.fg.g, root.theme.fg.b, 0.1)
        }

        Text {
            text: "PENDING"
            color: root.theme.fg3
            font { family: root.theme.font; pixelSize: 11; bold: true; letterSpacing: 1.5 }
        }

        // ---------- sections (scroll if long) ----------
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: sections.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: sections
                width: parent.width
                spacing: 6

                component Section: ColumnLayout {
                    id: sec
                    property string key: ""
                    property string label: ""
                    property var list: []
                    readonly property bool open: list.length > 0 && !root.collapsed[key]

                    Layout.fillWidth: true
                    spacing: 2

                    // section header: arrow, name, count (or "up to date")
                    MouseArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        hoverEnabled: true
                        cursorShape: sec.list.length ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: if (sec.list.length) root.toggle(sec.key)

                        RowLayout {
                            anchors.fill: parent
                            spacing: 8

                            Text {
                                Layout.preferredWidth: 16
                                text: "chevron_right"
                                visible: sec.list.length > 0
                                color: root.theme.fg3
                                rotation: sec.open ? 90 : 0
                                Behavior on rotation { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                font { family: "Material Symbols Outlined"; pixelSize: 16 }
                            }
                            Item { Layout.preferredWidth: 16; visible: sec.list.length === 0 }

                            Text {
                                text: sec.label
                                color: root.theme.fg
                                font { family: root.theme.font; pixelSize: 15; bold: true }
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: sec.list.length > 0 ? sec.list.length : "up to date"
                                color: sec.list.length > 0 ? root.theme.fg : root.theme.fg3
                                font { family: root.theme.font; pixelSize: 13 }
                            }
                        }
                    }

                    // package rows
                    Repeater {
                        model: sec.open ? sec.list : []
                        delegate: RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.leftMargin: 24
                            spacing: 12

                            Text {
                                text: modelData.name
                                color: root.theme.fg
                                elide: Text.ElideRight
                                Layout.maximumWidth: 170
                                font { family: root.theme.font; pixelSize: 13 }
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: modelData.from ? modelData.from + "  →  " + modelData.to : "→  " + modelData.to
                                color: root.theme.fg3
                                elide: Text.ElideLeft
                                Layout.maximumWidth: 230
                                font { family: root.theme.font; pixelSize: 12 }
                            }
                        }
                    }
                }

                Section { key: "system";  label: "System";  list: root.systemList }
                Section { key: "aur";     label: "AUR";     list: root.aurList }
                Section { key: "flatpak"; label: "Flatpak"; list: root.flatpakList }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(root.theme.fg.r, root.theme.fg.g, root.theme.fg.b, 0.1)
        }

        // ---------- footer ----------
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Last checked " + root.lastChecked
                color: root.theme.fg3
                font { family: root.theme.font; pixelSize: 12 }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                id: updateBtn
                readonly property bool usable: root.total > 0 && !root.updating && !root.busy
                Layout.preferredWidth: updateRow.implicitWidth + 28
                Layout.preferredHeight: 38
                radius: 10
                opacity: usable ? 1 : 0.4
                color: Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b,
                               updateMouse.containsMouse && usable ? 0.25 : 0.15)
                border.width: 1
                border.color: root.theme.accent
                Behavior on color { ColorAnimation { duration: 120 } }

                Row {
                    id: updateRow
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "sync"
                        color: root.theme.accent
                        font { family: "Material Symbols Outlined"; pixelSize: 18 }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.updating ? "Updating…" : "Update now"
                        color: root.theme.accent
                        font { family: root.theme.font; pixelSize: 13; bold: true }
                    }
                }

                MouseArea {
                    id: updateMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: updateBtn.usable ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (!updateBtn.usable) return
                        root.updating = true
                        updateProc.running = true
                    }
                }
            }
        }
    }
}
