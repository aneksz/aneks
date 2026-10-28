// components/UpdatesModule.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    focus: false
    signal closePanel()
    signal updatesFinished()
    
    required property var theme

    property int archCount: 0
    property int aurCount: 0
    property int flatpakCount: 0
    property string archChecked: "—"
    property string aurChecked: "—"
    property string flatpakChecked: "—"
    property bool checking: false
    property var checkAll: null

    readonly property int totalCount: archCount + aurCount + flatpakCount

    onVisibleChanged: {
    if (visible && root.checkAll) {
        root.checkAll()
    }
}

// ============================================================
// ACTIONS
// ============================================================

Process { id: archUpdateProcess; command: ["kitty", "-e", "pkexec", "bash", "-c", "pacman -Syu"]; onExited: { root.checkAll(); root.updatesFinished() } }
Process { id: aurUpdateProcess; command: ["kitty", "-e", "bash", "-c", "yay -Syu --aur"]; onExited: { root.checkAll(); root.updatesFinished() } }
Process { id: flatpakUpdateProcess; command: ["kitty", "-e", "bash", "-c", "flatpak update"]; onExited: { root.checkAll(); root.updatesFinished() } }

function updateArch() {
    archUpdateProcess.running = true
}

function updateAur() {
    aurUpdateProcess.running = true
}

function updateFlatpak() {
    flatpakUpdateProcess.running = true
}

    // ============================================================
    // UI
    // ============================================================

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "󰅢 System Updates"
                color: root.theme.fg
                font { family: root.theme.font; pixelSize: 22; bold: true }
            }

            Item { Layout.fillWidth: true }

            MouseArea {
                width: refreshText.implicitWidth
                height: refreshText.implicitHeight
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.checkAll()

                Text {
                    id: refreshText
                    text: root.checking ? "Checking…" : "Refresh"
                    color: parent.containsMouse ? root.theme.accent : root.theme.fg3
                    font { family: root.theme.font; pixelSize: 14 }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            component UpdateRow: Rectangle {
                id: rowRoot
                property string icon: ""
                property string name: ""
                property int count: 0
                property string checkedAt: "—"
                property var onUpdateClicked: null

                Layout.fillWidth: true
                height: 64
                radius: 12
                color: root.theme.bgAlt
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.06)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    Text {
                        text: rowRoot.icon
                        color: root.theme.fg
                        font { family: root.theme.font; pixelSize: 22 }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: rowRoot.name
                            color: root.theme.fg
                            font { family: root.theme.font; pixelSize: 15; bold: true }
                        }
                        Text {
                            text: (rowRoot.count === 0
                                    ? "Up to date"
                                    : rowRoot.count + " update" + (rowRoot.count === 1 ? "" : "s"))
                                  + "  ·  Checked " + rowRoot.checkedAt
                            color: rowRoot.count > 0 ? root.theme.warning : root.theme.fg3
                            font { family: root.theme.font; pixelSize: 12 }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 90
                        height: 34
                        radius: 8
                        color: updateMouse.containsMouse
                               ? Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.25)
                               : Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.15)
                        border.width: 1
                        border.color: root.theme.accent

                        Text {
                            anchors.centerIn: parent
                            text: "Update"
                            color: root.theme.accent
                            font { family: root.theme.font; pixelSize: 13; bold: true }
                        }

                        MouseArea {
                            id: updateMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (rowRoot.onUpdateClicked) rowRoot.onUpdateClicked()
                        }
                    }
                }
            }

            UpdateRow {
                icon: "󰣇"
                name: "Arch"
                count: root.archCount
                checkedAt: root.archChecked
                onUpdateClicked: root.updateArch
            }

            UpdateRow {
                icon: "󰮯"
                name: "AUR"
                count: root.aurCount
                checkedAt: root.aurChecked
                onUpdateClicked: root.updateAur
            }

            UpdateRow {
                icon: "󰏓"
                name: "Flatpak"
                count: root.flatpakCount
                checkedAt: root.flatpakChecked
                onUpdateClicked: root.updateFlatpak
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.totalCount === 0
                  ? "System is up to date."
                  : root.totalCount + " update" + (root.totalCount === 1 ? "" : "s") + " available."
            color: root.theme.fg3
            font { family: root.theme.font; pixelSize: 13 }
        }
    }
}