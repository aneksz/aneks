// components/UpdateAuthModule.qml
import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var theme: null
    property string actionDescription: "Authentication is needed to run `/usr/bin/true` as the super user"
    property string statusText: ""

    signal authenticated(string password)
    signal cancelled()
    
    function forceInputFocus() {
        passInput.forceActiveFocus()
    }
    
    function clearPassword() {
        passInput.text = ""
        passInput.forceActiveFocus()
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.topMargin: 42
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        spacing: 12
        focus: true 

        // Header Title Row
        Row {
            spacing: 8
            width: parent.width

            Text {
                text: "󰌾"
                font.family: root.theme?.font ?? ""
                font.pixelSize: 16
                color: root.theme.success
            }

            Text {
                text: "Authentication Required"
                font.family: root.theme?.font ?? ""
                color: root.theme.fg
                font.pixelSize: 16
                font.bold: true
            }
        }

        // Action Description
        Text {
            width: parent.width
            text: root.actionDescription
            font.family: root.theme.font
            color: root.theme.fg
            font.pixelSize: 13
            wrapMode: Text.Wrap
        }

        // Domain
        Text {
            width: parent.width
            text: "org.freedesktop.policykit.exec"
            font.family: root.theme?.font ?? ""
            color: root.theme.fg1
            font.pixelSize: 11
        }

        // Password label + input
        Column {
            width: parent.width
            spacing: 4

            Text {
                text: "Password:"
                font.family: root.theme?.font ?? ""
                color: root.theme.fg
                font.pixelSize: 13
            }

            TextField {
                id: passInput
                width: parent.width
                height: 38
                echoMode: TextInput.Password
                color: root.theme.fg
                font.family: root.theme?.font ?? ""
                font.pixelSize: 14
                focus: true
                
                background: Rectangle {
                    color: root.theme.bgAlt
                    radius: 8
                    border.color: passInput.activeFocus ? root.theme.success : "transparent"
                    border.width: 1
                }

                onAccepted: root.authenticated(passInput.text)
                onTextChanged: {
    if (text.length > 0 && root.statusText !== "")
        root.statusText = ""
}
            }
        Item {
    width: parent.width
    height: 8      

    Text {
        id: errorIndicatorLabel
        anchors.fill: parent
        text: root.statusText
        font.family: root.theme?.font ?? ""
        color: root.theme.error
        font.pixelSize: 11
        font.bold: true
        visible: root.statusText.length > 0
        verticalAlignment: Text.AlignVCenter
        // optional: horizontalAlignment: Text.AlignRight
    }
}
       

}

        // Buttons
        Row {
            id: buttonLayoutRow
            width: parent.width
            layoutDirection: Qt.RightToLeft
            spacing: 8

            Button {
                id: authBtn
                text: "Authenticate"
                contentItem: Text {
                    text: authBtn.text
                    font.family: root.theme?.font ?? ""
                    color: root.theme.bg
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    implicitWidth: 110
                    implicitHeight: 34
                    color: root.theme.success
                    radius: 12
                }
                onClicked: root.authenticated(passInput.text)
            }

            Button {
                id: cancelBtn
                text: "Cancel"
                contentItem: Text {
                    text: cancelBtn.text
                    font.family: root.theme?.font ?? ""
                    color: root.theme.fg
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    implicitWidth: 80
                    implicitHeight: 34
                    color: root.theme.bgAlt
                    radius: 12
                }
                onClicked: root.cancelled()
            }
        }
    }
}
