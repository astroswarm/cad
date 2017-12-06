//import("/Users/robby/Downloads/Raspberry-Pi-3-Fan-Mount-With-Offsets.stl");

$fn = 30;

bracket_depth = 1;

board_width = 56.0;
board_clearance = 14.0;
board_depth = 1.25;

board_hole_spacing = 49.0;
board_hole_diameter = 2.5;

board_leg_overlap = 6.0;
board_leg_latch_depth = 1.0;
board_leg_latch_overlap = 0.75;

fan_hole_spacing = 24.0;
fan_hole_diameter_top = 3.1;
fan_hole_diameter_bottom = 4.5;
fan_depth = 7;
fan_leg_latch_depth = 1.0;
fan_leg_latch_overlap = 0.75;

fan_mount_angle = 25;
fan_mount_y_offset = 8.6;
fan_mount_z_offset = 8.2;

module generic_leg_latch(hole_diameter, hole_length, vertical_overlap, horizontal_overlap) {
    // Leg
    color("cyan")
    translate([0, 0, vertical_overlap + hole_diameter / 2])
        difference() {
            cylinder(h = hole_length, d = hole_diameter);
            
            translate([-horizontal_overlap / 2, -hole_diameter / 2, 0])
                cube([horizontal_overlap, hole_diameter, hole_length]);
        }
    
    // Latch
    translate([0, 0, hole_diameter / 2])
        difference() {
            union() {
                color("yellow")
                cylinder(h = vertical_overlap, d = hole_diameter);
                translate([horizontal_overlap / 3, 0, 0])
                    color("red")
                    sphere(d = hole_diameter);
                translate([-horizontal_overlap / 3, 0, 0])
                    color("red")
                    sphere(d = hole_diameter);
            }
            
            translate([-horizontal_overlap / 2, -hole_diameter / 2, -hole_diameter / 2])
                cube([horizontal_overlap, hole_diameter, 2 * vertical_overlap + hole_diameter / 2]);
        }
    
    // Connector
    translate([0, 0, hole_length + hole_diameter / 2 + vertical_overlap])
        color("green")
            sphere(d = hole_diameter);
}

module bracket() {
    translate([(board_width - board_hole_spacing) / 2, 0, board_clearance + board_depth + board_leg_latch_depth + board_hole_diameter / 2])
        cube([board_hole_spacing, board_leg_overlap, bracket_depth]);
}
    
module board_leg() {
    cylinder(h = board_clearance + bracket_depth, d = board_leg_overlap);
}

module board_legs() {
    translate([(board_width - board_hole_spacing) / 2, board_leg_overlap / 2, board_depth + board_leg_latch_depth + board_hole_diameter / 2])
        board_leg();

    translate([board_width - (board_width - board_hole_spacing) / 2, board_leg_overlap / 2, board_depth + board_leg_latch_depth + board_hole_diameter / 2])
        board_leg();
}

module board_latch() {
    generic_leg_latch(
        hole_diameter = board_hole_diameter,
        hole_length = board_depth,
        vertical_overlap = board_leg_latch_depth,
        horizontal_overlap = board_leg_latch_overlap
    );
}

module fan_latch() {
    generic_leg_latch(
        hole_diameter = fan_hole_diameter_top,
        hole_length = fan_depth,
        vertical_overlap = fan_leg_latch_depth,
        horizontal_overlap = fan_leg_latch_overlap
    );
}

module board_latches() {
    translate([(board_width - board_hole_spacing) / 2, board_leg_overlap / 2, 0])
        board_latch();

    translate([board_width - (board_width - board_hole_spacing) / 2, board_leg_overlap / 2, 0])
        board_latch();
}

module fan_latches() {
     translate([0, fan_mount_y_offset, fan_mount_z_offset]) {
        rotate([fan_mount_angle, 0, 0]) {
            union() {
                translate([(board_width - fan_hole_spacing) / 2, 0, 0])
                    fan_latch();
                translate([board_width - (board_width - fan_hole_spacing) / 2, 0, 0])
                    fan_latch();
            }
        }

    }
    
}

module build() {
    union() {
        bracket();
        board_legs();
        board_latches();
        fan_latches();
    }
}

module build_for_printing() {        
    translate([0, 0, board_clearance + board_leg_latch_depth + board_hole_diameter + bracket_depth])
        rotate([180, 0, 0])
            build();
}

build_for_printing();