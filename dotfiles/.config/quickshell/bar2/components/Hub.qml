// components/Hub.qml
// Tabbed hub panel that lives inside the island (opened from the clock / system button).
//
// To add a tab later:
//   1. add an entry to `tabs` below
//   2. add a Loader for it in the body, with active: root.visible && root.currentTab === "<id>"
import QtQuick
import QtQuick.Layouts
import "system"

Item {
    id: root

    // ============================================================
    // API
    // ============================================================

    property var theme
    property var notifServer
    property var shell                     // the shell root (system stats, clock)
    property bool dndEnabled: false
    property var wallpaperApplier          // Process that runs awww
    property var mediaControl              // Process that runs playerctl
    property var cavaValues: []
    property bool cavaPlaying: false
    property string currentTab: "today"

    signal tabSelected(string tab)
    signal dndToggleRequested(bool enabled)
    signal closeRequested()
    signal wallpaperResolutionChanged(string folder)

    readonly property var tabs: [
        { id: "today",      label: "Today",      icon: "\udb81\udd6e" },
        { id: "system",     label: "System",     icon: "\ueaf8" },
        { id: "media",      label: "Media",      icon: "\udb80\udf88" },
        { id: "weather",    label: "Weather",    icon: "\uf522" },
        { id: "wallpapers", label: "Wallpapers", icon: "\udb83\ude09" }
    ]

    // ============================================================
    // LAYOUT
    // ============================================================

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // --------------------------------------------------------
        // TAB BAR
        // --------------------------------------------------------

        Item {
            id: tabBar

            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: 58
            Layout.maximumHeight: 58

            readonly property real cellWidth: width / Math.max(1, root.tabs.length)

            Repeater {
                model: root.tabs

                Item {
                    id: tab

                    required property var modelData
                    required property int index
                    readonly property bool selected: root.currentTab === modelData.id
                    readonly property bool hovered: tabMouse.containsMouse

                    x: index * tabBar.cellWidth
                    width: tabBar.cellWidth
                    height: tabBar.height

                    Column {
                        id: tabContent
                        anchors.centerIn: parent
                        spacing: 4

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 56
                            height: 30
                            radius: height / 2

                            color: tab.selected
                                ? Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.22)
                                : (tab.hovered ? Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.10) : "transparent")

                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: tab.modelData.icon
                                color: tab.selected ? root.theme.accent : root.theme.fg1

                                font {
                                    family: root.theme.font
                                    pixelSize: 26
                                }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tab.modelData.label
                            color: tab.selected ? root.theme.fg0 : root.theme.fg1

                            font {
                                family: root.theme.font
                                pixelSize: 12
                                weight: tab.selected ? Font.Bold : Font.Medium
                            }
                        }
                    }

                    // hit area hugs the icon + label only, so the gaps between tabs are inert
                    MouseArea {
                        id: tabMouse
                        x: tabContent.x - 4
                        y: tabContent.y - 4
                        width: tabContent.width + 8
                        height: tabContent.height + 8
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.tabSelected(tab.modelData.id)
                    }
                }
            }
        }

        // --------------------------------------------------------
        // BODY (each tab is only loaded while it is showing)
        // --------------------------------------------------------

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ---- Today: calendar + notifications ----
            Loader {
                anchors.fill: parent
                active: root.visible && root.currentTab === "today"

                sourceComponent: RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Calendar {
                        Layout.preferredWidth: 440
                        Layout.fillHeight: true
                        theme: root.theme
                    }

                    NotificationsNew {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        theme: root.theme
                        notifServer: root.notifServer
                    }
                }
            }

            // ---- System: toggles, info, stats, storage ----
            Loader {
                anchors.fill: parent
                active: root.visible && root.currentTab === "system"

                sourceComponent: SystemNew {
                    width: parent.width
                    height: parent.height

                    theme: root.theme
                    globalClock: root.shell.globalClock
                    notifServer: root.notifServer
                    panelVisible: true

                    cpuTemp: root.shell.cpuTemp
                    cpuUsage: root.shell.cpuUsage
                    gpuTemp: root.shell.gpuTemp
                    ramUsage: root.shell.ramUsage
                    ramTotal: root.shell.ramTotal
                    dataUsage: root.shell.dataUsage
                    homeUsage: root.shell.homeUsage
                    systemUptime: root.shell.systemUptime

                    dndEnabled: root.dndEnabled
                    onDndEnabledChanged: {
                        if (dndEnabled !== root.dndEnabled)
                            root.dndToggleRequested(dndEnabled)
                    }
                }
            }

            // ---- Media ----
            Loader {
                anchors.fill: parent
                active: root.visible && root.currentTab === "media"

                sourceComponent: Item {
                    MediaPlayer {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, 860)

                        theme: root.theme
                        track: root.shell.spotifyTrack
                        artUrl: root.shell.spotifyArtUrl
                        position: root.shell.spotifyPosition
                        length: root.shell.spotifyLength
                        status: root.shell.spotifyStatus
                        spotifyControl: root.mediaControl
                        cavaValues: root.cavaValues
                        cavaPlaying: root.cavaPlaying

                        artSize: 380
                        textScale: 1.9
                        controlScale: 1.5
                        infoSpacing: 20

                        // no staggered reveal in the hub: show everything straight away
                        contentVisible: true
                        textVisible: true
                        progressVisible: true
                        controlsVisible: true
                        labelVisible: true
                    }
                }
            }

            // ---- Weather ----
            Loader {
                anchors.fill: parent
                active: root.visible && root.currentTab === "weather"

                sourceComponent: Weather {
                    anchors.fill: parent
                    theme: root.theme
                }
            }

            // ---- Wallpapers ----
            Loader {
                anchors.fill: parent
                active: root.visible && root.currentTab === "wallpapers"

                sourceComponent: Wallpapers {
                    anchors.fill: parent
                    theme: root.theme
                    themeFolders: root.shell.themeFolders
                    wallpapers: root.shell.wallpapers
                    applyWallpaper: root.wallpaperApplier
                    currentResolutionFolder: root.shell.currentResolutionFolder
                    currentMonitor: root.shell.currentResolutionFolder === "4K" ? "DP-1" : "DP-3"

                    onCloseRequested: root.closeRequested()
                    onResolutionChanged: function(folder) { root.wallpaperResolutionChanged(folder) }
                }
            }
        }
    }
}
