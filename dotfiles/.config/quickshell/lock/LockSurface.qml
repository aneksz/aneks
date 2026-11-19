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
    property string colorsPath: Quickshell.env("HOME") + "/.config/hypr/colors.conf"
    property string font: "JetBrainsMono Nerd Font"

    // Fallback defaults — overwritten once colors.conf is parsed
    property color bg0: "#3b4252"
    property color fg0: "#eceff4"
    property color fg1: "#e5e9f0"
    property color mutedAccent: "#81a1c1"
    property color accent: "#81a1c1"
    property color errorColor: "#bf616a"

    property real introContent: 1   // 1 = fully shown, so the content can never get stuck hidden

    SequentialAnimation {
    running: true
    PropertyAction { target: root; property: "introContent"; value: 0 }
    PauseAnimation { duration: 100 }
    NumberAnimation { target: root; property: "introContent"; to: 1; duration: 600; easing.type: Easing.OutBack }
}

    // ============================================================
    // THEME: parse colors.conf ($name = rgb(RRGGBB) format)
    // ============================================================

    function toQtColor(raw) {
        raw = raw.trim().replace(/#.*$/, "").replace(/;$/, "").trim()

        // Matches Hyprland-sttayle: rgb(2e3440) or rgba(2e3440ff)
        const packedMatch = raw.match(/rgba?\(\s*([0-9a-fA-F]{6,8})\s*\)/i)
        if (packedMatch) {
            return "#" + packedMatch[1]
        }

        // Matches standard comma-separated: rgb(46, 52, 64) or rgba(46,52,64,0.5)
        const csvMatch = raw.match(/rgba?\(\s*([\d.]+)[,\s]+([\d.]+)[,\s]+([\d.]+)(?:[,\s]+([\d.]+))?\s*\)/i)
        if (csvMatch) {
            const r = parseFloat(csvMatch[1]) / (csvMatch[1] > 1 ? 255 : 1)
            const g = parseFloat(csvMatch[2]) / (csvMatch[2] > 1 ? 255 : 1)
            const b = parseFloat(csvMatch[3]) / (csvMatch[3] > 1 ? 255 : 1)
            const a = csvMatch[4] !== undefined ? parseFloat(csvMatch[4]) : 1.0
            return Qt.rgba(r, g, b, a)
        }

        // Plain hex, with or without '#'
        const hex = raw.replace(/^#/, "")
        if (/^[0-9a-fA-F]{6}$/.test(hex) || /^[0-9a-fA-F]{8}$/.test(hex)) {
            return "#" + hex
        }

        return raw
    }

    Process {
        id: colorsReader
        command: ["cat", root.colorsPath]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const match = line.match(/^\s*\$(\w+)\s*=\s*(.+)$/)
                if (!match) return

                const name = match[1]
                const value = root.toQtColor(match[2])

                switch (name) {
                    case "bg1": root.bg0 = value; break   // input field bg — bg1 reads closer to Nord's field tone than bg0
                    case "fg0": root.fg0 = value; break
                    case "fg1": root.fg1 = value; break
                    case "accent": root.accent = value; root.mutedAccent = value; break
                    case "error": root.errorColor = value; break
                }
            }
        }
    }

    readonly property var activePlayer: {
    for (let i = 0; i < Mpris.players.values.length; i++) {
        const p = Mpris.players.values[i]
        if (p.desktopEntry && p.desktopEntry.toLowerCase().includes("spotify")) return p
    }
    return null
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
        transform: Translate { y: -220 * (1 - root.introContent) }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                const now = new Date()
                hoursText.text = now.getHours().toString().padStart(2, '0')
                minutesText.text = now.getMinutes().toString().padStart(2, '0')
                dateText.text = Qt.formatDate(now, "dddd").toUpperCase() + "    " +
                                 now.getDate() + " " + Qt.formatDate(now, "MMM").toUpperCase()
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 30

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

            

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Text {
                    id: hoursText
                    text: new Date().getHours().toString().padStart(2, '0')
                    color: root.mutedAccent
                    font { family: "SF Compact Rounded"; pixelSize: 140; bold: true }
                }

                Text {
                    id: minutesText
                    text: new Date().getMinutes().toString().padStart(2, '0')
                    color: root.fg0
                    font { family: "SF Compact Rounded"; pixelSize: 140; bold: true }
                }
            }

            Text {
                id: dateText
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(new Date(), "dddd").toUpperCase() + "  •  " +
                      new Date().getDate() + " " + Qt.formatDate(new Date(), "MMM").toUpperCase()
                color: root.fg1
                font { family: "SF Compact Rounded"; pixelSize: 16; bold: true }
            }

            Rectangle {
                id: inputField
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
                width: 260
                height: 56
                radius: 28
                color: root.bg0
                border.width: 2
                border.color: root.context.showFailure ? root.errorColor : Qt.rgba(1, 1, 1, 0.15)

                Behavior on border.color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "󰌾"
                        color: root.fg1
                        font { family: root.font; pixelSize: 16 }
                    }

                    TextInput {
                        id: passwordInput
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: root.fg0
                        font { family: root.font; pixelSize: 15 }
                        echoMode: TextInput.Password
                        enabled: !root.context.unlockInProgress
                        focus: true

                        onTextChanged: root.context.currentText = this.text
                        onAccepted: root.context.tryUnlock()

                        Connections {
                            target: root.context
                            function onCurrentTextChanged() {
                                passwordInput.text = root.context.currentText
                            }
                        }

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: passwordInput.text.length === 0
                            text: "Enter your password"
                            color: root.fg1
                            font { family: root.font; pixelSize: 14 }
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
                            font { family: root.font; pixelSize: 16 }
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
            font { family: root.font; pixelSize: 30 }
            MouseArea { anchors.fill: parent; onClicked: root.activePlayer?.previous() }
        }
        Text {
            text: root.activePlayer?.isPlaying ? "" : ""
            color: root.accent
            font { family: root.font; pixelSize: 36 }
            MouseArea { anchors.fill: parent; onClicked: root.activePlayer?.togglePlaying() }
        }
        Text {
            text: "󰙡"
            color: root.accent
            font { family: root.font; pixelSize: 30 }
            MouseArea { anchors.fill: parent; onClicked: root.activePlayer?.next() }
        }
    }

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        Text {
            text: "󰓇"
            color: root.fg0
            font { family: root.font; pixelSize: 16 }
        }
        Text {
            Layout.maximumWidth: 280
            elide: Text.ElideRight
            text: (root.activePlayer?.trackArtist || "Unknown Artist") + " - " + (root.activePlayer?.trackTitle || "Unknown Title")
            color: root.fg1
            font { family: root.font; pixelSize: 16; bold: true }
        }
    }
}

        Component.onCompleted: passwordInput.forceActiveFocus()
    }
}