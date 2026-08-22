// components/Toast.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Wayland

Item {
    id: root

    required property var theme
    required property var currentNotif
    required property bool doNotDisturb
    property var lastNotifId: null
    property bool initialized: false
    
    property bool active: !!currentNotif && !doNotDisturb
    signal dismiss()
    property real progress: 0

    PanelWindow {
        id: toastWindow

        visible: !!root.currentNotif || mainRect.opacity > 0
        mask: root.active ? clickRegion : null

        Region {
            id: clickRegion
            item: mainRect
        }

        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.namespace: "notifications"

        anchors { top: true; right: true }
        margins { top: 10; right: 10 }

        implicitWidth: 280
        implicitHeight: 65
        color: "transparent"

    Connections {
    target: root

    function onCurrentNotifChanged() {
        // If it's null (closed), do nothing
        if (!root.currentNotif) return;

        // If DND is on, don't show the toast
        if (root.doNotDisturb) return;

        // Since the NotificationServer already filters out old/reloaded ones,
        // if we are here, it IS a new notification.
        root.progress = 0;
        progressAnim.restart();
        toastTimer.restart();
    }
}


        Timer {
            id: toastTimer
            interval: 5000
            repeat: false
            onTriggered: root.dismiss()
        }

        NumberAnimation {
            id: progressAnim
            target: root
            property: "progress"
            from: 0; to: 1
            duration: toastTimer.interval
            easing.type: Easing.InOutCubic // Restored your preferred easing
        }

        Rectangle {
            id: mainRect
            anchors.fill: parent
            visible: true
            color: theme.bg
            radius: 12
            border { color: theme.accent; width: 1 }

            opacity: root.active ? 1 : 0
            transform: Translate { 
                x: root.active ? 0 : 50 
                Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutQuint } }
            }
            Behavior on opacity { NumberAnimation { duration: 500 } }

            MouseArea {
    anchors.fill: parent
    hoverEnabled: true

    onEntered: {
        toastTimer.stop()
        progressAnim.stop()
    }

    onExited: {
    let remaining = toastTimer.interval * (1 - root.progress)

    if (remaining > 0) {
        toastTimer.interval = remaining
        toastTimer.start()

        progressAnim.from = root.progress
        progressAnim.to = 1
        progressAnim.duration = remaining
        progressAnim.start()
    }
  }
}

            // ❌ Close button
            Text {
                id: closeBtn
                text: ""
                font.pixelSize: 16
                color: theme.inactive
                anchors { top: parent.top; right: parent.right; topMargin: 6; rightMargin: 8 }
                opacity: 0.7
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.dismiss(); progressAnim.stop() }
                    onEntered: closeBtn.opacity = 1
                    onExited: closeBtn.opacity = 0.7
                }
            }

                        Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                // 🎵 Album Art/Icon Container
                                // 🎵 Album Art/Icon Container (Qt 6 Compliant)
                               // 🎵 Album Art/Icon Container
                Item {
                    id: iconContainer
                    // Only take up space if an image path exists
               visible: !!root.currentNotif &&
         !!(root.currentNotif.image ||
            root.currentNotif.appIcon ||
            root.currentNotif.icon)
                    width: 45
                    height: 45
                    anchors.verticalCenter: parent.verticalCenter

                    // The Rounded Clipping Frame
                    Rectangle {
                        anchors.fill: parent
                        radius: 6 
                        color: "transparent"
                        
                        // Enforce clipping directly on the rounding container
                        clip: true 

                        Image {
    id: notifIcon

    source: {
        if (!root.currentNotif)
            return "";

        let img =
            root.currentNotif.image ||
            root.currentNotif.appIcon ||
            root.currentNotif.icon || "";

        if (!img)
            return "";

        // Quickshell incorrectly wraps remote URLs
        if (img.startsWith("image://icon/http")) {
            img = img.replace("image://icon/", "");
        }

        // Local file path
        if (img.startsWith("/")) {
            return "file://" + img;
        }

        return img;
    }

    anchors.fill: parent
    fillMode: Image.PreserveAspectCrop
    antialiasing: true
}
                    }
                }



                // Metadata Column (Width automatically adjusts if an image is present)
                Column {
                    width: parent.width - (notifIcon.visible ? 65 : 20)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    
                    Text {
                        text: root.currentNotif ? root.currentNotif.summary : ""
                        color: theme.fg1
                        font { bold: true; pointSize: 9; family: theme.font }
                        elide: Text.ElideRight
                        width: parent.width
                    }
                    Text {
                        text: root.currentNotif ? root.currentNotif.body : ""
                        color: theme.inactive
                        font { pointSize: 8; family: theme.font }
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }
            }


            // 📊 Progress bar (Shrinks from both sides)
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 20; height: 3; radius: 2
                color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.25)

                Rectangle {
                    anchors.centerIn: parent
                    height: parent.height
                    width: parent.width * (1.0 - root.progress)
                    color: Qt.lighter(theme.accent, 1.2)
                    radius: 1
                }
            }
        }
    }
}
