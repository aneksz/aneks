// components/Wallpapers.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: root

    width: 32
    height: 30


    property bool popupVisible: false

    signal folderChanged(string folder)
    signal resolutionChanged(string folder)
    
    required property var themeFolders
    property bool themeMenuVisible: false
    property bool themeDropdownOpen: false

    property var filteredWallpapers: {
    if (root.currentThemeFolder === "")
        return wallpapers

    return wallpapers.filter(w =>
        w.includes("/" + root.currentThemeFolder + "/"))
}
    

    required property var theme  
    required property var wallpapers
    required property var applyWallpaper
    required property var wallpaperProc

    property string currentMonitor: "DP-1"
    property string currentResolutionFolder: "4K"

    property string currentThemeFolder: ""

    // ================= ICON =================
    HoverItem {
        anchors.fill: parent

        textValue: ""

        theme: root.theme
        hovered: wallpaperMouse.containsMouse

        overrideColor: root.popupVisible
            ? theme.accent
            : theme.warning
    }

    MouseArea {
        id: wallpaperMouse

        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.popupVisible = !root.popupVisible
        }
    }

    // ================= POPUP =================
    PopupWindow {
        id: wallpaperPopup

        visible: root.popupVisible || wallpaperCard.opacity > 0

        color: "transparent"
        mask: null
        grabFocus: false

        implicitWidth: 968
        implicitHeight: 620

        // ================= POSITION =================
        anchor.window: bar

        anchor.rect.x: 54
        anchor.rect.y: (bar.screen.height / 2) - (implicitHeight / 2)

        anchor.rect.width: implicitWidth 
        anchor.rect.height: implicitHeight

           // ================= CARD =================
    Rectangle {
        id: wallpaperCard

        width: 920
        height: 620

        color: theme.bg

        border.width: 1
        border.color: theme.surface

        radius: 24

    


            // ================= ANIMATION =================
            opacity: root.popupVisible ? 1 : 0
            scale: root.popupVisible ? 1 : 0.985

            transform: Translate {
              x: root.popupVisible ? 0 : -80

              Behavior on x {
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

            // ================= CONTENT =================
            Column {
                anchors.fill: parent
                anchors.margins: 20

                spacing: 18

                // ================= HEADER =================
Column {
    width: parent.width
    spacing: 14

    // ================= TOP BAR =================
    Row {
        width: parent.width
        spacing: 12

        Text {
            text: " Wallpaper Selector"

            color: theme.fg1

            font {
                family: theme.font
                pixelSize: 18
                bold: true
            }
        }

        Item {
            width: 1
            height: 1
            Layout.fillWidth: true
        }

        // ================= MONITOR SELECTOR =================
        Rectangle {
            width: 100
            height: 30

            radius: 12
            color: theme.surface

            Text {
                anchors.centerIn: parent

                text: root.currentResolutionFolder

                color: theme.fg1

                font {
                    family: theme.font
                    pixelSize: 12
                }
            }

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (root.currentMonitor === "DP-1") {
                        root.currentMonitor = "DP-3"
                        root.resolutionChanged("HD")
                    } else {
                        root.currentMonitor = "DP-1"
                        root.resolutionChanged("4K")
                    }

                    root.wallpaperProc.running = true
                }
            }
        }
    }

  }  

    PopupWindow {
    visible: root.themeMenuVisible

    color: "transparent"
    mask: null
    grabFocus: false

    implicitWidth: 180
    implicitHeight: themeColumn.implicitHeight + 16

    anchor.item: parent
    anchor.edges: Edges.Bottom
    anchor.margins.top: 38

    Rectangle {
        width: 180
        height: themeColumn.implicitHeight + 16

        radius: 14
        color: theme.bg

        border.width: 1
        border.color: theme.surface

        Column {
            id: themeColumn

            width: parent.width
            spacing: 4

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 8
            }

            Repeater {
                model: root.themeFolders

                delegate: Rectangle {
                    property string folderName: modelData

                    width: parent.width
                    height: 34

                    radius: 10

                    color: root.currentThemeFolder === folderName
                        ? theme.accent
                        : "transparent"

                    Text {
                        anchors.centerIn: parent

                        text: folderName === ""
                            ? "All Themes"
                            : folderName

                        color: theme.fg1

                        font {
                            family: theme.font
                            pixelSize: 11
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.currentThemeFolder = folderName
                            root.themeMenuVisible = false
                        }
                    }
                }
            }
        }
    }
}

   // ================= THEME DROPDOWN =================
Column {
    spacing: 6

    Rectangle {
        width: 100
        height: 34

        radius: 12
        color: theme.surface

        border.width: 1
        border.color: Qt.rgba(1,1,1,0.05)

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: root.currentThemeFolder === ""
                    ? "All Themes"
                    : root.currentThemeFolder

                color: theme.fg1

                font {
                    family: theme.font
                    pixelSize: 11
                }
            }

            Item {
                width: 1
                height: 1
                Layout.fillWidth: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: root.themeDropdownOpen ? "󰅀" : "󰅂"

                color: theme.textMuted

                font.pixelSize: 12
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.themeDropdownOpen =
                    !root.themeDropdownOpen
            }
        }
    }

    // ================= DROPDOWN CONTENT =================
    Column {
        visible: root.themeDropdownOpen

        spacing: 2

        Repeater {
            model: root.themeFolders

            delegate: Rectangle {
                property string folderName: modelData

                width: 140
                height: 30

                radius: 12

                color: root.currentThemeFolder === folderName
                    ? theme.accent
                    : "transparent"

                Text {
                    anchors.centerIn: parent

                    text: folderName === ""
                        ? "All Themes"
                        : folderName

                    color: theme.fg1

                    font {
                        family: theme.font
                        pixelSize: 11
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.currentThemeFolder = folderName
                        root.themeDropdownOpen = false
                    }
                }
            }
        }
    }
}

    // ================= WALLPAPER GRID =================
               GridView {
    id: wallpaperGrid

    width: parent.width
    height: parent.height - 80

    cellWidth: 215
    cellHeight: 130

    topMargin: 10
    leftMargin: 16
    rightMargin: 4
    bottomMargin: 10

    anchors.horizontalCenter: parent.horizontalCenter

    clip: true

    model: root.filteredWallpapers

    delegate: Rectangle {
        width: 200
        height: 110

        radius: 0
        color: theme.surface

        border.width: wallpaperMouse.containsMouse ? 2 : 1
        border.color: wallpaperMouse.containsMouse
            ? theme.accent
            : Qt.rgba(1,1,1,0.08)

        scale: wallpaperMouse.containsMouse ? 1.03 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        Image {
            anchors.fill: parent
            anchors.margins: 2

            source: "file://" + modelData

            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true

            clip: true
        }

        MouseArea {
            id: wallpaperMouse

            anchors.fill: parent
            hoverEnabled: true

            cursorShape: Qt.PointingHandCursor

            onClicked: {
    root.applyWallpaper.command = [
        "sh", "-c",
        `awww img "${modelData}" --outputs ${root.currentMonitor} --transition-type any`
    ]

    root.applyWallpaper.running = true
}
          }
        }
      }
     }

    }
  }
}