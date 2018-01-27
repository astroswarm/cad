$fn = 50;

// Quality: 0.3 for development, 1.0 for production
print_quality = 0.3;

inner_width = 29;
inner_depth = 104;
inner_height = 182;

width_thickness = 2;
depth_thickness = 2;
height_thickness = 2;

outer_width = inner_width + 2 * width_thickness;
outer_depth = inner_depth + 2 * depth_thickness;
outer_height = inner_height + 2 * height_thickness;

inner_case_ground_clearance = 44;
air_vent_lower_clearance = -30;

side_air_vent_width = 6;
side_air_vent_spacing = 4;
air_vent_cutoff_at_proportion = 0.86;

face_air_vent_angle = 70;
// Calculate air vent width to be exactly blocking any head-on (90 degree) debris. Add a 0.9 multiplier to add a little extra blockage to compensate for print error at thinnest points.
face_air_vent_width = width_thickness * sin(face_air_vent_angle) * 0.9;
face_air_vent_spacing = 10;
face_air_vent_side_padding = 18;
face_air_vent_height_crop_factor = 0.80;
face_air_vent_drop_angle = 50; // downward slope for water to drip out
face_air_vent_hollow_thickness = depth_thickness * 6;

outer_width_ratio = 2.75;
outer_depth_ratio = 1.10;
outer_cutout_diameter = 2 * outer_height;
outer_cutout_vertical_offset = outer_height - 112;
outer_cutout_horizontal_offset = outer_width / 2 + 6;

text_height_offset = 40;
face_airvent_height_offset = 62;

branding_height = 13;
branding_protrusion = 2;

lower_joint_height = inner_case_ground_clearance + air_vent_lower_clearance - side_air_vent_width / 2;
lower_joint_width = 6;

lower_cutout_depth_ratio = 0.38;
lower_cutout_z_offset = -6;

module generate_spheric_parabola(width, depth, height) {
    intersection() {
        scale([width, depth/2, height])
            sphere(r = 1, center = true, $fn = 100 * print_quality);
        
        translate([-width/2,-depth/2, 0])
            cube(
                size = [width, depth, height]
            );
    }
}

module inner_housing() {
    module shell_body() {
        difference() {
            generate_spheric_parabola(outer_width, outer_depth, outer_height);
            generate_spheric_parabola(inner_width, inner_depth, inner_height);
        }
    }
    
    module shell_bottom_rounded_cutout() {
        translate([0, 0, lower_cutout_z_offset])
            scale([inner_width, lower_cutout_depth_ratio * inner_depth, inner_case_ground_clearance])
                sphere(r = 1, center = true, $fn = 60 * print_quality);
    }
    
    module vertical_side_air_vent() {
        curve_radius = side_air_vent_width / 2;
        // Vertical portion
        cube(
            size = [side_air_vent_width, outer_depth, inner_height * air_vent_cutoff_at_proportion - inner_case_ground_clearance - air_vent_lower_clearance]
        );
        translate([curve_radius, 0, 0]) {
            // Rounded bottom
            rotate([-90, 0, 0])
                cylinder(h = outer_depth, r = curve_radius);
            // Rounded top
            translate([0, 0, inner_height * air_vent_cutoff_at_proportion - inner_case_ground_clearance - air_vent_lower_clearance])
                rotate([-90, 0, 0])
                    cylinder(h = outer_depth, r = curve_radius);
        }
    }
    
    module shell_side_air_vents() {
        // Create each side air vent
        iteration_width = side_air_vent_width + side_air_vent_spacing;
        num_vents = floor(inner_width / iteration_width);
        total_padding = inner_width - (num_vents * iteration_width) + side_air_vent_spacing; // There are n-1 spacings for n vents
        
        for (i = [-inner_width / 2:iteration_width:inner_width / 2 - iteration_width]) {
            translate([total_padding / 2, 0, 0]) {
                translate([i, -outer_depth / 2, inner_case_ground_clearance + air_vent_lower_clearance]) {
                    vertical_side_air_vent();
                }
            }
        }
    }
    
    module vertical_face_air_vent() {
        curve_radius = face_air_vent_width / 2;
        height = inner_height * air_vent_cutoff_at_proportion - face_airvent_height_offset;
        translate([-face_air_vent_hollow_thickness / 2, -curve_radius, -height / 2]) {
            // Vertical portion
            cube(
                size = [face_air_vent_hollow_thickness, face_air_vent_width, height]
            );
            translate([0, curve_radius, 0]) {
                // Rounded bottom
                rotate([0, 90 + face_air_vent_drop_angle, 0]) {
                    cylinder(h = face_air_vent_hollow_thickness * 1/cos(face_air_vent_drop_angle), r = curve_radius);
                    translate([0, face_air_vent_width / 2, 0])
                        rotate([0, 0, 180])
                            cube(size = [
                                face_air_vent_hollow_thickness * sin(face_air_vent_drop_angle),
                                face_air_vent_width,
                                face_air_vent_hollow_thickness * 1/cos(face_air_vent_drop_angle)
                            ]);
                }
                // Rounded top
                translate([0, 0, inner_height * air_vent_cutoff_at_proportion - face_airvent_height_offset])
                    rotate([0, 90, 0])
                        cylinder(h = face_air_vent_hollow_thickness, r = curve_radius);
            }
        }
        
    }
    
