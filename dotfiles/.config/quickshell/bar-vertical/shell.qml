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
import "components"
import "windows"

ShellRoot {
    id: root

    SystemClock {
    id: clock
    precision: SystemClock.Minutes 
}

    PersistentProperties {
    id: persist
    // Store as JSON strings to avoid engine assignment errors
    property string seenJson: "{}"
    property string timestampsJson: "{}"
}

function toggleLauncher() {
    let launcherRef = centerRow.item?.launcherItem
    if (!launcherRef) return

    launcherRef.visible = !launcherRef.visible

    if (launcherRef.visible) {
        launcherRef.open()
    }
}


    NotificationServer {
    id: notifServer
    keepOnReload: true 
    
    onNotification: (n) => {
    if (!n) return;

    const app = (n.appName || n.desktopEntry || "").toLowerCase();
    const isSpotify = app.includes("spotify");

    n.tracked = true;
    n.isSpotifyTransient = isSpotify;

    let key = String(n.id || (n.summary + n.body));
        // 1. Safely parse the persistent data
        let timestamps = {};
        let seen = {};
        try {
            timestamps = JSON.parse(persist.timestampsJson);
            seen = JSON.parse(persist.seenJson);
        } catch(e) { /* fallback to empty objects */ }

        // 2. Handle Timestamp
        if (!timestamps[key]) {
            timestamps[key] = Date.now();
            persist.timestampsJson = JSON.stringify(timestamps);
        }
        n.timestamp = timestamps[key];

        // 3. Handle Popups & Duplicates
        if (n.lastGeneration || seen[key]) {
            return;
        }

        // 4. Mark as seen and trigger popup
        seen[key] = true;
        persist.seenJson = JSON.stringify(seen);
        
        root.currentNotif = n;
     }
     
     
}


Component.onCompleted: {
    weatherCheck.running = true
    spotifyProc.running = true
    wgCheck.running = true
    diskCheck.running = true
    uptimeCheck.running = true
    ramCheck.running = true
    updateCheck.running = true
}

    // ====================== PROPERTIES ======================
    property int themeUpdateTrigger: 0
    property string swayncText: " "
    property string updateCount: "0"
    property bool popupVisible: false
    property string cpuTemp: "00°C"
    property string cpuUsage: "0%"
    property string gpuTemp: "00°C"
    property string systemUptime: "0m"
    property string dataUsage: "0 / 1" 
    property string homeUsage: "0 / 1"
    property var currentNotif: null
    property string ramUsage: "0B" 
    property string ramTotal: "0B"
    property string weatherText: "--°C"
    property string vpnName: ""
    property bool vpnActive: false
    property var vpnConfigs: []
    property var themes: []
    property string currentTheme: ""
    property string spotifyTrack: ""
    property string spotifyArtUrl: ""
    property bool doNotDisturb: false
    property date currentTime: clock.date
    property bool panelVisible: false
    property bool dndEnabled: false
    property var globalClock: clock
    property var notifTimestamps: ({})
    property var seenNotifications: ({})
    property string weatherTooltip: "Loading..."
    property string cpuFreq: "--"
    property string gpuUsage: "--"
    property string gpuMemory: "--"
    property string gpuClock: "--"
    property string ramAvailable: "--"
    property string ramCached: "--"
    property string ramSwap: "--"
    property bool mediaVisible: false
    property real spotifyPosition: 0
    property real spotifyLength: 0
    property string spotifyStatus: "Paused"
    property var wallpapers: []
    property string currentResolutionFolder: "4K"
    property string currentThemeFolder: ""
    
    property var themeFolders: []
    property var networkData: ({ iface: "--", ip: "--", totalDown: "--", totalUp: "--", down: "--", up: "--", type: "--", connectedTime: "--", connected: false })
    property var weatherData: ({ code: 0, temp: "--", icon: "", desc: "", humidity: "--", feels: "--", wind: "--", sunrise: "--", sunset: "--", forecast: [] })
    property string diskData: diskProc.stdout.data || ""
    property var diskParts: diskData.length > 0 ? diskData.split(";") : []
    property var homeDiskRaw: diskParts[0] || "--|--|--|0"
    property var dataDiskRaw: diskParts[1] || "--|--|--|0"
    property var homeDisk: homeDiskRaw.split("|")
    property var dataDisk: dataDiskRaw.split("|")

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



PanelWindow {
    id: bar
    property bool vertical: true
    property alias themeObj: theme
    property alias getThemesObj: getThemes
    property alias checkCurrentObj: checkCurrent
    property alias themeLoaderObj: themeLoader
    property alias wallpaperProcObj: wallpaperProc
    property alias applyWallpaperObj: applyWallpaper
    property alias volumeProcObj: volumeProc
    property alias spotifyControlObj: spotifyControl
    property alias updateCheckObj: updateCheck
    property alias themeRunnerObj: themeRunner
    property alias themeFolderProcObj: themeFolderProc
    visible: true
    function runGetThemes() { getThemes.running = true }
function runCheckCurrent() { checkCurrent.running = true }

    WlrLayershell.namespace: "my-bar"
    WlrLayershell.exclusiveZone: 46
    WlrLayershell.layer: WlrLayershell.Top

    anchors {
        top: true
        left: true
        right: !vertical
        bottom: vertical
    }

    implicitHeight: 46
    implicitWidth: 46
    color: "transparent"
   

    // ====================== SERVICES ======================
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
    
    Loader {
        id: themeLoader
        source: "file:///home/igor/.config/quickshell/Colors.qml"
    }

    Connections {
        target: themeLoader
        function onStatusChanged() {
            if (themeLoader.status === Loader.Ready) themeUpdateTrigger++
        }
    }

    // ====================== THEME ======================
    QtObject {
        id: c
        readonly property bool ready: themeLoader.status === Loader.Ready

        property color bg:       ready ? (themeLoader.item?.bg ?? "#11111b") : "#11111b"
        property color fg:       ready ? (themeLoader.item?.textPrimary ?? themeLoader.item?.fg0 ?? "#cdd6f4") : "#cdd6f4"
        property color accent:   ready ? (themeLoader.item?.accent ?? "#89b4fa") : "#89b4fa"
        property color inactive: ready ? (themeLoader.item?.inactive ?? "#6c7086") : "#6c7086"
        property color activeWs: ready ? (themeLoader.item?.activeWs ?? "#89b4fa") : "#89b4fa"
        property color green:    ready ? (themeLoader.item?.green ?? "#a6e3a1") : "#a6e3a1"
        property color red:      ready ? (themeLoader.item?.red ?? "#f38ba8") : "#f38ba8"
        property color surface:  ready ? (themeLoader.item?.surface ?? "#313244") : "#313244"
        property color fg1:      ready ? (themeLoader.item?.fg1 ?? "#cdd6f4") : "#cdd6f4"
        property color fg3:      ready ? (themeLoader.item?.fg3 ?? "#c0c5ce") : "#c0c5ce"
        property color warning:  ready ? (themeLoader.item?.warning ?? "#ebcb8b") : "#ebcb8b"
        property color success:  ready ? (themeLoader.item?.success ?? "#a6e3a1") : "#a6e3a1"
        property color error:    ready ? (themeLoader.item?.error ?? "#f38ba8") : "#f38ba8"
        property color bgAlt:     ready ? (themeLoader.item?.bg1 ?? c.bg) : c.bg
        property color surfaceAlt: ready ? (themeLoader.item?.surfaceAlt ?? c.surface) : c.surface
        property color border:    ready ? (themeLoader.item?.border ?? c.accent) : c.accent
        property color hover:     ready ? (themeLoader.item?.accentHover ?? c.accent) : c.accent
        property color textSecondary: ready ? (themeLoader.item?.textSecondary ?? c.fg1) : c.fg1
    }

    QtObject {
    id: theme
    property bool vertical: bar.vertical
    property string font: "JetBrains Mono Nerd Font Propo"
    property real fontSize: 11.5
    property int fontWeight: Font.DemiBold

    // base
    property color bg: c.bg
    property color fg: c.fg
    property color fg1: c.fg1

    // accents
    property color accent: c.accent
    property color hover: c.hover
    property color border: c.border

    // states
    property color green: c.green
    property color red: c.red
    property color warning: c.warning
    property color success: c.success
    property color error: c.error

    // surfaces
    property color surface: c.surface
    property color surfaceAlt: c.surfaceAlt
    property color bgAlt: c.bgAlt

    // ui
    property color inactive: c.inactive
    property color activeWs: c.activeWs

    // text
    property color textMuted: c.fg3
    property color textSecondary: c.textSecondary
}

    // ====================== PROCESSES ======================
    Process { id: vpnRunner }
    Process { id: volumeProc }
    Process { id: spotifyControl }
    Process { id: themeRunner }
    Process { id: wgCheck; command: ["sh","-c","wg show interfaces"]; stdout: StdioCollector { onTextChanged: { root.vpnName = text.trim(); root.vpnActive = text.trim().length > 0 } } }
    Process { id: listConfigs; command: ["sh","-c", "ls /etc/wireguard/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf//'"]; stdout: StdioCollector { onTextChanged: root.vpnConfigs = text.trim().split("\n") } }
    Process { id: updateCheck; command: ["sh", "-c", "~/.config/scripts/updates.sh"]; stdout: StdioCollector { onStreamFinished: { updateCount = text.trim() || "0" }}}
    Process { id: cpuCheck; command: ["sh", "-c", "sensors -u k10temp-pci-00c3 | awk '/temp1_input:/ {print int($2)}'"]; stdout: StdioCollector { onTextChanged: cpuTemp = (text.trim() || "00") + "°C" }}
    Process { id: cpuUsageCheck; command: ["sh", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total1=$((user + nice + system + idle + iowait + irq + softirq + steal)); idle1=$((idle + iowait)); sleep 0.2; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total2=$((user + nice + system + idle + iowait + irq + softirq + steal)); idle2=$((idle + iowait)); total=$((total2 - total1)); idle=$((idle2 - idle1)); usage=$((100 * (total - idle) / total)); echo \"${usage}%\""]; stdout: StdioCollector { onStreamFinished: { cpuUsage = text.trim() || "--" } } }
    Process { id: cpuFreqCheck; command: [ "sh", "-c", "awk -F: '/cpu MHz/ {printf \"%.1f GHz\", $2/1000; exit}' /proc/cpuinfo" ]; stdout: StdioCollector { onStreamFinished: { cpuFreq = text.trim() || "--" }}}
    Process { id: gpuCheck; command: ["sh", "-c", "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1"]; stdout: StdioCollector { onTextChanged: gpuTemp = (text.trim() || "00") + "°C" }}
    Process { id: gpuUsageCheck; command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1"]; stdout: StdioCollector { onStreamFinished: gpuUsage = (text.trim() || "--") + "%" } }
    Process { id: gpuMemoryCheck; command: ["sh", "-c", "nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | head -n1 | awk -F', ' '{printf \"%.1f / %.1f GB\", $1/1024, $2/1024}'"]; stdout: StdioCollector { onStreamFinished: gpuMemory = text.trim() || "--" } }
    Process { id: gpuClockCheck; command: ["sh", "-c", "nvidia-smi --query-gpu=clocks.current.graphics --format=csv,noheader,nounits | head -n1 | awk '{printf \"%.0f MHz\", $1}'"]; stdout: StdioCollector { onStreamFinished: gpuClock = text.trim() || "--" } }
    Process { id: uptimeCheck; command: ["sh", "-c", "uptime -p | sed 's/up //; s/ hours,/h/; s/ minutes/m/'"]; stdout: StdioCollector { onTextChanged: root.systemUptime = text.trim() }}
    Process { id: diskCheck; command: ["sh", "-c", "df -h | awk '$6==\"/mnt/data\" {print \"DATA:\" $3 \" / \" $2} $6==\"/home\" {print \"HOME:\" $3 \" / \" $2}'" ]; stdout: StdioCollector { onTextChanged: { let lines = text.trim().split("\n"); root.dataUsage = "0 / 1"; root.homeUsage = "0 / 1"; for (let line of lines) { if (line.startsWith("DATA:")) { root.dataUsage = line.replace("DATA:", ""); } if (line.startsWith("HOME:")) { root.homeUsage = line.replace("HOME:", ""); }}}}}
    Process { id: ramCheck; command: ["sh", "-c", "free -h --si | awk '/^Mem:/ {print $3 \" \" $2}' | sed 's/Gi/GB/g'"]; running: true; stdout: StdioCollector { onTextChanged: { let parts = text.trim().split(/\s+/); if (parts.length >= 2) { root.ramUsage = parts[0]; root.ramTotal = parts[1]; } } } }
    Process { id: ramAvailableCheck; command: ["sh", "-c", "free -h | awk '/Mem:/ {print $7}'"]; stdout: StdioCollector { onStreamFinished: ramAvailable = text.trim() || "--" } }
    Process { id: ramCachedCheck; command: ["sh", "-c", "free -h | awk '/Mem:/ {print $6}'"]; stdout: StdioCollector { onStreamFinished: ramCached = text.trim() || "--" } }
    Process { id: ramSwapCheck; command: ["sh", "-c", "free -h | awk '/Swap:/ {print $3 \" / \" $2}'"]; stdout: StdioCollector { onStreamFinished: ramSwap = text.trim() || "--" } }
    Process { id: checkCurrent; command: ["cat", "/home/igor/.config/.current_theme"]; stdout: StdioCollector { onTextChanged: root.currentTheme = text.trim() }}
    Process { id: getThemes; command: ["sh", "-c", "find /home/igor/.config/themes -maxdepth 1 -mindepth 1 -type d ! -name templates -printf '%f\\n' | sort"]; stdout: StdioCollector { onTextChanged: root.themes = text.trim().split("\n").filter(name => name.length > 0) } }
    Process { id: wallpaperProc; command: ["sh", "-c", `find ~/Pictures/Wallpapers/${root.currentResolutionFolder} -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \\)`]; running: true; stdout: StdioCollector { onTextChanged: { root.wallpapers = text.trim().split("\n").filter(x => x.length > 0) } } }
    Process { id: themeFolderProc; command: ["sh", "-c", `find ~/Pictures/Wallpapers/${root.currentResolutionFolder} -mindepth 1 -maxdepth 1 -type d -printf '%f\n'`]; running: true; stdout: StdioCollector { onTextChanged: { root.themeFolders = [""].concat(text.trim().split("\n").filter(x => x.length > 0)) } } }
    Process { id: applyWallpaper}
    Process { id: spotifyProc; command: ["sh", "-c", "/home/igor/.config/waybar/scripts/spotify.sh"]; stdout: StdioCollector { onTextChanged: { try { let j = JSON.parse(text.trim()); root.spotifyTrack = j.text || ""; root.spotifyArtUrl = j.art || ""; root.spotifyPosition = Number(j.position) || 0; root.spotifyLength = Number(j.length) || 0; root.spotifyStatus = j.status || "Paused"; } catch(e) { root.spotifyTrack = ""; root.spotifyArtUrl = ""; root.spotifyPosition = 0; root.spotifyLength = 0; root.spotifyStatus = "Paused"; } } } }
    Process { id: networkProc; command: ["sh", "-c", "iface=$(ip route | awk '/default/ {print $5}' | head -n1); ip=$(ip -4 addr show $iface | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1); rx1=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null); tx1=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null); state=$(cat /sys/class/net/$iface/operstate 2>/dev/null); type=$(iw dev 2>/dev/null | grep Interface | grep -q $iface && echo 'Wi-Fi' || echo 'Ethernet'); uptime=$(awk '{print int($1)}' /proc/uptime); sleep 1; rx2=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null); tx2=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null); down=$((rx2-rx1)); up=$((tx2-tx1)); printf '%s|%s|%s|%s|%s|%s|%s|%s|%s' \"$iface\" \"$ip\" \"$rx2\" \"$tx2\" \"$state\" \"$type\" \"$down\" \"$up\" \"$uptime\""]; running: true; stdout: StdioCollector { onTextChanged: { let parts = text.trim().split('|'); if (parts.length < 9) return; function formatSpeed(bytes) { bytes = parseInt(bytes); if (bytes > 1024 * 1024) return (bytes / 1024 / 1024).toFixed(1) + ' MB/s'; if (bytes > 1024) return (bytes / 1024).toFixed(1) + ' KB/s'; return bytes + ' B/s'; } function formatTotal(bytes) { bytes = parseInt(bytes); if (bytes > 1024 * 1024 * 1024) return (bytes / 1024 / 1024 / 1024).toFixed(1) + ' GB'; if (bytes > 1024 * 1024) return (bytes / 1024 / 1024).toFixed(1) + ' MB'; return (bytes / 1024).toFixed(1) + ' KB'; } function formatTime(seconds) { let h = Math.floor(seconds / 3600); let m = Math.floor((seconds % 3600) / 60); return h + 'h ' + m + 'm'; } root.networkData = { iface: parts[0], ip: parts[1], totalDown: formatTotal(parts[2]), totalUp: formatTotal(parts[3]), connected: parts[4] === 'up', type: parts[5], down: formatSpeed(parts[6]), up: formatSpeed(parts[7]), connectedTime: formatTime(parts[8]) }; networkProc.running = true } } }
    Process { id: diskProc; command: ["bash", "-c", "/home/igor/.config/quickshell/bar1/disk.sh"]; running: true; stdout: StdioCollector {} }
    Process {
    id: weatherCheck
    command: ["sh", "-c", "/home/igor/.config/waybar/scripts/weather.sh"]
    running: true // Ensure it runs
    
    stdout: StdioCollector {
        onTextChanged: {
            const raw = text ? text.trim() : ""
            if (!raw) return;

            try {
                const data = JSON.parse(raw)
                // text usually has the temp (e.g. "16°C")
                // tooltip usually has the detailed string
                root.weatherText = data.text || "--°C"
                root.weatherTooltip = data.tooltip || "No data"
            } catch(e) {
                root.weatherText = raw
            }
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
                    code: code,
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
    } 


Timer { interval: 5000; running: true; repeat: true; onTriggered: { if (!cpuCheck.running) cpuCheck.running = true } }
Timer { interval: 5200; running: true; repeat: true; onTriggered: { if (!gpuCheck.running) gpuCheck.running = true } }
Timer { interval: 5400; running: true; repeat: true; onTriggered: { if (!cpuUsageCheck.running) cpuUsageCheck.running = true } }

Timer { interval: 500; running: true; repeat: true; onTriggered: { if (!spotifyProc.running) spotifyProc.running = true } }

Timer { interval: 600000; running: true; repeat: true; onTriggered: { if (!weatherProc.running) weatherProc.running = true } }
Timer { interval: 600000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { if (!updateCheck.running) updateCheck.running = true } }
Timer { interval: 900000; running: true; repeat: true; onTriggered: { if (!weatherCheck.running) weatherCheck.running = true } }

Timer { interval: 6000; running: true; repeat: true; onTriggered: { if (!wgCheck.running) wgCheck.running = true } }
Timer { interval: 6500; running: true; repeat: true; onTriggered: { if (!listConfigs.running) listConfigs.running = true } }

Timer { interval: 60000; running: true; repeat: true; onTriggered: { if (!diskCheck.running) diskCheck.running = true } }

Timer { interval: 15000; running: true; repeat: true; onTriggered: { if (!uptimeCheck.running) uptimeCheck.running = true } }
Timer { interval: 17000; running: true; repeat: true; onTriggered: { if (!ramCheck.running) ramCheck.running = true } }

Timer { interval: 2000; running: true; repeat: true; onTriggered: { cpuFreqCheck.running = true }}
Timer { interval: 2000; running: true; repeat: true; onTriggered: { gpuCheck.running = true; gpuUsageCheck.running = true; gpuMemoryCheck.running = true; gpuClockCheck.running = true }}
Timer { interval: 3000; running: true; repeat: true; onTriggered: { ramAvailableCheck.running = true; ramCachedCheck.running = true; ramSwapCheck.running = true }}
Timer { interval: 5000; running: true; repeat: true; onTriggered: diskProc.running = true }

    // ====================== MAIN BAR ======================
    Rectangle {
        id: barBackground
    property alias themeObj: theme   // explicit, unambiguous path to the real theme object
        clip: false
        width: bar.vertical ? 38 : (bar.width > 0 ? bar.width - 16 : 900)
        height: bar.vertical ? (bar.height > 0 ? bar.height - 16 : 900) : 38
        radius: 18
        color: theme.bg
        anchors {
            horizontalCenter: bar.vertical ? undefined : parent.horizontalCenter
            verticalCenter: bar.vertical ? parent.verticalCenter : undefined
            top: bar.vertical ? undefined : parent.top
            left: bar.vertical ? parent.left : undefined
            topMargin: bar.vertical ? 0 : 6
            leftMargin: bar.vertical ? 6 : 0
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: bar.vertical ? 0 : 12
            anchors.rightMargin: bar.vertical ? 0 : 16
            anchors.topMargin: bar.vertical ? 12 : 0
            anchors.bottomMargin: bar.vertical ? 16 : 0

            // ================= LEFT / TOP =================
            Loader {
    id: leftRow
    sourceComponent: bar.vertical ? leftColumnComp : leftRowComp
    anchors {
        left: bar.vertical ? undefined : parent.left
        top: bar.vertical ? parent.top : undefined
        right: bar.vertical ? parent.right : centerRow.left
        horizontalCenter: bar.vertical ? parent.horizontalCenter : undefined
        verticalCenter: bar.vertical ? undefined : parent.verticalCenter
    }
}
            Component {
                id: leftRowComp
                Row {
                    spacing: 12
                    Menu { theme: bar.themeObj }
                    Ram { anchors.verticalCenter: parent.verticalCenter; ramUsage: root.ramUsage; ramTotal: "15.6GB"; ramAvailable: root.ramAvailable || "--"; ramCached: root.ramCached || "--"; ramSwap: root.ramSwap || "--"; theme: bar.themeObj }
                    Gpu { anchors.verticalCenter: parent.verticalCenter; temp: root.gpuTemp || "--"; usage: root.gpuUsage || "--"; memory: root.gpuMemory || "--"; clock: root.gpuClock || "--"; theme: bar.themeObj }
                    Cpu { anchors.verticalCenter: parent.verticalCenter; temp: root.cpuTemp || "--"; usage: root.cpuUsage || "--"; frequency: root.cpuFreq || "--"; theme: bar.themeObj }
                    Disk { theme: bar.themeObj; icon: ""; label: "Home"; free: (homeDisk[0] || "--"); total: (homeDisk[1] || "--"); onClicked: Qt.openUrlExternally("file:///home/igor") }
                    Disk { theme: bar.themeObj; icon: ""; label: "Data"; free: (dataDisk[0] || "--"); total: (dataDisk[1] || "--"); onClicked: Qt.openUrlExternally("file:///mnt/data") }
                    Windowtitle { theme: bar.themeObj; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }

           Component {
    id: leftColumnComp
    Column {
        spacing: 12
        Menu { theme: bar.themeObj; anchors.horizontalCenter: parent.horizontalCenter }
        Ram { ramUsage: root.ramUsage; ramTotal: "15.6GB"; ramAvailable: root.ramAvailable || "--"; ramCached: root.ramCached || "--"; ramSwap: root.ramSwap || "--"; theme: bar.themeObj; anchors.horizontalCenter: parent.horizontalCenter }
        Gpu { temp: root.gpuTemp || "--"; usage: root.gpuUsage || "--"; memory: root.gpuMemory || "--"; clock: root.gpuClock || "--"; theme: bar.themeObj; anchors.horizontalCenter: parent.horizontalCenter }
        Cpu { temp: root.cpuTemp || "--"; usage: root.cpuUsage || "--"; frequency: root.cpuFreq || "--"; theme: bar.themeObj; anchors.horizontalCenter: parent.horizontalCenter }
        Disk { theme: bar.themeObj; icon: ""; label: "Home"; free: (homeDisk[0] || "--"); total: (homeDisk[1] || "--"); onClicked: Qt.openUrlExternally("file:///home/igor"); anchors.horizontalCenter: parent.horizontalCenter }
        Disk { theme: bar.themeObj; icon: ""; label: "Data"; free: (dataDisk[0] || "--"); total: (dataDisk[1] || "--"); onClicked: Qt.openUrlExternally("file:///mnt/data"); anchors.horizontalCenter: parent.horizontalCenter }
        Windowtitle { theme: bar.themeObj; anchors.horizontalCenter: parent.horizontalCenter }
    }
}


            // ================= CENTER =================
            Loader {
    id: centerRow
    sourceComponent: bar.vertical ? centerColumnComp : centerRowComp
    anchors {
        top: bar.vertical ? leftRow.bottom : undefined
        topMargin: bar.vertical ? 20 : 0
        horizontalCenter: bar.vertical ? parent.horizontalCenter : undefined
        centerIn: bar.vertical ? undefined : parent
    }
}

            Component {
                id: centerRowComp
                Row {
                    clip: false
                    spacing: 14
                    height: parent ? parent.height : undefined

                    Cava { theme: bar.themeObj }

                    ClockModule {
                        anchors.verticalCenter: parent.verticalCenter
                        theme: bar.themeObj
                        weatherData: root.weatherData
                    }

                    Workspaces { theme: bar.themeObj }

                    Weather {
                        anchors.verticalCenter: parent.verticalCenter
                        tooltipText: "Melbourne"
                        weatherData: root.weatherData
                        theme: bar.themeObj
                    }

                    Spotify {
                        id: spotifyWidget
                        track: root.spotifyTrack
                        artUrl: root.spotifyArtUrl
                        theme: bar.themeObj
                        spotifyControl: spotifyControl
                        onClicked: { root.mediaVisible = !root.mediaVisible }
                    }

                    MediaPlayer {
                        visiblePlayer: root.mediaVisible
                        anchorItem: spotifyWidget
                        track: root.spotifyTrack
                        artUrl: root.spotifyArtUrl
                        position: root.spotifyPosition
                        length: root.spotifyLength
                        status: root.spotifyStatus
                        theme: bar.themeObj
                        spotifyControl: bar.spotifyControlObj
                    }
                }
            }

            Component {
    id: centerColumnComp
    Column {
        clip: false
        spacing: 14

        Cava { theme: bar.themeObj; anchors.horizontalCenter: parent.horizontalCenter }

        ClockModule {
            theme: bar.themeObj
            weatherData: root.weatherData
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Workspaces { theme: bar.themeObj; anchors.horizontalCenter: parent.horizontalCenter }

        Weather {
            tooltipText: "Melbourne"
            weatherData: root.weatherData
            theme: bar.themeObj
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Spotify {
            id: spotifyWidgetV
            track: root.spotifyTrack
            artUrl: root.spotifyArtUrl
            theme: bar.themeObj
            spotifyControl: spotifyControl
            onClicked: { root.mediaVisible = !root.mediaVisible }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MediaPlayer {
            visiblePlayer: root.mediaVisible
            anchorItem: spotifyWidgetV
            track: root.spotifyTrack
            artUrl: root.spotifyArtUrl
            position: root.spotifyPosition
            length: root.spotifyLength
            status: root.spotifyStatus
            theme: bar.themeObj
            spotifyControl: bar.spotifyControlObj
        }
    }
}

            // ================= RIGHT / BOTTOM =================
            Loader {
    id: rightRow
    sourceComponent: bar.vertical ? rightColumnComp : rightRowComp
    anchors {
        right: bar.vertical ? undefined : parent.right
        bottom: bar.vertical ? parent.bottom : undefined
        left: bar.vertical ? undefined : centerRow.right
        top: bar.vertical ? undefined : undefined
        verticalCenter: bar.vertical ? undefined : parent.verticalCenter
        horizontalCenter: bar.vertical ? parent.horizontalCenter : undefined
    }
}

            Component {
                id: rightRowComp
                Row {
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    layoutDirection: Qt.RightToLeft
                    spacing: 4

                    Item {
                        width: 24
                        height: parent.height

                        HoverItem {
                            anchors.fill: parent
                            textValue: ""
                            theme: bar.themeObj
                            hovered: mouseArea.containsMouse
                            overrideColor: (theme && theme.fg1)
                                           ? (panelVisible ? theme.accent : theme.fg1)
                                           : "#ffffff"
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { panelVisible = !panelVisible }
                        }
                    }

                    Volume {
                        anchors.verticalCenter: parent.verticalCenter
                        theme: bar.themeObj
                        volumeProc: volumeProc
                    }

                    Updates {
                        updateCount: root.updateCount
                        theme: bar.themeObj
                        themeRunner: themeRunner
                        updateCheck: updateCheck
                    }

                    Wallpapers {
    theme: bar.themeObj
    wallpapers: root.wallpapers
    themeFolders: root.themeFolders
    applyWallpaper: bar.applyWallpaperObj
    wallpaperProc: bar.wallpaperProcObj
    currentResolutionFolder: root.currentResolutionFolder
    currentThemeFolder: root.currentThemeFolder
    onResolutionChanged: folder => {
        root.currentResolutionFolder = folder
        bar.wallpaperProcObj.running = true
        bar.themeFolderProcObj.running = true
    }
}

                    Themes {
    theme: bar.themeObj
    themeLoader: bar.themeLoaderObj
    runGetThemes: bar.runGetThemes
    runCheckCurrent: bar.runCheckCurrent
    themes: root.themes
    currentTheme: root.currentTheme
    anchors.horizontalCenter: parent.horizontalCenter
}

                    Network {
                        anchors.verticalCenter: parent.verticalCenter
                        networkData: root.networkData
                        theme: bar.themeObj
                    }

                    Launcher {
                        id: launcher
                        theme: bar.themeObj
                    }

                    SystemTray { theme: bar.themeObj }

                    Toast {
                        theme: bar.themeObj
                        currentNotif: root.currentNotif
                        doNotDisturb: root.doNotDisturb
                        onDismiss: root.currentNotif = null
                    }

                    VolumeOSD { theme: bar.themeObj }
                    CapsLockOSD { theme: bar.themeObj }
                }
            }

            Component {
                id: rightColumnComp
                Column {
                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                    spacing: 10

                    Item {
                        width: parent ? parent.width : 24
                        height: 24

                        HoverItem {
                            anchors.fill: parent
                            textValue: ""
                            theme: bar.themeObj
                            hovered: mouseAreaV.containsMouse
                            overrideColor: (theme && theme.fg1)
                                           ? (panelVisible ? theme.accent : theme.fg1)
                                           : "#ffffff"
                        }

                        MouseArea {
                            id: mouseAreaV
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { panelVisible = !panelVisible }
                        }
                    }

                    Volume {
    theme: bar.themeObj
    volumeProc: volumeProc
    anchors.horizontalCenter: parent.horizontalCenter
}
Updates {
    updateCount: root.updateCount
    theme: bar.themeObj
    themeRunner: themeRunner
    updateCheck: updateCheck
    anchors.horizontalCenter: parent.horizontalCenter
}

Wallpapers {
    theme: bar.themeObj
    wallpapers: root.wallpapers
    themeFolders: root.themeFolders
    applyWallpaper: bar.applyWallpaperObj
    wallpaperProc: bar.wallpaperProcObj
    currentResolutionFolder: root.currentResolutionFolder
    currentThemeFolder: root.currentThemeFolder
    onResolutionChanged: folder => {
        root.currentResolutionFolder = folder
        bar.wallpaperProcObj.running = true
        bar.themeFolderProcObj.running = true
    }
}

Themes {
    theme: bar.themeObj
    themeLoader: bar.themeLoaderObj
    runGetThemes: bar.runGetThemes
    runCheckCurrent: bar.runCheckCurrent
    themes: root.themes
    currentTheme: root.currentTheme
    anchors.horizontalCenter: parent.horizontalCenter
}
Network {
    networkData: root.networkData
    theme: bar.themeObj
    anchors.horizontalCenter: parent.horizontalCenter
}
Launcher {
    id: launcherV
    theme: bar.themeObj
   
}
SystemTray { theme: bar.themeObj; anchors.horizontalCenter: parent.horizontalCenter }
Toast {
    theme: bar.themeObj
    currentNotif: root.currentNotif
    doNotDisturb: root.doNotDisturb
    onDismiss: root.currentNotif = null
    anchors.horizontalCenter: parent.horizontalCenter
}
VolumeOSD { theme: bar.themeObj }
CapsLockOSD { theme: bar.themeObj }                }
            }
        }
    }

 Loader {
    id: systemPanelLoader

    // Keep panel alive while closing animation runs
    active: true

    source: "components/SystemPanel.qml"

    onStatusChanged: {
        if (status === Loader.Error) {
            console.log("LOADER ERROR:", sourceComponent.errorString())
        }
    }

    onLoaded: {
    if (!item) return

    // --- Core ---
    item.globalClock = globalClock
    
    // Fix: Bind to globalClock.date, not .time
    item.currentTime = Qt.binding(() =>
        (globalClock && globalClock.date) ? globalClock.date : new Date()
    )
    
    item.theme = theme

        // --- Live stats ---
        item.cpuUsage = Qt.binding(() => cpuUsage)
        item.cpuTemp = Qt.binding(() => cpuTemp)
        item.gpuTemp = Qt.binding(() => gpuTemp)
        item.ramUsage = Qt.binding(() => ramUsage)
        item.dataUsage = Qt.binding(() => dataUsage)
        item.homeUsage = Qt.binding(() => homeUsage)
        item.systemUptime = Qt.binding(() => systemUptime)
        item.dndEnabled = Qt.binding(() => dndEnabled)

        // pass both states as bindings
        item.panelVisible = Qt.binding(() => panelVisible)
    }
  }
}
}
