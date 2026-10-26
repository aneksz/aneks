import QtQuick

Item {
    id: root

    required property string textValue
    required property var theme

    property color overrideColor: null
    property bool hovered

    property real hoverScale: 1.08
    property real iconSize: theme.fontSize

    width: iconSize + 6
    height: iconSize + 6

    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 1

        text: root.textValue

        font.family: theme.font
        font.pointSize: root.iconSize

        color: {
            let base = root.overrideColor !== null
                ? root.overrideColor
                : "#cdd6f4"

            return root.hovered
                ? theme.error
                : base
        }

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    // ===== SCALE EFFECT =====
    scale: hovered ? hoverScale : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }
}