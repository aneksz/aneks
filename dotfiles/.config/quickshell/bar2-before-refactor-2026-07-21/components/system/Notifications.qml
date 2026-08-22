// components/system/Notifications.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

Item {
    id: root

    // ============================================================
    // PUBLIC API
    // ============================================================

    property var theme
    property bool dndEnabled: false
    property var notifServer: Notifications

    signal requestClose()

    // ============================================================
    // NOTIFICATION DATA
    // ============================================================

    readonly property var notificationList: {
        if (
            !root.notifServer ||
            !root.notifServer.trackedNotifications ||
            !root.notifServer.trackedNotifications.values
        ) {
            return []
        }

        return root.notifServer.trackedNotifications.values.filter(
            notification =>
                !notification.isSpotifyTransient
        )
    }

    readonly property int notificationCount:
        root.notificationList.length

    // ============================================================
    // STATE
    // ============================================================

    readonly property bool emptyState:
        root.notificationCount === 0

    // ============================================================
    // SIZE
    // ============================================================

    width:
        parent
        ? parent.width
        : 0

    height:
        root.emptyState
        ? 60
        : Math.min(
            headerRow.height +
            12 +
            notificationListView.contentHeight,
            220
        )

    implicitHeight:
        height

    // ============================================================
    // EMPTY STATE PULSE
    // ============================================================

    SequentialAnimation {
        id: pulseAnimation

        NumberAnimation {
            target:
                bellIcon

            property:
                "scale"

            to:
                1.15

            duration:
                120
        }

        NumberAnimation {
            target:
                bellIcon

            property:
                "scale"

            to:
                1.0

            duration:
                180
        }
    }

    onEmptyStateChanged: {
        if (root.emptyState)
            pulseAnimation.restart()
    }

    // ============================================================
    // CONTENT
    // ============================================================

    Column {
        id: contentColumn

        anchors {
            left: parent.left
            right: parent.right
        }

        spacing:
            12

        // ========================================================
        // HEADER
        // ========================================================

        RowLayout {
            id: headerRow

            width:
                parent.width

            height:
                30

            spacing:
                10

            Text {
                text:
                    "Notifications"

                color:
                    root.theme
                    ? root.theme.fg1
                    : "white"

                font {
                    family:
                        root.theme
                        ? root.theme.font
                        : "sans"

                    pointSize:
                        9

                    bold:
                        true
                }
            }

            Text {
                visible:
                    root.notificationCount > 0

                text:
                    "(" +
                    root.notificationCount +
                    ")"

                color:
                    root.theme
                    ? root.theme.accent
                    : "blue"

                font {
                    family:
                        root.theme
                        ? root.theme.font
                        : "sans"

                    pointSize:
                        8
                }
            }

            Item {
                Layout.fillWidth:
                    true
            }

            RowLayout {
                spacing:
                    6

                // ------------------------------------------------
                // CLEAR ALL
                // ------------------------------------------------

                MouseArea {
                    width:
                        26

                    height:
                        26

                    visible:
                        root.notificationCount > 0

                    hoverEnabled:
                        true

                    cursorShape:
                        Qt.PointingHandCursor

                    Rectangle {
                        anchors.fill:
                            parent

                        radius:
                            width / 2

                        color:
                            parent.containsMouse
                            ? root.theme.surfaceAlt
                            : "transparent"
                    }

                    Text {
                        anchors.centerIn:
                            parent

                        text:
                            "󰎟"

                        color:
                            parent.parent.containsMouse
                            ? root.theme.error
                            : root.theme.inactive

                        font {
                            family:
                                root.theme
                                ? root.theme.font
                                : "sans"

                            pixelSize:
                                14
                        }
                    }

                    onClicked: {
                        root.notificationList
                            .slice()
                            .forEach(
                                notification =>
                                    notification.dismiss()
                            )
                    }
                }

                // ------------------------------------------------
                // DO NOT DISTURB
                // ------------------------------------------------

                MouseArea {
                    id:
                        dndButton

                    width:
                        26

                    height:
                        26

                    hoverEnabled:
                        true

                    cursorShape:
                        Qt.PointingHandCursor

                    Rectangle {
                        anchors.fill:
                            parent

                        radius:
                            width / 2

                        color:
                            parent.containsMouse
                            ? root.theme.surfaceAlt
                            : "transparent"
                    }

                    Text {
                        id:
                            bellIcon

                        anchors.centerIn:
                            parent

                        text:
                            root.dndEnabled
                            ? "󰂛"
                            : ""

                        color:
                            root.dndEnabled
                            ? root.theme.accent
                            : (
                                dndButton.containsMouse
                                ? Qt.lighter(
                                    root.theme.accent,
                                    1.2
                                )
                                : root.theme.inactive
                            )

                        font {
                            family:
                                root.theme
                                ? root.theme.font
                                : "sans"

                            pixelSize:
                                14
                        }

                        scale:
                            dndButton.pressed
                            ? 0.9
                            : (
                                dndButton.containsMouse
                                ? 1.15
                                : 1.0
                            )

                        Behavior on scale {
                            NumberAnimation {
                                duration:
                                    120
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration:
                                    120
                            }
                        }
                    }

                    onClicked: {
                        root.dndEnabled =
                            !root.dndEnabled
                    }
                }
            }
        }

        // ========================================================
        // NOTIFICATION LIST
        // ========================================================

        ListView {
            id:
                notificationListView

            visible:
                root.notificationCount > 0

            width:
                parent.width

            height:
                Math.min(
                    contentHeight,
                    220 -
                    headerRow.height -
                    contentColumn.spacing
                )

            spacing:
                8

            clip:
                true

            boundsBehavior:
                Flickable.StopAtBounds

            model:
                root.notificationList

            delegate:
                Item {
                    width:
                        notificationListView.width

                    height:
                        44

                    Rectangle {
                        anchors.fill:
                            parent

                        radius:
                            8

                        color:
                            notificationMouseArea.containsMouse
                            ? root.theme.surfaceAlt
                            : "transparent"

                        border {
                            width:
                                notificationMouseArea.containsMouse
                                ? 1
                                : 0

                            color:
                                root.theme.surface
                        }
                    }

                    MouseArea {
                        id:
                            notificationMouseArea

                        anchors.fill:
                            parent

                        hoverEnabled:
                            true

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            modelData.dismiss()
                        }
                    }

                    RowLayout {
                        anchors {
                            fill:
                                parent

                            leftMargin:
                                10

                            rightMargin:
                                10
                        }

                        spacing:
                            12

                        Text {
                            text:
                                "󰂚"

                            color:
                                root.theme.accent

                            font {
                                family:
                                    root.theme.font

                                pixelSize:
                                    14
                            }

                            Layout.alignment:
                                Qt.AlignVCenter
                        }

                        Column {
                            Layout.fillWidth:
                                true

                            Layout.alignment:
                                Qt.AlignVCenter

                            spacing:
                                0

                            Text {
                                width:
                                    parent.width

                                text:
                                    modelData.summary
                                    || "Notification"

                                color:
                                    root.theme.fg

                                font {
                                    family:
                                        root.theme.font

                                    pointSize:
                                        9

                                    bold:
                                        true
                                }

                                elide:
                                    Text.ElideRight
                            }

                            Text {
                                width:
                                    parent.width

                                text:
                                    modelData.body
                                    || ""

                                color:
                                    root.theme.inactive

                                font {
                                    family:
                                        root.theme.font

                                    pointSize:
                                        8
                                }

                                elide:
                                    Text.ElideRight
                            }
                        }
                    }
                }
        }

        // ========================================================
        // EMPTY STATE
        // ========================================================

        Text {
            visible:
                root.emptyState

            width:
                parent.width

            height:
                18

            text:
                "No Notifications"

            horizontalAlignment:
                Text.AlignHCenter

            verticalAlignment:
                Text.AlignVCenter

            color:
                root.theme
                ? root.theme.inactive
                : "gray"

            font {
                family:
                    root.theme
                    ? root.theme.font
                    : "sans"

                pointSize:
                    8.5

                italic:
                    true
            }
        }
    }
}