// components/system/Notifications.qml
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    // ============================================================
    // PUBLIC API
    // ============================================================

    property var theme
    property bool dndEnabled: false
    property var notifServer
    property var notifications: []         

    signal requestClose()

    // ============================================================
    // CLOCK (for relative time)
    // ============================================================

    SystemClock {
        id: listClock
        precision: SystemClock.Seconds
    }

    // ============================================================
    // HELPERS
    // ============================================================

    function timeAgo(ts) {
        if (!ts) return "—"

        const arrival = new Date(ts)
        const now = listClock.date

        if (isNaN(arrival.getTime())) return "err"

        const diff = Math.floor((now.getTime() - arrival.getTime()) / 1000)

        if (diff < 60) return "now"
        if (diff < 3600) return Math.floor(diff / 60) + "m"
        if (diff < 86400) return Math.floor(diff / 3600) + "h"
        return Math.floor(diff / 86400) + "d"
    }

    // ============================================================
    // NOTIFICATION LIST
    // ============================================================

    readonly property var notificationList: {
        if (!notifServer || !notifServer.trackedNotifications)
            return []

        var result = []
        var values = notifServer.trackedNotifications.values

        for (var i = 0; i < values.length; i++) {
            var n = values[i]
            if (n && !n.isSpotifyTransient)
                result.push(n)
        }
        return result.reverse()
    }

    readonly property int notificationCount: notificationList.length
    readonly property bool emptyState: notificationCount === 0

    // ============================================================
    // SIZE
    // ============================================================

    width: parent ? parent.width : 0
    height: emptyState ? 180 : Math.min(header.height + listView.contentHeight + 28, 240)
    implicitHeight: height

    // ============================================================
    // MAIN CARD
    // ============================================================

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.theme.bgAlt
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // ====================================================
            // HEADER
            // ====================================================

            RowLayout {
                id: header
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Notifications"
                    color: theme.fg
                    font {
                        family: theme.font
                        pixelSize: 13
                        weight: Font.Bold
                    }
                }

                Text {
                    visible: notificationCount > 0
                    text: notificationCount
                    color: theme.accent
                    font {
                        family: theme.font
                        pixelSize: 12
                        weight: Font.Medium
                    }
                }

                Item { Layout.fillWidth: true }

                // Clear All
                MouseArea {
                    id: clearBtn
                    width: 28
                    height: 28
                    visible: notificationCount > 0
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: clearBtn.containsMouse ? Qt.rgba(theme.error.r, theme.error.g, theme.error.b, 0.15) : "transparent"
                        border.width: 1
                        border.color: clearBtn.containsMouse ? theme.error : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰎟"
                        color: clearBtn.containsMouse ? theme.error : theme.inactive
                        font {
                            family: theme.font
                            pixelSize: 14
                        }
                    }

                    onClicked: {
                        if (!notifServer || !notifServer.trackedNotifications) return
                        const list = notifServer.trackedNotifications.values.slice()
                        list.forEach(n => { if (n && n.dismiss) n.dismiss() })
                    }
                }
            }

            // ====================================================
            // NOTIFICATION LIST
            // ====================================================

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !emptyState
                clip: true
                spacing: 6
                model: notificationList
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    width: listView.width
                    height: 48
                    radius: 10
                    color: mouse.containsMouse ? theme.surfaceAlt : "transparent"

                    Behavior on color { ColorAnimation { duration: 100 } }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData && modelData.dismiss)
                                modelData.dismiss()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        // Accent bar
                        Rectangle {
                            width: 3
                            height: 28
                            radius: 2
                            color: theme.accent
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            Text {
                                width: parent.width
                                text: modelData.summary || "Notification"
                                color: theme.fg
                                elide: Text.ElideRight
                                font {
                                    family: theme.font
                                    pixelSize: 12
                                    weight: Font.Medium
                                }
                            }

                            Text {
                                width: parent.width
                                text: modelData.body || ""
                                color: theme.inactive
                                elide: Text.ElideRight
                                font {
                                    family: theme.font
                                    pixelSize: 11
                                }
                            }
                        }

                        Text {
                            text: {
                                const t = timeAgo(modelData.timestamp)
                                return t === "now" ? "now" : t + " ago"
                            }
                            color: theme.inactive
                            font {
                                family: theme.font
                                pixelSize: 10
                            }
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }

            // ====================================================
            // EMPTY STATE
            // ====================================================

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true 
                visible: emptyState

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰂚"
                        color: theme.inactive
                        font {
                            family: theme.font
                            pixelSize: 48
                        }
                        opacity: 0.5
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No notifications"
                        color: theme.inactive
                        font {
                            family: theme.font
                            pixelSize: 12
                        }
                    }
                }
            }


        }
    }
}