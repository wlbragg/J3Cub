# IT AUTOFLIGHT:GA System Controller
# Joshua Davidson (it0uchpods)
# V1.0.2 Stable
# This program is 100% GPL!

setprop("/it-autoflight/internal/vert-speed-fpm", 0);

setlistener("/sim/signals/fdm-initialized", func {
	var locdefl = getprop("/instrumentation/nav[0]/heading-needle-deflection-norm");
	var locdefl_b = getprop("/instrumentation/nav[1]/heading-needle-deflection-norm");
	var signal = getprop("/instrumentation/nav[0]/gs-needle-deflection-norm");
	var signal_b = getprop("/instrumentation/nav[1]/gs-needle-deflection-norm");
	var bank_limit_sw = 0;
});

var ap_init = func {
	setprop("/it-autoflight/input/ap", 0);
	setprop("/it-autoflight/input/hdg", 360);
	setprop("/it-autoflight/input/alt", 1000);
	setprop("/it-autoflight/input/vs", 0);
	setprop("/it-autoflight/input/lat", 5);
	setprop("/it-autoflight/input/vert", 5);
	setprop("/it-autoflight/input/trk", 0);
	setprop("/it-autoflight/input/alt-arm", 0);
	setprop("/it-autoflight/output/ap", 0);
	setprop("/it-autoflight/output/lat-active", 0);
	setprop("/it-autoflight/output/vert-active", 0);
	setprop("/it-autoflight/output/nav-armed", 0);
	setprop("/it-autoflight/output/loc-armed", 0);
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/alt-arm", 0);
	setprop("/it-autoflight/output/lat", 5);
	setprop("/it-autoflight/output/vert", 5);
	setprop("/it-autoflight/settings/use-nav2-radio", 0);
	setprop("/it-autoflight/settings/slave-gps-nav", 0);
	setprop("/it-autoflight/internal/min-vs", -200);
	setprop("/it-autoflight/internal/max-vs", 200);
	setprop("/it-autoflight/internal/alt", 1000);
	setprop("/it-autoflight/mode/status", "STANDBY");
	setprop("/it-autoflight/mode/arm", " ");
	setprop("/it-autoflight/mode/lat", " ");
	setprop("/it-autoflight/mode/vert", " ");
	ap_varioust.start();
}

# AP Master System
setlistener("/it-autoflight/input/ap", func {
	var apmas = getprop("/it-autoflight/input/ap");
	if (apmas == 0) {
		setprop("/it-autoflight/output/ap", 0);
		setprop("/controls/flight/aileron", 0);
		setprop("/controls/flight/elevator", 0);
		setprop("/controls/flight/rudder", 0);
		setprop("/it-autoflight/output/lat-active", 0);
		setprop("/it-autoflight/output/vert-active", 0);
		setprop("/it-autoflight/input/lat", 5);
		setprop("/it-autoflight/input/vert", 5);
		setprop("/it-autoflight/output/lat", 5);
		setprop("/it-autoflight/output/vert", 5);
		altcaptt.stop();
		minmaxtimer.stop();
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/appr-armed", 0);
		setprop("/it-autoflight/mode/status", "STANDBY");
		setprop("/it-autoflight/mode/arm", " ");
		setprop("/it-autoflight/mode/lat", " ");
		setprop("/it-autoflight/mode/vert", " ");
		if (getprop("/it-autoflight/sound/enableapoffsound") == 1) {
			setprop("/it-autoflight/sound/apoffsound", 1);
			setprop("/it-autoflight/sound/enableapoffsound", 0);	  
		}
	} else if (apmas == 1) {
		setprop("/controls/flight/rudder", 0);
		setprop("/it-autoflight/input/cws", 0);
		setprop("/it-autoflight/output/ap", 1);
		setprop("/it-autoflight/sound/enableapoffsound", 1);
		setprop("/it-autoflight/sound/apoffsound", 0);
		if (getprop("/it-autoflight/settings/enable-stby") == 0) {
			setprop("/it-autoflight/input/lat", 1);
			setprop("/it-autoflight/input/vert", 1);
		}
	}
});

