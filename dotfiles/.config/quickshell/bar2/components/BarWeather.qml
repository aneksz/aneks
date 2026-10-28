import QtQuick

Item {
    id: root

    // =====================================================
    // PROPERTIES
    // =====================================================

    required property var theme

    property string icon: "\ue312"
    property string temperature: "--"

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

    Text {
        id: weatherIcon
        anchors.centerIn: parent

        text: root.icon
        color: theme.accent

        font {
            family: theme.iconFont
            pixelSize: 22
        }
    }
}

        Text {
    id: weatherTemp
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 1

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