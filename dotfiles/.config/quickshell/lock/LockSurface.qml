// ~/.config/quickshell/lock/LockSurface.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Item {
    id: root
    required property var context
    property string screenName: ""
    readonly property bool isPrimary: screenName === "DP-1"

    property string avatarPath: Quickshell.env("HOME") + "/.config/hypr/background/avatar2.png"
    property string wallpaperPath: Quickshell.env("HOME") + "/.config/hypr/background/current.png"
    property string colorsPath: Quickshell.env("HOME") + "/.config/hypr/colors.lua"
    property string font: "JetBrainsMono Nerd Font"

    // Fallback defaults — overwritten once colors.lua is parsed
    property color bg: "#2e3440"
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

    property real introContent: 1 // 1 = fully shown, so the content can never get stuck hidden

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

    function pad2(n) {
        return n.toString().padStart(2, '0');
    }

    // same format for the first frame and every timer tick
    function dateString(d) {
        return Qt.formatDate(d, "dddd").toUpperCase() + "    " + d.getDate() + " " + Qt.formatDate(d, "MMM").toUpperCase();
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
                hoursText.text = root.pad2(now.getHours());
                minutesText.text = root.pad2(now.getMinutes());
                dateText.text = root.dateString(now);
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
                    text: root.pad2(new Date().getHours())
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
                    renderType: Text.CurveRendering
                    Layout.alignment: Qt.AlignVCenter
                    Layout.topMargin: -40 // colon sits low next to the digits
                    font {
                        family: "SF Compact Rounded"
                        pixelSize: 240
                        bold: true
                    }
                }

                Text {
                    id: minutesText
                    text: root.pad2(new Date().getMinutes())
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
                text: root.dateString(new Date())
                color: root.fg1
                font {
                    family: "SF Compact Rounded"
                    pixelSize: 18
                    bold: true
                }
            }

            Item {
                id: avatarWrapper
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 260
                Layout.preferredHeight: 260

                readonly property int inset: 2

                Image {
                    id: avatarImg
                    anchors.fill: parent
                    source: "file://" + root.avatarPath
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(width * 2, height * 2)
                    mipmap: true
                    smooth: true
                    visible: false
                }

                Item {
                    id: avatarMask
                    anchors.fill: parent
                    layer.enabled: true
                    layer.smooth: true
                    visible: false

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: avatarWrapper.inset
                        radius: width / 2
                        antialiasing: true
                    }
                }

                MultiEffect {
                    anchors.fill: parent
                    source: avatarImg
                    maskEnabled: true
                    maskSource: avatarMask
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: avatarWrapper.inset - 2
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: root.accent
                    antialiasing: true
                }
            }

            Row {
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: "hi, "
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

            // Fixed-size slot: the column never re-lays out while the field animates,
            // the field grows inside it, centred.
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
                Layout.preferredWidth: inputField.maxWidth
                Layout.preferredHeight: inputField.height

                Rectangle {
                    id: inputField
                    anchors.centerIn: parent

                    readonly property int maxWidth: 420
                    readonly property int padding: 20
                    readonly property int dotSize: 10
                    readonly property int dotGap: 8
                    readonly property int dotStep: dotSize + dotGap
                    readonly property real dotsWidth: Math.max(0, dotModel.count * dotStep - dotGap)
                    readonly property bool showHint: passwordInput.text.length === 0 && root.context.showFailure

                    // Where the width wants to be; animWidth follows it at a steady speed,
                    // so fast typing doesn't restart the animation in jerks.
                    readonly property real targetWidth: {
                        const inner = showHint ? hint.implicitWidth : dotsWidth;
                        return Math.min(maxWidth, Math.max(height, inner + padding * 2));
                    }
                    property real animWidth: targetWidth
                    Behavior on animWidth {
                        SmoothedAnimation {
                            velocity: 260
                        }
                    }

                    width: animWidth
                    height: 48
                    radius: height / 2
                    color: root.bg
                    border.width: 2
                    border.color: root.context.showFailure ? root.errorColor : Qt.rgba(1, 1, 1, 0.15)
                    opacity: passwordInput.text.length > 0 || root.context.showFailure ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    // macOS-style shake on a wrong password: quick left-right wobble that dies down
                    transform: Translate {
                        id: shakeShift
                    }

                    SequentialAnimation {
                        id: shake
                        NumberAnimation {
                            target: shakeShift
                            property: "x"
                            to: -14
                            duration: 50
                            easing.type: Easing.OutQuad
                        }
                        NumberAnimation {
                            target: shakeShift
                            property: "x"
                            to: 12
                            duration: 70
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: shakeShift
                            property: "x"
                            to: -8
                            duration: 60
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: shakeShift
                            property: "x"
                            to: 5
                            duration: 50
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: shakeShift
                            property: "x"
                            to: 0
                            duration: 40
                            easing.type: Easing.InQuad
                        }
                    }

                    Connections {
                        target: root.context
                        function onShowFailureChanged() {
                            if (root.context.showFailure) {
                                shakeShift.x = 0;
                                shake.restart();
                            }
                        }
                    }

                    // Receives the keystrokes; its own text is invisible, the dots below show it
                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        color: "transparent"
                        cursorDelegate: Item {}
                        echoMode: TextInput.Password
                        enabled: !root.context.unlockInProgress
                        focus: true

                        onTextChanged: {
                            root.context.currentText = text;
                            // one dot per character, each with a random theme colour that stays put
                            while (dotModel.count < text.length) {
                                const p = root.dotPalette;
                                dotModel.append({
                                    c: p[Math.floor(Math.random() * p.length)].toString()
                                });
                            }
                            while (dotModel.count > text.length)
                                dotModel.remove(dotModel.count - 1);
                        }
                        onAccepted: root.context.tryUnlock()

                        Connections {
                            target: root.context
                            function onCurrentTextChanged() {
                                passwordInput.text = root.context.currentText;
                            }
                        }
                    }

                    ListModel {
                        id: dotModel
                    }

                    // Dots sit a fixed distance from the field's left edge, so they ride along
                    // with the growing edge; the newest dot is revealed as the field widens.
                    Item {
                        id: dots
                        anchors.fill: parent
                        clip: true

                        // past maxWidth, shift left so the newest dots stay visible
                        readonly property real startX: Math.min(inputField.padding, inputField.maxWidth - inputField.padding - inputField.dotsWidth)

                        Repeater {
                            model: dotModel

                            Rectangle {
                                required property string c
                                required property int index

                                x: dots.startX + index * inputField.dotStep
                                anchors.verticalCenter: parent.verticalCenter
                                width: inputField.dotSize
                                height: width
                                radius: width / 2
                                color: c

                                NumberAnimation on scale {
                                    from: 0
                                    to: 1
                                    duration: 220
                                    easing.type: Easing.OutBack
                                }
                                NumberAnimation on opacity {
                                    from: 0
                                    to: 1
                                    duration: 160
                                }
                            }
                        }
                    }

                    // shown after a failed attempt, once the field is empty again
                    Text {
                        id: hint
                        anchors.centerIn: parent
                        visible: inputField.showHint
                        text: "Wrong password, try again"
                        color: root.fg1
                        font {
                            family: root.font
                            pixelSize: 14
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
                        cursorShape: Qt.PointingHandCursor
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
                        cursorShape: Qt.PointingHandCursor
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
                        cursorShape: Qt.PointingHandCursor
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
