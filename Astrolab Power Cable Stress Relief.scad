$fn = 100;

plug_hole_scale_factor = 0.95; // How much smaller than the opening should our part be?

plug_width = 12 * plug_hole_scale_factor;
plug_height = 9 * plug_hole_scale_factor;
plug_ratio = plug_width / plug_height;

plug_cord_diameter = 3;
plug_cord_capture_distance = 8;

exterior_bracing_overlap = 1.5;
exterior_bracing_z_thickness = 0.5;

interior_bracing_overlap = 0.5;
interior_bracing_z_thickness = 0.5;

astrolab_thickness = 2;
protrusion_beyond_astrolab = 0.5;
wall_thickness = 1.5;

total_height = exterior_bracing_z_thickness + astrolab_thickness + protrusion_beyond_astrolab + interior_bracing_z_thickness;


module exterior_bracing() {
    scale([1, plug_ratio, 1])
        cylinder(h = exterior_bracing_z_thickness, d = plug_width + exterior_bracing_overlap);
}

module wall() {
    scale([1, plug_ratio, 1])
        cylinder(h = total_height, d = plug_width);
}

module interior_bracing() {
    z_offset = exterior_bracing_z_thickness + astrolab_thickness + protrusion_beyond_astrolab;
    translate([0, 0, z_offset])
        scale([1, plug_ratio, 1])
            cylinder(h = interior_bracing_z_thickness, d = plug_width + interior_bracing_overlap);
}

module cable_latch() {
    translate([0, plug_width / 2 * plug_ratio - plug_cord_diameter / 2, 0])
        cylinder(h = total_height, d = plug_cord_diameter);

    translate([-plug_cord_diameter / 2, plug_width / 2 * plug_ratio - plug_cord_diameter / 2, 0])
        cube([plug_cord_diameter, max(interior_bracing_overlap, exterior_bracing_overlap) * 2, total_height]);
}

module build_back_bracket() {
    difference() {
        union() {
            exterior_bracing();
            wall();
            interior_bracing();
        }
        
        cable_latch();
    }
}

build_back_bracket();
