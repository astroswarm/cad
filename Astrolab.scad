$fn = 30;
outer_width = 40;
outer_depth = 100;
outer_height = 200;

inner_width = 36;
inner_depth = 94;
inner_height = 194;

width_thickness = (outer_width - inner_width) / 2;
depth_thickness = (outer_depth - inner_depth) / 2;

inner_case_ground_clearance = 35;
air_vent_lower_clearance = -25;

side_air_vent_width = 6;
side_air_vent_spacing = 4;
air_vent_cutoff_at_proportion = 0.86;

face_air_vent_angle = 60;
face_air_vent_exposure_buffer_proportion = 0.95;
face_air_vent_width = width_thickness * face_air_vent_exposure_buffer_proportion * (sin(face_air_vent_angle));
face_air_vent_spacing = 5;
face_air_vent_side_padding = 18;
face_air_vent_height_crop_factor = 0.8;
face_air_vent_hollow_thickness = depth_thickness * 4;

outer_width_ratio = 2.27;
outer_depth_ratio = 1.13;
outer_cutout_degrees = 7.5;

text_height_offset = 50;
face_airvent_height_offset = text_height_offset + 30;

module generate_spheric_parabola(width, depth, height) {
    intersection() {
        scale([width, depth/2, height])
            sphere(r = 1, center = true);
        
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
        scale([inner_width, inner_depth / 2, inner_case_ground_clearance])
            sphere(r = 1, center = true);
    }
    
    module vertical_side_air_vent() {
        curve_radius = side_air_vent_width / 2;
        // Vertical portion
        cube(
            size = [side_air_vent_width, outer_depth, inner_height * air_vent_cutoff_at_proportion - inner_case_ground_clearance - air_vent_lower_clearance]
        );
        translate([curve_radius, 0, 0]) {
            // Rounded top
            rotate([-90, 0, 0])
                cylinder(h = outer_depth, r = curve_radius);
            // Rounded bottom
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
                rotate([0, 90, 0])
                    cylinder(h = face_air_vent_hollow_thickness, r = curve_radius);
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
                    rotate([0, 0, face_air_vent_angle])
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
    module cutaway_cubes() {
        translate([-outer_width * outer_width_ratio / 2, 0, 0])
        translate([-outer_width * outer_width_ratio, -outer_depth * outer_depth_ratio / 2, 0])
        rotate([0, outer_cutout_degrees, 0])
            cube(size=[outer_width * outer_width_ratio, outer_depth * outer_depth_ratio, outer_height*1.5]);

        rotate([0, 0, 180])
        translate([-outer_width * outer_width_ratio / 2, 0, 0])
        translate([-outer_width * outer_width_ratio, -outer_depth * outer_depth_ratio / 2, 0])
        rotate([0, outer_cutout_degrees, 0])
            cube(size=[outer_width * outer_width_ratio, outer_depth * outer_depth_ratio, outer_height * 1.5]);
    }

    difference() {
        generate_spheric_parabola(outer_width * outer_width_ratio, outer_depth * outer_depth_ratio, outer_height);
        generate_spheric_parabola(outer_width * outer_width_ratio, inner_depth * outer_depth_ratio, inner_height);

        cutaway_cubes();
    }
}

module branding() {
    module generate_3d_text() {
        linear_extrude(height = 1)
            text(
                font = "Arial Rounded MT Bold",
                text = "Astrolab",
                size = 13,
                halign = "center"
            );
    }
    translate([outer_width/2 - 1, 0, text_height_offset])
        rotate([94, 0, 90])
            generate_3d_text();
    translate([-outer_width/2 + 1, 0, text_height_offset])
        rotate([94, 0, 270])
            generate_3d_text();
}


inner_housing();
outer_housing();
branding();