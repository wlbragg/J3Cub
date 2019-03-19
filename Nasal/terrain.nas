##########################################
# Ground Detection
##########################################

var terrain_loop = func {
  var lat = getprop("/position/latitude-deg");
  var lon = getprop("/position/longitude-deg");

  var info = geodinfo(lat, lon);
  if (info != nil) {
    if (info[1] != nil){
      if (info[1].solid !=nil)
        setprop("",info[1].solid);
      #if (info[1].load_resistance !=nil)
      #  setprop("/environment/terrain-load-resistance",info[1].load_resistance);
      if (info[1].friction_factor !=nil)
        setprop("/environment/terrain-friction-factor",info[1].friction_factor);
      #if (info[1].bumpiness !=nil)
      #  setprop("/environment/terrain-bumpiness",info[1].bumpiness);
      if (info[1].rolling_friction !=nil)
        setprop("/environment/terrain-rolling-friction",info[1].rolling_friction);
      #if (info[1].names !=nil)
      #  setprop("/environment/terrain-names",info[1].names[0]);
      if (info[1].names !=nil)
        setprop("/fdm/jsbsim/ground/terrain-names",info[1].names[0]);
    }
  }
}

var terrain_timer = maketimer(0.5, func{terrain_loop()});
terrain_timer.start();

###############################################################################
# On-screen displays
var enableOSD = func {
  var left  = screen.display.new(20, 10);
  var right = screen.display.new(-300, 10);
    
    
  left.add("/environment/precipitation-control/snow-flake-size");
  left.add("/environment/snow-level-m");
  left.add("/environment/snow-norm");
  left.add("/environment/surface/snow-thickness-factor");
  left.add("/environment/surface/ground-scattering");
  left.add("/environment/surface/scattering");
  left.add("/environment/terrain-type");
  left.add("/environment/terrain-load-resistance");
  left.add("/environment/terrain-friction-factor");
  left.add("/environment/terrain-bumpiness");
  left.add("/environment/terrain-rolling-friction");
  left.add("/environment/terrain-names");

  right.add("/environment/surface/delta-T-rock");
  right.add("/environment/surface/delta-T-soil");
  right.add("/environment/surface/delta-T-structure");
  right.add("/environment/surface/delta-T-vegetation");
  right.add("/environment/surface/delta-T-water");
  right.add("/environment/surface/wetness");
  right.add("/environment/surface/wetness-set");
  right.add("/position/ground-elev-ft");
  right.add("/position/altitude-ft");
  right.add("/position/latitude-deg");
  right.add("/position/longitude-deg");
}
#enableOSD();
