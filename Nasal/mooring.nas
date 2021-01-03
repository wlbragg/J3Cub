#############################
#   Usable with FlightGear
#   Property of Gerard Robin
#   Copyright License:  GPL
#
#   Was by Gerard ROBIN.
#   update: grtux hangar team https://sites.google.com/site/grtuxhangar/
#   COPYRIGHT
############################
#init Moorage.
#Replace the generic Seaboat fightgear system which is wrong, and not completed with the list of harbours.
#This is a customized developpement done from an original idea => the Boeing 314A Project (the nice and accurate FG Clipper) thanks to his unknown Author.
#We are using the original harbour list which was used by the boeing314 model and using too a specific customized addon list which could be improved.
#both files are: mooring-pos_boeing314-based.xml, mooring-pos.xml
############################
#Modifications:
#Wayne Bragg/J3Cub, April 2018
############################

#init if allowed and called for
var mooring_preset = 0;
var presets = props.globals.getNode("/sim/presets");
var seaplanes = props.globals.getNode("/systems/mooring/route").getChildren("seaplane");
var harbour = "";
var airport = presets.getChild("airport-id").getValue();

setlistener("/sim/signals/fdm-initialized",
    func {
        setprop("/controls/mooring/port-available", 0);
        if(airport != nil and airport != "") {
            for(var i=0; i<size(seaplanes); i=i+1) {
                harbour = seaplanes[ i ].getChild("airport-id").getValue();
                if(harbour == airport) {
                    setprop("/controls/mooring/port-available", 1);
                }
            }
        }
        settimer(func{
            if (getprop("/controls/mooring/automatic") and getprop("/controls/mooring/allowed")) {
                seaplane = Mooring.new();
            }
            if (mooring_preset) {
                mooring_preset=0;
                # force aircraft into proper orientation (bug in presets or reset?)
                setprop("/orientation/roll-deg", 0);
                setprop("/orientation/pitch-deg", 0);

                if (getprop("/fdm/jsbsim/settings/damage-flag")) {
                    settimer(func {
                        setprop("/fdm/jsbsim/settings/damage", 1);
                        setprop("/fdm/jsbsim/settings/damage-flag", 0);
                    }, 2);
                }
                if (!getprop("/controls/switches/master-bat")) {
                    setprop("/controls/switches/master-bat", 1);
                    setprop("/controls/gear/gear-down", 0);
                    setprop("/fdm/jsbsim/gear/gear-pos-norm", 0);
                    settimer(func {
                        setprop("/controls/switches/master-bat", 0);
                    }, 0.1);
                } else {
                    setprop("/controls/gear/gear-down", 0);
                    setprop("/fdm/jsbsim/gear/gear-pos-norm", 0);
                }
            }
        },1.0);
    }
);

setlistener("/controls/mooring/go-to-mooring",
    func {
        if (getprop("/controls/mooring/allowed")) {
            seaplane = Mooring.new();
        }
    }
);

Mooring = {};

Mooring.new = func {
    var obj = {
        parents : [Mooring],
        presets : nil,
        seaplanes : nil,
    };
    obj.init();
    return obj;
};

Mooring.init = func {
    me.presets = props.globals.getNode("/sim/presets");
    me.seaplanes = props.globals.getNode("/systems/mooring/route").getChildren("seaplane");
    me.presetseaplane();
}

Mooring.setmoorage = func( index, moorage ) {
    var latitudedeg = me.seaplanes[ index ].getChild("latitude-deg").getValue();
    var longitudedeg = me.seaplanes[ index ].getChild("longitude-deg").getValue();
    var headingdeg = me.seaplanes[ index ].getChild("heading-deg").getValue();
    print (" LAT ",latitudedeg," LON ",longitudedeg," HEAD ",headingdeg);

    # overwrite the coordinates from the original airport
    me.presets.getChild("airport-id").setValue("");
    me.presets.getChild("latitude-deg").setValue(latitudedeg);
    me.presets.getChild("longitude-deg").setValue(longitudedeg);
    me.presets.getChild("heading-deg").setValue(headingdeg);
    me.presets.getChild("roll-deg").setValue(0);
    me.presets.getChild("pitch-deg").setValue(0);
    me.presets.getChild("airspeed-kt").setValue(0);
    # forces the computation of ground
    me.presets.getChild("altitude-ft").setValue(-9999);
}

Mooring.presetseaplane = func {
    # to search the harbor
    if(getprop("/sim/sceneryloaded")) {
        mooring_preset = 1;
        me.presetharbour();
    }
    else
        mooring_preset = 0
}

# search the port
Mooring.presetharbour = func {
    var airport = "";
    var harbour = "";
    airport = me.presets.getChild("airport-id").getValue();
    if(airport != nil and airport != "") {
        for(var i=0; i<size(me.seaplanes); i=i+1) {
            harbour = me.seaplanes[ i ].getChild("airport-id").getValue();
            if(harbour == airport) {
                print("PORT ",harbour,"    Index ",i);
                me.setmoorage(i, airport);
                me.prepareseaplane();
                aircraft.data.add("/fdm/jsbsim/bushkit");
                fgcommand("reposition");
                break;
            }
        }
    }
}

#Specific initialization of the aircraft
Mooring.prepareseaplane = func{
    if (getprop("/fdm/jsbsim/settings/damage")) {
        setprop("/fdm/jsbsim/settings/damage-flag", 1);
        setprop("/fdm/jsbsim/settings/damage", 0);
    }
    setprop("/sim/model/j3cub/securing/tiedownL-visible", 0);
    setprop("/sim/model/j3cub/securing/tiedownR-visible", 0);
    setprop("/sim/model/j3cub/securing/tiedownT-visible", 0);
    setprop("/sim/model/j3cub/securing/chock-visible", 0);
}