# Master Lateral
setlistener("/it-autoflight/input/lat", func {
	if (getprop("/it-autoflight/output/ap") == 1) {
		lateral();
		setprop("/it-autoflight/output/lat-active", 1);
		setprop("/it-autoflight/mode/status", " ACTIVE");
	}
});

var lateral = func {
	var latset = getprop("/it-autoflight/input/lat");
	if (latset == 0) {
		setprop("/it-autoflight/output/nav-armed", 0);
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/appr-armed", 0);
		setprop("/it-autoflight/output/lat", 0);
		setprop("/it-autoflight/mode/lat", "HDG");
		setprop("/it-autoflight/mode/arm", " ");
	} else if (latset == 1) {
		setprop("/it-autoflight/output/nav-armed", 0);
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/appr-armed", 0);
		setprop("/it-autoflight/output/lat", 1);
		setprop("/it-autoflight/mode/lat", "LVL");
		setprop("/it-autoflight/mode/arm", " ");
	} else if (latset == 2) {
		if (getprop("/autopilot/settings/gps-driving-true-heading") == 0) {
			setprop("/it-autoflight/settings/slave-gps-nav", 0);
		}
		if (getprop("/it-autoflight/output/lat") == 2) {
			# Do nothing because VOR/LOC is active
		} else {
			setprop("/instrumentation/nav[0]/signal-quality-norm", 0);
			setprop("/instrumentation/nav[1]/signal-quality-norm", 0);
			setprop("/it-autoflight/output/nav-armed", 1);
			setprop("/it-autoflight/mode/arm", "V/L");
		}
	} else if (latset == 3) {
		setprop("/it-autoflight/output/nav-armed", 0);
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/appr-armed", 0);
		var hdgnow = int(getprop("/orientation/heading-magnetic-deg")+0.5);
		setprop("/it-autoflight/input/hdg", hdgnow);
		setprop("/it-autoflight/output/lat", 0);
		setprop("/it-autoflight/mode/lat", "HDG");
		setprop("/it-autoflight/mode/arm", " ");
	}
}

# Master Vertical
setlistener("/it-autoflight/input/vert", func {
	if (getprop("/it-autoflight/output/ap") == 1) {
		var altinput = getprop("/it-autoflight/input/alt");
		setprop("/it-autoflight/internal/alt", altinput);
		vertical();
		setprop("/it-autoflight/output/vert-active", 1);
		setprop("/it-autoflight/mode/status", " ACTIVE");
	}
});

