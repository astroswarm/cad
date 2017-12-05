//import("/Users/robby/Downloads/Raspberry-Pi-3-Fan-Mount-With-Offsets.stl");

$fn = 30;

board_width = 56.0;
board_clearance = 6.0;
board_depth = 1.25;

hole_spacing = 48.0;
hole_diameter = 2.5;

leg_overlap = 6.0;
leg_latch_depth = 1.0;
leg_latch_overlap = 0.75;

module bracket() {
    translate([0, 0, board_clearance + board_depth + leg_latch_depth])
        cube([board_width, leg_overlap, 1]);
}
    
module leg() {
    cylinder(h = board_clearance, d = leg_overlap);
}

module legs() {
    
    translate([(board_width - hole_spacing) / 2, leg_overlap / 2, board_depth + leg_latch_depth])
        leg();

    translate([board_width - (board_width - hole_spacing) / 2, leg_overlap / 2, board_depth + leg_latch_depth])
        leg();
}

module latch_endcap() {
    difference() {
        sphere(d = hole_diameter);
        
//        translate([-hole_diameter / 2, -hole_diameter / 2, -hole_diameter])
//            cube(hole_diameter, hole_diameter, hole_diameter);
    }
}

module latch() {
    difference() {
        union() {
            cylinder(h = board_depth + leg_latch_depth, d = hole_diameter);
            translate([leg_latch_overlap / 2, 0, 0])
                latch_endcap();
            translate([-leg_latch_overlap / 2, 0, 0])
                latch_endcap();
        }
        
        translate([-leg_latch_overlap / 2, -hole_diameter / 2, -hole_diameter / 2])
            cube([leg_latch_overlap, hole_diameter, leg_latch_depth + board_depth + hole_diameter / 2]);
    }
}

module latches() {
    translate([(board_width - hole_spacing) / 2, leg_overlap / 2, 0])
        latch();

    translate([board_width - (board_width - hole_spacing) / 2, leg_overlap / 2, 0])
        latch();
}

bracket();
legs();

latches();