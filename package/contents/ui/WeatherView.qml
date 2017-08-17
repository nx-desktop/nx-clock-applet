import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    property string location: "lat:25.6196;lon:-100.3014"

    PlasmaCore.DataSource {
        id: weatherDataSource
        engine: "weather"
        interval: 10000
        property var place: plasmoid.configuration.place
        property var query: plasmoid.configuration.query

        onDataChanged: {
            print (query)
            print(data)

            for (var k in data)
                print(k, data[k])
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
