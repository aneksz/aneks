import QtQuick

Item {
    id: root

    property string name: ""
    property color color: "white"
    property int size: 18
    property string family: "Material Symbols Outlined"

    // optional hover tilt: set hovered from the button's MouseArea
    property bool hovered: false
    property real restRotation: 0
    property real hoverRotation: 0



    width: size + 2
    height: size + 2

    rotation: hovered ? hoverRotation : restRotation
    Behavior on rotation { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    Text {
        anchors.centerIn: parent
        text: root.name
        color: root.color
        font.family: root.family
        font.pixelSize: root.size
    }
}