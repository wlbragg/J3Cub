io.include("Aircraft/J3Cub/Nasal/registration_number.nas");

var refresh_immat = func {
    var immat = props.globals.getNode("/sim/model/immat",1).getValue();
    set_registration_number(props.globals, immat);
};

var immat_dialog = gui.Dialog.new("/sim/gui/dialogs/J3Cub/status/dialog",
                  "Aircraft/J3Cub/Dialogs/immat.xml");

setlistener("sim/model/immat", refresh_immat, 1, 0);

setlistener("/sim/signals/fdm-initialized", func {
    if (props.globals.getNode("/sim/model/immat") == nil) {
        var immat = props.globals.getNode("/sim/model/immat", 1);
        var callsign = props.globals.getNode("/sim/multiplay/callsign").getValue();

        if (callsign != "callsign")
            immat.setValue(callsign);
        else
            immat.setValue("");
    }
});
