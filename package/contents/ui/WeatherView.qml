import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    property string location: "lat:25.6196;lon:-100.3014"

    PlasmaCore.DataSource {
        id: weatherDataSource
        engine: "weather"
        interval: 10000

        onDataChanged: {
            var list = data["bbcukmet|validate|"+location]
            for (var k in list)
                print(list[k].split("|place|"))
        }
        Component.onCompleted: {
//            print (sources)
            weatherDataSource.connectSource("bbcukmet|validate|"+location)
        }
    }


}
