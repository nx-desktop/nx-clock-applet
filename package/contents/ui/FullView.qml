import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
ColumnLayout {
    Layout.minimumHeight: Screen.desktopAvailableWidth
    CalendarView {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
    }
}
