// components/system/Notifications.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../singletons"

Item {
    id: root

    // ============================================================
    // PUBLIC API
    // ============================================================

    property var theme
    property bool dndEnabled: false
    property var notifServer
    property var notifications: []         

    signal requestClose()

    // ============================================================
    // CLOCK (for relative time)
    // ============================================================

    SystemClock {
        id: listClock
        precision: SystemClock.Seconds
    }

    // ============================================================
    // HELPERS
    // ============================================================

    function timeAgo(ts) {
        if (!ts) return "—"

        const arrival = new Date(ts)
        const now = listClock.date

        if (isNaN(arrival.getTime())) return "err"

        const diff = Math.floor((now.getTime() - arrival.getTime()) / 1000)

        if (diff < 60) return "now"
        if (diff < 3600) return Math.floor(diff / 60) + "m"
        if (diff < 86400) return Math.floor(diff / 3600) + "h"
        return Math.floor(diff / 86400) + "d"
    }

    function keyFor(item) {
    if (item.historyKey) return item.historyKey
    if (item.key) return item.key
    return String(item.id || (item.summary + item.body))
}

        function truncate(str, maxLen) {
        if (!str) return ""
        str = String(str).replace(/\s*\n+\s*/g, " ")   
        return str.length > maxLen ? str.substring(0, maxLen).trim() + "…" : str
    }

    // ============================================================
    // NOTIFICATION LIST - merges live trackedNotifications (this
    // session) with disk-persisted history (survives qs reloads).
    // Where a key exists in both, the live object is used so
    // dismiss() etc. still works normally; history-only entries
    // are plain data and dismiss just removes them from disk.
    // ============================================================

   readonly property var notificationList: {
    function toMs(t) {
        if (t instanceof Date) return t.getTime()
        if (typeof t === "number") return t
        const ms = new Date(t).getTime()
        return isNaN(ms) ? 0 : ms
    }

    var liveByKey = {}
    if (notifServer && notifServer.trackedNotifications) {
        var liveValues = notifServer.trackedNotifications.values
        for (var i = 0; i < liveValues.length; i++) {
            var ln = liveValues[i]
            if (!ln || ln.isSpotifyTransient) continue
            liveByKey[keyFor(ln)] = ln
        }
    }

    // Collect { item, ts } pairs so live objects sort by their history timestamp
    var rows = []
    var historyEntries = NotificationHistory.entries
    for (var j = 0; j < historyEntries.length; j++) {
        var entry = historyEntries[j]
        var item = liveByKey[entry.key]
        if (item) {
            delete liveByKey[entry.key]
        } else {
            item = {
                key: entry.key,
                summary: entry.summary,
                body: entry.body,
                timestamp: entry.timestamp,
                isHistorical: true
            }
        }
       rows.push({ item: item, ts: toMs(item.timestamp) || toMs(entry.timestamp) })
    }

    // Live notifications not yet in history: treat as brand new if no timestamp
    for (var remainingKey in liveByKey) {
        var live = liveByKey[remainingKey]
        rows.push({ item: live, ts: toMs(live.timestamp) || Date.now() })
    }

    // Newest first
    rows.sort(function(a, b) { return b.ts - a.ts })
    return rows.map(function(r) { return r.item })
}

    readonly property int notificationCount: notificationList.length
    readonly property bool emptyState: notificationCount === 0

    // ============================================================
    // GROUPING - notifications with the same title (e.g. several
    // "Theme Updated") collapse into one row that expands on click.
    // ============================================================

    property var expandedGroups: ({})      // group title -> true when expanded

    function toggleGroup(key) {
        const next = Object.assign({}, expandedGroups)
        next[key] = !next[key]
        expandedGroups = next              // reassign so the list rebuilds
    }

    function dismissItem(item) {
        if (item && item.dismiss) item.dismiss()
        NotificationHistory.removeEntry(root.keyFor(item))
    }

    function dismissGroup(items) {
        items.slice().forEach(function(it) { root.dismissItem(it) })
    }

    // Rows for the list: { type: "single" | "group" | "child", ... }
    readonly property var displayRows: {
        var groups = []
        var byTitle = {}
        for (var i = 0; i < notificationList.length; i++) {
            var n = notificationList[i]
            var title = n.summary || "Notification"
            if (!byTitle[title]) {
                byTitle[title] = { title: title, items: [] }
                groups.push(byTitle[title])          // keeps newest-first order
            }
            byTitle[title].items.push(n)
        }

        var rows = []
        for (var g = 0; g < groups.length; g++) {
            var grp = groups[g]
            if (grp.items.length === 1) {
                rows.push({ type: "single", item: grp.items[0] })
                continue
            }
            var open = !!expandedGroups[grp.title]
            rows.push({ type: "group", title: grp.title, items: grp.items, item: grp.items[0], expanded: open })
            if (open)
                for (var c = 0; c < grp.items.length; c++)
                    rows.push({ type: "child", item: grp.items[c] })
        }
        return rows
    }

    // ============================================================
    // SIZE
    // ============================================================

    width: parent ? parent.width : 0
    

    // ============================================================
    // MAIN CARD
    // ============================================================

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: theme.surface
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // ====================================================
            // HEADER
            // ====================================================

            RowLayout {
                id: header
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Notifications"
                    color: theme.fg
                    font {
                        family: theme.font
                        pixelSize: 13
                        weight: Font.Bold
                    }
                }

                Text {
                    visible: notificationCount > 0
                    text: notificationCount
                    color: theme.accent
                    font {
                        family: theme.font
                        pixelSize: 12
                        weight: Font.Medium
                    }
                }

                Item { Layout.fillWidth: true }

                // Clear All
                MouseArea {
                    id: clearBtn
                    width: 28
                    height: 28
                    visible: notificationCount > 0
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: clearBtn.containsMouse ? Qt.rgba(theme.error.r, theme.error.g, theme.error.b, 0.15) : "transparent"
                        border.width: 1
                        border.color: clearBtn.containsMouse ? theme.error : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰎟"
                        color: clearBtn.containsMouse ? theme.error : theme.fg1
                        font {
                            family: theme.font
                            pixelSize: 14
                        }
                    }

                    onClicked: {
                        if (notifServer && notifServer.trackedNotifications) {
                            const list = notifServer.trackedNotifications.values.slice()
                            list.forEach(n => { if (n && n.dismiss) n.dismiss() })
                        }
                        NotificationHistory.clearAll()
                        root.expandedGroups = ({})
                    }
                }
            }

            // ====================================================
            // NOTIFICATION LIST
            // ====================================================

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !emptyState
                clip: true
                spacing: 6
                model: root.displayRows
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: rowRect
                    required property var modelData

                    readonly property bool isGroup: modelData.type === "group"
                    readonly property bool isChild: modelData.type === "child"
                    readonly property var item: modelData.item

                    width: listView.width
                    height: isChild ? 42 : 48
                    radius: 10
                    color: rowMouse.containsMouse ? theme.surfaceAlt : "transparent"

                    Behavior on color { ColorAnimation { duration: 100 } }

                    // Group: click toggles open/closed. Single/child: click dismisses.
                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (rowRect.isGroup) root.toggleGroup(rowRect.modelData.title)
                            else root.dismissItem(rowRect.item)
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: rowRect.isChild ? 24 : 10   // children indented under their group
                        anchors.rightMargin: 10
                        spacing: 10

                        // Accent bar (dimmer for children)
                        Rectangle {
                            width: 3
                            height: rowRect.isChild ? 22 : 28
                            radius: 2
                            color: theme.accent
                            opacity: rowRect.isChild ? 0.5 : 1
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            Row {
                                width: parent.width
                                spacing: 6

                                Text {
                                    width: Math.min(implicitWidth, parent.width - (countBadge.visible ? countBadge.width + 6 : 0))
                                    text: rowRect.isChild
                                        ? truncate(rowRect.item.body || rowRect.item.summary || "", 40)
                                        : truncate(rowRect.item.summary || "Notification", 28)
                                    color: theme.fg
                                    elide: Text.ElideRight
                                    font {
                                        family: theme.font
                                        pixelSize: 12
                                        weight: rowRect.isChild ? Font.Normal : Font.Medium
                                    }
                                }

                                // How many are in the group
                                Rectangle {
                                    id: countBadge
                                    visible: rowRect.isGroup
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: countText.implicitWidth + 10
                                    height: 16
                                    radius: 8
                                    color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.18)

                                    Text {
                                        id: countText
                                        anchors.centerIn: parent
                                        text: rowRect.isGroup ? rowRect.modelData.items.length : ""
                                        color: theme.accent
                                        font { family: theme.font; pixelSize: 10; weight: Font.Bold }
                                    }
                                }
                            }

                            // Body: latest one for a group, own body for single (children show it as title)
                            Text {
                                visible: !rowRect.isChild
                                width: parent.width
                                text: truncate(rowRect.item.body || "", 50)
                                color: theme.fg0
                                elide: Text.ElideRight
                                font {
                                    family: theme.font
                                    pixelSize: 11
                                }
                            }
                        }

                        Text {
                            text: {
                                const t = timeAgo(rowRect.item.timestamp)
                                return t === "now" ? "now" : t + " ago"
                            }
                            color: theme.fg1
                            font {
                                family: theme.font
                                pixelSize: 10
                            }
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Group only: clear the whole group
                        MouseArea {
                            id: clearGroupBtn
                            visible: rowRect.isGroup
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            Layout.alignment: Qt.AlignVCenter
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dismissGroup(rowRect.modelData.items)

                            Text {
                                anchors.centerIn: parent
                                text: "close"
                                color: clearGroupBtn.containsMouse ? theme.error : theme.fg1
                                font { family: "Material Symbols Outlined"; pixelSize: 16 }
                                scale: clearGroupBtn.containsMouse ? 1.1 : 1.0
                                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                            }
                        }

                        // Group only: expand / collapse arrow
                        Text {
                            visible: rowRect.isGroup
                            text: "expand_more"
                            color: theme.fg1
                            font { family: "Material Symbols Outlined"; pixelSize: 18 }
                            rotation: rowRect.isGroup && rowRect.modelData.expanded ? 180 : 0
                            Behavior on rotation { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }

            // ====================================================
            // EMPTY STATE
            // ====================================================

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true 
                visible: emptyState

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰂚"
                        color: theme.inactive
                        font {
                            family: theme.font
                            pixelSize: 48
                        }
                        opacity: 0.5
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No notifications"
                        color: theme.inactive
                        font {
                            family: theme.font
                            pixelSize: 12
                        }
                    }
                }
            }


        }
    }
}
