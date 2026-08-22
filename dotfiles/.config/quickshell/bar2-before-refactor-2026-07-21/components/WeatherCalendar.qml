// components/WeatherCalendar.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
id: root

// =====================================================
// API FROM SHELL
// =====================================================

property var theme
property var weatherData
property int displayMonth: new Date().getMonth()
property int displayYear: new Date().getFullYear()
property int selectedDay: -1
property int selectedMonth: -1
property int selectedYear: -1


// =====================================================
// CALENDAR NAVIGATION
// =====================================================

function previousMonth() {
    if (root.displayMonth === 0) {
        root.displayMonth = 11
        root.displayYear--
    } else {
        root.displayMonth--
    }
}

function nextMonth() {
    if (root.displayMonth === 11) {
        root.displayMonth = 0
        root.displayYear++
    } else {
        root.displayMonth++
    }
}


// =====================================================
// BACKGROUND PANEL
// =====================================================

Rectangle {
    id: background

    anchors {
        fill: parent
        margins: 12
    }

    radius: 16

    color: theme.bg

    border {
        width: 1
        color: theme.surface
    }


    // =================================================
    // MAIN CONTENT
    // =================================================

    RowLayout {
        anchors {
            fill: parent
            margins: 20
        }

        spacing: 20


// =================================================
// CALENDAR SECTION
// =================================================

ColumnLayout {
    id: calendarSection

    Layout.preferredWidth: 240
    Layout.minimumWidth: 240
    Layout.maximumWidth: 240
    Layout.fillHeight: true

    spacing: 14


    // =================================================
    // MONTH HEADER
    // =================================================

    RowLayout {
        Layout.alignment: Qt.AlignHCenter

        Layout.preferredWidth: 220
        Layout.minimumWidth: 220
        Layout.maximumWidth: 220

        Layout.preferredHeight: 36

        spacing: 8


// ---------------------------------------------
// PREVIOUS MONTH
// ---------------------------------------------

Rectangle {
    Layout.preferredWidth: 32
    Layout.preferredHeight: 32

    radius: width / 2

    color:
        previousMonthMouse.containsMouse
        ? theme.surfaceAlt
        : theme.surface


    Text {
        anchors.centerIn: parent

        text: ""

        color: theme.fg

        font {
            family: theme.font
            pixelSize: 14
        }
    }


    MouseArea {
        id: previousMonthMouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor


        onClicked: {
            root.previousMonth()
        }
    }
}


        // ---------------------------------------------
        // MONTH / YEAR
        // ---------------------------------------------

        Text {
            Layout.fillWidth: true

            Layout.preferredHeight: 32

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            text: Qt.formatDate(
                new Date(
                    root.displayYear,
                    root.displayMonth,
                    1
                ),
                "MMMM yyyy"
            )

            color: theme.accent

            font {
                family: theme.font
                pixelSize: 14
                bold: true
            }
        }


// ---------------------------------------------
// NEXT MONTH
// ---------------------------------------------

Rectangle {
    Layout.preferredWidth: 32
    Layout.preferredHeight: 32

    radius: width / 2

    color:
        nextMonthMouse.containsMouse
        ? theme.surfaceAlt
        : theme.surface


    Text {
        anchors.centerIn: parent

        text: ""

        color: theme.fg

        font {
            family: theme.font
            pixelSize: 14
        }
    }


    MouseArea {
        id: nextMonthMouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape:
            Qt.PointingHandCursor


        onClicked: {
            root.nextMonth()
        }
    }
}
    }


// =================================================
// CALENDAR GRID
// =================================================

MonthGrid {
    id: calendarGrid

    Layout.alignment:
        Qt.AlignHCenter

    Layout.preferredWidth:
        220

    Layout.preferredHeight:
        190


    month:
        root.displayMonth


    year:
        root.displayYear


    locale:
        Qt.locale("en_US")


    // ---------------------------------------------
    // CALENDAR DAY DELEGATE
    // ---------------------------------------------

    delegate:
        Rectangle {

            implicitWidth:
                30


            implicitHeight:
                30


            radius:
                8


            property bool isSelected:
                model.day === root.selectedDay &&
                model.month === root.selectedMonth &&
                model.year === root.selectedYear


            color:
                isSelected
                ? theme.accent
                : model.today
                ? theme.accent
                : dateMouse.containsMouse
                ? theme.surfaceAlt
                : "transparent"


            Text {
                anchors.centerIn:
                    parent


                text:
                    model.day


                color:
                    isSelected
                    ? theme.bg
                    : model.today
                    ? theme.bg
                    : model.month === calendarGrid.month
                    ? theme.fg
                    : theme.inactive


                font {
                    family:
                        theme.font

                    pixelSize:
                        12
                }
            }


            MouseArea {
                id:
                    dateMouse


                anchors.fill:
                    parent


                hoverEnabled:
                    true


                cursorShape:
                    Qt.PointingHandCursor


                onClicked: {

                    root.selectedDay =
                        model.day


                    root.selectedMonth =
                        model.month


                    root.selectedYear =
                        model.year

                }
            }
        }
   }
}
        // =================================================
        // DIVIDER
        // =================================================

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true

            color: theme.surface
            opacity: 0.5
        }


        // =================================================
// WEATHER SECTION
// =================================================

ColumnLayout {

    Layout.fillWidth: true
    Layout.fillHeight: true

    spacing: 12

 // =============================================
    // SUNRISE / SUNSET
    // =============================================

    RowLayout {

        Layout.fillWidth: true

        spacing: 8


        Rectangle {

            Layout.fillWidth: true

            Layout.preferredHeight: 48

            radius: 10

            color: theme.surface


            Row {

                anchors.centerIn: parent

                spacing: 8


                Text {
                    text: ""

                    color: theme.accent

                    font.family: theme.font
                    font.pixelSize: 14
                }


                Column {

                    spacing: 1


                    Text {
                        text: "Sunrise"

                        color: theme.inactive

                        font.family: theme.font
                        font.pixelSize: 9
                    }


                    Text {
                        text: weatherData
                              ? weatherData.sunrise
                              : "--"

                        color: theme.fg

                        font.family: theme.font
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }
        }


        Rectangle {

            Layout.fillWidth: true

            Layout.preferredHeight: 48

            radius: 10

            color: theme.surface


            Row {

                anchors.centerIn: parent

                spacing: 8


                Text {
                    text: ""

                    color: theme.accent

                    font.family: theme.font
                    font.pixelSize: 14
                }


                Column {

                    spacing: 1


                    Text {
                        text: "Sunset"

                        color: theme.inactive

                        font.family: theme.font
                        font.pixelSize: 9
                    }


                    Text {
                        text: weatherData
                              ? weatherData.sunset
                              : "--"

                        color: theme.fg

                        font.family: theme.font
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }
        }
    }
   

    // =============================================
    // CURRENT WEATHER
    // =============================================

    Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 130
    Layout.maximumHeight: 130

    radius: 14
    color: theme.surface

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16

        spacing: 14

        // =============================================
        // WEATHER ICON
        // =============================================

        Text {
            Layout.alignment: Qt.AlignVCenter

            text: weatherData
                  ? weatherData.icon
                  : "☁"

            font.pixelSize: 46
        }

        // =============================================
        // TEMPERATURE + DESCRIPTION
        // =============================================

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            spacing: 2

            Text {
                Layout.fillWidth: true

                text: weatherData
                      ? weatherData.temp + "°C"
                      : "--°C"

                color: theme.fg

                font {
                    family: theme.font
                    pixelSize: 34
                    bold: true
                }
            }

            Text {
                Layout.fillWidth: true

                text: weatherData
                      ? weatherData.desc
                      : "Loading..."

                color: theme.inactive

                font {
                    family: theme.font
                    pixelSize: 12
                }
            }
        }
    }
}
    // =============================================
// WEATHER STATS
// =============================================

RowLayout {
    Layout.fillWidth: true
    spacing: 10

    Repeater {
        model: [
            {
                icon: "",
                title: "Humidity",
                value: weatherData
                       ? weatherData.humidity
                       : "--"
            },

            {
                icon: "",
                title: "Feels Like",
                value: weatherData
                       ? weatherData.feels
                       : "--"
            },

            {
                icon: "",
                title: "Wind",
                value: weatherData
                       ? weatherData.wind
                       : "--"
            }
        ]

        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 1

            radius: 14

            color:
                theme.surface

            border {
                width: 1
                color:
                    Qt.rgba(
                        1,
                        1,
                        1,
                        0.05
                    )
            }

            implicitHeight:
                contentRow.implicitHeight +
                16

            Row {
                id:
                    contentRow

                anchors.centerIn:
                    parent

                spacing:
                    8

                Text {
                    text:
                        modelData.icon

                    color:
                        theme.accent

                    font {
                        family:
                            theme.font

                        pixelSize:
                            14
                    }

                    anchors.verticalCenter:
                        parent.verticalCenter
                }

                Column {
                    spacing:
                        2

                    Text {
                        text:
                            modelData.title

                        color:
                            theme.inactive

                        font {
                            family:
                                theme.font

                            pixelSize:
                                11
                        }
                    }

                    Text {
                        text:
                            modelData.value ||
                            "--"

                        color:
                            theme.fg

                        font {
                            family:
                                theme.font

                            pixelSize:
                                11

                            bold:
                                true
                        }
                    }
                }
            }
        }
    }
}


   
    // =============================================
    // 7-DAY FORECAST HEADER
    // =============================================

    Text {

        text: "7-Day Forecast"

        color: theme.fg

        font {
            family: theme.font
            pixelSize: 11
            bold: true
        }
    }


    // =============================================
    // FORECAST ROW
    // =============================================

    RowLayout {
    Layout.fillWidth: true
    Layout.preferredHeight: 92
    Layout.maximumHeight: 92
    spacing: 6

        Repeater {

            model: weatherData
                   ? weatherData.forecast
                   : []


            delegate: Rectangle {

                Layout.fillWidth: true

                Layout.fillHeight: true

                radius: 10

                color: theme.surface


                Column {

                    anchors.centerIn: parent

                    spacing: 4


                    Text {

                        anchors.horizontalCenter: parent.horizontalCenter

                        text: modelData.day

                        color: modelData.day === "Today"
                               ? theme.accent
                               : theme.inactive

                        font {
                            family: theme.font
                            pixelSize: 9
                            bold: true
                        }
                    }


                    Text {

                        anchors.horizontalCenter: parent.horizontalCenter

                        text: modelData.icon

                        font.pixelSize: 18
                    }


                    Text {

                        anchors.horizontalCenter: parent.horizontalCenter

                        text: modelData.temp + "°"

                        color: theme.fg

                        font {
                            family: theme.font
                            pixelSize: 10
                            bold: true
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
