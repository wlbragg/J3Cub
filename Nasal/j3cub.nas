##########################################
# Autostart
##########################################

var autostart = func (msg=1) {
    if (getprop("/engines/active-engine/running")) {
        if (msg)
            gui.popupTip("Engine already running", 5);
        return;
    }

    setprop("/controls/switches/magnetos", 3);
    setprop("/controls/engines/current-engine/throttle", 0.2);

    var engine_regime = getprop("/controls/engines/active-engine");
    if (engine_regime > 0) {
        var auto_mixture = getprop("/fdm/jsbsim/engine/auto-mixture");
        setprop("/controls/engines/current-engine/mixture", auto_mixture);
    } else {
        setprop("/controls/engines/current-engine/mixture", 0.88);
    }

    # Reset battery charge and circuit breakers
    electrical.reset_battery_and_circuit_breakers();

    if (getprop("/sim/model/j3cub/pa-18")) {

        # Setting lights
        setprop("/controls/lighting/nav-lights", 0);
        setprop("/controls/lighting/strobe-lights", 0);
        setprop("/controls/lighting/beacon-light", 0);
        setprop("/controls/switches/panel-lights", 0);
        setprop("/controls/lighting/taxi-light", 0);
        setprop("/controls/lighting/landing-light", 0);
        setprop("/controls/switches/master-avionics", 0);
        setprop("/controls/switches/pitot-heat", 0);
        setprop("/systems/static-selected-source", 0);
        setprop("/controls/switches/master-bat", 1);
    }

    # Setting amphibious landing gear if needed
    if (getprop("/fdm/jsbsim/bushkit")==3){
        if (getprop("/fdm/jsbsim/hydro/active-norm")) {
            setprop("controls/gear/gear-down-command", 0);
            setprop("/fdm/jsbsim/gear/gear-pos-norm", 0);
        } else {
            setprop("controls/gear/gear-down-command", 1);
            setprop("/fdm/jsbsim/gear/gear-pos-norm", 1);
        }
    }

    # Set the altimeter
    var pressure_sea_level = getprop("/environment/pressure-sea-level-inhg");
    setprop("/instrumentation/altimeter/setting-inhg", pressure_sea_level);

    # Set heading offset
    var magnetic_variation = getprop("/environment/magnetic-variation-deg");
    setprop("/instrumentation/heading-indicator/offset-deg", -magnetic_variation);

    # removing any ice from the carburetor
    setprop("/engines/active-engine/carb_ice", 0.0);
    setprop("/engines/active-engine/carb_icing_rate", 0.0);

    # Set the altimeter
    var pressure_sea_level = getprop("/environment/pressure-sea-level-inhg");
    setprop("/instrumentation/altimeter/setting-inhg", pressure_sea_level);

    # Pre-flight inspection
    #setprop("/sim/model/j3cub/brake-parking", 0);
    setprop("/sim/model/j3cub/securing/chock", 0);
    setprop("/sim/model/j3cub/securing/pitot-cover-visible", 0);
    setprop("/sim/model/j3cub/securing/tiedownL-visible", 0);
    setprop("/sim/model/j3cub/securing/tiedownR-visible", 0);
    setprop("/sim/model/j3cub/securing/tiedownT-visible", 0);
    #setprop("/engines/active-engine/oil-level", 7.0);
    #setprop("/consumables/fuel/tank[0]/water-contamination", 0.0);

    # set fuel configuration
    set_fuel();

    setprop("/controls/engines/engine[0]/primer-lever", 0);
    setprop("/controls/engines/engine/primer", 3);
    
        ############################
    # All set, starting engine
    setprop("/controls/switches/starter", 1);
    setprop("/engines/active-engine/auto-start", 1);


    var engine_running_check_delay = 6.0;
    settimer(func {
        if (!getprop("/engines/active-engine/running")) {
            gui.popupTip("The autostart failed to start the engine. You can lean the mixture and try to start the engine manually.", 5);
        } else {
            if (getprop("/sim/model/j3cub/pa-18")) {

                # Setting lights
                setprop("/controls/lighting/nav-lights", 1);
                setprop("/controls/lighting/strobe-lights", 1);
                setprop("/controls/lighting/beacon-light", 1);

                # Setting instrument lights if needed
                var light_level = 1-getprop("/rendering/scene/diffuse/red");
                if (light_level > .6) {
                    setprop("/controls/switches/panel-lights", 1);
                    setprop("/controls/lighting/taxi-light", 1);
                    setprop("/controls/lighting/landing-light", 1);
                } else {
                    setprop("/controls/switches/panel-lights", 0);
                    setprop("/controls/lighting/taxi-light", 0);
                    setprop("/controls/lighting/landing-light", 0);
                }

                setprop("controls/switches/master-avionics", 1);

            }
        }

        #setprop("/controls/engines/current-engine/starter", 0);
        setprop("/controls/switches/starter", 0);
        setprop("/engines/active-engine/auto-start", 0);

    }, engine_running_check_delay);

};

