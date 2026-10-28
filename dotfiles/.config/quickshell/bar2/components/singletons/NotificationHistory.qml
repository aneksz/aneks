// components/singletons/NotificationHistory.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias entries: adapter.entries

    function addEntry(key, summary, body, timestamp, appName) {
        for (var i = 0; i < adapter.entries.length; i++) {
            if (adapter.entries[i].key === key) return   // already have it
        }
        var arr = adapter.entries.slice()
        arr.push({
            key: key,
            summary: summary,
            body: body,
            timestamp: timestamp,
            appName: appName
        })
        adapter.entries = arr
    }

    function removeEntry(key) {
        adapter.entries = adapter.entries.filter(e => e.key !== key)
    }

    function clearAll() {
        adapter.entries = []
    }

    FileView {
        path: Quickshell.statePath("notification_history.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: {}   // first-ever run, no file yet - defaults apply fine

        JsonAdapter {
            id: adapter
            property var entries: []
        }
    }
}
