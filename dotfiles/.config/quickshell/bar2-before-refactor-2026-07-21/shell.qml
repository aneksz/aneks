//@ pragma UseQApplication
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Io
import Quickshell.Services.Notifications
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import QtQuick.Shapes

import "./components" as LocalComponents

PanelWindow {
    id: root

    
    anchors {
        top: true
        left: true
        right: true
    }

    margins { top: 0 }
    color: "transparent"
    
        // Lock window frame height permanently to eliminate compositor re-buffering jitters
    implicitHeight: 800
    
    // FIX: Tells Hyprland to reserve exactly 50px of space relative to your anchors,
    // automatically forcing exclusionMode back to Normal behavior.
    exclusiveZone: 50


    // FIX: Uses a standard boolean flag to resolve the underlying type assignment requirements!
    // This completely removes the word-enum mapping loops and clears the error for good.
    WlrLayershell.keyboardFocus: root.launcherVisible

    // Anything outside our visual island capsule boundary becomes 100% invisible and click-through
    mask: Region { item: island }

       // =====================================================
    // AUTO-DISMISS CLICK AWAY MECHANISM (In top of shell.qml)
    // =====================================================
    MouseArea {
        id: clickAwayDismissMask
        anchors.fill: parent
        
        // FIX 2: Listens to media view state along with launcher settings!
        enabled: root.launcherVisible || root.panelVisible || root.mediaVisible
        
        onClicked: {
            root.launcherVisible = false;
            root.panelVisible = false;
            
            // NEW: Instantly contract the media tray card back to a small pill!
            root.mediaVisible = false;
        }
    }
    

    // =====================================================
    // Launcher IPC
    // =====================================================
    IpcHandler {
    target: "launcher"

    function toggle() {
        root.launcherVisible = !root.launcherVisible
    }

    function open() {
        root.launcherVisible = true
    }

    function close() {
        root.launcherVisible = false
    }
}

    // =====================================================
    // NATIVE SERVICES & TIME MIGRATION
    // =====================================================

    SystemClock {
        id: clock
        precision: SystemClock.Minutes 
    }

    property string currentTime: Qt.formatTime(clock.date, "HH:mm")

    // =====================================================
    // PERSISTENT STORAGE CACHE
    // =====================================================
    PersistentProperties {
        id: persist
        property string seenJson: "{}"
        property string timestampsJson: "{}"
    }

    // =====================================================
    // CORE SYSTEM MONITORING PROPERTIES
    // =====================================================
    property int themeUpdateTrigger: 0
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
    property real spotifyPosition: 0
    property real spotifyLength: 0
    property string spotifyStatus: "Paused"
    property bool panelVisible: false
    property bool dndEnabled: false
    property var currentNotif: null
    property bool weatherVisible: false
    property bool themeVisible: false
    property string currentTheme: ""
    property string currentThemeFolder: ""
    property var themeFolders: []
    property var themes: []
    property string osdMode: ""
    property bool osdVisible: root.osdMode !== ""
    property int systemContentWidth: 420
    property bool wallpaperVisible: false
    property var wallpapers: []
    property string currentResolutionFolder: "4K"
    property string updateCount: "0"

    // Dynamic Island State Controls
    property bool launcherVisible: false
    property string searchText: ""
    property int selectedIndex: 0
    property var apps: []
    property var filteredApps: []
    property var parsedApps: []
    property bool calcMode: false
    property int islandTopMargin: 4

    property bool islandExpanded:
    launcherVisible ||
    panelVisible ||
    mediaVisible

    // Legacy context routing maps
    property var bar: root
    property var globalClock: clock
    property var notifServer: realNotifServer
    property var weatherData: ({ temp: "--", icon: "", desc: "", humidity: "--", feels: "--", wind: "--", sunrise: "--", sunset: "--", forecast: [] })

    readonly property var weatherIcon: (code) => {
        if (code === 0) return "☀️"
        if ([1,2,3].includes(code)) return "🌤️"
        if ([45,48].includes(code)) return "☁️"
        if ([51,53,55].includes(code)) return "🌦️"
        if ([61,63,65,80,81,82].includes(code)) return "🌧️"
        if ([71,73,75].includes(code)) return "❄️"
        if ([95,96,99].includes(code)) return "⛈️"
        return "❔"
    }

    readonly property var weatherDesc: (code) => {
        if (code === 0) return "Clear"
        if ([1,2,3].includes(code)) return "Cloudy"
        if ([45,48].includes(code)) return "Fog"
        if ([51,53,55].includes(code)) return "Drizzle"
        if ([61,63,65].includes(code)) return "Rain"
        if ([71,73,75].includes(code)) return "Snow"
        if ([80,81,82].includes(code)) return "Showers"
        if ([95,96,99].includes(code)) return "Storm"
        return ""
    }

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

        // =====================================================
    // ACTIVE CORE UTILITY PROCESSES
    // =====================================================
    Process { id: vpnRunner }
    Process { id: spotifyControl }
    Process { id: spotifyProc; command: ["sh", "-c", "/home/igor/.config/waybar/scripts/spotify.sh"]; running: true; stdout: StdioCollector { onTextChanged: { try { let j = JSON.parse(text.trim()); root.spotifyTrack = j.text || ""; root.spotifyArtUrl = j.art || ""; root.spotifyPosition = Number(j.position) || 0; root.spotifyLength = Number(j.length) || 0; root.spotifyStatus = j.status || "Paused";} catch(e) {} } } }
    Process { id : volumeProc }
    Process { id: wallpaperProc; stdout: StdioCollector { onTextChanged: { root.wallpapers = text.trim().split("\n").filter(path => path.length > 0);  } } }
    Process { id: themeFolderProc; command: ["sh", "-c", `find ~/Pictures/Wallpapers/${root.currentResolutionFolder} -mindepth 1 -maxdepth 1 -type d -printf '%f\n'`]; running: true; stdout: StdioCollector { onTextChanged: { root.themeFolders = [""].concat(text.trim().split("\n").filter(x => x.length > 0)) } } }
    Process { id: applyWallpaper}
    Process { id: updateCheck; command: ["sh", "-c", "~/.config/scripts/updates.sh"]; stdout: StdioCollector { onStreamFinished: { updateCount = text.trim() || "0" }}}
    // FIX 1: Added root.cpuTemp assignment path hook explicitly
    Process { id: cpuCheck; command: ["sh", "-c", "sensors -u k10temp-pci-00c3 | awk '/temp1_input:/ {print int($2)}'"]; stdout: StdioCollector { onTextChanged: root.cpuTemp = (text.trim() || "00") + "°C" } }
    
    // FIX 2: Added root.cpuUsage assignment path hook explicitly
    Process { id: cpuUsageCheck; command: ["sh", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total1=$((user + nice + system + idle + iowait + irq + softirq + steal)); idle1=$((idle + iowait)); sleep 0.1; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total2=$((user + nice + system + idle + iowait + irq + softirq + steal)); idle2=$((idle + iowait)); total=$((total2 - total1)); idle=$((idle2 - idle1)); usage=$((100 * (total - idle) / total)); echo \"${usage}%\""]; stdout: StdioCollector { onStreamFinished: { root.cpuUsage = text.trim() || "--" } } }
    
    // FIX 3: Added root.gpuTemp assignment path hook explicitly
    Process { id: gpuCheck; command: ["sh", "-c", "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1"]; stdout: StdioCollector { onTextChanged: root.gpuTemp = (text.trim() || "00") + "°C" } }
    
    // These lines are already correct because they are using root. paths safely:
    Process { id: uptimeCheck; command: ["sh", "-c", "uptime -p | sed 's/up //; s/ hours,/h/; s/ minutes/m/'"]; stdout: StdioCollector { onTextChanged: root.systemUptime = text.trim() } }
    Process { id: diskCheck; command: ["sh", "-c", "df -h | awk '$6==\"/mnt/data\" {print \"DATA:\" $3 \" / \" $2} $6==\"/home\" {print \"HOME:\" $3 \" / \" $2}'" ]; stdout: StdioCollector { onTextChanged: { let lines = text.trim().split("\n"); root.dataUsage = "0 / 1"; root.homeUsage = "0 / 1"; for (let line of lines) { if (line.startsWith("DATA:")) root.dataUsage = line.replace("DATA:", ""); if (line.startsWith("HOME:")) root.homeUsage = line.replace("HOME:", ""); } } } }
    Process { id: ramCheck; command: ["sh", "-c", "free -h --si | awk '/^Mem:/ {print $3 \" \" $2}' | sed 's/Gi/GB/g'"]; stdout: StdioCollector { onTextChanged: { let parts = text.trim().split(/\s+/); if (parts.length >= 2) { root.ramUsage = parts[0]; root.ramTotal = parts[1]; } } } }
    Process { id: checkCurrent; command: ["cat", "/home/igor/.config/.current_theme"]; stdout: StdioCollector { onTextChanged: root.currentTheme = text.trim() }}
    Process {
    id: getThemes
    command: ["sh", "-c", "ls /home/igor/.config/themes/*.sh | xargs -n1 basename | sed 's/.sh$//'"]
    stdout: StdioCollector {
        onTextChanged: {
            root.themes = text.trim().split("\n").filter(name => name.length > 0)
            if (root.themes.length > 0)
                root.themeVisible = true
        }
    }
}
    Process {
    id: weatherProc
    command: [
        "sh", "-c",
        "curl -s --max-time 5 'https://api.open-meteo.com/v1/forecast?latitude=-37.814&longitude=144.9633&current=temperature_2m,weather_code,relative_humidity_2m,apparent_temperature,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,weather_code,sunrise,sunset&timezone=auto'"
    ]


    stdout: StdioCollector {
        waitForEnd: true
        onTextChanged: {
            if (typeof root === 'undefined' || !text.trim()) return;

            try {
                let data = JSON.parse(text.trim());
                let current = data.current;
                let daily = data.daily;
                let code = current.weather_code;

                let forecast = [];
                for (let i = 0; i < daily.time.length; i++) {
                    let dateObj = new Date(daily.time[i] + "T00:00:00");
                    forecast.push({
                        day: i === 0 ? "Today" : Qt.formatDateTime(dateObj, "ddd"),
                        date: Qt.formatDateTime(dateObj, "MMM d"),
                        temp: Math.round(daily.temperature_2m_max[i]),
                        icon: root.weatherIcon(daily.weather_code[i])
                    });
                }

                
                root.weatherData = {
                    temp: Math.round(current.temperature_2m),
                    icon: root.weatherIcon(code),
                    desc: root.weatherDesc(code),
                    humidity: current.relative_humidity_2m + "%",
                    feels: Math.round(current.apparent_temperature) + "°C",
                    wind: Math.round(current.wind_speed_10m) + " km/h",
                    sunrise: Qt.formatTime(new Date(daily.sunrise[0] + ":00"), "h:mm AP"),
                    sunset: Qt.formatTime(new Date(daily.sunset[0] + ":00"), "h:mm AP"),
                    forecast: forecast
                };

            } catch (e) {
                console.log("Weather parse failed:", e);
            }
        }
    }
}

   Component.onCompleted: {
        weatherProc.running = true
        scanner.running = true
        updateCheck.running = true
        scanWallpapers()

    } 

function scanWallpapers() { wallpaperProc.command = ["sh", "-c", `find "$HOME/Pictures/Wallpapers/${root.currentResolutionFolder}" -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \\)`]; wallpaperProc.running = true }
    // =====================================================
    // CORE SYSTEM STATISTICS REFRESH TIMER
    // =====================================================
    Timer { 
        id: statsPoller
        
        // OPTIMIZED: Sweeps frequently (2s) when interacting, drops down to a calm cycle (8s) when idle
        interval: (detector.activeHover || root.panelVisible) ? 2000 : 8000 
        
        running: true 
        repeat: true 
        triggeredOnStart: true 
        
        onTriggered: {
            // These core components always refresh on every timer loop cycle
            cpuUsageCheck.running = true 
            ramCheck.running = true 
            
            // These heavier disk and temperature sensors only scan when the bar is active or opened
            if (detector.activeHover || root.panelVisible) { 
                cpuCheck.running = true 
                gpuCheck.running = true 
                uptimeCheck.running = true 
                diskCheck.running = true 
            } 
        } 
    }
    
    Timer { interval: 500; running: true; repeat: true; onTriggered: { if (!spotifyProc.running) spotifyProc.running = true } }
    Timer { interval: 600000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { if (!updateCheck.running) updateCheck.running = true } }
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
Timer { interval: 600000; running: true; repeat: true; onTriggered: { if (!weatherProc.running) weatherProc.running = true } }

    // =====================================================
    // APPLICATION BACKGROUND DESKTOP SCANNER
    // =====================================================
    Process {
        id: scanner
        command: [
            "sh", 
            "-c", 
            "for file in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop /var/lib/flatpak/exports/share/applications/*.desktop ~/.local/share/flatpak/exports/share/applications/*.desktop; do [ -f \"$file\" ] || continue; grep -q '^NoDisplay=true' \"$file\" && continue; grep -q '^Hidden=true' \"$file\" && continue; grep -q '^Type=Service' \"$file\" && continue; name=$(grep -m1 '^Name=' \"$file\" | cut -d= -f2-); exec=$(grep -m1 '^Exec=' \"$file\" | cut -d= -f2-); icon=$(grep -m1 '^Icon=' \"$file\" | cut -d= -f2-); [ -z \"$icon\" ] && icon=\"application-x-executable\"; if echo \"$file\" | grep -q '/flatpak/exports/'; then app_id=$(basename \"$file\" .desktop); exec=\"flatpak run $app_id\"; else exec=$(echo \"$exec\" | sed -E 's/[[:space:]]+%[fFuUdDnNickvm]//g'); fi; if [ -n \"$name\" ] && [ -n \"$exec\" ]; then echo \"$name|$exec|$icon\"; fi; done | sort -f"
        ]
        
        // Gathers all bash script output text into a single stream automatically
        stdout: StdioCollector {
            // Fires exactly once when the background scanning process finishes executing
            onStreamFinished: {
                if (!text || text.trim() === "") return;
                
                let lines = text.trim().split("\n");
                let arr = [];
                let seenApps = new Set();
                
                for (let line of lines) {
                    let parts = line.split("|");
                    if (parts.length === 3) {
                        let appName = parts[0].trim();
                        
                        // Filters out duplicate entries found across system and user folders
                        if (!seenApps.has(appName)) {
                            seenApps.add(appName);
                            
                            arr.push({ 
                                name: appName, 
                                exec: parts[1].trim(), 
                                icon: parts[2].trim() 
                            });
                        }
                    }
                }
                
                root.apps = arr;
                root.filteredApps = arr;
                root.updateFilter();
            }
        }
    }

    
// =====================================================
// OSD HIDE TIMER
// =====================================================

Timer {
    id:
        osdHideTimer


    interval:
        1500


    repeat:
        false


    onTriggered: {

        if (
            root.osdMode ===
            "volume"
        ) {

            root.osdMode =
                ""
        }
    }
}

Timer {
    id: capsHideTimer

    interval:
        1200

    repeat:
        false

    onTriggered: {

        if (
            root.osdMode ===
            "caps"
        ) {

            root.osdMode =
                ""
        }
    }
}

Timer {
    id:
        toastHideTimer

    interval:
        5000

    repeat:
        false

    onTriggered: {

        if (
            root.osdMode ===
            "toast"
        ) {

            root.osdMode =
                ""
        }
    }
}

   // =====================================================
// LAUNCHER LOGIC FUNCTIONS
// =====================================================

function evaluate(expr) {
    try {
        if (!/^[0-9+\-*/().\s]+$/.test(expr))
            return "invalid"

        return Function(
            "return (" + expr + ")"
        )().toString()

    } catch (e) {
        return "error"
    }
}


function updateFilter() {


    var q = searchText.trim()


    // =================================================
    // CALCULATOR MODE
    // =================================================

    if (q.indexOf("=") === 0) {

        calcMode = true

        var expr = q.slice(1).trim()
        var result = evaluate(expr)


        filteredApps = [{
            name: expr + " = " + result,
            exec: "",
            icon: "accessories-calculator"
        }]


        selectedIndex = 0

        return
    }


    // =================================================
    // APPLICATION FILTERING
    // =================================================

    calcMode = false


    var lower = q.toLowerCase()
    var results = []


    for (var i = 0; i < apps.length; i++) {

        var app = apps[i]
        var name = app.name.toLowerCase()
        var score = 0


        if (lower === "") {
            score = 1
        }

        else if (name.indexOf(lower) === 0) {
            score = 100
        }

        else if (name.indexOf(lower) !== -1) {
            score = 50
        }


        if (score > 0) {

            results.push({
                app: app,
                score: score
            })
        }
    }


    // =================================================
    // SORT RESULTS
    // =================================================

    results.sort(function (a, b) {
        return b.score - a.score
    })


    // =================================================
    // BUILD FILTERED LIST
    // =================================================

    var out = []


    for (var j = 0; j < results.length; j++) {
        out.push(results[j].app)
    }


    filteredApps = out

    selectedIndex = 0


}


function launch(app) {

    if (!app)
        return


    if (calcMode) {

        root.launcherVisible = false

        return
    }


    Quickshell.execDetached([
        "sh",
        "-c",
        app.exec
    ])


    root.launcherVisible = false
}



// =====================================================
// NOTIFICATION TOAST POPUPS
// =====================================================

BoundComponent {
    id:
        toastLoader

    source:
        Qt.resolvedUrl(
            "components/Toast.qml"
        )


    property var theme:
        theme


    property var currentNotif:
        root.currentNotif


    property bool doNotDisturb:
        root.dndEnabled


    onItemChanged: {

        if (
            !item
        ) {
            return
        }


        // ---------------------------------------------
        // DISMISS
        // ---------------------------------------------

        item.dismiss.connect(
            function() {

                root.currentNotif =
                    null
            }
        )


        // ---------------------------------------------
        // NEW TOAST
        // ---------------------------------------------

        item.toastTriggered.connect(
            function() {

                root.osdMode =
                    "toast"

                toastHideTimer.restart()
            }
        )
    }
}

    // =====================================================
// NOTIFICATION DAEMON SYSTEM
// =====================================================
NotificationServer {
    id: realNotifServer
    keepOnReload: true

    onNotification: (n) => {
        if (!n)
            return

        const app =
            (n.appName ||
             n.desktopEntry ||
             "").toLowerCase()

        const isSpotify =
            app.includes("spotify")

        n.tracked =
            true

        n.isSpotifyTransient =
            isSpotify

        let key =
            String(
                n.id ||
                (n.summary + n.body)
            )

        let timestamps = {}
        let seen = {}

        try {
            timestamps =
                JSON.parse(
                    persist.timestampsJson
                )

            seen =
                JSON.parse(
                    persist.seenJson
                )
        }
        catch (e) {
        }

        if (
            !timestamps[key]
        ) {
            timestamps[key] =
                Date.now()

            persist.timestampsJson =
                JSON.stringify(
                    timestamps
                )
        }

        n.timestamp =
            timestamps[key]

        if (
            n.lastGeneration ||
            seen[key]
        ) {
            return
        }

        seen[key] =
            true

        persist.seenJson =
            JSON.stringify(
                seen
            )

        root.currentNotif =
            n
    }
}

    // =====================================================
    // THEME CONFIGURATION ENGINE
    // =====================================================
    Loader { 
        id: themeLoader
        source: "file:///home/igor/.config/quickshell/bar2/Colors.qml" 
    }

    Connections { 
        target: themeLoader
        function onStatusChanged() { 
            if (themeLoader.status === Loader.Ready) root.themeUpdateTrigger++ 
        } 
    }

    QtObject {
        id: c
        readonly property bool ready: themeLoader.status === Loader.Ready

        property color bg:            ready ? (themeLoader.item?.bg ?? "#11111b") : "#11111b"
        property color fg:            ready ? (themeLoader.item?.textPrimary ?? themeLoader.item?.fg0 ?? "#cdd6f4") : "#cdd6f4"
        property color accent:        ready ? (themeLoader.item?.accent ?? "#89b4fa") : "#89b4fa"
        property color inactive:      ready ? (themeLoader.item?.inactive ?? "#6c7086") : "#6c7086"
        property color activeWs:      ready ? (themeLoader.item?.activeWs ?? "#89b4fa") : "#89b4fa"
        property color green:         ready ? (themeLoader.item?.green ?? "#a6e3a1") : "#a6e3a1"
        property color red:           ready ? (themeLoader.item?.red ?? "#f38ba8") : "#f38ba8"
        property color surface:       ready ? (themeLoader.item?.surface ?? "#313244") : "#313244"
        property color fg1:           ready ? (themeLoader.item?.fg1 ?? "#cdd6f4") : "#cdd6f4"
        property color fg3:           ready ? (themeLoader.item?.fg3 ?? "#c0c5ce") : "#c0c5ce"
        property color warning:       ready ? (themeLoader.item?.warning ?? "#ebcb8b") : "#ebcb8b"
        property color success:       ready ? (themeLoader.item?.success ?? "#a6e3a1") : "#a6e3a1"
        property color error:         ready ? (themeLoader.item?.error ?? "#f38ba8") : "#f38ba8"
        property color bgAlt:         ready ? (themeLoader.item?.bg1 ?? c.bg) : c.bg
        property color surfaceAlt:    ready ? (themeLoader.item?.surfaceAlt ?? c.surface) : c.surface
        property color border:        ready ? (themeLoader.item?.border ?? c.accent) : c.accent
        property color hover:         ready ? (themeLoader.item?.accentHover ?? c.accent) : c.accent
        property color textSecondary: ready ? (themeLoader.item?.textSecondary ?? c.fg1) : c.fg1
    }

    QtObject {
        id: theme

        property string font: "JetBrains Mono Nerd Font Propo"
        property real fontSize: 11.5
        property int fontWeight: Font.DemiBold

        property color bg:            c.bg
        property color fg:            c.fg
        property color fg1:           c.fg1
        property color accent:        c.accent
        property color hover:         c.hover
        property color border:        c.border
        property color green:         c.green
        property color red:           c.red
        property color warning:       c.warning
        property color success:       c.success
        property color error:         c.error
        property color surface:       c.surface
        property color surfaceAlt:    c.surfaceAlt
        property color bgAlt:         c.bgAlt
        property color inactive:      c.inactive
        property color activeWs:      c.activeWs
        property color textMuted:     c.fg3
        property color textSecondary: c.textSecondary
    }


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

    width: 520

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

    // -------------------------------------------------
    // EXIT DEBOUNCE
    // -------------------------------------------------
    Timer {
    id: hoverDebounceTimer

    interval: 200
    repeat: false

    onTriggered: {

    if (
    !masterHover.containsMouse &&
    !detector.childHovered &&
    !detector.wallpaperHovered &&
    !detector.volumeHovered &&
    !detector.updatesHovered &&
    !detector.isPinned &&
    !root.launcherVisible &&
    !root.panelVisible &&
    !root.mediaVisible
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
    detector.isPinned


        Keys.onEscapePressed: {

    root.launcherVisible = false
    root.panelVisible = false
    root.mediaVisible = false
    root.weatherVisible = false
    root.themeVisible = false
    root.wallpaperVisible = false

    detector.isPinned = false
    detector.activeHover = false
}
    }


 // -------------------------------------------------
// MASTER HOVER ZONE
// -------------------------------------------------

MouseArea {
    id: masterHover

    anchors.fill: parent

    hoverEnabled: true

    propagateComposedEvents: true

    onContainsMouseChanged: {

        if (
            root.launcherVisible ||
            root.panelVisible ||
            root.mediaVisible ||
            root.weatherVisible ||
            root.themeVisible ||
            root.wallpaperVisible
        ) {
            return
        }

        if (containsMouse) {

            detector.activeHover = true

            hoverDebounceTimer.stop()

        } else {

            hoverDebounceTimer.start()
        }
    }

    onClicked: {

        if (
            root.launcherVisible ||
            root.panelVisible ||
            root.mediaVisible ||
            root.weatherVisible ||
            root.themeVisible ||
            root.wallpaperVisible
        ) {
            return
        }

        detector.isPinned =
            !detector.isPinned

        if (detector.isPinned) {

            detector.activeHover = true

            hoverDebounceTimer.stop()

        } else {

            hoverDebounceTimer.start()
        }
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

    clip:
        true


    anchors {

        horizontalCenter:
            parent.horizontalCenter

        top:
            parent.top

        topMargin:
            root.islandTopMargin
    }

// =====================================================
// DYNAMIC ISLAND TOAST OSD
// =====================================================

Loader {
    id: dynamicToastLoader

    active:
        true

    visible:
        root.osdMode === "toast"

    anchors.fill:
        parent

    source:
        "components/Toast.qml"

    Binding {
        target:
            dynamicToastLoader.item

        property:
            "theme"

        value:
            theme

        when:
            dynamicToastLoader.status ===
            Loader.Ready
    }

    Binding {
        target:
            dynamicToastLoader.item

        property:
            "currentNotif"

        value:
            root.currentNotif

        when:
            dynamicToastLoader.status ===
            Loader.Ready
    }

    Binding {
        target:
            dynamicToastLoader.item

        property:
            "doNotDisturb"

        value:
            root.dndEnabled

        when:
            dynamicToastLoader.status ===
            Loader.Ready
    }

    Binding {
        target:
            dynamicToastLoader.item

        property:
            "osdMode"

        value:
            root.osdMode

        when:
            dynamicToastLoader.status ===
            Loader.Ready
    }

    Connections {
        target:
            dynamicToastLoader.item

        ignoreUnknownSignals:
            true

        function onDismiss() {

            root.currentNotif =
                null

            root.osdMode =
                ""
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

    active:
        true

    visible:
        root.osdMode === "caps"

    anchors.fill:
        parent

    source:
        "components/CapsLockOSD.qml"

    onLoaded: {

        item.theme =
            theme

        item.osdTriggered.connect(
            function() {

                root.osdMode =
                    "caps"

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

    active:
        true

    visible:
        root.osdMode === "volume"


    anchors.fill:
        parent


    source:
        "components/VolumeOSD.qml"


    onLoaded: {

 

        item.theme =
            theme


        item.osdTriggered.connect(
            function() {


                root.osdMode =
                    "volume"


                osdHideTimer.restart()
            }
        )
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
        root.wallpaperVisible = false
    }

    function onResolutionChanged(folder) {
        root.currentResolutionFolder = folder
        root.scanWallpapers()
    }
}

    Binding {
        target: wallpaperSelectorLoader.item
        property: "theme"
        value: theme
        when: wallpaperSelectorLoader.status === Loader.Ready
    }

    Binding {
        target: wallpaperSelectorLoader.item
        property: "themeFolders"
        value: root.themeFolders
        when: wallpaperSelectorLoader.status === Loader.Ready
    }

    Binding {
        target: wallpaperSelectorLoader.item
        property: "wallpapers"
        value: root.wallpapers
        when: wallpaperSelectorLoader.status === Loader.Ready
    }

    Binding {
        target: wallpaperSelectorLoader.item
        property: "applyWallpaper"
        value: applyWallpaper
        when: wallpaperSelectorLoader.status === Loader.Ready
    }

    Binding {
        target: wallpaperSelectorLoader.item
        property: "wallpaperProc"
        value: wallpaperProc
        when: wallpaperSelectorLoader.status === Loader.Ready
    }

    // =================================================
    // THEME
    // =================================================

    Binding {
        target:
            wallpaperSelectorLoader.item

        property:
            "theme"

        value:
            theme

        when:
            wallpaperSelectorLoader.status ===
            Loader.Ready
    }


    // =================================================
    // WALLPAPERS
    // =================================================

    Binding {
        target:
            wallpaperSelectorLoader.item

        property:
            "wallpapers"

        value:
            root.wallpapers

        when:
            wallpaperSelectorLoader.status ===
            Loader.Ready
    }


    // =================================================
    // THEME FOLDERS
    // =================================================

    Binding {
        target:
            wallpaperSelectorLoader.item

        property:
            "themeFolders"

        value:
            root.themeFolders

        when:
            wallpaperSelectorLoader.status ===
            Loader.Ready
    }


    // =================================================
    // APPLY WALLPAPER
    // =================================================

    Binding {
        target:
            wallpaperSelectorLoader.item

        property:
            "applyWallpaper"

        value:
            applyWallpaper

        when:
            wallpaperSelectorLoader.status ===
            Loader.Ready
    }


    // =================================================
    // WALLPAPER PROCESS
    // =================================================

    Binding {
        target:
            wallpaperSelectorLoader.item

        property:
            "wallpaperProc"

        value:
            wallpaperProc

        when:
            wallpaperSelectorLoader.status ===
            Loader.Ready
    }


    onStatusChanged: {

        if (
            status ===
            Loader.Ready
        ) {

        }
    }
}

// =====================================================
// THEME SELECTOR
// =====================================================

Loader {
    id: themeSelectorLoader

    active:
        root.themeVisible

    visible:
        root.themeVisible

    anchors {
        fill:
            parent

        margins:
            14
    }

    source:
        "components/Themes.qml"


    Binding {
        target:
            themeSelectorLoader.item

        property:
            "theme"

        value:
            theme

        when:
            themeSelectorLoader.status ===
            Loader.Ready
    }


    Binding {
        target:
            themeSelectorLoader.item

        property:
            "currentTheme"

        value:
            root.currentTheme

        when:
            themeSelectorLoader.status ===
            Loader.Ready
    }


    Binding {
        target:
            themeSelectorLoader.item

        property:
            "checkCurrent"

        value:
            checkCurrent

        when:
            themeSelectorLoader.status ===
            Loader.Ready
    }


    Binding {
        target:
            themeSelectorLoader.item

        property:
            "getThemes"

        value:
            getThemes

        when:
            themeSelectorLoader.status ===
            Loader.Ready
    }


    Binding {
        target:
            themeSelectorLoader.item

        property:
            "themeLoader"

        value:
            themeLoader

        when:
            themeSelectorLoader.status ===
            Loader.Ready
    }


    Binding {
        target:
            themeSelectorLoader.item

        property:
            "themes"

        value:
            root.themes

        when:
            themeSelectorLoader.status ===
            Loader.Ready
    }


    onStatusChanged: {

       

        if (
            status ===
            Loader.Ready
        ) {

        }
    }
}

// =================================================
// WIDTH
// =================================================

width: {

    if (root.osdMode === "toast")
        return 300

    if (root.osdMode === "volume")
        return 280

    if (root.osdMode === "caps")
        return 210

    if (root.panelVisible)
        return 560

    if (root.launcherVisible)
        return 530

    if (root.mediaVisible)
        return 480

    if (root.weatherVisible)
        return 680

    if (root.themeVisible)
        return 540

    if (root.wallpaperVisible)
        return 968

    if (
    detector.activeHover ||
    detector.wallpaperHovered ||
    detector.volumeHovered ||
    root.spotifyTrack !== ""
) {
    return topBarHeader.width + 32
}

    return topBarHeader.width + 20
}
    

// =================================================
// HEIGHT
// =================================================

height:
    root.osdMode === "volume"
    ? 40

    : root.osdMode === "caps"
    ? 60

    : root.osdMode === "toast"
    ? 80

    : root.panelVisible
    ? topBarHeader.height
        + 14
        + systemDashboardTileModule.height
        + 14

    : root.launcherVisible
    ? 530

    : root.mediaVisible
    ? 600

    : root.weatherVisible
    ? 650

    : root.themeVisible
    ? 500

    : root.wallpaperVisible
    ? 680

    : 42


    radius:
        (root.launcherVisible || root.panelVisible)
        ? 16
        : 21



    scale:
        detector.activeHover
        ? 1.01
        : 1.0



    color: theme.bg

    Connections {
        target: root


        function onSpotifyTrackChanged() {
        }
    }



    // ============================================================
    // ANIMATIONS
    // ============================================================
    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
    Behavior on radius { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }


 // =======================================================
// Weather
// =======================================================
LocalComponents.WeatherCalendar {

    id: weatherModule

    anchors {
        top: topBarHeader.bottom
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    visible: root.weatherVisible

    theme: theme

    weatherData: root.weatherData

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
    visible: root.mediaVisible

    source: "components/MediaPlayer.qml"

    anchors {
        top: topBarHeader.bottom
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    opacity: root.mediaVisible ? 1.0 : 0.0

    Behavior on opacity {
        NumberAnimation {
            duration: root.mediaVisible ? 180 : 100
        }
    }


    Binding {
    target: embeddedMediaContent.item
    property: "track"

    value:
        root.spotifyTrack

    when:
        embeddedMediaContent.status === Loader.Ready
}


Binding {
    target: embeddedMediaContent.item
    property: "artUrl"

    value:
        root.spotifyArtUrl

    when:
        embeddedMediaContent.status === Loader.Ready
}


Binding {
    target: embeddedMediaContent.item
    property: "position"

    value:
        root.spotifyPosition

    when:
        embeddedMediaContent.status === Loader.Ready
}


Binding {
    target: embeddedMediaContent.item
    property: "length"

    value:
        root.spotifyLength

    when:
        embeddedMediaContent.status === Loader.Ready
}


Binding {
    target: embeddedMediaContent.item
    property: "status"

    value:
        root.spotifyStatus

    when:
        embeddedMediaContent.status === Loader.Ready
}


Binding {
    target: embeddedMediaContent.item
    property: "theme"

    value:
        theme

    when:
        embeddedMediaContent.status === Loader.Ready
}


Binding {
    target: embeddedMediaContent.item
    property: "spotifyControl"

    value:
        spotifyControl

    when:
        embeddedMediaContent.status === Loader.Ready
   }
}

    // ============================================================
    // MAIN ISLAND ROW
    // WORKSPACES -> CAVA -> LAUNCHER -> CLOCK -> SYSTEM -> SPOTIFY
    // ============================================================
    Row {
        id: mainRow

        anchors.centerIn: parent

        height: 42

        spacing: 4

        visible:
    root.osdMode === "" &&
    !root.wallpaperVisible

// ========================================================
// WORKSPACES (HOVER ONLY)
// ========================================================

Loader {
    id: workspaceLoader

    active:
        true


    property var workspaceTheme:
        theme


    source:
        "components/Workspaces.qml"


    visible:
        detector.activeHover &&
        !root.islandExpanded &&
        !root.weatherVisible &&
        !root.themeVisible


    width:
        visible
        ? 184
        : 0


    height:
        30


    anchors.verticalCenter:
        parent.verticalCenter


    onLoaded: {

        if (item) {

            item.theme =
                workspaceTheme
        }
    }
}

// ========================================================
// CAVA (MUSIC ONLY)
// ========================================================

Item {
    id: cavaWrapper

    width:
        cavaLoader.visible
        ? cavaLoader.width + 8
        : 0

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
            !root.themeVisible

        width:
            visible && item
            ? item.visualWidth
            : 0

        height: 42

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 8
        }

        Behavior on width {
            NumberAnimation {
                duration: 250
            }
        }
    }
}

 // ========================================================
// LAUNCHER BUTTON
// ========================================================

Rectangle {
    id: menuButton

    width: 24
    height: 30

    radius:
        height / 2

    anchors.verticalCenter:
        parent.verticalCenter

    visible:
        root.osdMode === "" &&
        !root.mediaVisible

    color:
        menuMouse.containsMouse
        ? theme.surfaceAlt
        : theme.bg

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Text {
        anchors.centerIn:
            parent

        text:
            "󰣇"

        color:
            menuMouse.containsMouse
            ? theme.error
            : theme.fg

        font {
            family:
                theme.font

            pixelSize:
                16
        }

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    MouseArea {
        id:
            menuMouse

        anchors.fill:
            parent

        hoverEnabled:
            true

        cursorShape:
            Qt.PointingHandCursor

        onEntered:
            detector.childHovered = true

        onExited:
            detector.childHovered = false

        onClicked: {
            root.panelVisible = false
            root.mediaVisible = false
            root.themeVisible = false
            root.wallpaperVisible = false
            root.weatherVisible = false

            root.launcherVisible =
                !root.launcherVisible

            if (root.launcherVisible) {
                root.searchText = ""

                root.updateFilter()

                Qt.callLater(() =>
                    inputField.forceActiveFocus()
                )
            }
        }
    }
}

// ========================================================
// WALLPAPER BUTTON
// ========================================================

Rectangle {
    id: wallpaperButton

    width: 24
    height: 30

    radius: height / 2

    anchors.verticalCenter:
        parent.verticalCenter

    color:
        wallpaperMouse.containsMouse
        ? theme.surfaceAlt
        : "transparent"

    Text {
        anchors.centerIn:
            parent

        text:
            "󰋩"

        color:
            root.wallpaperVisible
            ? theme.accent
            : theme.warning

        font {
            family:
                theme.font

            pixelSize:
                16
        }
    }

    MouseArea {
    id: wallpaperMouse

    anchors.fill: parent

    hoverEnabled: true

    cursorShape: Qt.PointingHandCursor

    onContainsMouseChanged: {
        detector.wallpaperHovered = containsMouse

        if (containsMouse) {
            detector.activeHover = true
            hoverDebounceTimer.stop()
        } else if (!detector.isPinned) {
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
}

// ========================================================
// THEME BUTTON
// ========================================================

Rectangle {
    id: themeButton

    width: 30
    height: 30

    radius:
        height / 2

    anchors.verticalCenter:
        parent.verticalCenter

        visible:
        root.osdMode === "" &&
        !root.mediaVisible

    color:
        themeMouse.containsMouse
        ? theme.surfaceAlt
        : theme.bg

    

    Text {
        anchors.centerIn:
            parent

    

        text:
            "󰏘"

        color:
            root.themeVisible
            ? theme.accent
            : themeMouse.containsMouse
            ? theme.accent
            : theme.fg

        font {
            family:
                theme.font

            pixelSize:
                16
        }

        Behavior on color {
            ColorAnimation {
                duration:
                    120
            }
        }
    }


    MouseArea {
        id:
            themeMouse

        anchors.fill:
            parent

        hoverEnabled:
            true

        cursorShape:
            Qt.PointingHandCursor


        onEntered: {

            detector.childHovered =
                true
        }


        onExited: {

            detector.childHovered =
                false
        }


        onClicked: {

            root.panelVisible = false
            root.launcherVisible = false
            root.wallpaperVisible = false
            root.weatherVisible = false
            if (
                root.themeVisible
            ) {

                root.themeVisible =
                    false

                return
            }
    // ---------------------------------------------
    // LOAD THEME DATA FIRST
    // ---------------------------------------------

    getThemes.running =
        true

    checkCurrent.running =
        true
}
    }
}


        // ========================================================
        // CLOCK
        // ========================================================
   LocalComponents.Clock {
    id: clockModule

    theme: theme

    visible:
        root.osdMode === "" &&
        !root.mediaVisible

    anchors.verticalCenter: parent.verticalCenter

    onClicked: {
        

        root.weatherVisible = !root.weatherVisible

        root.mediaVisible = false
        root.panelVisible = false
        root.launcherVisible = false
        root.wallpaperVisible = false
        root.themeVisible = false
    }
}
 // ========================================================
// SYSTEM BUTTON
// ========================================================
Rectangle {
    id: systemButton

    width: 30
    height: 30
    radius: height / 2

    anchors.verticalCenter:
        parent.verticalCenter

        visible:
        root.osdMode === "" &&
        !root.mediaVisible

    color:
        sysMouse.containsMouse
        ? theme.surfaceAlt
        : theme.bg


    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }
   
    Text {
        anchors.centerIn:
            parent

   
        text:
            ""

        color:
            sysMouse.containsMouse
            ? theme.accent
            : theme.fg

        font {
            family:
                theme.font

            pixelSize:
                16
        }


        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }


    MouseArea {
        id:
            sysMouse

        anchors.fill:
            parent

        hoverEnabled:
            true

        cursorShape:
            Qt.PointingHandCursor


        onEntered:
            detector.childHovered = true


        onExited:
            detector.childHovered = false


        onClicked: {

            root.launcherVisible =
                false

            root.weatherVisible = false    

            root.mediaVisible =
                false

            root.themeVisible =
                false
            root.wallpaperVisible = false    

            root.panelVisible =
                !root.panelVisible
        }
    }
}

// ========================================================
// VOLUME BUTTON
// ========================================================

LocalComponents.Volume {
    id: volumeButton

    width: 58
    height: 30

    anchors.verticalCenter:
        parent.verticalCenter

    theme: theme
    volumeProc: volumeProc
    

}

// ========================================================
// UPDATES
// ========================================================

LocalComponents.Updates {
    id: updatesButton

    height: 32

    anchors.verticalCenter:
        parent.verticalCenter

    updateCount:
        root.updateCount

    theme:
        theme

    themeRunner:
        themeRunner

    updateCheck:
        updateCheck
}

// ========================================================
// VOLUME HOVER BRIDGE
// ========================================================

Connections {
    target: volumeButton

    function onHoveredChanged() {
        detector.volumeHovered = volumeButton.hovered
    }
}

Connections {
    target: updatesButton

    function onHoveredChanged() {
        detector.updatesHovered =
            updatesButton.hovered

        if (updatesButton.hovered) {
            detector.activeHover = true
            hoverDebounceTimer.stop()
        } else if (!detector.isPinned) {
            hoverDebounceTimer.start()
        }
    }
}
        // ========================================================
        // SPOTIFY
        // ========================================================
        Loader {
            id: spotifyLoader

            active: true

            source: "components/Spotify.qml"


            visible:
                root.spotifyTrack !== "" &&
                !root.launcherVisible &&
                !root.panelVisible &&
                !root.weatherVisible &&
                !root.themeVisible 


            width:
    visible && item
    ? item.implicitWidth
    : 0


            height: 42


            anchors.verticalCenter:
                parent.verticalCenter


            Behavior on width {
                NumberAnimation {
                    duration: 250
                }
            }



            Binding {
                target: spotifyLoader.item
                property: "track"

                value: root.spotifyTrack

                when:
                    spotifyLoader.status === Loader.Ready
            }


            Binding {
                target: spotifyLoader.item
                property: "artUrl"

                value: root.spotifyArtUrl

                when:
                    spotifyLoader.status === Loader.Ready
            }


            Binding {
                target: spotifyLoader.item
                property: "theme"

                value: theme

                when:
                    spotifyLoader.status === Loader.Ready
            }


            Binding {
                target: spotifyLoader.item
                property: "spotifyControl"

                value: spotifyControl

                when:
                    spotifyLoader.status === Loader.Ready
            }



            Connections {
    target: spotifyLoader.item

    ignoreUnknownSignals: true

    function onClicked() {
    root.launcherVisible = false
    root.panelVisible = false
    root.themeVisible = false
    root.weatherVisible = false

    root.mediaVisible =
        !root.mediaVisible
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
        

    width:
        visible && item
        ? item.implicitWidth
        : 0

    height: 30

    anchors.verticalCenter:
        parent.verticalCenter

    onLoaded: {
        item.theme = theme

    }

    Behavior on width {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
      }
    }
  }
}
    // =====================================================
    // 3. VIEWPORT 1: EMBEDDED LAUNCHER ENGINE VIEWS
    // =====================================================
    Column {
        id: embeddedLauncherContent
        spacing: 12
        
        anchors { 
            top: topBarHeader.bottom 
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 14 
        }

        opacity: root.launcherVisible ? 1.0 : 0.0
        visible: opacity > 0
        
        Behavior on opacity { NumberAnimation { duration: root.launcherVisible ? 180 : 100 } }

        // SEARCH BAR
        Rectangle {
            width: parent.width
            height: 42
            radius: 8
            color: theme.surface

            Text { 
                text: ""
                color: theme.textMuted
                font.family: theme.font
                anchors { 
                    left: parent.left
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter 
                } 
            }

            TextField {
                id: inputField
                text: root.searchText
                color: theme.fg
                background: null
                font.family: theme.font
                
                anchors { 
                    fill: parent
                    leftMargin: 36
                    rightMargin: 8 
                }
                
                onTextChanged: { 
                    root.searchText = text
                    root.updateFilter() 
                }

                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Escape) { 
                        root.launcherVisible = false
                        event.accepted = true
                        return 
                    }
                    if (event.key === Qt.Key_Down) { 
                        root.selectedIndex = Math.min(root.selectedIndex + 1, root.filteredApps.length - 1)
                        event.accepted = true 
                    }
                    if (event.key === Qt.Key_Up) { 
                        root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
                        event.accepted = true 
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { 
                        if (root.filteredApps.length > 0) root.launch(root.filteredApps[root.selectedIndex])
                        event.accepted = true 
                    }
                }
            }
        }

        // LIST ENTRIES VIEW
        ListView {
            width: parent.width
            height: parent.height - 54
            model: root.filteredApps
            clip: true
            currentIndex: root.selectedIndex

            delegate: Rectangle {

                               // ListView Delegate parameters formatted onto clean lines
                width: ListView.view.width
                height: 38
                radius: 6
                color: index === root.selectedIndex ? theme.surfaceAlt : "transparent"

                Row {
                    spacing: 10
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10

                    Image {
                        width: 20
                        height: 20
                        source: modelData.icon ? "image://icon/" + modelData.icon : "image://icon/application-x-executable"
                    }

                    Text {
                        text: modelData.name
                        color: theme.fg
                        font { 
                            family: theme.font
                            pixelSize: 13 
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.selectedIndex = index
                        root.launch(modelData)
                    }
                }
            }
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
        bottom: parent.bottom
    }

    opacity: root.panelVisible ? 1.0 : 0.0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: root.panelVisible ? 180 : 100
        }
    }

   LocalComponents.System {
    id: systemDashboardTileModule

    width:
        420

    anchors {
        top:
            parent.top

        horizontalCenter:
            parent.horizontalCenter

        topMargin:
            14
    }

    theme:
        theme

    globalClock:
        clock

    panelVisible:
        root.panelVisible

    dndEnabled:
        root.dndEnabled

    notifServer:
        realNotifServer

    cpuTemp:
        root.cpuTemp

    cpuUsage:
        root.cpuUsage

    gpuTemp:
        root.gpuTemp

    ramUsage:
        root.ramUsage

    dataUsage:
        root.dataUsage

    homeUsage:
        root.homeUsage

    systemUptime:
        root.systemUptime
}
}
  } 
}