##########################################
# Brakes
##########################################

controls.applyBrakes = func (v, which = 0) {
    if (which <= 0 and !getprop("/fdm/jsbsim/gear/unit[1]/broken")) {
        interpolate("/controls/gear/brake-left", v, controls.fullBrakeTime);
    }
    if (which >= 0 and !getprop("/fdm/jsbsim/gear/unit[2]/broken")) {
        interpolate("/controls/gear/brake-right", v, controls.fullBrakeTime);
    }
};

controls.applyParkingBrake = func (v) {
    if (!v) {
        return;
    }

    var p = "/sim/model/j3cub/brake-parking";
    setprop(p, var i = !getprop(p));
    return i;
};

##########################################
# Click Sounds
##########################################

var click = func (name, timeout=0.1, delay=0) {
    var sound_prop = "/sim/model/j3cub/sound/click-" ~ name;

    settimer(func {
        # Play the sound
        setprop(sound_prop, 1);

        # Reset the property after "timeout" seconds so that the sound can be
        # played again.
        settimer(func {
            setprop(sound_prop, 0);
        }, timeout);
    }, delay);
};

##########################################
# Thunder Sound
##########################################

var speed_of_sound = func (t, re) {
    # Compute speed of sound in m/s
    #
    # t = temperature in Celsius
    # re = amount of water vapor in the air

    # Compute virtual temperature using mixing ratio (amount of water vapor)
    # Ratio of gas constants of dry air and water vapor: 287.058 / 461.5 = 0.622
    var T = 273.15 + t;
    var v_T = T * (1 + re/0.622)/(1 + re);

    # Compute speed of sound using adiabatic index, gas constant of air,
    # and virtual temperature in Kelvin.
    return math.sqrt(1.4 * 287.058 * v_T);
};

var thunder = func (name) {
    var flash = getprop("/environment/lightning/flash");
    if (flash < 1) return;

    var thunderCalls = 0;

    var lightning_pos_x = getprop("/environment/lightning/lightning-pos-x");
    var lightning_pos_y = getprop("/environment/lightning/lightning-pos-y");
    var lightning_distance = math.sqrt(math.pow(lightning_pos_x, 2) + math.pow(lightning_pos_y, 2));

    # On the ground, thunder can be heard up to 16 km. Increase this value
    # a bit because the aircraft is usually in the air.
    if (lightning_distance > 20000)
        return;

    var t = getprop("/environment/temperature-degc");
    var re = getprop("/environment/relative-humidity") / 100;
    var delay_seconds = lightning_distance / speed_of_sound(t, re);

    # Maximum volume at 5000 meter
    var lightning_distance_norm = std.min(1.0, 1 / math.pow(lightning_distance / 5000.0, 2));

    settimer(func {
        var thunder1 = getprop("/sim/model/j3cub/sound/click-thunder1");
        var thunder2 = getprop("/sim/model/j3cub/sound/click-thunder2");
        var thunder3 = getprop("/sim/model/j3cub/sound/click-thunder3");

        if (!thunder1) {
            thunderCalls = 1;
            setprop("/sim/model/j3cub/sound/lightning/dist1", lightning_distance_norm);
        }
        else if (!thunder2) {
            thunderCalls = 2;
            setprop("/sim/model/j3cub/sound/lightning/dist2", lightning_distance_norm);
        }
        else if (!thunder3) {
            thunderCalls = 3;
            setprop("/sim/model/j3cub/sound/lightning/dist3", lightning_distance_norm);
        }
        else
            return;

        # Play the sound (sound files are about 9 seconds)
        click("thunder" ~ thunderCalls, 9.0, 0);
    }, delay_seconds);
};

