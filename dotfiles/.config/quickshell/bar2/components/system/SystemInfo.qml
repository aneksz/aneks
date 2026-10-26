// components/system/SystemInfo.qml
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme

    implicitWidth: parent ? parent.width : 0
    implicitHeight: content.implicitHeight + 28
    width: parent ? parent.width : implicitWidth
    height: implicitHeight

    property string userVal: Quickshell.env("USER") || ""
    property string hostnameVal: ""
    property string uptimeVal: ""
    property string osAgeVal: ""
    property string distroVal: ""
    property string wmVal: ""

    function refresh() {
        hostnameProc.running = true
        uptimeProc.running = true
        osAgeProc.running = true
        distroProc.running = true
        wmProc.running = true
    }

    Component.onCompleted: refresh()
    onVisibleChanged: if (visible) refresh()

    // Same Loader pattern the real theme engine (bar2's theme.qml)
    // already uses to read this exact file - sidesteps the
    // pragma-Singleton import ambiguity entirely.
    Loader {
        id: paletteLoader
        source: "file:///home/igor/.config/quickshell/bar2/Colors.qml"
    }

    readonly property var paletteColors: paletteLoader.status === Loader.Ready ? [
        paletteLoader.item.color0, paletteLoader.item.color1,
        paletteLoader.item.color2, paletteLoader.item.color3,
        paletteLoader.item.color4, paletteLoader.item.color5,
        paletteLoader.item.color6, paletteLoader.item.color7
    ] : ["#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000", "#000000"]

    Process {
        id: hostnameProc
        command: ["hostname"]
        stdout: StdioCollector { onStreamFinished: root.hostnameVal = text.trim() }
    }

    Process {
        id: uptimeProc
        command: ["sh", "-c", "uptime -p | sed -E 's/up //; s/,//g; s/ hours?/hr/g; s/ minutes?/min/g; s/ days?/d/g'"]
        stdout: StdioCollector { onStreamFinished: root.uptimeVal = text.trim() }
    }

    // NOTE: reconstructed ending, since the pasted command was cut off -
    // verify this matches what you actually have
    Process {
        id: osAgeProc
        command: ["sh", "-c", "birth_install=$(stat -c %W /); current=$(date +%s); days=$(((current - birth_install) / 86400)); printf '%s days' \"$days\""]
        stdout: StdioCollector { onStreamFinished: root.osAgeVal = text.trim() }
    }

    Process {
        id: distroProc
        command: ["sh", "-c", ". /etc/os-release && echo $NAME"]
        stdout: StdioCollector { onStreamFinished: root.distroVal = text.trim() }
    }

    // NOTE: inferred from fastfetch's {pretty-name} {version} format,
    // not confirmed against your actual `hyprctl version` output
    Process {
        id: wmProc
        command: ["sh", "-c", "hyprctl version | head -n1 | awk '{print $1, $2}'"]
        stdout: StdioCollector { onStreamFinished: root.wmVal = text.trim() }
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: theme.bgAlt
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                // --------------------------------------------------
                // LOGO (fastfetch image, same masking pattern as the
                // header avatar)
                // --------------------------------------------------

                Item {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    Layout.alignment: Qt.AlignTop

                    Rectangle {
                        id: logoMask
                        anchors.fill: parent
                        radius: width / 2
                        visible: false
                    }

                    Image {
                        id: logoImage
                        anchors.fill: parent
                        source: "file:///home/igor/Downloads/images/anime-girl.png"
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                        asynchronous: true
                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: logoImage
                        maskSource: logoMask
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.width: 2
                        border.color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.35)
                    }
                }

                // --------------------------------------------------
                // FASTFETCH-STYLE INFO FIELDS
                // --------------------------------------------------

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    component InfoRow: RowLayout {
                     id: row
                     property string icon: ""
                     property string label: ""
                     property string value: ""
                     property color accent: theme.fg

                Layout.fillWidth: true
                     spacing: 8


              Item {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                Layout.alignment: Qt.AlignVCenter

              Text {
                anchors.centerIn: parent
                text: row.icon
                color: row.accent
                font { family: "JetBrainsMono Nerd Font Mono"; pixelSize: 16 }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                  }
              }

              Text {
                Layout.preferredWidth: 55
                Layout.alignment: Qt.AlignVCenter
                text: row.label
                color: theme.accent
                font { family: theme.font; pixelSize: 12 }
                }

             Text {
               Layout.fillWidth: true
               Layout.alignment: Qt.AlignVCenter
               text: row.value
               color: row.accent
               font { family: theme.font; pixelSize: 12; weight: Font.Bold }
               elide: Text.ElideRight
                  }
              }
                    InfoRow {
                        icon: "" 
                        label: "user"
                        value: root.userVal
                        accent: theme.error
                    }

                    InfoRow {
                        icon: "󰇅"
                        label: "hname"
                        value: root.hostnameVal
                        accent: theme.success
                    }

                    InfoRow {
                        icon: "󰅐"
                        label: "uptime"
                        value: root.uptimeVal
                        accent: theme.warning
                    }

                    InfoRow {
                        icon: "󱦟"
                        label: "os age"
                        value: root.osAgeVal
                        accent: theme.accent
                    }

                    InfoRow {
                        icon: "󰣇"
                        label: "distro"
                        value: root.distroVal
                        accent: theme.fg1
                    }

                    InfoRow {
                        icon: "󰍹"
                        label: "wm"
                        value: root.wmVal
                        accent: theme.fg
                    }
                }
            }

            // --------------------------------------------------
            // COLOR PALETTE SWATCHES (color0-color7 from the
            // active theme's colors.toml, rendered as circles)
            // --------------------------------------------------

            Row {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                spacing: 6

                Repeater {
                    model: root.paletteColors

                    delegate: Rectangle {
                        width: 20
                        height: 20
                        radius: width / 2
                        color: modelData
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.15)
                    }
                }
            }
        }
    }
}
