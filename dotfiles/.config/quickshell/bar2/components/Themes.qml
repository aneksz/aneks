import QtQuick
import QtQuick.Layouts
import QtQml
import Quickshell

Item {
    id: root
    anchors.fill: parent

    // ── Interface (unchanged, shell.qml keeps working) ──────────────
    property string currentTheme
    property var checkCurrent
    property var getThemes
    property var themeLoader
    property var theme
    property var themes
    property string selectedTheme: ""
    signal themeSelected(string name)

    // Paths (edit here if your layout changes)
    property string themesDir: "/home/igor/.config/themes"
    property string currentThemeFile: "/home/igor/.config/.current_theme"
    property string colorsPath: "/home/igor/.config/quickshell/bar2/Colors.qml"

    // getThemes lists themes/*.sh, which also catches apply-theme.sh
    readonly property var themeList: (themes || []).filter(t => t && t !== "apply-theme")

    // name -> { bg, accent, fg }, filled from each theme's quickshell_theme.qml
    property var themePreviews: ({})

    function tint(a) { return Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, a) }

    Component.onCompleted: {
        selectedTheme = currentTheme !== "" ? currentTheme
                      : (themeList.length > 0 ? themeList[0] : "")
    }
    onCurrentThemeChanged: {
        if (currentTheme !== "")
            selectedTheme = currentTheme
    }

    function applyTheme(name) {
        selectedTheme = name
        themeSelected(name)
        // name is passed as $1, never interpolated into the shell string
        Quickshell.execDetached([
            "sh", "-c",
            'echo "$1" > "$2" && "$3/apply-theme.sh" "$1"',
            "sh", name, currentThemeFile, themesDir
        ])
        themeUpdateTimer.restart()
    }

    // Give apply-theme.sh time to write files, then refresh state + colors
    Timer {
        id: themeUpdateTimer
        interval: 1200
        repeat: false
        onTriggered: {
            if (root.checkCurrent) {
                root.checkCurrent.running = false
                root.checkCurrent.running = true
            }
            if (root.themeLoader) {
                root.themeLoader.source = ""
                root.themeLoader.source = "file://" + root.colorsPath + "?v=" + Date.now()
            }
        }
    }

    // Pull preview colours straight from each theme's generated file
    Instantiator {
        model: root.themeList

        delegate: Loader {
            required property string modelData
            source: "file://" + root.themesDir + "/" + modelData + "/quickshell_theme.qml"

            onStatusChanged: {
                if (status === Loader.Ready && item) {
                    var updated = Object.assign({}, root.themePreviews)
                    // colour1..6 = red, green, yellow, blue, magenta, cyan
                    var pal = []
                    for (var i = 1; i <= 6; i++) {
                        var col = item["color" + i]
                        pal.push(col !== undefined ? col : item.accent)
                    }
                    updated[modelData] = {
                        bg: item.background,
                        accent: item.accent,
                        fg: item.foreground,
                        palette: pal
                    }
                    root.themePreviews = updated
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // ── Header ──────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: 12
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "󰏘"
                    font.pixelSize: 22
                    font.family: theme.font
                    color: theme.accent
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Themes"
                    font.family: theme.font
                    font.pixelSize: 20
                    font.bold: true
                    color: theme.fg0
                }
                Text {
                    text: root.selectedTheme !== "" ? "Current: " + root.selectedTheme
                                                    : root.themeList.length + " available"
                    font.family: theme.font
                    font.pixelSize: 13
                    color: theme.textMuted
                }
            }

            Item { Layout.fillWidth: true }
        }

        // ── Grid ────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridView {
                id: grid
                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.themeList

                readonly property int columns: Math.max(2, Math.floor(width / 150))
                cellWidth: Math.floor(width / columns)
                cellHeight: 96

                delegate: Item {
                    id: cell
                    required property var modelData
                    width: grid.cellWidth
                    height: grid.cellHeight

                    readonly property var preview: root.themePreviews[modelData]
                    readonly property bool selected: modelData === root.selectedTheme
                    readonly property color pBg: preview ? preview.bg : theme.surface
                    readonly property color pAccent: preview ? preview.accent : theme.accent
                    readonly property color pFg: preview ? preview.fg : theme.fg

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 14
                        color: cell.pBg
                        // border only on the active theme, in that theme's accent
                        border.width: cell.selected ? 2 : 0
                        border.color: cell.pAccent
                        scale: mouse.containsMouse ? 1.03 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 4

                                Repeater {
                                    model: cell.preview ? cell.preview.palette : []
                                    Rectangle {
                                        required property var modelData
                                        width: 10
                                        height: 10
                                        radius: 5
                                        color: modelData
                                    }
                                }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: cell.modelData
                                font.family: theme.font
                                font.pixelSize: 12
                                font.bold: true
                                color: cell.pFg
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, cell.width - 32)
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyTheme(cell.modelData)
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.themeList.length === 0
                text: "No themes found"
                font.family: theme.font
                font.pixelSize: 14
                color: theme.textMuted
                opacity: 0.5
            }
        }

        // ── Footer ──────────────────────────────────────────────────
        Text {
            Layout.fillWidth: true
            text: "Click a theme to apply it"
            font.family: theme.font
            font.pixelSize: 12
            color: theme.textMuted
        }
    }
}