########
# Reset
########

var reset_system = func {
    if (getprop("/fdm/jsbsim/running")) {
        j3cub.autostart(0);
    } else
    if (getprop("/sim/model/j3cub/pa-18")==0) {
        setprop("/controls/flight/elevator-trim", 0.0);
        setprop("/controls/switches/master-bat", 1);
        setprop("/controls/switches/master-avionics", 1);
        setprop("/controls/engines/current-engine/mixture", 0.88);
        setprop("/controls/switches/pitot-heat", 0);
        setprop("/systems/static-selected-source", 0);
    } else {
        setprop("/controls/engines/current-engine/mixture", 1.0);
    }
    setprop("/controls/switches/magnetos", 0);
    setprop("/engines/active-engine/volumetric-efficiency-factor", .85);

    # These properties are aliased to MP properties in /sim/multiplay/generic/.
    # This aliasing seems to work in both ways, because the two properties below
    # appear to receive the random values from the MP properties during initialization.
    # Therefore, override these random values with the proper values we want.
    props.globals.getNode("/fdm/jsbsim/crash", 0).setBoolValue(0);
    props.globals.getNode("/fdm/jsbsim/gear/unit[0]/broken", 0).setBoolValue(0);
    props.globals.getNode("/fdm/jsbsim/gear/unit[1]/broken", 0).setBoolValue(0);
    props.globals.getNode("/fdm/jsbsim/gear/unit[2]/broken", 0).setBoolValue(0);
    props.globals.getNode("/fdm/jsbsim/gear/unit[29]/broken", 0).setBoolValue(0);
    props.globals.getNode("/fdm/jsbsim/pontoon-damage/left-pontoon", 0).setIntValue(0);
    props.globals.getNode("/fdm/jsbsim/pontoon-damage/right-pontoon", 0).setIntValue(0);
    props.globals.getNode("/fdm/jsbsim/ski-damage/left-ski", 0).setIntValue(0);
    props.globals.getNode("/fdm/jsbsim/ski-damage/right-ski", 0).setIntValue(0);
    setprop("/engines/active-engine/crash-engine", 0);

}

##################
# Passenger state
##################

var update_pax = func {
    var state = 0;
    state = bits.switch(state, 0, getprop("pax/pilot/present"));
    state = bits.switch(state, 1, getprop("pax/passenger/present"));
    setprop("/payload/pax-state", state);
};

setlistener("/pax/pilot/present", update_pax, 0, 0);
setlistener("/pax/passenger/present", update_pax, 0, 0);
update_pax();

##################
# Secure aircraft
##################

var update_securing = func {
    var state = 0;
    state = bits.switch(state, 0, getprop("/sim/model/j3cub/securing/pitot-cover-visible"));
    state = bits.switch(state, 1, getprop("/sim/model/j3cub/securing/chock-visible"));
    state = bits.switch(state, 2, getprop("/sim/model/j3cub/securing/tiedownL-visible"));
    state = bits.switch(state, 3, getprop("/sim/model/j3cub/securing/tiedownR-visible"));
    state = bits.switch(state, 4, getprop("/sim/model/j3cub/securing/tiedownT-visible"));
    setprop("/payload/securing-state", state);
};

