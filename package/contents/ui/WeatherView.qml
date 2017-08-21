import QtQuick 2.0
import QtQuick.Layouts 1.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: weatherViewRoot
    height: 200
    property string location
    property string station: value


    ListModel {
        id: forecast
    }

    GridLayout {
        anchors.fill: parent

        columns: 4
        PlasmaExtras.Heading {
            id: location

            text: weatherViewRoot.location

            Layout.columnSpan: 3
        }

        PlasmaExtras.Heading {
            id: currentTemperature

            Layout.rowSpan: 2
        }

        PlasmaExtras.Heading {
            id: station

            level: 5
            text: weatherViewRoot.station

            Layout.columnSpan: 3
        }



        ListView {
            Layout.columnSpan: 4
            Layout.fillWidth: true
            Layout.minimumHeight: 90

            orientation: ListView.Horizontal
            spacing: 18
            model: forecast
            delegate: ColumnLayout {
                width: 40
                PlasmaComponents.Label {
                    text: model.when

                    Layout.alignment: Qt.AlignHCenter
                }
                PlasmaCore.IconItem {
                    source: model.icon

                    Layout.alignment: Qt.AlignHCenter
                }
                PlasmaComponents.Label {
                    text: model.temperature_max

                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    PlasmaCore.DataSource {
        id: weatherDataSource
        engine: "weather"
        interval: 10000
        property var place: plasmoid.configuration.place
        property var query: plasmoid.configuration.query

        onDataChanged: {
            print (" ------------------------- \n\t", query)
            var queryData = data[query]
            for (var k in queryData) {
                print(k, ' - ', queryData[k])
            }
            weatherViewRoot.location = queryData['Place']
            weatherViewRoot.station = queryData['Station']

            // forecast
            var days = queryData['Total Weather Days']
            forecast.clear()
            for (var i = 0; i < days; i++) {
                var raw_day_forecast = queryData['Short Forecast Day ' + i]
                raw_day_forecast = raw_day_forecast.split('|')
                var day_forecast = {
                    when: raw_day_forecast[0],
                    icon: raw_day_forecast[1],
                    forecast_str: raw_day_forecast[2],
                    temperature_max:  raw_day_forecast[3],
                    temperature_min:  raw_day_forecast[4],
                    wind_speed: raw_day_forecast[4]
                }
                print(raw_day_forecast, day_forecast)
                forecast.append(day_forecast)
            }
        }

        onQueryChanged: updateSource()
//        Component.onCompleted: updateSource()

        function updateSource() {
            print (query)
            // Clear previous sources
            for (var i in connectedSources)
                disconnectSource(connectedSources[i])

            weatherDataSource.connectSource(query)
        }
    }
}
