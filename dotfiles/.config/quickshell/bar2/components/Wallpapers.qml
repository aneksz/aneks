// components/Wallpapers.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // =====================================================
    // LAYOUT
    // =====================================================

    anchors.fill:
        parent

    // =====================================================
    // EXTERNAL DATA
    // =====================================================

    property var theme
    property var themeFolders
    property var wallpapers
    property var applyWallpaper
    property var wallpaperProc

    // =====================================================
    // SIGNALS
    // =====================================================

    signal closeRequested()
    signal folderChanged(string folder)
    signal resolutionChanged(string folder)

    // =====================================================
    // UI STATE
    // =====================================================

    property bool themeDropdownOpen: false

    // =====================================================
    // DISPLAY STATE
    // =====================================================

    property string currentMonitor: "DP-1"

    property string currentResolutionFolder: "4K"

    property string currentThemeFolder: ""

    // =====================================================
    // FILTERED WALLPAPERS
    // =====================================================

    property var filteredWallpapers: {

        if (
            !root.wallpapers
        ) {
            return []
        }


        if (
            root.currentThemeFolder === ""
        ) {
            return root.wallpapers
        }


        return root.wallpapers.filter(
            wallpaper =>
                wallpaper.includes(
                    "/" +
                    root.currentThemeFolder +
                    "/"
                )
        )
    }
    // =====================================================
    // MAIN CARD
    // =====================================================

    Rectangle {
        id: wallpaperCard
        anchors.fill: parent
        color: root.theme.bg
        radius: 24

        // =================================================
        // CONTENT
        // =================================================

        Column {
            id: contentColumn


            anchors { fill: parent; margins: 20 }


            spacing:
                14
            // =============================================
            // HEADER
            // =============================================

            Row {
                id: headerRow
                width: parent.width
                height: 34
                spacing: 12
                // =========================================
                // TITLE
                // =========================================

                Text {
                    text:
                        " Wallpapers"

                    color: root.theme.fg1


                    font {
                        family:
                            root.theme.font
                            pixelSize: 16
                            weight: root.theme.fontWeight
                    }
                     anchors.verticalCenter: parent.verticalCenter
                }

                // =========================================
                // SPACER
                // =========================================

                Item {
                    Layout.fillWidth: true
                }

                // =========================================
                // RESOLUTION BUTTON
                // =========================================

                Rectangle {
                    id: resolutionButton
                    width: 100
                    height: 30
                    radius: 12

                    color: root.theme.surface
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: root.currentResolutionFolder
                        color: root.theme.fg1

                        font {
                            family: root.theme.font
                            pixelSize: 12
                        }
                    }

                    MouseArea {
    anchors.fill: parent

    cursorShape: Qt.PointingHandCursor

    onClicked: {
    if (root.currentResolutionFolder === "4K") {
        root.currentMonitor = "DP-3"
        root.currentResolutionFolder = "HD"
    } else {
        root.currentMonitor = "DP-1"
        root.currentResolutionFolder = "4K"
    }

    root.currentThemeFolder = ""

    root.resolutionChanged(
        root.currentResolutionFolder
    )
}
}
                }

                // =========================================
                // CLOSE BUTTON
                // =========================================

                Rectangle {
                    id: closeButton
                    width: 30
                    height: 30
                    radius: 15

                    color:
                        closeMouse.containsMouse
                        ? root.theme.surfaceAlt
                        : "transparent"

                    anchors.verticalCenter: parent.verticalCenter


                    Text {
                        anchors.centerIn: parent


                        text: "󰅖"

                        color:
                            closeMouse.containsMouse
                            ? root.theme.error
                            : root.theme.fg1

                        font {
                            family: root.theme.font
                            pixelSize: 16
                        }
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeRequested()
                    }
                }
            }

            // =============================================
            // THEME SELECTOR
            // =============================================

            Rectangle {
                id: themeSelector
                width: 140
                height: 34
                radius: 12
                color: root.theme.surface

                border {
                    width: 1
                     color:
                        Qt.rgba(1,1,1,0.05)
                }

                Row {
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                    }
                    spacing: 6

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 25

                        text:
                            root.currentThemeFolder === ""
                            ? "All Themes"
                            : root.currentThemeFolder

                        color: root.theme.fg1
                        elide: Text.ElideRight

                        font {
                            family: root.theme.font
                            pixelSize: 11
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text:
                            root.themeDropdownOpen
                            ? "󰅀"
                            : "󰅂"

                        color: root.theme.inactive
                        font.pixelSize: 12
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked:
                        root.themeDropdownOpen =
                            !root.themeDropdownOpen
                }
            }
            // =============================================
            // THEME OPTIONS
            // =============================================

            Column {
                id: themeOptions
                visible: root.themeDropdownOpen
                width: 140
                spacing: 2

                Repeater {
                    model:
                        root.themeFolders || []

                    delegate:
                        Rectangle {
                               width: 140
                               height: 30
                               radius: 10

                            color:
                                root.currentThemeFolder ===
                                modelData
                                ? root.theme.accent
                                : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text:
                                    modelData === ""
                                    ? "All Themes"
                                    : modelData

                                color: root.theme.fg1

                                font {
                                    family: root.theme.font
                                    pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                root.currentThemeFolder = modelData
                                root.themeDropdownOpen = false
                                root.folderChanged(modelData)
                                }
                            }
                        }
                }
            }

            // =============================================
            // DEBUG INFO
            // =============================================

            Text {
                text:
                    "Wallpapers: " +
                    (
                        root.wallpapers
                        ? root.wallpapers.length
                        : 0
                    ) +
                    " | Filtered: " +
                    root.filteredWallpapers.length
                   
                    color: root.theme.fg1

                font {
                    family: root.theme.font
                    pixelSize: 11
                }
            }

