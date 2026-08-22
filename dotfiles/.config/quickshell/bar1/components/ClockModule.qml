// components/ClockModule.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    width: clock.implicitWidth + 10
    height: 30
    anchors.verticalCenter: parent.verticalCenter

    // Properties passed from shell.qml
    required property var theme
    required property var weatherData

    property bool calendarVisible: false
    property int displayMonth: new Date().getMonth()
    property int displayYear: new Date().getFullYear()

    property int animDirection: 1
    property bool animating: false

    property int animDur: 220
    property int animOffset: 12
    property bool calendarOpen: false

    onCalendarVisibleChanged: {
    if (calendarVisible)
        calendarOpen = true
    else
        Qt.callLater(() => calendarOpen = false)
}

    // ===== CLOCK =====
    Text {
        id: clock
        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "dd MMM HH:mm")
        color: theme.fg1

        font.family: theme.font
        font.pointSize: theme.fontSize
        font.weight: theme.fontWeight

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatDateTime(new Date(), "dd MMM HH:mm")
        }
    }

    // ===== CLICK TO TOGGLE POPUP =====
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.displayMonth = new Date().getMonth()
            root.displayYear = new Date().getFullYear()
            root.calendarVisible = !root.calendarVisible
        }
    }

    // ===== POPUP - Calendar + Weather =====
    PopupWindow {
        id: calendarPopup
        visible: root.calendarOpen || calendarContent.opacity > 0

        color: "transparent"
        mask: null
        grabFocus: false

        onVisibleChanged: {
            if (!visible) {
                calendarContent.state = ""
                root.calendarVisible = false
            }
        }

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.margins.top: 38
        anchor.rect.x: root.mapToItem(null, 0, 0).x - (620 / 2) + (root.width / 2)

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

                // ================= ANIMATION =================
opacity: root.calendarOpen ? 1 : 0
scale: root.calendarOpen ? 1 : 0.985

transform: Translate {
    y: root.calendarOpen ? 0 : -16

    Behavior on y {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }
}

Behavior on opacity {
    NumberAnimation {
        duration: 300
    }
}

Behavior on scale {
    NumberAnimation {
        duration: 260
        easing.type: Easing.OutCubic
    }
}

                // ===== MAIN LAYOUT =====
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 20

                    // ===== CALENDAR SECTION =====
                    Column {
                        Layout.preferredWidth: 220
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 10

                        // Header
                        Row {
                            width: parent.width
                            height: 30
                            spacing: 10

                            // Previous Month
                            MouseArea {
                                id: prevMonthBtn
                                width: 30; height: 30
                                hoverEnabled: true
                                enabled: !root.animating

                                onClicked: {
                                    if (root.animating) return
                                    root.animDirection = -1
                                    root.animating = true
                                    slideOut.start()
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: prevMonthBtn.containsMouse ? theme.surfaceAlt : "transparent"
                                    border.color: prevMonthBtn.containsMouse ? theme.accent : "transparent"
                                    border.width: 1

                                    Behavior on color { ColorAnimation { duration: 120 } }
                                    Behavior on border.color { ColorAnimation { duration: 120 } }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    color: prevMonthBtn.containsMouse ? theme.accent : theme.fg
                                    font.family: theme.font
                                    font.pixelSize: theme.fontSize + 4

                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                scale: containsMouse ? 1.2 : 1.0
                                Behavior on scale {
                                    NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                                }
                            }

                            // Month Title
                            MouseArea {
                                width: parent.width - 80
                                height: 30

                                onClicked: {
                                    root.displayMonth = new Date().getMonth()
                                    root.displayYear = new Date().getFullYear()
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: new Date(root.displayYear, root.displayMonth)
                                          .toLocaleString(Qt.locale(), "MMMM yyyy")
                                    color: theme.accent
                                    font.family: theme.font
                                    font.bold: true
                                }
                            }

                            // Next Month
                            MouseArea {
                                id: nextMonthBtn
                                width: 30; height: 30
                                hoverEnabled: true
                                enabled: !root.animating

                                onClicked: {
                                    if (root.animating) return
                                    root.animDirection = 1
                                    root.animating = true
                                    slideOut.start()
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: nextMonthBtn.containsMouse ? theme.surfaceAlt : "transparent"
                                    border.color: nextMonthBtn.containsMouse ? theme.accent : "transparent"
                                    border.width: 1

                                    Behavior on color { ColorAnimation { duration: 120 } }
                                    Behavior on border.color { ColorAnimation { duration: 120 } }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    color: nextMonthBtn.containsMouse ? theme.accent : theme.fg
                                    font.family: theme.font
                                    font.pixelSize: theme.fontSize + 4

                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                scale: containsMouse ? 1.2 : 1.0
                                Behavior on scale {
                                    NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                                }
                            }
                        }

                        // Animated Calendar View
                        Item {
                            id: calendarViewport
                            width: parent.width
                            height: 200
                            clip: true

                            Item {
                                id: calendarView
                                anchors.fill: parent
                                x: 0
                                opacity: 1.0

                                Column {
                                    width: parent.width
                                    spacing: 5

                                    DayOfWeekRow {
                                        width: parent.width
                                        locale: Qt.locale("en_US")
                                        delegate: Text {
                                            text: model.shortName
                                            horizontalAlignment: Text.AlignHCenter
                                            color: theme.inactive
                                            font.pixelSize: 10
                                            font.family: theme.font
                                        }
                                    }

                                    MonthGrid {
                                        id: grid
                                        width: parent.width
                                        height: 160
                                        month: root.displayMonth
                                        year: root.displayYear

                                        property date selectedDate: new Date()
                                        onClicked: (date) => grid.selectedDate = date

                                        delegate: Rectangle {
                                            implicitWidth: 30
                                            implicitHeight: 30
                                            radius: 6

                                            color: (model.date.toDateString() === grid.selectedDate.toDateString())
                                                ? theme.accent
                                                : (model.today ? theme.surface : "transparent")

                                            Text {
                                                anchors.centerIn: parent
                                                font.family: theme.font
                                                text: model.day
                                                color: (model.date.toDateString() === grid.selectedDate.toDateString())
                                                    ? theme.bg
                                                    : (model.month === grid.month ? theme.fg : theme.inactive)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                        color: theme.surface
                        opacity: 0.5
                    }

                    // ================= WEATHER SECTION =================

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        height: 380
                        property int animDur: 220

                        // Top Right Sun Times
                        Row {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            spacing: 20
                            

                            // Sunrise
                            Row {
                                spacing: 4
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
                                        horizontalAlignment: Text.AlignLeft
                                        color: theme.inactive
                                        font.family: theme.font
                                        font.pixelSize: 11
                                    }
                                    Text {
                                        text: weatherData.sunrise || "--"
                                        width: parent.width
                                        horizontalAlignment: Text.AlignLeft
                                        color: theme.fg
                                        font.family: theme.font
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }
                            }

                            // Sunset
                            Row {
                                spacing: 8
                                Text {
                                    text: ""
                                    color: theme.accent
                                    font.pixelSize: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Column {
                                    width: 80
                                    spacing: 2
                                    Text {
                                        text: "Sunset"
                                        width: parent.width
                                        horizontalAlignment: Text.AlignLeft
                                        color: theme.inactive
                                        font.family: theme.font
                                        font.pixelSize: 11
                                    }
                                    Text {
                                        text: weatherData.sunset || "--"
                                        width: parent.width
                                        horizontalAlignment: Text.AlignLeft
                                        color: theme.fg
                                        font.pixelSize: 11
                                        font.family: theme.font
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        // Main Weather Content
                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            anchors.topMargin: 50
                            spacing: 18

                            // Current Weather
                            Rectangle {
                                width: parent.width - 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                radius: 18
                                color: theme.surface
                                border.color: Qt.rgba(1,1,1,0.05)
                                border.width: 1
                                implicitHeight: contentCol.implicitHeight + 28

                                Column {
                                    id: contentCol
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

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
                                            font.family: theme.font
                                        }
                                    }

                                    Text {
                                        text: weatherData.desc
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        color: theme.inactive
                                        font.family: theme.font
                                        font.pixelSize: 11
                                    }
                                }
                            }

                            // Stats
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

                                            Text {
                                                text: modelData.icon
                                                color: theme.accent
                                                font.family: theme.font
                                                font.pixelSize: 14
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Column {
                                                spacing: 2
                                                Text {
                                                    text: modelData.title
                                                    color: theme.inactive
                                                    font.family: theme.font
                                                    font.pixelSize: 11
                                                }
                                                Text {
                                                    text: modelData.value || "--"
                                                    color: theme.fg
                                                    font.family: theme.font
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Forecast Header
                            Text {
                                text: "7-Day Forecast"
                                color: theme.fg
                                font.family: theme.font
                                font.pixelSize: 11
                                font.bold: true
                            }

                            // Forecast
                            RowLayout {
                                width: parent.width
                                spacing: 10

                                Repeater {
                                    model: weatherData.forecast

                                    delegate: Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 1
                                        radius: 12
                                        color: theme.surface
                                        border.color: Qt.rgba(1,1,1,0.05)
                                        border.width: 1
                                        implicitHeight: forecastCol.implicitHeight + 16

                                        Column {
                                            id: forecastCol
                                            anchors.centerIn: parent
                                            width: parent.width
                                            spacing: 6

                                            Text {
                                                text: modelData.day
                                                width: parent.width
                                                horizontalAlignment: Text.AlignHCenter
                                                color: modelData.day === "Today" ? theme.accent : theme.inactive
                                                font.family: theme.font
                                                font.pixelSize: 11
                                                font.bold: true
                                            }

                                            Text {
                                                text: modelData.date || ""
                                                width: parent.width
                                                horizontalAlignment: Text.AlignHCenter
                                                color: theme.inactive
                                                font.family: theme.font
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
                                                font.family: theme.font
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

        // ===== SLIDE + FADE ANIMATIONS =====
        ParallelAnimation {
            id: slideOut
            NumberAnimation {
                target: calendarView
                property: "x"
                to: -calendarViewport.width * root.animDirection
                duration: 220
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: calendarView
                property: "opacity"
                to: 0.3
                duration: 220
                easing.type: Easing.InOutQuad
            }
            onStopped: {
                if (root.animDirection === 1) {
                    if (root.displayMonth === 11) {
                        root.displayMonth = 0
                        root.displayYear++
                    } else {
                        root.displayMonth++
                    }
                } else {
                    if (root.displayMonth === 0) {
                        root.displayMonth = 11
                        root.displayYear--
                    } else {
                        root.displayMonth--
                    }
                }

                calendarView.x = calendarViewport.width * root.animDirection
                calendarView.opacity = 0
                slideIn.start()
            }
        }

        ParallelAnimation {
            id: slideIn
            NumberAnimation {
                target: calendarView
                property: "x"
                to: 0
                duration: 280
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: calendarView
                property: "opacity"
                to: 1.0
                duration: 280
                easing.type: Easing.OutQuad
            }
            onStopped: root.animating = false
        }
    }
}