var vertical = func {
	var vertset = getprop("/it-autoflight/input/vert");
	if (vertset == 0) {
		setprop("/it-autoflight/output/appr-armed", 0);
		setprop("/it-autoflight/output/vert", 0);
		setprop("/it-autoflight/mode/vert", "ALT HLD");
		if (getprop("/it-autoflight/output/nav-armed")) {
			setprop("/it-autoflight/mode/arm", "V/L");
		} else {
			setprop("/it-autoflight/mode/arm", " ");
		}
		var altnow = int((getprop("/instrumentation/altimeter/indicated-altitude-ft")+50)/100)*100;
		setprop("/it-autoflight/input/alt", altnow);
		setprop("/it-autoflight/internal/alt", altnow);
	} else if (vertset == 1) {
		var altinput = getprop("/it-autoflight/input/alt");
		setprop("/it-autoflight/internal/alt", altinput);
		var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		var alt = getprop("/it-autoflight/internal/alt");
		var dif = calt - alt;
		if (dif < 50 and dif > -50 and getprop("/it-autoflight/settings/auto-arm-alt") == 1) {
			alt_on();
		} else {
			setprop("/it-autoflight/output/appr-armed", 0);
			var altinput = getprop("/it-autoflight/input/alt");
			setprop("/it-autoflight/internal/alt", altinput);
			var vsnow = int(getprop("/velocities/vertical-speed-fps")*0.6)*100;
			setprop("/it-autoflight/input/vs", vsnow);
			setprop("/it-autoflight/output/vert", 1);
			setprop("/it-autoflight/mode/vert", "V/S");
			if (getprop("/it-autoflight/output/nav-armed")) {
				setprop("/it-autoflight/mode/arm", "V/L");
			} else {
				setprop("/it-autoflight/mode/arm", " ");
			}
		}
	} else if (vertset == 2) {
		if (getprop("/it-autoflight/output/lat") == 2) {
			# Do nothing because VOR/LOC is active
		} else {
			setprop("/it-autoflight/output/nav-armed", 0);
			setprop("/instrumentation/nav[0]/signal-quality-norm", 0);
			setprop("/instrumentation/nav[1]/signal-quality-norm", 0);
			setprop("/it-autoflight/output/loc-armed", 1);
		}
		if (getprop("/it-autoflight/output/vert") == 2 or getprop("/it-autoflight/output/appr-armed") == 1) {
			# Do nothing because G/S is active
		} else {
			setprop("/instrumentation/nav[0]/gs-rate-of-climb", 0);
			setprop("/instrumentation/nav[1]/gs-rate-of-climb", 0);
			setprop("/it-autoflight/output/appr-armed", 1);
			setprop("/it-autoflight/mode/arm", "ILS");
			setprop("/it-autoflight/autoland/target-vs", "-650");
		}
	} else if (vertset == 3) {
		var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		var alt = getprop("/it-autoflight/internal/alt");
		var dif = calt - alt;
		var vsnow = getprop("/it-autoflight/internal/vert-speed-fpm");
		if (calt < alt) {
			setprop("/it-autoflight/internal/max-vs", vsnow);
		} else if (calt > alt) {
			setprop("/it-autoflight/internal/min-vs", vsnow);
		}
		minmaxtimer.start();
		setprop("/it-autoflight/output/vert", 0);
		setprop("/it-autoflight/mode/vert", "ALT CAP");
	}
}

# Helpers
var ap_various = func {
	if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1) {
		if (getprop("/autopilot/route-manager/wp/dist") <= 1.0) {
			if ((getprop("/autopilot/route-manager/current-wp") + 1) < getprop("/autopilot/route-manager/route/num")) {
				setprop("/autopilot/route-manager/current-wp", getprop("/autopilot/route-manager/current-wp") + 1);
			}
		}
	}
}

var alt_on = func {
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/vert", 0);
	setprop("/it-autoflight/mode/vert", "ALT CAP");
	setprop("/it-autoflight/internal/max-vs", 200);
	setprop("/it-autoflight/internal/min-vs", -200);
	minmaxtimer.start();
}

# Manually ARM altitude
setlistener("/it-autoflight/input/alt-arm", func {
	if (getprop("/it-autoflight/input/alt-arm") == 1) {
		if (getprop("/it-autoflight/output/vert") == 1) {
			setprop("/it-autoflight/output/alt-arm", 1);
			altcaptt.start();
		}
	} else {
		setprop("/it-autoflight/output/alt-arm", 0);
		altcaptt.stop();
	}
});

# Change to V/S if ALT changed
setlistener("/it-autoflight/input/alt", func {
	if (getprop("/it-autoflight/output/ap") == 1 and getprop("/it-autoflight/output/vert") == 0) {
		setprop("/it-autoflight/input/vert", 1);
	}
});

# Altitude Capture
setlistener("/it-autoflight/output/vert", func {
	var vertm = getprop("/it-autoflight/output/vert");
	if (vertm == 1) {
		if (getprop("/it-autoflight/settings/auto-arm-alt") == 1) {
			setprop("/it-autoflight/output/alt-arm", 1);
			altcaptt.start();
		} else {
			setprop("/it-autoflight/output/alt-arm", 0);
			altcaptt.stop();
		}
	} else {
		setprop("/it-autoflight/output/alt-arm", 0);
		altcaptt.stop();
	}
});

