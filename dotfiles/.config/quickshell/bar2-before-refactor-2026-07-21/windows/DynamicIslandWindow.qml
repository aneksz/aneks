import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland


PanelWindow {
    id: win


    // ============================================================
    // WINDOW
    // ============================================================

    anchors {
        top: true
        left: true
        right: true
    }


    margins {
        top: 0
    }


    color: "transparent"

    implicitHeight: 800

    exclusiveZone: 50


    mask: Region {
        item: island
    }



    // ============================================================
    // ISLAND
    // ============================================================

    Rectangle {
        id: island

        Component.onCompleted: {
    console.log("ISLAND CREATED")
}


        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }


        width: globalRoot.panelVisible ? 520 : 180
        height: globalRoot.panelVisible ? 680 : 42


        color: "#222222"



        // ========================================================
        // TOP LEFT TEST AREA
        // ========================================================

        Rectangle {
            id: testBox

            width: 100
            height: 30

            color: "red"

            anchors {
                left: parent.left
                top: parent.top

                leftMargin: 20
                topMargin: 13
            }

            z: 10
        }



        // ========================================================
        // SYSTEM PANEL
        // ========================================================

        Loader {
            id: systemPanelLoader


            active: true
            visible: globalRoot.panelVisible


            width: parent.width - 40


            anchors {
                horizontalCenter: parent.horizontalCenter

                top: parent.top
                topMargin: 60
            }


            z: 5


            source: "../components/System.qml"


            onLoaded: {

                if (!item)
                    return


                item.theme = theme
                item.globalClock = clock


                item.cpuUsage =
                    Qt.binding(() => globalRoot.cpuUsage)

                item.cpuTemp =
                    Qt.binding(() => globalRoot.cpuTemp)

                item.gpuTemp =
                    Qt.binding(() => globalRoot.gpuTemp)

                item.ramUsage =
                    Qt.binding(() => globalRoot.ramUsage)

                item.dataUsage =
                    Qt.binding(() => globalRoot.dataUsage)

                item.homeUsage =
                    Qt.binding(() => globalRoot.homeUsage)

                item.systemUptime =
                    Qt.binding(() => globalRoot.systemUptime)

                item.dndEnabled =
                    Qt.binding(() => globalRoot.dndEnabled)

                item.panelVisible =
                    Qt.binding(() => globalRoot.panelVisible)
            }
        }
    }
}