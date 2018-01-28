$fn = 100;

plug_hole_scale_factor = 0.95; // How much smaller than the opening should our part be?

plug_width = 10 * plug_hole_scale_factor;
plug_height = 7 * plug_hole_scale_factor;
plug_ratio = plug_width / plug_height;

plug_cord_diameter = 3;
plug_cord_capture_distance = 8;

bracing_overlap = 1.5;
bracing_z_thickness = 0.5;

astrolab_thickness = 2;
protrusion_beyond_astrolab = 0.25;
wall_thickness = 1.5;

locking_clip_z_thickness = 1;
locking_clip_xy_groove = 0.5;
locking_clip_z_groove = 0.5;

module back_bracing() {
    difference() {
        scale([1, plug_ratio, 1])
            cylinder(h = bracing_z_thickness, d = plug_width + bracing_overlap);
        
        scale([1, plug_ratio, 1])
            cylinder(h = bracing_z_thickness, d = plug_width);
    }
}

module wall() {
    height = bracing_z_thickness + astrolab_thickness + protrusion_beyond_astrolab;
    difference() {
        scale([1, plug_ratio, 1])
            cylinder(h = height, d = plug_width);
        
        scale([1, plug_ratio, 1])
            cylinder(h = height, d = plug_width - wall_thickness);
    }
}

module locking_groove() {
    z_offset = bracing_z_thickness + astrolab_thickness + protrusion_beyond_astrolab;
    translate([0, 0, z_offset])
        difference() {
            scale([1, plug_ratio, 1])
                cylinder(h = locking_clip_z_thickness, d = plug_width);
            
            scale([1, plug_ratio, 1])
                cylinder(h = locking_clip_z_thickness, d = plug_width - wall_thickness);
            
            difference() {
                scale([1, plug_ratio, 1])
                    cylinder(h = locking_clip_z_groove, d = plug_width);
                scale([1, plug_ratio, 1])
                    cylinder(h = locking_clip_z_groove, d = plug_width - locking_clip_xy_groove);
            }
        }
}

module build_back_bracket() {
    back_bracing();
    wall();
    locking_groove();
}

translate([plug_width * 1.25, 0, 0])
    build_back_bracket();

module front_bracing() {
    difference() {
        scale([1, plug_ratio, 1])
            cylinder(h = locking_clip_z_thickness, d = plug_width + bracing_overlap);
        
        scale([1, plug_ratio, 1])
            cylinder(h = locking_clip_z_thickness, d = plug_width);
    }
    
    // Internal cylinder
    difference() {
        scale([1, plug_ratio, 1])
            cylinder(h = 2 * locking_clip_z_thickness + plug_cord_capture_distance, d = plug_cord_diameter + bracing_overlap);
        scale([1, 1, 1])
            cylinder(h = 2 * locking_clip_z_thickness + plug_cord_capture_distance, d = plug_cord_diameter);
    }
    
    translate([0, 0, locking_clip_z_thickness])
        difference() {
            scale([1, plug_ratio, 1])
                cylinder(h = plug_cord_capture_distance, d1 = plug_width + bracing_overlap, d2 = plug_cord_diameter + bracing_overlap);
            scale([1, plug_ratio, 1])
                cylinder(h = plug_cord_capture_distance, d1 = plug_width, d2 = plug_cord_diameter);
        }
    
    translate([0, 0, locking_clip_z_thickness + plug_cord_capture_distance])
        difference() {
            scale([1, plug_ratio, 1])
                cylinder(h = locking_clip_z_thickness, d = plug_cord_diameter + bracing_overlap);
        
            scale([1, plug_ratio, 1])
                cylinder(h = locking_clip_z_thickness, d = plug_cord_diameter);
        }
}

module front_clip() {
        difference() {
            scale([1, plug_ratio, 1])
                cylinder(h = locking_clip_z_groove, d = plug_width);
            scale([1, plug_ratio, 1])
                cylinder(h = locking_clip_z_groove, d = plug_width - locking_clip_xy_groove);
        }
}

module split_surface() {
    height = 2 * locking_clip_z_thickness + plug_cord_capture_distance;
    translate([-plug_width * 1.25 / 2, 0, 0])
        cube([plug_width * 1.25, plug_height * 1.25, height]);
}

module build_front_bracket() {
    translate([0, plug_width * 0.5, 0])
    intersection() {
        split_surface();
        
        union() {
            front_bracing();
            front_clip();
        }
    }
    
    difference() {
        union() {
            front_bracing();
            front_clip();
        }
        
        split_surface();
    }
}

build_front_bracket();

clip_width = 1.5;

module bottom_clip() {
    translate([0, -plug_width * 2, 0])
    difference() {
        scale([1, plug_ratio, 1])
            cylinder(h = locking_clip_z_thickness, d = plug_width + bracing_overlap + clip_width);
        scale([1, plug_ratio, 1])
            cylinder(h = locking_clip_z_thickness, d = plug_width + bracing_overlap);
    }
}

bottom_clip();


module top_clip() {
    difference() {
        scale([1, plug_ratio, 1])
            cylinder(h = locking_clip_z_thickness, d = plug_cord_diameter + bracing_overlap + clip_width);
        scale([1, plug_ratio, 1])
            cylinder(h = locking_clip_z_thickness, d = plug_cord_diameter + bracing_overlap);
        translate([0, -plug_cord_diameter / 2, 0])
            cube([plug_cord_diameter + bracing_overlap, plug_cord_diameter, locking_clip_z_thickness]);
    }
}

translate([-plug_width, 0, 0])
top_clip();
