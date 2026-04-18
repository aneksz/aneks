import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Io
import Quickshell.Services.Notifications
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

PanelWindow {
    id: bar
    
    // ====================== PROPERTIES ======================
    property int themeUpdateTrigger: 0
    property string swayncText: " "
    property string updateCount: "0"
    property bool popupVisible: false
    property string cpuTemp: "00°C"
    property string gpuTemp: "00°C"
    property string systemUptime: "0m"
    property string dataUsage: "0"
    property string homeUsage: "0"
    property string ramUsage: "0B"
    property var weatherData: ({
    temp: "--",
    icon: "",
    desc: "",
    humidity: "--",
    feels: "--",
    wind: "--",
    sunrise: "--",
    sunset: "--",
    forecast: []
})

    // ====================== WINDOW ======================
    anchors { top: true; left: true; right: true }
    implicitHeight: 46
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

        property color bg:       ready ? (themeLoader.item?.bg ?? "#D911111b") : "#D911111b"
        property color fg:       ready ? (themeLoader.item?.fg ?? themeLoader.item?.fg0 ?? themeLoader.item?.fg1 ?? "#cdd6f4") : "#cdd6f4"
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
    }

    QtObject {
        id: theme
        property string font: "JetBrainsMono Nerd Font Propo"
        property real fontSize: 12
        property int fontWeight: Font.DemiBold

        property color bg: c.bg
        property color fg: c.fg
        property color fg1: c.fg1
        property color accent: c.accent
        property color green: c.green
        property color red: c.red
        property color inactive: c.inactive
        property color activeWs: c.activeWs
        property color surface: c.surface
        property color warning: c.warning
        property color success: c.success
        property color error: c.error
        property color textMuted: c.fg3
    }

    // ====================== PROCESSES ======================
    Process { id: vpnRunner }
    Process { id: volumeProc }
    Process { id: spotifyControl }
    Process { id: themeRunner }
    Process { id: updateCheck; command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]; running: true; stdout: StdioCollector { onTextChanged: updateCount = text.trim() || "0" }}
    Process { id: swayncCheck; command: ["/home/igor/.config/waybar/scripts/notifications.sh"]; running: true; stdout: SplitParser { onRead: data => { swayncText = data.trim() }}}
    Process { id: cpuCheck; command: ["sh", "-c", "sensors -u k10temp-pci-00c3 | awk '/temp1_input:/ {print int($2)}'"]; running: true; stdout: StdioCollector { onTextChanged: cpuTemp = (text.trim() || "00") + "°C" }}
    Process { id: gpuCheck; command: ["sh", "-c", "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1"]; running: true; stdout: StdioCollector { onTextChanged: gpuTemp = (text.trim() || "00") + "°C" }}
    Process { id: uptimeCheck; command: ["sh", "-c", "uptime -p | sed 's/up //; s/ hours,/h/; s/ minutes/m/'"]; running: true; stdout: StdioCollector { onTextChanged: systemUptime = text.trim() }}
    Process { id: diskCheck; command: ["sh", "-c", "df -h /mnt/data /home | awk 'NR==2{print $3 \" / \" $4} NR==3{print $3 \" / \" $4}'"]; running: true; stdout: StdioCollector { onTextChanged: { let lines = text.trim().split("\n"); if (lines.length >= 2) { bar.dataUsage = lines[0]; bar.homeUsage = lines[1]; }}}}
    Process { id: ramCheck; command: ["sh", "-c", "free -b | awk '/^Mem:/ {print $3}' | numfmt --to=si"]; running: true; stdout: StdioCollector { onTextChanged: ramUsage = text.trim().replace("G", " GB") }}
    Process { id: spotifyProc; command: ["sh", "-c", "/home/igor/.config/waybar/scripts/spotify.sh"]; running: true; stdout: StdioCollector { onTextChanged: spotify.track = (text.trim() ? JSON.parse(text.trim()).text : "") } }        
    Process {
    id: weatherProc

    command: [
        "sh", "-c",
        "curl -s 'https://api.open-meteo.com/v1/forecast?latitude=-37.814&longitude=144.9633&current=temperature_2m,weather_code,relative_humidity_2m,apparent_temperature,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,weather_code,sunrise,sunset&timezone=auto'"
    ]

    running: true

    stdout: StdioCollector {
        waitForEnd: true

        onTextChanged: {
            try {
                let data = JSON.parse(text.trim())

                let current = data.current
                let daily = data.daily
                let code = current.weather_code

                // ===== FORECAST =====
                let forecast = []

                for (let i = 0; i < daily.time.length; i++) {
                    let dateObj = new Date(daily.time[i] + "T00:00:00")

                    forecast.push({
                        day: i === 0
                            ? "Today"
                            : Qt.formatDateTime(dateObj, "ddd"),

                        date: Qt.formatDateTime(dateObj, "MMM d"),
                        temp: Math.round(daily.temperature_2m_max[i]),
                        icon: weatherIcon(daily.weather_code[i])
                    })
                }

                // ===== FINAL DATA =====
                weatherData = {
                    temp: Math.round(current.temperature_2m),
                    icon: weatherIcon(code),
                    desc: weatherDesc(code),

                    humidity: current.relative_humidity_2m + "%",
                    feels: Math.round(current.apparent_temperature) + "°C",
                    wind: Math.round(current.wind_speed_10m) + " km/h",

                    sunrise: Qt.formatTime(new Date(daily.sunrise[0] + ":00"), "h:mm AP"),
                    sunset: Qt.formatTime(new Date(daily.sunset[0] + ":00"), "h:mm AP"),

                    forecast: forecast
                }

            } catch (e) {
                console.log("Weather parse failed:", e)
            }
        }
    }
}
Component.onCompleted: {
        weatherProc.running = true
    }

