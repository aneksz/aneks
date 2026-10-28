// components/singletons/ToggleState.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias nightLightEnabled: adapter.nightLightEnabled
    property alias caffeineEnabled: adapter.caffeineEnabled
    property alias dndEnabled: adapter.dndEnabled
    property bool bootChecked: false  

    FileView {
        id: fileView
        path: Quickshell.statePath("toggles.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoaded: bootIdCheck.running = true
        onLoadFailed: bootIdCheck.running = true   
        JsonAdapter {
            id: adapter
            property bool nightLightEnabled: false
            property bool caffeineEnabled: false
            property bool dndEnabled: false
            property string bootId: ""
        }
    }

    Process {
        id: bootIdCheck
        command: ["cat", "/proc/sys/kernel/random/boot_id"]
        stdout: StdioCollector {
            onStreamFinished: {
                const currentBoot = text.trim()
                if (adapter.bootId !== currentBoot) {
                    adapter.nightLightEnabled = false
                    adapter.caffeineEnabled = false
                    adapter.dndEnabled = false
                    adapter.bootId = currentBoot
                }
                root.bootChecked = true
            }
        }
    }
}
