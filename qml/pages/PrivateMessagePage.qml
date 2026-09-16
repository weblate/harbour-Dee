import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Utils.js" as Utils

Page {
    id: page

    property var api
    property string content
    property string otherActor
    property int recipientId
    property bool own
    property string published
    property bool submitting: false

    function submit() {
        if (messageField.text.trim().length === 0)
            return;

        submitting = true;
        api.sendPrivateMessage(recipientId, messageField.text.trim());
    }

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: own ? qsTr("Sent private message") : qsTr("Private message")
            }

            Rectangle {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                height: messageLabel.height + 2 * Theme.paddingMedium
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.08)
                radius: Theme.paddingSmall

                Rectangle {
                    width: 3
                    height: parent.height
                    color: Theme.secondaryHighlightColor
                    opacity: 0.6
                    radius: 1
                }

                Label {
                    id: messageLabel

                    x: Theme.paddingMedium + 3
                    y: Theme.paddingMedium
                    width: parent.width - x - Theme.paddingMedium
                    text: page.content
                    wrapMode: Text.Wrap
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            Row {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingSmall

                Label {
                    text: page.own ? qsTr("To %1").arg(Utils.formatAuthor(page.otherActor)) : qsTr("From %1").arg(Utils.formatAuthor(page.otherActor))
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryHighlightColor
                }

                Label {
                    text: page.published ? "·" : ""
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }

                Label {
                    text: page.published ? Format.formatDate(page.published, Formatter.DurationElapsed) : ""
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            TextArea {
                id: messageField

                visible: page.recipientId > 0
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                focus: true
                placeholderText: qsTr("Write a reply…")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                enabled: !submitting
                onTextChanged: errorLabel.text = ""
            }

            Button {
                visible: page.recipientId > 0
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: submitting ? qsTr("Sending…") : qsTr("Send")
                enabled: !submitting && messageField.text.trim().length > 0
                onClicked: submit()
            }

            Label {
                id: errorLabel

                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.errorColor
                font.pixelSize: Theme.fontSizeSmall
                visible: text.length > 0
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: submitting
    }

    Connections {
        target: api
        onRequestFinished: {
            if (method === "sendPrivateMessage") {
                messageField.text = "";
                submitting = false;
                pageStack.pop();
            }
        }
        onRequestFailed: {
            if (method === "sendPrivateMessage") {
                errorLabel.text = message;
                submitting = false;
            }
        }
    }
}
