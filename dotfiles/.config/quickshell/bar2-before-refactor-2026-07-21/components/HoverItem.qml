import QtQuick

Item {
    id: root

    required property string textValue
    required property var theme

    property color overrideColor: null
    property bool hovered: false

    property real hoverScale: 1.08
    property real iconSize: 16

    width:
        iconSize + 6

    height:
        iconSize + 6

    Text {
        anchors.centerIn:
            parent

        text:
            root.textValue

        font {
            family:
                root.theme.font
            pixelSize:
                root.iconSize
        }

        color: {
            let base =
                root.overrideColor !== null
                ? root.overrideColor
                : "#cdd6f4"

            return root.hovered
                ? root.theme.error
                : base
        }

        Behavior on color {
            ColorAnimation {
                duration:
                    120
            }
        }
    }

    scale:
        hovered
        ? hoverScale
        : 1.0

    Behavior on scale {
        NumberAnimation {
            duration:
                120

            easing.type:
                Easing.OutCubic
        }
    }
}