var altcapt = func {
	var vsnow = getprop("/it-autoflight/internal/vert-speed-fpm");
	if ((vsnow >= 0 and vsnow < 500) or (vsnow < 0 and vsnow > -500)) {
		setprop("/it-autoflight/internal/captvs", 100);
		setprop("/it-autoflight/internal/captvsneg", -100);
	} else  if ((vsnow >= 500 and vsnow < 1000) or (vsnow < -500 and vsnow > -1000)) {
		setprop("/it-autoflight/internal/captvs", 200);
		setprop("/it-autoflight/internal/captvsneg", -200);
	} else  if ((vsnow >= 1000 and vsnow < 1500) or (vsnow < -1000 and vsnow > -1500)) {
		setprop("/it-autoflight/internal/captvs", 300);
		setprop("/it-autoflight/internal/captvsneg", -300);
	} else  if ((vsnow >= 1500 and vsnow < 2000) or (vsnow < -1500 and vsnow > -2000)) {
		setprop("/it-autoflight/internal/captvs", 400);
		setprop("/it-autoflight/internal/captvsneg", -400);
	} else  if ((vsnow >= 2000 and vsnow < 3000) or (vsnow < -2000 and vsnow > -3000)) {
		setprop("/it-autoflight/internal/captvs", 600);
		setprop("/it-autoflight/internal/captvsneg", -600);
	} else  if ((vsnow >= 3000 and vsnow < 4000) or (vsnow < -3000 and vsnow > -4000)) {
		setprop("/it-autoflight/internal/captvs", 900);
		setprop("/it-autoflight/internal/captvsneg", -900);
	} else  if ((vsnow >= 4000 and vsnow < 5000) or (vsnow < -4000 and vsnow > -5000)) {
		setprop("/it-autoflight/internal/captvs", 1200);
		setprop("/it-autoflight/internal/captvsneg", -1200);
	} else  if ((vsnow >= 5000) or (vsnow < -5000)) {
		setprop("/it-autoflight/internal/captvs", 1500);
		setprop("/it-autoflight/internal/captvsneg", -1500);
	}
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var alt = getprop("/it-autoflight/internal/alt");
	var dif = calt - alt;
	if (dif < getprop("/it-autoflight/internal/captvs") and dif > getprop("/it-autoflight/internal/captvsneg")) {
		if (vsnow > 0 and dif < 0) {
			setprop("/it-autoflight/input/vert", 3);
		} else if (vsnow < 0 and dif > 0) {
			setprop("/it-autoflight/input/vert", 3);
		}
	}
	var altinput = getprop("/it-autoflight/input/alt");
	setprop("/it-autoflight/internal/alt", altinput);
}

# Min and Max Pitch Reset
var minmax = func {
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var alt = getprop("/it-autoflight/internal/alt");
	var dif = calt - alt;
	if (dif < 50 and dif > -50) {
		setprop("/it-autoflight/internal/max-vs", 200);
		setprop("/it-autoflight/internal/min-vs", -200);
		var vertmode = getprop("/it-autoflight/output/vert");
		if (vertmode == 1 or vertmode == 2 or vertmode == 4 or vertmode == 5 or vertmode == 6 or vertmode == 7) {
			# Do not change the vertical mode because we are not trying to capture altitude.
		} else {
			setprop("/it-autoflight/mode/vert", "ALT HLD");
		}
		minmaxtimer.stop();
	}
}

# ILS
# LOC and G/S arming
setlistener("/it-autoflight/output/nav-armed", func {
	check_arms();
});

setlistener("/it-autoflight/output/loc-armed", func {
	check_arms();
});

setlistener("/it-autoflight/output/appr-armed", func {
	check_arms();
});

