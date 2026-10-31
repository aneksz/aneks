// components/GitModule.qml
// Commit and push the dotfiles repo from the bar.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property var theme
    property string repoPath: Quickshell.env("HOME") + "/Projects/aneks"

    // Tells shell.qml to refresh the bar button's dot
    signal refreshed()

    property string branch: ""
    property var files: []        // [{ code: "M", path: "..." }]
    property var commits: []      // ["abc1234 message", ...]
    property int ahead: 0
    property bool busy: false
    property string statusText: ""
    property bool statusError: false

    readonly property bool hasChanges: files.length > 0
    readonly property bool canCommit: !busy && hasChanges && messageInput.text.trim().length > 0
    readonly property bool canPushOnly: !busy && !hasChanges && ahead > 0

    onVisibleChanged: {
        if (visible) {
            statusText = ""
            refresh()
        }
    }

    function refresh() {
        statusProc.running = true
    }

    function commitAndPush() {
        if (!(canCommit || canPushOnly)) return
        busy = true
        statusError = false
        statusText = hasChanges ? "Committing and pushing…" : "Pushing…"
        commitProc.command = ["bash", "-c",
            'cd "$1" || exit 1\n' +
            'if [ -n "$(git status --porcelain)" ]; then\n' +
            '  git add -A && git commit -q -m "$2" || exit 1\n' +
            'fi\n' +
            'git push 2>&1',
            "_", repoPath, messageInput.text.trim()]
        commitProc.running = true
    }

    function pull() {
        if (busy) return
        busy = true
        statusError = false
        statusText = "Pulling…"
        pullProc.running = true
    }

    // Last non-empty line of command output, for the status line
    function lastLine(text) {
        const lines = (text || "").trim().split("\n").filter(l => l.trim().length > 0)
        return lines.length ? lines[lines.length - 1].trim() : ""
    }

    // ============================================================
    // PROCESSES
    // ============================================================

    // branch / status / log / unpushed count, separated by "@@"
    Process {
        id: statusProc
        command: ["bash", "-c",
            'cd "$1" || exit 1\n' +
            'git branch --show-current; echo @@\n' +
            'git status --porcelain; echo @@\n' +
            'git log --oneline -5; echo @@\n' +
            'git rev-list --count @{u}..HEAD 2>/dev/null || echo 0',
            "_", root.repoPath]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.split("@@")
                if (parts.length < 4) return
                root.branch = parts[0].trim()
                root.files = parts[1].split("\n")
                    .filter(l => l.length > 3)
                    .map(l => ({ code: l.substring(0, 2).trim() || "?", path: l.substring(3) }))
                root.commits = parts[2].trim().split("\n").filter(l => l.length > 0)
                root.ahead = parseInt(parts[3].trim()) || 0
                root.refreshed()
            }
        }
    }

    Process {
        id: commitProc
        stdout: StdioCollector { id: commitOut }
        stderr: StdioCollector { id: commitErr }
        onExited: function(exitCode) {
            root.busy = false
            if (exitCode === 0) {
                root.statusError = false
                root.statusText = "Pushed to GitHub"
                messageInput.text = ""
            } else {
                root.statusError = true
                root.statusText = root.lastLine(commitErr.text) || root.lastLine(commitOut.text) || "Commit or push failed"
            }
            root.refresh()
        }
    }

    Process {
        id: pullProc
        command: ["git", "-C", root.repoPath, "pull", "--ff-only"]
        stdout: StdioCollector { id: pullOut }
        stderr: StdioCollector { id: pullErr }
        onExited: function(exitCode) {
            root.busy = false
            root.statusError = exitCode !== 0
            root.statusText = exitCode === 0
                ? (root.lastLine(pullOut.text) || "Up to date")
                : (root.lastLine(pullErr.text) || "Pull failed")
            root.refresh()
        }
    }

    // ============================================================
    // UI
    // ============================================================

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 14

        // ---------- header ----------
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "commit"
                color: root.theme.accent
                font { family: "Material Symbols Outlined"; pixelSize: 24 }
            }

            ColumnLayout {
                spacing: 0
                Text {
                    text: "Dotfiles"
                    color: root.theme.fg
                    font { family: root.theme.font; pixelSize: 22; bold: true }
                }
                Text {
                    text: (root.branch || "…") + "  ·  " +
                          (root.hasChanges ? root.files.length + " changed" : "no changes") +
                          (root.ahead > 0 ? "  ·  " + root.ahead + " to push" : "")
                    color: root.theme.fg3
                    font { family: root.theme.font; pixelSize: 12 }
                }
            }

            Item { Layout.fillWidth: true }

            MouseArea {
                width: refreshText.implicitWidth
                height: refreshText.implicitHeight
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.refresh()

                Text {
                    id: refreshText
                    text: "Refresh"
                    color: parent.containsMouse ? root.theme.accent : root.theme.fg3
                    font { family: root.theme.font; pixelSize: 14 }
                }
            }
        }

        // ---------- changed files ----------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            radius: 12
            color: root.theme.bgAlt
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.06)

            Text {
                anchors.centerIn: parent
                visible: !root.hasChanges
                text: "Working tree clean"
                color: root.theme.fg3
                font { family: root.theme.font; pixelSize: 13 }
            }

            ListView {
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                spacing: 4
                model: root.files
                visible: root.hasChanges

                delegate: RowLayout {
                    required property var modelData
                    width: ListView.view.width
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 18
                        text: modelData.code === "??" ? "+" : modelData.code.charAt(0)
                        color: modelData.code.indexOf("D") >= 0 ? root.theme.error
                             : (modelData.code === "??" || modelData.code.indexOf("A") >= 0) ? root.theme.success
                             : root.theme.warning
                        font { family: root.theme.font; pixelSize: 13; bold: true }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: modelData.path.replace(/^dotfiles\/\.config\//, "")
                        elide: Text.ElideMiddle
                        color: root.theme.fg
                        font { family: root.theme.font; pixelSize: 13 }
                    }
                }
            }
        }

        // ---------- commit message ----------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: 10
            color: root.theme.bgAlt
            border.width: 1
            border.color: messageInput.activeFocus ? root.theme.accent : Qt.rgba(1, 1, 1, 0.06)

            TextInput {
                id: messageInput
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                color: root.theme.fg
                font { family: root.theme.font; pixelSize: 14 }
                focus: root.visible
                enabled: !root.busy
                onAccepted: root.commitAndPush()

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: messageInput.text.length === 0
                    text: root.hasChanges ? "Commit message…" : "Nothing to commit"
                    color: root.theme.fg3
                    font: messageInput.font
                }
            }
        }

        // ---------- buttons ----------
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            component PanelButton: Rectangle {
                id: btn
                property string label: ""
                property bool enabledState: true
                property bool primary: false
                signal activated()

                Layout.preferredHeight: 36
                radius: 8
                opacity: enabledState ? 1 : 0.4
                color: primary
                    ? Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, btnMouse.containsMouse && enabledState ? 0.25 : 0.15)
                    : (btnMouse.containsMouse && enabledState ? root.theme.surfaceAlt : root.theme.bgAlt)
                border.width: 1
                border.color: primary ? root.theme.accent : Qt.rgba(1, 1, 1, 0.06)

                Text {
                    anchors.centerIn: parent
                    text: btn.label
                    color: btn.primary ? root.theme.accent : root.theme.fg
                    font { family: root.theme.font; pixelSize: 13; bold: true }
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: btn.enabledState ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: if (btn.enabledState) btn.activated()
                }
            }

            PanelButton {
                Layout.fillWidth: true
                primary: true
                label: root.canPushOnly ? "Push" : "Commit & Push"
                enabledState: root.canCommit || root.canPushOnly
                onActivated: root.commitAndPush()
            }

            PanelButton {
                Layout.preferredWidth: 90
                label: "Pull"
                enabledState: !root.busy
                onActivated: root.pull()
            }
        }

        // ---------- status ----------
        Text {
            Layout.fillWidth: true
            text: root.statusText
            elide: Text.ElideRight
            color: root.statusError ? root.theme.error : root.theme.success
            font { family: root.theme.font; pixelSize: 12 }
        }

        // ---------- recent commits ----------
        Text {
            text: "Recent commits"
            color: root.theme.fg3
            font { family: root.theme.font; pixelSize: 12; bold: true }
        }

        Repeater {
            model: root.commits

            delegate: RowLayout {
                required property string modelData
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: modelData.split(" ")[0]
                    color: root.theme.accent
                    font { family: root.theme.font; pixelSize: 12 }
                }
                Text {
                    Layout.fillWidth: true
                    text: modelData.substring(modelData.indexOf(" ") + 1)
                    elide: Text.ElideRight
                    color: root.theme.fg
                    font { family: root.theme.font; pixelSize: 12 }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