function weatherIcon(code) {
    if (code === 0) return "☀️"
    if ([1,2,3].includes(code)) return "🌤️"
    if ([45,48].includes(code)) return "☁️"
    if ([51,53,55].includes(code)) return "🌦️"
    if ([61,63,65,80,81,82].includes(code)) return "🌧️"
    if ([71,73,75].includes(code)) return "❄️"
    if ([95,96,99].includes(code)) return "⛈️"
    return "❔"
}

function weatherDesc(code) {
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
    Timer { interval: 2000; running: true; repeat: true; onTriggered: { cpuCheck.running = true; gpuCheck.running = true }}

    Timer { interval: 1000; running: true; repeat: true; onTriggered: spotifyProc.running = true }
    Timer {interval: 600000; running: true; repeat: true; onTriggered: { weatherProc.running = false; weatherProc.running = true }}

    // ====================== MAIN BAR ======================
    Rectangle {
        id: barBackground
        width: parent.width - 16
        height: 38
        radius: 20
        color: theme.bg
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 8 }

        Item {
    anchors.fill: parent
    anchors.leftMargin: 16
    anchors.rightMargin: 16
    
    // 1. LEFT
        Row {
            id: leftRow
            spacing: 20
            anchors.left: parent.left
            anchors.right: centerRow.left // Anchors to sibling
            anchors.verticalCenter: parent.verticalCenter

            // =========== WORKSPACES ==============
Item {
    id: workspaceModule
    height: 30
    width: wsRow.width
    anchors.verticalCenter: parent.verticalCenter

    // ✅ reliable in Quickshell
    property int activeWs: Hyprland.focusedWorkspace?.id ?? -1

    // ✅ only show for this bar's workspaces
    property bool showIndicator: activeWs >= 1 && activeWs <= 6

    // ================= INDICATOR =================
    Rectangle {
        id: animatedIndicator
        height: 4
        width: 20
        radius: 6
        color: c.activeWs

        anchors.bottom: parent.bottom
        anchors.bottomMargin: -1

        visible: workspaceModule.showIndicator

        // ✅ safe positioning
        x: (workspaceModule.activeWs - 1) * (28 + wsRow.spacing) + 4

        Behavior on x {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutQuint
            }
        }
    }
    // ================= WORKSPACES =================
    Row {
        id: wsRow
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: [1, 2, 3, 4, 5, 6]

            delegate: MouseArea {
    width: 28
    height: 28
    cursorShape: Qt.PointingHandCursor

    property int wsId: modelData
    property bool isActive: workspaceModule.activeWs === wsId

    property var icons: ({
        1: "",
        2: "",
        3: "",
        4: "",
        5: "",
        6: ""
    })

    Text {
        anchors.centerIn: parent

        text: icons[wsId] || ""

        color: isActive
            ? theme.accent
            : c.inactive

        font {
            family: theme.font
            pointSize: theme.fontSize 
        }

        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
 
    onClicked: Hyprland.dispatch("workspace " + wsId)
        }
     }
  }
}
// ============ WINDOW TITLE  ================
Item {
    id: windowTitle
    height: parent.height
    width: 350
    clip: true

    property string winClass: ""
    property string winTitle: ""
    
    Process {
    id: hyprProc
    command: ["hyprctl", "-j", "activewindow"]
    running: true

    stdout: StdioCollector {
        waitForEnd: true   // 🔥 IMPORTANT

        onTextChanged: {
            try {
                let data = JSON.parse(text.trim())

                windowTitle.winClass = (data.class || "").toLowerCase()
                windowTitle.winTitle = (data.title || "").toLowerCase()
               
            } catch (e) {
                // ignore
            }
        }
    }
}

    // 🔥 refresh loop (fast + reliable)
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: hyprProc.running = true
    }

    // 🔥 icon logic
    property string currentIcon: {
        let cls = winClass;
        let title = winTitle;

        if (!cls && !title) return "";

       
        if (cls.includes("whatsapp")) return "";
        if (cls.includes("spotify")) return "";
        if (cls.includes("brave")) return "";
        if (cls.includes("kitty") || cls.includes("alacritty")) return "";
        if (cls.includes("nautilus")) return "󰉋";
        if (cls.includes("discord")) return "";
        if (cls.includes("code") || cls.includes("codium")) return "";
        if (cls.includes("steam")) return "󰓓";
        
        
        if (title.includes("whatsapp")) return "󰖣";
        if (title.includes(".qml") || title.includes("vscodium")) return "";
        if (title.includes(" - ")) return "";
   

        return "";
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12
        height: parent.height

        Text {
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            font.pointSize: theme.fontSize
            font.family: theme.font
            color: theme.accent
            text: windowTitle.currentIcon
        }

        Text {
            height: parent.height
            width: 250
            verticalAlignment: Text.AlignVCenter
            text: windowTitle.winTitle !== "" ? windowTitle.winTitle : "Desktop"
            color: "white"
            font.pixelSize: 14
            elide: Text.ElideRight
        }
    }
  }

// ============ CAVA WAVE (Inside leftRow) ================
Item {
    id: cavaContainer
    height: parent.height
    // No horizontal anchors here! Row handles position.
    clip: true
    
    property var levels: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    readonly property bool active: {
        if (!levels || levels.length === 0) return false;
        var sum = 0;
        for (var i = 0; i < levels.length; i++) sum += levels[i];
        return sum > 0;
    }

    width: active ? 180 : 0
    opacity: active ? 1 : 0

    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    Behavior on opacity { NumberAnimation { duration: 400 } }

    Process {
        command: ["bash", "/home/igor/.config/waybar/scripts/cava.sh"]
        running: true
        stdout: StdioCollector {
            waitForEnd: false
            onTextChanged: {
                var lines = text.trim().split("\n");
                if (lines.length === 0) return;
                var lastLine = lines[lines.length - 1].trim();
                try {
                    var data = JSON.parse(lastLine);
                    if (data && data.values) {
                        // Re-assigning the whole array to trigger property updates
                        cavaContainer.levels = data.values;
                    }
                } catch (e) {
                    console.log("Cava QML Parse Error: " + e);
                }
            }
        }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        Repeater {
            model: 20
            delegate: Rectangle {
                width: 3
                anchors.verticalCenter: parent.verticalCenter 
                height: {
                    var val = cavaContainer.levels[index] || 0;
                    return Math.max(4, (val / 100) * (cavaContainer.height * 0.5));
                }
                radius: 2
                color: theme.accent
                Behavior on height { NumberAnimation { duration: 80 } }
            }
        }
    }
 }
}
    // ================= CENTER =================
