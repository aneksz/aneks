// components/Weather.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Item {
    id: root

    // =====================================================
    // FONT
    // =====================================================
    FontLoader {
        id: weatherFont
        source: "file://" + Quickshell.env("HOME") + "/.local/share/fonts/ttf/weathericons-regular-webfont.ttf"
    }

    // =====================================================
    // API FROM SHELL
    // =====================================================
    property var theme
    property bool weatherVisible: false

    property var weatherData: ({
        temp: "--",
        iconCode: 0,
        desc: "",
        high: "--",
        low: "--",
        humidity: "--",
        feels: "--",
        wind: "--",
        sunrise: "--",
        sunset: "--",
        timezone: "--",
        forecast: []
    })

    // =====================================================
    // WEATHER ICON + DESCRIPTION HELPERS
    // (Erik Flowers Weather Icons + probability logic)
    // =====================================================
    readonly property var weatherIconName: function(code, precipProb) {
        const c = Number(code)
        const p = Number(precipProb) || 0

        // Light precip codes that we demote when probability is low
        const lightPrecip = [51, 53, 55, 61, 80]

        if (lightPrecip.includes(c) && p < 40)
            return "\uf013"          // wi-cloudy

        switch (c) {
            case 0:  return "\uf00d" // wi-day-sunny
            case 1:
            case 2:  return "\uf002" // wi-day-cloudy
            case 3:  return "\uf013" // wi-cloudy

            case 45:
            case 48: return "\uf014" // wi-fog

            case 51:
            case 53:
            case 55: return "\uf01c" // drizzle / sprinkle
            case 56:
            case 57: return "\uf0b5" // freezing drizzle

            case 61:
            case 63:
            case 65: return "\uf019" // rain
            case 66:
            case 67: return "\uf0b5" // freezing rain

            case 71:
            case 73:
            case 75:
            case 77: return "\uf01b" // snow
            case 85:
            case 86: return "\uf01b" // snow showers

            case 80:
            case 81:
            case 82: return "\uf01a" // showers

            case 95:
            case 96:
            case 99: return "\uf01e" // thunderstorm

            default: return "\uf07b" // wi-na
        }
    }

    readonly property var weatherDesc: function(code, precipProb) {
        const c = Number(code)
        const p = Number(precipProb) || 0

        const lightPrecip = [51, 53, 55, 61, 80]
        if (lightPrecip.includes(c) && p < 40)
            return "Cloudy"

        switch (c) {
            case 0:  return "Clear"
            case 1:  return "Mainly clear"
            case 2:  return "Partly cloudy"
            case 3:  return "Overcast"
            case 45:
            case 48: return "Fog"
            case 51:
            case 53:
            case 55: return "Drizzle"
            case 56:
            case 57: return "Freezing drizzle"
            case 61:
            case 63:
            case 65: return "Rain"
            case 66:
            case 67: return "Freezing rain"
            case 71:
            case 73:
            case 75: return "Snow"
            case 77: return "Snow grains"
            case 80:
            case 81:
            case 82: return "Showers"
            case 85:
            case 86: return "Snow showers"
            case 95: return "Thunderstorm"
            case 96:
            case 99: return "Thunderstorm + hail"
            default: return ""
        }
    }

    // =====================================================
    // WEATHER PROCESS
    // =====================================================
    Process {
        id: weatherProc

        command: [
            "curl", "-s", "--max-time", "5",
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=-37.814&longitude=144.9633" +
            "&current=temperature_2m,weather_code,relative_humidity_2m,apparent_temperature,wind_speed_10m" +
            "&daily=temperature_2m_max,temperature_2m_min,weather_code,precipitation_probability_max,sunrise,sunset" +
            "&timezone=auto&forecast_days=8"
        ]

        stdout: StdioCollector {
            waitForEnd: true

            onTextChanged: {
                if (typeof root === "undefined" || !text || !text.trim())
                    return

                const raw = text.trim()
                if (raw.startsWith("<") || !raw.startsWith("{")) {
                    console.log("Weather: skipped invalid response")
                    return
                }

                try {
                    const data = JSON.parse(raw)
                    const current = data.current
                    const daily   = data.daily

                    if (!current || !daily)
                        return

                    const currentCode = current.weather_code ?? 0
                    const forecast = []

                    for (let i = 0; i < daily.time.length; i++) {
                        const dateObj = new Date(daily.time[i] + "T00:00:00")
                        const code    = daily.weather_code ? daily.weather_code[i] : -1
                        const precip  = daily.precipitation_probability_max
                                        ? daily.precipitation_probability_max[i]
                                        : 0

                        forecast.push({
                            day:         i === 0 ? "Today" : Qt.formatDateTime(dateObj, "dddd"),
                            max:         daily.temperature_2m_max ? Math.round(daily.temperature_2m_max[i]) : "--",
                            min:         daily.temperature_2m_min ? Math.round(daily.temperature_2m_min[i]) : "--",
                            iconName:    root.weatherIconName(code, precip),
                            description: root.weatherDesc(code, precip),
                            precipProb:  precip,
                            dayOfWeek:   dateObj.getDay()
                        })
                    }

                    const timezoneName = data.timezone
                        ? data.timezone.split("/").pop().replace("_", " ")
                        : "--"

                    const maxToday = (daily.temperature_2m_max && daily.temperature_2m_max.length > 0)
                                     ? Math.round(daily.temperature_2m_max[0]) : "--"
                    const minToday = (daily.temperature_2m_min && daily.temperature_2m_min.length > 0)
                                     ? Math.round(daily.temperature_2m_min[0]) : "--"

                    const sunriseStr = (daily.sunrise && daily.sunrise.length > 0) ? daily.sunrise[0] : null
                    const sunsetStr  = (daily.sunset  && daily.sunset.length  > 0) ? daily.sunset[0]  : null

                    root.weatherData = {
                        temp:     current.temperature_2m !== undefined ? Math.round(current.temperature_2m) : "--",
                        iconCode: currentCode,
                        desc:     root.weatherDesc(currentCode, 100),   // current has no prob → force full
                        high:     maxToday,
                        low:      minToday,
                        humidity: current.relative_humidity_2m !== undefined
                                  ? current.relative_humidity_2m + "%" : "--%",
                        feels:    current.apparent_temperature !== undefined
                                  ? Math.round(current.apparent_temperature) + "°" : "--°",
                        wind:     current.wind_speed_10m !== undefined
                                  ? Math.round(current.wind_speed_10m) + " km/h" : "-- km/h",
                        sunrise:  sunriseStr
                                  ? Qt.formatTime(new Date(sunriseStr + ":00"), "h:mm AP") : "--:-- AM",
                        sunset:   sunsetStr
                                  ? Qt.formatTime(new Date(sunsetStr  + ":00"), "h:mm AP") : "--:-- PM",
                        timezone: timezoneName,
                        forecast: forecast
                    }
                }
                catch (e) {
                    console.log("Weather JSON parse error:", e)
                }
            }
        }
    }

    Timer {
        interval: 600000   // 10 minutes
        running: true
        repeat: true
        onTriggered: if (!weatherProc.running) weatherProc.running = true
    }

    Component.onCompleted: weatherProc.running = true

    // =====================================================
    // UI
    // =====================================================
    Rectangle {
        id: background
        anchors.fill: parent
        radius: 16
        color: "transparent"

        RowLayout {
            id: mainLayout
            anchors { fill: parent; margins: 12 }
            spacing: 12

            // -------------------------------------------------
            // LEFT COLUMN
            // -------------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 5
                Layout.fillHeight: true
                spacing: 10

                // TODAY CARD
Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 180
    radius: 14
    color: root.theme.surface

    RowLayout {
        anchors.centerIn: parent          // centres the whole group
        spacing: 24                       // adjust to taste

        // Large weather icon
        Item {
            Layout.preferredWidth: 130
            Layout.preferredHeight: 130

            Text {
                anchors.centerIn: parent
                text: root.weatherIconName(weatherData.iconCode, 100)
                color: root.theme.accent
                font {
                    family: "Weather Icons"
                    pixelSize: 112
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Temperature + description (aligned to top of icon)
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            spacing: 4

            Text {
                text: (weatherData.temp ?? "--") + "°C"
                color: root.theme.fg0
                font { family: root.theme.font; pixelSize: 62; bold: true }
            }

            Text {
                text: (weatherData.low ?? "--") + "° / " + (weatherData.high ?? "--") + "°"
                color: root.theme.fg0
                font { family: root.theme.font; pixelSize: 18 }
            }

            Text {
                text: weatherData.desc || "Loading..."
                color: root.theme.fg0
                font { family: root.theme.font; pixelSize: 20 }
            }
        }
    }
}

                // DETAILS CARD
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 14
                    color: root.theme.surface

                    GridLayout {
                        anchors { fill: parent; margins: 12 }
                        columns: 2
                        columnSpacing: 28
                        rowSpacing: 0

                        Repeater {
                            model: [
                                { icon: "", label: "Max",      value: (weatherData.high ?? "--") + "°" },
                                { icon: "", label: "Min",      value: (weatherData.low  ?? "--") + "°" },
                                { icon: "", label: "Wind",     value: weatherData.wind     || "--" },
                                { icon: "", label: "Feels",    value: weatherData.feels    || "--" },
                                { icon: "", label: "Humidity", value: weatherData.humidity || "--" },
                                { icon: "", label: "Sunrise",  value: weatherData.sunrise  || "--" },
                                { icon: "", label: "Sunset",   value: weatherData.sunset   || "--" },
                                { icon: "󰥔", label: "Timezone", value: weatherData.timezone || "--" }
                            ]

                            delegate: RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Layout.fillHeight: true
                                spacing: 8

                                Item {
                                    Layout.preferredWidth: 22
                                    Layout.preferredHeight: 16
                                    Layout.alignment: Qt.AlignVCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.icon
                                        color: root.theme.accent
                                        font { family: root.theme.font; pixelSize: 14 }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.label
                                    color: root.theme.fg0
                                    font { family: root.theme.font; pixelSize: 12 }
                                }

                                Text {
                                    text: modelData.value
                                    color: root.theme.fg
                                    font {
                                        family: root.theme.font
                                        pixelSize: 12
                                        bold: true
                                    }
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            // -------------------------------------------------
            // RIGHT COLUMN – NEXT 7 DAYS
            // -------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 4
                Layout.fillHeight: true
                radius: 14
                color: root.theme.surface

                ColumnLayout {
                    anchors {
                        fill: parent
                        topMargin: 12
                        bottomMargin: 12
                        leftMargin: 12
                        rightMargin: 12
                    }
                    spacing: 0

                    Repeater {
                        model: weatherData.forecast ? weatherData.forecast.slice(1, 8) : []

                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Column {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                RowLayout {
                                    width: parent.width
                                    spacing: 8

                                    // Forecast icon
                                    Item {
                                        Layout.preferredWidth: 30
                                        Layout.preferredHeight: 30
                                        Layout.alignment: Qt.AlignVCenter

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.iconName
                                            color: root.theme.fg
                                            font {
                                                family: "Weather Icons"
                                                pixelSize: 21
                                            }
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.day
                                        verticalAlignment: Text.AlignVCenter
                                        color: (modelData.dayOfWeek === 0 || modelData.dayOfWeek === 6)
                                               ? root.theme.error
                                               : root.theme.fg
                                        font {
                                            family: root.theme.font
                                            pixelSize: 14
                                            bold: true
                                        }
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.min + "° / " + modelData.max + "°"
                                        horizontalAlignment: Text.AlignRight
                                        verticalAlignment: Text.AlignVCenter
                                        color: root.theme.fg
                                        font {
                                            family: root.theme.font
                                            pixelSize: 13
                                        }
                                    }
                                }

                                Text {
                                    width: parent.width
                                    text: modelData.description || ""
                                    color: root.theme.fg0
                                    font {
                                        family: root.theme.font
                                        pixelSize: 11
                                    }
                                    elide: Text.ElideRight
                                }

                                // Optional probability line
                                Text {
                                    width: parent.width
                                    text: modelData.precipProb > 0
                                          ? modelData.precipProb + "% chance"
                                          : ""
                                    color: root.theme.inactive
                                    font {
                                        family: root.theme.font
                                        pixelSize: 11
                                    }
                                    visible: modelData.precipProb > 0
                                }
                            }

                            // Separator
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 1
                                color: Qt.rgba(1, 1, 1, 0.05)
                                visible: index < 6
                            }
                        }
                    }
                }
            }
        }
    }
}