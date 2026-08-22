// components/system/Stats.qml
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // ============================================================
    // SIZE
    // ============================================================

    width:
        parent
        ? parent.width
        : 0

    height:
        contentColumn.implicitHeight

    implicitHeight:
        contentColumn.implicitHeight

    // ============================================================
    // PUBLIC API
    // ============================================================

    property var theme

    property string cpuTemp: ""
    property string gpuTemp: ""
    property string cpuUsage: ""
    property string ramUsage: ""
    property string dataUsage: ""
    property string homeUsage: ""

    // ============================================================
    // STAT TILE COMPONENT
    // ============================================================

    component Tile: Item {
        id: tile

        property string icon: ""
        property string value: ""
        property string label: ""

        property color accent:
            root.theme
            ? root.theme.accent
            : "white"

        property bool hovered:
            false

        height:
            64

        Layout.fillWidth:
            true

        // --------------------------------------------------------
        // TILE BACKGROUND
        // --------------------------------------------------------

        Rectangle {
            anchors.fill:
                parent

            radius:
                8

            color:
                tile.hovered
                ? Qt.rgba(
                    tile.accent.r,
                    tile.accent.g,
                    tile.accent.b,
                    0.08
                )
                : "transparent"

            border {
                width:
                    tile.hovered
                    ? 1
                    : 0

                color:
                    tile.accent
            }

            Behavior on color {
                ColorAnimation {
                    duration:
                        120
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration:
                        120
                }
            }
        }

        // --------------------------------------------------------
        // TILE CONTENT
        // --------------------------------------------------------

        Column {
            anchors.centerIn:
                parent

            spacing:
                2

            Row {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                spacing:
                    6

                Text {
                    text:
                        tile.icon

                    color:
                        tile.accent

                    font {
                        family:
                            root.theme
                            ? root.theme.font
                            : "JetBrainsMono Nerd Font"

                        pixelSize:
                            13
                    }
                }

                Text {
                    text:
                        tile.value

                    color:
                        root.theme
                        ? root.theme.fg1
                        : "white"

                    font {
                        family:
                            root.theme
                            ? root.theme.font
                            : "JetBrainsMono Nerd Font"

                        pixelSize:
                            12

                        bold:
                            true
                    }
                }
            }

            Text {
                anchors.horizontalCenter:
                    parent.horizontalCenter

                text:
                    tile.label

                color:
                    root.theme
                    ? root.theme.inactive
                    : "#888888"

                font {
                    family:
                        root.theme
                        ? root.theme.font
                        : "JetBrainsMono Nerd Font"

                    pixelSize:
                        9
                }
            }
        }

        // --------------------------------------------------------
        // HOVER
        // --------------------------------------------------------

        MouseArea {
            anchors.fill:
                parent

            hoverEnabled:
                true

            cursorShape:
                Qt.PointingHandCursor

            onEntered:
                tile.hovered = true

            onExited:
                tile.hovered = false
        }
    }

    // ============================================================
    // STAT GRID
    // ============================================================

    ColumnLayout {
        id:
            contentColumn

        anchors {
            left:
                parent.left

            right:
                parent.right
        }

        spacing:
            12

        // --------------------------------------------------------
        // CPU / GPU TEMPERATURE
        // --------------------------------------------------------

        RowLayout {
            Layout.fillWidth:
                true

            spacing:
                12

            Tile {
                icon:
                    ""

                value:
                    root.cpuTemp
                    || "0°C"

                label:
                    "CPU Temp"
            }

            Tile {
                icon:
                    ""

                value:
                    root.gpuTemp
                    || "0°C"

                label:
                    "GPU Temp"
            }
        }

        // --------------------------------------------------------
        // CPU / MEMORY USAGE
        // --------------------------------------------------------

        RowLayout {
            Layout.fillWidth:
                true

            spacing:
                12

            Tile {
                icon:
                    ""

                value:
                    root.cpuUsage
                    || "0%"

                label:
                    "CPU Usage"
            }

            Tile {
                icon:
                    ""

                value:
                    root.ramUsage
                    || "0%"

                label:
                    "Memory"
            }
        }

        // --------------------------------------------------------
        // STORAGE
        // --------------------------------------------------------

        RowLayout {
            Layout.fillWidth:
                true

            spacing:
                12

            Tile {
                icon:
                    "󰆼"

                value:
                    root.dataUsage
                    || "0%"

                label:
                    "/mnt/data"

                accent:
                    root.theme
                    ? root.theme.warning
                    : "orange"
            }

            Tile {
                icon:
                    ""

                value:
                    root.homeUsage
                    || "0%"

                label:
                    "/home/igor"

                accent:
                    root.theme
                    ? root.theme.success
                    : "green"
            }
        }
    }
}