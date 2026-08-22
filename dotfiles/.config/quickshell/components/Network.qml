// components/Network.qml
import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property var networkData
    required property var theme

    implicitWidth: networkIcon.implicitWidth + 10
    implicitHeight: 30

    Text {
        id: networkIcon

        anchors.centerIn: parent

        text: networkData.connected
            ? "󰱓"
            : "󰅛"

        color: networkData.connected
            ? theme.accent
            : "#e06c75"

        font {
            family: theme.font
            pointSize: theme.fontSize
        }
    }
    // ================= HOVER =================
      MouseArea {
         id: mouseArea

         anchors.fill: parent
         hoverEnabled: true
       }
    // ================= POPUP =================
PopupWindow {
    id: popup

    visible: mouseArea.containsMouse &&
             root.Window.window !== null

    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    anchor.margins {
        top: 38
    }

    color: "transparent"

    implicitWidth: card.implicitWidth + 2
    implicitHeight: card.implicitHeight + 2
   
    Rectangle {
    id: card

    anchors.centerIn: parent

    radius: 16
    color: theme.bg

    border.width: 1
    border.color: theme.surface

    implicitWidth: content.implicitWidth + 28
    implicitHeight: content.implicitHeight + 28

    // ================= ANIMATION =================
opacity: mouseArea.containsMouse ? 1 : 0
scale: mouseArea.containsMouse ? 1 : 0.96

transform: Translate {
    y: mouseArea.containsMouse ? 0 : -4
}

Behavior on opacity {
    NumberAnimation {
        duration: 160
    }
}

Behavior on scale {
    NumberAnimation {
        duration: 220
        easing.type: Easing.OutCubic
    }
  }
  // ================= CONTENT =================
Column {
    id: content

    anchors.centerIn: parent
    spacing: 10

    // ================= HEADER =================
    Text {
        text: networkData.connected
            ? "󰱓 Connected"
            : "󰅛 Disconnected"

        color: networkData.connected
            ? theme.accent
            : "#e06c75"

        font {
            family: theme.font
            pixelSize: 15
            bold: true
        }
    }

    // ================= DIVIDER =================
    Rectangle {
        width: 220
        height: 1

        color: Qt.rgba(1,1,1,0.08)
    }

    // ================= DETAILS =================
    Column {
        spacing: 6

        Row {
            spacing: 40

            Text {
                text: "Interface"
                color: theme.inactive
                width: 80
            }

            Text {
                text: networkData.iface || "--"
                color: theme.fg1
            }
        }

        Row {
            spacing: 40

            Text {
                text: "IP Address"
                color: theme.inactive
                width: 80
            }

            Text {
                text: networkData.ip || "--"
                color: theme.fg1
            }
        }

        Row {
            spacing: 40

            Text {
                text: "Download"
                color: theme.inactive
                width: 80
            }

            Text {
                text: networkData.totalDown || "--"
                color: theme.fg1
            }
        }

        Row {
            spacing: 40

            Text {
                text: "Upload"
                color: theme.inactive
                width: 80
            }
     
            Text {
                text: networkData.totalUp || "--"
                color: theme.fg1
               }
        }
               
            Row {
    spacing: 40

    Text {
        text: "Type"
        color: theme.inactive
        width: 80
    }

    Text {
        text: networkData.type || "--"
        color: theme.fg1
    }
}
Row {
    spacing: 40

    Text {
        text: "Connected"
        color: theme.inactive
        width: 80
    }

    Text {
        text: networkData.connectedTime || "--"
        color: theme.fg1
    }
}
Row {
    spacing: 40

    Text {
        text: "Down"
        color: theme.inactive
        width: 80
    }

    Text {
        text: networkData.down || "--"
        color: theme.fg1
    }
}

Row {
    spacing: 40

    Text {
        text: "Up"
        color: theme.inactive
        width: 80
    }

    Text {
        text: networkData.up || "--"
        color: theme.fg1
    }
}
            }
         }
      }
    }
  }