setlistener("/sim/model/j3cub/securing/pitot-cover-visible", update_securing, 0, 0);
setlistener("/sim/model/j3cub/securing/chock-visible", update_securing, 0, 0);
setlistener("/sim/model/j3cub/securing/tiedownL-visible", update_securing, 0, 0);
setlistener("/sim/model/j3cub/securing/tiedownR-visible", update_securing, 0, 0);
setlistener("/sim/model/j3cub/securing/tiedownT-visible", update_securing, 0, 0);
update_securing();

#########################
# Engine coughing sound
#########################

setlistener("/engines/active-engine/killed", func (node) {
    if (node.getValue() and getprop("/engines/active-engine/running")) {
        click("coughing-engine-sound", 0.7, 0);
    };
});

##############
# Payload
##############
var capacity = 0.0;
var velocity = 0; 

var payload_release = func {

    var payload = getprop("/sim/model/payload");
    var trigger = getprop("/controls/armament/trigger");
    var hopperweight = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[15]");
    var payloadpackage = getprop("/sim/model/payload-package");

    if (!payload) {
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[15]", 0.0);  
        return;
    }
    if (trigger and payload and (!hopperweight or hopperweight < .01)) {
        logger.screen.white("Hopper is empty");
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[15]", 0);
        return;
    }
    if (trigger and hopperweight and payloadpackage == 0 and payload) {
        capacity = 0.025;    
        velocity = getprop("/velocities/airspeed-kt");
        hopperweight = hopperweight - capacity * velocity;
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[15]", hopperweight);
    } else if (trigger and hopperweight and payloadpackage == 1 and payload) {
        capacity = .75;
        velocity = 9.8;
        hopperweight = hopperweight - capacity * velocity;
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[15]", hopperweight);
    } else if (trigger and hopperweight and payloadpackage == 2 and payload and getprop("/sim/model/drums/rotate/position-norm") > .633) {
        capacity = 15;
        velocity = 13;
        hopperweight = hopperweight - capacity * velocity;
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[15]", hopperweight);
    }
}

var prior_view = getprop("/sim/current-view/view-number-raw") or 0;

var view_manager = func {
    var payload = getprop("/sim/model/payload");
    var payloadpackage = getprop("/sim/model/payload-package");
    var occ1 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]");#back
    var occ2 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]");#front

    var currentview = getprop("/sim/current-view/view-number-raw") or 0;
    # ext-front 8, raw 8 : front 9, raw 100 : back 0 raw 0 : ext-back 1, raw 1

    var hopperweight = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[15]");

    if (payload == 1 and payloadpackage < 2) {
        if (currentview == 0 and prior_view == 0) {
            setprop("/sim/current-view/view-number-raw", 100);
            setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", occ1);
            setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", 0);
            logger.screen.white("Pilot moved to front seat, no passengers allowed!");
        } else
        if (currentview == 0 and prior_view == 1) {
            setprop("/sim/current-view/view-number-raw", 100);
        } else
        if (currentview == 0 and prior_view == 9) {
            setprop("/sim/current-view/view-number-raw", 1);
        }
    }

    #if ((currentview == 0 and prior_view == 100) or (currentview == 100 and prior_view == 0)) {
    #        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", occ1);
    #        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", occ2);
    #}

    prior_view = getprop("/sim/current-view/view-number-raw") or 0;
}

var drum_release = func {
    j3cub.drums.toggle();
}

var resolve_impact = func (n) {
    #print("Retardant impact!");
    var node = props.globals.getNode(n.getValue());
    var pos  = geo.Coord.new().set_latlon
                   (node.getNode("impact/latitude-deg").getValue(),
                    node.getNode("impact/longitude-deg").getValue(),
                    node.getNode("impact/elevation-m").getValue());
    # The arguments are: position, radius and volume (currently unused).
    wildfire.resolve_foam_drop(pos, 10, 0);
    #wildfire.resolve_retardant_drop(pos, 10, 0);
}

