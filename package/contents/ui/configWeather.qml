import QtQml 2.2
import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

GridLayout {
    columns: 2
    columnSpacing: 10

    property alias cfg_location: location.text

    PlasmaComponents.Label {
        Layout.leftMargin: 20
        text: i18n("Location")
    }

    PlasmaComponents.TextField {
        id: location
        Layout.minimumWidth: 300
        Layout.fillWidth: true
        Layout.rightMargin: 12

        focus: true
        Keys.priority: Keys.BeforeItem
        Keys.onUpPressed: {
            suggestionsListView.currentIndex = Math.max(
                        0, suggestionsListView.currentIndex - 1)
            var new_text = placesSuggestionModel.get(
                        suggestionsListView.currentIndex).text
            if (new_text !== '')
                text = new_text
        }
        Keys.onDownPressed: {
            suggestionsListView.currentIndex = Math.min(
                        placesSuggestionModel.count - 1,
                        suggestionsListView.currentIndex + 1)
            var new_text = placesSuggestionModel.get(
                        suggestionsListView.currentIndex).text
            if (new_text !== '')
                text = new_text
        }

        Keys.onReleased: {
            if (event.text !== "" && text != weatherDataSource.query)
                weatherDataSource.query = text
        }

        PlasmaCore.FrameSvgItem {

            imagePath: "dialogs/background"
            enabledBorders: PlasmaCore.FrameSvg.NoBorder

            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            clip: true
            height: Math.min(6, placesSuggestionModel.count) * 32
            visible: (activeFocus || location.activeFocus)
                     && placesSuggestionModel.count > 0

            PlasmaExtras.ScrollArea {
                anchors.fill: parent

                ListView {
                    id: suggestionsListView

                    model: placesSuggestionModel
                    delegate: PlasmaComponents.ListItem {
                        height: 32
                        width: suggestionsListView.width
                        PlasmaComponents.Label {
                            anchors.fill: parent
                            text: model.text
                        }

                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true
                            onClicked: location.text = model.text
                            onEntered: suggestionsListView.currentIndex = index
                        }
                    }

                    highlight: PlasmaComponents.Highlight {
                    }
                }
            }
        }
    }

    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true
    }

    ListModel {
        id: placesSuggestionModel
    }

    PlasmaCore.DataSource {
        id: weatherDataSource
        engine: "weather"

        property string query: ""
        readonly property var ions: ["bbcukmet"]

        onDataChanged: {
            placesSuggestionModel.clear()
            var bbcukmetRegexp = /\|place\|(.*?)\|extra\|/g

            for (var k in data) {
                if (k.startsWith('bbcukmet') && data[k]) {
                    var output = data[k]['validate']
                    var match = bbcukmetRegexp.exec(output)
                    while (match != null) {
                        var item = {
                            text: match[1]
                        }
                        placesSuggestionModel.append(item)
                        match = bbcukmetRegexp.exec(output)
                    }
                }
            }
        }

        onQueryChanged: {
            // Clear previous sources
            for (var i in connectedSources)
                disconnectSource(connectedSources[i])

            // Connect new sources
            for (var i in ions)
                weatherDataSource.connectSource(ions[i] + "|validate|" + query)
        }
    }
}
