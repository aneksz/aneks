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
        : theme.textMuted
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
    
    visible: root.popupVisible
    color: "transparent"
    mask: null
    grabFocus: true

    onVisibleChanged: {
        if (!visible) {
            vpnContent.state = ""
            root.popupVisible = false
        }
    }

    anchor.item: root
    anchor.edges: Quickshell.Bottom | Quickshell.Left
    anchor.margins.top: 38
    anchor.margins.left: -180

    implicitWidth: 200
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

            // 🎬 animation
            opacity: 0
            transform: Translate { id: vpnTranslate; y: -10 }

            states: State {
                name: "visible"
                when: root.popupVisible
                PropertyChanges { target: vpnContent; opacity: 1 }
                PropertyChanges { target: vpnTranslate; y: 0 }
            }

            transitions: [
                Transition {
                    from: ""; to: "visible"
                    ParallelAnimation {
                        NumberAnimation { properties: "opacity"; duration: 160; easing.type: Easing.OutQuad }
                        NumberAnimation { target: vpnTranslate; property: "y"; duration: 200; easing.type: Easing.OutCubic }
                    }
                },
                Transition {
                    from: "visible"; to: ""
                    ParallelAnimation {
                        NumberAnimation { properties: "opacity"; duration: 120; easing.type: Easing.InQuad }
                        NumberAnimation { target: vpnTranslate; property: "y"; duration: 140; easing.type: Easing.InCubic }
                    }
                }
            ]

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
        width: 176
        height: 36
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