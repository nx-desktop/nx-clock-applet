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

    property alias cfg_place: queryField.place
    property alias cfg_query: queryField.query

    PlasmaComponents.Label {
        Layout.leftMargin: 20
        text: i18n("Location")
    }

    PlasmaComponents.TextField {
        id: queryField
        Layout.minimumWidth: 300
        Layout.fillWidth: true
        Layout.rightMargin: 12

        property bool accepted: false
        property string query: ""
        property string place: ""

        text: place

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
            if (event.text !== "" && text != weatherDataSource.query) {
                weatherDataSource.query = text
                queryField.accepted = false
            }
        }

        PlasmaCore.FrameSvgItem {

            imagePath: "dialogs/background"
            enabledBorders: PlasmaCore.FrameSvg.NoBorder

            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            clip: true
            height: Math.min(6, placesSuggestionModel.count) * 32
            visible: (activeFocus || queryField.activeFocus)
                     && placesSuggestionModel.count > 0
                     && !queryField.accepted

            PlasmaExtras.ScrollArea {
                anchors.fill: parent

                ListView {
                    id: suggestionsListView

                    model: placesSuggestionModel
                    delegate: PlasmaComponents.ListItem {
                        height: 32
                        width: suggestionsListView.width
                        RowLayout {
                            anchors.fill: parent
                            Image {
                                Layout.leftMargin: 6
                                Layout.preferredHeight: 18
                                Layout.preferredWidth: 18
                                Layout.alignment: Qt.AlignVCenter

                                source: model.icon
                            }

                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                Layout.leftMargin: 6

                                text: model.text
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true
                            onClicked: {
                                queryField.place = model.text
                                queryField.query = model.query
                                queryField.accepted = true

                                print("  ----  ",cfg_query, cfg_place)
                            }
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
        readonly property var ions: ["bbcukmet", "noaa", "wettercom", "envcan"]

        onDataChanged: {
            placesSuggestionModel.clear()
            var placeRegexp = /\|place\|(.*?)\|extra\|(.*?)(?=(\||$))/g

            for (var k in data) {
                // Ignore empty results data
                if (!data[k])
                    continue

                var ion = ""
                var icon = ""

                if (k.startsWith('bbcukmet')) {
                    ion = 'bbcukmet'
                    icon = "http://www.bbc.com/favicon.ico"
                }

                if (k.startsWith('noaa')) {
                    ion = 'noaa'
                    icon = 'http://www.noaa.gov/sites/all/themes/custom/noaa/images/noaa_logo_circle_bw_72x72.svg'
                }

                if (k.startsWith('wettercom') ) {
                    ion = 'wettercom'
                    icon = 'http://www.wetter.com/favicon.ico'
                }

                if (k.startsWith('envcan')) {
                    ion = 'envcan'
                    icon = 'https://weather.gc.ca/favicon.ico'
                }

                if (ion != '') {
                    var output = data[k]['validate']
                    print(output)
                    var match = placeRegexp.exec(output)
                    while (match != null) {
                        var item = {
                            text: match[1],
                            query: ion + "|place|"+match[1],
                            icon: icon
                        }
                        if (match[3])
                            item.query = item.query + '|extra|' + match[3]

                        placesSuggestionModel.append(item)
                        match = placeRegexp.exec(output)
                    }
                }
            }
        }

        onQueryChanged: {
            if (query.length < 3)
                return

            // Clear previous sources
            for (var i in connectedSources)
                disconnectSource(connectedSources[i])

            // Connect new sources
            for (var i in ions)
                weatherDataSource.connectSource(ions[i] + "|validate|" + query)
        }
    }
}