    module shell_face_air_vents() {
        // Create each side air vent
        iteration_depth = face_air_vent_width + face_air_vent_spacing;
        num_vents = floor((inner_depth - face_air_vent_side_padding * 2) / iteration_depth);
        total_padding = inner_depth - (num_vents * iteration_depth) + face_air_vent_spacing - 2 * face_air_vent_side_padding; // There are n-1 spacings for n vents
        
        vent_width = face_air_vent_width + tan(face_air_vent_angle) * face_air_vent_width;
        for (i = [-inner_depth / 2 + face_air_vent_side_padding:iteration_depth:inner_depth / 2 - iteration_depth - face_air_vent_side_padding]) {
            translate([0, total_padding / 2, (inner_height * air_vent_cutoff_at_proportion)/2 + face_airvent_height_offset/2]) {
                x_spacing = inner_width / 2 + width_thickness / 2;
                translate([x_spacing, i + vent_width / 2, inner_case_ground_clearance + air_vent_lower_clearance])
                    rotate([0, 0, -face_air_vent_angle])
                        vertical_face_air_vent();
                translate([-x_spacing, i + vent_width / 2, inner_case_ground_clearance + air_vent_lower_clearance])
                    rotate([0, 0, 180 + face_air_vent_angle])
                        vertical_face_air_vent();
            }
        }
    }
    difference() {
        shell_body();
        
        shell_bottom_rounded_cutout();
        shell_side_air_vents();
        
        intersection() {
            shell_face_air_vents();
            generate_spheric_parabola(outer_width * 1.1, outer_depth * 1.1, outer_height * face_air_vent_height_crop_factor);
        }               
    }
}


module outer_housing() {
    module cutaway_cylinders() {
        cylinder_length = max([outer_height, outer_width, outer_depth]);
        
        translate([(outer_cutout_diameter / 2) + outer_cutout_horizontal_offset, cylinder_length / 2, outer_cutout_vertical_offset])
            rotate([90, 0, 0]) {
                cylinder(
                    h = cylinder_length,
                    d = outer_cutout_diameter,
                    $fn = 200 * print_quality
                );
                translate([-outer_cutout_diameter / 2, 0, 0])
                    cube([outer_cutout_diameter, outer_cutout_diameter, cylinder_length]);
            }
        
        translate([-(outer_cutout_diameter / 2) - outer_cutout_horizontal_offset, cylinder_length / 2, outer_cutout_vertical_offset])
            rotate([90, 0, 0]) {
                cylinder(
                    h = cylinder_length,
                    d = outer_cutout_diameter,
                    $fn = 200 * print_quality
                );
                translate([-outer_cutout_diameter / 2, 0, 0])
                    cube([outer_cutout_diameter, outer_cutout_diameter, cylinder_length]);
            }
            
    }

    difference() {
        generate_spheric_parabola(outer_width * outer_width_ratio, outer_depth * outer_depth_ratio, outer_height);
        generate_spheric_parabola(outer_width * outer_width_ratio, inner_depth * outer_depth_ratio, inner_height);

        cutaway_cylinders();
    }
}

module branding() {
    module generate_3d_text() {
        linear_extrude(height = branding_protrusion)
            text(
                font = "Arial Rounded MT Bold",
                text = "Astrolab",
                size = branding_height,
                halign = "center"
            );
    }
    branding_angle = atan(branding_protrusion / branding_height) + 90;

    translate([outer_width/2 - branding_protrusion * sin(branding_angle), 0, text_height_offset])
        rotate([branding_angle, 0, 90])
            generate_3d_text();
    translate([-outer_width/2 + branding_protrusion * sin(branding_angle), 0, text_height_offset])
        rotate([branding_angle, 0, 270])
            generate_3d_text();
}

module housings_joint() {
    block_width = outer_width * outer_width_ratio;
    block_depth = outer_depth * outer_depth_ratio;
    
    
    difference() {
        // Solid base
        /*intersection() {
            generate_spheric_parabola(block_width, block_depth, outer_height);
                    translate([-outer_width / 2, -block_depth / 2, 0])
            cube(
                size = [outer_width, block_depth, outer_height]
            );
        }*/
        // Curved base
        generate_spheric_parabola(lower_joint_width, block_depth, outer_height);
        
        generate_spheric_parabola(outer_width, outer_depth, outer_height);
        
        translate([-block_width / 2, -block_depth / 2, lower_joint_height])
            cube(
                size = [block_width, block_depth, outer_height]
            );
    }

}