Row {
    id: centerRow
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    spacing: 12
    height: parent.height


    // GPU
    Text { 
        text: " " + gpuTemp
        color: theme.error 
        font { family: theme.font; pointSize: theme.fontSize }
        y: (parent.height - height) / 2   
    }
     // ============ CLOCK & CALENDAR ==============
Item {
    id: clockModule
    width: clock.implicitWidth + 10
    height: 30
    anchors.verticalCenter: parent.verticalCenter
    
    
    property bool calendarVisible: false
    property int displayMonth: new Date().getMonth()
    property int displayYear: new Date().getFullYear()

    // ===== CLOCK =====
    Text {
        id: clock
        anchors.centerIn: parent

        text: Qt.formatDateTime(new Date(), "ddd dd MMM yy HH:mm")
        color: theme.fg1

        font.family: theme.font
        font.pointSize: theme.fontSize
        font.weight: theme.fontWeight
        
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd dd MMM yy HH:mm")
        }
    }
    // ===== CLICK =====
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            clockModule.displayMonth = new Date().getMonth()
            clockModule.displayYear = new Date().getFullYear()
            clockModule.calendarVisible = !clockModule.calendarVisible
        }
    }
    // ===== POPUP =====
    PopupWindow {
        id: calendarPopup
        visible: clockModule.calendarVisible
    

        color: "transparent"
        mask: null
        grabFocus: true
    

        onVisibleChanged: {
            if (!visible) {
                calendarContent.state = ""
                clockModule.calendarVisible = false
            }
        }

        anchor.item: clockModule
        anchor.edges: Edges.Bottom
        anchor.margins.top: 38
        anchor.rect.x: clockModule.mapToItem(null, 0, 0).x - (520 / 2) + (clockModule.width / 2)
        

        implicitWidth: 720
        implicitHeight: 460

        Item {
            anchors.fill: parent

            Rectangle {
                id: calendarContent
                anchors.fill: parent

                color: theme.bg
                border.color: theme.surface
                border.width: 1
                radius: 12
                

                opacity: 0
                transform: Translate { id: animTranslate; y: -10 }

                states: State {
                    name: "visible"
                    when: calendarPopup.visible
                    PropertyChanges { target: calendarContent; opacity: 1 }
                    PropertyChanges { target: animTranslate; y: 0 }
                }

                transitions: [
                    Transition {
                        ParallelAnimation {
                            NumberAnimation { properties: "opacity"; duration: 180 }
                            NumberAnimation { target: animTranslate; property: "y"; duration: 220 }
                        }
                    },
                    Transition {
                        ParallelAnimation {
                            NumberAnimation { properties: "opacity"; duration: 140 }
                            NumberAnimation { target: animTranslate; property: "y"; duration: 140 }
                        }
                    }
                ]

                // ===== MAIN LAYOUT =====
            RowLayout {
            anchors.fill: parent
            Layout.fillHeight: true
            anchors.margins: 15
           spacing: 20

             // ===== CALENDAR =====
             Column {
             Layout.preferredWidth: 220
            Layout.alignment: Qt.AlignVCenter
            spacing: 10

                        Row {
                            width: parent.width
                            height: 30
                            spacing: 10

                            MouseArea {
                                width: 30; height: 30
                                onClicked: {
                                    if (clockModule.displayMonth === 0) {
                                        clockModule.displayMonth = 11
                                        clockModule.displayYear--
                                    } else {
                                        clockModule.displayMonth--
                                    }
                                }
                                Text { anchors.centerIn: parent; text: ""; color: theme.fg }
                            }

                            MouseArea {
                                width: parent.width - 80
                                height: 30
                                onClicked: {
                                    clockModule.displayMonth = new Date().getMonth()
                                    clockModule.displayYear = new Date().getFullYear()
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: new Date(clockModule.displayYear, clockModule.displayMonth)
                                          .toLocaleString(Qt.locale(), "MMMM yyyy")
                                    color: theme.accent
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                width: 30; height: 30
                                onClicked: {
                                    if (clockModule.displayMonth === 11) {
                                        clockModule.displayMonth = 0
                                        clockModule.displayYear++
                                    } else {
                                        clockModule.displayMonth++
                                    }
                                }
                                Text { anchors.centerIn: parent; text: ""; color: theme.fg }
                            }
                        }

                        DayOfWeekRow {
                            width: parent.width
                            locale: Qt.locale("en_US")
                            delegate: Text {
                                text: model.shortName
                                horizontalAlignment: Text.AlignHCenter
                                color: theme.inactive
                                font.pixelSize: 10
                            }
                        }

                        MonthGrid {
                            id: grid
                            width: parent.width
                            height: 160
                            month: clockModule.displayMonth
                            year: clockModule.displayYear

                            property date selectedDate: new Date()
                            onClicked: (date) => grid.selectedDate = date

                            delegate: Rectangle {
                                implicitWidth: 30
                                implicitHeight: 30
                                radius: 6

                                color:
                                    (model.date.toDateString() === grid.selectedDate.toDateString())
                                        ? theme.accent
                                        : (model.today ? theme.surface : "transparent")

                                Text {
                                    anchors.centerIn: parent
                                    text: model.day
                                    color: model.month === grid.month ? theme.fg : theme.inactive
                                }
                            }
                        }
                    }

                    // ===== DIVIDER =====
    Rectangle {
        Layout.preferredWidth: 1
        Layout.fillHeight: true
        color: theme.surface
        opacity: 0.5
    }

           // ===== WEATHER =====
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        height: 380

       // ===== TOP RIGHT: SUN TIMES =====
Row {
    anchors.top: parent.top
    anchors.right: parent.right
    spacing: 20

    // ===== SUNRISE =====
    Row {
        spacing: 8

        Text {
            text: ""
            color: theme.accent
            font.family: theme.font
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
    width: 80
    spacing: 2

    Text {
        text: "Sunrise"
        width: parent.width
        horizontalAlignment: Text.AlignLeft   // 👈 FIX
        color: theme.inactive
        font.pixelSize: 11
    }

    Text {
        text: weatherData.sunrise || "--"
        width: parent.width
        horizontalAlignment: Text.AlignLeft   // 👈 FIX
        color: theme.fg
        font.pixelSize: 11
        font.bold: true
    }
}
    }

    // ===== SUNSET =====
    Row {
        spacing: 8

        Text {
            text: ""
            color: theme.accent
            font.family: theme.font
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
    width: 80
    spacing: 2

    Text {
        text: "Sunset"
        width: parent.width
        horizontalAlignment: Text.AlignLeft   // 👈 FIX
        color: theme.inactive
        font.pixelSize: 11
    }

    Text {
        text: weatherData.sunset || "--"
        width: parent.width
        horizontalAlignment: Text.AlignLeft   // 👈 FIX
        color: theme.fg
        font.pixelSize: 11
        font.bold: true
    }
}
    }
}
        // ===== MAIN CONTENT =====
        Column {
            anchors.fill: parent
            anchors.margins: 12
            anchors.topMargin: 50
            spacing: 18

            // ===== CURRENT =====
            Rectangle {
    width: parent.width - 2
    anchors.horizontalCenter: parent.horizontalCenter

    radius: 30
    color: theme.surface
    border.color: Qt.rgba(1,1,1,0.05)
    border.width: 1

    // 👇 THIS is the key
    implicitHeight: contentCol.implicitHeight + 28

    Column {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Text {
        
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: theme.inactive
            font.pixelSize: 11
        }

        Row {
            spacing: 16
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: weatherData.icon
                font.pixelSize: 42
            }

            Text {
                text: weatherData.temp + "°C"
                color: theme.fg
                font.pixelSize: 42
                font.bold: true
            }
        }

        Text {
            text: weatherData.desc
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: theme.inactive
            font.pixelSize: 11
        }
    }
}
            // ===== STATS =====
RowLayout {
    width: parent.width
    spacing: 10

    Repeater {
        model: [
            { icon: "", title: "Humidity", value: weatherData.humidity },
            { icon: "", title: "Feels Like", value: weatherData.feels },
            { icon: "", title: "Wind", value: weatherData.wind }
        ]

        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 1

            radius: 14
            color: theme.surface
            border.color: Qt.rgba(1,1,1,0.05)
            border.width: 1

            implicitHeight: contentRow.implicitHeight + 16

            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: 8

                // 👈 ICON (centered vertically)
                Text {
                    text: modelData.icon
                    color: theme.accent
                    font.family: theme.font
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }

                

                // 👈 TEXT STACK
                Column {
                    spacing: 2

                    Text {
                        text: modelData.title
                        color: theme.inactive
                        font.pixelSize: 11
                    }

                    Text {
                        text: modelData.value || "--"
                        color: theme.fg
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }
        }
    }
}
            // ===== FORECAST HEADER =====
            Text {
                text: "7-Day Forecast"
                color: theme.fg
                font.pixelSize: 11
                font.bold: true
            }

            // ===== FORECAST =====
RowLayout {
    width: parent.width
    spacing: 10

    Repeater {
        model: weatherData.forecast

        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 1   // 👈 equal width cards

            radius: 12
            color: theme.surface
            border.color: Qt.rgba(1,1,1,0.05)
            border.width: 1

            implicitHeight: contentCol.implicitHeight + 16

            Column {
    id: contentCol
    anchors.centerIn: parent
    width: parent.width
    spacing: 6

    Text {
        text: modelData.day
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        color: modelData.day === "Today"
            ? theme.accent
            : theme.inactive
        font.pixelSize: 11
        font.bold: true
    }

    Text {
        text: modelData.date || ""
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        color: theme.inactive
        font.pixelSize: 11
        opacity: 0.7
    }

    Text {
        text: modelData.icon
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 22
    }

    Text {
        text: modelData.temp + "°"
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        color: theme.fg
        font.pixelSize: 11
        font.bold: true
    }
}
             }
           }
         }
       }
     }
    }
   }
  }
 }
}
// ============== WEATHER ===================
                Text {
                    id: weather
                    anchors.verticalCenter: parent.verticalCenter
                    text: "--°C"
                    color: theme.accent
                    font { family: theme.font; pointSize: theme.fontSize; weight: theme.fontWeight }
                    Process {
                        command: ["sh", "-c", "/home/igor/.config/waybar/scripts/weather.sh"]
                        running: true
                        stdout: StdioCollector { onTextChanged: {
                            try { weather.text = JSON.parse(text.trim()).text.replace(/^(\S+)\s*/, "$1 ") }
                            catch(e) { weather.text = text.trim() }
                        }}
                    }
                    Timer { interval: 900000; running: true; repeat: true; onTriggered: parent.Process.running = true }
                }

                // ================ CPU =====================

                // CPU
                Text { text: " " + cpuTemp; color: theme.warning; font { family: theme.font; pointSize: theme.fontSize } anchors.verticalCenter: parent.verticalCenter }
}

