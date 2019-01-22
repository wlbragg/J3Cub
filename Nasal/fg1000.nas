var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
io.load_nasal(nasal_dir ~ 'FG1000.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericInterfaceController.nas', "fg1000");

var interfaceController = fg1000.GenericInterfaceController.getOrCreateInstance();
interfaceController.start();

# Create the FG1000
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

var fg1000 = getprop("sim/model/j3cub/fg1000");
if (fg1000) {
  fg1000system.show(1);
  fg1000system.show(2);
} else {
  fg1000system.hide(1);
  fg1000system.hide(2);
}

setlistener("sim/model/j3cub/fg1000", func(n) {
    if (n.getValue() > 0) {
      fg1000system.show(1);
      fg1000system.show(2);
    } else {
      fg1000system.hide(1);
      fg1000system.hide(2);
    }
}, 0, 0);

#setlistener("/systems/electrical/outputs/gps", func(n) {
#    if (n.getValue() > 0) {
#      fg1000system.show();
#    } else {
#      fg1000system.hide();
#    }
#}, 0, 0);