# write theJ3Cub state to file and resume
# Addapted from Shuttle, Thorsten Renk 2016 - 2017
# by Wayne Bragg 2019

var save_state = func {

    var running = getprop("/engines/active-engine/running");
    var moving = math.abs(getprop("/velocities/groundspeed-kt"));
    var currentpitch = math.abs(getprop("/orientation/pitch-deg"));
    var roll = math.abs(getprop("/orientation/roll-deg"));

    if (running) {
        gui.popupTip("Engine must be turned off to save state!", 5.0);
        return;
    }
    if (moving > 7 or moving < -7) {
        gui.popupTip("Aircraft cannot be moving to save state!", 5.0);
        return;
    }

    var variant = getprop("/sim/model/variant");
    setprop("/save/variant", variant);
    var bushkit = getprop("/fdm/jsbsim/bushkit");
    setprop("/save/bushkit", bushkit);

    if (bushkit < 3) currentpitch = currentpitch - 10;

    if (currentpitch > 10 or roll > 10) {
        gui.popupTip("Slope too steep to save state!", 5.0);
        return;
    }

    var lat = getprop("/position/latitude-deg");
    setprop("/save/latitude-deg", lat);
    var lon = getprop("/position/longitude-deg");
    setprop("/save/longitude-deg", lon);
    var altitude = getprop("/position/altitude-ft");
    setprop("/save/altitude-ft", altitude);
    var heading = getprop("/orientation/heading-deg");
    setprop("/save/heading-deg", heading);
    var pitch = getprop("/orientation/pitch-deg");
    setprop("/save/pitch-deg", pitch);
    var roll = getprop("/orientation/roll-deg");
    setprop("/save/roll-deg", roll);
    var uBody = getprop("/velocities/uBody-fps");
    setprop("/save/uBody-fps", uBody);
    var vBody = getprop("/velocities/vBody-fps");
    setprop("/save/vBody-fps", vBody);
    var wBody = getprop("/velocities/wBody-fps");
    setprop("/save/wBody-fps", wBody);

    var tank1sel = getprop("/consumables/fuel/tank[0]/selected");
    var tank2sel = getprop("/consumables/fuel/tank[1]/selected");
    setprop("/save/tank1-select", tank1sel);
    setprop("/save/tank2-select", tank2sel);
    var tank1 = getprop("/consumables/fuel/tank[0]/level-lbs");
    var tank2 = getprop("/consumables/fuel/tank[1]/level-lbs");
    setprop("/save/tank1-level-lbs", tank1);
    setprop("/save/tank2-level-lbs", tank2);

    var throttle = getprop("/controls/engines/current-engine/throttle");
    setprop("/save/throttle", throttle);
    var mixture = getprop("/controls/engines/current-engine/mixture");
    setprop("/save/mixture", mixture);
    var primlever = getprop("/controls/engines/engine[0]/primer-lever");
    setprop("/save/primlever", primlever);

    var ptmas1 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]");
    var ptmas2 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]");
    var ptmas3 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[2]");
    var ptmas4 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[3]");
    var ptmas5 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[4]");
    var ptmas6 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[5]");
    var ptmas7 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[6]");
    var ptmas8 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[7]");
    var ptmas9 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[8]");
    var ptmas10 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[9]");
    var ptmas11 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[10]");
    var ptmas12 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[11]");
    var ptmas13 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[12]");
    var ptmas14 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[13]");
    var ptmas15 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[14]");
    var ptmas16 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[15]");
    var ptmas17 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[16]");
    var ptmas18 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[17]");
    var ptmas19 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[18]");
    var ptmas20 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[19]");
    var ptmas21 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[20]");
    var ptmas22 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[21]");
    var ptmas23 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[22]");
    setprop("/save/ptmas1", ptmas1);
    setprop("/save/ptmas2", ptmas2);
    setprop("/save/ptmas3", ptmas3);
    setprop("/save/ptmas4", ptmas4);
    setprop("/save/ptmas5", ptmas5);
    setprop("/save/ptmas6", ptmas6);
    setprop("/save/ptmas7", ptmas7);
    setprop("/save/ptmas8", ptmas8);
    setprop("/save/ptmas9", ptmas9);
    setprop("/save/ptmas10", ptmas10);
    setprop("/save/ptmas11", ptmas11);
    setprop("/save/ptmas12", ptmas12);
    setprop("/save/ptmas13", ptmas13);
    setprop("/save/ptmas14", ptmas14);
    setprop("/save/ptmas15", ptmas15);
    setprop("/save/ptmas16", ptmas16);
    setprop("/save/ptmas17", ptmas17);
    setprop("/save/ptmas18", ptmas18);
    setprop("/save/ptmas19", ptmas19);
    setprop("/save/ptmas20", ptmas20);
    setprop("/save/ptmas21", ptmas21);
    setprop("/save/ptmas22", ptmas22);
    setprop("/save/ptmas23", ptmas23);

    var tiedownL = getprop("/sim/model/j3cub/securing/tiedownL-visible");
    var tiedownR = getprop("/sim/model/j3cub/securing/tiedownR-visible");
    var tiedownT = getprop("/sim/model/j3cub/securing/tiedownT-visible");
    setprop("/save/tiedownL", tiedownL);
    setprop("/save/tiedownR", tiedownR);
    setprop("/save/tiedownT", tiedownT);
    var pitot = getprop("/sim/model/j3cub/securing/pitot-cover-visible");
    setprop("/save/pitot", pitot);
    var chock = getprop("/sim/model/j3cub/securing/chock");
    setprop("/save/chock", chock);

    #getprop("/controls/circuit-breakers/aircond");
    #getprop("/controls/circuit-breakers/autopilot");
    #getprop("/controls/circuit-breakers/bcnlt");
    #getprop("/controls/circuit-breakers/flaps");
    #getprop("/controls/circuit-breakers/instr");
    #getprop("/controls/circuit-breakers/intlt");
    #getprop("/controls/circuit-breakers/landing");
    #getprop("/controls/circuit-breakers/master");
    #getprop("/controls/circuit-breakers/navlt");
    #getprop("/controls/circuit-breakers/pitot-heat");
    #getprop("/controls/circuit-breakers/radio1");
    #getprop("/controls/circuit-breakers/strobe");
    #getprop("/controls/circuit-breakers/turn-coordinator");

    var avionics = getprop("/controls/switches/master-avionics");
    setprop("/save/avionics", avionics);
    var alt = getprop("/controls/switches/master-alt");
    setprop("/save/alt", alt);
    var bat = getprop("/controls/switches/master-bat");
    setprop("/save/bat", bat);
    var magnetos = getprop("/controls/switches/magnetos");
    setprop("/save/magnetos", magnetos);
    var dome = getprop("/controls/switches/dome-light");
    setprop("/save/dome", dome);
    var dome = getprop("/controls/lighting/dome-norm");
    setprop("/save/domenorm", dome);
    var radionorm = getprop("/controls/lighting/radio-norm");
    setprop("/save/radionorm", radionorm);
    var instrumentsnorm = getprop("/controls/lighting/instruments-norm");
    setprop("/save/instrumentsnorm", instrumentsnorm);
    var gpsnorm = getprop("/controls/lighting/gps-norm");
    setprop("/save/gpsnorm", gpsnorm);
    var gearled = getprop("/controls/lighting/gearled");
    setprop("/save/gearled", gearled);

    var nav = getprop("/controls/lighting/nav-lights");
    setprop("/save/nav", nav);
    var beacon = getprop("/controls/lighting/beacon");
    setprop("/save/beacon", beacon);
    var strobe = getprop("/controls/lighting/strobe");
    setprop("/save/strobe", strobe);
    var taxi = getprop("/controls/lighting/taxi-light");
    setprop("/save/taxi", taxi);
    var landing = getprop("/controls/lighting/landing-lights");
    setprop("/save/landing", landing);
    var instruments = getprop("/controls/lighting/instruments-norm");
    setprop("/save/instruments", instruments);

    var garmin = getprop("/sim/model/j3cub/garmin196-visible");
    setprop("/save/garmin", garmin);

    var rdoornorm = getprop("/sim/model/door-positions/rightDoor/position-norm");
    setprop("/save/rdoornorm", rdoornorm);
    #var lwindnorm = getprop("/sim/model/door-positions/leftWindow/position-norm");
    #setprop("/save/lwindnorm", lwindnorm);
    var rwindnorm = getprop("/sim/model/door-positions/rightWindow/position-norm");
    setprop("/save/rwindnorm", rwindnorm);

    var damage = getprop("/fdm/jsbsim/settings/damage");
    setprop("/save/damage", damage);

    var geardown = getprop("/controls/gear/gear-down");
    setprop("/save/geardown", geardown);
    var gearpos = getprop("/fdm/jsbsim/gear/gear-pos-norm");
    setprop("/save/gearpos", gearpos);
    var wrudder = getprop("/controls/gear/water-rudder");
    setprop("/save/wrudder", wrudder);
    var wrudderdown = getprop("/controls/gear/water-rudder-down");
    setprop("/save/wrudderdown", wrudderdown);
    var parkbrake = getprop("/sim/model/j3cub/brake-parking");
    setprop("/save/parkbrake", parkbrake);
    var flaps = getprop("/controls/flight/flaps");
    setprop("/save/flaps", flaps);
    var flapsnorm = getprop("/surface-positions/flap-pos-norm");
    setprop("/save/flapsnorm", flapsnorm);
    var elevtrim = getprop("/controls/flight/elevator-trim");
    setprop("/save/elevtrim", elevtrim);
    var carbheat1 = getprop("/controls/anti-ice/engine[0]/carb-heat");
    setprop("/save/carbheat1", carbheat1);
    var carbheat2 = getprop("/controls/anti-ice/engine[1]/carb-heat");
    setprop("/save/carbheat2", carbheat2);
    var pitotheat = getprop("/controls/anti-ice/pitot-heat");
    setprop("/save/pitotheat", pitotheat);
    var cabheat = getprop("/environment/aircraft-effects/cabin-heat-set");
    setprop("/save/cabheat", cabheat);
    #var cabdef = getprop("/environment/aircraft-effects/cabin-def-set");
    #setprop("/save/cabdef", cabdef);

    var anchorconnect = getprop("/fdm/jsbsim/mooring/mooring-connected");
    setprop("/save/anchorconnect", anchorconnect);
    var anchor = getprop("/controls/mooring/anchor");
    setprop("/save/anchor", anchor);
    if (anchor) {
        var anchorlon = getprop("/fdm/jsbsim/mooring/anchor-lon");
        var anchorlat = getprop("/fdm/jsbsim/mooring/anchor-lat");
        setprop("/save/anchorlon", anchorlon);
        setprop("/save/anchorlat", anchorlat);
    }

    # the scenario description
    var timestring = getprop("/sim/time/real/year");
    timestring = timestring~ "-"~getprop("/sim/time/real/month");
    timestring = timestring~ "-"~getprop("/sim/time/real/day");
    timestring = timestring~ "-"~getprop("/sim/time/real/hour");

    var minute = getprop("/sim/time/real/minute");
    if (minute < 10) {minute = "0"~minute;}
    timestring = timestring~ ":"~minute;

    var description = getprop("/sim/gui/dialogs/j3cub/save/description");

    setprop("/save/description", description);
    setprop("/save/timestring", timestring);

    # save state to specified file

    var filename = getprop("/sim/gui/dialogs/j3cub/save/filename");
    var path = getprop("/sim/fg-home") ~ "/aircraft-data/j3cubSave/"~filename;
    var nodeSave = props.globals.getNode("/save", 0);
    io.write_properties(path, nodeSave);

    print("Current state written to ", filename, " !");
}

