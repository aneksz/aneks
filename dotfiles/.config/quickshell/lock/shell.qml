// ~/.config/quickshell/lock/shell.qml
import Quickshell
import Quickshell.Wayland

ShellRoot {
    LockContext {
        id: lockContext
        onUnlocked: {
            lock.locked = false
            Qt.quit()
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            id: lockSurface
            color: "black"

            LockSurface {
                anchors.fill: parent
                context: lockContext
                screenName: lockSurface.screen ? lockSurface.screen.name : ""
            }
        }
    }
}