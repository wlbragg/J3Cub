var particle_effects_loop = func {

    #particle effect colors
    var alt = getprop("/position/altitude-agl-m");
    var land = getprop("/fdm/jsbsim/ground/solid");
    var red_diffuse = getprop("/rendering/scene/diffuse/red");
    var snowlevel = getprop("/environment/snow-level-m");
    var winter = getprop("/sim/startup/season-winter");

    var friction = getprop("/fdm/jsbsim/ground/rolling_friction-factor");
    var bumpiness = getprop("/fdm/jsbsim/ground/bumpiness");
    var smooth_surface = 0;

    if (friction == 1 or friction == .25 and bumpiness == 0) {
        smooth_surface = 1;
    }

    if (land) {
        if (alt > snowlevel or smooth_surface or winter) {
            setprop("/sim/model/j3cub/lighting/particles/redcombinedstart",   red_diffuse*.8);
            setprop("/sim/model/j3cub/lighting/particles/greencombinedstart", red_diffuse*.8);
            setprop("/sim/model/j3cub/lighting/particles/bluecombinedstart",  red_diffuse*.8);
            setprop("/sim/model/j3cub/lighting/particles/redcombinedend",     red_diffuse*.9);
            setprop("/sim/model/j3cub/lighting/particles/greencombinedend",   red_diffuse*.9);
            setprop("/sim/model/j3cub/lighting/particles/bluecombinedend",    red_diffuse*.9);
        } else {
            setprop("/sim/model/j3cub/lighting/particles/redcombinedstart",   red_diffuse*.89);
            setprop("/sim/model/j3cub/lighting/particles/greencombinedstart", red_diffuse*.76);
            setprop("/sim/model/j3cub/lighting/particles/bluecombinedstart",  red_diffuse*.57);
            setprop("/sim/model/j3cub/lighting/particles/redcombinedend",     red_diffuse*.99);
            setprop("/sim/model/j3cub/lighting/particles/greencombinedend",   red_diffuse*.86);
            setprop("/sim/model/j3cub/lighting/particles/bluecombinedend",    red_diffuse*.67);
        }
    } else {
        setprop("/sim/model/j3cub/lighting/particles/redcombinedstart",   red_diffuse*.90);
        setprop("/sim/model/j3cub/lighting/particles/greencombinedstart", red_diffuse*.95);
        setprop("/sim/model/j3cub/lighting/particles/bluecombinedstart",  red_diffuse*.93);
        setprop("/sim/model/j3cub/lighting/particles/redcombinedend",     red_diffuse*.92);
        setprop("/sim/model/j3cub/lighting/particles/greencombinedend",   red_diffuse*.98);
        setprop("/sim/model/j3cub/lighting/particles/bluecombinedend",    red_diffuse*.95);
    }

    #smoke and damage smoke
    setprop("/sim/model/j3cub/lighting/particles/redsmokestart",   red_diffuse*.10);
    setprop("/sim/model/j3cub/lighting/particles/greensmokestart", red_diffuse*.10);
    setprop("/sim/model/j3cub/lighting/particles/bluesmokestart",  red_diffuse*.10);
    setprop("/sim/model/j3cub/lighting/particles/redsmokeend",     red_diffuse*.7);
    setprop("/sim/model/j3cub/lighting/particles/greensmokeend",   red_diffuse*.7);
    setprop("/sim/model/j3cub/lighting/particles/bluesmokeend",    red_diffuse*.85);
}

