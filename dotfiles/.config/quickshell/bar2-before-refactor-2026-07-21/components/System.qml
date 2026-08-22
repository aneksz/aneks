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

property int contentWidth: 420

width:
    contentWidth + 20

height:
    content.implicitHeight

implicitHeight:
    content.implicitHeight


// ============================================================
// EXTERNAL PROPERTIES
// ============================================================

property var theme
property var globalClock
property var notifServer

property bool panelVisible:
    false

signal requestClose()


// ============================================================
// SYSTEM STATE
// ============================================================

property bool dndEnabled:
    false

property string systemUptime:
    ""

property string cpuTemp:
    ""

property string cpuUsage:
    ""

property string gpuTemp:
    ""

property string ramUsage:
    ""

property string dataUsage:
    ""

property string homeUsage:
    ""


// ============================================================
// THEME FALLBACK
// ============================================================

readonly property var activeTheme:
    systemDropdown.theme
    ? systemDropdown.theme
    : {
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
// SYSTEM UPTIME
// ============================================================

Process {
    id: uptimeProcess

    command: [
        "sh",
        "-c",
        "awk '{print $1}' /proc/uptime"
    ]

    running:
        true

    stdout:
        StdioCollector {

            onStreamFinished: {

                let seconds =
                    Math.floor(
                        Number(
                            text.trim()
                        )
                    )


                let hours =
                    Math.floor(
                        seconds / 3600
                    )


                let minutes =
                    Math.floor(
                        (seconds % 3600) / 60
                    )


                systemDropdown.systemUptime =
                    hours > 0
                    ? hours + "h " + minutes + "m"
                    : minutes + "m"
            }
        }
}



// ============================================================
// PANEL CONTENT
// ============================================================

Column {
    id: content

    width:
        parent.width

    spacing:
        12


    // ========================================================
    // HEADER
    // ========================================================

    Header {

        width:
            parent.width - 24

        x:
            12


        theme:
            systemDropdown.activeTheme

        globalClock:
            systemDropdown.globalClock

        systemUptime:
            systemDropdown.systemUptime
    }


    // ========================================================
    // SEPARATOR
    // ========================================================

    Rectangle {

        width:
            parent.width - 24

        x:
            12

        height:
            1

        color:
            systemDropdown.activeTheme.surface

        opacity:
            0.3
    }


    // ========================================================
    // VOLUME
    // ========================================================

    VolumeCard {

        width:
            parent.width - 24

        x:
            12


        theme:
            systemDropdown.activeTheme
    }


    // ========================================================
    // SEPARATOR
    // ========================================================

    Rectangle {

        width:
            parent.width - 24

        x:
            12

        height:
            1

        color:
            systemDropdown.activeTheme.surface

        opacity:
            0.3
    }


    // ========================================================
    // QUICK CONTROLS
    // ========================================================

    Controls {

        width:
            parent.width - 24

        x:
            12


        theme:
            systemDropdown.activeTheme

        dndEnabled:
            systemDropdown.dndEnabled
    }


    // ========================================================
    // SEPARATOR
    // ========================================================

    Rectangle {

        width:
            parent.width - 24

        x:
            12

        height:
            1

        color:
            systemDropdown.activeTheme.surface

        opacity:
            0.3
    }


    // ========================================================
    // NOTIFICATIONS
    // ========================================================

    Notifications {

        width:
            parent.width - 24

        x:
            12


        theme:
            systemDropdown.activeTheme

        notifServer:
            systemDropdown.notifServer

        dndEnabled:
            systemDropdown.dndEnabled


        onRequestClose:
            systemDropdown.requestClose()
    }


    // ========================================================
    // SEPARATOR
    // ========================================================

    Rectangle {

        width:
            parent.width - 24

        x:
            12

        height:
            1

        color:
            systemDropdown.activeTheme.surface

        opacity:
            0.3
    }


    // ========================================================
    // SYSTEM STATS
    // ========================================================

    Stats {

        width:
            parent.width - 24

        x:
            12


        theme:
            systemDropdown.activeTheme

        cpuTemp:
            systemDropdown.cpuTemp

        cpuUsage:
            systemDropdown.cpuUsage

        gpuTemp:
            systemDropdown.gpuTemp

        ramUsage:
            systemDropdown.ramUsage

        dataUsage:
            systemDropdown.dataUsage

        homeUsage:
            systemDropdown.homeUsage
    }
}
}
