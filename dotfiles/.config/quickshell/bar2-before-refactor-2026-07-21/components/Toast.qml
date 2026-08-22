// components/Toast.qml

import QtQuick
import Quickshell
import QtQuick.Controls
import QtQuick.Layouts

Item {
id: root

// ============================================================
// API
// ============================================================

property var theme
property var currentNotif
property bool doNotDisturb: false
property string osdMode: ""

signal dismiss()
signal toastTriggered()

// ============================================================
// STATE
// ============================================================

property bool active:
    root.osdMode === "toast" &&
    !!root.currentNotif &&
    !root.doNotDisturb

property real progress:
    0


// ============================================================
// SIZE
// ============================================================

anchors.fill:
    parent


// ============================================================
// NOTIFICATION CHANGED
// ============================================================

Connections {
    target:
        root

    function onCurrentNotifChanged() {

        // --------------------------------------------
        // No notification
        // --------------------------------------------

        if (
            !root.currentNotif
        ) {
            return
        }


        // --------------------------------------------
        // Do Not Disturb
        // --------------------------------------------

        if (
            root.doNotDisturb
        ) {
            return
        }


        // --------------------------------------------
        // Restart notification lifetime
        // --------------------------------------------

        root.progress =
            0

        progressAnim.restart()

        toastTimer.restart()


        // --------------------------------------------
        // Tell shell.qml to morph the island
        // --------------------------------------------

        root.toastTriggered()
    }
}


// ============================================================
// AUTO HIDE
// ============================================================

Timer {
    id:
        toastTimer

    interval:
        5000

    repeat:
        false

    onTriggered: {

        root.dismiss()
    }
}


// ============================================================
// PROGRESS ANIMATION
// ============================================================

NumberAnimation {
    id:
        progressAnim

    target:
        root

    property:
        "progress"

    from:
        0

    to:
        1

    duration:
        toastTimer.interval

    easing.type:
        Easing.InOutCubic
}


// ============================================================
// MAIN TOAST CARD
// ============================================================

Rectangle {
    id:
        mainRect

    anchors.fill:
        parent

    radius:
        12

    color:
        root.theme.bg


    border {
        width:
            1

        color:
            root.theme.accent
    }


    // ========================================================
    // ANIMATION
    // ========================================================

    opacity:
        root.active
        ? 1.0
        : 0.0


    transform:
        Translate {

            x:
                root.active
                ? 0
                : 50


            Behavior on x {

                NumberAnimation {

                    duration:
                        600

                    easing.type:
                        Easing.OutQuint
                }
            }
        }


    Behavior on opacity {

        NumberAnimation {

            duration:
                500
        }
    }


    // ========================================================
    // MOUSE INTERACTION
    // ========================================================

    MouseArea {
        anchors.fill:
            parent

        hoverEnabled:
            true


        onEntered: {

            toastTimer.stop()

            progressAnim.stop()
        }


        onExited: {

            let remaining =
                toastTimer.interval *
                (1.0 - root.progress)


            if (
                remaining <= 0
            ) {
                return
            }


            toastTimer.interval =
                remaining

            toastTimer.start()


            progressAnim.from =
                root.progress

            progressAnim.to =
                1

            progressAnim.duration =
                remaining

            progressAnim.start()
        }
    }


    // ========================================================
    // CLOSE BUTTON
    // ========================================================

    Text {
        id:
            closeButton

        text:
            ""

        color:
            root.theme.inactive

        opacity:
            0.7


        anchors {
            top:
                parent.top

            right:
                parent.right

            topMargin:
                6

            rightMargin:
                8
        }


        font {
            family:
                root.theme.font

            pixelSize:
                16
        }


        MouseArea {
            anchors.fill:
                parent

            hoverEnabled:
                true

            cursorShape:
                Qt.PointingHandCursor


            onEntered: {

                closeButton.opacity =
                    1.0
            }


            onExited: {

                closeButton.opacity =
                    0.7
            }


            onClicked: {

                root.dismiss()

                progressAnim.stop()
            }
        }
    }


    // ========================================================
    // NOTIFICATION CONTENT
    // ========================================================

    Row {
        anchors.fill:
            parent

        anchors.margins:
            10

        spacing:
            12


        // ====================================================
        // ICON
        // ====================================================

        Item {
            id:
                iconContainer

            visible:
                !!root.currentNotif &&
                !!(
                    root.currentNotif.image ||
                    root.currentNotif.appIcon ||
                    root.currentNotif.icon
                )

            width:
                45

            height:
                45

            anchors.verticalCenter:
                parent.verticalCenter


            Rectangle {
                anchors.fill:
                    parent

                radius:
                    6

                color:
                    "transparent"

                clip:
                    true


                Image {
                    id:
                        notifIcon

                    anchors.fill:
                        parent

                    fillMode:
                        Image.PreserveAspectCrop

                    antialiasing:
                        true


                    source: {

                        if (
                            !root.currentNotif
                        ) {
                            return ""
                        }


                        let image =
                            root.currentNotif.image ||
                            root.currentNotif.appIcon ||
                            root.currentNotif.icon ||
                            ""


                        if (
                            !image
                        ) {
                            return ""
                        }


                        // Fix image://icon/http...
                        if (
                            image.startsWith(
                                "image://icon/http"
                            )
                        ) {

                            image =
                                image.replace(
                                    "image://icon/",
                                    ""
                                )
                        }


                        // Local file path
                        if (
                            image.startsWith(
                                "/"
                            )
                        ) {

                            return "file://" +
                                image
                        }


                        return image
                    }
                }
            }
        }


        // ====================================================
        // NOTIFICATION TEXT
        // ====================================================

        Column {
            anchors.verticalCenter:
                parent.verticalCenter

            spacing:
                2

            width:
                parent.width -
                (
                    iconContainer.visible
                    ? 65
                    : 20
                )


            Text {
                width:
                    parent.width

                text:
                    root.currentNotif
                    ? root.currentNotif.summary
                    : ""

                color:
                    root.theme.fg1

                elide:
                    Text.ElideRight

                font {
                    family:
                        root.theme.font

                    pointSize:
                        9

                    bold:
                        true
                }
            }


            Text {
                width:
                    parent.width

                text:
                    root.currentNotif
                    ? root.currentNotif.body
                    : ""

                color:
                    root.theme.inactive

                elide:
                    Text.ElideRight

                font {
                    family:
                        root.theme.font

                    pointSize:
                        8
                }
            }
        }
    }


    // ========================================================
    // PROGRESS BAR
    // ========================================================

    Rectangle {
        anchors.bottom:
            parent.bottom

        anchors.horizontalCenter:
            parent.horizontalCenter

        width:
            parent.width -
            20

        height:
            3

        radius:
            2

        color:
            Qt.rgba(
                root.theme.accent.r,
                root.theme.accent.g,
                root.theme.accent.b,
                0.25
            )


        Rectangle {
            anchors.centerIn:
                parent

            height:
                parent.height

            width:
                parent.width *
                (
                    1.0 -
                    root.progress
                )

            radius:
                1

            color:
                Qt.lighter(
                    root.theme.accent,
                    1.2
                )
        }
    }
 }

}
