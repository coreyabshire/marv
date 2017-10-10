$fs=0.2;

plate_width = 130.0;
plate_depth = 120.0;
plate_thickness = 2.5;

main_standoff_mounting_holes = [
  [-45,  50], [ 45,  50],
  [-45, -44], [ 45, -44],
];

pi_holes = [
  [0, 0], [49, 0],
  [0, 58], [49, 58],
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
    for (hole = pi_holes) {
        translate([hole[0] + 10, hole[1] - 55, 8]) {
            cylinder(h=16,r=2.5, center=true);
        }
        translate([hole[0] + 10, hole[1] - 55, 5]) {
            cylinder(h=10,r=4, center=true);
        }
    }
    translate([0,-plate_depth/2-2,3.25]) {
        difference() {
            cube([20,10,6.5], center=true);
            translate([0,0,2.5])
                cube([16,4,10], center=true);
        }
    }
}

module breadboard() {
    cube([54.45, 82.56, 9.5]);
}

module breadboard_support() {
    cube([54.45, 10, 4.0]);
}

module breadboard_clip() {
    h = 20;
    rotate([90,0,0]) linear_extrude(height=5) 
        polygon(points=[[0,0],[3,0],[3,h],[2,h],[0,h-3],[0,h-4],[1.5,h-4],[1.5,0]]);
}

module breadboard_clips() {
    translate([-8,0,0])
        breadboard_clip();
    translate([-8,-32,0])
        breadboard_clip();
    translate([-59.45,-5,0]) rotate([0,0,180]) 
        breadboard_clip();
    translate([-59.45,-37,0]) rotate([0,0,180]) 
        breadboard_clip();
    translate([-25,20,0]) rotate([0,0,90])
        breadboard_clip();
    translate([-50,20,0]) rotate([0,0,90])
        breadboard_clip();
    translate([-20,-82.56+20+3,0]) rotate([0,0,-90])
        breadboard_clip();
    translate([-45,-82.56+20+3,0]) rotate([0,0,-90])
        breadboard_clip();
}

module breadboard_mount() {
    union() {
        translate([(-plate_width/2)+4,(-plate_depth/2),2.5]) {
            breadboard_support();
        }
        translate([(-plate_width/2)+4,(-plate_depth/2)-2+82.56/2-5,2.5]) {
            breadboard_support();
        }
        translate([(-plate_width/2)+4,(-plate_depth/2)-3+82.56-8,2.5]) {
            breadboard_support();
        }
    }
}

module main_plate() {
    difference() {
        union() {
            main_plate_base();
            breadboard_mount();
        }
        union() {
            esc_cutout();
            corner_cutouts();
            power_switch_cutout();
            for (hole = main_standoff_mounting_holes) {
                translate([hole[0], hole[1], 0.0]) {
                    cylinder(h=10.0,r=1.5, center=true);
                }
            }
            for (hole = pi_holes) {
                translate([hole[0] + 10, hole[1] - 55, 0.0]) {
                    cylinder(h=40.0,r=1.135, center=true);
                }
            }
            translate([-plate_width/2+4, 6, 0.0]) {
                cylinder(h=20.0,r=1.135, center=true);
            }
            translate([-plate_width/2+4, -11, 0.0]) {
                cylinder(h=20.0,r=1.135, center=true);
            }
        }
    }
}


main_plate();
translate([(-plate_width/2)+4,(-plate_depth/2)-1,6.5]) {
    %breadboard();
}
