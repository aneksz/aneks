import QtQuick
import Quickshell // Imported to allow native process running if needed

MouseArea {
    id: root

    // -------- API --------
    property string icon: ""
    property color baseColor: "#ECEFF4"
    property color hoverColor: baseColor
    property var command: []

    // Custom Signal: Lets components/system.qml handle what happens on click safely
    signal triggered(var command)

    // REMOVED hardcoded width formula so it can respect RowLayout constraints perfectly
    height: 48 // SEAMLESS: Trimmed down from 60px to maintain a tighter visual line

    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    // -------- INTERACTION --------
    scale: pressed ? 0.95 : (containsMouse ? 1.04 : 1.0)

    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
    }

    // -------- SEAMLESS BACKGROUND BACKGROUND --------
    Rectangle {
        anchors.fill: parent
        radius: 10

        // SEAMLESS: No solid dark backplanes. Flat transparency until active.
        // On hover, it shows a subtle alpha glow using the button's specific utility color tint.
        color: root.containsMouse 
               ? Qt.rgba(root.baseColor.r, root.baseColor.g, root.baseColor.b, 0.12) 
               : "transparent"

        // SEAMLESS: Completely flat. No border line grid artifacts when resting.
        border.color: root.containsMouse ? root.baseColor : "transparent"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    // -------- ICON --------
    Text {
        anchors.centerIn: parent
        text: root.icon

        // Inherits native utility tone (Success green, Error red, etc.) or switches to custom hover
        color: root.containsMouse ? root.hoverColor : root.baseColor
        scale: root.containsMouse ? 1.05 : 1.0

        font.pointSize: 14 // Resized slightly from 18 to fit the sleeker vertical grid line
        font.family: typeof theme !== "undefined" ? theme.font : "JetBrainsMono Nerd Font"

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 120 } }
    }

    // -------- ACTION --------
    onClicked: {
        root.triggered(root.command)

        if (typeof vpnRunner !== "undefined") {
            vpnRunner.command = root.command
            vpnRunner.running = true
        } else {
            console.log("ActionButton clicked, command payload:", JSON.stringify(root.command))
        }
    }
}
