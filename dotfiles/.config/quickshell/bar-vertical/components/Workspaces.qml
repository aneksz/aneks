// components/Workspaces.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import Quickshell.Hyprland

Item {
    id: root

    required property var theme

    property int activeWs: Hyprland.focusedWorkspace?.id ?? 1

    implicitWidth: wsRow.implicitWidth
    implicitHeight: wsRow.implicitHeight
    width: implicitWidth
    height: implicitHeight

    // ================= WORKSPACES (step 4: real pill sizing/animation) =================
    Grid {
        id: wsRow
        columns: 1
        spacing: 10
        anchors.centerIn: parent

        Repeater {
            model: [1, 2, 3, 4, 5, 6]

            delegate: Item {
                id: wsItem

                property int wsId: modelData
                property bool isActive: root.activeWs === wsId
                property bool isHovered: mouseArea.containsMouse

                width: 42
                height: 14

                Rectangle {
                    id: pill

                    anchors.centerIn: parent

                    height: 16
                    width: isActive
                        ? 34
                        : (isHovered ? 30 : 24)

                    radius: height / 2
                    antialiasing: true

                    color: isActive
                        ? theme.accent
                        : (isHovered ? theme.activeWs : theme.inactive)

                    opacity: isActive
                        ? 1.0
                        : (isHovered ? 0.9 : 0.65)

                    Behavior on width {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        Hyprland.dispatch(
                            `hl.dsp.focus({ workspace = "${wsId}" })`
                        )
                    }
                }
            }
        }
    }
}