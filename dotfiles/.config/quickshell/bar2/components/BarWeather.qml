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

        Text {
            id: weatherIcon
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1
            text: root.icon

            color: theme.accent

            font {
                family: theme.font
                pixelSize: 20
            }
          y: 0
        }

        Text {
            id: weatherTemp

            text: root.temperature + "°C"

            color: theme.accent

            font {
                family: theme.font
                pixelSize: 16
                weight: theme.fontWeight
            }

            y: 3
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