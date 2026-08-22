import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root

    signal closeRequested()

    // =================================================
    // THEME
    // =================================================
    required property var theme
    readonly property string uiFont: theme.font
    // =================================================
    // STATE
    // =================================================
    property bool launcherVisible: false
    property string searchText: ""
    property int selectedIndex: 0
    property var apps: []
    property var filteredApps: []
    property var parsedApps: []
    property bool calcMode: false

    // =================================================
    // CALCULATOR
    // =================================================

    function evaluate(expr) {
        try {
            if (!/^[0-9+\-*/().\s]+$/.test(expr))
                return "invalid"

            return Function(
                "return (" + expr + ")"
            )().toString()

        } catch (e) {
            return "error"
        }
    }
    // =================================================
    // FILTER LOGIC
    // =================================================
    function updateFilter() {
        var q =
            searchText.trim()
        // ---------------------------------------------
        // CALCULATOR MODE
        // ---------------------------------------------

        if (
            q.indexOf("=") === 0
        ) {
            calcMode = true
            var expr = q.slice(1).trim()
            var result = evaluate(expr)
            filteredApps = [{ name: expr + " = " + result, exec: "", icon: "accessories-calculator" }]
            selectedIndex = 0
            return
        }
        // ---------------------------------------------
        // APPLICATION MODE
        // ---------------------------------------------

        calcMode = false
        var lower = q.toLowerCase()
        var results = []


        for (
            var i = 0;
            i < apps.length;
            i++
        ) {
            var app = apps[i]
            var name = app.name.toLowerCase()
            var score = 0

            if (
                lower === ""
            ) {

                score =
                    1

            } else if (
                name.indexOf(lower) === 0
            ) {

                score = 100

            } else if (
                name.indexOf(lower) !== -1
            ) {
                score = 50
            }

            if (
                score > 0
            ) {

                results.push({

                    app:
                        app,


                    score:
                        score
                })
            }
        }
        // ---------------------------------------------
        // SORT RESULTS
        // ---------------------------------------------

        results.sort(
            function (a, b) {
                return b.score - a.score
            }
        )
        // ---------------------------------------------
        // BUILD FILTERED LIST
        // ---------------------------------------------
        var out = []
        for (
            var j = 0;
            j < results.length;
            j++
        ) {

            out.push(
                results[j].app
            )
        }

        filteredApps = out
        selectedIndex = 0
    }
    // =================================================
    // LAUNCH APPLICATION
    // =================================================

    function launch(app) {

    if (!app)
        return

    if (calcMode) {
        closeLauncher()
        return
    }

    Quickshell.execDetached([
        "sh",
        "-c",
        app.exec
    ])

    closeLauncher()
}
    // =================================================
    // OPEN LAUNCHER
    // =================================================

    function openLauncher() {

        launcherVisible = true
        searchText = ""

        updateFilter()

        Qt.callLater(
            function () {
                input.forceActiveFocus()
            }
        )
    }
// =================================================
// CLOSE LAUNCHER
// =================================================

