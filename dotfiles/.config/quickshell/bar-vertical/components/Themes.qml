// components/Themes.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

// ============== THEME SELECTOR =================

Item {
    id: root
    width: 32; height: 30

    property bool menuVisible: false
    required property string currentTheme
    required property var runGetThemes
    required property var runCheckCurrent
    required property var themeLoader
    required property var theme
    required property var themes

    HoverItem {
    anchors.fill: parent
    textValue: ""
    theme: root.theme
    hovered: mouseArea.containsMouse

    overrideColor: root.menuVisible
        ? theme.accent
        : theme.textMuted
}

MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
    root.runGetThemes()
    root.runCheckCurrent()
    root.menuVisible = !root.menuVisible
}
}

Timer {
    id: themeUpdateTimer
    interval: 1200
    repeat: false
    onTriggered: {
        root.runCheckCurrent()
        root.themeLoader.source = ""
        root.themeLoader.source =
            "file:///home/igor/.config/quickshell/Colors.qml?v=" + Date.now()
    }
}


    PopupWindow {
    visible: root.menuVisible || themeContent.opacity > 0
    color: "transparent"
    mask: null
    grabFocus: false
   

    onVisibleChanged: {
        if (!visible) {
            themeContent.state = ""
            root.menuVisible = false
        }
    }
        anchor.item: root
        anchor.edges: theme.vertical ? Edges.Right : Edges.Bottom
        anchor.margins.top: theme.vertical ? 0 : 34
        anchor.margins.left: theme.vertical ? 40 : -180

        implicitWidth: 180
        implicitHeight: themeColumn.implicitHeight + 30
    Item {
        anchors.fill: parent
        

        Rectangle {
            id: themeContent
            width: 170
            height: themeColumn.implicitHeight + 24
            anchors.centerIn: parent
            radius: 12
            border.width: 1
            border.color: theme.surface
            color: themeLoader.item?.bg ?? theme.surface
        
    // ================= ANIMATION =================
opacity: root.menuVisible ? 1 : 0
scale: root.menuVisible ? 1 : 0.98

transform: Translate {
    y: root.menuVisible ? 0 : -30

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
    id: themeColumn

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 12

    width: 150
    spacing: 8

    Repeater {
        model: root.themes


   delegate: MouseArea {
    width: parent.width
    height: 30

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Rectangle {
        anchors.fill: parent

        radius: 6

        color: modelData === root.currentTheme
            ? theme.surface
            : (parent.containsMouse
                ? Qt.rgba(
                    theme.surface.r,
                    theme.surface.g,
                    theme.surface.b,
                    0.6
                )
                : "transparent")

        border.width: parent.containsMouse ? 1 : 0

        border.color: parent.containsMouse
            ? Qt.rgba(1,1,1,0.06)
            : "transparent"

        scale: parent.containsMouse ? 1.02 : 1

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 120
            }
        }

        // Tick icon
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 18

            width: 16

            horizontalAlignment: Text.AlignHCenter

            text: modelData === root.currentTheme
                ? "󰞑"
                : ""

            color: theme.accent

            font.family: theme.font
            font.weight: Font.Bold
            font.pixelSize: 12
        }

        // Theme name
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 42

            text: modelData

            color: modelData === root.currentTheme
                ? theme.accent
                : theme.fg

            font.family: theme.font
            font.weight: theme.fontWeight
            font.pixelSize: 12
        }
    }

    onClicked: {
    root.currentTheme = modelData

    Quickshell.execDetached([
        "sh", "-c",
        "echo '" + modelData + "' > /home/igor/.config/.current_theme && " +
        "/home/igor/.config/themes/apply-theme.sh '" + modelData + "'"
    ])

    root.menuVisible = false

    themeUpdateTimer.restart()
}
}
         }
       }
     }
   }
  }
}

