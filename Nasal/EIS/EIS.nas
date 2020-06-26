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
# EIS
var EIS =
{
  new : func (mfd, myCanvas, device, svg)
  {
    var obj = {
      parents : [
        EIS,
        MFDPage.new(mfd, myCanvas, device, svg, "EIS", "")
      ],
    };

    obj.setController(fg1000.EISController.new(obj, svg));

    obj.addTextElements(["RPMDisplay", "MBusVolts", "EBusVolts", "EngineHours"]);

    obj._fuelFlowPointer    = PFD.PointerElement.new(obj.pageName, svg, "FuelFlowPointer", 0.0, 20.0, 135);
    obj._oilPressurePointer = PFD.PointerElement.new(obj.pageName, svg, "OilPressurePointer", 0.0, 115.0, 135);
    obj._oilTempPointer     = PFD.PointerElement.new(obj.pageName, svg, "OilTempPointer", 0.0, 245.0, 135);
    obj._EGTPointer         = PFD.PointerElement.new(obj.pageName, svg, "EGTPointer", 0.0, 1.0, 135);
    obj._EGTCylinder        = PFD.PointerElement.new(obj.pageName, svg, "EGTCylinder", 0.0, 1.0, 135);
    obj._vacPointer         = PFD.PointerElement.new(obj.pageName, svg, "VacPointer", 3.0, 7.0, 135);
    obj._leftFuelPointer    = PFD.PointerElement.new(obj.pageName, svg, "LeftFuelPointer", 0.0, 30.0, 135);
    obj._rightFuelPointer   = PFD.PointerElement.new(obj.pageName, svg, "RightFuelPointer", 0.0, 30.0, 135);

    obj._RPMPointer = PFD.RotatingElement.new(obj.pageName, svg, "RPMPointer", 0.0, 3000.0, 260.0, [150,100]);

    return obj;
  },

  updateData : func(engineData) {
    me.setTextElement("RPMDisplay", sprintf("%i", engineData.RPM));
    me.setTextElement("MBusVolts", sprintf("%.01f", engineData.MBusVolts));
    me.setTextElement("EBusVolts", sprintf("%.01f", engineData.MBusVolts)); # TODO: Include Emergency Bus
    me.setTextElement("EngineHours", sprintf("%.01f", engineData.EngineHours));

    me._fuelFlowPointer.setValue(engineData.FuelFlowGPH);
    me._oilPressurePointer.setValue(engineData.OilPressurePSI);
    me._oilTempPointer.setValue(engineData.OilTemperatureF);
    me._EGTPointer.setValue(engineData.EGTNorm);
    me._EGTCylinder.setValue(engineData.EGTNorm);
    me._vacPointer.setValue(engineData.VacuumSuctionInHG);
    me._leftFuelPointer.setValue(engineData.LeftFuelUSGal);
    me._rightFuelPointer.setValue(engineData.RightFuelUSGal);

    me._RPMPointer.setValue(engineData.RPM);
  },

  # Menu tree .  engineMenu is referenced from most pages as softkey 0:
  # pg.addMenuItem(0, "ENGINE", pg, pg.mfd.EISPage.engineMenu);

  engineMenu : func(device, pg, menuitem) {
    pg.clearMenu();
    pg.resetMenuColors();
    pg.addMenuItem(0, "ENGINE", pg, pg.mfd.EIS.engineMenu);
    pg.addMenuItem(1, "LEAN", pg, pg.mfd.EIS.leanMenu);
    pg.addMenuItem(2, "SYSTEM", pg, pg.mfd.EIS.systemMenu);
    pg.addMenuItem(8, "BACK", pg, pg.topMenu);
    device.updateMenus();
  },

  leanMenu : func(device, pg, menuitem) {
      pg.clearMenu();
      pg.resetMenuColors();
      pg.addMenuItem(0, "ENGINE", pg, pg.mfd.EIS.engineMenu);
      pg.addMenuItem(1, "LEAN", pg, pg.mfd.EIS.leanMenu);
      pg.addMenuItem(2, "SYSTEM", pg, pg.mfd.EIS.systemMenu);
      pg.addMenuItem(3, "CYL SELECT", pg);
      pg.addMenuItem(4, "ASSIST", pg);
      pg.addMenuItem(9, "BACK", pg, pg.mfd.EIS.engineMenu);
      device.updateMenus();
  },

  systemMenu : func(device, pg, menuitem) {
      pg.clearMenu();
      pg.resetMenuColors();
      pg.addMenuItem(0, "ENGINE", pg, pg.mfd.EIS.engineMenu);
      pg.addMenuItem(1, "LEAN", pg, pg.mfd.EIS.leanMenu);
      pg.addMenuItem(2, "SYSTEM", pg, pg.mfd.EIS.systemMenu);
      pg.addMenuItem(3, "RST FUEL", pg);
      pg.addMenuItem(4, "GAL REM", pg, pg.mfd.EIS.galRemMenu);
      pg.addMenuItem(5, "BACK", pg, pg.mfd.EIS.engineMenu);
      device.updateMenus();
  },

  galRemMenu : func(device, pg, menuitem) {
    pg.clearMenu();
    pg.resetMenuColors();
    pg.addMenuItem(0, "ENGINE", pg, pg.mfd.EIS.engineMenu);
    pg.addMenuItem(1, "LEAN", pg, pg.mfd.EIS.leanMenu);
    pg.addMenuItem(2, "SYSTEM", pg, pg.mfd.EIS.systemMenu);
    pg.addMenuItem(3, "-10 GAL", pg);
    pg.addMenuItem(4, "-1 GAL", pg);
    pg.addMenuItem(5, "+1 GAL", pg);
    pg.addMenuItem(6, "+10 GAL", pg);
    pg.addMenuItem(7, "44 GAL", pg);
    pg.addMenuItem(8, "BACK", pg, pg.mfd.EIS.engineMenu);
    device.updateMenus();
  },

  offdisplay : func() {
    me._group.setVisible(0);

    # Reset the menu colours.  Shouldn't have to do this here, but
    # there's not currently an obvious other location to do so.
    for(var i = 0; i < 12; i +=1) {
      var name = sprintf("SoftKey%d",i);
      me.device.svg.getElementById(name ~ "-bg").setColorFill(0.0,0.0,0.0);
      me.device.svg.getElementById(name).setColor(1.0,1.0,1.0);
    }
    me.getController().offdisplay();
  },
  ondisplay : func() {
    me._group.setVisible(1);
    me.getController().ondisplay();
  },


};
