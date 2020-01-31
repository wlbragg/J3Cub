# Manages the engine
#
# =============================== DEFINITIONS ===========================================

# set the update period

var UPDATE_PERIOD = 0.3;

# ================================ Initalize ====================================== 
# Make sure all needed properties are present and accounted 
# for, and that they have sane default values.

# =============== Variables ================

controls.incThrottle = func {
    var delta = arg[1] * controls.THROTTLE_RATE * getprop("/sim/time/delta-realtime-sec");
    var old_value = getprop("/controls/engines/current-engine/throttle");
    var new_value = std.max(0.0, std.min(old_value + delta, 1.0));
    setprop("/controls/engines/current-engine/throttle", new_value);
};

controls.throttleMouse = func {
    if (!getprop("/devices/status/mice/mouse[0]/button[1]")) {
        return;
    }
    var delta = cmdarg().getNode("offset").getValue() * -4;
    var old_value = getprop("/controls/engines/current-engine/throttle");
    var new_value = std.max(0.0, std.min(old_value + delta, 1.0));
    setprop("/controls/engines/current-engine/throttle", new_value);
};

# 2018.2 introduces new "all" properties for throttle, mixture and prop pitch.
# this is the correct way to interface with the axis based controls - use a listener
# on the *-all property
_setlistener("/controls/engines/throttle-all", func{
    var value = (1 - getprop("/controls/engines/throttle-all")) / 2;
    var new_value = std.max(0.0, std.min(value, 1.0));
    setprop("/controls/engines/current-engine/throttle", new_value);
},0,0);
_setlistener("/controls/engines/mixture-all", func{

    var value = (1 - getprop("/controls/engines/mixture-all")) / 2;
    var new_value = std.max(0.0, std.min(value, 1.0));
    setprop("/controls/engines/current-engine/mixture", new_value);
},0,0);

# backwards compatibility only - the controls.throttleAxis should not be overridden like this. The joystick binding Throttle (all) has 
# been replaced and controls.throttleAxis will not be called from the controls binding
controls.throttleAxis = func {
    var value = (1 - cmdarg().getNode("setting").getValue()) / 2;
    var new_value = std.max(0.0, std.min(value, 1.0));
    setprop("/controls/engines/current-engine/throttle", new_value);
};

controls.adjMixture = func {
    var delta = arg[0] * controls.THROTTLE_RATE * getprop("/sim/time/delta-realtime-sec");
    var old_value = getprop("/controls/engines/current-engine/mixture");
    var new_value = std.max(0.0, std.min(old_value + delta, 1.0));
    setprop("/controls/engines/current-engine/mixture", new_value);
};

# backwards compatibility only - the controls.throttleAxis should not be overridden like this. The joystick binding Throttle (all) has 
# been replaced and controls.throttleAxis will not be called from the controls binding
controls.mixtureAxis = func {
    var value = (1 - cmdarg().getNode("setting").getValue()) / 2;
    var new_value = std.max(0.0, std.min(value, 1.0));
    setprop("/controls/engines/current-engine/mixture", new_value);
};

controls.stepMagnetos = func {
    var old_value = getprop("/controls/switches/magnetos");
    var new_value = std.max(0, std.min(old_value + arg[0], 3));
    setprop("/controls/switches/magnetos", new_value);
};

# ========== primer stuff ======================

# Toggles the state of the primer
var pumpPrimer = func {
    var push = getprop("/controls/engines/engine/primer-lever") or 0;

    if (push) {
        var pump = getprop("/controls/engines/engine/primer") or 0;
        setprop("/controls/engines/engine/primer", pump + 1);
        setprop("/controls/engines/engine/primer-lever", 0);
    }
    else {
        setprop("/controls/engines/engine/primer-lever", 1);
    }
};

# Primes the engine automatically. This function takes several seconds
var autoPrime = func {
    var p = getprop("/controls/engines/engine/primer") or 0;
    if (p < 3) {
        pumpPrimer();
        settimer(autoPrime, 1);
    }
};