///////////////////////////
// Raspberry Pi Mounting //
///////////////////////////
pi_drop_angle = 50;
pi_clip_thickness = 2;
pi_clip_width = 3;
pi_clip_length = 16;
pi_clip_recess = 4; // Space between top of pi board and the Astrolab. Be sure to include any backing material.
clip_positions = [0, 20, 38, 51 + pi_clip_width];

pi_reserved_width = 56;
pi_reserved_depth = 25;
pi_reserved_height = 88 + pi_clip_length;

pi_vertical_offset = inner_case_ground_clearance - 4 + lower_cutout_z_offset;
pi_horizontal_offset = 0;

module mock_pi() {
    color("blue")
    cube(size = [pi_reserved_depth, pi_reserved_width, pi_reserved_height], center = false);
}

// Todo: Create an enlarged sphere at clip bend merging straight and bent portion smoothly.
module single_pi_clip() {
    bent_length = pi_clip_recess / sin(pi_drop_angle) + pi_clip_thickness / tan(pi_drop_angle);
    bent_height = bent_length * cos (pi_drop_angle);
    
    rotate([0, pi_drop_angle, 0]) {
        cube(size = [pi_clip_thickness, pi_clip_width, bent_length], center = false);
        translate([pi_clip_thickness / 2, pi_clip_width, bent_length])
            rotate([90, 0, 0])
                cylinder(h = pi_clip_width, d = pi_clip_thickness, center = false);
    }
    
    translate([pi_clip_recess + pi_clip_thickness * cos(pi_drop_angle), 0, bent_height]) {
        // Straight clip
        cube(size = [pi_clip_thickness, pi_clip_width, pi_clip_length], center = false);
        
        // Lower cylinder on straight clip
        translate([pi_clip_thickness / 2, pi_clip_width, 0])
            rotate([90, 0, 0])
                cylinder(h = pi_clip_width, d = pi_clip_thickness, center = false);
        // Upper cylinder on straight clip
        translate([pi_clip_thickness / 2, pi_clip_width, pi_clip_length])
            rotate([90, 0, 0])
                cylinder(h = pi_clip_width, d = pi_clip_thickness, center = false);
    }
    
}

module pi_clips() {
    translate([0, 0, pi_vertical_offset]) {
        translate([-inner_width / 2 - pi_clip_thickness * cos(pi_drop_angle), pi_horizontal_offset, 0]) {
            max_pos = max(clip_positions) + pi_clip_width;
            min_pos = min(clip_positions);
            x_offset = (max_pos - min_pos) / 2;
            for (pos = clip_positions) {
                translate([0, pos - x_offset, 0])
                    single_pi_clip();
            }
        }
        
        translate([-inner_width / 2, -pi_reserved_width / 2,  pi_clip_thickness / tan(pi_drop_angle)]) {
            //mock_pi(); // Uncomment to see spatial footprint for a Raspberry pi
        }
    }
}

power_x_offset = 7;
power_z_offset = 76 + pi_vertical_offset + pi_clip_thickness / tan(pi_drop_angle) + 4;
power_plug_width = 10;
power_plug_height = 7;

power_plug_width_factor = power_plug_width / power_plug_height;
power_cord_diameter = 4;
power_cord_compression = 0.25;
power_cap_scale_factor = 0.95;

module pi_power_opening() {
    translate([-inner_width / 2 + power_x_offset, 0, power_z_offset])
        rotate([90, 0, 0])
            scale([1, power_plug_width_factor, 1])
                cylinder(h = outer_depth / 2, d = power_plug_width);
}

module simulate_pi_power_plug() {
    color("blue")
    translate([-inner_width / 2 + power_x_offset, -inner_depth / 2, power_z_offset])
        rotate([90, 0, 0])
            cube([power_plug_height, power_plug_width, inner_depth / 2], center = true);
}

module power_cap() {
    translate([outer_depth / 2, 0, 0])
    difference() {
        // Main area
        scale([power_cap_scale_factor, 1, power_cap_scale_factor])
        translate([
            inner_width / 2 - power_x_offset,
            45,
            -power_z_offset + power_plug_width * power_plug_width_factor / 2
        ])
            intersection() {
                outer_housing();
                pi_power_opening();
            }
        
        // Power cord hole
        translate([0, outer_depth / 2, power_cord_diameter / 2 - power_cord_compression])
            rotate([90, 0, 0])
                cylinder(h = outer_depth, d = power_cord_diameter);
    }
}

module build_structure() {
    difference() {
        union() {
            inner_housing();
            outer_housing();
            housings_joint();
            branding();
            pi_clips();
        }
        
        pi_power_opening();
    }

    //simulate_pi_power_plug();
}

module build_cap() {
    power_cap();
}

build_structure();
build_cap();