function closeLauncher() {
    closeRequested()
}

    // =================================================
    // APPLICATION SCANNER
    // =================================================

    Process {
    id: scanner

    command: [
        "sh",
        "-c",
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

                nodisplay=$(awk -F= '/NoDisplay=/ {print $2; exit}' "$file" 2>/dev/null | tr -d '[:space:]')
                hidden=$(awk -F= '/Hidden=/ {print $2; exit}' "$file" 2>/dev/null | tr -d '[:space:]')
                type=$(awk -F= '/Type=/ {print $2; exit}' "$file" 2>/dev/null | tr -d '[:space:]')

                [ "$nodisplay" = "true" ] && continue
                [ "$hidden" = "true" ] && continue
                [ "$type" = "Service" ] && continue

                name=$(awk -F= '/Name=/ {print $2; exit}' "$file" 2>/dev/null | tr -d '\\r')
                exec=$(awk -F= '/Exec=/ {print $2; exit}' "$file" 2>/dev/null | tr -d '\\r')
                icon=$(awk -F= '/Icon=/ {print $2; exit}' "$file" 2>/dev/null | tr -d '\\r')

                [ -z "$name" ] || [ -z "$exec" ] && continue

                if echo "$file" | grep -q '/flatpak/exports/'; then
                    flatpak_id=$(basename "$file" .desktop)
                    exec="flatpak run $flatpak_id"
                else
                    exec=$(printf '%s' "$exec" | sed -E 's/[[:space:]]+%[fFuUdDnNickvm]//g')
                fi

                [ -z "$icon" ] && icon="application-x-executable"

                printf '%s|%s|%s\\n' "$name" "$exec" "$icon"
            done
        done | sort -f
        `
    ]

        stdout:
            SplitParser {

            splitMarker:
                "\n"

            onRead:
                function (data) {

                    if (
                        !data
                    ) {
                        return
                    }


                    var line =
                        data.trim()

                    if (
                        line === ""
                    ) {
                        return
                    }

                    var parts =
                        line.split("|")

                    if (
                        parts.length < 3
                    ) {
                        return
                    }

                    var name =
                        parts[0].trim()

                    var exec =
                        parts[1].trim()

                    var icon =
                        parts
                        .slice(2)
                        .join("|")
                        .trim()

                    if (
                        !name ||
                        !exec
                    ) {
                        return
                    }
                    // ---------------------------------
                    // REMOVE DUPLICATES
                    // ---------------------------------

                    for (
                        var i = 0;
                        i < root.parsedApps.length;
                        i++
                    ) {

                        if (
                            root.parsedApps[i].name ===
                            name
                        ) {

                            return
                        }
                    }
                    // ---------------------------------
                    // ADD APPLICATION
                    // ---------------------------------

                    root.parsedApps.push({

                        name: name,
                        exec: exec,
                        icon: icon || "application-x-executable"
                    })
                }
        }

        // ---------------------------------------------
        // PROCESS FINISHED
        // ---------------------------------------------

        onExited:
            function (
                exitCode,
                exitStatus
            ) {

                root.apps = root.parsedApps.slice()
                root.filteredApps = root.apps
                root.updateFilter()
            }
    }
    // =================================================
    // INITIALIZATION
    // =================================================

    Component.onCompleted: {
        root.parsedApps = []
        scanner.running = true
    }

    // =================================================
    // UI
    // =================================================

    Rectangle {

        anchors.fill: parent
        visible: root.launcherVisible
        radius: 12
        color: theme.bg
        clip: true


        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12
            // -----------------------------------------
            // SEARCH BAR
            // -----------------------------------------

            Rectangle {

                width: parent.width
                height: 42
                radius: 8
                color: theme.surface


                Text {

                    text: ""
                    color: theme.textMuted
                    font.family: root.uiFont


                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                }

                TextField {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: 36
                    anchors.rightMargin: 8
                    text: root.searchText
                    color: theme.fg
                    background: null
                    font.family: root.uiFont


                    onTextChanged: {
                        root.searchText = text
                        root.updateFilter()
                    }


                    Keys.onPressed:
                        function (event) {

                        if (
                            event.key ===
                            Qt.Key_Escape
                        ) {

                            root.closeLauncher()
                            event.accepted = true

                            return
                        }


                        if (
                            event.key ===
                            Qt.Key_Down
                        ) {

                            root.selectedIndex =
                                Math.min(

                                    root.selectedIndex +
                                    1,

                                    root.filteredApps.length -
                                    1
                                )
                            event.accepted = true
                        }


                        if (
                            event.key === Qt.Key_Up
                        ) {

                            root.selectedIndex =
                                Math.max(

                                    root.selectedIndex -
                                    1,

                                    0
                                )
                            event.accepted = true
                        }

                        if (

                            event.key ===
                            Qt.Key_Return ||

                            event.key ===
                            Qt.Key_Enter

                        ) {

                            if (

                                root.filteredApps.length >
                                0

                            ) {

                                root.launch(

                                    root.filteredApps[
                                        root.selectedIndex
                                    ]
                                )
                            }


                            event.accepted =
                                true
                        }
                    }
                }
            }
            // -----------------------------------------
            // RESULTS
            // -----------------------------------------

            ListView {

                width: parent.width
                height: parent.height - 70
                model: root.filteredApps

                clip: true


                currentIndex: root.selectedIndex


                delegate:
                    Rectangle {
                    width: ListView.view.width
                    height: 40
                    radius: 6


                    color:
                        index ===
                        root.selectedIndex

                        ? theme.surfaceAlt

                        : "transparent"

                    Row {

                        anchors {

                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 10
                        }

                        spacing: 10

                        Image {
    id: appIcon
    width: 22
    height: 22

    sourceSize: Qt.size(96, 96)   // or 48, 48
    smooth: true
    mipmap: true
    antialiasing: true
    fillMode: Image.PreserveAspectFit

    source: {
        if (modelData.icon)
            return "image://icon/" + modelData.icon
        return "image://icon/application-x-executable"
    }
}

                        Text {
                            text: modelData.name
                            color: theme.fg

                            font {
                                family: root.uiFont
                                pixelSize: 13
                            }
                        }
                    }

                    MouseArea {

                        anchors.fill: parent


                        onClicked: {

                            root.selectedIndex = index
                            root.launch(
                                modelData
                            )
                        }
                    }
                }
            }
        }
    }
}