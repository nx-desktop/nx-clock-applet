/*
 * Copyright 2013  Bhushan Shah <bhush94@gmail.com>
 * Copyright 2015  Martin Klapetek <mklapetek@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

import QtQuick 2.0

import org.kde.plasma.configuration 2.0
import org.kde.plasma.calendar 2.0 as PlasmaCalendar

ConfigModel {
    id: configModel

    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-color"
         source: "configAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Calendar")
        icon: "view-calendar"
        source: "configCalendar.qml"
    }
    ConfigCategory {
        name: i18n("Time Zones")
        icon: "preferences-system-time"
        source: "configTimeZones.qml"
    }


    ConfigCategory {
        name: i18n("Weather")
        icon: "weather-few-clouds"
        source: "configWeather.qml"
    }

    Component.onCompleted: {
        var model = PlasmaCalendar.EventPluginsManager.model;

        for (var i = 0; i < model.rowCount(); i++) {
            //FIXME: this check doesn't work because the engines
            //       of the applet and the config are not shared
//             if (model.get(i, "checked") == true) {
                configModel.appendCategory(model.get(i, "decoration"),
                                        model.get(i, "display"),
                                        model.get(i, "configUi"),
                                        "",
                                        true);
//             }
        }
    }
}
