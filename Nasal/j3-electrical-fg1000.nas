var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
io.load_nasal(nasal_dir ~ 'FG1000.nas', "fg1000");
var aircraft_dir = getprop("/sim/aircraft-dir");
io.load_nasal(aircraft_dir ~ '/Nasal/Interfaces/J3CubInterfaceController.nas', "fg1000");

var interfaceController = fg1000.J3CubInterfaceController.getOrCreateInstance();
#var interfaceController = fg1000.GenericInterfaceController.getOrCreateInstance();
interfaceController.start();

#io.load_nasal(aircraft_dir ~ '/Nasal/EIS/EIS-J3Cub.nas', "fg1000");
#io.load_nasal(aircraft_dir ~ '/Nasal/EIS/EISController.nas', "fg1000");
#io.load_nasal(aircraft_dir ~ '/Nasal/EIS/EISStyles.nas', "fg1000");
#io.load_nasal(aircraft_dir ~ '/Nasal/EIS/EISOptions.nas', "fg1000");
#var EIS_Class = fg1000.EISJ3Cub;

# Create the FG1000 using custom EIS
#var fg1000system = fg1000.FG1000.getOrCreateInstance(EIS_Class:EIS_Class, EIS_SVG: "Nasal/EIS/EIS-J3Cub.svg");
var fg1000system = fg1000.FG1000.getOrCreateInstance();

# Create a PFD as device 1, MFD as device 2
fg1000system.addPFD(1);
fg1000system.addMFD(2);

# Display the devices
fg1000system.display(1);
fg1000system.display(2);

#  Display a GUI version of device 1 at 50% scale.
var toggle_fg1000_PFD = func {
  fg1000system.displayGUI(1, 0.5);
};
var toggle_fg1000_MFD = func {
  fg1000system.displayGUI(2, 0.5);
};

var ElectricalSystemUpdater = {
    new : func {
        var m = {
            parents: [ElectricalSystemUpdater]
        };
        # Request that the update function be called each frame
        m.loop = updateloop.UpdateLoop.new(components: [m], update_period: 0.0, enable: 0);
        return m;
    },

    enable: func {
        me.loop.reset();
        me.loop.enable();
    },

    disable: func {
        me.loop.disable();
    },

    reset: func {
        # Do nothing
    },

    update: func (dt) {
        update_virtual_bus(dt);
    }
};

var update_virtual_bus = func (dt) {
 
    if (getprop("/engines/active-engine/rpm"))
    {
		fg1000system.show(1);
		fg1000system.show(2);
	} else {
		fg1000system.hide(1);
		fg1000system.hide(2);
	}
}

var system_updater = ElectricalSystemUpdater.new();
system_updater.enable();