# Mixture will be calculated using the primer during 5 seconds AFTER the pilot used the starter
# This prevents the engine to start just after releasing the starter: the propeller will be running
# thanks to the electric starter, but carburator has not yet enough mixture
var primerTimer = maketimer(5, func {
    setprop("/controls/engines/engine/use-primer", 0);
    # Reset the number of times the pilot used the primer only AFTER using the starter
    setprop("/controls/engines/engine/primer", 0);
    print("Primer reset to 0");
    primerTimer.stop();
});

# ========== Main loop ======================

var update = func {

    var usePrimer = getprop("/controls/engines/engine/use-primer") or 0;
    var engine_running = getprop("/engines/active-engine/running");
    var magneto_settings = getprop("/controls/switches/magnetos");

    #use if engine oil system is ever added
    #if (usePrimer and !engine_running and getprop("/engines/active-engine/oil-temperature-degf") <= 75) {
    if (usePrimer and !engine_running) {
        # Mixture is controlled by start conditions
        var primer = getprop("/controls/engines/engine/primer");
        if (!getprop("/fdm/jsbsim/fcs/mixture-primer-cmd") and getprop("/controls/switches/starter") and getprop("/controls/switches/master-bat")) {
            if (primer < 3) {
                print("Use the primer!");
                gui.popupTip("Use the primer!");
            }
            elsif (primer > 6) {
                print("Flooded engine!");
                gui.popupTip("Flooded engine!");
            }
            elsif (magneto_settings < 1) {
                print("Check Magnetos Switch!");
                gui.popupTip("Check Magnetos Switch!");
            } else {
                print("Check the throttle!");
                gui.popupTip("Check the throttle!");
            }
        }
    }
};

setlistener("/controls/switches/starter", func {
    var v = getprop("/controls/switches/starter") or 0;
    if (v == 0) {
        print("Starter off");
        # notice the starter will be reset after 5 seconds
        primerTimer.restart(5);
    }
    else {
        print("Starter on");
        setprop("/controls/engines/engine/use-primer", 1);
        if (primerTimer.isRunning) {
            primerTimer.stop();
        }
    }
}, 1, 0);

# ========== end primer stuff ======================

# key 's' calls to this function when it is pressed DOWN even if I overwrite the binding in the -set.xml file!
# fun fact: the key UP event can be overwriten!
controls.startEngine = func(v = 1) {
    # Only operate in non-walker mode ('s' is also bound to walk-backward)
    #var view_name = getprop("/sim/current-view/name");
    #if (view_name == getprop("/sim/view[110]/name") or view_name == getprop("/sim/view[111]/name")) {
    #    return;
    #}
    if (getprop("/engines/active-engine/running"))
    {
        setprop("/controls/switches/starter", 0);
        return;
    }
    else {
        setprop("/controls/switches/starter", v);
    }
};

# ========== carburetor icing ======================

# adapted from c172p, thanks to @gilbertohasnofb

