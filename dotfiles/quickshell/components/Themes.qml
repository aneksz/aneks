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
    anchors.verticalCenter: parent.verticalCenter 
    visible: true

    property bool menuVisible: false
    required property string currentTheme
    required property var checkCurrent
    required property var getThemes
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
        getThemes.running = true
        checkCurrent.running = true
        root.menuVisible = !root.menuVisible
    }
}

    PopupWindow {
    visible: root.menuVisible
    color: "transparent"
    mask: null
    grabFocus: true
   

    onVisibleChanged: {
        if (!visible) {
            themeContent.state = ""
            root.menuVisible = false
        }
    }
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.margins.top: 34        
        anchor.margins.left: -180   

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
        
            opacity: 0
            transform: Translate { id: themeTranslate; y: -10 }

            states: State {
                name: "visible"
                when: root.menuVisible
                PropertyChanges { target: themeContent; opacity: 1 }
                PropertyChanges { target: themeTranslate; y: 0 }
            }

            transitions: [
                Transition {
                    from: ""; to: "visible"
                    ParallelAnimation {
                        NumberAnimation { properties: "opacity"; duration: 160; easing.type: Easing.OutQuad }
                        NumberAnimation { target: themeTranslate; property: "y"; duration: 200; easing.type: Easing.OutCubic }
                    }
                },
                Transition {
                    from: "visible"; to: ""
                    ParallelAnimation {
                        NumberAnimation { properties: "opacity"; duration: 120; easing.type: Easing.InQuad }
                        NumberAnimation { target: themeTranslate; property: "y"; duration: 140; easing.type: Easing.InCubic }
                    }
                }
            ]

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
                        width: 150
                        height: 30
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: modelData === root.currentTheme
                                ? theme.surface
                                : (parent.containsMouse ? theme.surface : "transparent")
                        }

                        Text {
                            anchors.centerIn: parent
                            text: (modelData === root.currentTheme ? "󰞑 " : "") + modelData
                            color: modelData === root.currentTheme
                                ? theme.accent
                                : theme.fg
                            font.family: theme.font 
                            font.weight: theme.fontWeight
                        }

                        onClicked: {
                            Quickshell.execDetached([
                                "sh", "-c",
                                "/home/igor/.config/themes/" + modelData + ".sh"
                            ])

                            root.menuVisible = false

                            Qt.callLater(() => {
                                themeLoader.source = ""
                                themeLoader.source =
                                    "file:///home/igor/.config/quickshell/Colors.qml?v=" + Date.now()
                                                      })
                        }
                    } 
                } 
            } 
        } 
    } 
} 
} 