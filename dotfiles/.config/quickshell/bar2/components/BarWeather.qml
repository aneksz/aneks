import QtQuick


Item {
    id: root

    // =====================================================
    // PROPERTIES
    // =====================================================

    required property var theme

    property string icon: "\ue312"
    property string temperature: "--"
    
    // Nerd Font weather glyph (from the weather script) -> Material Symbols name
readonly property var materialNames: ({
    "\ue30d": "clear_day",             // clear, day
    "\ue32b": "clear_night",           // clear, night
    "\ue30c": "partly_cloudy_day",     // mainly clear, day
    "\ue37e": "partly_cloudy_night",   // mainly clear, night
    "\ue302": "partly_cloudy_day",     // partly cloudy, day
    "\ue32e": "partly_cloudy_night",   // partly cloudy, night
    "\ue312": "cloud",                 // overcast
    "\ue313": "foggy",                 // fog
    "\ue31b": "rainy_light",           // drizzle
    "\ue318": "rainy",                 // rain
    "\ue319": "rainy_heavy",           // showers
    "\ue31a": "weather_snowy",         // snow
    "\ue31d": "thunderstorm"           // thunderstorm
})
readonly property string materialName: materialNames[root.icon] ?? "cloud"
    signal clicked()

    // =====================================================
    // SIZE
    // =====================================================

    implicitWidth: weatherRow.implicitWidth + 4
    implicitHeight: weatherRow.implicitHeight

    // =====================================================
    // WEATHER DISPLAY
    // =====================================================

    Row {
        id: weatherRow

        anchors.centerIn: parent
        spacing: 5

       Item {
    id: iconBox
    width: 28
    height: 28
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 2

    Icon {
    anchors.centerIn: parent
    name: root.materialName
    size: 20
    color: theme.accent
}
}

        Text {
    id: weatherTemp
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 2

    text: root.temperature + "°C"
    color: theme.accent

    font {
        family: theme.font
        pointSize: theme.fontSize
        weight: theme.fontWeight
    }
}
    }

    // =====================================================
    // CLICK
    // =====================================================

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}