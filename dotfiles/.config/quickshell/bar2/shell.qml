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
import "components/singletons"

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
    root.hubVisible ||
    root.launcherVisible ||
    root.panelVisible ||
    root.mediaVisible ||
    root.weatherVisible ||
    root.themeVisible ||
    root.wallpaperVisible ||
    root.timerOsdVisible ||
    root.calendarVisible ||
    root.networkVisible ||
    root.updateAuthVisible ||
    root.updatesVisible ||
    root.volumeVisible ||
    root.batteryVisible ||
    root.clipboardVisible ||
    root.torrentsVisible ||
    root.gitVisible
    mask: Region { item: clickAwayDismissMask.enabled ? clickAwayDismissMask : island }

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
// PERSISTENT BAR STATE: keeps the pin across reloads (e.g. theme changes)
// ===========================================================
PersistentProperties {
    id: barState
    reloadableId: "barPinState"

    property bool pinned: false

    onReloaded: {
        if (pinned) {
            detector.isPinned = true
            detector.activeHover = true
        }
    }
}

// ===========================================================
// Notifications Server
// ===========================================================

NotificationServer {
    id: notificationServer

    keepOnReload: true
    actionsSupported: true
    bodyMarkupSupported: true
    persistenceSupported: true

    onNotification: function(n) {
        if (!n) return;

        const app = String(n.appName || n.desktopEntry || "").toLowerCase();
        const isSpotify = app.includes("spotify");
        const isBetterbird = app.includes("betterbird") || app.includes("thunderbird");

        n.tracked = true;
        n.isSpotifyTransient = isSpotify;

        let key = String(n.id || (n.summary + n.body));
        if (isBetterbird) {
            key = key + "_" + Date.now();
        }
        n.historyKey = key; 
        let timestamps = {};
        let seen = {};
        try {
            timestamps = JSON.parse(persist.timestampsJson);
            seen = JSON.parse(persist.seenJson);
        } catch(e) { /* fallback to clean dictionaries */ }

        if (!timestamps[key]) {
            timestamps[key] = Date.now();
            persist.timestampsJson = JSON.stringify(timestamps);
        }
        n.timestamp = timestamps[key];
        
        if (!isSpotify) {
            NotificationHistory.addEntry(key, n.summary, n.body, n.timestamp, app);
        }

        if (n.lastGeneration || seen[key]) {
            return;
        }

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

        if (polkitService.isActive) {
            root.updatesVisible = false
        }

        if (polkitService.isActive && updateAuthLoader.item && polkitService.flow) {
            updateAuthLoader.item.actionDescription = polkitService.flow.message
        }
    }
}

    // =====================================================
    // THEME ENGINE
    // =====================================================

 LocalComponents.ThemeEngine { id: themeEngine }
    
    // =====================================================
    // AUTO-DISMISS CLICK AWAY MECHANISM 
    // =====================================================
    MouseArea {
    id: clickAwayDismissMask

    anchors.fill: parent

    enabled:
    root.hubVisible ||
    root.launcherVisible ||
    root.panelVisible ||
    root.mediaVisible ||
    root.themeVisible ||
    root.calendarVisible ||
    root.weatherVisible ||
    root.wallpaperVisible ||
    root.timerOsdVisible ||
    root.networkVisible ||
    root.timerControlOsdVisible ||
    root.updatesVisible || 
    root.volumeVisible || 
    root.batteryVisible ||
    root.clipboardVisible ||
    root.torrentsVisible ||
    root.gitVisible

    z: -1

    onClicked: {
        root.hubVisible = false
        root.launcherVisible = false
        root.panelVisible = false
        root.mediaVisible = false
        root.themeVisible = false
        root.calendarVisible = false
        root.weatherVisible = false
        root.wallpaperVisible = false
        root.networkVisible = false
        root.updatesVisible = false
        root.volumeVisible = false
        root.batteryVisible = false
        root.clipboardVisible = false
        root.torrentsVisible = false
        root.gitVisible = false
        
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
    property string spotifyIcon: ""
    property bool mediaVisible: false
    property bool volumeVisible: false
    property bool spotifyVisible: false
    property real spotifyPosition: 0
    property real spotifyLength: 0
    property string spotifyStatus: "Paused"
    property bool panelVisible: false
    property bool networkVisible: false
    property bool updatesVisible: false
    property bool batteryVisible: false
    property bool clipboardVisible: false
    property bool torrentsVisible: false
    property bool gitVisible: false
    property int gitChanges: 0      // uncommitted changes in the dotfiles repo
    property int gitAhead: 0        // commits not yet pushed
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
    property bool weatherVisible: false
    property bool calendarVisible: false

    // Hub (tabbed panel opened from the clock)
    property bool hubVisible: false
    property string hubTab: "today"
    readonly property int hubWidth: 940
    readonly property int hubHeight: 612

    // Opening any other panel closes the hub, so buttons don't need to know about it
    readonly property bool otherPanelOpen:
        launcherVisible || panelVisible || mediaVisible || weatherVisible || themeVisible ||
        wallpaperVisible || networkVisible || updatesVisible || volumeVisible || batteryVisible ||
        clipboardVisible || torrentsVisible || updateAuthVisible || gitVisible
    onOtherPanelOpenChanged: { if (otherPanelOpen) hubVisible = false }

    // Opening any other panel closes the git panel, so other buttons don't need to know about it
    readonly property bool nonGitPanelOpen:
        hubVisible || calendarVisible || launcherVisible || panelVisible || mediaVisible || weatherVisible ||
        themeVisible || wallpaperVisible || networkVisible || updatesVisible || volumeVisible || batteryVisible ||
        clipboardVisible || torrentsVisible || updateAuthVisible
    onNonGitPanelOpenChanged: { if (nonGitPanelOpen) gitVisible = false }

    readonly property bool systemTabOpen: hubVisible && hubTab === "system"
    onSystemTabOpenChanged: { if (systemTabOpen) statsPoller.triggered() }
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
    property int archCount: 0
    property int aurCount: 0
    property int flatpakCount: 0
    property string archChecked: "—"
    property string aurChecked: "—"
    property string flatpakChecked: "—"
    property bool updatesChecking: false
    readonly property int totalUpdateCount: archCount + aurCount + flatpakCount

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
    mediaVisible ||
    networkVisible ||
    updatesVisible ||
    updateAuthVisible ||
    volumeVisible ||
    batteryVisible ||
    wallpaperVisible ||
    clipboardVisible ||
    torrentsVisible ||
    gitVisible

    property bool showHoverModules:
    detector.activeHover &&
    !root.launcherVisible &&
    !root.panelVisible &&
    !root.weatherVisible &&
    !root.themeVisible &&
    !root.networkVisible &&
    !root.updatesVisible &&
    !root.volumeVisible &&
    !root.batteryVisible &&
    !root.wallpaperVisible &&
    !root.clipboardVisible &&
    !root.torrentsVisible &&
    !root.gitVisible

    property var bar: root
    property var globalClock: clock
     
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    // =====================================================
    // ACTIVE CORE UTILITY PROCESSES
    // =====================================================
    Process { id: vpnRunner }
    Process { id: caffeineProc }
    Process { id: spotifyControl }
    Process { id: spotifyProc; command: ["sh", "-c", "/home/igor/.config/waybar/scripts/spotify.sh"]; running: true; stdout: StdioCollector { onTextChanged: { try { let j = JSON.parse(text.trim()); root.spotifyTrack = j.text || ""; root.spotifyIcon = j.icon || ""; root.spotifyArtUrl = j.art || ""; root.spotifyPosition = Number(j.position) || 0; root.spotifyLength = Number(j.length) || 0; root.spotifyStatus = j.status || "Paused"; } catch(e) {} } } }
    Process { id : volumeProc }
    Process { id: wallpaperProc; stdout: StdioCollector { onTextChanged: { root.wallpapers = text.trim().split("\n").filter(path => path.length > 0);  } } }
    Process { id: themeFolderProc; command: ["sh", "-c", `find ~/Pictures/Wallpapers/${root.currentResolutionFolder} -mindepth 1 -maxdepth 1 -type d -printf '%f\n'`]; running: true; stdout: StdioCollector { onTextChanged: { root.themeFolders = [""].concat(text.trim().split("\n").filter(x => x.length > 0)) } } }
    Process { id: applyWallpaper}
    Process { id: cpuCheck; command: ["sh", "-c", "sensors -u k10temp-pci-00c3 | awk '/temp1_input:/ {print int($2)}'"]; stdout: StdioCollector { onTextChanged: root.cpuTemp = (text.trim() || "00") + "°C" } }
    Process { id: cpuUsageCheck; command: ["sh", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total1=$((user + nice + system + idle + iowait + irq + softirq + steal)); idle1=$((idle + iowait)); sleep 0.1; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total2=$((user + nice + system + idle + iowait + irq + softirq + steal)); idle2=$((idle + iowait)); total=$((total2 - total1)); idle=$((idle2 - idle1)); usage=$((100 * (total - idle) / total)); echo \"${usage}%\""]; stdout: StdioCollector { onStreamFinished: { root.cpuUsage = text.trim() || "--" } } }
    Process { id: gpuCheck; command: ["sh", "-c", "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1"]; stdout: StdioCollector { onTextChanged: root.gpuTemp = (text.trim() || "00") + "°C" } }
    Process { id: uptimeCheck; command: ["sh", "-c", "uptime -p | sed 's/up //; s/ hours,/h/; s/ minutes/m/'"]; stdout: StdioCollector { onTextChanged: root.systemUptime = text.trim() } }
    Process { id: diskCheck; command: ["sh", "-c", "df -h | awk '$6==\"/mnt/data\" {print \"DATA:\" $3 \" / \" $2} $6==\"/home\" {print \"HOME:\" $3 \" / \" $2}'" ]; stdout: StdioCollector { onTextChanged: { let lines = text.trim().split("\n"); root.dataUsage = "0 / 1"; root.homeUsage = "0 / 1"; for (let line of lines) { if (line.startsWith("DATA:")) root.dataUsage = line.replace("DATA:", ""); if (line.startsWith("HOME:")) root.homeUsage = line.replace("HOME:", ""); } } } }
    Process { id: ramCheck; command: ["sh", "-c", "free -h --si | awk '/^Mem:/ {print $3 \" \" $2}' | sed 's/Gi/GB/g'"]; stdout: StdioCollector { onTextChanged: { let parts = text.trim().split(/\s+/); if (parts.length >= 2) { root.ramUsage = parts[0]; root.ramTotal = parts[1]; } } } }
    Process { id: checkCurrent; command: ["cat", "/home/igor/.config/.current_theme"]; stdout: StdioCollector { onTextChanged: root.currentTheme = text.trim() }}
    Process { id: getThemes; command: ["sh", "-c", "find -H /home/igor/.config/themes -maxdepth 1 -mindepth 1 -type d ! -name templates -printf '%f\\n' | sort"]; stdout: StdioCollector { onTextChanged: root.themes = text.trim().split("\n").filter(name => name.length > 0) } }
    Process { id: archCheck; command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]; stdout: SplitParser { onRead: line => { const n = parseInt(line.trim()); root.archCount = isNaN(n) ? 0 : n; root.archChecked = root.tsNow() } } }
    Process { id: aurCheck; command: ["sh", "-c", "yay -Qua 2>/dev/null | wc -l"]; stdout: SplitParser { onRead: line => { const n = parseInt(line.trim()); root.aurCount = isNaN(n) ? 0 : n; root.aurChecked = root.tsNow() } } }
    Process { id: flatpakCheck; command: ["sh", "-c", "flatpak remote-ls --updates 2>/dev/null | wc -l"]; stdout: SplitParser { onRead: line => { const n = parseInt(line.trim()); root.flatpakCount = isNaN(n) ? 0 : n; root.flatpakChecked = root.tsNow() } } }
    Process { id: archUpdateProcess; command: ["kitty", "-e", "pkexec", "bash", "-c", "pacman -Syu"]; onExited: root.checkAllUpdates() }
    Process { id: aurUpdateProcess; command: ["kitty", "-e", "bash", "-c", "yay -Syu --aur"]; onExited: root.checkAllUpdates() }
    Process { id: flatpakUpdateProcess; command: ["kitty", "-e", "bash", "-c", "flatpak update"]; onExited: root.checkAllUpdates() }
    Process { id: barWeatherProc; command: ["/home/igor/.config/waybar/scripts/weather.sh"]; running: true; stdout: StdioCollector { onTextChanged: { const output = text.trim(); if (!output) return; const parts = output.split(/\s+/); root.currentWeatherIcon = parts[0] || "❔"; root.currentTemperature = parts[1] ? parts[1].replace("°C", "") : "--"; } } }
    
    Component.onCompleted: {scanWallpapers(); root.checkAllUpdates()} 

    function scanWallpapers() { wallpaperProc.command = ["sh", "-c", `find "$HOME/Pictures/Wallpapers/${root.currentResolutionFolder}" -type f \\( -iname '*.jpeg' -o -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \\)`]; wallpaperProc.running = true }

    // ---------- git: keep the bar button's dot current ----------
    function checkGit() { gitPoll.running = true }
    Process {
        id: gitPoll
        command: ["bash", "-c",
            'cd "$HOME/Projects/aneks" 2>/dev/null || exit 0\n' +
            'git status --porcelain | wc -l\n' +
            'git rev-list --count @{u}..HEAD 2>/dev/null || echo 0']
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim().split("\n")
                root.gitChanges = parseInt(v[0]) || 0
                root.gitAhead = parseInt(v[1]) || 0
            }
        }
    }
    Timer { interval: 30000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.checkGit() }
    onGitVisibleChanged: if (!gitVisible) checkGit()

    function tsNow() {
    return Qt.formatTime(new Date(), "hh:mm:ss")
    }

    function checkAllUpdates() {
    root.updatesChecking = true
    archCheck.running = true
    aurCheck.running = true
    flatpakCheck.running = true
    updatesCheckingResetTimer.start()
   }
    
    function updateArch() { archUpdateProcess.running = true }
    function updateAur() { aurUpdateProcess.running = true }
    function updateFlatpak() { flatpakUpdateProcess.running = true } 

    // =====================================================
    // CORE SYSTEM STATISTICS REFRESH TIMER
    // =====================================================
    Timer { id: statsPoller; interval: (detector.activeHover || root.panelVisible || root.systemTabOpen) ? 2000 : 8000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { cpuUsageCheck.running = true; ramCheck.running = true; if (detector.activeHover || root.panelVisible || root.systemTabOpen) { cpuCheck.running = true; gpuCheck.running = true; uptimeCheck.running = true; diskCheck.running = true } } }
    Timer { interval: 500; running: true; repeat: true; onTriggered: { if (!spotifyProc.running) spotifyProc.running = true } }
    Timer { interval: 600000; running: true; repeat: true; onTriggered: { if (!barWeatherProc.running) barWeatherProc.running = true }}
    Timer { id: countdownTimer; interval: 1000; repeat: true }
    Timer { id: updatesCheckingResetTimer; interval: 3000; onTriggered: root.updatesChecking = false }
    Timer { interval: 600000; running: true; repeat: true; onTriggered: root.checkAllUpdates() }

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

