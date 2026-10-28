import QtQuick

Item {
    id: root

    property string name: ""
    property color color: "white"
    property int size: 18
    property string family: "Material Symbols Outlined"

    width: size + 2
    height: size + 2

    Text {
        anchors.centerIn: parent
        text: root.name
        color: root.color
        font.family: root.family
        font.pixelSize: root.size
    }
}
