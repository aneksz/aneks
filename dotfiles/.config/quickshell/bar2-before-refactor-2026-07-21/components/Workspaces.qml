import QtQuick
import Quickshell.Hyprland

Item {
    id: root


    // ============================================================
    // THEME
    // ============================================================

    property var theme



    // ============================================================
    // WORKSPACE STATE
    // ============================================================

    property int activeWs:
        Hyprland.focusedWorkspace?.id ?? 1

    property int hoveredIdx:
        -1



    // ============================================================
    // SIZE
    // ============================================================

    width:
        184

    height:
        30



    // ============================================================
    // WORKSPACE ROW
    // ============================================================

    Row {
        id: wsRow

        anchors.centerIn:
            parent

        spacing:
            8


        Repeater {

            model:
                [1, 2, 3, 4, 5, 6]


            delegate:
                Item {

                    id:
                        wsItem


                    width:
                        24

                    height:
                        24


                    // ------------------------------------------------
                    // WORKSPACE STATE
                    // ------------------------------------------------

                    property int wsId:
                        modelData


                    property bool isActive:
                        root.activeWs === wsId


                    property bool isHovered:
                        root.hoveredIdx === index



                    // ------------------------------------------------
                    // WORKSPACE CIRCLE
                    // ------------------------------------------------

                    Rectangle {

                        id:
                            circle


                        anchors.fill:
                            parent


                        radius:
                            width / 2


                        color:

                            isActive
                            ? root.theme.accent

                            : isHovered
                            ? root.theme.surfaceAlt

                            : root.theme.inactive


                        opacity:

                            isActive
                            ? 1.0

                            : isHovered
                            ? 0.9

                            : 0.6


                        Behavior on color {

                            ColorAnimation {

                                duration:
                                    120
                            }
                        }


                        Behavior on opacity {

                            NumberAnimation {

                                duration:
                                    120
                            }
                        }



                        // ------------------------------------------------
                        // WORKSPACE NUMBER
                        // ------------------------------------------------

                        Text {

                            anchors.centerIn:
                                parent


                            text:
                                wsId


                            color:

                                isActive
                                ? root.theme.bg
                                : root.theme.fg


                            font {

                                family:
                                    root.theme.font

                                pixelSize:
                                    11

                                bold:
                                    false
                            }
                        }
                    }
                }
        }
    }



    // ============================================================
    // GLOBAL MOUSE ZONE
    // ============================================================

    MouseArea {

        id:
            masterWorkspaceMouse


        anchors.fill:
            parent


        hoverEnabled:
            true


        propagateComposedEvents:
            true



        // ------------------------------------------------
        // MOUSE ENTER
        // ------------------------------------------------

        onEntered: {

            if (
                typeof detector !==
                "undefined"
            ) {

                detector.childHovered =
                    true
            }
        }



        // ------------------------------------------------
        // MOUSE EXIT
        // ------------------------------------------------

        onExited: {

            if (
                typeof detector !==
                "undefined"
            ) {

                detector.childHovered =
                    false
            }


            root.hoveredIdx =
                -1
        }



        // ------------------------------------------------
        // HOVER TRACKING
        // ------------------------------------------------

        onPositionChanged:
            function(mouse) {

                const itemWidthPlusSpacing =
                    32


                const localX =
                    mouse.x -
                    wsRow.x


                const targetIndex =
                    Math.floor(
                        localX /
                        itemWidthPlusSpacing
                    )


                if (

                    targetIndex >= 0 &&

                    targetIndex < 6 &&

                    (
                        localX %
                        itemWidthPlusSpacing
                    ) <= 24

                ) {

                    root.hoveredIdx =
                        targetIndex

                } else {

                    root.hoveredIdx =
                        -1
                }
            }



        // ------------------------------------------------
        // WORKSPACE CLICK
        // ------------------------------------------------

        onClicked:
            function(mouse) {

                const itemWidthPlusSpacing =
                    32


                const localX =
                    mouse.x -
                    wsRow.x


                const targetIndex =
                    Math.floor(
                        localX /
                        itemWidthPlusSpacing
                    )


                if (

                    targetIndex >= 0 &&

                    targetIndex < 6

                ) {

                    const wsId =
                        targetIndex + 1


                    Hyprland.dispatch(
                        `hl.dsp.focus({ workspace = "${wsId}" })`
                    )


                    if (
                        typeof detector !==
                        "undefined"
                    ) {

                        detector.childHovered =
                            false

                        detector.activeHover =
                            false
                    }
                }


                mouse.accepted =
                    true
            }
    }
}