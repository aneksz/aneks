// systemnew.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "system"

Item {
    id: systemDropdown

    // ============================================================
    // SIZE
    // ============================================================

    property int contentWidth: 920

    width: contentWidth
    height: content.implicitHeight
    implicitHeight: content.implicitHeight

    // ============================================================
    // EXTERNAL PROPERTIES
    // ============================================================

    property var theme
    property var globalClock
    property var notifServer
    property var notifications: []

    property bool panelVisible: false

    signal requestClose()

    // ============================================================
    // SYSTEM STATE
    // ============================================================

    property bool dndEnabled: false

    property string systemUptime: ""
    property string cpuTemp: ""
    property string cpuUsage: ""
    property string gpuTemp: ""
    property string ramUsage: ""
    property string dataUsage: ""
    property string homeUsage: ""
    property string ramTotal: ""
    // ============================================================
    // THEME FALLBACK
    // ============================================================

    readonly property var activeTheme: systemDropdown.theme ? systemDropdown.theme : {
        bg: "#2e3440",
        bgAlt: "#2e3440",
        surface: "#3b4252",
        surfaceAlt: "#434c5e",
        border: "#4c566a",
        accent: "#88c0d0",
        fg1: "#eceff4",
        fg: "#e5e9f0",
        inactive: "#4c566a",
        textMuted: "#4c566a",
        warning: "#ebcb8b",
        success: "#a3be8c",
        error: "#bf616a",
        font: "sans",
        fontSize: 11,
        fontWeight: Font.Normal
    }

    // ============================================================
    // DEBUG PLACEHOLDER CARD (delete once real content is wired in)
    // ============================================================

    component PlaceholderCard: Rectangle {
        property string label: ""
        radius: 16
        color: systemDropdown.activeTheme.bgAlt
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        Text {
            anchors.centerIn: parent
            text: parent.label
            color: systemDropdown.activeTheme.inactive
            font {
                family: systemDropdown.activeTheme.font
                pixelSize: 12
            }
        }
    }

    // ============================================================
    // THREE-COLUMN LAYOUT
    // ============================================================

    RowLayout {
        id: content
        width: parent.width
        spacing: 10

        // ========================================================
        // LEFT COLUMN — Toggles (+ Volume, tbd) / System Info
        // ========================================================

        ColumnLayout {
    Layout.fillWidth: true
    Layout.preferredWidth: 1.25
    Layout.alignment: Qt.AlignTop
    spacing: 10

            TogglesAndVolume {
    Layout.fillWidth: true
    theme: activeTheme
    dndEnabled: systemDropdown.dndEnabled
    onDndToggled: (enabled) => systemDropdown.dndEnabled = enabled
}

        SystemInfo { theme: activeTheme; Layout.fillWidth: true }

        Storage {
    Layout.fillWidth: true
    theme: activeTheme
    dataUsage: systemDropdown.dataUsage
    homeUsage: systemDropdown.homeUsage
}
        }

        // ========================================================
        // CENTER COLUMN — Clock / Avatar / Power buttons
        // ========================================================

        ColumnLayout {
    Layout.fillWidth: true
    Layout.preferredWidth: 1.2
    spacing: 10


    CenterPanel {
    Layout.fillWidth: true
    Layout.fillHeight: true
    theme: activeTheme
    globalClock: systemDropdown.globalClock
   }
        }

        // ========================================================
        // RIGHT COLUMN 
        // ========================================================

        ColumnLayout {
    Layout.fillWidth: true
    Layout.preferredWidth: 1.25
    Layout.alignment: Qt.AlignTop
    spacing: 10

        StatsNew {
    Layout.fillWidth: true
    theme: activeTheme
    cpuTemp: systemDropdown.cpuTemp
    cpuUsage: systemDropdown.cpuUsage
    gpuTemp: systemDropdown.gpuTemp
    ramUsage: systemDropdown.ramUsage
    ramTotal: systemDropdown.ramTotal
}

        NotificationsNew {
    Layout.fillWidth: true
    Layout.fillHeight: true
    theme: activeTheme
    notifServer: systemDropdown.notifServer
    dndEnabled: systemDropdown.dndEnabled
    onRequestClose: systemDropdown.requestClose()
}
        }
    }
}
