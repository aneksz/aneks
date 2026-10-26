import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root

    required property var theme

    property bool popupVisible: false
    property bool vpnActive: false
    property string vpnType: ""

    height: 30
    implicitWidth: content.implicitWidth + 14

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    // ================= STATE CHECK =================
    Process {
        id: vpnCheck
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]

        stdout: SplitParser {
            onRead: (data) => {
                vpnActive = data.includes("wireguard")
                vpnType = vpnActive ? "Surfshark (WG)" : ""
            }
        }
    }

    // ================= MAIN BUTTON =================
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.popupVisible = !root.popupVisible

        Row {
            id: content
            anchors.centerIn: parent
            spacing: 6

            HoverItem {
                textValue: vpnActive ? "󰦝" : "󱦚"
                theme: root.theme
                hovered: mouseArea.containsMouse
                overrideColor: vpnActive ? theme.accent : theme.fg
            }

            Text {
                text: vpnType
                visible: vpnActive
                opacity: vpnActive ? 1 : 0
                color: theme.fg

                font {
                    family: theme.font
                    pointSize: theme.fontSize
                }

                Behavior on opacity {
                    NumberAnimation { duration: 160 }
                }
            }
        }
    }

    // ================= POPUP (INFO ONLY) =================
    PopupWindow {
        visible: root.popupVisible && vpnActive
        color: "transparent"
        grabFocus: false

        anchor.item: root
        anchor.edges: Quickshell.Bottom | Quickshell.Left
        anchor.margins.top: 38
        anchor.margins.left: -140

        implicitWidth: 180
        implicitHeight: 90

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: theme.bg
            border.color: theme.surface
            border.width: 1

            opacity: root.popupVisible ? 1 : 0
            scale: root.popupVisible ? 1 : 0.98

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "VPN STATUS"
                    color: theme.inactive
                    font.family: theme.font
                    font.pointSize: 10
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: vpnType
                    color: theme.fg
                    font.family: theme.font
                }

                Text {
                    text: "WireGuard (NetworkManager)"
                    color: theme.inactive
                    font.family: theme.font
                    font.pointSize: 9
                }
            }
        }
    }
}