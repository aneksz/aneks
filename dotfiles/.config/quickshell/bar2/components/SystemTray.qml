// components/SystemTray.qml

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray as QuickshellTray

Item {
    id: trayRoot

    // =================================================
    // API
    // =================================================

    property var theme

    // Asks shell.qml to open the themed tray menu for this item
    signal menuRequested(var item)

    // Per-app icon size in px, keyed by the tray item's id (lower-case).
    // Apps not listed use defaultIconSize.
    readonly property var iconSizes: ({
        "spotify-client": 24,
        "chrome_status_icon_1": 18
    })
    readonly property int defaultIconSize: 20

    // Padding added around each icon to form its clickable slot
    readonly property int slotPadding: 10
    readonly property int menuYOffset: 11

    // =================================================
    // SIZE
    // =================================================

    implicitHeight: 30
    implicitWidth: trayRow.implicitWidth

    // =================================================
    // TRAY ITEMS
    // =================================================

    Row {
        id: trayRow

        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: QuickshellTray.SystemTray.items

            delegate: Item {
                id: trayItem

                required property var modelData

                readonly property int iconSize:
                    trayRoot.iconSizes[(modelData.id ?? "").toLowerCase()]
                    ?? trayRoot.defaultIconSize

                width: iconSize + trayRoot.slotPadding
                height: trayRoot.implicitHeight

                // ---------------------------------
                // ICON
                // ---------------------------------

                IconImage {
                    anchors.centerIn: parent

                    source: trayItem.modelData.icon
                    width: trayItem.iconSize
                    height: trayItem.iconSize
                    smooth: true
                    mipmap: true

                    opacity: trayMouse.containsMouse ? 1.0 : 0.85
                    scale: trayMouse.containsMouse ? 1.08 : 1.0

                    Behavior on opacity { NumberAnimation { duration: 120 } }
                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }
                }

                // ---------------------------------
                // INTERACTION
                // ---------------------------------

                MouseArea {
                    id: trayMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: function(mouse) {
                        const item = trayItem.modelData

                        // Themed menu drawn in the island (see TrayMenu.qml) instead of a native Qt menu
                        const showMenu = () => trayRoot.menuRequested(item)

                        if (mouse.button === Qt.LeftButton) {
                            if (item.onlyMenu && item.hasMenu)
                                showMenu()
                            else
                                item.activate()
                        } else if (mouse.button === Qt.RightButton && item.hasMenu) {
                            showMenu()
                        }
                    }
                }
            }
        }
    }
}
