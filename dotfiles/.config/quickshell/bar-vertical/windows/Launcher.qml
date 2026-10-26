import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Window {
    id: root

    required property var theme
    readonly property string uiFont: theme.font

    // -------------------------------------------------
    // WINDOW IDENTITY (IMPORTANT FOR HYPRLAND RULES)
    // -------------------------------------------------
    property string appId: "qs-launcher"

    width: 840
    height: 550

    minimumWidth: 440
    maximumWidth: 440
    minimumHeight: 450
    maximumHeight: 550

    visible: false
    flags: Qt.Window | Qt.FramelessWindowHint

    // Set a stable title for compositor matching
    title: "qs-launcher"

    // -------------------------------------------------
    // IPC
    // -------------------------------------------------
    IpcHandler {
        id: ipc
        target: "launcher"

        function open() {
            root.visible = true
            searchText = ""
            updateFilter()

            Qt.callLater(function () {
                input.forceActiveFocus()
            })
        }

        function close() {
            root.visible = false
        }

        function toggle() {
            if (root.visible) close()
            else open()
        }
    }

    // -------------------------------------------------
    // ESC (reliable, input-level)
    // -------------------------------------------------
    function closeLauncher() {
        root.visible = false
    }

    function open() { ipc.open() }
function close() { ipc.close() }
function toggle() { ipc.toggle() }

    // -------------------------------------------------
    // STATE
    // -------------------------------------------------
    property string searchText: ""
    property int selectedIndex: 0

    property var apps: []
    property var filteredApps: []
    property var parsedApps: []

    property bool calcMode: false

    // -------------------------------------------------
    // INIT
    // -------------------------------------------------
    Component.onCompleted: {
        Qt.callLater(function () {
            root.x = (Screen.width - width) / 2
            root.y = (Screen.height - height) / 2
        })
        scanner.running = true
    }

    // -------------------------------------------------
    // CALCULATOR
    // -------------------------------------------------
    function evaluate(expr) {
        try {
            if (!/^[0-9+\-*/().\s]+$/.test(expr))
                return "invalid"

            return Function("return (" + expr + ")")().toString()
        } catch (e) {
            return "error"
        }
    }

    // -------------------------------------------------
    // FILTER LOGIC
    // -------------------------------------------------
    function updateFilter() {
        var q = searchText.trim()

        if (q.indexOf("=") === 0) {
            calcMode = true

            var expr = q.slice(1).trim()
            var result = evaluate(expr)

            filteredApps = [{
                name: expr + " = " + result,
                exec: "",
                icon: "accessories-calculator"
            }]

            selectedIndex = 0
            return
        }

        calcMode = false

        var lower = q.toLowerCase()
        var results = []

        for (var i = 0; i < apps.length; i++) {
            var app = apps[i]
            var name = app.name.toLowerCase()

            var score = 0
            if (lower === "") score = 1
            else if (name.indexOf(lower) === 0) score = 100
            else if (name.indexOf(lower) !== -1) score = 50

            if (score > 0) {
                results.push({ app: app, score: score })
            }
        }

        results.sort(function (a, b) {
            return b.score - a.score
        })

        var out = []
        for (var j = 0; j < results.length; j++) {
            out.push(results[j].app)
        }

        filteredApps = out
        selectedIndex = 0
    }

    function launch(app) {
        if (!app) return

        if (calcMode) {
            root.visible = false
            return
        }

        Quickshell.execDetached(["sh", "-c", app.exec])
        root.visible = false
    }

    // -------------------------------------------------
    // APP SCANNER
    // -------------------------------------------------
    Process {
        id: scanner

        command: ["sh", "-c", "
    for file in \
        /usr/share/applications/*.desktop \
        ~/.local/share/applications/*.desktop \
        /var/lib/flatpak/exports/share/applications/*.desktop \
        ~/.local/share/flatpak/exports/share/applications/*.desktop
    do
        [ -f \"$file\" ] || continue

        grep -qiE '^(NoDisplay=true|Terminal=true|Type=Service)' \"$file\" && continue

        name=$(grep -m1 '^Name=' \"$file\" | cut -d= -f2-)
        exec=$(grep -m1 '^Exec=' \"$file\" | cut -d= -f2- | cut -d% -f1)
        icon=$(grep -m1 '^Icon=' \"$file\" | cut -d= -f2-)

        [ -z \"$icon\" ] && icon=\"application-x-executable\"

        if [ -n \"$name\" ] && [ -n \"$exec\" ]; then
            echo \"$name|$exec|$icon\"
        fi
    done | sort -f
"]

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: function (data) {
                if (!data) return

                var line = data.trim()
                if (line === "") return

                var parts = line.split("|")
                if (parts.length !== 3) return

                var name = parts[0].trim()
                var exec = parts[1].trim()
                var icon = parts[2].trim()

                for (var i = 0; i < root.parsedApps.length; i++) {
                    if (root.parsedApps[i].name === name)
                        return
                }

                root.parsedApps.push({
                    name: name,
                    exec: exec,
                    icon: icon
                })
            }
        }

        onExited: function () {
            root.apps = root.parsedApps.slice()
            root.filteredApps = root.apps
            root.updateFilter()
        }
    }

    // -------------------------------------------------
    // UI ROOT
    // -------------------------------------------------
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#1e1e2e"
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // SEARCH BAR
            Rectangle {
                width: parent.width
                height: 42
                radius: 8
                color: "#313244"

                Text {
                    text: ""
                    color: "#585b70"
                    font.family: root.uiFont
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField {
                    id: input

                    anchors.fill: parent
                    anchors.leftMargin: 36
                    anchors.rightMargin: 8

                    text: searchText
                    color: "#cdd6f4"
                    background: null
                    font.family: root.uiFont

                    onTextChanged: {
                        searchText = text
                        updateFilter()
                    }

                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Escape) {
                            closeLauncher()
                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_Down) {
                            selectedIndex = Math.min(selectedIndex + 1, filteredApps.length - 1)
                            event.accepted = true
                        }

                        if (event.key === Qt.Key_Up) {
                            selectedIndex = Math.max(selectedIndex - 1, 0)
                            event.accepted = true
                        }

                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (filteredApps.length > 0)
                                launch(filteredApps[selectedIndex])
                            event.accepted = true
                        }
                    }
                }
            }

            // RESULTS
            ListView {
                width: parent.width
                height: parent.height - 70

                model: filteredApps
                clip: true
                currentIndex: selectedIndex

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 40
                    radius: 6

                    color: index === selectedIndex ? "#45475a" : "transparent"

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        Image {
                            width: 22
                            height: 22
                            source: modelData.icon
                                ? "image://icon/" + modelData.icon
                                : "image://icon/application-x-executable"
                        }

                        Text {
                            text: modelData.name
                            color: "#cdd6f4"
                            font.family: root.uiFont
                            font.pixelSize: 13
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedIndex = index
                            root.launch(modelData)
                        }
                    }
                }
            }
        }
    }
}