# Listen for release of payload
setlistener("controls/armament/trigger", drum_release);

# Listen for impact of released payload
setlistener("/sim/ai/aircraft/impact/retardant", resolve_impact);

#######################
# Cabin heat and air
#######################

var log_cabin_temp = func {
    if (getprop("/sim/model/j3cub/enable-fog-frost")) {
        var temp_degc = getprop("/fdm/jsbsim/heat/cabin-air-temp-degc") or 32.0;
        if (temp_degc >= 32)
            logger.screen.red("Cabin temperature exceeding 90F/32C!");
        elsif (temp_degc <= 0)
            logger.screen.red("Cabin temperature falling below 32F/0C!");
    }
};
var cabin_temp_timer = maketimer(30.0, log_cabin_temp);

var log_fog_frost = func {
    if (getprop("/sim/model/j3cub/enable-fog-frost")) {
        logger.screen.white("Wait until fog/frost clears up or decrease cabin air temperature");
    }
}
var fog_frost_timer = maketimer(30.0, log_fog_frost);

#######################
# Fuel and Payload
#######################
var set_limits = func (engine, model) {

    if (engine == 2) {
        var limits = props.globals.getNode("/limits/mass-and-balance-150hp");
    }
    else
    if (engine == 1) {
        var limits = props.globals.getNode("/limits/mass-and-balance-95hp");
    }
    else {
        var limits = props.globals.getNode("/limits/mass-and-balance-65hp");
    }

    # Get the mass limits of the current engine
    var ramp_mass = limits.getNode("maximum-ramp-mass-lbs");
    var takeoff_mass = limits.getNode("maximum-takeoff-mass-lbs");
    var landing_mass = limits.getNode("maximum-landing-mass-lbs");

    var ac_limits = props.globals.getNode("/limits/mass-and-balance");

    # Get the actual mass limit nodes of the aircraft
    var ac_ramp_mass = ac_limits.getNode("maximum-ramp-mass-lbs");
    var ac_takeoff_mass = ac_limits.getNode("maximum-takeoff-mass-lbs");
    var ac_landing_mass = ac_limits.getNode("maximum-landing-mass-lbs");

    if (model == 1) {
        var vne_limits = props.globals.getNode("/limits/vne-pa18");
    }
    else {
        var vne_limits = props.globals.getNode("/limits/vne-j3cub");
    }

    # Set the Vne of the current model
    setprop("limits/vne", vne_limits.getValue("vne"));

    # Set the mass limits of the aircraft
    ac_ramp_mass.unalias();
    ac_takeoff_mass.unalias();
    ac_landing_mass.unalias();

    ac_ramp_mass.alias(ramp_mass);
    ac_takeoff_mass.alias(takeoff_mass);
    ac_landing_mass.alias(landing_mass);
};

var set_fuel = func {
    
    var tanks = getprop("/sim/model/j3cub/pa-18");
    if (tanks) {
        setprop("/consumables/fuel/tank[0]/level-gal_us", 0);
        setprop("/consumables/fuel/tank[1]/level-gal_us", 16);
        setprop("/consumables/fuel/tank[2]/level-gal_us", 16);
        setprop("/consumables/fuel/tanks/selected", 2);
        setprop("/consumables/fuel/tank[0]/selected", 0);
        setprop("/controls/engines/current-engine/mixture", 1.0);
        # Setting flaps to 0 in PA-18
        setprop("/controls/flight/flaps", 0.0);
    } else {
        setprop("/consumables/fuel/tank[0]/level-gal_us", 10);
        setprop("/consumables/fuel/tank[1]/level-gal_us",  0);
        setprop("/consumables/fuel/tank[2]/level-gal_us",  0);
        setprop("/consumables/fuel/tanks/selected", 0);
        setprop("/consumables/fuel/tank[0]/selected", 1);
        # No flaps in J3Cub
        setprop("/controls/flight/flaps", 0.0);
        # if j3cub, no mixture control, so set to .88
        setprop("/controls/engines/current-engine/mixture", 0.88);
    }
    setprop("/engines/active-engine/volumetric-efficiency-factor", .85);
};

