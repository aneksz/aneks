import QtQuick
import QtQuick.Controls

Item {
    id: root


    // =================================================
    // API
    // =================================================

    required property var theme

    signal clicked()


    // =================================================
    // SIZE
    // =================================================

    implicitWidth:
        clockText.implicitWidth

    implicitHeight:
        30


    // =================================================
    // CLOCK TEXT
    // =================================================

    Text {
        id: clockText

        anchors.centerIn:
            parent


        text:
            Qt.formatDateTime(
                new Date(),
                "dd MMM HH:mm"
            )


        color:
            theme.fg1


        font {
            family:
                theme.font

            pointSize:
                theme.fontSize 

            weight:
                theme.fontWeight
        }


        // =============================================
        // UPDATE CLOCK
        // =============================================

        Timer {
            interval:
                1000

            running:
                true

            repeat:
                true


            onTriggered: {

                clockText.text =
                    Qt.formatDateTime(
                        new Date(),
                        "dd MMM HH:mm"
                    )
            }
        }
    }


    // =================================================
    // CLICK HANDLER
    // =================================================

    MouseArea {
        anchors.fill:
            parent

        cursorShape:
            Qt.PointingHandCursor


        onClicked:
            root.clicked()
    }
}