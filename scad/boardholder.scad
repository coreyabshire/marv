$fs=0.2;

plate_width = 110.0;
plate_depth = 120.0;
plate_thickness = 3;

main_standoff_mounting_holes = [
  [-45,  50], [ 45,  50],
  [-45, -44], [ 45, -44],
];

module esc_cutout() {
    translate([0.0, plate_depth / 2.0, 0.0]) {
        cube([62.0, 38.0 * 2.0, plate_thickness * 4.0], 
            center=true);
    }
    translate([0.0, 23.0, 0.0]) {
        cylinder(h=10.0,r=5, center=true);
    }
}

module corner_cutouts() {
    union() {
        translate([plate_width / 2, plate_depth / 2, 0.0]) {
            rotate(60.0) {
                cube([20.0, 40.0, 8.0], center=true);
            }
        }
        translate([-plate_width / 2, plate_depth / 2, 0.0]) {
            rotate(-600.0) {
                cube([20.0, 40.0, 8.0], center=true);
            }
        }
    }
}

module power_switch_cutout() {
    translate([-45.0, 35.0, 0.0]) {
        cylinder(h=10.0,r=3.175, center=true);
    }
}

module main_plate_base() {
    translate([0.0, 0.0, plate_thickness / 2.0]) {
        cube([plate_width, plate_depth, plate_thickness], 
            center=true);
    }
    
}

module main_plate() {
    difference() {
        union() {
            main_plate_base();
        }
        union() {
            esc_cutout();
            //corner_cutouts();
            //power_switch_cutout();
            for (hole = main_standoff_mounting_holes) {
                translate([hole[0], hole[1], 0.0]) {
                    cylinder(h=10.0,r=1.5, center=true);
                }
            }
            for (x = [-1, 1], y=[-1, 1]) {
                translate([x * 25, y * 25-25, 0.0]) {
                    cylinder(h=10.0,r=1.5, center=true);
                }
            }
        }
    }
}


main_plate();