############################################
# Static objects: mooring anchor
############################################

var StaticModel = {
    new: func (name, file) {
        var m = {
            parents: [StaticModel],
            model: nil,
            model_file: file,
            object_name: name
        };

        setlistener("/sim/" ~ name ~ "/enable", func (node) {
            if (node.getBoolValue()) {
                m.add();
            }
            else {
                m.remove();
            }
        });

        return m;
    },

    add: func {
        var manager = props.globals.getNode("/models", 1);
        var i = 0;
        for (; 1; i += 1) {
            if (manager.getChild("model", i, 0) == nil) {
                break;
            }
        }
        var position = geo.aircraft_position().set_alt(getprop("/position/ground-elev-m"));
        if (me.object_name == "anchorbuoy") {
            me.model = geo.put_model(me.model_file, getprop("/fdm/jsbsim/mooring/anchor-lat"), getprop("/fdm/jsbsim/mooring/anchor-lon"), getprop("/position/ground-elev-m"), getprop("/orientation/heading-deg"));
        } else {
            me.model = geo.put_model(me.model_file, position, getprop("/orientation/heading-deg"));
        }
    },

    remove: func {
        if (me.model != nil) {
            me.model.remove();
            me.model = nil;
        }
    }
};

StaticModel.new("coneR", "Aircraft/J3Cub/Models/Exterior/safety-cone/coneR.ac");
StaticModel.new("coneL", "Aircraft/J3Cub/Models/Exterior/safety-cone/coneL.ac");
StaticModel.new("gpu", "Aircraft/J3Cub/Models/Exterior/external-power/external-power.xml");
StaticModel.new("ladderL", "Aircraft/J3Cub/Models/Exterior/ladder/ladderL.ac");
StaticModel.new("ladderR", "Aircraft/J3Cub/Models/Exterior/ladder/ladderR.ac");
StaticModel.new("fueltanktrailer", "Aircraft/J3Cub/Models/Exterior/fueltanktrailer/fueltanktrailer.ac");
StaticModel.new("externalheater", "Aircraft/J3Cub/Models/Exterior/external-heater/heater.xml");

# Mooring anchor and rope
StaticModel.new("anchorbuoy", "Aircraft/J3Cub/Models/Effects/pontoon/mooring.xml");

var prior_variant = getprop("/sim/model/j3cub/pa-18");
############################################
# Global loop function
# If you need to run nasal as loop, add it in this function
############################################
var global_system_loop = func {

    if (getprop("/sim/model/preload") == 1) {
        setprop("/sim/current-view/view-number-raw", prior_view);
        setprop("/sim/model/j3cub/pa-18", prior_variant);
        setprop("/sim/model/preload", 0);
        print("End Preloading Mesh");
    }

    j3cub.physics_loop();
    view_manager();
    payload_release();

}

var j3cub_timer = maketimer(0.25, func{global_system_loop()});

