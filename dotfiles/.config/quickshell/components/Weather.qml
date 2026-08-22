// components/Weather.qml
import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property string textValue
    required property string tooltipText
    required property var theme
    required property string weatherIcon
    required property string temperature

    property var weatherData: ({})

    implicitWidth: weatherRow.implicitWidth + 10
    implicitHeight: 30

    // ================= WEATHER LABEL =================
    Row {
    id: weatherRow
    anchors.centerIn: parent
    spacing: 4

    // Weather icon
    Text {
        text: weatherData?.icon || "❔"

        color: theme.accent

        font {
            family: theme.font
            pointSize: theme.fontSize
        }
        y: 3
    }

    // Temperature
    Text {
        text: (weatherData?.temp || "--") + "°C"

        color: theme.accent

        font {
            family: theme.font
            pointSize: theme.fontSize
            weight: theme.fontWeight
        }
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
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom

        anchor.margins {
            top: 38
        }

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

            // ================= ANIMATION =================
            opacity: mouseArea.containsMouse ? 1 : 0
            scale: mouseArea.containsMouse ? 1 : 0.96

            transform: Translate {
                y: mouseArea.containsMouse ? 0 : -4
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            // ================= CONTENT =================
            Column {
                id: content

                anchors.centerIn: parent
                spacing: 10

              // ================= MAIN TEMP =================
Row {
    spacing: 6

    Text {
        text: weatherData?.icon || "❔"

        color: theme.accent

        font {
            family: theme.font
            pixelSize: 16
        }

        anchors.verticalCenter: parent.verticalCenter
        y: 1
    }

    Text {
        text: (weatherData?.temp || "--") + "°C"

        color: theme.accent

        font {
            family: theme.font
            pixelSize: 16
            bold: true
        }
    }
}

                // ================= LOCATION =================
                Text {
                    text: root.tooltipText

                    color: theme.fg1

                    font {
                        family: theme.font
                        pixelSize: 11
                    }

                    horizontalAlignment: Text.AlignHCenter
                }

                // ================= DIVIDER =================
                Rectangle {
                    width: 180
                    height: 1

                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                // ================= WEATHER DETAILS =================
                Column {
                    spacing: 6

                    Row {
                        spacing: 50

                        Text {
                            text: "Feels Like"
                            color: theme.inactive
                            width: 80
                        }

                        Text {
                            text: weatherData?.feels || "--"

                            color: theme.fg1
                        }
                    }

                    Row {
                        spacing: 50

                        Text {
                            text: "Humidity"
                            color: theme.inactive
                            width: 80
                        }

                        Text {
                            text: weatherData?.humidity || "--"

                            color: theme.fg1
                        }
                    }
                }
            }
        }
    }
}