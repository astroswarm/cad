$fn = 30;

bracket_depth = 1;

board_length = 85.0;
board_width = 56.0;
board_clearance = 2.0;
board_depth = 1.25;

board_hole_spacing = 49.0;
board_hole_diameter = 2.5;

board_leg_overlap = board_width - board_hole_spacing;
board_leg_latch_depth = 1.0;
board_leg_latch_overlap = 0.75;

sd_cutout_diameter = 30;
sd_cutout_clearance = 4.0;

bracket_z_offset = board_clearance + board_depth + board_leg_latch_depth + board_hole_diameter / 2;
    
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
    // Leg portion
    translate([(board_width - board_hole_spacing) / 2, 0, bracket_z_offset])
        cube([board_hole_spacing, board_leg_overlap, bracket_depth]);
    
    // Board portion
    translate([0, (board_width - board_hole_spacing) / 2, bracket_z_offset])
        cube([board_hole_spacing + board_leg_overlap, board_length - board_leg_overlap, bracket_depth]);
    
    // Back portion
    translate([(board_width - board_hole_spacing) / 2, board_length - board_leg_overlap, bracket_z_offset])
        cube([board_hole_spacing, board_leg_overlap, bracket_depth]);
    translate([board_leg_overlap / 2, board_length - board_leg_overlap / 2, bracket_z_offset])
        cylinder(h = bracket_depth, d = board_leg_overlap);
    translate([board_width - board_leg_overlap / 2, board_length - board_leg_overlap / 2, bracket_z_offset])
        cylinder(h = bracket_depth, d = board_leg_overlap);
}

module sd_cutout() {
    translate([board_width / 2, -sd_cutout_diameter / 2 + sd_cutout_clearance, bracket_z_offset])
        cylinder(h = bracket_depth, d = sd_cutout_diameter, $fn = 100);
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

module board_latches() {
    translate([(board_width - board_hole_spacing) / 2, board_leg_overlap / 2, 0])
        board_latch();

    translate([board_width - (board_width - board_hole_spacing) / 2, board_leg_overlap / 2, 0])
        board_latch();
}


module build() {
    union() {
        difference() {
            bracket();
            sd_cutout();
        }
        board_legs();
        board_latches();
    }
}

module build_for_printing() {        
    translate([0, 0, board_clearance + board_leg_latch_depth + board_hole_diameter + bracket_depth])
        rotate([180, 0, 0])
            build();
}

build_for_printing();