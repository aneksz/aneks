// components/TrayMenu.qml
// Tray app menus drawn in the island with the current theme (instead of a native Qt menu).
// Submenus open in place with a back arrow.
// Keys: Up/Down to move, Enter/Right to open, Left/Backspace to go back, Escape to close.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property var theme
    property var trayItem: null           // the SystemTrayItem whose menu is shown
    signal closeRequested()

    readonly property int rowHeight: 34
    readonly property int separatorHeight: 9
    readonly property int headerHeight: 34
    readonly property int maxListHeight: 440

    // Submenu stack: [{ menu, title }]
    property var stack: []
    readonly property var currentMenu: stack.length ? stack[stack.length - 1].menu : (trayItem ? trayItem.menu : null)
        readonly property string currentTitle: {
        const t = stack.length
            ? stack[stack.length - 1].title
            : (trayItem ? (trayItem.tooltipTitle || trayItem.title || trayItem.id || "Menu") : "Menu")
        return t.charAt(0).toUpperCase() + t.slice(1)
    }

    property int selected: -1

    // Height the island should use: header + items (capped, then scrolls)
    implicitHeight: headerHeight + 6 + Math.min(list.contentHeight, maxListHeight)

    onVisibleChanged: {
        if (visible) {
            stack = []
            selected = -1
            forceActiveFocus()
        }
    }
    onTrayItemChanged: { stack = []; selected = -1; if (!trayItem && visible) closeRequested() }
    onCurrentMenuChanged: selected = -1

    // DBus menus mark keyboard shortcuts with "_" ("_Quit"); "__" means a real underscore
    function cleanText(t) {
        return (t || "").replace(/__/g, "\u0001").replace(/_/g, "").replace(/\u0001/g, "_")
    }

    function entries() { return opener.children ? opener.children.values : [] }

    function activate(entry) {
        if (!entry || entry.isSeparator || !entry.enabled) return
        if (entry.hasChildren) {
            stack = stack.concat([{ menu: entry, title: cleanText(entry.text) }])
        } else {
            entry.triggered()
            root.closeRequested()
        }
    }

    function back() {
        if (stack.length) stack = stack.slice(0, -1)
    }

    function move(step) {
        const e = entries()
        if (!e.length) return
        let i = selected
        for (let n = 0; n < e.length; n++) {
            i = (i + step + e.length) % e.length
            if (!e[i].isSeparator && e[i].enabled) { selected = i; list.positionViewAtIndex(i, ListView.Contain); return }
        }
    }

    // Close if the app quits while its menu is open
    Connections {
        target: root.trayItem
        ignoreUnknownSignals: true
        function onDestroyed() { root.closeRequested() }
    }

    QsMenuOpener {
        id: opener
        menu: root.currentMenu
    }

    focus: visible
    Keys.onDownPressed: move(1)
    Keys.onUpPressed: move(-1)
    Keys.onReturnPressed: activate(entries()[selected])
    Keys.onEnterPressed: activate(entries()[selected])
    Keys.onRightPressed: { const e = entries()[selected]; if (e && e.hasChildren) activate(e) }
    Keys.onLeftPressed: back()
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Backspace) { back(); event.accepted = true }
    }
    Keys.onEscapePressed: closeRequested()

    // ============================================================
    // HEADER: app name, back arrow inside submenus
    // ============================================================
    RowLayout {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.headerHeight
        spacing: 6

        Rectangle {
            visible: root.stack.length > 0
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: 13
            color: backMouse.containsMouse ? root.theme.surfaceAlt : "transparent"

            Text {
                anchors.centerIn: parent
                text: "arrow_back"
                color: root.theme.fg
                font { family: "Material Symbols Outlined"; pixelSize: 18 }
            }
            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.back()
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: root.stack.length ? 0 : 8
            text: root.currentTitle
            elide: Text.ElideRight
            color: root.theme.fg3
            font { family: root.theme.font; pixelSize: 12; bold: true }
        }
    }

    // ============================================================
    // ITEMS
    // ============================================================
    ListView {
        id: list
        anchors { top: header.bottom; topMargin: 6; left: parent.left; right: parent.right; bottom: parent.bottom }
        clip: true
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        model: opener.children

        delegate: Item {
            id: row
            required property var modelData
            required property int index

            readonly property bool isSep: modelData.isSeparator
            readonly property bool isSelected: root.selected === index
            readonly property bool usable: !isSep && modelData.enabled

            width: ListView.view.width
            height: isSep ? root.separatorHeight : root.rowHeight

            // separator
            Rectangle {
                visible: row.isSep
                anchors.centerIn: parent
                width: parent.width - 16
                height: 1
                color: Qt.rgba(root.theme.fg.r, root.theme.fg.g, root.theme.fg.b, 0.1)
            }

            // item
            Rectangle {
                visible: !row.isSep
                anchors.fill: parent
                radius: 8
                color: row.isSelected && row.usable
                    ? Qt.rgba(root.theme.accent.r, root.theme.accent.g, root.theme.accent.b, 0.15)
                    : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    spacing: 10
                    opacity: row.usable ? 1 : 0.4

                    // checkbox / radio
                    Text {
                        visible: row.modelData.buttonType !== QsMenuButtonType.None
                        text: row.modelData.buttonType === QsMenuButtonType.RadioButton
                            ? (row.modelData.checkState === Qt.Checked ? "radio_button_checked" : "radio_button_unchecked")
                            : (row.modelData.checkState === Qt.Checked ? "check_box" : "check_box_outline_blank")
                        color: row.modelData.checkState === Qt.Checked ? root.theme.accent : root.theme.fg3
                        font { family: "Material Symbols Outlined"; pixelSize: 18 }
                    }

                    // app-provided icon
                    IconImage {
                        visible: row.modelData.icon !== "" && row.modelData.buttonType === QsMenuButtonType.None
                        source: row.modelData.icon
                        implicitSize: 16
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.cleanText(row.modelData.text)
                        elide: Text.ElideRight
                        color: row.isSelected && row.usable ? root.theme.accent : root.theme.fg
                        font { family: root.theme.font; pixelSize: 13 }
                    }

                    // submenu arrow
                    Text {
                        visible: row.modelData.hasChildren
                        text: "chevron_right"
                        color: root.theme.fg3
                        font { family: "Material Symbols Outlined"; pixelSize: 18 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: row.usable ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onEntered: if (row.usable) root.selected = row.index
                    onClicked: root.activate(row.modelData)
                }
            }
        }
    }
}