function startTimer(seconds) { if (seconds > 0) { root.timerDuration = seconds; root.timerRemaining = seconds; root.timerRunning = true; root.timerFinished = false; root.timerActive = true; } }
function pauseTimer() { root.timerRunning = false; }
function resumeTimer() { if (root.timerRemaining > 0) { root.timerFinished = false; root.timerRunning = true; } }
function toggleTimer() { if (!root.timerFinished) { root.timerRunning ? pauseTimer() : resumeTimer(); } }
function adjustTimer(seconds) { if (root.timerActive && !root.timerFinished) { root.timerRemaining = Math.max(0, root.timerRemaining + seconds); root.timerDuration = Math.max(0, root.timerDuration + seconds); if (root.timerRemaining <= 0) { root.timerRemaining = 0; root.timerRunning = false; root.timerFinished = true; } } }
function closeTimerControlOsd() { root.timerControlOsdVisible = false; root.islandState = root.islandStateClosing; Qt.callLater(() => root.islandState = root.islandStateCollapsed); }
function dismissTimer() { root.timerRunning = false; root.timerFinished = false; root.timerActive = false; root.timerOsdVisible = false; root.timerRemaining = 0; root.timerDuration = 0; root.islandState = root.islandStateClosing; Qt.callLater(() => root.islandState = root.islandStateCollapsed); }

    // =====================================================
    // EVENT-DRIVEN INSTANT PANEL REFRESH HOOK
    // =====================================================
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
    : root.networkVisible
    ? 540
    : root.updateAuthVisible
    ? 300
    : root.updatesVisible
    ? 460
    : root.volumeVisible
    ? 540
    : root.launcherVisible ||
      root.panelVisible ||
      root.mediaVisible 
    ? 540
    : 42

    // -------------------------------------------------
    // STATE
    // -------------------------------------------------
    property bool isPinned: false
    onIsPinnedChanged: barState.pinned = isPinned
    property bool childHovered: false
    property bool activeHover: false
    property bool volumeHovered: false
    property bool updatesHovered: false
    property bool launcherHovered: false
    property bool themeHovered: false
    property bool networkHovered: false 
    property bool spotifyHovered: false
    property bool timerHovered: false
    property bool calendarHovered: false
    property bool authHovered: false
    property bool volumesHovered: false
    property bool batteryHovered: false
    property bool clipboardHovered: false
    property bool torrentsHovered: false
    property bool gitHovered: false

    // -------------------------------------------------
    // PINNED: return to expanded once every panel has closed
    // -------------------------------------------------
    readonly property bool anyPanelOpen:
        root.hubVisible ||
        root.launcherVisible ||
        root.panelVisible ||
        root.mediaVisible ||
        root.weatherVisible ||
        root.themeVisible ||
        root.wallpaperVisible ||
        root.calendarVisible ||
        root.networkVisible ||
        root.updatesVisible ||
        root.updateAuthVisible ||
        root.volumeVisible ||
        root.batteryVisible ||
        root.clipboardVisible ||
        root.torrentsVisible ||
        root.gitVisible

    onAnyPanelOpenChanged: {
        if (!anyPanelOpen && isPinned) {
            activeHover = true
            hoverDebounceTimer.stop()
        }
    }    
    
