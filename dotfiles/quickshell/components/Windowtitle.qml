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

// ============ WINDOW TITLE  ================
Item {
    id: root
    height: parent.height
    width: 350
    clip: true


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

        if (!cls && !title) return "";

       
        if (cls.includes("whatsapp")) return "";
        if (cls.includes("spotify")) return "";
        if (cls.includes("brave")) return "";
        if (cls.includes("kitty") || cls.includes("alacritty")) return "";
        if (cls.includes("nautilus")) return "󰉋";
        if (cls.includes("discord")) return "";
        if (cls.includes("code") || cls.includes("codium")) return "";
        if (cls.includes("steam")) return "󰓓";
        
        
        if (title.includes("whatsapp")) return "󰖣";
        if (title.includes(".qml") || title.includes("vscodium")) return "";
        if (title.includes(" - ")) return "";
   

        return "";
    }

    Row {
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
            width: 250
            verticalAlignment: Text.AlignVCenter
            text: root.winTitle !== "" ? root.winTitle : "Desktop"
            color: "white"
            font.family: theme.font
            font.pointSize: theme.fontSize
            elide: Text.ElideRight
        }
    }
  }