// ~/.config/quickshell/lock/LockSurface.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects

Item {
    id: root
    required property var context
    property string screenName: ""
    readonly property bool isPrimary: screenName === "DP-1"

    property string avatarPath: Quickshell.env("HOME") + "/.config/hypr/background/avatar1.png"
    property string wallpaperPath: Quickshell.env("HOME") + "/.config/hypr/background/current.png"
    property string colorsPath: Quickshell.env("HOME") + "/.config/hypr/colors.lua"
    property string font: "JetBrainsMono Nerd Font"

    // Fallback defaults — overwritten once colors.lua is parsed
    property color bg: "#2e3440"
    property color bg0: "#3b4252"
    property color fg0: "#eceff4"
    property color fg1: "#e5e9f0"
    property color mutedAccent: "#81a1c1"
    property color accent: "#81a1c1"
    property color errorColor: "#bf616a"
    property color accentAlt: "#b48ead"
    property color warn: "#ebcb8b"
    property color info: "#88c0d0"
    property color success: "#a3be8c"
    readonly property var dotPalette: [accent, accentAlt, errorColor, warn, info, success]

    property real introContent: 1   // 1 = fully shown, so the content can never get stuck hidden

    SequentialAnimation {
        running: true
        PropertyAction {
            target: root
            property: "introContent"
            value: 0
        }
        PauseAnimation {
            duration: 100
        }
        NumberAnimation {
            target: root
            property: "introContent"
            to: 1
            duration: 600
            easing.type: Easing.OutBack
        }
    }

    Process {
        id: colorsReader
        command: ["cat", root.colorsPath]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const match = line.match(/^\s*(\w+)\s*=\s*"0x[0-9a-fA-F]{2}([0-9a-fA-F]{6})"/);
                if (!match)
                    return;
                const name = match[1];
                const value = "#" + match[2];

                switch (name) {
                case "accent_alt":
                    root.accentAlt = value;
                    break;
                case "warn":
                    root.warn = value;
                    break;
                case "info":
                    root.info = value;
                    break;
                case "success":
                    root.success = value;
                    break;
                case "bg":
                    root.bg = value;
                    break;
                case "bg1":
                    root.bg0 = value;   // input field bg
                    break;
                case "fg0":
                    root.fg0 = value;
                    break;
                case "fg1":
                    root.fg1 = value;
                    break;
                case "accent":
                    root.accent = value;
                    root.mutedAccent = value;
                    break;
                case "error":
                    root.errorColor = value;
                    break;
                }
            }
        }
    }

    readonly property var activePlayer: {
        for (let i = 0; i < Mpris.players.values.length; i++) {
            const p = Mpris.players.values[i];
            if (p.desktopEntry && p.desktopEntry.toLowerCase().includes("spotify"))
                return p;
        }
        return null;
    }

    // ============================================================
    // BACKGROUND — blurred wallpaper on every monitor
    // ============================================================

    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file://" + root.wallpaperPath
        sourceSize.width: 1280
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    FastBlur {
        anchors.fill: parent
        source: wallpaper
        radius: 64
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)
    }

    // ============================================================
    // CONTENT
    // ============================================================

    Item {
        id: content
        anchors.fill: parent
        visible: root.isPrimary
        opacity: root.introContent
        transform: Translate {
            y: -220 * (1 - root.introContent)
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                const now = new Date();
                hoursText.text = now.getHours().toString().padStart(2, '0');
                minutesText.text = now.getMinutes().toString().padStart(2, '0');
                dateText.text = Qt.formatDate(now, "dddd").toUpperCase() + "     " + now.getDate() + " " + Qt.formatDate(now, "MMM").toUpperCase();
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 30

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Text {
                    id: hoursText
                    text: new Date().getHours().toString().padStart(2, '0')
                    color: root.mutedAccent
                    renderType: Text.CurveRendering
                    font {
                        family: "SF Compact Rounded"
                        pixelSize: 240
                        bold: true
                    }
                }

                Text {
                    text: ":"
                    color: root.fg0
                    font {
                        family: "SF Compact Rounded"
                        pixelSize: 240
                        bold: true
                    }
                    Layout.alignment: Qt.AlignVCenter
                    renderType: Text.CurveRendering
                    Layout.topMargin: -40
                }

                Text {
                    id: minutesText
                    text: new Date().getMinutes().toString().padStart(2, '0')
                    color: root.fg0
                    renderType: Text.CurveRendering
                    font {
                        family: "SF Compact Rounded"
                        pixelSize: 240
                        bold: true
                    }
                }
            }

            Text {
                id: dateText
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(new Date(), "dddd").toUpperCase() + "  •  " + new Date().getDate() + " " + Qt.formatDate(new Date(), "MMM").toUpperCase()
                color: root.fg1
                font {
                    family: "SF Compact Rounded"
                    pixelSize: 16
                    bold: true
                }
            }

            Item {
                id: avatarWrapper
                Layout.alignment: Qt.AlignHCenter
                width: 220
                height: 220

                Rectangle {
                    id: avatarMaskShape
                    anchors.fill: parent
                    radius: width / 2
                    visible: false
                }

                Image {
                    id: avatarImg
                    anchors.fill: parent
                    source: "file://" + root.avatarPath
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                }

                OpacityMask {
                    anchors.fill: parent
                    source: avatarImg
                    maskSource: avatarMaskShape
                }

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: root.accent
                }
            }

            Row {
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: "hi,  "
                    color: root.fg1
                    font {
                        family: "SF Compact Rounded"
                        pixelSize: 24
                        bold: true
                    }
                }
                Text {
                    text: Quickshell.env("USER")
                    color: root.mutedAccent
                    font {
                        family: "SF Compact Rounded"
                        pixelSize: 24
                        bold: true
                    }
                }
            }

            Rectangle {
                id: inputField
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
                width: 260
                height: 56
                radius: 28
                opacity: passwordInput.text.length > 0 || root.context.showFailure ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                }
                color: root.bg
                border.width: 2
                border.color: root.context.showFailure ? root.errorColor : Qt.rgba(1, 1, 1, 0.15)

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "󰌾"
                        color: root.fg1
                        font {
                            family: root.font
                            pixelSize: 16
                        }
                    }

                    TextInput {
                        id: passwordInput
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: "transparent"
                        cursorVisible: false
                        font {
                            family: root.font
                            pixelSize: 15
                        }
                        echoMode: TextInput.Password
                        enabled: !root.context.unlockInProgress
                        focus: true

                        onTextChanged: {
                            root.context.currentText = text;
                            while (dotModel.count < text.length) {
                                const p = root.dotPalette;
                                dotModel.append({
                                    c: p[Math.floor(Math.random() * p.length)].toString()
                                });
                            }
                            while (dotModel.count > text.length)
                                dotModel.remove(dotModel.count - 1);
                        }
                        ListModel {
                            id: dotModel
                        }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            clip: true
                            spacing: 6

                            Repeater {
                                model: dotModel
                                Text {
                                    required property string c
                                    text: "●"
                                    color: c
                                    font {
                                        family: root.font
                                        pixelSize: 14
                                    }
                                }
                            }
                        }
                        onAccepted: root.context.tryUnlock()

                        Connections {
                            target: root.context
                            function onCurrentTextChanged() {
                                passwordInput.text = root.context.currentText;
                            }
                        }

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: passwordInput.text.length === 0
                            text: "Enter your password"
                            color: root.fg1
                            font {
                                family: root.font
                                pixelSize: 14
                            }
                        }
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: Qt.rgba(1, 1, 1, 0.08)

                        Text {
                            anchors.centerIn: parent
                            text: "→"
                            color: root.fg0
                            font {
                                family: root.font
                                pixelSize: 16
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.context.tryUnlock()
                        }
                    }
                }
            }
        }

        // Spotify controls + track, pinned to the bottom centre
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 48
            spacing: 16
            visible: root.activePlayer !== null

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 46

                Text {
                    text: "󰙣"
                    color: root.accent
                    font {
                        family: root.font
                        pixelSize: 30
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.activePlayer?.previous()
                    }
                }
                Text {
                    text: root.activePlayer?.isPlaying ? "" : ""
                    color: root.accent
                    font {
                        family: root.font
                        pixelSize: 36
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.activePlayer?.togglePlaying()
                    }
                }
                Text {
                    text: "󰙡"
                    color: root.accent
                    font {
                        family: root.font
                        pixelSize: 30
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.activePlayer?.next()
                    }
                }
            }

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Text {
                    text: "󰓇"
                    color: root.fg0
                    font {
                        family: root.font
                        pixelSize: 16
                    }
                }
                Text {
                    Layout.maximumWidth: 280
                    elide: Text.ElideRight
                    text: (root.activePlayer?.trackArtist || "Unknown Artist") + " - " + (root.activePlayer?.trackTitle || "Unknown Title")
                    color: root.fg1
                    font {
                        family: root.font
                        pixelSize: 16
                        bold: true
                    }
                }
            }
        }

        Component.onCompleted: passwordInput.forceActiveFocus()
    }
}
