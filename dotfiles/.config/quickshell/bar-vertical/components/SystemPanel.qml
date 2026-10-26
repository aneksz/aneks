// components/SystemPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // --- Core ---
    property var theme
    property var globalClock
    property date currentTime: globalClock.date 
    property var lastTick: root.currentTime

    Process {
    id: dndNotify
    }

    property bool panelVisible: false
    signal requestClose()

    visible: panelVisible || panelWrapper.opacity > 0

    // --- Time updates ---
    Connections {
        target: root.globalClock || null
        ignoreUnknownSignals: true

        function onTimeChanged() {
            root.currentTime = root.globalClock.time
        }
    }

    onGlobalClockChanged: {
        if (globalClock) {
            root.currentTime = globalClock.time || new Date()
        }
    }

    // --- Data from shell ---
    property bool dndEnabled
    property string systemUptime
    property string cpuTemp
    property string cpuUsage
    property string gpuTemp
    property string ramUsage
    property string dataUsage
    property string homeUsage

    // --- Helpers ---
    QtObject {
        id: helpers

        function timeAgo(ts, now) {
            if (!ts) return "—"

            const arrival = new Date(ts)
            const current = (now instanceof Date && !isNaN(now.getTime())) ? now : new Date()

            if (isNaN(arrival.getTime())) return "err"

            const diff = Math.floor((current.getTime() - arrival.getTime()) / 1000)

            if (diff < 60) return "now"
            if (diff < 3600) return Math.floor(diff / 60) + "m"
            if (diff < 86400) return Math.floor(diff / 3600) + "h"
            return Math.floor(diff / 86400) + "d"
        }
    }

    function formatUptime(uptimeStr) {
        if (!uptimeStr) return "—"
        return uptimeStr
            .replace(/ hours?/, "hr")
            .replace(/ minutes?/, "min")
            .replace(", ", " ")
    }

    // --- Popup ---
    PopupWindow {
        id: systemPopup

        visible: panelVisible || panelCard.opacity > 0
        color: "transparent"
        mask: null
        grabFocus: false

        anchor.window: bar
        anchor.rect.x: bar.screen.width - 320 - 10
        anchor.rect.y: 140
        anchor.rect.width: 560
        anchor.rect.height: 800
        anchor.margins.left: -60

        implicitWidth: 420
        implicitHeight: 1100

        Item {
            anchors.fill: parent
            clip: false

            MouseArea {
    anchors.fill: parent
    z: 0

    enabled: panelVisible

    onClicked: {
        panelVisible = false
    }
}

    Item {
    id: panelWrapper

    anchors.fill: parent
    visible: panelVisible || panelCard.opacity > 0

    Rectangle {
    id: panelCard

    width: parent.width - 20
    implicitHeight: contentColumn.implicitHeight + 40

    radius: 22
    color: theme.bg

    border.color: theme.surface
    border.width: 1

    anchors.top: parent.top
    anchors.topMargin: 20

    x: panelVisible
        ? parent.width - width
        : parent.width + 40

    opacity: panelVisible ? 1 : 0

    Behavior on x {
        NumberAnimation {
            duration: 600
            easing.type: Easing.OutCubic
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }

    Column {
        id: contentColumn

        anchors.fill: parent
        anchors.margins: 20

        spacing: 18
      
                      
        // -------- HEADER --------
Rectangle {
    id: header
    width: parent.width
    height: 80
    radius: 12
    color: theme.bgAlt
    border.color: theme.surface
    border.width: 1

    // -------- DATA (TOP LEVEL ONLY) --------
    property string username: ""
    property string hostname: ""

    Process {
        command: ["whoami"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: header.username = text.trim()
        }
    }

    Process {
        command: ["hostname"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: header.hostname = text.trim()
        }
    }

    // -------- LEFT SIDE --------
    Row {
        spacing: 12
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        // --- Avatar ---
        Item {
            width: 48
            height: 48

            Rectangle {
                id: maskObj
                anchors.fill: parent
                radius: 24
                visible: false
            }

            Image {
                id: faceImage
                anchors.fill: parent
                source: "file:///home/igor/.config/quickshell/face3.png"
                fillMode: Image.PreserveAspectCrop
                visible: false
            }

            OpacityMask {
                anchors.fill: parent
                source: faceImage
                maskSource: maskObj
            }

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: "transparent"
                border.color: theme.border
                border.width: 1
            }
        }

        // --- Text ---
        Column {
            spacing: 2

            Text {
                text: header.username + "@" + header.hostname
                color: theme.accent

                font {
                    family: theme.font
                    bold: true
                    pixelSize: theme.fontSize + 2
                }
            }

            Text {
                text: "Uptime:" + formatUptime(root.systemUptime)
                color: theme.accent

                font {
                    family: theme.font
                    pixelSize: theme.fontSize
                }
            }
        }
    }

    // -------- RIGHT SIDE --------
    Row {
        spacing: 6
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        // -------- Bluetooth --------
        MouseArea {
            width: 28; height: 28
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: parent.containsMouse ? theme.surfaceAlt : "transparent"
                border.color: parent.containsMouse ? theme.accent : theme.surface
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }
            }

            Text {
                anchors.centerIn: parent
                text: ""
                color: parent.containsMouse ? theme.accent : theme.textMuted
                font.family: theme.font
                font.pixelSize: theme.fontSize + 1

                Behavior on color { ColorAnimation { duration: 120 } }
            }

            scale: containsMouse ? 1.1 : 1.0
            Behavior on scale { NumberAnimation { duration: 120 } }

            onClicked: {
                vpnRunner.command = ["kitty", "-e", "bluetui"]
                vpnRunner.running = true
            }
        }

    // -------- Night Light --------

        MouseArea {
    id: nightBtn
    width: 28; height: 28
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    property bool nightEnabled: false

    Rectangle {
    anchors.fill: parent
    radius: width / 2

    color: nightBtn.nightEnabled
        ? Qt.rgba(1, 0.8, 0, 0.12)
        : (parent.containsMouse ? theme.surfaceAlt : "transparent")

    border.color: nightBtn.nightEnabled
        ? theme.warning
        : (parent.containsMouse ? theme.warning : theme.surface)

    border.width: 1

    Behavior on color {
        ColorAnimation { duration: 180 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 180 }
    }
}

    Item {
    anchors.centerIn: parent
    width: 20
    height: 20

   
    Text {
        anchors.centerIn: parent
        text: ""
        opacity: nightBtn.nightEnabled ? 1 : 0
        rotation: nightBtn.nightEnabled ? 0 : -90

        color: nightBtn.containsMouse
            ? theme.warning
            : theme.warning

        font.family: theme.font
        font.pixelSize: theme.fontSize + 1

        Behavior on opacity {
    NumberAnimation { duration: 180; easing.type: Easing.InOutQuad }
}
Behavior on rotation {
    NumberAnimation { duration: 180; easing.type: Easing.InOutQuad }
    
}
    }

  
    Text {
        anchors.centerIn: parent
        text: ""
        opacity: nightBtn.nightEnabled ? 0 : 1
        rotation: nightBtn.nightEnabled ? 90 : 0

        color: nightBtn.containsMouse
            ? theme.warning
            : theme.textMuted

        font.family: theme.font
        font.pixelSize: theme.fontSize + 1

        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on rotation { NumberAnimation { duration: 180 } }
    }
}

    scale: containsMouse ? 1.1 : 1.0
    Behavior on scale { NumberAnimation { duration: 120 } }

    onClicked: {
    nightBtn.nightEnabled = !nightBtn.nightEnabled

    vpnRunner.command = [
    "sh", "-c",
    nightBtn.nightEnabled
    ? "hyprctl hyprsunset temperature 4000 && notify-send 'Night Light' 'On'"
    : "hyprctl hyprsunset identity && notify-send 'Night Light' 'Off'"
]
    vpnRunner.running = true
 }
}

        // -------- Volume --------
        MouseArea {
            width: 28; height: 28
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: parent.containsMouse ? theme.surfaceAlt : "transparent"
                border.color: parent.containsMouse ? theme.accent : theme.surface
                border.width: 1
            }

            Text {
                anchors.centerIn: parent
                text: ""
                color: parent.containsMouse ? theme.accent : theme.textMuted
                font.family: theme.font
                font.pixelSize: theme.fontSize + 1
            }

            scale: containsMouse ? 1.1 : 1.0
            Behavior on scale { NumberAnimation { duration: 120 } }

            onClicked: {
                vpnRunner.command = ["kitty", "-e", "wiremix"]
                vpnRunner.running = true
            }
        }
    }
}
    // --- Volume Section ---
Rectangle {
    id: volContainer
    width: parent.width; height: 80; radius: 12
    property bool hovered: false

    color: Qt.rgba(theme.bgAlt.r, theme.bgAlt.g, theme.bgAlt.b, hovered ? 1 : 0.9)
    border.width: 1
    border.color: hovered ? theme.accent : theme.surface
    scale: hovered ? 1.01 : 1

    visible: Pipewire.defaultAudioSink !== null

    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    // reactive volume
    readonly property real currentVol: {
        const sink = Pipewire.defaultAudioSink;
        if (sink && sink.audio) return sink.audio.volume;
        return 0.0;
    }

    readonly property bool isAirPods: {
    const sink = Pipewire.defaultAudioSink;
    return sink &&
           sink.description &&
           sink.description.includes("AirPods Pro");
   }

    Column {
        anchors.fill: parent; anchors.margins: 15; spacing: 10
        
        Item {
            width: parent.width; height: 20

            Row {
                anchors.left: parent.left; spacing: 8

                Text {
                    text: { const sink = Pipewire.defaultAudioSink; if (sink && sink.audio && sink.audio.muted) return "󰝟"; if (volContainer.isAirPods) return "󱡏"; return ""; }
                    color: theme.accent
                    font.family: theme.font
                    font.pointSize: 10
                    opacity: parent.parent.hovered ? 1 : 0.85
                }

                Text {
                    text: "Volume"
                    color: theme.fg1
                    font.pointSize: 9
                    font.family: theme.font
                    font.weight: theme.fontWeight
                }
            }

            Text {
                anchors.right: parent.right
                text: Math.round(volContainer.currentVol * 100) + "%"
                color: theme.inactive
                font.pointSize: 8
                font.family: theme.font
                font.weight: theme.fontWeight
            }
        }

        MouseArea {
            width: parent.width; height: 10
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            // click
            onClicked: (mouse) => {
                if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                    Pipewire.defaultAudioSink.audio.volume = mouse.x / width
                }
            }

            // scroll
            onWheel: (wheel) => {
                if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                    let step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                    let newVol = Pipewire.defaultAudioSink.audio.volume + step;
                    Pipewire.defaultAudioSink.audio.volume = Math.min(Math.max(newVol, 0), 1);
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 5
                color: theme.bg

                Rectangle {
                    width: parent.width * volContainer.currentVol
                    height: parent.height
                    radius: 5
                    color: theme.accent

                    Behavior on width {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }
            }

            onEntered: volContainer.hovered = true
            onExited: volContainer.hovered = false
        }
    


    }
}

       // --- 2. Power Actions ---
Row {
    width: parent.width
    spacing: 10

    ActionButton {
        icon: ""
        baseColor: theme.success
        hoverColor: theme.accent
        command: ["systemctl", "reboot"]
    }

    ActionButton {
        icon: "⏻"
        baseColor: theme.error
        command: ["systemctl", "poweroff"]
    }

    ActionButton {
    icon: "󰗽"
    baseColor: theme.accent
    command: ["hyprctl", "dispatch", "hl.dsp.exit()"]
  }
}

// --- NOTIFICATIONS PANEL ---
Rectangle {
    id: swayncNotifSection
    width: parent.width
    height: 400
    radius: 12
    

    color: theme.bgAlt
    border.color: theme.surface
    border.width: 1
    clip: true
    
   
    property bool emptyState: !root.dndEnabled
        && (!notifServer.trackedNotifications
            || notifServer.trackedNotifications.values.length === 0)

    
    SequentialAnimation {
        id: pulse
        NumberAnimation { target: watermark; property: "scale"; to: 1.05; duration: 120 }
        NumberAnimation { target: watermark; property: "scale"; to: 1.0; duration: 180 }
    }

    onEmptyStateChanged: if (emptyState) pulse.start()

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 12

        // -------- HEADER --------
        Item {
            width: parent.width
            height: 30

            Text {
                text: "Notifications"
                anchors.verticalCenter: parent.verticalCenter
                color: theme.fg1
                font { bold: true; pointSize: 10; family: theme.font }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                // CLEAR ALL
                MouseArea {
                    width: 28; height: 28
                    hoverEnabled: true
                    visible: !swayncNotifSection.emptyState

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: parent.containsMouse ? theme.surfaceAlt : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰎟"
                        color: parent.containsMouse ? theme.error : theme.inactive
                        font.pixelSize: theme.fontSize + 6
                        font.family: theme.font

                        scale: parent.containsMouse ? 1.15 : 1.0
                        rotation: parent.containsMouse ? -10 : 0

                        Behavior on scale { NumberAnimation { duration: 120 } }
                        Behavior on rotation { NumberAnimation { duration: 120 } }
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    onClicked: {
                        notifServer.trackedNotifications?.values
                            ?.slice()
                            .forEach(n => n.dismiss())
                    }
                }

                // DND
                MouseArea {
    id: dndBtn
    width: 28; height: 28
    hoverEnabled: true

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: parent.containsMouse ? theme.surfaceAlt : "transparent"
    }

   Text {
    id: bellIcon  
    anchors.centerIn: parent
    text: root.dndEnabled ? "󰂛" : "󰂚"

    property bool pressed: false

    color: root.dndEnabled
    ? theme.accent
    : (dndBtn.containsMouse ? Qt.lighter(theme.accent, 1.2) : theme.inactive)

    font.pixelSize: theme.fontSize + 6
    font.family: theme.font

    scale: pressed
        ? 0.9
        : (dndBtn.containsMouse ? 1.15 : 1.0)

    Behavior on scale { NumberAnimation { duration: 120 } }
    Behavior on color { ColorAnimation { duration: 120 } }
}

onPressed: {
    bellIcon.pressed = true
}

onReleased: {
    bellIcon.pressed = false

    root.dndEnabled = !root.dndEnabled

    dndNotify.command = [
    "notify-send",
    root.dndEnabled
        ? "󰂛 Do Not Disturb"
        : "󰂚 Do Not Disturb",

    root.dndEnabled
        ? "Enabled"
        : "Disabled"
]

    dndNotify.running = true

    bounce.start()
}

NumberAnimation {
    id: bounce
    target: bellIcon   
    property: "scale"
    to: 1.15
    duration: 140
    easing.type: Easing.OutBack

    onStopped: {
        bellIcon.scale = Qt.binding(function() {
            return bellIcon.pressed
                ? 0.9
                : (dndBtn.containsMouse ? 1.15 : 1.0)
        })
    }
  }
}
            }
        }

           // -------- LIST --------
ListView {
    id: list
    width: parent.width
    height: parent.height - 50
    spacing: 10
    clip: true
    cacheBuffer: 0
    reuseItems: true
    boundsBehavior: Flickable.StopAtBounds

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: list.forceLayout()
    }

    function normalizeApp(n) {
        let name = n.desktopEntry || n.appName || "system";
        name = name.toLowerCase().trim();

        if (name.includes("spotify")) return "spotify";
        if (name.includes("brave")) return "brave";
        if (name.includes("chrome")) return "chrome";

        return name;
    }

    property var groupedData: {
        if (!notifServer.trackedNotifications || root.dndEnabled)
            return [];

        const notifs = notifServer.trackedNotifications.values || [];
        const groups = {};

        for (let i = 0; i < notifs.length; i++) {
    const n = notifs[i];

    // Hide transient Spotify notifications from panel
    if (n.isSpotifyTransient)
        continue;

    const app = normalizeApp(n);

    if (!groups[app]) groups[app] = [];
    groups[app].push(n);
    }

        return Object.keys(groups).map(key => ({
            name: key,
            notifs: groups[key]
        }));
    }

    model: list.groupedData

    delegate: Column {
        width: list.width
        spacing: 6

        property bool expanded: false
        property var groupNotifs: modelData.notifs || []

        Behavior on height {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }

        // -------- GROUP HEADER --------
        Row {
            width: parent.width

            Text {
                text: modelData.name.toUpperCase()
                color: theme.accent
                opacity: 0.7
                font { bold: true; pointSize: 7; family: theme.font }
            }

            Text {
                text: groupNotifs.length > 1 ? " (" + groupNotifs.length + ")" : ""
                color: theme.inactive
                font.pointSize: 7
            }
        }

        // -------- NOTIFICATIONS --------
        Repeater {
            model: expanded
                ? groupNotifs.slice().reverse()
                : groupNotifs.length > 0
                    ? [groupNotifs[groupNotifs.length - 1]]
                    : []

            delegate: Rectangle {
                id: card
                width: parent.width
                radius: 8

                property bool hovered: false

                color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, hovered ? 0.95 : 0.85)
                border.color: hovered ? theme.accent : theme.surface

                height: contentCol.implicitHeight + 16

                property int stackIndex: index
                y: expanded ? 0 : (stackIndex * -3)
                opacity: expanded ? 1 : (1 - stackIndex * 0.15)

                Behavior on y {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Behavior on border.color {
                    ColorAnimation { duration: 120 }
                }

                // -------- CONTENT --------
                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Column {
                        id: contentCol
                        width: parent.width - 60
                        spacing: 3

                        Text {
                            text: modelData.summary || ""
                            color: theme.fg1
                            font.bold: true
                            width: parent.width
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                        }

                        Text {
                            text: modelData.body || ""
                            color: theme.inactive
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                            maximumLineCount: 4
                        }
                    }

    Text {
        text: {
        let pulse = lastTick;
        let t = helpers.timeAgo(modelData.timestamp, root.currentTime);

        return t === "now" ? "now" : t + " ago";
    }

        color: theme.inactive
        font.pixelSize: 11
        verticalAlignment: Text.AlignTop
          }
    }
                // -------- INTERACTION --------
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false

                    onClicked: {
                        if (groupNotifs.length > 1) {
                            expanded = !expanded
                        } else {
                            modelData.dismiss()
                        }
                    }
                }
            }
        }
    }

    // -------- EMPTY TEXT --------
    Text {
        visible: swayncNotifSection.emptyState
        text: "No Notifications"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        color: theme.inactive
        font { italic: true; family: theme.font }
    }

    // -------- WATERMARK --------
    Text {
        id: watermark
        visible: swayncNotifSection.emptyState

        text: "󰂚"
        font.family: theme.font
        font.pixelSize: 120

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 100
        anchors.bottomMargin: 100

        color: Qt.rgba(0.8, 0.85, 0.9, 1.0)
        opacity: swayncNotifSection.emptyState ? 0.05 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }
}
    }
}

        // --- 3. Stats Row 1: CPU & GPU ---
    Row {
        width: parent.width; spacing: 10
        
    Rectangle {
    width: (parent.width / 2) - 5; height: 80; radius: 12
    property bool hovered: false

    color: Qt.rgba(theme.bgAlt.r, theme.bgAlt.g, theme.bgAlt.b, hovered ? 1 : 0.9)
    border.width: 1; border.color: hovered ? theme.accent : theme.surface
    scale: hovered ? 1.02 : 1

    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Column {
        width: parent.width; anchors.centerIn: parent; spacing: 4

        Text { width: parent.width; text: ""; color: theme.accent; opacity: parent.hovered ? 1 : 0.85; font.pointSize: 16; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }

        Text { width: parent.width; text: root.cpuTemp; color: theme.fg1; font.bold: true; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }

        Text { width: parent.width; text: "CPU Temp"; color: theme.inactive; font.pointSize: 8; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
    }

    MouseArea {
        anchors.fill: parent; hoverEnabled: true
        onEntered: parent.hovered = true
        onExited: parent.hovered = false
        onPressed: parent.scale = 0.97
        onReleased: parent.scale = hovered ? 1.02 : 1
    }
}
        
    Rectangle {
    width: (parent.width / 2) - 5; height: 80; radius: 12
    property bool hovered: false

    color: Qt.rgba(theme.bgAlt.r, theme.bgAlt.g, theme.bgAlt.b, hovered ? 1 : 0.9)
    border.width: 1; border.color: hovered ? theme.success : theme.surface
    scale: hovered ? 1.02 : 1

    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Column {
        width: parent.width; anchors.centerIn: parent; spacing: 4

        Text { width: parent.width; text: ""; color: theme.success; opacity: parent.hovered ? 1 : 0.85; font.pointSize: 16; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }

        Text { width: parent.width; text: root.gpuTemp; color: theme.fg1; font.bold: true; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }

        Text { width: parent.width; text: "GPU Temp"; color: theme.inactive; font.pointSize: 8; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
    }

    MouseArea {
        anchors.fill: parent; hoverEnabled: true
        onEntered: parent.hovered = true
        onExited: parent.hovered = false
        onPressed: parent.scale = 0.97
        onReleased: parent.scale = hovered ? 1.02 : 1
      }
   }
}

    // --- 4. Stats Row 2: CPU Usage & Memory  ---
    Row {
        width: parent.width; spacing: 10
        
        Rectangle {
    width: (parent.width / 2) - 5; height: 80; radius: 12
    property bool hovered: false

    color: Qt.rgba(theme.bgAlt.r, theme.bgAlt.g, theme.bgAlt.b, parent.hovered ? 1 : 0.9)
    border.width: 1; border.color: hovered ? theme.accent : theme.surface
    scale: parent.hovered ? 1.02 : 1

    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Column {
        width: parent.width; anchors.centerIn: parent; spacing: 4

        Text { width: parent.width; text: ""; color: theme.accent; opacity: parent.hovered ? 1 : 0.85; font.pointSize: 16; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }

        Text { width: parent.width; text: root.cpuUsage; color: theme.fg1; font.bold: true; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }

        Text { width: parent.width; text: "CPU Usage"; color: theme.inactive; font.pointSize: 8; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
    }

    MouseArea {
        anchors.fill: parent; hoverEnabled: true
        onEntered: parent.hovered = true
        onExited: parent.hovered = false
        onPressed: parent.scale = 0.97
        onReleased: parent.scale = parent.hovered ? 1.02 : 1
    }
}
        
        Rectangle {
    width: (parent.width / 2) - 5; height: 80; radius: 12
    property bool hovered: false

    color: Qt.rgba(theme.bgAlt.r, theme.bgAlt.g, theme.bgAlt.b, parent.hovered ? 1 : 0.9)
    border.width: 1; border.color: hovered ? theme.success : theme.surface
    scale: parent.hovered ? 1.02 : 1

    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Column {
        width: parent.width; anchors.centerIn: parent; spacing: 4

        Text { width: parent.width; text: ""; color: theme.success; opacity: parent.hovered ? 1 : 0.85; font.pointSize: 16; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }

        Text { width: parent.width; text: root.ramUsage; color: theme.fg1; font.bold: true; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }

        Text { width: parent.width; text: "Memory"; color: theme.inactive; font.pointSize: 8; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
    }

    MouseArea {
        anchors.fill: parent; hoverEnabled: true
        onEntered: parent.hovered = true
        onExited: parent.hovered = false
        onPressed: parent.scale = 0.97
        onReleased: parent.scale = parent.hovered ? 1.02 : 1
    }
}
    }



  // --- Storage Section ---
Text { text: "Storage"; color: theme.inactive; font.bold: true; font.pointSize: 9; font.family: theme.font}

Rectangle {
    width: parent.width; height: 130; radius: 12
    property bool hovered: false

    color: Qt.rgba(theme.bgAlt.r, theme.bgAlt.g, theme.bgAlt.b, hovered ? 1 : 0.9)
    border.width: 1; border.color: hovered ? theme.accent : theme.surface
    scale: hovered ? 1.01 : 1

    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Column {
        anchors.fill: parent; anchors.margins: 15; spacing: 15
        
        // --- Data Partition ---
        Column {
            width: parent.width; spacing: 6

            Item {
                width: parent.width; height: 15

                Text { text: "/mnt/data"; color: theme.fg1; font.pointSize: 9; anchors.left: parent.left; font.weight: theme.fontWeight; font.family: theme.font }
                Text { text: root.dataUsage || ""; color: theme.inactive; font.pointSize: 8; anchors.right: parent.right; font.weight: theme.fontWeight; font.family: theme.font }
            }
            
            Rectangle {
                width: parent.width; height: 10; radius: 3; color: theme.bg 

                Rectangle {
                    height: 10; radius: 4; color: theme.accent

                    width: {
                        let usage = root.dataUsage || "";
                        let parts = usage.split(" / ");
                        if (parts.length < 2) return 0;

                        function toMB(val) {
                            let n = parseFloat(val);
                            if (val.includes("T")) return n * 1024 * 1024;
                            if (val.includes("G")) return n * 1024;
                            if (val.includes("M")) return n;
                            return n;
                        }

                        let used = toMB(parts[0]);
                        let total = toMB(parts[1]);

                        if (!total) return 0;
                        return parent.width * (used / total);
                    }

                    Behavior on width {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                }
            }
        }

        // --- Home Partition ---
        Column {
            width: parent.width; spacing: 6

            Item {
                width: parent.width; height: 15

                Text { text: "/home/igor"; color: theme.fg1; font.pointSize: 9; anchors.left: parent.left; font.weight: theme.fontWeight; font.family: theme.font }
                Text { text: root.homeUsage || ""; color: theme.inactive; font.pointSize: 8; anchors.right: parent.right; font.weight: theme.fontWeight; font.family: theme.font }
            }
            
            Rectangle {
                width: parent.width; height: 10; radius: 3; color: theme.bg 

                Rectangle {
                    height: 10; radius: 4; color: theme.success

                    width: {
                        let usage = root.homeUsage || "";
                        let parts = usage.split(" / ");
                        if (parts.length < 2) return 0;

                        function toMB(val) {
                            let n = parseFloat(val);
                            if (val.includes("T")) return n * 1024 * 1024;
                            if (val.includes("G")) return n * 1024;
                            if (val.includes("M")) return n;
                            return n;
                        }

                        let used = toMB(parts[0]);
                        let total = toMB(parts[1]);

                        if (!total) return 0;
                        return parent.width * (used / total);
                    }

                    Behavior on width {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent; hoverEnabled: true
        onEntered: parent.hovered = true
        onExited: parent.hovered = false
         }
       }
     }
    }
   }
  }
 }
}