var carb_icing_function = maketimer(1.0, func {

    if (getprop("/engines/active-engine/carb_icing_allowed")) {
        var rpm = getprop("/engines/active-engine/rpm");
        var dewpointC = getprop("/environment/dewpoint-degc");
        var dewpointF = dewpointC * 9.0 / 5.0 + 32;
        var airtempF = getprop("/environment/temperature-degf");
        var oil_temp = getprop("/engines/active-engine/oil-temperature-degf");
        var egt_degf = getprop("/engines/active-engine/egt-degf");
        var engine_running = getprop("/engines/active-engine/running");
        
        # the formula below attempts to modle the graph found in the POH, using RPM, airtempF and dewpointF as variables
        # carb_icing_formula ranges from 0.65 to -0.35
        var factorX = 13.2 - 3.2 * math.atan2 ( ((rpm - 2000.0) * 0.008), 1);
        var factorY = 7.0 - 2.0 * math.atan2 ( ((rpm - 2000.0) * 0.008), 1);
        var carb_icing_formula = (math.exp( math.pow((0.6 * airtempF + 0.3 * dewpointF - 42.0),2) / (-2 * math.pow(factorX,2))) * math.exp( math.pow((0.3 * airtempF - 0.6 * dewpointF + 14.0),2) / (-2 * math.pow(factorY,2))) - 0.35)  * engine_running;
        
        # with carb heat on and a typical EGT of ~1450, the carb_heat_rate will be around -1.5
        if (getprop("/controls/engines/current-engine/carb-heat"))
            var carb_heat_rate = -0.001 * egt_degf;
        else
            var carb_heat_rate = 0.0;
        
        # a warm engine will accumulate less oil than a cold one, which is what oil temp factor is used for
        # oil_temp_factor ranges from 0 to aprox -0.2 (at 250 oF)
        var oil_temp_factor = oil_temp / -1250;
        var carb_icing_rate = carb_icing_formula + carb_heat_rate + oil_temp_factor;

        var carb_ice = getprop("/engines/active-engine/carb_ice");
        carb_ice = carb_ice + carb_icing_rate * 0.00001;
        carb_ice = std.max(0.0, std.min(carb_ice, 1.0));

        # this property is used to lower the RPM of the engine as ice accumulates
        vol_eff_factor = std.max(0.0, 0.85 - 1.72 * carb_ice);

        setprop("/engines/active-engine/carb_ice", carb_ice);
        setprop("/engines/active-engine/carb_icing_rate", carb_icing_rate);
        setprop("/engines/active-engine/volumetric-efficiency-factor", vol_eff_factor);
        setprop("/engines/active-engine/oil_temp_factor", oil_temp_factor);
    }
    else {
        setprop("/engines/active-engine/carb_ice", 0.0);
        setprop("/engines/active-engine/carb_icing_rate", 0.0);
        setprop("/engines/active-engine/volumetric-efficiency-factor", .85);
        setprop("/engines/active-engine/oil_temp_factor", 0.0);
    };
});

# ========== engine coughing ======================

# adapted from c172p, thanks to @gilbertohasnofb

var engine_coughing = func(){

    var coughing = getprop("/engines/active-engine/coughing");
    var running = getprop("/engines/active-engine/running");
    
    if (coughing and running) {        
        setprop("/engines/active-engine/kill-engine", 1);
        # Bring the engine back to life after 0.25 seconds
        settimer(func {
            setprop("/engines/active-engine/kill-engine", 0);
        }, 0.25);
    };
    
    # basic value for the delay, in case no fuel contamination nor carb ice are present
    # this will be the update value for this function
    var delay = 2;
    
    # if coughing due to fuel contamination, then cough interval depends on quantity of water
    #var water_contamination0 = getprop("/consumables/fuel/tank[0]/water-contamination");
    #var water_contamination1 = getprop("/consumables/fuel/tank[1]/water-contamination");
    #var total_water_contamination = std.min((water_contamination0 + water_contamination1), 0.4);
    #if (total_water_contamination > 0) {
        # if contamination is near 0, then interval is between 17 and 20 seconds, but if contamination is near the 
        # engine stopping value of 0.4, then interval falls to around 0.5 and 3.5 seconds
    #    delay = 3.0 * rand() + 17 - 41.25 * total_water_contamination;
    #};
    
    # if coughing due to carb ice melting, then cough depends on quantity of ice
    var carb_ice = getprop("/engines/active-engine/carb_ice");
    if (carb_ice > 0) {
        # if carb_ice is near 0, then interval is between 17 and 20 seconds, but if carb_ice is near the 
        # engine stopping value of 0.3, then interval falls to around 0.5 and 3.5 seconds
        delay = 3.0 * rand() + 17 - 41.25 * carb_ice;
    };
    
    coughing_timer.restart(delay);
    
}

var coughing_timer = maketimer(1, engine_coughing);
coughing_timer.singleShot = 1;

var engine_timer = maketimer(UPDATE_PERIOD, func { update(); });

setlistener("/sim/signals/fdm-initialized", func {
    engine_timer.start();
    carb_icing_function.start();
    coughing_timer.start();
});
