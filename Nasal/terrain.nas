##########################################
# Ground Detection
##########################################

#setprop("sim/fdm/surface/override-level", 1);

var terrain_loop = func {
  var lat = getprop("/position/latitude-deg");
  var lon = getprop("/position/longitude-deg");

  var info = geodinfo(lat, lon);
  if (info != nil) {
    if (info[1] != nil){
      if (info[1].solid !=nil)
        setprop("/environment/terrain-type",info[1].solid);
      if (info[1].load_resistance !=nil)
        setprop("/environment/terrain-load-resistance",info[1].load_resistance);
      if (info[1].friction_factor !=nil)
        setprop("/environment/terrain-friction-factor",info[1].friction_factor);
      if (info[1].bumpiness !=nil)
        setprop("/environment/terrain-bumpiness",info[1].bumpiness);
      if (info[1].rolling_friction !=nil)
        setprop("/environment/terrain-rolling-friction",info[1].rolling_friction);
      if (info[1].names !=nil)
        setprop("/environment/terrain-names",info[1].names[0]);
    }  
    var tt = getprop("/environment/terrain-type");
	var lr = getprop("/environment/terrain-load-resistance");
	var ff = getprop("/environment/terrain-friction-factor");
    var tb = getprop("/environment/terrain-bumpiness");
	var rf = getprop("/environment/terrain-rolling-friction");
	var tn = getprop("/environment/terrain-names");
	var elv = getprop("/position/ground-elev-ft");
	var alt = getprop("/position/altitude-ft");
	var lat=getprop("/position/latitude-deg");
	var lon=getprop("/position/longitude-deg");
    var result=geodinfo(lat,lon);
	var elevation_m = result[0];
  	#var hdg = getprop("/orientation/heading-magnetic-deg");
	#var hdg_true = getprop("/orientation/heading-deg");
	#var agl = getprop("/position/altitude-agl-ft");

	#var loc=getprop("/instrumentation/clock/local-hour");
	#var gmt=getprop("/sim/time/gmt-string");
	#var sar=getprop("/sim/time/sun-angle-rad");
	#gui.popupTip(loc~" "~gmt~" "~sar,5);
    #/instrumentation/clock/local-short-string
    #/sim/time/gmt-string
  }
  

  
  #if (groundtype == whatever){
  #  setprop("/environment/terrain",1);
  #  setprop("/environment/terrain-load-resistance",1e+30);
  #  setprop("/environment/terrain-friction-factor",1.05);
  #  setprop("/environment/terrain-bumpiness",0);
  #  setprop("/environment/terrain-rolling-friction",0.02);
  #}

  #if(!getprop("sim/freeze/replay-state") and !getprop("/environment/terrain-type") and getprop("/position/altitude-agl-ft") < 3.0){
  #  setprop("sim/messages/copilot", "You are on water !");
  #  setprop("sim/freeze/clock", 1);
  #  setprop("sim/freeze/master", 1);
  #  setprop("sim/crashed", 1);
  #}

}
var terrain_timer = maketimer(0.25, func{terrain_loop()});

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
terrain_timer.start();
#enableOSD();
