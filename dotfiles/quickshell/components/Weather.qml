// components/Weather.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

Item {
    required property string textValue
    required property var theme

    implicitWidth: text.implicitWidth
    implicitHeight: text.implicitHeight

    Text {
        id: text
        anchors.verticalCenter: parent.verticalCenter
        text: textValue
        color: theme.accent
        font {
            family: theme.font
            pointSize: theme.fontSize
            weight: theme.fontWeight
        }
    }
}