###########################################
# SetListerner requiring fdminit go here
###########################################
setlistener("/sim/signals/fdm-initialized", func {

    if (getprop("/sim/model/j3cub/pa-18")) {
        setprop("/sim/current-view/view-number-raw", 100);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", 180);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", 0);
    }  else {
        setprop("/sim/current-view/view-number-raw", 0);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", 180);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", 0);
    }

    prior_view = getprop("/sim/current-view/view-number-raw") or 0;

    if (getprop("/sim/model/j3cub/preload-resources")) {
      print("Begin Preloading Mesh");
      setprop("/sim/model/preload", 1);
      if (prior_view == 0)
          setprop("/sim/current-view/view-number-raw", 100);
      else
          setprop("/sim/current-view/view-number-raw", 0);
      setprop("/sim/current-view/view-number-raw", 1);
      if (prior_variant == 0)
          setprop("/sim/model/j3cub/pa-18", 1);
      else
          setprop("/sim/model/j3cub/pa-18", 0);
    }

    # Use Nasal to make some properties persistent. <aircraft-data> does
    # not work reliably.
    aircraft.data.add("/sim/model/occupants");
    aircraft.data.add("/sim/model/j3cub/securing/allow-securing-aircraft");
    aircraft.data.add("/sim/model/j3cub/securing/pitot-cover-visible");
    aircraft.data.add("/sim/model/j3cub/securing/chock");
    #aircraft.data.add("/sim/model/j3cub/securing/tiedownL-visible");
    #aircraft.data.add("/sim/model/j3cub/securing/tiedownR-visible");
    #aircraft.data.add("/sim/model/j3cub/securing/tiedownT-visible");
    aircraft.data.add("/sim/model/j3cub/securing/brake-parking");
    aircraft.data.add("/environment/aircraft-effects/dirt");
    aircraft.data.add("/fdm/jsbsim/running");
    aircraft.data.add("/fdm/jsbsim/settings/damage");
    aircraft.data.add("/engines/active-engine/carb_icing_allowed");
    aircraft.data.add("/sim/model/j3cub/enable-fog-frost");
    aircraft.data.add("/environment/aircraft-effects/cabin-heat-set");
    aircraft.data.add("/consumables/fuel/tanks/selected");
    aircraft.data.add("/sim/model/j3cub/brake-parking");
    aircraft.data.add("/controls/mooring/automatic");
    aircraft.data.add("/sim/model/immat");
    aircraft.data.add("/sim/model/j3cub/airtemp");
    aircraft.data.add("/sim/model/j3cub/autopilot");
    aircraft.data.add("/it-stec55x/input/hdg");
    aircraft.data.add("/sim/model/pa-18/variable-prop");
    aircraft.data.load();

    set_fuel();

    # Listening for lightning strikes
    setlistener("/environment/lightning/flash", thunder);

    # Initialize mass limits
    setlistener("/controls/engines/active-engine", func {
        # Set new mass limits for Fuel and Payload Settings dialog
        set_limits(getprop("/controls/engines/active-engine"), getprop("/sim/model/j3cub/pa-18"));
        set_fuel();
        # Emit a sound because the engine has been replaced
        click("engine-repair", 6.0);
    }, 0, 0);

    setlistener("/sim/model/j3cub/pa-18", func (node) {
    #   #switch occupant weight if variant change
    #   var occ1 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]");
    #   var occ2 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]");
    #   setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", occ1);
    #   setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", occ2);

        # Set view to front seat if pa-18
    #   if (getprop("/sim/current-view/interior")) {
    #       setprop("/sim/current-view/view-number-raw", 100);
    #   } else {
    #       setprop("/sim/current-view/view-number-raw", 0);
    #   }

        # Set new mass limits for Fuel and Payload Settings dialog
        set_limits(getprop("/controls/engines/active-engine"), node.getValue());
        set_fuel();
    }, 0, 0);

    setlistener("/engines/active-engine/running", func (node) {
        var autostart = getprop("/engines/active-engine/auto-start");
        var cranking  = getprop("/engines/active-engine/cranking");
        if (autostart and cranking and node.getBoolValue()) {
            setprop("/controls/switches/starter", 0);
            setprop("/engines/active-engine/auto-start", 0);
        }
    }, 0, 0);

    setlistener("/engines/active-engine/cranking", func (node) {
        setprop("/engines/active-engine/external-heat/enabled", 0);
        setprop("/sim/externalheater/enable", 0)
    }, 0, 0);

    reset_system();

    var onground = getprop("/sim/presets/onground") or "";
    if (!onground) {
        state_manager();
    }

    j3cub.rightWindow.toggle();
    j3cub.rightDoor.toggle();

    # set user defined pilot view or initialize it
    if (getprop("sim/current-view/view-number") == 0){
        settimer(func {
            if (getprop("sim/current-view/user/x-offset-m") != nil){
                setprop("sim/current-view/x-offset-m", getprop("sim/current-view/user/x-offset-m"));
            } else {
                setprop("sim/current-view/user/x-offset-m", getprop("sim/view/config/x-offset-m"));
            }
            if (getprop("sim/current-view/user/y-offset-m") != nil){
                setprop("sim/current-view/y-offset-m", getprop("sim/current-view/user/y-offset-m"));
            } else {
                setprop("sim/current-view/user/y-offset-m", getprop("sim/view/config/y-offset-m"));
            }
            if (getprop("sim/current-view/user/z-offset-m") != nil){
                setprop("sim/current-view/z-offset-m", getprop("sim/current-view/user/z-offset-m"));
            } else {
                setprop("sim/current-view/user/z-offset-m", getprop("sim/view/config/z-offset-m"));
            }
            if (getprop("sim/current-view/user/default-field-of-view-deg") != nil){
                setprop("sim/current-view/field-of-view", getprop("sim/current-view/user/default-field-of-view-deg"));
            } else {
                setprop("sim/current-view/user/default-field-of-view-deg", getprop("sim/view/config/default-field-of-view-deg"));
            }
            if (getprop("sim/current-view/user/pitch-offset-deg") != nil){
                setprop("sim/current-view/pitch-offset-deg", getprop("sim/current-view/user/pitch-offset-deg"));
            } else {
                setprop("sim/current-view/user/pitch-offset-deg", getprop("sim/view/config/pitch-offset-deg"));
            }
        }, 1);
    }

    settimer(func {
        if (getprop("/sim/model/j3cub/securing/tiedownT"))
            setprop("/sim/model/j3cub/securing/tiedownT-visible", 1);
        if (getprop("/sim/model/j3cub/securing/tiedownR"))
            setprop("/sim/model/j3cub/securing/tiedownR-visible", 1);
        if (getprop("/sim/model/j3cub/securing/tiedownL"))
            setprop("/sim/model/j3cub/securing/tiedownL-visible", 1);
    }, 10);

    j3cub_timer.start();
});

