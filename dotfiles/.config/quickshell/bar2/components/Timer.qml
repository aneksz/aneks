// components/Timer.qml
// Bar pill for the timer: icon and time left.
// Click opens the timer panel (or dismisses a finished timer), scroll adds or
// removes a minute.
import QtQuick

Item {
    id: root

    // ── Size ────────────────────────────────────────────────────
    implicitWidth: content.implicitWidth + 20
    implicitHeight: 30
    width: implicitWidth
    height: implicitHeight

    // ── Public API ──────────────────────────────────────────────
    property var theme
    property var timer               // TimerService
    readonly property bool hovered: mouse.containsMouse

    signal clicked()

    // ── Display state ───────────────────────────────────────────
    readonly property bool finished: timer ? timer.finished : false
    readonly property bool running: timer ? timer.running : false
    readonly property bool alert: finished || (timer ? timer.warning : false)
    readonly property color tint: alert ? theme.error : theme.accent

    readonly property string icon: finished ? "alarm" : running ? "timer" : "timer_pause"

    // ── Background ──────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: mouse.containsMouse ? root.theme.surfaceAlt : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    // ── Content ─────────────────────────────────────────────────
    Row {
        id: content
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.tint
            font { family: "Material Symbols Outlined"; pixelSize: 18 }
            scale: mouse.pressed ? 0.9 : mouse.containsMouse ? 1.1 : 1.0
            Behavior on scale { NumberAnimation { duration: 120 } }
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            text: root.finished ? "Done" : root.timer ? root.timer.format(root.timer.remaining) : ""
            color: root.alert ? root.theme.error : root.running ? root.theme.fg1 : root.theme.inactive
            font {
                family: root.theme.font
                pixelSize: 15
                weight: root.theme.fontWeight
                features: { "tnum": 1 }   // fixed-width digits, no jitter while counting
            }
            Behavior on color { ColorAnimation { duration: 120 } }

            SequentialAnimation on opacity {
                running: root.finished
                loops: Animation.Infinite
                alwaysRunToEnd: true
                NumberAnimation { to: 0.4; duration: 700; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
            }
        }
    }

    // ── Interaction ─────────────────────────────────────────────
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.finished)
                root.timer.cancel();
            else
                root.clicked();
        }

        onWheel: event => {
            if (root.timer && !root.finished)
                root.timer.adjust(event.angleDelta.y > 0 ? 60 : -60);
        }
    }
}
