$fn = 30;
outer_width = 40;
outer_depth = 100;
outer_height = 200;

inner_width = 36;
inner_depth = 94;
inner_height = 194;

inner_case_ground_clearance = 35;
air_vent_lower_clearance = -25;

air_vent_width = 6;
air_vent_spacing = 4;
air_vent_cutoff_at_proportion = 0.86;

outer_width_ratio = 2.27;
outer_depth_ratio = 1.13;
outer_cutout_degrees = 7.5;

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
    
    difference() {
        shell_body();
        
        shell_bottom_rounded_cutout();
                    
        
        // Side air vents on inner housing
        curve_radius = air_vent_width / 2;
        for(i = [0:air_vent_width + air_vent_spacing:inner_width / 2]) {
            // Vertical portion of vents
            translate([-inner_width / 2 + i, -outer_depth / 2, inner_case_ground_clearance + air_vent_lower_clearance]) {
                cube(
                    size = [air_vent_width, outer_depth, inner_height * air_vent_cutoff_at_proportion - inner_case_ground_clearance - air_vent_lower_clearance]
                );
            }
            translate([inner_width / 2 - i - air_vent_width, -outer_depth/2, inner_case_ground_clearance + air_vent_lower_clearance]) {
                cube(
                    size = [air_vent_width, outer_depth, inner_height * air_vent_cutoff_at_proportion - inner_case_ground_clearance - air_vent_lower_clearance]
                );
            }
            
            // Rounded tops and bottoms of vertical vents
            translate([-inner_width / 2 + curve_radius + i, outer_depth / 2, inner_case_ground_clearance + air_vent_lower_clearance]) {
                rotate([90, 0, 0])
                    cylinder(h = outer_depth, r = curve_radius);
                translate([0, 0, inner_height * air_vent_cutoff_at_proportion - inner_case_ground_clearance - air_vent_lower_clearance])
                    rotate([90, 0, 0])
                        cylinder(h = outer_depth, r = curve_radius);
            }
            translate([inner_width / 2 - curve_radius - i, outer_depth / 2, inner_case_ground_clearance + air_vent_lower_clearance]) {
                rotate([90, 0, 0])
                    cylinder(h = outer_depth, r = curve_radius);
                translate([0, 0, inner_height * air_vent_cutoff_at_proportion - inner_case_ground_clearance - air_vent_lower_clearance])
                    rotate([90, 0, 0])
                        cylinder(h = outer_depth, r = curve_radius);
            }
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
    translate([outer_width/2 - 1, 0, 50])
        rotate([94, 0, 90])
            generate_3d_text();
    translate([-outer_width/2 + 1, 0, 50])
        rotate([94, 0, 270])
            generate_3d_text();
}


inner_housing();
outer_housing();
branding();