var check_arms = func {
	if (getprop("/it-autoflight/output/nav-armed") or getprop("/it-autoflight/output/loc-armed") or getprop("/it-autoflight/output/appr-armed")) {
		update_armst.start();
	} else {
		update_armst.stop();
	}
}

var update_arms = func {
	if (getprop("/it-autoflight/output/nav-armed")) {
		if (getprop("/it-autoflight/settings/slave-gps-nav") == 0) {
			if ((getprop("/instrumentation/nav[0]/signal-quality-norm") > 0.99) and (getprop("/it-autoflight/settings/use-nav2-radio") == 0)) {
				make_loc_active();
			} else if ((getprop("/instrumentation/nav[1]/signal-quality-norm") > 0.99) and (getprop("/it-autoflight/settings/use-nav2-radio") == 1)) {
				make_loc_active();
			} else {
				return 0;
			}
		} else {
			if (getprop("/autopilot/route-manager/active") == 1) {
				make_loc_active();
			}
		}
	}
	if (getprop("/it-autoflight/output/loc-armed")) {
		locdefl = getprop("/instrumentation/nav[0]/heading-needle-deflection-norm");
		locdefl_b = getprop("/instrumentation/nav[1]/heading-needle-deflection-norm");
		if ((locdefl < 0.9233) and (getprop("/instrumentation/nav[0]/signal-quality-norm") > 0.99) and (getprop("/it-autoflight/settings/use-nav2-radio") == 0)) {
			make_loc_active();
		} else if ((locdefl_b < 0.9233) and (getprop("/instrumentation/nav[1]/signal-quality-norm") > 0.99) and (getprop("/it-autoflight/settings/use-nav2-radio") == 1)) {
			make_loc_active();
		} else {
			return 0;
		}
	}
	if (getprop("/it-autoflight/output/appr-armed")) {
		signal = getprop("/instrumentation/nav[0]/gs-needle-deflection-norm");
		signal_b = getprop("/instrumentation/nav[1]/gs-needle-deflection-norm");
		if (((signal < 0 and signal >= -0.30) or (signal > 0 and signal <= 0.30)) and (getprop("/it-autoflight/settings/use-nav2-radio") == 0) and (getprop("/it-autoflight/output/lat") == 2)) {
			make_appr_active();
		} else if (((signal_b < 0 and signal_b >= -0.30) or (signal_b > 0 and signal_b <= 0.30)) and (getprop("/it-autoflight/settings/use-nav2-radio") == 1) and (getprop("/it-autoflight/output/lat") == 2)) {
			make_appr_active();
		} else {
			return 0;
		}
	}
}

var make_loc_active = func {
	setprop("/it-autoflight/output/nav-armed", 0);
	setprop("/it-autoflight/output/loc-armed", 0);
	setprop("/it-autoflight/output/lat", 2);
	setprop("/it-autoflight/mode/lat", "LOC");
	if (getprop("/it-autoflight/output/appr-armed") == 1) {
		# Do nothing because G/S is armed
	} else {
		setprop("/it-autoflight/mode/arm", " ");
	}
}

var make_appr_active = func {
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/vert", 2);
	setprop("/it-autoflight/mode/vert", "G/S");
	setprop("/it-autoflight/mode/arm", " ");
}

# For Canvas Nav Display.
setlistener("/it-autoflight/input/hdg", func {
	setprop("/autopilot/settings/heading-bug-deg", getprop("/it-autoflight/input/hdg"));
});

setlistener("/it-autoflight/internal/alt", func {
	setprop("/autopilot/settings/target-altitude-ft", getprop("/it-autoflight/internal/alt"));
});

# Timers
var update_armst = maketimer(0.5, update_arms);
var altcaptt = maketimer(0.5, altcapt);
var minmaxtimer = maketimer(0.5, minmax);
var ap_varioust = maketimer(1, ap_various);
