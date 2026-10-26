// components/Windowtitle.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

// ============ WINDOW TITLE ================
Item {
    id: root

    required property var theme

    height: theme.vertical ? verticalDisplay.implicitHeight : parent.height

    implicitWidth: theme.vertical ? verticalDisplay.implicitWidth : titleRow.implicitWidth
    width: theme.vertical ? implicitWidth : Math.min(implicitWidth, 300)

    clip: true

    Behavior on width {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    property string winClass: ""
    property string winTitle: ""

    Process {
    id: hyprProc
    command: ["hyprctl", "-j", "activewindow"]
    running: true

    stdout: StdioCollector {
        waitForEnd: true   // 🔥 IMPORTANT

        onTextChanged: {
            try {
                let data = JSON.parse(text.trim())

                root.winClass = (data.class || "").toLowerCase()
                root.winTitle = (data.title || "").toLowerCase()
               
            } catch (e) {
                // ignore
            }
        }
    }
}

    
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: hyprProc.running = true
    }

    
    property string currentIcon: {
        let cls = winClass;
        let title = winTitle;

        if (!cls && !title) return "󰍹";

       
        if (cls.includes("whatsapp")) return "";
        if (cls.includes("spotify")) return "";
        if (cls.includes("brave")) return "";
        if (cls.includes("kitty") || cls.includes("alacritty")) return "";
        if (cls.includes("nautilus")) return "󰉋";
        if (cls.includes("discord")) return "";
        if (cls.includes("code") || cls.includes("codium")) return "";
        if (cls.includes("steam")) return "󰓓";
        if (cls.includes("org.qbittorrent.qBittorrent")) return "󰅢";
        
        
        if (title.includes("whatsapp")) return "󰖣";
        if (title.includes("qbittorrent")) return "󰅢";
        if (title.includes(".qml") || title.includes("vscodium")) return "";
        if (title.includes(" - ")) return "";
   

        return "󰍹";
    }

    // ================= VERTICAL: ICON + ROTATED TITLE, ALWAYS VISIBLE =================
    Column {
        id: verticalDisplay
        visible: theme.vertical
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        Item {
            id: titleWrapper
            anchors.horizontalCenter: parent.horizontalCenter
            width: rotatedText.contentHeight
            height: 140   // <-- max vertical space the title may take; tune to taste

            Text {
                id: rotatedText
                anchors.centerIn: parent
                text: root.winTitle !== "" ? root.winTitle : "Desktop"
                color: theme.fg1
                font { family: theme.font; pointSize: theme.fontSize  }
                rotation: -90
                transformOrigin: Item.Center
                width: titleWrapper.height
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
        } 

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: theme.fontSize
            font.weight: theme.fontWeight
            font.family: theme.font
            color: theme.accent
            text: root.currentIcon
        }

        
    }

    // ================= HORIZONTAL: ICON + TITLE =================
    Row {
        id: titleRow
        visible: !theme.vertical
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        height: parent.height

        Text {
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            font.pointSize: theme.fontSize
            font.weight: theme.fontWeight
            font.family: theme.font
            color: theme.accent
            text: root.currentIcon
        }

      Text {
    height: parent.height

    width: Math.min(implicitWidth, 220)

    verticalAlignment: Text.AlignVCenter

    text: root.winTitle !== "" ? root.winTitle : "Desktop"

    color: "white"

    font.family: theme.font
    font.pointSize: theme.fontSize

    elide: Text.ElideRight

    Behavior on width {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
      }
    }
  }
}