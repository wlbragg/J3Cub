# Copyright (C) 2015  onox
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Position and offset of the start point of a tiedown. The position is on
# the surface of the fuselage or wing.

io.include("Aircraft/Generic/updateloop.nas");

var point_coords = {
    left: {
        x:  0.2609,
        y: -3.4362,
        z:  0.0088,
        offset: 90.0
    },

    right: {
        x:  0.2713,
        y:  3.3659,
        z:  0.0089,
        offset: -90.0
    },

    tail: {
        x:  4.8094,
        y: -0.0025,
        z: -0.5440,
        offset: 0.0
    },
};

# Values must be the same as in Models/J3Cub.xml
var model_offsets_pitch_deg = 0.0;
var model_offsets_z_m = 0.0;

var TiedownPositionUpdater = {

    new: func (name) {
        var m = {
            parents: [TiedownPositionUpdater]
        };
        m.loop = UpdateLoop.new(components: [m], update_period: 0.0, enable: 0);
        m.name = name;
        return m;
    },

    enable: func {
        me.loop.reset();
        me.loop.enable();
    },

    disable: func {
        me.loop.disable();
    },

    enable_or_disable: func (enable) {
        if (enable)
            me.enable();
        else
            me.disable();
    },

    reset: func {
        me.end_point = geo.aircraft_position();
        var heading = getprop("/orientation/heading-deg");

        var x = getprop("/sim/model/j3cub/tiedowns", me.name, "x");
        var y = getprop("/sim/model/j3cub/tiedowns", me.name, "y");

        # Set position of end point
        var course = heading + geo.normdeg(math_ext.atan(y, x));
        var distance = math.sqrt(math.pow(x, 2) + math.pow(y, 2));
        me.end_point.apply_course_distance(course, distance);

        # Set altitude of end point
        var elev_m = geo.elevation(me.end_point.lat(), me.end_point.lon());
        me.end_point.set_alt(elev_m or getprop("/position/ground-elev-m"));

        me.init_ref_length();
    },

    init_ref_length: func {
        # Call update() to compute initial length
        me.update(0);
        var length = getprop("/sim/model/j3cub/tiedowns", me.name, "length");
        setprop("/sim/model/j3cub/tiedowns", me.name, "ref-length", length);
    },

    update: func (dt) {
        var point = point_coords[me.name];

        var start_x = point.x;
        var start_y = point.y;
        var start_z = point.z + model_offsets_z_m;

        var roll_deg  = getprop("/orientation/roll-deg");
        var pitch_deg = getprop("/orientation/pitch-deg") + model_offsets_pitch_deg;
        var heading   = getprop("/orientation/heading-deg");

        # Compute the actual position of the start of the tiedown
        var (start_point_2d, start_point) = math_ext.get_point(start_x, start_y, start_z, roll_deg, pitch_deg, heading);

        var (yaw, pitch, distance) = math_ext.get_yaw_pitch_distance_inert(start_point_2d, start_point, me.end_point, heading);
        (yaw, pitch) = math_ext.get_yaw_pitch_body(roll_deg, pitch_deg, yaw, pitch, point.offset);

        setprop("/sim/model/j3cub/tiedowns", me.name, "heading-deg", yaw);
        setprop("/sim/model/j3cub/tiedowns", me.name, "pitch-deg", pitch);
        setprop("/sim/model/j3cub/tiedowns", me.name, "length", distance);
    },

};

var tiedown_left_updater  = TiedownPositionUpdater.new("left");
var tiedown_right_updater = TiedownPositionUpdater.new("right");
var tiedown_tail_updater  = TiedownPositionUpdater.new("tail");

setlistener("/sim/signals/fdm-initialized", func {
    setlistener("/sim/model/j3cub/securing/tiedownL-visible", func (node) {
        tiedown_left_updater.enable_or_disable(node.getValue());
    }, 1, 0);

    setlistener("/sim/model/j3cub/securing/tiedownR-visible", func (node) {
        tiedown_right_updater.enable_or_disable(node.getValue());
    }, 1, 0);

    setlistener("/sim/model/j3cub/securing/tiedownT-visible", func (node) {
        tiedown_tail_updater.enable_or_disable(node.getValue());
    }, 1, 0);

    setlistener("/fdm/jsbsim/damage/repairing", func (node) {
        # When the aircraft has been repaired (value is switched back
        # to 0), compute the new initial length of the tiedowns
        if (!node.getValue()) {
            tiedown_left_updater.init_ref_length();
            tiedown_right_updater.init_ref_length();
            tiedown_tail_updater.init_ref_length();
        }
    }, 0, 0);
});
