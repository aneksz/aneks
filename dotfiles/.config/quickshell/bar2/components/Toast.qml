// components/Toast.qml

import QtQuick
import Quickshell
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // ============================================================
    // API
    // ============================================================

    property var theme
    property var currentNotif
    property bool doNotDisturb: false
    property string spotifyArtUrl: ""

    signal dismiss()
    signal toastTriggered()

    // ============================================================
    // STATE
    // ============================================================

    property bool active:
        !!root.currentNotif &&
        !root.doNotDisturb

    property real progress: 0

    // ============================================================
    // SIZE
    // ============================================================

    anchors.fill: parent

    // ============================================================
    // NOTIFICATION CHANGED
    // ============================================================

    Connections {
        target: root

        function onCurrentNotifChanged() {
            if (!root.currentNotif)
                return

            if (root.doNotDisturb)
                return

            root.progress = 0
            progressAnim.restart()
            toastTimer.restart()
            root.toastTriggered()
        }
    }

    // ============================================================
    // AUTO HIDE
    // ============================================================

    Timer {
        id: toastTimer
        interval: 5000
        repeat: false
    }

    // ============================================================
    // PROGRESS ANIMATION
    // ============================================================

    NumberAnimation {
        id: progressAnim
        target: root
        property: "progress"
        from: 0
        to: 1
        duration: toastTimer.interval
        easing.type: Easing.InOutCubic
    }

    // ============================================================
    // MAIN TOAST CARD
    // ============================================================

    Rectangle {
        id: mainRect
        anchors.fill: parent
        radius: 16
        color: root.theme.bg

        opacity: root.active ? 1.0 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        // ========================================================
        // MOUSE INTERACTION
        // ========================================================

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                toastTimer.stop()
                progressAnim.stop()
            }

            onExited: {
                let remaining = toastTimer.interval * (1.0 - root.progress)

                if (remaining <= 0)
                    return

                toastTimer.interval = remaining
                toastTimer.start()

                progressAnim.from = root.progress
                progressAnim.to = 1
                progressAnim.duration = remaining
                progressAnim.start()
            }
        }

        // ========================================================
        // CLOSE BUTTON
        // ========================================================

        Text {
            id: closeButton
            text: ""
            color: root.theme.inactive
            opacity: 0.7
            z: 100

            anchors {
                top: parent.top
                right: parent.right
                topMargin: 6
                rightMargin: 8
            }

            font {
                family: root.theme.font
                pixelSize: 16
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onEntered: closeButton.opacity = 1.0
                onExited:  closeButton.opacity = 0.7

                onClicked: {
                    root.dismiss()
                    progressAnim.stop()
                }
            }
        }

        // ========================================================
        // NOTIFICATION CONTENT
        // ========================================================

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            anchors.rightMargin: 24
            spacing: 12

            // ====================================================
            // ICON CONTAINER
            // ====================================================

            Item {
                id: iconContainer

                Layout.preferredWidth: 52
                Layout.preferredHeight: 52
                Layout.alignment: Qt.AlignVCenter

                // Helper: does this notification have a real image?
                function hasRealImage() {
                    if (!root.currentNotif) return false

                    const app = String(
                        root.currentNotif.appName ||
                        root.currentNotif.app_name ||
                        root.currentNotif.desktopEntry ||
                        ""
                    ).toLowerCase()

                    // Catch theme updates early so they never evaluate as image fallbacks
                    if (isThemeUpdate()) return false

                    // Spotify with album art
                    if (app.includes("spotify") && root.spotifyArtUrl && root.spotifyArtUrl !== "")
                        return true

                    // Any other notification that actually has an icon/image
                    return !!(
                        root.currentNotif.image ||
                        root.currentNotif.appIcon ||
                        root.currentNotif.icon
                    )
                }

                // Identify if notification content came from theme engine
                function isThemeUpdate() {
                    if (!root.currentNotif) return false
                    
                    const summary = String(root.currentNotif.summary || "").toLowerCase()
                    const body = String(root.currentNotif.body || "").toLowerCase()
                    
                    return summary.includes("theme updated") || body.includes("theme updated")
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: theme.bg
                    clip: true

                    // ---------- Spotify art / app icon ----------
                    Item {
                        anchors.fill: parent
                        visible: iconContainer.hasRealImage()

                        Image {
                            id: notifIcon
                            anchors.fill: parent
                            visible: false
                            fillMode: Image.PreserveAspectCrop
                            antialiasing: true
                            cache: false
                            asynchronous: true

                            function getNotificationSource() {
                                if (!root.currentNotif)
                                    return ""

                                const app = String(
                                    root.currentNotif.appName ||
                                    root.currentNotif.app_name ||
                                    root.currentNotif.desktopEntry ||
                                    ""
                                ).toLowerCase()

                                if (app.includes("spotify") && root.spotifyArtUrl)
                                    return root.spotifyArtUrl

                                return root.currentNotif.image ||
                                       root.currentNotif.appIcon ||
                                       root.currentNotif.icon ||
                                       ""
                            }

                            source: {
                                // force re-evaluation when these change
                                var _ = root.currentNotif
                                var __ = root.spotifyArtUrl
                                return notifIcon.getNotificationSource()
                            }
                        }

                        OpacityMask {
                            anchors.fill: notifIcon
                            source: notifIcon
                            maskSource: Rectangle {
                                width: notifIcon.width
                                height: notifIcon.height
                                radius: 10
                                color: "white"
                            }
                        }
                    }

                    // ---------- Fallback Text Glyphs (Bell vs Palette) ----------
                    Text {
                        anchors.centerIn: parent
                        visible: !iconContainer.hasRealImage()
                        text: iconContainer.isThemeUpdate() ? "󰏘" : "󰂚"
                        color: root.theme.accent

                        font {
                            family: root.theme.font
                            pixelSize: 26
                        }
                    }
                }
            }


            // ====================================================
            // NOTIFICATION TEXT
            // ====================================================

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.currentNotif ? root.currentNotif.summary : ""
                    color: root.theme.fg1
                    elide: Text.ElideRight

                    font {
                        family: root.theme.font
                        pointSize: 9
                        bold: true
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.currentNotif ? root.currentNotif.body : ""
                    color: root.theme.inactive
                    elide: Text.ElideRight

                    font {
                        family: root.theme.font
                        pointSize: 8
                    }
                }
            }
        }

        // ========================================================
        // PROGRESS BAR
        // ========================================================

        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 20
            height: 2
            radius: 2

            color: Qt.rgba(
                root.theme.accent.r,
                root.theme.accent.g,
                root.theme.accent.b,
                0.25
            )

            Rectangle {
                anchors.centerIn: parent
                height: parent.height
                width: parent.width * (1.0 - root.progress)
                radius: 1
                color: Qt.lighter(root.theme.accent, 1.2)
            }
        }
    }
}