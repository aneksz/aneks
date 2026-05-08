import QtQuick

Item {
    id: root

    required property string textValue
    required property var theme
    property color overrideColor: null
    property bool hovered

    property real hoverScale: 1.08

    width: 30
    height: 30

    Text {
        anchors.centerIn: parent
        text: root.textValue

        font.family: theme.font
        font.pointSize: theme.fontSize

        color: {
            let base = root.overrideColor !== null
                ? root.overrideColor
                : "#cdd6f4"

           color: {
    let base = root.overrideColor !== null
        ? root.overrideColor
        : "#cdd6f4"

    return root.hovered
        ? theme.error
        : base
}
        }

        Behavior on color {
            ColorAnimation { duration: 120 }
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