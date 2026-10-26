// components/Weather.qml
import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property string tooltipText
    required property var theme

    property var weatherData: ({})

    FontLoader {
        id: weatherFont
        source: "file://" + Quickshell.env("HOME") + "/.local/share/fonts/ttf/weathericons-regular-webfont.ttf"
    }

    readonly property var weatherIconName: function(code, precipProb) {
        const c = Number(code)
        const p = Number(precipProb) || 0
        const lightPrecip = [51, 53, 55, 61, 80]

        if (lightPrecip.includes(c) && p < 40)
            return "\uf013"

        switch (c) {
            case 0:  return "\uf00d"
            case 1:
            case 2:  return "\uf002"
            case 3:  return "\uf013"
            case 45:
            case 48: return "\uf014"
            case 51:
            case 53:
            case 55: return "\uf01c"
            case 56:
            case 57: return "\uf0b5"
            case 61:
            case 63:
            case 65: return "\uf019"
            case 66:
            case 67: return "\uf0b5"
            case 71:
            case 73:
            case 75:
            case 77: return "\uf01b"
            case 85:
            case 86: return "\uf01b"
            case 80:
            case 81:
            case 82: return "\uf01a"
            case 95:
            case 96:
            case 99: return "\uf01e"
            default: return "\uf07b"
        }
    }

    implicitWidth: theme.vertical ? weatherColumn.implicitWidth : weatherRow.implicitWidth + 10
    implicitHeight: theme.vertical ? weatherColumn.implicitHeight : 30
    width: implicitWidth
    height: implicitHeight

    // ================= WEATHER LABEL: HORIZONTAL =================
    Row {
        id: weatherRow
        visible: !theme.vertical
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: root.weatherIconName(weatherData?.code, 100)
            color: theme.accent
            font { family: "Weather Icons"; pointSize: theme.fontSize }
            y: 3
        }

        Text {
            text: (weatherData?.temp || "--") + "°C"
            color: theme.accent
            font { family: theme.font; pointSize: theme.fontSize; weight: theme.fontWeight }
        }
    }

    // ================= WEATHER LABEL: VERTICAL =================
    Column {
        id: weatherColumn
        visible: theme.vertical
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.weatherIconName(weatherData?.code, 100)
            color: theme.accent
            font { family: "Weather Icons"; pointSize: theme.fontSize }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: (weatherData?.temp || "--") + "°C"
            color: theme.accent
            font { family: theme.font; pointSize: theme.fontSize - 2; weight: theme.fontWeight }
        }
    }

    // ================= HOVER DETECTION =================
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    // ================= FLOATING MINI CARD =================
    PopupWindow {
        id: popup

        visible: mouseArea.containsMouse &&
                 root.Window.window !== null

        anchor.item: root
        anchor.edges: theme.vertical ? Edges.Right : Edges.Bottom
        anchor.gravity: theme.vertical ? Edges.Right : Edges.Bottom
        anchor.margins.top: theme.vertical ? 0 : 38
        anchor.margins.left: theme.vertical ? 40 : 0

        color: "transparent"

        implicitWidth: card.implicitWidth + 2
        implicitHeight: card.implicitHeight + 2

        Rectangle {
            id: card
            anchors.centerIn: parent
            antialiasing: true
            radius: 16
            color: theme.bg
            implicitWidth: content.implicitWidth + 28
            implicitHeight: content.implicitHeight + 28

            opacity: mouseArea.containsMouse ? 1 : 0
            scale: mouseArea.containsMouse ? 1 : 0.96

            transform: Translate {
                y: mouseArea.containsMouse ? 0 : -4
            }

            Behavior on opacity { NumberAnimation { duration: 160 } }
            Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            Column {
                id: content
                anchors.centerIn: parent
                spacing: 10

                Row {
                    spacing: 6

                    Text {
                        text: root.weatherIconName(weatherData?.code, 100)
                        color: theme.accent
                        font { family: "Weather Icons"; pixelSize: 16 }
                        anchors.verticalCenter: parent.verticalCenter
                        y: 1
                    }

                    Text {
                        text: (weatherData?.temp || "--") + "°C"
                        color: theme.accent
                        font { family: theme.font; pixelSize: 16; bold: true }
                    }
                }

                Text {
                    text: root.tooltipText
                    color: theme.fg1
                    font { family: theme.font; pixelSize: 11 }
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    width: 180
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                Column {
                    spacing: 6

                    Row {
                        spacing: 50
                        Text { text: "Feels Like"; color: theme.inactive; width: 80 }
                        Text { text: weatherData?.feels || "--"; color: theme.fg1 }
                    }

                    Row {
                        spacing: 50
                        Text { text: "Humidity"; color: theme.inactive; width: 80 }
                        Text { text: weatherData?.humidity || "--"; color: theme.fg1 }
                    }
                }
            }
        }
    }
}