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
# J3Cub Interface controller.

var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
var aircraft_dir = getprop("/sim/aircraft-dir");
io.load_nasal(nasal_dir ~ 'Interfaces/PropertyPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/PropertyUpdater.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/NavDataInterface.nas', "fg1000");
io.load_nasal(aircraft_dir ~ '/Nasal/Interfaces/J3CubEISPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericNavComPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericNavComUpdater.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericFMSPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericFMSUpdater.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericADCPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericFuelInterface.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericFuelPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GFC700Publisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GFC700Interface.nas', "fg1000");

var J3CubInterfaceController = {

  _instance : nil,

  INTERFACE_LIST : [
    "NavDataInterface",
    "J3CubEISPublisher",
    "GenericNavComPublisher",
    "GenericNavComUpdater",
    "GenericFMSPublisher",
    "GenericFMSUpdater",
    "GenericADCPublisher",
    "GenericFuelInterface",
    "GenericFuelPublisher",
    "GFC700Publisher",
    "GFC700Interface",
  ],

  # Factory method
  getOrCreateInstance : func() {
    if (J3CubInterfaceController._instance == nil) {
      J3CubInterfaceController._instance = J3CubInterfaceController.new();
    }

    return J3CubInterfaceController._instance;
  },

  new : func() {
    var obj = {
      parents : [J3CubInterfaceController],
      running : 0,
    };

    return obj;
  },

  start : func() {
    if (me.running) return;

    foreach (var interface; J3CubInterfaceController.INTERFACE_LIST) {
      var code = sprintf("me.%sInstance = fg1000.%s.new();", interface, interface);
      var instantiate = compile(code);
      instantiate();
    }

    foreach (var interface; J3CubInterfaceController.INTERFACE_LIST) {
      var code = 'me.' ~ interface ~ 'Instance.start();';
      var start_interface = compile(code);
      start_interface();
    }

    me.running = 1;
  },

  stop : func() {
    if (me.running == 0) return;

    foreach (var interface; J3CubInterfaceController.INTERFACE_LIST) {
      var code = 'me.' ~ interface ~ 'Instance.stop();';
      var stop_interface = compile(code);
      stop_interface();
    }
  },

  restart : func() {
    me.stop();
    me.start();
  }
};
