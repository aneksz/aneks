//@ pragma UseQApplication
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Services.Polkit
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import QtQuick.Shapes

import "./components" as LocalComponents
import "components/buttons" as Buttons
import "./components/system" as SystemModules

PanelWindow {
    id: root
   
    anchors {
        top: true
        left: true
        right: true
    }

    margins { top: 0 }
    color: "transparent"
    implicitHeight: 900
    exclusiveZone: 50
    WlrLayershell.keyboardFocus:
    root.launcherVisible ||
    root.panelVisible ||
    root.mediaVisible ||
    root.weatherVisible ||
    root.themeVisible ||
    root.wallpaperVisible ||
    root.timerOsdVisible ||
    root.calendarVisible ||
    root.updateAuthVisible 
    mask: Region { item: island }

    Connections { target: root.theme }
// ===========================================================
// PERSISTENT NOTIFICATION STORAGE (In shell.qml)
// ===========================================================

PersistentProperties {
    id: persist
    reloadableId: "notificationHistoryStateCache"

    property string timestampsJson: "{}"
    property string seenJson: "{}"
}

// ===========================================================
// Notifications Server
// ===========================================================

NotificationServer {
    id: notificationServer

    keepOnReload: true

    onNotification: function(n) {
        if (!n) return;


        const app = String(n.appName || n.desktopEntry || "").toLowerCase();
        const isSpotify = app.includes("spotify");

        n.tracked = true;
        n.isSpotifyTransient = isSpotify;

        // Unique tracking key parsing
        let key = String(n.id || (n.summary + n.body));

        // 1. Safely pull your persistent string from the cached data store
        let timestamps = {};
        let seen = {};
        try {
            timestamps = JSON.parse(persist.timestampsJson);
            seen = JSON.parse(persist.seenJson);
        } catch(e) { /* fallback to clean dictionaries */ }

        // 2. Lock-In Timestamp (Only handles organic, fresh arrival items)
        if (!timestamps[key]) {
            timestamps[key] = Date.now();
            persist.timestampsJson = JSON.stringify(timestamps);
        }
        n.timestamp = timestamps[key];

        // 3. Skip re-triggering popup banners during background theme replays
        if (n.lastGeneration || seen[key]) {
            return;
        }

        // 4. Mark as seen and map over to your Toast popup loader component
        seen[key] = true;
        persist.seenJson = JSON.stringify(seen);
        
        root.currentNotif = n;
    }
}
    // =====================================================
    // POLKIT AGENT 
    // =====================================================

    PolkitAgent {
    id: polkitService

    onIsActiveChanged: {
        root.updateAuthVisible = polkitService.isActive

        if (polkitService.isActive && updateAuthLoader.item && polkitService.flow) {
            updateAuthLoader.item.actionDescription = polkitService.flow.message
        }
    }
}

    // =====================================================
    // THEME ENGINE
    // =====================================================

 LocalComponents.ThemeEngine {
    id: themeEngine
}
    
    // =====================================================
    // AUTO-DISMISS CLICK AWAY MECHANISM 
    // =====================================================
    MouseArea {
    id: clickAwayDismissMask

    anchors.fill: parent

    enabled:
    root.launcherVisible ||
    root.panelVisible ||
    root.mediaVisible ||
    root.themeVisible ||
    root.calendarVisible ||
    root.weatherVisible ||
    root.wallpaperVisible ||
    root.timerOsdVisible ||
    root.timerControlOsdVisible

    z: -1

    onClicked: {
        root.launcherVisible = false
        root.panelVisible = false
        root.mediaVisible = false
        root.themeVisible = false
        root.calendarVisible = false
        root.weatherVisible = false
        root.wallpaperVisible = false
    }
}

    // =====================================================
    // NATIVE SERVICES & TIME MIGRATION
    // =====================================================

    SystemClock { id: clock; precision: SystemClock.Minutes }

    property string currentTime: Qt.formatTime(clock.date, "HH:mm")

    // =====================================================
    // CORE SYSTEM MONITORING PROPERTIES
    // =====================================================
    property string cpuTemp: "00°C"
    property string cpuUsage: "0%"
    property string gpuTemp: "00°C"
    property string systemUptime: "0m"
    property string dataUsage: "0 / 1" 
    property string homeUsage: "0 / 1"
    property string ramUsage: "0B" 
    property string ramTotal: "0B"
    property string spotifyTrack: ""
    property string spotifyArtUrl: ""
    property bool mediaVisible: false
    property bool spotifyVisible: false
    property real spotifyPosition: 0
    property real spotifyLength: 0
    property string spotifyStatus: "Paused"
    property bool panelVisible: false
    property bool dndEnabled: false
    property bool caffeineEnabled: false
    property var currentNotif: null
    property bool themeVisible: false
    property string currentTheme: ""
    property string currentThemeFolder: ""
    property var themeFolders: []
    property var themes: []
    property string osdMode: ""
    property bool osdVisible: root.osdMode !== ""
    property int systemContentWidth: 460
    property bool wallpaperVisible: false
    property var wallpapers: []
    property string currentResolutionFolder: "4K"
    property string updateCount: "0"
    property bool weatherVisible: false
    property bool calendarVisible: false
    property var toast: dynamicToastLoader.item
    property var theme: themeEngine.theme
    property int themeUpdateTrigger: themeEngine.themeUpdateTrigger
    property var notifications: []
    property string currentWeatherIcon: "❔"
    property string currentTemperature: "--"
    property string weatherText: "--°C"
    property bool timerActive: false
    property bool timerRunning: false
    property bool timerFinished: false
    property int timerRemaining: 0
    property int timerDuration: 0
    property bool timerOsdVisible: false
    property bool timerControlOsdVisible: false
    property bool updateAuthVisible: false

    // Dynamic Island State Controls
    property bool launcherVisible: false
    property string searchText: ""
    property int selectedIndex: 0
    property var apps: []
    property var filteredApps: []
    property var parsedApps: []
    property bool calcMode: false
    property int islandTopMargin: 4
    property int collapsedOpticalOffset: 6
    readonly property int islandStateCollapsed: 0
    readonly property int islandStateExpanded: 1
    readonly property int islandStateClosing: 2

    property int islandState: islandStateCollapsed
  
    property bool islandExpanded:
    launcherVisible ||
    panelVisible ||
    mediaVisible

    property bool showHoverModules:
    detector.activeHover &&
    !root.launcherVisible &&
    !root.panelVisible &&
    !root.weatherVisible &&
    !root.themeVisible

    // Legacy context routing maps
    property var bar: root
    property var globalClock: clock
     
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    // =====================================================
    // ACTIVE CORE UTILITY PROCESSES
    // =====================================================
    Process { id: vpnRunner }
    Process { id: caffeineProc }
    Process { id: spotifyControl }
    Process { id: spotifyProc; command: ["sh", "-c", "/home/igor/.config/waybar/scripts/spotify.sh"]; running: true; stdout: StdioCollector { onTextChanged: { try { let j = JSON.parse(text.trim()); root.spotifyTrack = j.text || ""; root.spotifyArtUrl = j.art || ""; root.spotifyPosition = Number(j.position) || 0; root.spotifyLength = Number(j.length) || 0; root.spotifyStatus = j.status || "Paused";} catch(e) {} } } }
    Process { id : volumeProc }
    Process { id: wallpaperProc; stdout: StdioCollector { onTextChanged: { root.wallpapers = text.trim().split("\n").filter(path => path.length > 0);  } } }
    Process { id: themeFolderProc; command: ["sh", "-c", `find ~/Pictures/Wallpapers/${root.currentResolutionFolder} -mindepth 1 -maxdepth 1 -type d -printf '%f\n'`]; running: true; stdout: StdioCollector { onTextChanged: { root.themeFolders = [""].concat(text.trim().split("\n").filter(x => x.length > 0)) } } }
    Process { id: applyWallpaper}
    Process { id: updateCheck; command: ["sh", "-c", "~/.config/scripts/updates.sh"]; stdout: StdioCollector { onStreamFinished: { updateCount = text.trim() || "0" }}}
    Process { id: cpuCheck; command: ["sh", "-c", "sensors -u k10temp-pci-00c3 | awk '/temp1_input:/ {print int($2)}'"]; stdout: StdioCollector { onTextChanged: root.cpuTemp = (text.trim() || "00") + "°C" } }
    Process { id: cpuUsageCheck; command: ["sh", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total1=$((user + nice + system + idle + iowait + irq + softirq + steal)); idle1=$((idle + iowait)); sleep 0.1; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total2=$((user + nice + system + idle + iowait + irq + softirq + steal)); idle2=$((idle + iowait)); total=$((total2 - total1)); idle=$((idle2 - idle1)); usage=$((100 * (total - idle) / total)); echo \"${usage}%\""]; stdout: StdioCollector { onStreamFinished: { root.cpuUsage = text.trim() || "--" } } }
    Process { id: gpuCheck; command: ["sh", "-c", "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1"]; stdout: StdioCollector { onTextChanged: root.gpuTemp = (text.trim() || "00") + "°C" } }
    Process { id: uptimeCheck; command: ["sh", "-c", "uptime -p | sed 's/up //; s/ hours,/h/; s/ minutes/m/'"]; stdout: StdioCollector { onTextChanged: root.systemUptime = text.trim() } }
    Process { id: diskCheck; command: ["sh", "-c", "df -h | awk '$6==\"/mnt/data\" {print \"DATA:\" $3 \" / \" $2} $6==\"/home\" {print \"HOME:\" $3 \" / \" $2}'" ]; stdout: StdioCollector { onTextChanged: { let lines = text.trim().split("\n"); root.dataUsage = "0 / 1"; root.homeUsage = "0 / 1"; for (let line of lines) { if (line.startsWith("DATA:")) root.dataUsage = line.replace("DATA:", ""); if (line.startsWith("HOME:")) root.homeUsage = line.replace("HOME:", ""); } } } }
    Process { id: ramCheck; command: ["sh", "-c", "free -h --si | awk '/^Mem:/ {print $3 \" \" $2}' | sed 's/Gi/GB/g'"]; stdout: StdioCollector { onTextChanged: { let parts = text.trim().split(/\s+/); if (parts.length >= 2) { root.ramUsage = parts[0]; root.ramTotal = parts[1]; } } } }
    Process { id: checkCurrent; command: ["cat", "/home/igor/.config/.current_theme"]; stdout: StdioCollector { onTextChanged: root.currentTheme = text.trim() }}
    Process { id: getThemes; command: ["sh", "-c", "ls /home/igor/.config/themes/*.sh | xargs -n1 basename | sed 's/.sh$//'"]; stdout: StdioCollector { onTextChanged: root.themes = text.trim().split("\n").filter(name => name.length > 0) } }
    Process {
    id: barWeatherProc

    command: ["/home/igor/.config/waybar/scripts/weather.sh"]
    running: true

    stdout: StdioCollector {
        onTextChanged: {
            const output = text.trim()

            if (!output)
                return

            const parts = output.split(/\s+/)

            root.currentWeatherIcon = parts[0] || "❔"
            root.currentTemperature = parts[1]
                ? parts[1].replace("°C", "")
                : "--"
        }
    }
}    
    

    Component.onCompleted: { updateCheck.running = true; scanWallpapers()} 

    function scanWallpapers() { wallpaperProc.command = ["sh", "-c", `find "$HOME/Pictures/Wallpapers/${root.currentResolutionFolder}" -type f \\( -iname '*.jpeg' -o -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \\)`]; wallpaperProc.running = true }
    // =====================================================
    // CORE SYSTEM STATISTICS REFRESH TIMER
    // =====================================================
    Timer { id: statsPoller; interval: (detector.activeHover || root.panelVisible) ? 2000 : 8000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { cpuUsageCheck.running = true; ramCheck.running = true; if (detector.activeHover || root.panelVisible) { cpuCheck.running = true; gpuCheck.running = true; uptimeCheck.running = true; diskCheck.running = true } } }
    Timer { interval: 500; running: true; repeat: true; onTriggered: { if (!spotifyProc.running) spotifyProc.running = true } }
    Timer { interval: 600000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { if (!updateCheck.running) updateCheck.running = true } }
    Timer { interval: 600000; running: true; repeat: true; onTriggered: { if (!barWeatherProc.running) barWeatherProc.running = true }}
    Timer { id: countdownTimer; interval: 1000; repeat: true }

// ============================================================
// TIMER ENGINE
// ============================================================

Timer {
    id: timerCountdown

    interval: 1000
    repeat: true
    running: root.timerRunning

    onTriggered: {
        if (root.timerRemaining <= 0)
            return

        root.timerRemaining--

        if (root.timerRemaining <= 0) {
            root.timerRemaining = 0
            root.timerRunning = false
            root.timerFinished = true
            root.timerActive = false
            root.timerOsdVisible = false
        }
    }
}

// ============================================================
// TIMER FUNCTIONS
// ============================================================

function startTimer(seconds) {
    if (seconds <= 0)
        return

    root.timerDuration = seconds
    root.timerRemaining = seconds
    root.timerRunning = true
    root.timerFinished = false
    root.timerActive = true
}

function pauseTimer() {
    root.timerRunning = false

}

function resumeTimer() {
    if (root.timerRemaining <= 0)
        return

    root.timerFinished = false
    root.timerRunning = true

}

function toggleTimer() {
    if (root.timerFinished)
        return

    if (root.timerRunning)
        pauseTimer()
    else
        resumeTimer()
}

function adjustTimer(seconds) {
    if (!root.timerActive || root.timerFinished)
        return

    root.timerRemaining =
        Math.max(
            0,
            root.timerRemaining + seconds
        )

    root.timerDuration =
        Math.max(
            0,
            root.timerDuration + seconds
        )

    if (root.timerRemaining <= 0) {
        root.timerRemaining = 0
        root.timerRunning = false
        root.timerFinished = true
    }
}

function closeTimerControlOsd() {
    root.timerControlOsdVisible = false
    root.islandState = root.islandStateClosing

    Qt.callLater(function() {
        root.islandState = root.islandStateCollapsed
    })

}

function dismissTimer() {
    root.timerRunning = false
    root.timerFinished = false
    root.timerActive = false
    root.timerOsdVisible = false

    root.timerRemaining = 0
    root.timerDuration = 0

    root.islandState = root.islandStateClosing

    Qt.callLater(function() {
        root.islandState = root.islandStateCollapsed
    })
}

    // =====================================================
    // EVENT-DRIVEN INSTANT PANEL REFRESH HOOK
    // =====================================================
    // The exact millisecond you click your gear icon to open the panel, 
    // this forces an instant data pull so your numbers update without lag!
    onPanelVisibleChanged: {
        if (root.panelVisible) {
            statsPoller.triggered()
        }
    }
 
// =====================================================
// OSD HIDE TIMER
// =====================================================
Timer { id: capsHideTimer; interval: 1200; repeat: false; onTriggered: { if (root.osdMode === "caps") { root.islandState = root.islandStateClosing; capsCloseTimer.start() } } }
Timer { id: capsCloseTimer; interval: 300; repeat: false; onTriggered: { root.osdMode = ""; root.islandState = root.islandStateCollapsed } }
Timer { id: osdHideTimer; interval: 1500; repeat: false; onTriggered: if (root.osdMode === "volume") root.osdMode = "" }
Timer { id: toastHideTimer; interval: 5000; repeat: false; onTriggered: if (root.osdMode === "toast") { root.islandState = root.islandStateClosing; toastCloseTimer.start() } }
Timer { id: toastCloseTimer; interval: 300; repeat: false; onTriggered: { root.currentNotif = null; root.osdMode = ""; root.islandState = root.islandStateCollapsed } }

IpcHandler { target: "launcher"; function toggle() { root.launcherVisible = !root.launcherVisible; if (root.launcherVisible) launcher.openLauncher(); } }
IpcHandler { target: "timer"; function open() { root.timerOsdVisible = true }}

// =====================================================
// STATIC HOVER & CLICK ZONE
// =====================================================
Item {
    id: detector

    anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
        topMargin: 5
    }

    width: Math.max(520, island.width + 20)

    height:
        root.wallpaperVisible
        ? 650
        : root.weatherVisible
        ? 650
        : root.themeVisible
        ? 500
        : root.launcherVisible ||
          root.panelVisible ||
          root.mediaVisible
        ? 540
        : 42

    // -------------------------------------------------
    // STATE
    // -------------------------------------------------
    property bool isPinned: false
    property bool childHovered: false
    property bool activeHover: false
    property bool wallpaperHovered: false
    property bool volumeHovered: false
    property bool updatesHovered: false
    property bool launcherHovered: false
    property bool themeHovered: false
    property bool panelHovered: false
    property bool spotifyHovered: false
    property bool timerHovered: false
    property bool calendarHovered: false
    property bool authHovered: false
// -------------------------------------------------
// EXIT DEBOUNCE - FIXED FOR WORKSPACE HOVER
// -------------------------------------------------
Timer {
    id: hoverDebounceTimer

    interval: 200

    onTriggered: {

        // Never allow normal hover state while
        // the calendar is open.
        if (root.calendarVisible) {
            detector.activeHover = false
            return
        }

        if (root.updateAuthVisible) {
            detector.activeHover = false
            return
        }

        let workspacesHovered = false

        if (
            workspaceLoader &&
            workspaceLoader.item &&
            workspaceLoader.item.masterWorkspaceMouse
        ) {
            workspacesHovered =
                workspaceLoader.item.masterWorkspaceMouse.containsMouse
        }

        if (
            !masterHoverHandler.hovered &&
            !workspacesHovered &&
            !detector.wallpaperHovered &&
            !detector.volumeHovered &&
            !detector.updatesHovered &&
            !detector.launcherHovered &&
            !detector.themeHovered &&
            !detector.panelHovered &&
            !detector.spotifyHovered &&
            !detector.timerHovered &&
            !detector.authHovered &&
            !detector.isPinned
        ) {
            detector.activeHover = false
        }
    }
}

    // -------------------------------------------------
    // KEYBOARD FOCUS
    // -------------------------------------------------
    FocusScope {
    anchors.fill: parent

    focus:
        root.launcherVisible ||
        root.panelVisible ||
        root.mediaVisible ||
        root.weatherVisible ||
        root.themeVisible ||
        root.wallpaperVisible ||
        root.timerOsdVisible ||
        root.calendarVisible

    Keys.onEscapePressed: function(event) {
    root.launcherVisible = false
    root.panelVisible = false
    root.mediaVisible = false
    root.weatherVisible = false
    root.themeVisible = false
    root.wallpaperVisible = false
    root.calendarVisible = false

    if (root.timerOsdVisible) {
        root.timerOsdVisible = false
        root.islandState = root.islandStateClosing

        Qt.callLater(function() {
            root.islandState = root.islandStateCollapsed
        })
    }

    detector.isPinned = false
    detector.activeHover = false

    event.accepted = true
}
}
   
// -------------------------------------------------
// MASTER HOVER ZONE
// -------------------------------------------------
Item {
    id: masterHover

    anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
    }

    width: 760
    height: 80

    HoverHandler {
        id: masterHoverHandler

        onHoveredChanged: {

            // Calendar owns the island while it is open.
            // Normal hover expansion must not activate.
            if (root.calendarVisible) {
                detector.activeHover = false
                hoverDebounceTimer.stop()
                return
            }

            if (root.updateAuthVisible) {
                detector.activeHover = false
                hoverDebounceTimer.stop()
                return
            }

            if (hovered) {
                detector.activeHover = true
                hoverDebounceTimer.stop()
            } else {
                hoverDebounceTimer.start()
            }
        }
    }

// =====================================================
// VISUAL ISLAND
// =====================================================

Rectangle {
    id: island
    
    // =================================================
    // BASIC SETUP
    // =================================================

    clip: true


   anchors {
    horizontalCenter: parent.horizontalCenter
    top: parent.top
    topMargin: root.islandTopMargin
}

// =====================================================
// RIGHT CLICK - PIN BAR
// =====================================================

MouseArea {
    id: islandPinMouse

    anchors.fill: parent
    acceptedButtons: Qt.RightButton

    z: -1

    onClicked: {
        detector.isPinned = !detector.isPinned

        if (detector.isPinned) {
            detector.activeHover = true
            hoverDebounceTimer.stop()
        } else {
            hoverDebounceTimer.start()
        }
    }
}

// =====================================================
// POLKIT SERVICE ERROR INTERCEPTOR
// =====================================================
Connections {
    target: polkitService.flow
    enabled: !!polkitService.flow
    ignoreUnknownSignals: true

    function onAuthenticationFailed() {
        if (updateAuthLoader.item) {
            updateAuthLoader.item.statusText = "Invalid password. Please try again."
            updateAuthLoader.item.clearPassword()
        }
    }
}

// =====================================================
// PKEXEC AUTH MODULE
// =====================================================
Loader {
    id: updateAuthLoader
    anchors.fill: parent
    active: root.updateAuthVisible
    source: "components/UpdateAuthModule.qml"
    focus: true
    visible: active

    onItemChanged: {
        if (item) {
            item.theme = root.theme

            // Safely grab the description from the root service tracking frame
            if (polkitService.flow) {
                item.actionDescription = polkitService.flow.message
            }

            Qt.callLater(function() {
                item.forceInputFocus()
            })
        }
    }

    Connections {
    target: updateAuthLoader.item
    ignoreUnknownSignals: true

    function onAuthenticated(password) {
        if (polkitService.flow) {
            polkitService.flow.submit(password)
        }
        // Do NOT hide the dialog here.
        // Let the flow finish (success → isActive becomes false)
    }

    function onCancelled() {
        if (polkitService.flow) {
            polkitService.flow.cancelAuthenticationRequest()
        }
        root.updateAuthVisible = false
    }
 }
}


// =====================================================
// DYNAMIC ISLAND TOAST OSD
// =====================================================

Loader {
    id: dynamicToastLoader

    active: true
    visible: root.osdMode === "toast"

    anchors.fill: parent

    source: "components/Toast.qml"

    Binding { target: dynamicToastLoader.item; property: "theme"; value: root.theme; when: dynamicToastLoader.status === Loader.Ready }
    Binding { target: dynamicToastLoader.item; property: "currentNotif"; value: root.currentNotif; when: dynamicToastLoader.status === Loader.Ready }
    Binding { target: dynamicToastLoader.item; property: "doNotDisturb"; value: root.dndEnabled; when: dynamicToastLoader.status === Loader.Ready }
    Binding { target: dynamicToastLoader.item; property: "spotifyArtUrl"; value: root.spotifyArtUrl; when: dynamicToastLoader.status === Loader.Ready }

    Connections {
        target: dynamicToastLoader.item
        ignoreUnknownSignals: true

        function onDismiss() {

    if (root.currentNotif) {
        let key = String(root.currentNotif.id || (root.currentNotif.summary + root.currentNotif.body))

        try {
            let seen = JSON.parse(persist.seenJson)
            delete seen[key]
            persist.seenJson = JSON.stringify(seen)
        } catch(e) {}
    }

    root.islandState = root.islandClosing

    toastCloseTimer.start()
}


        function onToastTriggered() {
            root.mediaVisible = false
            root.panelVisible = false
            root.launcherVisible = false
            root.weatherVisible = false
            root.themeVisible = false
            root.wallpaperVisible = false

            root.osdMode = "toast"
            toastHideTimer.restart()
        }
    }
}

// =====================================================
// CAPS LOCK OSD
// =====================================================

Loader {
    id: capsLockOsdLoader
    active: true
    visible: root.osdMode === "caps"
    anchors.fill: parent
    source: "components/CapsLockOSD.qml"
    
    onLoaded: {
        item.theme = theme
        item.osdTriggered.connect(
            function() {
                root.osdMode = "caps"
                capsHideTimer.restart()
            }
        )
    }
}
// =====================================================
// VOLUME OSD
// =====================================================

Loader {
    id: volumeOsdLoader
    active: true
    visible: root.osdMode === "volume"
    anchors.fill: parent
    source: "components/VolumeOSD.qml"

    onLoaded: {
        item.theme = theme
        item.osdTriggered.connect(
            function() {
                root.osdMode = "volume"
                osdHideTimer.restart()
            }
        )
    }
}
// =======================================================
// Timer OSD Controller
// =======================================================

Loader {
    id: timerControlOsdLoader
    active: root.timerControlOsdVisible
    visible: root.timerControlOsdVisible && item
    anchors.centerIn: parent
    source: "components/TimerControlOSD.qml"

    width: item ? item.implicitWidth : 0
    height: item ? item.implicitHeight : 0

    z: 500

    Binding { target: timerControlOsdLoader.item; property: "theme"; value: root.theme; when: timerControlOsdLoader.status === Loader.Ready }
    Binding { target: timerControlOsdLoader.item; property: "remainingSeconds"; value: root.timerRemaining; when: timerControlOsdLoader.status === Loader.Ready }
    Binding { target: timerControlOsdLoader.item; property: "running"; value: root.timerRunning; when: timerControlOsdLoader.status === Loader.Ready }

    Connections {
    target: timerControlOsdLoader.item
    ignoreUnknownSignals: true

    function onPauseRequested() {
        root.pauseTimer()
    }

    function onResumeRequested() {
        root.resumeTimer()
    }

    function onDismissRequested() {
        root.closeTimerControlOsd()
    }

   function onCancelRequested() {
    root.closeTimerControlOsd()
    root.dismissTimer()
    }
  }
}
// =====================================================
// TIMER OSD LOADER
// =====================================================

Loader {
    id: timerOsdLoader
    active: root.timerOsdVisible
    visible: root.timerOsdVisible && item
    anchors.centerIn: parent
    source: "components/TimerOSD.qml"

    width: item ? item.implicitWidth : 0
    height: item ? item.implicitHeight : 0

    z: 500

    Binding { target: timerOsdLoader.item; property: "theme"; value: root.theme; when: timerOsdLoader.status === Loader.Ready }

    Connections {
        target: timerOsdLoader.item
        ignoreUnknownSignals: true

        function onStartRequested(seconds) {
            root.startTimer(seconds)
            root.timerOsdVisible = false
        }

        function onDismissRequested() {
            root.timerOsdVisible = false
        }
    }
}
// =====================================================
// WALLPAPER SELECTOR
// =====================================================

Loader {
    id: wallpaperSelectorLoader
    active: root.wallpaperVisible
    visible: root.wallpaperVisible
    anchors.fill: parent
    anchors.margins: 14
    source: "components/Wallpapers.qml"

    Connections { 
        target: wallpaperSelectorLoader.item 
        function onCloseRequested() { 
            root.wallpaperVisible = false; 
        } 
        function onResolutionChanged(folder) { 
            root.currentResolutionFolder = folder; 
            root.scanWallpapers(); 
        } 
    }

    // Single unified set of safe bindings
    Binding { target: wallpaperSelectorLoader.item; property: "theme"; value: root.theme; when: wallpaperSelectorLoader.status === Loader.Ready }
    Binding { target: wallpaperSelectorLoader.item; property: "themeFolders"; value: root.themeFolders; when: wallpaperSelectorLoader.status === Loader.Ready }
    Binding { target: wallpaperSelectorLoader.item; property: "wallpapers"; value: root.wallpapers; when: wallpaperSelectorLoader.status === Loader.Ready }
    Binding { target: wallpaperSelectorLoader.item; property: "applyWallpaper"; value: applyWallpaper; when: wallpaperSelectorLoader.status === Loader.Ready }
    Binding { target: wallpaperSelectorLoader.item; property: "wallpaperProc"; value: wallpaperProc; when: wallpaperSelectorLoader.status === Loader.Ready }
}

// =====================================================
// THEME SELECTOR
// =====================================================

Loader {
    id: themeSelectorLoader
    active: root.themeVisible
    visible: root.themeVisible
    anchors {
        fill: parent
        margins: 14
    }
    source: "components/Themes.qml"

    Binding { target: themeSelectorLoader.item; property: "theme";        value: root.theme;          when: themeSelectorLoader.status === Loader.Ready }
    Binding { target: themeSelectorLoader.item; property: "currentTheme"; value: root.currentTheme;   when: themeSelectorLoader.status === Loader.Ready }
    Binding { target: themeSelectorLoader.item; property: "checkCurrent"; value: checkCurrent;        when: themeSelectorLoader.status === Loader.Ready }
    Binding { target: themeSelectorLoader.item; property: "getThemes";    value: getThemes;           when: themeSelectorLoader.status === Loader.Ready }
    Binding { target: themeSelectorLoader.item; property: "themeLoader";  value: themeEngine.themeLoader; when: themeSelectorLoader.status === Loader.Ready }
    Binding { target: themeSelectorLoader.item; property: "themes";       value: root.themes;         when: themeSelectorLoader.status === Loader.Ready }

    // Catch the signal and update the real currentTheme
    Connections {
        target: themeSelectorLoader.item
        ignoreUnknownSignals: true

        function onThemeSelected(name) {
            root.currentTheme = name
        }
    }
}
// =================================================
// WIDTH
// =================================================

width:
    root.osdMode === "toast" ? 300

    : root.osdMode === "volume" ? 240

    : root.osdMode === "caps" ? 210

    : root.timerOsdVisible || root.timerControlOsdVisible? 300

    : root.panelVisible ? 400

    : root.launcherVisible ? 530

    : root.mediaVisible ? 460

    : root.weatherVisible ? 560

    : root.calendarVisible ? 440

    : root.themeVisible ? 540

    : root.wallpaperVisible ? 968

    : root.updateAuthVisible ? 540

    : (detector.activeHover || detector.wallpaperHovered || detector.timerHovered || detector.volumeHovered || detector.themeHovered || detector.calendarHovered || detector.authHovered || root.spotifyTrack !== "")

    ? (topBarHeader.width + 32)
    
    : (topBarHeader.width + 20)

// =================================================
// HEIGHT
// =================================================

height:

    root.islandState === root.islandStateClosing ? 42

    : root.osdMode === "volume" ? 40

    : root.osdMode === "caps" ? 60
    
     : root.timerOsdVisible || root.timerControlOsdVisible ? 70

    : root.osdMode === "toast" ? 80

    : root.panelVisible ? root.islandTopMargin + topBarHeader.height + embeddedSystemContent.height + 14

    : root.launcherVisible ? 530

    : root.mediaVisible ? 220

    : root.weatherVisible ? 540

    : root.calendarVisible ? 500

    : root.themeVisible ? 420

    : root.wallpaperVisible ? 680

    : root.updateAuthVisible ? 280

    : 42

    radius: (root.launcherVisible || root.panelVisible) ? 16 : 21

    scale: detector.activeHover ? 1.01 : 1.0

    color: root.theme.bg

    Connections { target: root; function onSpotifyTrackChanged() {}}

    // ============================================================
    // ANIMATIONS (Perfect Frame-Rate Synchronization)
    // ============================================================
Behavior on width  { NumberAnimation { duration: 380; easing.type: Easing.OutCubic } }
Behavior on height { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
Behavior on radius { NumberAnimation { duration: 550; easing.type: Easing.OutQuad } }
Behavior on scale  { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

 // =======================================================
// Weather
// =======================================================
LocalComponents.Weather {
    id: weatherModule

    anchors {
        top: topBarHeader.bottom
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    visible: root.weatherVisible
    theme: root.theme
    z: 1
}

 // =======================================================
// Calendar
// =======================================================
LocalComponents.Calendar {
    id: calendarModule

    anchors {
        top: topBarHeader.bottom
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    visible: root.calendarVisible
    theme: root.theme
    z: 1
}

// ============================================================
// 1. TOP HEADER (DYNAMIC ISLAND CONTENT)
// ============================================================
Item {
    id: topBarHeader

    anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
    }

    width: mainRow.width
    height: 42

    z: 100

// =====================================================
// EMBEDDED MEDIA PLAYER
// =====================================================

Loader {
    id: embeddedMediaContent

    active: true
    visible: root.mediaVisible || root.islandState === root.islandStateClosing
    source: "components/MediaPlayer.qml"

    // Match the island’s media size
    width: root.mediaVisible ? 440 : 220
    // height is driven by MediaPlayer’s implicitHeight

    anchors {
        top: topBarHeader.bottom
        horizontalCenter: parent.horizontalCenter   // ← this is the critical change
        // do NOT use left: parent.left
    }

    onLoaded: {
        if (item) {
            item.anchors.fill = item.parent
            item.anchors.margins = 0
        }
    }

    Connections {
        target: embeddedMediaContent.item
        ignoreUnknownSignals: true

        function onClosingFinished() {
            root.mediaVisible = false
            root.islandState = root.islandStateCollapsed
        }
    }

    opacity: root.islandState === root.islandStateCollapsed ? 0.0 : 1.0

    Binding { target: embeddedMediaContent.item; property: "track";          value: root.spotifyTrack;    when: embeddedMediaContent.status === Loader.Ready }
    Binding { target: embeddedMediaContent.item; property: "artUrl";         value: root.spotifyArtUrl;   when: embeddedMediaContent.status === Loader.Ready }
    Binding { target: embeddedMediaContent.item; property: "position";       value: root.spotifyPosition; when: embeddedMediaContent.status === Loader.Ready }
    Binding { target: embeddedMediaContent.item; property: "length";         value: root.spotifyLength;   when: embeddedMediaContent.status === Loader.Ready }
    Binding { target: embeddedMediaContent.item; property: "status";         value: root.spotifyStatus;   when: embeddedMediaContent.status === Loader.Ready }
    Binding { target: embeddedMediaContent.item; property: "theme";          value: root.theme;           when: embeddedMediaContent.status === Loader.Ready }
    Binding { target: embeddedMediaContent.item; property: "spotifyControl"; value: spotifyControl;       when: embeddedMediaContent.status === Loader.Ready }
    Binding { target: embeddedMediaContent.item; property: "islandState";    value: root.islandState;     when: embeddedMediaContent.status === Loader.Ready }
}

    // ============================================================
    // MAIN ISLAND ROW
    // WORKSPACES -> CAVA -> LAUNCHER -> CLOCK -> SYSTEM -> SPOTIFY
    // ============================================================
    Row {
    id: mainRow

    anchors.centerIn: parent

    height: 42
    spacing: 10
    visible: root.osdMode === "" && !root.wallpaperVisible && !root.timerOsdVisible
    
    // ============================
    // LEFT SIDE
    // ============================
    Row {
        id: leftRow

        height: 42
        spacing: 6

// ========================================================
// WORKSPACES (HOVER ONLY)
// ========================================================

Loader {
    id: workspaceLoader
    active: true
    source: "components/Workspaces.qml"
    
    visible: detector.activeHover &&
             !root.islandExpanded &&
             !root.weatherVisible &&
             !root.themeVisible

    width: 184          
    height: 30
    opacity: visible ? 1 : 0   

    anchors.verticalCenter: parent.verticalCenter

    onLoaded: {
        if (item) {
            item.theme = theme
            item.detector = detector
        }
    }
}   
 
// ========================================================
// CAVA (MUSIC ONLY)
// ========================================================

Item {
    id: cavaWrapper
    width: cavaLoader.visible ? cavaLoader.width + 16 : 0
    height: 42

    Loader {
        id: cavaLoader

        active: true

        source: "components/Cava.qml"

        visible:
            item &&
            item.active &&
            root.spotifyTrack !== "" &&
            !root.islandExpanded &&
            !root.weatherVisible &&
            !root.themeVisible &&
            !root.calendarVisible

        width: visible && item ? item.visualWidth : 0
        height: 42

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 8
        }

        Behavior on width { NumberAnimation { duration: 250 }}
    }
} 
// ========================================================
// LAUNCHER BUTTON
// ========================================================

Buttons.LauncherButton {
    id: menuButton

    visible: root.showHoverModules && !root.mediaVisible
    theme: root.theme
    detector: detector
    osdActive: root.osdMode !== ""
    mediaVisible: root.mediaVisible

    onHoverEntered: {
        detector.launcherHovered = true
        detector.activeHover = true
        hoverDebounceTimer.stop()
    }

    onHoverExited: {
        detector.launcherHovered = false

        if (
            !detector.isPinned
        ) {
            hoverDebounceTimer.start()
        }
    }    

    onClicked: {

        root.panelVisible = false
        root.mediaVisible = false
        root.themeVisible = false
        root.wallpaperVisible = false
        root.weatherVisible = false
        root.launcherVisible = !root.launcherVisible

        if (
            root.launcherVisible
        ) {

            launcher.openLauncher()
        }
    }
}
// ========================================================
// WALLPAPER BUTTON
// ========================================================

Buttons.WallpaperButton {
    id: wallpaperButton

    visible: root.showHoverModules && !root.mediaVisible
    theme: root.theme
    wallpaperVisible: root.wallpaperVisible

    onHoverEntered: {
        detector.wallpaperHovered = true
        detector.activeHover = true
        hoverDebounceTimer.stop()
    }

    onHoverExited: {
        detector.wallpaperHovered = false

        if (
            !detector.isPinned
        ) {
            hoverDebounceTimer.start()
        }
    }

    onClicked: {
        root.panelVisible = false
        root.launcherVisible = false
        root.mediaVisible = false
        root.themeVisible = false
        root.weatherVisible = false
        root.wallpaperVisible = !root.wallpaperVisible
    }
}
// ========================================================
// THEME BUTTON
// ========================================================

Buttons.ThemeButton {
    id: themeButton
    
    visible: root.showHoverModules && !root.mediaVisible
    theme: root.theme
    detector: detector
    osdActive: root.osdMode !== ""
    mediaVisible: root.mediaVisible
    themeVisible: root.themeVisible

    onHoverEntered: {
        detector.themeHovered =true
        detector.activeHover = true
        hoverDebounceTimer.stop()
    }

    onHoverExited: {
        detector.themeHovered = false

        if (
            !detector.isPinned
        ) {
            hoverDebounceTimer.start()
        }
    }

    onClicked: {
        root.panelVisible = false
        root.launcherVisible = false
        root.wallpaperVisible = false
        root.weatherVisible = false
        root.themeVisible = !root.themeVisible
    }
}

// ---------------------------------------------
// LOAD THEME DATA FIRST
// ---------------------------------------------

Component.onCompleted: {
    getThemes.running = true
    checkCurrent.running = true
}
    
    // ============================
    // CENTER
    // ============================
    Row {
        id: centerRow

        height: 42
        spacing: 6
// ========================================================
// CLOCK
// =========================================================
LocalComponents.Clock {
    id: clockModule
    theme: root.theme
    visible: root.osdMode === "" && !root.mediaVisible 
    anchors.verticalCenter: parent.verticalCenter
    onClicked: {
        root.launcherVisible = false
        root.weatherVisible = false
        root.mediaVisible = false
        root.themeVisible = false
        root.wallpaperVisible = false
        root.spotifyVisible = false
        root.panelVisible = false
        root.calendarVisible = !root.calendarVisible

        if (root.calendarVisible) {
            detector.activeHover = false
            detector.childHovered = false
        }
    }
}

// =======================================================
// Timer
// =======================================================

Loader {
    id: timerLoader
    active: root.timerActive
    source: "components/Timer.qml"
    visible: root.timerActive && timerLoader.item
    width: visible && item ? item.implicitWidth : 0
    height: 30
    anchors.verticalCenter: parent.verticalCenter

    Binding { target: timerLoader.item; property: "theme"; value: root.theme; when: timerLoader.status === Loader.Ready }
    Binding { target: timerLoader.item; property: "running"; value: root.timerRunning; when: timerLoader.status === Loader.Ready }
    Binding { target: timerLoader.item; property: "finished"; value: root.timerFinished; when: timerLoader.status === Loader.Ready }
    Binding { target: timerLoader.item; property: "remainingSeconds"; value: root.timerRemaining; when: timerLoader.status === Loader.Ready }

    Connections {
    target: timerLoader.item
    ignoreUnknownSignals: true

    function onHoveredChanged() {
        detector.timerHovered =
            timerLoader.item.hovered

        if (timerLoader.item.hovered) {
            detector.activeHover = true
            hoverDebounceTimer.stop()
        } else if (!detector.isPinned) {
            hoverDebounceTimer.start()
        }
    }
}

Connections {
    target: timerLoader.item
    ignoreUnknownSignals: true

    function onClicked() {
        root.timerControlOsdVisible = true
    }
  }
}
// =======================================================
// Weather
// =======================================================

LocalComponents.BarWeather {
    id: weather
    theme: root.theme
    visible: root.osdMode === "" && !root.mediaVisible
    icon: root.currentWeatherIcon
    temperature: root.currentTemperature
    anchors.verticalCenter: parent.verticalCenter

    onClicked: {        
        root.weatherVisible = !root.weatherVisible
        root.mediaVisible = false
        root.panelVisible = false
        root.launcherVisible = false
        root.wallpaperVisible = false
        root.themeVisible = false
        root.calendarVisible = false
    }   

    height: 30
    }

}
    // ============================
    // RIGHT SIDE
    // ============================
    Row {
        id: rightRow
        height: 42
        spacing: 6
// ========================================================
// SYSTEM BUTTON
// ========================================================
Buttons.SystemButton {
    id: systemButton
    visible: root.showHoverModules && !root.mediaVisible
    theme: root.theme
    detector: detector
    onHoverEntered: {
        detector.panelHovered =true
        detector.activeHover = true
        hoverDebounceTimer.stop()
    }
    onHoverExited: {
        detector.panelHovered = false

        if (
            !detector.isPinned
        ) {
            hoverDebounceTimer.start()
        }
    }    
    onClicked: {
        root.launcherVisible = false
        root.weatherVisible = false
        root.mediaVisible = false
        root.themeVisible = false
        root.wallpaperVisible = false
        root.calendarVisible = false
        root.panelVisible = !root.panelVisible
    }
}
// ========================================================
// VOLUME BUTTON
// ========================================================

LocalComponents.Volume {
    id: volumeButton
    visible: root.showHoverModules && !root.mediaVisible
    height: 30
    anchors.verticalCenter: parent.verticalCenter
    theme: root.theme
    volumeProc: volumeProc
}
// ========================================================
// UPDATES
// ========================================================

LocalComponents.Updates {
    id: updatesButton
    visible: root.showHoverModules && !root.mediaVisible
    height: 32
    anchors.verticalCenter: parent.verticalCenter
    updateCount: root.updateCount
    theme: root.theme
    themeRunner: themeRunner
    updateCheck: updateCheck
}
// ========================================================
// VOLUME HOVER BRIDGE
// ========================================================
Connections { target: volumeButton; function onHoveredChanged() { detector.volumeHovered = volumeButton.hovered }}
Connections { target: updatesButton; function onHoveredChanged() { detector.updatesHovered = updatesButton.hovered; if (updatesButton.hovered) { detector.activeHover = true; hoverDebounceTimer.stop(); } else if (!detector.isPinned) { hoverDebounceTimer.start(); } } }

 // ========================================================
// SPOTIFY
// ========================================================

Loader {
    id: spotifyLoader
    active: true
    source: "components/Spotify.qml"
    visible: root.spotifyTrack !== "" &&
             !root.launcherVisible &&
             !root.panelVisible &&
             !root.weatherVisible &&
             !root.themeVisible &&
             !root.calendarVisible

    width: visible && item ? item.implicitWidth : 0
    height: 42
    anchors.verticalCenter: parent.verticalCenter

    Behavior on width { NumberAnimation { duration: 250 }}

    Binding { target: spotifyLoader.item; property: "track"; value: root.spotifyTrack; when: spotifyLoader.status === Loader.Ready }
    Binding { target: spotifyLoader.item; property: "artUrl"; value: root.spotifyArtUrl; when: spotifyLoader.status === Loader.Ready }
    Binding { target: spotifyLoader.item; property: "theme"; value: root.theme; when: spotifyLoader.status === Loader.Ready }
    Binding { target: spotifyLoader.item; property: "spotifyControl"; value: spotifyControl; when: spotifyLoader.status === Loader.Ready }
   
    Connections { 
    target: spotifyLoader.item
    ignoreUnknownSignals: true
    
    function onClicked() { 
        root.launcherVisible = false 
        root.panelVisible = false 
        root.themeVisible = false 
        root.weatherVisible = false 
        if (!root.mediaVisible) { 
            root.mediaVisible = true
            root.islandState = root.islandStateExpanded 
        } else { 
            root.islandState = root.islandStateClosing 
        } 
    } 

    // The new hover tracking logic to stop the jittering
    function onHoveredChanged() { 
    detector.spotifyHovered = spotifyLoader.item.hovered 
    
    if (spotifyLoader.item.hovered) { 
        hoverDebounceTimer.stop() 
    } else if (!detector.isPinned) { 
        hoverDebounceTimer.start() 
     } 
   }
  }
}
// ========================================================
// SYSTEM TRAY (HOVER / EXPANDED ISLAND ONLY)
// ========================================================

Loader {
    id: systemTrayLoader
    active: true
    source: "components/SystemTray.qml"
    visible:
        detector.activeHover &&
        !root.islandExpanded &&
        !root.weatherVisible &&
        !root.launcherVisible &&
        !root.panelVisible &&
        !root.themeVisible
        

    width: visible && item ? item.implicitWidth : 0
    height: 30
    anchors.verticalCenter: parent.verticalCenter
    onLoaded: { item.theme = theme }

    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic }}
        }
      }
    }
  }
} 
// ================================================
// Launcher
// ================================================
    LocalComponents.Launcher {
    id: launcher
    anchors {
        top: topBarHeader.bottom
        left: parent.left
        right: parent.right
        bottom: parent.bottom
        margins: 14
    }

    visible: root.launcherVisible
    theme: root.theme
    launcherVisible: root.launcherVisible
    onCloseRequested: {
    root.launcherVisible = false
  }     
}

// =====================================================
// 4. VIEWPORT 2: EMBEDDED SYSTEM PERFORMANCE VIEWS
// =====================================================

Item {
    id: embeddedSystemContent
    anchors {
        top: topBarHeader.bottom
        left: parent.left
        right: parent.right
    }
    height: systemDashboardTileModule.implicitHeight + 34
    opacity: root.panelVisible ? 1.0 : 0.0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration:
                root.panelVisible ? 180 : 100
        }
    }

    LocalComponents.SystemNew {
        id: systemDashboardTileModule
        width: 360
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 28
        }

        dndEnabled: root.dndEnabled

        onDndEnabledChanged: {
        if (dndEnabled !== root.dndEnabled) {
            root.dndEnabled = dndEnabled
        }
    }

        theme: root.theme
        globalClock: clock
        notifServer: notificationServer
        panelVisible: root.panelVisible
        cpuTemp: root.cpuTemp
        cpuUsage: root.cpuUsage
        gpuTemp: root.gpuTemp
        ramUsage: root.ramUsage
        dataUsage: root.dataUsage
        homeUsage: root.homeUsage
        systemUptime: root.systemUptime
        }
      }
    } 
  }
 }
}