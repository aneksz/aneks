import QtQuick

Item {
    id: root

    required property string textValue
    required property var theme

    property color overrideColor: null
    property bool hovered: false

    property real hoverScale: 1.08
    property real iconSize: 16
    property real textSize: iconSize
    property real spacing: 4

    // Width of icon + label, for parents that size themselves to the content
    readonly property real contentWidth: row.implicitWidth

    // -------------------------------------------------
    // Split "<glyph> <label>" into icon + label.
    // Nerd Font glyphs live in the Private Use Areas (U+E000 and up).
    // -------------------------------------------------

    readonly property bool hasIcon: {
        const cp = textValue.codePointAt(0)
        return cp !== undefined && cp >= 0xE000
    }

    readonly property string iconPart:
        hasIcon ? String.fromCodePoint(textValue.codePointAt(0)) : ""

    readonly property string labelPart:
        hasIcon ? textValue.slice(iconPart.length).trim() : textValue

    readonly property color currentColor: {
        const base = overrideColor !== null ? overrideColor : "#cdd6f4"
        return hovered ? theme.error : base
    }

    width: iconSize + 6
    height: iconSize + 6

    Row {
        id: row
        anchors.centerIn: parent
        spacing: root.iconPart !== "" && root.labelPart !== "" ? root.spacing : 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.iconPart !== ""
            text: root.iconPart
            color: root.currentColor
            font {
                family: root.theme.iconFont ?? root.theme.font
                pixelSize: root.iconSize
            }
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.labelPart !== ""
            text: root.labelPart
            color: root.currentColor
            font {
                family: root.theme.font
                pixelSize: root.textSize
            }
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }

    scale: hovered ? hoverScale : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }
}