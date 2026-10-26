import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray as QuickshellTray

Item {
    id: trayRoot

    required property var theme

    property bool expanded: false

    implicitHeight: theme.vertical
        ? (expanded ? trayRow.implicitHeight : collapsedIcon.implicitHeight)
        : 30
    implicitWidth: theme.vertical
        ? 30
        : (expanded ? trayRow.implicitWidth : collapsedIcon.implicitWidth)

    Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    // ================= COLLAPSE DEBOUNCE =================
    // Prevents flicker: the hover boundary itself moves while
    // trayRoot resizes, so a brief boundary-crossing mid-animation
    // shouldn't immediately collapse it back.
    Timer {
        id: collapseTimer
        interval: 250
        onTriggered: trayRoot.expanded = false
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true

        onContainsMouseChanged: {
            if (containsMouse) {
                collapseTimer.stop()
                trayRoot.expanded = true
            } else {
                collapseTimer.restart()
            }
        }
    }

    // ================= COLLAPSED INDICATOR =================
    Text {
        id: collapsedIcon
        visible: !trayRoot.expanded
        anchors.centerIn: parent
        text: "󰄝"
        color: theme.fg1
        font { family: theme.font; pointSize: theme.fontSize }

        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // ================= EXPANDED TRAY =================
    Flow {
        id: trayRow
        visible: trayRoot.expanded
        opacity: trayRoot.expanded ? 1 : 0

        flow: theme.vertical ? Flow.TopToBottom : Flow.LeftToRight
        spacing: 8

        Behavior on opacity { NumberAnimation { duration: 150 } }

        Repeater {
            // Protects the global engine from file namespace clashing loops
            model: QuickshellTray.SystemTray.items

            delegate: Item {
                id: trayItem

                required property var modelData

                width: 24
                height: 24

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