// =============================================
// WALLPAPER GRID
// =============================================

Item {
    id: gridWrapper
    width: parent.width
    height: parent.height - headerRow.height - themeSelector.height - 70

    GridView {
        id: wallpaperGrid
        
        model: root.filteredWallpapers
        
        width: 872
        height: parent.height

        anchors.horizontalCenter: parent.horizontalCenter

        cellWidth: 215
        cellHeight: 130
        clip: true

        boundsBehavior: Flickable.StopAtBounds
        
        topMargin: 4
        bottomMargin: 4
        
        leftMargin: 6
        rightMargin: 6

        delegate: Rectangle {
            id: wallpaperCard
            property string wallpaperPath: modelData
            width: 200; height: 110
            radius: 10
            color: root.theme.surface
            
            property bool hovered: wallpaperMouse.containsMouse
            scale: hovered ? 1.04 : 1.0
            border.width: hovered ? 2 : 0
            border.color: root.theme.accent

            Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on border.color { ColorAnimation { duration: 160 } }

            // ============================================================
            // MASKED IMAGE CONTAINER
            // ============================================================
            Item {
                id: imageContainer
                anchors.fill: parent
                anchors.margins: wallpaperCard.border.width 

                Image {
                    id: wallpaperImage
                    anchors.fill: parent
                    source: "file://" + wallpaperCard.wallpaperPath
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true; cache: true; smooth: true
                    visible: false 
                }

                Rectangle {
                    id: roundedMask
                    anchors.fill: parent
                    radius: Math.max(0, wallpaperCard.radius - wallpaperCard.border.width)
                    color: "black"
                    visible: false
                }

                OpacityMask {
                    anchors.fill: parent
                    source: wallpaperImage
                    maskSource: roundedMask
                    layer.enabled: true
                    visible: true 
                }
            }

            MouseArea {
                id: wallpaperMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    root.applyWallpaper.command = [
                        "awww", 
                        "img", 
                        modelData, 
                        "--outputs", 
                        root.currentMonitor, 
                        "--transition-type", 
                        "any"
                    ]
                    root.applyWallpaper.running = true
                    root.closeRequested() 

                    if (typeof root.islandState !== "undefined") {
                        root.islandState = root.islandStateClosing
                    }
                }
            }
        }
    }
}

        }
    }
}