// -------------------------------------------------
// EXIT DEBOUNCE - FIXED FOR WORKSPACE HOVER
// -------------------------------------------------
Timer {
    id: hoverDebounceTimer

    interval: 200

    onTriggered: {

       if (root.hubVisible || root.calendarVisible || root.updateAuthVisible || root.networkVisible || root.clipboardVisible || root.volumeVisible || root.updatesVisible || root.batteryVisible || root.gitVisible) { if (root.hubVisible || root.calendarVisible || root.updateAuthVisible) detector.activeHover = false; return; }
       let workspacesHovered = !!(workspaceLoader?.item?.masterWorkspaceMouse?.containsMouse);

        if (
            !masterHoverHandler.hovered &&
            !workspacesHovered &&
            !detector.volumeHovered &&
            !detector.updatesHovered &&
            !detector.launcherHovered &&
            !detector.themeHovered &&
            !detector.spotifyHovered &&
            !detector.timerHovered &&
            !detector.authHovered &&
            !detector.networkHovered &&
            !detector.batteryHovered &&
            !detector.clipboardHovered &&
            !detector.torrentsHovered &&
            !detector.gitHovered &&
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
    id: globalFocusScope
    anchors.fill: parent

    focus:
        root.hubVisible ||
        root.launcherVisible ||
        root.panelVisible ||
        root.mediaVisible ||
        root.weatherVisible ||
        root.themeVisible ||
        root.wallpaperVisible ||
        root.timerOsdVisible ||
        root.calendarVisible ||
        root.networkVisible ||
        root.updatesVisible ||
        root.volumeVisible ||
        root.batteryVisible ||
        root.clipboardVisible ||
        root.torrentsVisible ||
        root.gitVisible

    Keys.onEscapePressed: function(event) {
    root.hubVisible = false
    root.launcherVisible = false
    root.panelVisible = false
    root.mediaVisible = false
    root.weatherVisible = false
    root.themeVisible = false
    root.wallpaperVisible = false
    root.calendarVisible = false
    root.networkVisible = false
    root.updatesVisible = false
    root.volumeVisible = false
    root.batteryVisible = false
    root.clipboardVisible = false
    root.torrentsVisible = false
    root.gitVisible = false

    if (root.timerOsdVisible) {
        root.timerOsdVisible = false
        root.islandState = root.islandStateClosing

        Qt.callLater(function() {
            root.islandState = root.islandStateCollapsed
        })
    }

   

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

            if (root.calendarVisible || root.hubVisible) {
                detector.activeHover = false
                hoverDebounceTimer.stop()
                return
            }

            if (root.networkVisible) {
                detector.activeHover = false
                hoverDebounceTimer.stop()
                return
            }

            if (root.torrentsVisible) {
                detector.activeHover = false
                hoverDebounceTimer.stop()
                return
            }

            if (root.gitVisible) {
                detector.activeHover = false
                hoverDebounceTimer.stop()
                return
            }


            if (root.volumeVisible) {
                detector.activeHover = false
                hoverDebounceTimer.stop()
                return
            }

            if (root.clipboardVisible) {
                detector.activeHover = false
                hoverDebounceTimer.stop()
                return
            }

            if (root.updatesVisible) {
                detector.activeHover = false
                hoverDebounceTimer.stop()
                return
            }

            if (root.updateAuthVisible) {
                detector.activeHover = false
                hoverDebounceTimer.stop()
                return
            }

            if (root.batteryVisible) {
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
            root.hubVisible = false
            root.mediaVisible = false
            root.panelVisible = false
            root.launcherVisible = false
            root.weatherVisible = false
            root.themeVisible = false
            root.wallpaperVisible = false
            root.networkVisible = false
            root.updatesVisible = false
            root.volumeVisible = false
            root.batteryVisible = false
            root.gitVisible = false
            root.clipboardVisible = false

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

    function onPauseRequested() { root.pauseTimer(); }
    function onResumeRequested() { root.resumeTimer(); }
    function onDismissRequested() { root.closeTimerControlOsd(); }
    function onCancelRequested() { root.closeTimerControlOsd(); root.dismissTimer(); }
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
        function onStartRequested(seconds) { root.startTimer(seconds); root.timerOsdVisible = false; }
        function onDismissRequested() { root.timerOsdVisible = false; }
    }
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

    Connections {
        target: themeSelectorLoader.item
        ignoreUnknownSignals: true

        function onThemeSelected(name) { root.currentTheme = name }
    }
}

// =====================================================
// UPDATES MODULE
// =====================================================
LocalComponents.UpdatesModule {
    id: updatesLoader

    anchors.fill: parent
    anchors.margins: 12

    visible: root.updatesVisible
    theme: root.theme

    archCount: root.archCount
    aurCount: root.aurCount
    flatpakCount: root.flatpakCount
    archChecked: root.archChecked
    aurChecked: root.aurChecked
    flatpakChecked: root.flatpakChecked
    checking: root.updatesChecking
    checkAll: root.checkAllUpdates
}

// =====================================================
// NETWORK MODULE
// =====================================================
LocalComponents.NetworkModule {
    id: networkLoader
    
    anchors.fill: parent
    anchors.margins: 12

    visible: root.networkVisible
    theme: root.theme
}

// =====================================================
// CLIPBOARD MODULE
// =====================================================
Loader {
    id: clipboardLoader
    active: root.clipboardVisible
    visible: root.clipboardVisible
    anchors { fill: parent; margins: 14 }
    source: "components/ClipboardHistory.qml"

    Binding { target: clipboardLoader.item; property: "theme"; value: root.theme; when: clipboardLoader.status === Loader.Ready }
}
// =====================================================
// GIT MODULE
// =====================================================
LocalComponents.GitModule {
    id: gitLoader
    anchors { fill: parent; margins: 14 }
    visible: root.gitVisible
    theme: root.theme
    onRefreshed: root.checkGit()

    opacity: root.osdMode === "" ? 1 : 0
    enabled: root.osdMode === ""
    Behavior on opacity { NumberAnimation { duration: 150 } }
}

// =====================================================
// BATTERY MODULE
// =====================================================
LocalComponents.BatteryModule {
    id: batteryLoader
    
    anchors.fill: parent
    anchors.margins: 14

    visible: root.batteryVisible
    theme: root.theme
}

// =====================================================
// VOLUME MODULE
// =====================================================
LocalComponents.VolumeModule {
    id: volumeLoader

    anchors.fill: parent
    anchors.margins: 14

    visible: root.volumeVisible
    theme: root.theme
    volumeButton: volumeButton          
}

// =====================================================
// WIDTH
// =====================================================

width:

    root.osdMode === "toast" ? (dynamicToastLoader.item ? dynamicToastLoader.item.implicitWidth : 300)

    : root.osdMode === "volume" ? 240

    : root.osdMode === "caps" ? 210

    : root.timerOsdVisible || root.timerControlOsdVisible? 300

    : root.hubVisible ? root.hubWidth

    : root.panelVisible ? 940

    : root.launcherVisible ? 530

    : root.mediaVisible ? 460

    : root.weatherVisible ? 560

    : root.calendarVisible ? 440

    : root.themeVisible ? 540

    : root.wallpaperVisible ? 968

    : root.updateAuthVisible ? 540

    : root.networkVisible ? 520

    : root.updatesVisible ? 480

    : root.volumeVisible ? 480

    : root.batteryVisible ? 580

    : root.clipboardVisible ? 700

    : root.torrentsVisible ? 560

    : root.gitVisible ? 560

    : (detector.activeHover || detector.timerHovered || detector.volumeHovered || detector.themeHovered || detector.calendarHovered || detector.networkHovered || detector.authHovered || root.spotifyTrack !== "")

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

    : root.osdMode === "toast" ? (dynamicToastLoader.item ? dynamicToastLoader.item.implicitHeight : 80)

    : root.hubVisible ? root.hubHeight

    : root.launcherVisible ? 530

    : root.mediaVisible ? 235

    : root.weatherVisible ? 540

    : root.calendarVisible ? 500

    : root.themeVisible ? 650

    : root.wallpaperVisible ? 680

    : root.updateAuthVisible ? 280

    : root.networkVisible ? networkLoader.implicitHeight + 28

    : root.updatesVisible ? 400

    : root.batteryVisible ? 400

    : root.clipboardVisible ? 520

    : root.torrentsVisible ? 480

    : root.gitVisible ? 600

    : root.volumeVisible ? volumeLoader.requiredHeight

    : 42

    radius: (root.launcherVisible || root.panelVisible || root.hubVisible) ? 16 : 21

    scale: (detector.activeHover && !root.hubVisible) ? 1.01 : 1.0

    color: root.theme.bg

    Connections { target: root; function onSpotifyTrackChanged() {}}

    // ============================================================
    // ANIMATIONS (Perfect Frame-Rate Synchronization)
    // ============================================================
Behavior on width  { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
Behavior on height { NumberAnimation { duration: 550; easing.type: Easing.OutCubic } }
Behavior on radius { NumberAnimation { duration: 650; easing.type: Easing.OutQuad } }
Behavior on scale  { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }


 // =======================================================
// Calendar
// =======================================================
// =======================================================
// Hub (tabbed panel)
// =======================================================
LocalComponents.Hub {
    id: hubModule

    anchors {
        top: topBarHeader.bottom
        left: parent.left
        right: parent.right
        bottom: parent.bottom
        margins: 14
    }

    visible: root.hubVisible
    theme: root.theme
    notifServer: notificationServer
    shell: root
    dndEnabled: root.dndEnabled
    currentTab: root.hubTab
    onTabSelected: function(tab) { root.hubTab = tab }
    onDndToggleRequested: function(enabled) { root.dndEnabled = enabled }
    wallpaperApplier: applyWallpaper
    mediaControl: spotifyControl
    cavaValues: cavaWrapper.levels
    cavaPlaying: cavaWrapper.playing

    // hide while a toast / OSD owns the island (state is kept, it fades back afterwards)
    opacity: root.osdMode === "" ? 1 : 0
    enabled: root.osdMode === ""
    Behavior on opacity { NumberAnimation { duration: 150 } }
    onCloseRequested: root.hubVisible = false
    onWallpaperResolutionChanged: function(folder) { root.currentResolutionFolder = folder; root.scanWallpapers() }
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
    width: root.mediaVisible ? 440 : 220

    anchors {
        top: topBarHeader.bottom
        horizontalCenter: parent.horizontalCenter   
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
    Binding { target: embeddedMediaContent.item; property: "cavaValues";  value: cavaWrapper.levels;  when: embeddedMediaContent.status === Loader.Ready }
    Binding { target: embeddedMediaContent.item; property: "cavaPlaying"; value: cavaWrapper.playing; when: embeddedMediaContent.status === Loader.Ready }
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
// CAVA 
// ========================================================

Item {
    id: cavaWrapper

    // Hidden entirely when not playing, so the Row skips its spacing
    readonly property bool shown:
        cavaLoader.item &&
        cavaLoader.item.active &&
        !root.islandExpanded &&
        !root.weatherVisible &&
        !root.themeVisible &&
        !root.calendarVisible &&
        !root.hubVisible &&
        !root.updateAuthVisible

    visible: shown
    width: shown ? cavaLoader.width + 8 : 0
    height: 42

    readonly property var levels: cavaLoader.item ? cavaLoader.item.levels : []
    readonly property bool playing: cavaLoader.item ? cavaLoader.item.playing : false

    Loader {
        id: cavaLoader

        active: true
        source: "components/Cava.qml"

        width: cavaWrapper.shown && item ? item.visualWidth : 0
        height: 42

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 8
        }

        Behavior on width { NumberAnimation { duration: 250 } }
    }
}

// ========================================================
// BATTERY BUTTON
// ========================================================
Buttons.BatteryButton {
    id: batteryButton
    visible: root.showHoverModules && !root.batteryVisible && !root.mediaVisible
    theme: root.theme
    detector: detector

    // Show the lowest battery of the devices that have reported a level
    batteryPercent: {
        const m = batteryLoader.mousePercent
        const k = batteryLoader.keyboardPercent
        if (m > 0 && k > 0) return Math.min(m, k)
        if (m > 0) return m
        if (k > 0) return k
        return 1.0
    }
    
    onHoverEntered: {
    detector.batteryHovered = true
    detector.activeHover = true
    hoverDebounceTimer.stop()
}
    onHoverExited: {
        detector.batteryHovered = false

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
        root.volumeVisible = false
        root.batteryVisible = !root.batteryVisible
    }
}

// ========================================================
// CLIPBOARD BUTTON
// ========================================================
Buttons.ClipboardButton {
    id: clipboardButton
    visible: root.showHoverModules && !root.clipboardVisible && !root.mediaVisible
    theme: root.theme
    detector: detector
    
    onHoverEntered: {
    detector.clipboardHovered = true
    detector.activeHover = true
    hoverDebounceTimer.stop()
}
    onHoverExited: {
        detector.clipboardHovered = false

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
        root.volumeVisible = false
        root.batteryVisible = false
        root.networkVisible = false
        root.torrentsVisible = false
        root.clipboardVisible = !root.clipboardVisible
    }
}

// ========================================================
// GIT BUTTON
// ========================================================
Buttons.GitButton {
    id: gitButton
    visible: root.showHoverModules && !root.gitVisible && !root.mediaVisible
    theme: root.theme
    detector: detector
    changes: root.gitChanges
    ahead: root.gitAhead

    onHoverEntered: {
        detector.gitHovered = true
        detector.activeHover = true
        hoverDebounceTimer.stop()
    }
    onHoverExited: {
        detector.gitHovered = false
        if (!detector.isPinned) hoverDebounceTimer.start()
    }
    onClicked: root.gitVisible = !root.gitVisible
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
// ========================================================
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
        root.networkVisible = false
        root.updatesVisible = false
        root.volumeVisible = false
        root.batteryVisible = false
        root.clipboardVisible = false
        root.torrentsVisible = false
        root.calendarVisible = false
        root.hubVisible = !root.hubVisible

        if (root.hubVisible) {
            root.hubTab = "today"
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

    function onHoveredChanged() { detector.timerHovered = timerLoader.item.hovered; timerLoader.item.hovered ? (detector.activeHover = true, hoverDebounceTimer.stop()) : (!detector.isPinned && hoverDebounceTimer.start()); }

}

Connections {
    target: timerLoader.item
    ignoreUnknownSignals: true

    function onClicked() { root.timerControlOsdVisible = true}
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
// NETWORK BUTTON
// ========================================================
Buttons.NetworkButton {
    id: networkButton
    visible: root.showHoverModules && !root.networkVisible && !root.mediaVisible
    theme: root.theme
    detector: detector
    
    onHoverEntered: {
    detector.networkHovered = true
    detector.activeHover = true
    hoverDebounceTimer.stop()
}
    onHoverExited: {
        detector.networkHovered = false

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
        root.volumeVisible = false
        root.networkVisible = !root.networkVisible
    }
}


// ========================================================
// UPDATES
// ========================================================

LocalComponents.Updates {
    id: updatesButton

    visible:
        root.showHoverModules &&
        !root.updatesVisible &&
        !root.mediaVisible

    height: 32
    anchors.verticalCenter: parent.verticalCenter
    updateCount: root.totalUpdateCount
    theme: root.theme
    themeRunner: themeRunner

    // ----------------------------------------------------
    // HOVER
    // ----------------------------------------------------

    onHoverEntered: {
        detector.updatesHovered = true
        detector.activeHover = true
        hoverDebounceTimer.stop()
    }

    onHoverExited: {
        detector.updatesHovered = false

        if (!detector.isPinned) {
            hoverDebounceTimer.start()
        }
    }

    // ----------------------------------------------------
    // CLICK
    // ----------------------------------------------------

    onClicked: {
    root.launcherVisible = false
    root.weatherVisible = false
    root.mediaVisible = false
    root.themeVisible = false
    root.wallpaperVisible = false
    root.calendarVisible = false
    root.networkVisible = false
    root.volumeVisible = false
    root.updateAuthVisible = false

    root.updatesVisible = !root.updatesVisible

    if (root.updatesVisible) {
        detector.activeHover = false
        hoverDebounceTimer.stop()

        Qt.callLater(function() {
            globalFocusScope.forceActiveFocus()
        })
    } else {
        detector.activeHover = false
        detector.updatesHovered = false
    }
}
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
             !root.calendarVisible &&
             !root.hubVisible &&
             !root.networkVisible &&
             !root.updatesVisible &&
             !root.volumeVisible &&
             !root.updateAuthVisible &&
             !root.batteryVisible &&
             !root.clipboardVisible &&
             !root.torrentsVisible &&
             !root.gitVisible

    width: visible && item ? item.implicitWidth : 0
    height: 42
    anchors.verticalCenter: parent.verticalCenter

    Behavior on width { NumberAnimation { duration: 250 }}

   Binding { target: spotifyLoader.item; property: "track";         value: root.spotifyTrack;   when: spotifyLoader.status === Loader.Ready }
   Binding { target: spotifyLoader.item; property: "icon";          value: root.spotifyIcon;    when: spotifyLoader.status === Loader.Ready }
   Binding { target: spotifyLoader.item; property: "artUrl";        value: root.spotifyArtUrl;  when: spotifyLoader.status === Loader.Ready }
   Binding { target: spotifyLoader.item; property: "theme";         value: root.theme;          when: spotifyLoader.status === Loader.Ready }
   Binding { target: spotifyLoader.item; property: "spotifyControl"; value: spotifyControl;     when: spotifyLoader.status === Loader.Ready }
   
    Connections { 
    target: spotifyLoader.item
    ignoreUnknownSignals: true
    
    function onClicked() { root.launcherVisible = false; root.panelVisible = false; root.themeVisible = false; root.weatherVisible = false; !root.mediaVisible ? (root.mediaVisible = true, root.islandState = root.islandStateExpanded) : root.islandState = root.islandStateClosing; }
    function onHoveredChanged() { detector.spotifyHovered = spotifyLoader.item.hovered; spotifyLoader.item.hovered ? hoverDebounceTimer.stop() : (!detector.isPinned && hoverDebounceTimer.start()); }

  }
}

// ========================================================
// VOLUME BUTTON
// ========================================================

LocalComponents.Volume {
    id: volumeButton
    visible: root.showHoverModules && !root.volumeVisible && !root.mediaVisible
    height: 30
    anchors.verticalCenter: parent.verticalCenter
    theme: root.theme

    onClicked: {
        root.launcherVisible = false
        root.weatherVisible = false
        root.mediaVisible = false
        root.themeVisible = false
        root.wallpaperVisible = false
        root.calendarVisible = false
        root.networkVisible = false

        root.volumeVisible = !root.volumeVisible

        if (root.volumeVisible) {
            detector.activeHover = false
            hoverDebounceTimer.stop()
            Qt.callLater(function() {
                globalFocusScope.forceActiveFocus()
            })
        } else {
            detector.activeHover = false
            detector.volumesHovered = false
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
        item && item.implicitWidth > 0 &&
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

    } 
  }
 }
}