// components/Vpn.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

// ================ VPN ================================
Item {
    id: root
    visible: true

    required property var theme
    required property var vpnRunner
    required property string name
    required property bool active
    required property var configs

    property bool popupVisible: false

    // ===== LABEL =====
    property string label: root.active
        ? "󰦝 " + root.name
        : "󱦚 VPN"

    // ===== REAL WIDTH (SAFE) =====
    Text {
        id: measureText
        text: root.label
        font.family: theme.font
        font.pointSize: theme.fontSize
        visible: false
    }

    width: Math.max(measureText.implicitWidth + 20, 60)
    height: 30

    anchors.verticalCenter: parent.verticalCenter

    // ===== VISUAL =====
    HoverItem {
    anchors.fill: parent
    textValue: root.label
    theme: root.theme
    hovered: mouseArea.containsMouse

    overrideColor: root.active
        ? theme.accent
        : theme.fg
  }
    // ===== INPUT =====
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.popupVisible = !root.popupVisible
    }
                
    PopupWindow {
    
    visible: root.popupVisible || vpnContent.opacity > 0
    color: "transparent"
    mask: null
    grabFocus: false

    onVisibleChanged: {
        if (!visible) {
            vpnContent.state = ""
            root.popupVisible = false
        }
    }

    anchor.item: root
    anchor.edges: Quickshell.Bottom | Quickshell.Left
    anchor.margins.top: 38
    anchor.margins.left: -140

    implicitWidth: 160
    implicitHeight: vpnCol.implicitHeight + 28

    Item {
        anchors.fill: parent

        Rectangle {
            id: vpnContent
            anchors.fill: parent
            radius: 12
            color: theme.bg
            border.color: theme.surface
            border.width: 1

            // ================= ANIMATION =================
opacity: root.popupVisible ? 1 : 0
scale: root.popupVisible ? 1 : 0.98

transform: Translate {
    y: root.popupVisible ? 0 : -30

    Behavior on y {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }
}

Behavior on opacity {
    NumberAnimation {
        duration: 300
    }
}

Behavior on scale {
    NumberAnimation {
        duration: 260
        easing.type: Easing.OutCubic
    }
}

            Column {
    id: vpnCol
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 12
    width: 176
    spacing: 10

    // -------- TITLE --------
    Text {
        width: parent.width
        text: "VPN CONNECTIONS"
        color: theme.inactive
        font.family: theme.font
        font.pointSize: 10
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }

    // -------- LIST --------
    Repeater {
        model: root.configs

        delegate: MouseArea {
            width: 176
            height: 32
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: parent.containsMouse ? theme.surface : "transparent"
            }

            Text {
                anchors.centerIn: parent
                text: modelData
                color: parent.containsMouse ? theme.accent : theme.fg
                font.family: theme.font
            }

            onClicked: {
                root.vpnRunner.command = ["sudo", "wg-quick", "up", modelData]
                root.vpnRunner.running = true
                root.popupVisible = false
            }
        }
    }

    // -------- DIVIDER --------
    Rectangle {
        width: parent.width - 20
        height: 1
        color: theme.surface
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.active
    }

    // -------- DISCONNECT --------
    MouseArea {
        width: 120
        height: 36
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.active
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: parent.containsMouse ? theme.surface : "transparent"
            border.color: parent.containsMouse ? theme.accent : "transparent"
            border.width: 1
        }

        Text {
            anchors.centerIn: parent
            text: "DISCONNECT"
            color: theme.accent
            font.family: theme.font
            font.bold: true
        }

        onClicked: {
 root.vpnRunner.command = ["sudo", "wg-quick", "down", root.name]
   root. vpnRunner.running = true
    root.popupVisible = false
}
    }
}
   }
 }
}  
}