// components/Timer.qml
import QtQuick

Item {
    id: root

    // ── Size ────────────────────────────────────────────────────
    width: 90
    height: 30
    implicitWidth: 70
    implicitHeight: 30

    // ── Public API ──────────────────────────────────────────────
    property var theme

    property bool running: false
    property bool finished: false
    property int remainingSeconds: 0
    readonly property bool hovered: mouse.containsMouse

    signal clicked()
    signal adjustRequested(int seconds)
    signal dismissRequested()

    // ── Display state ───────────────────────────────────────────
    readonly property bool warning: remainingSeconds > 0 && remainingSeconds <= 10
    readonly property bool alert: finished || warning
    readonly property string displayTime: formatTime(remainingSeconds)

    readonly property string icon: finished ? "󰂚"
                                 : running  ? "󱎫"
                                 :            "󱫞"

    function formatTime(seconds) {
        const m = Math.floor(seconds / 60)
        const s = seconds % 60
        return m.toString().padStart(2, "0") + ":" + s.toString().padStart(2, "0")
    }

    // ── Background ──────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: mouse.containsMouse ? root.theme.surfaceAlt : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    // ── Content ─────────────────────────────────────────────────
    Row {
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.alert ? root.theme.error : root.theme.accent
            font {
                family: root.theme.font
                pixelSize: 16
            }
            scale: mouse.pressed ? 0.9 : mouse.containsMouse ? 1.1 : 1.0

            Behavior on scale { NumberAnimation { duration: 120 } }
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            text: root.finished ? "Done" : root.displayTime
            color: root.alert ? root.theme.error : root.theme.fg1
            font {
                family: root.theme.font
                pixelSize: 16
                weight: root.theme.fontWeight
                features: { "tnum": 1 }   // fixed-width digits, no jitter while counting
            }

            Behavior on color { ColorAnimation { duration: 120 } }
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
                root.dismissRequested()
            else
                root.clicked()
        }

        onWheel: event => {
            if (root.finished)
                return
            root.adjustRequested(event.angleDelta.y > 0 ? 60 : -60)
        }
    }
}