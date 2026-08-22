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


// =================================================
// SIZE
// =================================================

implicitHeight:
    30

implicitWidth:
    trayRepeater.count > 0
    ? (
        trayRepeater.count * 24
        +
        (trayRepeater.count - 1) * 8
    )
    : 0


// =================================================
// TRAY ITEMS
// =================================================

Row {
    id: trayRow

    anchors.verticalCenter:
        parent.verticalCenter

    spacing:
        8


    Repeater {
        id: trayRepeater

        model:
            QuickshellTray.SystemTray.items


        delegate:
            Item {

                id:
                    trayItem


                required property var modelData


                width:
                    24

                height:
                    24


                // ---------------------------------
                // ICON
                // ---------------------------------

                IconImage {

                    id:
                        trayIcon


                    anchors.centerIn:
                        parent


                    source:
                        modelData.icon


                    implicitSize:
                        20


                    smooth:
                        true


                    opacity:
                        trayMouse.containsMouse
                        ? 1.0
                        : 0.85


                    scale:
                        trayMouse.containsMouse
                        ? 1.08
                        : 1.0


                    Behavior on opacity {

                        NumberAnimation {

                            duration:
                                120
                        }
                    }


                    Behavior on scale {

                        NumberAnimation {

                            duration:
                                120


                            easing.type:
                                Easing.OutCubic
                        }
                    }
                }


                // ---------------------------------
                // INTERACTION
                // ---------------------------------

                MouseArea {

                    id:
                        trayMouse


                    anchors.fill:
                        parent


                    hoverEnabled:
                        true


                    cursorShape:
                        Qt.PointingHandCursor


                    acceptedButtons:
                        Qt.LeftButton |
                        Qt.RightButton


                    onClicked:
                        function(mouse) {




                            var parentWindow =
                                QsWindow.window


                            var iconBottom =
                                trayItem.mapToItem(
                                    null,
                                    0,
                                    trayItem.height
                                )


                            var yOffset =
                                11


                            if (
                                mouse.button ===
                                Qt.LeftButton
                            ) {

                                if (
                                    modelData.onlyMenu &&
                                    modelData.hasMenu
                                ) {

                                    modelData.display(
                                        parentWindow,
                                        iconBottom.x,
                                        iconBottom.y +
                                        yOffset
                                    )

                                } else {

                                    modelData.activate()
                                }
                            }


                            else if (
                                mouse.button ===
                                Qt.RightButton &&
                                modelData.hasMenu
                            ) {

                                modelData.display(
                                    parentWindow,
                                    iconBottom.x,
                                    iconBottom.y +
                                    yOffset
                                )
                            }
                        }
                }
            }
    }
 }
}