// ================= RIGHT =================
Row {
    id: rightRow // Helpful to have an ID
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.left: centerRow.right 
    
    anchors.verticalCenter: parent.verticalCenter
    layoutDirection: Qt.RightToLeft 
    spacing: 4

// ===== SYSTEM PANEL =====

Item {
    id: systemPanelButton
    width: 30
    height: 30
    anchors.verticalCenter: parent.verticalCenter

    property bool panelVisible: false

    Text {
        anchors.centerIn: parent
        text: ""
        font.family: theme.font
        font.pointSize: theme.fontSize
        color: systemPanelButton.panelVisible ? theme.accent : theme.fg1
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: systemPanelButton.panelVisible = !systemPanelButton.panelVisible
    }

    PopupWindow {
        id: systemPopup
        visible: systemPanelButton.panelVisible || panelContent.opacity > 0.01
        color: "transparent"
        mask: null
        grabFocus: false

        onVisibleChanged: {
            if (!visible && systemPanelButton.panelVisible) {
                 systemPanelButton.panelVisible = false
            }
        }

        anchor.window: bar
        anchor.rect.x: bar.screen.width - 320 - 10
        anchor.rect.y: 55
        anchor.rect.width: 320
        anchor.rect.height: 800

        implicitWidth: 360
        implicitHeight: 800

        Item {
            anchors.fill: parent
            clip: true 

            Rectangle {
                id: panelContent
                anchors.fill: parent
                color: theme.bg
                radius: 12
                border.color: theme.surface
                border.width: 1

                // Smooth Animation Logic
                opacity: systemPanelButton.panelVisible ? 1 : 0
                transform: Translate { 
                    x: systemPanelButton.panelVisible ? 0 : 320 
                }

                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on transform { 
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 18

           // --- Header Section ---
    Row {
        width: parent.width; spacing: 12
        
        Item {
            width: 48; height: 48

            // 1. The Mask (The shape we want)
            Rectangle {
                id: maskObj
                anchors.fill: parent
                radius: 24
                visible: false // Hidden, only used as a template
            }

            // 2. The Image (The content we want)
            Image {
                id: faceImage
                anchors.fill: parent
                source: "file:///home/igor/.config/quickshell/face.png"
                fillMode: Image.PreserveAspectCrop
                visible: false // Hidden, only used as source for the mask
            }

            // 3. The Final Result (Combining 1 and 2)
            OpacityMask {
                anchors.fill: parent
                source: faceImage
                maskSource: maskObj
            }

            // 4. Optional Border to make it look sharp
            Rectangle {
                anchors.fill: parent
                radius: 24
                color: "transparent"
                border.color: theme.surface
                border.width: 1
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter; spacing: 2
            Text { text: "System Dashboard"; color: theme.fg1; font.weight: theme.fontWeight; font.pointSize: 14; font.family: theme.font }
            Row {
                spacing: 5
                Text { text: " igor@arch"; color: theme.inactive; font.family: theme.font; font.weight: theme.fontWeight; font.pointSize: 11 }
            }
        }
    }



    // --- Volume Section ---
Rectangle {
    id: volContainer
    width: parent.width; height: 80; radius: 12; color: theme.surface
    visible: Pipewire.defaultAudioSink !== null

    // 1. Force a reactive binding to the volume
    readonly property real currentVol: {
        const sink = Pipewire.defaultAudioSink;
        if (sink && sink.audio) return sink.audio.volume;
        return 0.0;
    }

    Column {
        anchors.fill: parent; anchors.margins: 15; spacing: 10
        
        Item {
            width: parent.width; height: 20
            Row {
                anchors.left: parent.left; spacing: 8
                Text { 
                    // Reactive mute icon
                    text: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio && Pipewire.defaultAudioSink.audio.muted) ? "  " : "  "
                    color: theme.accent; font.family: theme.font; font.pointSize: 14 
                }
                Text { text: "Volume"; color: theme.fg1; font.pointSize: 9; font.family: theme.font; font.weight: theme.fontWeight }
            }

            Text { 
                anchors.right: parent.right
                // 2. Reference the ID directly to ensure the binding works
                text: Math.round(volContainer.currentVol * 100) + "%"
                color: theme.inactive; font.pointSize: 8; font.family: theme.font; font.weight: theme.fontWeight
            }
        }

                MouseArea {
            width: parent.width; height: 10; cursorShape: Qt.PointingHandCursor
            
            // 1. Click to set volume
            onClicked: (mouse) => { 
                if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                    Pipewire.defaultAudioSink.audio.volume = mouse.x / width 
                }
            }

            // 2. Scroll to change volume
            onWheel: (wheel) => {
                if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                    // Calculate step (0.05 = 5% per scroll notch)
                    let step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                    let newVol = Pipewire.defaultAudioSink.audio.volume + step;
                    
                    // Keep volume between 0.0 and 1.0
                    Pipewire.defaultAudioSink.audio.volume = Math.min(Math.max(newVol, 0), 1);
                }
            }
            
            Rectangle {
                anchors.fill: parent; radius: 5; color: theme.bg
                Rectangle {
                    width: parent.width * volContainer.currentVol
                    height: parent.height; radius: 5; color: theme.accent
                }
            }
        }

    }
}

        // --- 2. Power Actions ---
    Row {
        width: parent.width; spacing: 10
        
        MouseArea {
            width: (parent.width / 3) - 7; height: 60; cursorShape: Qt.PointingHandCursor
            Rectangle { anchors.fill: parent; radius: 12; color: theme.surface; border.color: theme.surface; border.width: 1 }
            Text { anchors.centerIn: parent; text: ""; color: theme.success; font.pointSize: 18; font.family: theme.font }
            onClicked: { vpnRunner.command = ["systemctl", "reboot"]; vpnRunner.running = true }
        }

        MouseArea {
            width: (parent.width / 3) - 7; height: 60; cursorShape: Qt.PointingHandCursor
            Rectangle { anchors.fill: parent; radius: 12; color: theme.surface; border.color: theme.surface; border.width: 1 }
            Text { anchors.centerIn: parent; text: "⏻"; color: theme.error; font.pointSize: 18; font.family: theme.font }
            onClicked: { vpnRunner.command = ["systemctl", "poweroff"]; vpnRunner.running = true }
        }

        MouseArea {
            width: (parent.width / 3) - 7; height: 60; cursorShape: Qt.PointingHandCursor
            Rectangle { anchors.fill: parent; radius: 12; color: theme.surface; border.color: theme.surface; border.width: 1 }
            Text { anchors.centerIn: parent; text: "󰗽"; color: theme.accent; font.pointSize: 18; font.family: theme.font }
            onClicked: { vpnRunner.command = ["hyprctl", "dispatch", "exit"]; vpnRunner.running = true }
        }
    }

        // --- 3. Stats Row 1: CPU & GPU ---
    Row {
        width: parent.width; spacing: 10
        
        Rectangle {
            width: (parent.width / 2) - 5; height: 80; radius: 12; color: theme.surface
            Column {
                width: parent.width; anchors.centerIn: parent; spacing: 4
                Text { width: parent.width; text: ""; color: theme.accent; font.pointSize: 16; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
                Text { width: parent.width; text: bar.cpuTemp; color: theme.fg1; font.bold: true; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight } 
                Text { width: parent.width; text: "CPU Temp"; color: theme.inactive; font.pointSize: 8; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
            }
        }
        
        Rectangle {
            width: (parent.width / 2) - 5; height: 80; radius: 12; color: theme.surface
            Column {
                width: parent.width; anchors.centerIn: parent; spacing: 4
                Text { width: parent.width; text: ""; color: theme.success; font.pointSize: 16; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
                Text { width: parent.width; text: bar.gpuTemp; color: theme.fg1; font.bold: true; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
                Text { width: parent.width; text: "GPU Temp"; color: theme.inactive; font.pointSize: 8; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
            }
        }
    }

    // --- 4. Stats Row 2: Memory & Uptime ---
    Row {
        width: parent.width; spacing: 10
        
        Rectangle {
            width: (parent.width / 2) - 5; height: 80; radius: 12; color: theme.surface
            Column {
                width: parent.width; anchors.centerIn: parent; spacing: 4
                Text { width: parent.width; text: ""; color: theme.accent; font.pointSize: 16; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
                Text { width: parent.width; text: bar.ramUsage; color: theme.fg1; font.bold: true; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight } 
                Text { width: parent.width; text: "Memory"; color: theme.inactive; font.pointSize: 8; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
            }
        }
        
        Rectangle {
            width: (parent.width / 2) - 5; height: 80; radius: 12; color: theme.surface
            Column {
                width: parent.width; anchors.centerIn: parent; spacing: 4
                Text { width: parent.width; text: "󱑂"; color: theme.success; font.pointSize: 16; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
                Text { width: parent.width; text: bar.systemUptime; color: theme.fg1; font.bold: true; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
                Text { width: parent.width; text: "System Uptime"; color: theme.inactive; font.pointSize: 8; font.family: theme.font; horizontalAlignment: Text.AlignHCenter; font.weight: theme.fontWeight }
            }
        }
    }



    // --- Storage Section ---
    Text { text: "Storage"; color: theme.inactive; font.bold: true; font.pointSize: 9 }
    
    Rectangle {
        width: parent.width; height: 130; radius: 12; color: theme.surface
        Column {
            anchors.fill: parent; anchors.margins: 15; spacing: 15
            
          // --- Data Partition ---
Column {
    width: parent.width; spacing: 6
    Item {
        width: parent.width; height: 15
        Text { text: "/mnt/data"; color: theme.fg1; font.pointSize: 9; anchors.left: parent.left; font.weight: theme.fontWeight }
        Text { text: bar.dataUsage; color: theme.inactive; font.pointSize: 8; anchors.right: parent.right; font.weight: theme.fontWeight }
    }
    // The "Track" (Background)
    Rectangle { 
        width: parent.width; height: 10; radius: 3; color: theme.bg 
        
        // The "Progress" (Colored Bar)
        Rectangle { 
            height: 10; radius: 4; color: theme.accent
            width: (bar.dataUsage.split(" / ").length < 2) ? 0 : parent.width * (parseFloat(bar.dataUsage.split(" / ")[0]) / parseFloat(bar.dataUsage.split(" / ")[1]))
        }
    }
}

// --- Home Partition ---
Column {
    width: parent.width; spacing: 6
    Item {
        width: parent.width; height: 15
        Text { text: "/home/igor"; color: theme.fg1; font.pointSize: 9; anchors.left: parent.left; font.weight: theme.fontWeight }
        Text { text: bar.homeUsage; color: theme.inactive; font.pointSize: 8; anchors.right: parent.right; font.weight: theme.fontWeight }
    }
    // The "Track" (Background)
    Rectangle { 
        width: parent.width; height: 10; radius: 3; color: theme.bg 

        // The "Progress" (Colored Bar)
        Rectangle { 
            height: 10; radius: 4; color: theme.success
            width: (bar.homeUsage.split(" / ").length < 2) ? 0 : parent.width * (parseFloat(bar.homeUsage.split(" / ")[0]) / parseFloat(bar.homeUsage.split(" / ")[1]))
         }
       }
     }
   }   
  }
 }
 }
 }
 }
 }            


// ============= SWAYNC =================
                Item {
                    id: notifications
                    width: notifyText.implicitWidth + 10; height: 30
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: notifyText
                        anchors.centerIn: parent
                        text: swayncText
                        color: swayncText.includes("󰂛") ? theme.error : (swayncText.includes("󰍡") ? theme.warning : theme.textMuted)
                        font { family: theme.font; pointSize: theme.fontSize }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                themeRunner.command = ["hyprctl", "dispatch", "exec", "wlogout"]
                            } else {
                                themeRunner.command = ["swaync-client", "-t", "-sw"]
                            }
                            themeRunner.running = true
                        }
                    }
                }
      // =========== VOLUME ==============
            Item {
    id: volume
    width: volText.implicitWidth + 10
    height: 30
    anchors.verticalCenter: parent.verticalCenter

    property bool isMuted: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio
        ? Pipewire.defaultAudioSink.audio.muted
        : false

    property real vol: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio
        ? Pipewire.defaultAudioSink.audio.volume
        : 0

    Text {
        id: volText
        anchors.centerIn: parent
        text: volume.isMuted
            ? "    Mute"
            : " " + Math.round(volume.vol * 100) + "%"
        color: volume.isMuted ? theme.red : theme.success
        font.family: theme.font
        font.pointSize: theme.fontSize
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            volumeProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
            volumeProc.running = true
        }

        onWheel: (e) => {
            let step = e.angleDelta.y > 0 ? "5%+" : "5%-"
            volumeProc.command = ["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", step]
            volumeProc.running = true
        }
    }
}
                // ================ VPN ================================
                Item {
                id: vpn; width: Math.max(vpnText.implicitWidth + 20, 60); height: 30
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0
                property string name: ""; property bool active: false; property var configs: []
                Process { id: wgCheck; command: ["sh","-c","wg show interfaces"]; running: true; stdout: StdioCollector { onTextChanged: { vpn.name = text.trim(); vpn.active = text.trim().length > 0 } } }
                Process { id: listConfigs; command: ["sh","-c", "ls /etc/wireguard/*.conf 2>/dev/null | xargs -n1 basename | sed 's/.conf//'"]; running: true; stdout: StdioCollector { onTextChanged: vpn.configs = text.trim().split("\n") } }
                Timer { interval: 3000; running: true; repeat: true; onTriggered: { wgCheck.running = true; listConfigs.running = true } }
                Text { id: vpnText; anchors.centerIn: parent; text: vpn.active ? "󰦝 " + vpn.name : "󱦚 VPN"; color: vpn.active ? theme.accent : theme.textMuted; font.family: theme.font; font.pointSize: theme.fontSize }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.popupVisible = !bar.popupVisible }
                PopupWindow {
    visible: bar.popupVisible
    color: "transparent"
    mask: null
    grabFocus: true

    onVisibleChanged: {
        if (!visible) {
            vpnContent.state = ""
            bar.popupVisible = false
        }
    }

    anchor.item: vpn
    anchor.edges: Quickshell.Bottom | Quickshell.Left
    anchor.margins.top: 38
    anchor.margins.left: -180

    implicitWidth: 200
    implicitHeight: vpnCol.implicitHeight + 24

    Item {
        anchors.fill: parent

        Rectangle {
            id: vpnContent
            anchors.fill: parent
            radius: 12
            color: theme.bg
            border.color: theme.surface
            border.width: 1

            // 🎬 animation
            opacity: 0
            transform: Translate { id: vpnTranslate; y: -10 }

            states: State {
                name: "visible"
                when: bar.popupVisible
                PropertyChanges { target: vpnContent; opacity: 1 }
                PropertyChanges { target: vpnTranslate; y: 0 }
            }

            transitions: [
                Transition {
                    from: ""; to: "visible"
                    ParallelAnimation {
                        NumberAnimation { properties: "opacity"; duration: 160; easing.type: Easing.OutQuad }
                        NumberAnimation { target: vpnTranslate; property: "y"; duration: 200; easing.type: Easing.OutCubic }
                    }
                },
                Transition {
                    from: "visible"; to: ""
                    ParallelAnimation {
                        NumberAnimation { properties: "opacity"; duration: 120; easing.type: Easing.InQuad }
                        NumberAnimation { target: vpnTranslate; property: "y"; duration: 140; easing.type: Easing.InCubic }
                    }
                }
            ]

            Column {
                id: vpnCol
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 12
                width: 176
                spacing: 10

                Text {
                    width: parent.width
                    text: "VPN CONNECTIONS"
                    color: theme.inactive
                    font.family: theme.font
                    font.pointSize: 10
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Repeater {
                    model: vpn.configs

                    delegate: MouseArea {
                        width: 176
                        height: 32
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: parent.containsMouse ? theme.surface : "transparent"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: parent.containsMouse ? theme.green : theme.fg
                            font.family: theme.font
                        }

                        onClicked: {
                            vpnRunner.command = ["sudo", "wg-quick", "up", modelData]
                            vpnRunner.running = true
                            bar.popupVisible = false
                        }
                    }
                }
            }
                            Rectangle { width: parent.width - 20; height: 1; color: theme.surface; anchors.horizontalCenter: parent.horizontalCenter; visible: vpn.active }
                            MouseArea {
                                width: 176; height: 36; visible: vpn.active; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                Rectangle { anchors.fill: parent; color: parent.containsMouse ? theme.surface : "transparent"; border.color: parent.containsMouse ? theme.red : "transparent"; border.width: 1; radius: 8 }
                                Text { anchors.centerIn: parent; text: "DISCONNECT"; color: theme.red; font.family: theme.font; font.bold: true }
                                onClicked: { vpnRunner.command = ["/home/igor/.config/waybar/scripts/vpn.sh", "toggle"]; vpnRunner.running = true; bar.popupVisible = false }
                            }
                        }
                    }
                }
            }
      // ============= UPDATES ================
                Item {
                    width: updateText.implicitWidth + 10; height: 30
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        id: updateText
                        anchors.centerIn: parent
                        text: " " + updateCount
                        color: parseInt(updateCount) > 50 ? theme.error : (parseInt(updateCount) > 0 ? theme.warning : theme.error)
                        font { family: theme.font; pointSize: theme.fontSize; weight: theme.fontWeight }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { themeRunner.command = ["hyprctl", "dispatch", "exec", "kitty -e sudo pacman -Syyu"]; themeRunner.running = true; updateCount = "0" } }
  }
     // ============== THEME SELECTOR =================

Item {
    id: themeSelector
    width: 32; height: 30
    anchors.verticalCenter: parent.verticalCenter 

    property var themes: []
    property bool menuVisible: false
    property string currentTheme: ""

    Process {
        id: checkCurrent
        command: ["cat", "/home/igor/.config/.current_theme"]
        running: true
        stdout: StdioCollector {
            onTextChanged: themeSelector.currentTheme = text.trim()
        }
    }

    Process {
        id: getThemes
        command: ["sh", "-c", "ls /home/igor/.config/themes/*.sh | xargs -n1 basename | sed 's/.sh//'"]
        running: true
        stdout: StdioCollector {
            onTextChanged: themeSelector.themes = text.trim().split("\n")
        }
    }

    Text {
        anchors.centerIn: parent
        text: ""
        font.family: theme.font
        font.pointSize: theme.fontSize
        color: themeSelector.menuVisible ? theme.accent : theme.textMuted
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            getThemes.running = true
            checkCurrent.running = true
            themeSelector.menuVisible = !themeSelector.menuVisible
        }
    }

    PopupWindow {
    visible: themeSelector.menuVisible
    color: "transparent"
    mask: null
    grabFocus: true
   

    onVisibleChanged: {
        if (!visible) {
            themeContent.state = ""
            themeSelector.menuVisible = false
        }
    }
        anchor.item: themeSelector
        anchor.edges: Edges.Bottom
        anchor.margins.top: 34        
        anchor.margins.left: -140   

        implicitWidth: 180
        implicitHeight: themeColumn.implicitHeight + 30
    Item {
        anchors.fill: parent

        Rectangle {
            id: themeContent
            width: 170
            height: themeColumn.implicitHeight + 24
            anchors.centerIn: parent
            radius: 12

            // ✅ safe fallback
            color: themeLoader.item?.bg ?? theme.surface

            // 🎬 animation
            opacity: 0
            transform: Translate { id: themeTranslate; y: -10 }

            states: State {
                name: "visible"
                when: themeSelector.menuVisible
                PropertyChanges { target: themeContent; opacity: 1 }
                PropertyChanges { target: themeTranslate; y: 0 }
            }

            transitions: [
                Transition {
                    from: ""; to: "visible"
                    ParallelAnimation {
                        NumberAnimation { properties: "opacity"; duration: 160; easing.type: Easing.OutQuad }
                        NumberAnimation { target: themeTranslate; property: "y"; duration: 200; easing.type: Easing.OutCubic }
                    }
                },
                Transition {
                    from: "visible"; to: ""
                    ParallelAnimation {
                        NumberAnimation { properties: "opacity"; duration: 120; easing.type: Easing.InQuad }
                        NumberAnimation { target: themeTranslate; property: "y"; duration: 140; easing.type: Easing.InCubic }
                    }
                }
            ]

            Column {
                id: themeColumn
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 12
                width: 150
                spacing: 8

                Repeater {
                    model: themeSelector.themes

                    delegate: MouseArea {
                        width: 150
                        height: 30
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: modelData === themeSelector.currentTheme
                                ? theme.surface
                                : (parent.containsMouse ? theme.surface : "transparent")
                        }

                        Text {
                            anchors.centerIn: parent
                            text: (modelData === themeSelector.currentTheme ? "󰞑 " : "") + modelData
                            color: modelData === themeSelector.currentTheme
                                ? theme.accent
                                : theme.fg
                            font.family: theme.font 
                            font.weight: theme.fontWeight
                        }

                        onClicked: {
                            Quickshell.execDetached([
                                "sh", "-c",
                                "/home/igor/.config/themes/" + modelData + ".sh"
                            ])

                            themeSelector.menuVisible = false

                            Qt.callLater(() => {
                                themeLoader.source = ""
                                themeLoader.source =
                                    "file:///home/igor/.config/quickshell/Colors.qml?v=" + Date.now()
                                                      })
                        }
                    } // Closes MouseArea delegate
                } // Closes Repeater
            } // Closes Column
        } // Closes Rectangle (themeContent)
    } // Closes Item (inside Popup)
} // Closes PopupWindow
} // Closes Item (themeSelector)

// <--- NO EXTRA BRACES HERE. 
// Paste your UPDATES module directly below this.

   // ================= SPOTIFY =================
Item {
    id: spotify
    width: track !== "" ? 200 : 0
    height: 30
    // Force it to be a sibling and not overlap
    anchors.verticalCenter: parent.verticalCenter
    
    // 🔥 ADD THIS LINE: It forces Spotify to stay in the layout flow
    visible: track !== "" 

    property string track: ""

    Text {
        id: spotifyText
        anchors.fill: parent
        // Aligning to the left helps separate it from the update icon
        horizontalAlignment: Text.AlignLeft 
        verticalAlignment: Text.AlignVCenter
        text: spotify.track
        color: theme.success
        font { family: theme.font; pointSize: theme.fontSize }
        elide: Text.ElideRight
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: { 
            spotifyControl.command = ["sh","-c","playerctl --player=spotify play-pause"]
            spotifyControl.running = true 
        }
        onWheel: e => { 
            spotifyControl.command = ["sh","-c", e.angleDelta.y > 0 ? "playerctl next" : "playerctl previous"]
            spotifyControl.running = true 
          }
        }
      }
    }
   } 
  } 
} 



