##########################################
# Autostart
##########################################

var autostart = func (msg=1) {
    if (getprop("/engines/engine/running")) {
        if (msg)
            gui.popupTip("Engine already running", 5);
        return;
    }

    setprop("/controls/engines/engine/magnetos", 3);
    setprop("/controls/engines/engine/throttle", 0.2);
    setprop("/controls/engines/engine/mixture", 1.0);
    setprop("/controls/flight/elevator-trim", 0.0);
    setprop("/controls/engines/engine/master-bat", 1);
    setprop("/controls/engines/engine/master-alt", 1);

    # if empty get fuel or warn
    # setprop("/consumables/fuel/tank[0]/empty", 1);
   

    # Set the altimeter
    var pressure_sea_level = getprop("/environment/pressure-sea-level-inhg");
    setprop("/instrumentation/altimeter/setting-inhg", pressure_sea_level);

    if (msg)
        gui.popupTip("Hold down \"s\" to start the engine", 5);
};

var reset_system = func {
    if (getprop("/fdm/jsbsim/running")) {
        Cub.autostart(0);
        setprop("/controls/engines/engine/starter", 1);
    }
}

############################################
# Global loop function
# If you need to run nasal as loop, add it in this function
############################################
var global_system_loop = func {
    if (getprop("/engines/engine/running") and getprop("/controls/engines/engine/starter")){
        setprop("/controls/engines/engine/starter", 0);
    }
    if (getprop("/instrumentation/garmin196/antenne-deg") < 180) 
        setprop("/instrumentation/garmin196/antenne-deg", 180);
}

##########################################
# SetListerner must be at the end of this file
##########################################
setlistener("/sim/signals/fdm-initialized", func {
    aircraft.data.load();

    reset_system();
    Cub.rightWindow.toggle();
    Cub.rightDoor.toggle();

    var cub_timer = maketimer(0.25, func{global_system_loop()});
    cub_timer.start();
});