setlistener("/sim/model/j3cub/cabin-air-temp-in-range", func (node) {
    if (node.getValue()) {
        cabin_temp_timer.stop();
        logger.screen.green("Cabin temperature between 32F/0C and 90F/32C");
    }
    else {
        log_cabin_temp();
        cabin_temp_timer.start();
    }
}, 1, 0);

setlistener("/sim/model/j3cub/fog-or-frost-increasing", func (node) {
    if (node.getValue()) {
        log_fog_frost();
        fog_frost_timer.start();
    }
    else {
        fog_frost_timer.stop();
    }
}, 1, 0);

# season-winter is a conversion value, see j3cub-ground-effects.xml
setprop("/sim/startup/season-winter", getprop("/sim/startup/season") == "winter");
setlistener("/sim/startup/season", func (node) {
    setprop("/sim/startup/season-winter", node.getValue() == "winter");
}, 0, 0);

# fdm/jsbsim/ground/terrain-name-value is a conversion value, see j3cub-ground-effects-terrain.xml
setprop("/fdm/jsbsim/ground/terrain-name-value", getprop("/fdm/jsbsim/ground/terrain-names") == "EvergreenBroadCover");
setlistener("/fdm/jsbsim/ground/terrain-names", func (node) {
    setprop("/fdm/jsbsim/ground/terrain-name-value", node.getValue() == "EvergreenBroadCover");
}, 0, 0);

setlistener("/sim/model/j3cub/securing/chock-can-have", func (node) {
	if (!node.getValue()) {
        setprop("/sim/model/j3cub/securing/chock", 0);
    }
}, 0, 0);
