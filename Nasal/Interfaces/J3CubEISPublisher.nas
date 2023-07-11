# Copyright 2018 Stuart Buchanan
# This file is part of FlightGear.
#
# FlightGear is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# FlightGear is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FlightGear.  If not, see <http://www.gnu.org/licenses/>.
#
# EIS Driver using Emesary for a J3 Cub
var J3CubEISPublisher =
{

  new : func (period=0.25) {
    var obj = {
      parents : [
        J3CubEISPublisher,
        PeriodicPropertyPublisher.new(notifications.PFDEventNotification.EngineData, period)
      ],
    };

    # Hack to handle most aircraft not having proper engine hours
    if (getprop("/engines/engine[0]/hours") == nil) setprop("/engines/engine[0]/hours", 157.0);

    obj.addPropMap("RPM", "/engines/active-engine/rpm");
    obj.addPropMap("Man", "/engines/active-engine/mp-osi");
    obj.addPropMap("MBusVolts", "/systems/electrical/volts");
	obj.addPropMap("EBusVolts", "/systems/electrical/volts");
	obj.addPropMap("SBattAmps", "/systems/electrical/amps");
    obj.addPropMap("EngineHours", "/engines/engine[0]/hours");
    obj.addPropMap("FuelFlowGPH", "/engines/active-engine/fuel-flow-gph");
    obj.addPropMap("OilPressurePSI", "/engines/active-engine/oil-pressure-psi");
    obj.addPropMap("OilTemperatureF", "/engines/active-engine/oil-temperature-degf");
    obj.addPropMap("EGTNorm", "/engines/active-engine/egt-norm");
    obj.addPropMap("VacuumSuctionInHG", "/systems/vacuum/suction-inhg");

    return obj;
  },

  # Custom publish method as we package the values into an array of engines,
  # in this case, only one!
  publish : func() {
    var engineData0 = {};

    foreach (var propmap; me._propmaps) {
      var name = propmap.getName();
      engineData0[name] = propmap.getValue();
    }

    var engineData = [];
    append(engineData, engineData0);

    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      notifications.PFDEventNotification.EngineData,
      { Id: "EngineData", Value: engineData } );

    me._transmitter.NotifyAll(notification);
  },
};
