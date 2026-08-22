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

    property int contentWidth: 480

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
    // DEVICE BATTERY HELPER
    // ============================================================

    DeviceBattery {
        id: deviceBattery
    }

    // ============================================================
    // PANEL CONTENT
    // ============================================================

    Column {
        id: content
        width: parent.width
        spacing: 10
        anchors.margins: 10

        // ========================================================
        // 1. HEADER (Avatar + Uptime + Power buttons)
        // ========================================================

        HeaderNew {
            width: parent.width
            x: 0

            theme: systemDropdown.activeTheme
            globalClock: systemDropdown.globalClock
            systemUptime: systemDropdown.systemUptime
        }

        // ========================================================
        // 2. TOGGLES (Bluetooth, Night Light, DND, Caffeine...)
        // ========================================================

        Toggles {
            width: parent.width
            x: 0

            theme: systemDropdown.activeTheme
            dndEnabled: systemDropdown.dndEnabled

            onDndToggled: (enabled) => {
                systemDropdown.dndEnabled = enabled
            }
        }

        // ========================================================
        // 3. VOLUME
        // ========================================================

        VolumeCardNew {
            width: parent.width
            x: 0
            theme: systemDropdown.activeTheme
        }

        // ========================================================
        // 4. NOTIFICATIONS
        // ========================================================

        NotificationsNew {
            width: parent.width
            x: 0

            theme: systemDropdown.activeTheme
            notifServer: systemDropdown.notifServer
            dndEnabled: systemDropdown.dndEnabled
            property bool emptyState: !notifServer || !notifServer.trackedNotifications || notifServer.trackedNotifications.values.length === 0
            onRequestClose: systemDropdown.requestClose()
        }
        // ========================================================
        // STORAGE
        // ========================================================
        Storage {
            width: parent.width
            x: 0

            theme: systemDropdown.activeTheme
            dataUsage: systemDropdown.dataUsage
            homeUsage: systemDropdown.homeUsage

        }

        // ========================================================
        // 5. STATS
        // ========================================================

        StatsNew {
            width: parent.width
            x: 0

            theme: systemDropdown.activeTheme

            cpuTemp: systemDropdown.cpuTemp
            cpuUsage: systemDropdown.cpuUsage
            gpuTemp: systemDropdown.gpuTemp
            ramUsage: systemDropdown.ramUsage
            

            keyboardBattery: deviceBattery.keyboardBattery
            mouseBattery: deviceBattery.mouseBattery
        }
    }
}