var read_state_from_file = func (filename) {

    # read state from specified file

    var path = getprop("/sim/fg-home") ~ "/aircraft-data/j3cubSave/"~filename;
    var readNode = props.globals.getNode("/save", 0);

    io.read_properties(path, readNode);

}

var resume_state = func {

    setprop("/fdm/jsbsim/settings/damage", 0);

    setprop("/sim/presets/airport-id", "");
    var lat = getprop("/save/latitude-deg");
    setprop("/sim/presets/latitude-deg", lat);
    var lon = getprop("/save/longitude-deg");
    setprop("/sim/presets/longitude-deg", lon);
    var pitch = getprop("/save/pitch-deg");
    setprop("/sim/presets/pitch-deg", pitch);
    var roll = getprop("/save/roll-deg");
    setprop("/sim/presets/roll-deg", roll);
    var uBody = getprop("/save/uBody-fps");
    setprop("/sim/presets/uBody-fps", uBody);
    var vBody = getprop("/save/vBody-fps");
    setprop("/sim/presets/vBody-fps", vBody);
    var wBody = getprop("/save/wBody-fps");
    setprop("/sim/presets/wBody-fps", wBody);
    setprop("/sim/presets/altitude-ft", -9999);
    setprop("/sim/presets/airspeed-kt", 0);
    setprop("/sim/presets/offset-distance-nm", 0);
    setprop("/sim/presets/glideslope-deg", 0);
    setprop("/sim/presets/runway", "");
    setprop("/sim/presets/parkpos", "");
    setprop("/sim/presets/runway-requested", 0);

    var heading = getprop("/save/heading-deg");
    var anchorconnect = getprop("/save/anchorconnect");
    setprop("/fdm/jsbsim/mooring/mooring-connected", anchorconnect);
    if (!anchorconnect) {
        setprop("/sim/presets/heading-deg", heading);
    }

    fgcommand("reposition");

    var load_delay = 2.0;
    settimer(func {

        #var lat = getprop("/save/latitude-deg");
        #setprop("/position/latitude-deg", lat);
        #var lon = getprop("/save/longitude-deg");
        #setprop("/position/longitude-deg", lon);

        var tank1sel = getprop("/save/tank1-select");
        var tank2sel = getprop("/save/tank2-select");
        setprop("/consumables/fuel/tank[0]/selected", tank1sel);
        setprop("/consumables/fuel/tank[1]/selected", tank2sel);
        var tank1 = getprop("/save/tank1-level-lbs");
        var tank2 = getprop("/save/tank2-level-lbs");
        setprop("/consumables/fuel/tank[0]/level-lbs", tank1);
        setprop("/consumables/fuel/tank[1]/level-lbs", tank2);

        var throttle = getprop("/save/throttle");
        setprop("/controls/engines/current-engine/throttle", throttle);
        var mixture = getprop("/save/mixture");
        setprop("/controls/engines/current-engine/mixture", mixture);
        var primlever = getprop("/save/primlever");
        setprop("/controls/engines/engine[0]/primer-lever", primlever);

        var ptmas1 = getprop("/save/ptmas1");
        var ptmas2 = getprop("/save/ptmas2");
        var ptmas3 = getprop("/save/ptmas3");
        var ptmas4 = getprop("/save/ptmas4");
        var ptmas5 = getprop("/save/ptmas5");
        var ptmas6 = getprop("/save/ptmas6");
        var ptmas7 = getprop("/save/ptmas7");
        var ptmas8 = getprop("/save/ptmas8");
        var ptmas9 = getprop("/save/ptmas9");
        var ptmas10 = getprop("/save/ptmas10");
        var ptmas11 = getprop("/save/ptmas11");
        var ptmas12 = getprop("/save/ptmas12");
        var ptmas13 = getprop("/save/ptmas13");
        var ptmas14 = getprop("/save/ptmas14");
        var ptmas15 = getprop("/save/ptmas15");
        var ptmas16 = getprop("/save/ptmas16");
        var ptmas17 = getprop("/save/ptmas17");
        var ptmas18 = getprop("/save/ptmas18");
        var ptmas19 = getprop("/save/ptmas19");
        var ptmas20 = getprop("/save/ptmas20");
        var ptmas21 = getprop("/save/ptmas21");
        var ptmas22 = getprop("/save/ptmas22");
        var ptmas23 = getprop("/save/ptmas23");

        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", ptmas1);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", ptmas2);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[2]", ptmas3);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[3]", ptmas4);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[4]", ptmas5);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[5]", ptmas6);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[6]", ptmas7);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[7]", ptmas8);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[8]", ptmas9);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[9]", ptmas10);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[10]", ptmas11);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[11]", ptmas12);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[12]", ptmas13);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[13]", ptmas14);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[14]", ptmas15);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[15]", ptmas16);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[16]", ptmas17);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[17]", ptmas18);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[18]", ptmas19);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[19]", ptmas20);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[20]", ptmas21);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[21]", ptmas22);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[22]", ptmas23);

        var tiedownL = getprop("/save/tiedownL");
        var tiedownR = getprop("/save/tiedownR");
        var tiedownT = getprop("/save/tiedownT");
        setprop("/sim/model/j3cub/securing/tiedownL-visible", tiedownL);
        setprop("/sim/model/j3cub/securing/tiedownR-visible", tiedownR);
        setprop("/sim/model/j3cub/securing/tiedownT-visible", tiedownT);
        var pitot = getprop("/save/pitot");
        setprop("/sim/model/j3cub/securing/pitot-cover-visible", pitot);
        var chock = getprop("/save/chock");

        #getprop("/controls/circuit-breakers/autopilot");
        #getprop("/controls/circuit-breakers/bcnlt");
        #getprop("/controls/circuit-breakers/flaps");
        #getprop("/controls/circuit-breakers/instr");
        #getprop("/controls/circuit-breakers/intlt");
        #getprop("/controls/circuit-breakers/landing");
        #getprop("/controls/circuit-breakers/master");
        #getprop("/controls/circuit-breakers/navlt");
        #getprop("/controls/circuit-breakers/pitot-heat");
        #getprop("/controls/circuit-breakers/radio1");
        #getprop("/controls/circuit-breakers/radio2");
        #getprop("/controls/circuit-breakers/radio3");
        #getprop("/controls/circuit-breakers/radio4");
        #getprop("/controls/circuit-breakers/radio5");
        #getprop("/controls/circuit-breakers/strobe");
        #getprop("/controls/circuit-breakers/turn-coordinator");

        var avionics = getprop("/save/avionics");
        setprop("/controls/switches/master-avionics", avionics);
        var alt = getprop("/save/alt");
        setprop("/controls/switches/master-alt", alt);
        var bat = getprop("/save/bat");
        setprop("/controls/switches/master-bat", bat);
        var magnetos = getprop("/save/magnetos");
        setprop("/controls/switches/magnetos", magnetos);
        var dome = getprop("/save/dome");
        setprop("/controls/switches/dome-light", dome);
        var radionorm = getprop("/save/radionorm");
        setprop("/controls/lighting/radio-norm", radionorm);
        var domenorm = getprop("/save/domenorm");
        setprop("/controls/lighting/dome-norm", domenorm);
        var instrumentsnorm = getprop("/save/instrumentsnorm");
        setprop("/controls/lighting/instruments-norm", instrumentsnorm);
        var gpsnorm = getprop("/save/gpsnorm");
        setprop("/controls/lighting/gps-norm", gpsnorm);
        var gearled = getprop("/save/gearled");
        setprop("/controls/lighting/gearled", gearled);

        var nav = getprop("/save/nav");
        setprop("/controls/lighting/nav-lights", nav);
        var beacon = getprop("/save/beacon");
        setprop("/controls/lighting/beacon", beacon);
        var strobe = getprop("/save/strobe");
        setprop("/controls/lighting/strobe", strobe);
        var taxi = getprop("/save/taxi");
        setprop("/controls/lighting/taxi-light", taxi);
        var landing = getprop("/save/landing");
        setprop("/controls/lighting/landing-lights", landing);
        var instruments = getprop("/save/instruments");
        setprop("/controls/lighting/instruments-norm", instruments);

        var garmin = getprop("/save/garmin");
        setprop("/sim/model/j3cub/garmin196-visible", garmin);
        var rdoornorm = getprop("/save/rdoornorm");
        setprop("/sim/model/door-positions/rightDoor/position-norm", rdoornorm);
        #var lwindnorm = getprop("/save/lwindnorm");
        #setprop("/sim/model/door-positions/leftWindow/position-norm", lwindnorm);
        var rwindnorm = getprop("/save/rwindnorm");
        setprop("/sim/model/door-positions/rightWindow/position-norm", rwindnorm);

        var variant = getprop("/save/variant");
        setprop("/sim/model/variant", variant);
        var bushkit = getprop("/save/bushkit");
        setprop("/fdm/jsbsim/bushkit", bushkit);

        var geardown = getprop("/save/geardown");
        setprop("/controls/gear/gear-down", geardown);
        var gearpos = getprop("/save/gearpos");
        setprop("/fdm/jsbsim/gear/gear-pos-norm", gearpos);
        var wrudder = getprop("/save/wrudder");
        setprop("/controls/gear/water-rudder", wrudder);
        var wrudderdown = getprop("/save/wrudderdown");
        setprop("/controls/gear/water-rudder-down", wrudderdown);
        var parkbrake = getprop("/save/parkbrake");
        setprop("/sim/model/j3cub/brake-parking", parkbrake);
        var flaps = getprop("/save/flaps");
        setprop("/controls/flight/flaps", flaps);
        var flapsnorm = getprop("/save/flapsnorm");
        setprop("/surface-positions/flap-pos-norm", flapsnorm);
        var elevtrim = getprop("/save/elevtrim");
        setprop("/controls/flight/elevator-trim", elevtrim);
        var carbheat1 = getprop("/save/carbheat1");
        setprop("/controls/anti-ice/engine[0]/carb-heat", carbheat1);
        var carbheat2 = getprop("/save/carbheat2");
        setprop("/controls/anti-ice/engine[1]/carb-heat", carbheat2);
        var pitotheat = getprop("/save/pitotheat");
        setprop("/controls/anti-ice/pitot-heat", pitotheat);
        var cabheat = getprop("/save/cabheat");
        setprop("/environment/aircraft-effects/cabin-heat-set", cabheat);
        #var cabdef = getprop("/save/cabdef");
        #setprop("/environment/aircraft-effects/cabin-def-set", cabdef);

        var anchor = getprop("/save/anchor");
        setprop("/controls/mooring/anchor", anchor);

        var damage = getprop("/save/damage");
        #var altitude = getprop("/save/altitude-ft");

        var heading_delay = 3.0;
        var mooring_delay = 4.0;
        var damage_delay = 5.0;

        if (anchorconnect) {
            settimer(func {
                var headwind = getprop("/environment/wind-from-heading-deg");
                setprop("/orientation/heading-deg", headwind);
            }, heading_delay);
            settimer(func {
                var anchorlon = getprop("/save/anchorlon");
                var anchorlat = getprop("/save/anchorlat");
                setprop("/fdm/jsbsim/mooring/anchor-lon", anchorlon);
                setprop("/fdm/jsbsim/mooring/anchor-lat", anchorlat);
                setprop("/sim/anchorbuoy/enable", 0);
                setprop("/fdm/jsbsim/mooring/anchor-dist", 0);
                setprop("/fdm/jsbsim/mooring/anchor-length", 0);
                setprop("/fdm/jsbsim/mooring/mooring-connected", 0);
                setprop("/controls/mooring/anchor", anchor);
            }, mooring_delay);
        }

        settimer(func {
            setprop("/fdm/jsbsim/settings/damage", damage);
        }, damage_delay);

        print("State resumed!");

    }, load_delay);
}
