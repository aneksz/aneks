import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQml
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects

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
    property string thumbScript: "/home/igor/.config/quickshell/bar2/scripts/theme-thumbs.sh"
    property string favouritesFile: "/home/igor/.config/themes/.favourites"

    // ── Look ─────────────────────────────────────────────────────────
    readonly property int columns: 2      // 1 = one wide card per row
    readonly property int cardRadius: 14

    // getThemes lists themes/*.sh, which also catches apply-theme.sh
    readonly property var themeList: (themes || []).filter(t => t && t !== "apply-theme")

    // name -> { bg, accent, fg, palette[6], ramp[4], light }, from each theme's quickshell_theme.qml
    property var themePreviews: ({})
    // name -> thumbnail path, from scripts/theme-thumbs.sh
    property var thumbs: ({})
    property int thumbVersion: 0
    property var favourites: []
    property string applyingTheme: ""
    property int kbIndex: 0

    readonly property string filterText: filterInput.text.trim().toLowerCase()

    // Favourites first, then alphabetical; narrowed by whatever has been typed
    readonly property var shownList: {
        const f = filterText;
        const favs = favourites;
        const list = themeList.filter(t => f === "" || t.toLowerCase().indexOf(f) >= 0);
        list.sort((a, b) => {
            const fa = favs.indexOf(a) >= 0, fb = favs.indexOf(b) >= 0;
            if (fa !== fb)
                return fa ? -1 : 1;
            return a.localeCompare(b);
        });
        return list;
    }

    function tint(a) {
        return Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, a);
    }
    function withAlpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }
    function luminance(c) {
        return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b;
    }

    Component.onCompleted: {
        selectedTheme = currentTheme !== "" ? currentTheme : (themeList.length > 0 ? themeList[0] : "");
        favReader.running = true;
        Qt.callLater(opened);
    }
    onCurrentThemeChanged: {
        if (currentTheme !== "")
            selectedTheme = currentTheme;
    }

    // The Loader in shell.qml creates this fresh each time the switcher opens,
    // so "opening" = being created. Bindings from shell.qml land just after
    // creation, hence the callLater and the kbTouched logic below.
    property bool kbTouched: false   // true once the arrows / mouse have moved the highlight

    function opened() {
        filterInput.forceActiveFocus();
        thumbProc.running = true;
        syncKbToCurrent();
    }
    function syncKbToCurrent() {
        if (kbTouched || filterText !== "")
            return;
        const i = shownList.indexOf(selectedTheme);
        kbIndex = i >= 0 ? i : 0;
        Qt.callLater(() => grid.positionViewAtIndex(kbIndex, GridView.Contain));
    }
    onVisibleChanged: if (visible)
        Qt.callLater(opened)

    onFilterTextChanged: kbIndex = 0
    onShownListChanged: {
        kbIndex = Math.max(0, Math.min(kbIndex, shownList.length - 1));
        syncKbToCurrent();
    }
    onSelectedThemeChanged: syncKbToCurrent()
    onKbIndexChanged: grid.positionViewAtIndex(kbIndex, GridView.Contain)

    function applyTheme(name) {
        if (!name)
            return;
        selectedTheme = name;
        applyingTheme = name;
        themeSelected(name);
        // name is passed as $1, never interpolated into the shell string
        Quickshell.execDetached(["sh", "-c", 'echo "$1" > "$2" && "$3/apply-theme.sh" "$1"', "sh", name, currentThemeFile, themesDir]);
        themeUpdateTimer.restart();
    }

    function applyRandom() {
        const pool = shownList.filter(t => t !== selectedTheme);
        if (pool.length > 0)
            applyTheme(pool[Math.floor(Math.random() * pool.length)]);
    }

    function toggleFavourite(name) {
        const favs = favourites.slice();
        const i = favs.indexOf(name);
        if (i >= 0)
            favs.splice(i, 1);
        else
            favs.push(name);
        favourites = favs;
        // one name per line; names are passed as arguments, never interpolated
        Quickshell.execDetached(["sh", "-c", 'f="$1"; shift; printf "%s\\n" "$@" > "$f"', "sh", favouritesFile].concat(favs));
    }

    function moveKb(step) {
        const n = shownList.length;
        if (n === 0)
            return;
        kbTouched = true;
        kbIndex = Math.max(0, Math.min(n - 1, kbIndex + step));
    }

    // Give apply-theme.sh time to write files, then refresh state + colors
    Timer {
        id: themeUpdateTimer
        interval: 1200
        repeat: false
        onTriggered: {
            root.applyingTheme = "";
            if (root.checkCurrent) {
                root.checkCurrent.running = false;
                root.checkCurrent.running = true;
            }
            if (root.themeLoader) {
                root.themeLoader.source = "";
                root.themeLoader.source = "file://" + root.colorsPath + "?v=" + Date.now();
            }
        }
    }

    // ── Data sources ─────────────────────────────────────────────────

    // Thumbnails: makes any missing ones, then lists "name<TAB>path"
    Process {
        id: thumbProc
        command: ["bash", root.thumbScript]
        stdout: StdioCollector {
            onStreamFinished: {
                const map = {};
                text.split("\n").forEach(line => {
                    const parts = line.split("\t");
                    if (parts.length === 2 && parts[0] !== "")
                        map[parts[0]] = parts[1];
                });
                root.thumbs = map;
                root.thumbVersion++;  // reload images that were just (re)made
            }
        }
    }

    Process {
        id: favReader
        command: ["sh", "-c", 'cat "$1" 2>/dev/null', "sh", root.favouritesFile]
        stdout: StdioCollector {
            onStreamFinished: root.favourites = text.split("\n").map(s => s.trim()).filter(s => s !== "")
        }
    }

    // Preview colours straight from each theme's generated file
    Instantiator {
        model: root.themeList

        delegate: Loader {
            required property string modelData
            source: "file://" + root.themesDir + "/" + modelData + "/quickshell_theme.qml"

            onStatusChanged: {
                if (status === Loader.Ready && item) {
                    const updated = Object.assign({}, root.themePreviews);
                    // colour1..6 = red, green, yellow, blue, magenta, cyan
                    const pal = [];
                    for (let i = 1; i <= 6; i++) {
                        const col = item["color" + i];
                        pal.push(col !== undefined ? col : item.accent);
                    }
                    const bg = item.background !== undefined ? item.background : item.bg;
                    // background ramp: bg -> bg1 -> bg2 (surfaceAlt) -> bg3 (accentHover)
                    const ramp = [bg, item.bg1 || bg, item.surfaceAlt || bg, item.accentHover || bg];
                    updated[modelData] = {
                        bg: bg,
                        accent: item.accent,
                        fg: item.foreground !== undefined ? item.foreground : item.fg,
                        palette: pal,
                        ramp: ramp,
                        light: root.luminance(bg) > 0.5
                    };
                    root.themePreviews = updated;
                }
            }
        }
    }

    // ── Layout ───────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // Header: title · search · random
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Text {
                text: "palette"
                color: theme.accent
                font {
                    family: "Material Symbols Outlined"
                    pixelSize: 26
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
                    text: root.selectedTheme !== "" ? "Current: " + root.selectedTheme : root.themeList.length + " available"
                    font.family: theme.font
                    font.pixelSize: 13
                    color: theme.fg1
                }
            }

            Item {
                Layout.fillWidth: true
            }

            // Search pill: typing filters straight away
            Rectangle {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 36
                radius: height / 2
                color: theme.surface
                border.width: 1
                border.color: filterInput.text !== "" ? root.tint(0.6) : Qt.rgba(1, 1, 1, 0.06)

                Text {
                    id: searchIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "search"
                    color: theme.fg1
                    font {
                        family: "Material Symbols Outlined"
                        pixelSize: 18
                    }
                }

                TextInput {
                    id: filterInput
                    anchors.left: searchIcon.right
                    anchors.leftMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: theme.fg
                    clip: true
                    font.family: theme.font
                    font.pixelSize: 13
                    focus: root.visible

                    // arrows move between cards; Enter applies; Ctrl+R picks at random
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Right) {
                            root.moveKb(1);
                        } else if (event.key === Qt.Key_Left) {
                            root.moveKb(-1);
                        } else if (event.key === Qt.Key_Down) {
                            root.moveKb(root.columns);
                        } else if (event.key === Qt.Key_Up) {
                            root.moveKb(-root.columns);
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.applyTheme(root.shownList[root.kbIndex]);
                        } else if (event.key === Qt.Key_R && (event.modifiers & Qt.ControlModifier)) {
                            root.applyRandom();
                        } else {
                            return;  // let the field handle typing (and Escape bubble up)
                        }
                        event.accepted = true;
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: filterInput.text.length === 0
                        text: "Type to filter"
                        color: theme.fg1
                        opacity: 0.7
                        font: filterInput.font
                    }
                }
            }

            // Random theme
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: height / 2
                color: randomMouse.containsMouse ? root.tint(0.2) : theme.surface
                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "shuffle"
                    color: randomMouse.containsMouse ? theme.accent : theme.fg1
                    font {
                        family: "Material Symbols Outlined"
                        pixelSize: 18
                    }
                }

                MouseArea {
                    id: randomMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.applyRandom()
                }
            }
        }

        // Cards
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridView {
                id: grid
                anchors.fill: parent
                clip: true
                readonly property real moreAbove: atYBeginning ? 0 : Math.max(0, Math.min(1, (contentY - originY) / 60))
                readonly property real moreBelow: atYEnd ? 0 : Math.max(0, Math.min(1, (contentHeight - height - (contentY - originY)) / 60))
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: gridFade
                }
                boundsBehavior: Flickable.StopAtBounds
                model: root.shownList

                cellWidth: Math.floor(width / root.columns)
                cellHeight: root.columns === 1 ? 120 : Math.round(cellWidth * 0.5)

                delegate: Item {
                    id: cell
                    required property var modelData
                    required property int index
                    width: grid.cellWidth
                    height: grid.cellHeight

                    readonly property var preview: root.themePreviews[modelData]
                    readonly property bool isActive: modelData === root.selectedTheme
                    readonly property bool isFocused: index === root.kbIndex
                    readonly property bool isFav: root.favourites.indexOf(modelData) >= 0
                    readonly property bool isApplying: root.applyingTheme === modelData
                    readonly property string thumb: root.thumbs[modelData] || ""
                    readonly property color pBg: preview ? preview.bg : theme.surface
                    readonly property color pAccent: preview ? preview.accent : theme.accent
                    readonly property color pFg: preview ? preview.fg : theme.fg

                    Item {
                        id: card
                        anchors.fill: parent
                        anchors.margins: 6
                        scale: cell.isFocused ? 1.02 : 1.0
                        Behavior on scale {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }

                        // Everything inside is clipped to the rounded card shape
                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskSource: cardMask
                                maskThresholdMin: 0.5
                                maskSpreadAtMin: 1.0
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: cell.pBg
                            }

                            // Theme wallpaper
                            Image {
                                anchors.fill: parent
                                source: cell.thumb !== "" ? "file://" + cell.thumb + "?v=" + root.thumbVersion : ""
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(640, 360)
                                asynchronous: true
                                smooth: true
                                opacity: status === Image.Ready ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }
                            }

                            // Theme background fading in from the left, so the name stays readable
                            Rectangle {
                                anchors.fill: parent
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {
                                        position: 0.0
                                        color: root.withAlpha(cell.pBg, 0.92)
                                    }
                                    GradientStop {
                                        position: 0.5
                                        color: root.withAlpha(cell.pBg, 0.55)
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: root.withAlpha(cell.pBg, 0.05)
                                    }
                                }
                            }
                        }

                        Item {
                            id: cardMask
                            anchors.fill: parent
                            layer.enabled: true
                            visible: false
                            Rectangle {
                                anchors.fill: parent
                                radius: root.cardRadius
                                antialiasing: true
                            }
                        }

                        // Border: the theme's own accent when active, a faint outline under the keyboard
                        Rectangle {
                            anchors.fill: parent
                            radius: root.cardRadius
                            color: "transparent"
                            antialiasing: true
                            border.width: cell.isActive ? 2 : cell.isFocused ? 1 : 0
                            border.color: cell.isActive ? cell.pAccent : root.withAlpha(theme.fg, 0.4)
                        }

                        // Name + palette, bottom left
                        Column {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 16
                            anchors.bottomMargin: 18
                            spacing: 8

                            Row {
                                spacing: 5
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
                                text: cell.modelData
                                color: cell.pFg
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, card.width - 32)
                                font {
                                    family: theme.font
                                    pixelSize: 15
                                    bold: true
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                root.kbTouched = true;
                                root.kbIndex = cell.index;
                            }
                            onClicked: root.applyTheme(cell.modelData)
                        }

                        // Favourite star, top left: always shown when starred, on hover otherwise
                        Text {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 10
                            text: "star"
                            color: cell.isFav ? cell.pAccent : cell.pFg
                            opacity: cell.isFav ? 1 : starMouse.containsMouse ? 0.9 : cell.isFocused ? 0.5 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                }
                            }
                            font {
                                family: "Material Symbols Outlined"
                                pixelSize: 18
                            }

                            MouseArea {
                                id: starMouse
                                anchors.fill: parent
                                anchors.margins: -6
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: {
                                    root.kbTouched = true;
                                    root.kbIndex = cell.index;
                                }
                                onClicked: root.toggleFavourite(cell.modelData)
                            }
                        }

                        // Badges, top right: applying spinner / active check, light or dark
                        Row {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 10
                            spacing: 6

                            Text {
                                visible: cell.isApplying
                                text: "progress_activity"
                                color: cell.pAccent
                                font {
                                    family: "Material Symbols Outlined"
                                    pixelSize: 18
                                }
                                RotationAnimator on rotation {
                                    from: 0
                                    to: 360
                                    duration: 900
                                    loops: Animation.Infinite
                                    running: cell.isApplying
                                }
                            }
                            Text {
                                visible: cell.isActive && !cell.isApplying
                                text: "check_circle"
                                color: cell.pAccent
                                font {
                                    family: "Material Symbols Outlined"
                                    pixelSize: 18
                                }
                            }
                            Text {
                                text: cell.preview && cell.preview.light ? "light_mode" : "dark_mode"
                                color: cell.pFg
                                opacity: 0.75
                                font {
                                    family: "Material Symbols Outlined"
                                    pixelSize: 18
                                }
                            }
                        }
                    }
                }
            }

            // Fade mask: transparent at an edge only when there's more to scroll that way
            // Fade mask: transparent at an edge only when there's more to scroll that way
            Item {
                id: gridFade
                anchors.fill: grid
                visible: false
                layer.enabled: true

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: Qt.rgba(1, 1, 1, 1 - grid.moreAbove)
                        }
                        GradientStop {
                            position: 0.08
                            color: "white"
                        }
                        GradientStop {
                            position: 0.88
                            color: "white"
                        }
                        GradientStop {
                            position: 1.0
                            color: Qt.rgba(1, 1, 1, 1 - grid.moreBelow)
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.shownList.length === 0
                text: root.themeList.length === 0 ? "No themes found" : "No themes match “" + filterInput.text + "”"
                font.family: theme.font
                font.pixelSize: 14
                color: theme.fg1
                opacity: 0.6
            }
        }

        // Footer: key hints
        Text {
            Layout.fillWidth: true
            text: "Type to filter  ·  arrows to move  ·  Enter to apply  ·  Ctrl+R random  ·  ★ to favourite"
            elide: Text.ElideRight
            font.family: theme.font
            font.pixelSize: 12
            color: theme.fg1
        }
    }
}
