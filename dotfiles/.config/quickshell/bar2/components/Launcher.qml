import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    signal closeRequested()

    // ── Theme ───────────────────────────────────────────────────────
    required property var theme
    readonly property string uiFont: theme.font

    // Terminal used for Terminal=true apps (btop, nvim, ...)
    property var terminalCmd: ["kitty", "-e"]

    // Entries whose name contains any of these (case-insensitive) are hidden.
    // Add anything else that clutters the list.
    property var hiddenApps: [
        "avahi", "ssh server browser", "vnc server browser",
        "qt assistant", "qt designer", "qt linguist", "qdbusviewer",
        "qv4l2", "qvidcap", "lstopo"
    ]

    // Second line under each app name (GenericName / Comment from the .desktop file)
    property bool showSubtitle: true

    // ── State ───────────────────────────────────────────────────────
    property bool launcherVisible: false
    property string searchText: ""
    property int selectedIndex: 0
    property var apps: []
    property var filteredApps: []
    property var parsedApps: []
    property var seenNames: ({})
    property bool calcMode: false
    property string calcResult: ""

    // ── Calculator ──────────────────────────────────────────────────
    function evaluate(expr) {
        if (expr === "")
            return ""
        try {
            if (!/^[0-9+\-*/%^().\s]+$/.test(expr))
                return "invalid"
            const v = Function("return (" + expr.replace(/\^/g, "**") + ")")()
            if (typeof v !== "number" || !isFinite(v))
                return "error"
            return parseFloat(v.toPrecision(12)).toString()
        } catch (e) {
            return "error"
        }
    }

    // ── Search ──────────────────────────────────────────────────────
    // Scores one app name against the query tokens (0 = no match).
    function scoreName(name, lower, tokens) {
        if (lower === "")
            return 1
        if (name.indexOf(lower) === 0)
            return 100

        const words = name.split(/[\s\-_.]+/).filter(w => w.length > 0)

        // every token must match the start of some word
        let allWordStarts = true
        for (const t of tokens) {
            if (!words.some(w => w.indexOf(t) === 0)) { allWordStarts = false; break }
        }
        if (allWordStarts)
            return 75

        // acronym: "vsc" -> Visual Studio Code
        if (tokens.length === 1 && words.map(w => w[0]).join("").indexOf(lower) === 0)
            return 60

        if (name.indexOf(lower) !== -1)
            return 50

        return 0
    }

    function updateFilter() {
        const q = searchText.trim()

        if (q.indexOf("=") === 0) {
            calcMode = true
            const expr = q.slice(1).trim()
            calcResult = evaluate(expr)
            const label = expr === "" ? "Type an expression"
                        : expr + " = " + calcResult
            filteredApps = [{ name: label, exec: "", icon: "accessories-calculator" }]
            selectedIndex = 0
            return
        }

        calcMode = false
        const lower = q.toLowerCase()
        const tokens = lower.split(/\s+/).filter(t => t.length > 0)
        const results = []

        for (let i = 0; i < apps.length; i++) {
            const s = scoreName(apps[i].name.toLowerCase(), lower, tokens)
            if (s > 0)
                results.push({ app: apps[i], score: s })
        }

        // best score first, then alphabetical
        results.sort((a, b) => (b.score - a.score) || a.app.name.localeCompare(b.app.name))

        filteredApps = results.map(r => r.app)
        selectedIndex = 0
    }

    // ── Launch / open / close ───────────────────────────────────────
    function launch(app) {
        if (!app)
            return

        if (calcMode) {
            if (calcResult !== "" && calcResult !== "invalid" && calcResult !== "error") {
                Quickshell.execDetached(["wl-copy", calcResult])
                closeLauncher()
            }
            return
        }

        const cmd = app.terminal
            ? root.terminalCmd.concat(["sh", "-c", app.exec])
            : ["sh", "-c", app.exec]
        Quickshell.execDetached(cmd)
        closeLauncher()
    }

    function openLauncher() {
        launcherVisible = true
        searchText = ""
        updateFilter()
        Qt.callLater(() => input.forceActiveFocus())
    }

    function closeLauncher() {
        closeRequested()
    }

    function move(delta) {
        if (filteredApps.length === 0)
            return
        selectedIndex = Math.max(0, Math.min(selectedIndex + delta, filteredApps.length - 1))
    }

    // ── Application scanner ─────────────────────────────────────────
    // Output per app: name|description|exec|icon|terminal
    Process {
        id: scanner

        command: [
            "sh", "-c",
            `
            for dir in \
                "/usr/share/applications" \
                "$HOME/.local/share/applications" \
                "/var/lib/flatpak/exports/share/applications" \
                "$HOME/.local/share/flatpak/exports/share/applications"
            do
                [ ! -d "$dir" ] && continue

                for file in "$dir"/*.desktop
                do
                    [ ! -r "$file" ] && continue

                    nodisplay=$(sed -n 's/^NoDisplay=//p' "$file" | head -n1 | tr -d '[:space:]')
                    hidden=$(sed -n 's/^Hidden=//p' "$file" | head -n1 | tr -d '[:space:]')
                    type=$(sed -n 's/^Type=//p' "$file" | head -n1 | tr -d '[:space:]')
                    terminal=$(sed -n 's/^Terminal=//p' "$file" | head -n1 | tr -d '[:space:]')

                    [ "$nodisplay" = "true" ] && continue
                    [ "$hidden" = "true" ] && continue
                    [ "$type" = "Service" ] && continue

                    # honour OnlyShowIn / NotShowIn for the current desktop (e.g. Hyprland)
                    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
                        only=$(sed -n 's/^OnlyShowIn=//p' "$file" | head -n1 | tr -d '[:space:]')
                        notin=$(sed -n 's/^NotShowIn=//p' "$file" | head -n1 | tr -d '[:space:]')
                        if [ -n "$only" ]; then
                            case ";$only;" in *";$XDG_CURRENT_DESKTOP;"*) ;; *) continue ;; esac
                        fi
                        if [ -n "$notin" ]; then
                            case ";$notin;" in *";$XDG_CURRENT_DESKTOP;"*) continue ;; esac
                        fi
                    fi

                    name=$(sed -n 's/^Name=//p' "$file" | head -n1 | tr -d '\\r')
                    exec=$(sed -n 's/^Exec=//p' "$file" | head -n1 | tr -d '\\r')
                    icon=$(sed -n 's/^Icon=//p' "$file" | head -n1 | tr -d '\\r')
                    generic=$(sed -n 's/^GenericName=//p' "$file" | head -n1 | tr -d '\\r' | tr '|' ' ')
                    comment=$(sed -n 's/^Comment=//p' "$file" | head -n1 | tr -d '\\r' | tr '|' ' ')
                    if [ -n "$generic" ]; then desc="$generic"; else desc="$comment"; fi

                    [ -z "$name" ] || [ -z "$exec" ] && continue

                    if echo "$file" | grep -q '/flatpak/exports/'; then
                        flatpak_id=$(basename "$file" .desktop)
                        exec="flatpak run $flatpak_id"
                    else
                        exec=$(printf '%s' "$exec" | sed -E 's/[[:space:]]+%[fFuUdDnNickvm]//g')
                    fi

                    [ -z "$icon" ] && icon="application-x-executable"
                    [ "$terminal" = "true" ] || terminal="false"

                    printf '%s|%s|%s|%s|%s\\n' "$name" "$desc" "$exec" "$icon" "$terminal"
                done
            done | sort -f
            `
        ]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const line = (data || "").trim()
                if (line === "")
                    return

                const parts = line.split("|")
                if (parts.length < 5)
                    return

                // exec may itself contain "|", so take icon/terminal from the end
                const terminal = parts[parts.length - 1].trim() === "true"
                const icon = parts[parts.length - 2].trim()
                const name = parts[0].trim()
                const desc = parts[1].trim()
                const exec = parts.slice(2, -2).join("|").trim()

                if (!name || !exec || root.seenNames[name])
                    return

                const lname = name.toLowerCase()
                if (root.hiddenApps.some(h => lname.indexOf(h) !== -1))
                    return
                root.seenNames[name] = true

                root.parsedApps.push({
                    name: name,
                    exec: exec,
                    desc: desc,
                    icon: icon || "application-x-executable",
                    terminal: terminal
                })
            }
        }

        onExited: {
            root.apps = root.parsedApps.slice()
            root.updateFilter()
        }
    }

    Component.onCompleted: {
        root.parsedApps = []
        root.seenNames = ({})
        scanner.running = true
    }

    // ── UI ──────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        visible: root.launcherVisible
        radius: 24
        color: theme.bg
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // Search bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                border.width: 1
                radius: 12
                border.color: theme.accent
                color: "transparent"

                Text {
                    id: searchIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.calcMode ? "󰃬" : " 󰍉"
                    font.family: root.uiFont
                    font.pixelSize: 16
                    color: theme.accent
                }

                TextField {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: 32
                    anchors.rightMargin: 4
                    text: root.searchText
                    color: theme.fg
                    background: null
                    font.family: root.uiFont
                    font.pixelSize: 15
                    placeholderText: "Search apps  ·  start with = to calculate"
                    placeholderTextColor: theme.textMuted
                    verticalAlignment: TextInput.AlignVCenter

                    onTextChanged: {
                        root.searchText = text
                        root.updateFilter()
                    }

                    Keys.onPressed: event => {
                        const ctrl = event.modifiers & Qt.ControlModifier

                        if (event.key === Qt.Key_Escape) {
                            root.closeLauncher()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_J || event.key === Qt.Key_N))) {
                            root.move(1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_K || event.key === Qt.Key_P))) {
                            root.move(-1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_PageDown) {
                            root.move(8)
                            event.accepted = true
                        } else if (event.key === Qt.Key_PageUp) {
                            root.move(-8)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.filteredApps.length > 0)
                                root.launch(root.filteredApps[root.selectedIndex])
                            event.accepted = true
                        }
                    }
                }
            }


            // Results
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    anchors.fill: parent
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    spacing: 2
                    model: root.filteredApps
                    currentIndex: root.selectedIndex

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool selected: index === root.selectedIndex

                        width: ListView.view.width
                        height: root.showSubtitle ? 56 : 44
                        radius: 12
                        color: selected ? Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.12)
                             : rowMouse.containsMouse ? Qt.rgba(theme.surfaceAlt.r, theme.surfaceAlt.g, theme.surfaceAlt.b, 0.6)
                             : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }

                        // accent bar on the selected row
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 3
                            height: parent.height * 0.6
                            radius: 2
                            color: theme.accent
                            opacity: row.selected ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 100 } }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 12
                            spacing: 12

                            // icon tile
                            Rectangle {
                                Layout.preferredWidth: root.showSubtitle ? 40 : 32
                                Layout.preferredHeight: root.showSubtitle ? 40 : 32
                                radius: 10
                                color: theme.surface

                                Image {
                                    anchors.centerIn: parent
                                    width: root.showSubtitle ? 26 : 22
                                    height: width
                                    sourceSize: Qt.size(96, 96)
                                    smooth: true
                                    mipmap: true
                                    fillMode: Image.PreserveAspectFit
                                    source: "image://icon/" + (row.modelData.icon || "application-x-executable")
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    Layout.fillWidth: true
                                    text: row.modelData.name
                                    elide: Text.ElideRight
                                    color: row.selected ? (theme.fg0 || theme.fg) : theme.fg
                                    font.family: root.uiFont
                                    font.pixelSize: 14
                                    font.bold: row.selected
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: root.showSubtitle && text !== ""
                                    text: row.modelData.desc || ""
                                    elide: Text.ElideRight
                                    color: theme.textMuted
                                    font.family: root.uiFont
                                    font.pixelSize: 11
                                }
                            }

                            Text {
                                visible: row.modelData.terminal === true
                                text: "󰆍"
                                color: theme.textMuted
                                font.family: root.uiFont
                                font.pixelSize: 14
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedIndex = row.index
                                root.launch(row.modelData)
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.filteredApps.length === 0
                    text: "No results"
                    color: theme.textMuted
                    opacity: 0.5
                    font.family: root.uiFont
                    font.pixelSize: 14
                }
            }

            // Footer
            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: root.calcMode ? "Enter to copy result · Esc to close"
                                        : "↑↓ navigate · Enter launch · Esc close"
                    color: theme.textMuted
                    font.family: root.uiFont
                    font.pixelSize: 12
                }
                Text {
                    visible: !root.calcMode
                    text: root.filteredApps.length + " apps"
                    color: theme.textMuted
                    font.family: root.uiFont
                    font.pixelSize: 12
                }
            }
        }
    }
}
