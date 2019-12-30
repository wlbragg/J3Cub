var start = func (msg=1) {
    #if (getprop("/engines/active-engine/running")) {
      #if (msg)
        #gui.popupTip("Engine already running", 5);
        #return;
    #}
    j3cub.autostart();
};