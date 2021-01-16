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
# EIS Styles
var EISStyles =
{
  new : func() {
    var obj = { parents : [ EISStyles ]};
    obj.Styles = {};
    obj.loadStyles();
    return obj;
  },

  getStyle : func(type) {
    return me.Styles[type];
  },

  setStyle : func(type, name, value) {
    me.Styles[type][name] = value;
  },

  loadStyles : func() {
    me. clearStyles();
    me.Styles.XXX = {};
  },

  clearStyles : func() {
    me.Styles = {};
  },

};
