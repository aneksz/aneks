import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray as QuickshellTray

Item {
    id: trayRoot

    required property var theme

    implicitHeight: 30
    implicitWidth: trayRow.implicitWidth

    Row {
        id: trayRow

        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Repeater {
            // Protects the global engine from file namespace clashing loops
            model: QuickshellTray.SystemTray.items

            delegate: Item {
                id: trayItem

                required property var modelData

                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter

                // ================= ICON VISUALS =================
                IconImage {
                    id: icon

                    anchors.centerIn: parent
                    source: modelData.icon
                    implicitSize: 20
                    smooth: true
                    anchors.verticalCenterOffset: 2
                    
                    opacity: mouseArea.containsMouse ? 1.0 : 0.85
                    scale: mouseArea.containsMouse ? 1.08 : 1.0

                    Behavior on opacity { NumberAnimation { duration: 120 } }
                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }
                }

                // ================= INPUT HANDLING =================
                MouseArea {
                    id: mouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: function(mouse) {
                var parentWindow = QsWindow.window;
                var iconBottom = trayItem.mapToItem(null, 0, trayItem.height);

                const yOffset = 11;

                if (mouse.button === Qt.LeftButton) {
                if (modelData.onlyMenu && modelData.hasMenu) {
                modelData.display(parentWindow, iconBottom.x, iconBottom.y + yOffset);
               } else {
                  modelData.activate();
               }
            }  
                else if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                modelData.display(parentWindow, iconBottom.x, iconBottom.y + yOffset);
              }
            }
                }
            }
        }
    }
}
