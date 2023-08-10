# Copyright (C) 2015  Juan Vera
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

ki266.new(0);
aircraft.data.add("engines/engine[0]/egt-bug-norm");

var headingNeedleDeflection = "/instrumentation/nav/heading-needle-deflection";
var gsNeedleDeflection = "/instrumentation/nav/gs-needle-deflection-norm";
var staticPressure = "systems/static/pressure-inhg";

# NAV/COMM1 (according to its documentation)
aircraft.data.add(
    "instrumentation/comm[0]/power-btn",
    "instrumentation/comm[0]/volume-selected",
    "instrumentation/comm[0]/frequencies/selected-mhz",
    "instrumentation/comm[0]/frequencies/standby-mhz",
    "instrumentation/comm[0]/frequencies/dial-khz",
    "instrumentation/comm[0]/frequencies/dial-mhz",
    "instrumentation/comm[0]/test-btn",
    "instrumentation/comm[0]/channel-mode-selector",
    "instrumentation/nav[0]/ident-audible",
    "instrumentation/nav[0]/power-btn",
    "instrumentation/nav[0]/volume",
    "instrumentation/nav[0]/frequencies/selected-mhz",
    "instrumentation/nav[0]/frequencies/standby-mhz",
    "instrumentation/nav[0]/frequencies/dial-khz",
    "instrumentation/nav[0]/frequencies/dial-mhz",
    "instrumentation/nav[0]/radials/selected-deg",
);

#fg1000 in fgdata uses this for the GMA1347 panel
aircraft.data.add(
    "instrumentation/nav[0]/ident",
    "instrumentation/nav[1]/ident",
);

aircraft.data.add(
    "instrumentation/dme/switch-position",
    "instrumentation/dme/frequencies/source",
    "instrumentation/dme/frequencies/selected-mhz",
);

# Instruments
aircraft.data.add(
    "instrumentation/altimeter/setting-inhg",
    "instrumentation/attitude-indicator/horizon-offset-deg",
    "autopilot/settings/heading-bug-deg",
    "instrumentation/heading-indicator/offset-deg",
    "instrumentation/adf[0]/rotation-deg",
    "instrumentation/adf[0]/frequencies/dial-1-khz",
    "instrumentation/adf[0]/frequencies/dial-100-khz",
);

# DME saves power-btn in ki266.nas
# ADF saves its properties in ki87.nas
# TRANSPONDER (KT76A)
aircraft.data.add(
    "instrumentation/transponder/inputs/digit[0]",
    "instrumentation/transponder/inputs/digit[1]",
    "instrumentation/transponder/inputs/digit[2]",
    "instrumentation/transponder/inputs/digit[3]",
    "instrumentation/transponder/inputs/dimming-norm",
);

# Hobbs meter is saved in Nasal/engine.nas
# Save switches
aircraft.data.add(
    "/controls/lighting/beacon-light",
    "/controls/lighting/landing-light",
    "/controls/lighting/nav-lights",
    "/controls/lighting/strobe-lights",
    "/controls/lighting/taxi-light",
    "/controls/switches/magnetos",
    "/controls/switches/master-bat",
    "/controls/switches/master-avionics",
    "/controls/lighting/gearled",
    "/controls/lighting/instruments-norm",
    "/controls/lighting/radio-norm",
    "/controls/switches/panel-lights",
);

# Other controls
aircraft.data.add(
    "/controls/anti-ice/engine/carb-heat",
    "/controls/anti-ice/pitot-heat",
    "/consumables/fuel/tank/selected",
    "/consumables/fuel/tank[1]/selected",
    "/sim/model/j3cub/brake-parking",
    "/controls/flight/flaps",
    "/controls/flight/elevator-trim",
    "/controls/engines/current-engine/throttle",
    "/controls/engines/current-engine/mixture",
    "/controls/engines/engine[0]/primer-lever",
);

# Circuit breakers
aircraft.data.add(
    "/controls/circuit-breakers/bcnlt",
    "/controls/circuit-breakers/flaps",
    "/controls/circuit-breakers/instr",
    "/controls/circuit-breakers/intlt",
    "/controls/circuit-breakers/avionics",
    "/controls/circuit-breakers/landing",
    "/controls/circuit-breakers/master",
    "/controls/circuit-breakers/navlt",
    "/controls/circuit-breakers/pitot-heat",
    "/controls/circuit-breakers/strobe",
    "/controls/circuit-breakers/turn-coordinator",
    "/controls/circuit-breakers/gear-select",
    "/controls/circuit-breakers/gear-advisory",
    "/controls/circuit-breakers/hydraulic-pump",
    "/controls/circuit-breakers/autopilot",
    "/controls/circuit-breakers/electrim",
);
