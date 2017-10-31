use <main_electronics_case.scad>
use <rustler.scad>
use <scad-utils/linalg.scad>

module rustler() {
    rotate([-90,180,-90]) scale([1,1,1]*10) color("gray")
        import("r-slash-c-car/RC CAR.stl", convexity=3);
}    

module attachment() {
    upper = [67.5, 10.0, 4.0];
    lower = [48.0, 10.0, 2.0];
    hole_diameter = 6.0;
    epsilon = 0.01;
    
    hole_offset_x = [-1, 1] * (upper[0] / 2 - upper[1] / 2);
    
    module upper() {
        hull() 
            for (x = hole_offset_x)
                translate([x, 0, 0]) 
                    cylinder(d = upper[1], h = upper[2]);
    }
    
    module lower() {
        translate(hadamard(lower, [-0.5, -0.5, 0.0])) 
            cube(lower);
    }
    
    module holes() {
        height = upper[2] + lower[2] + epsilon * 2;
        for (x = hole_offset_x)
            translate([x, 0, -epsilon]) 
                cylinder(d = hole_diameter, h = height, $fn=20);
    }
    
    module positive() {
        lower();
        translate([0, 0, lower[2]]) 
            upper();
    }

    module negative() {
        holes();
    }
    
    difference() {
        positive();
        negative();
    }
    

}

module original_battery_plate() {
    upper = [67.5, 10.0, 2.0];
    lower = [48.0, 10.0, 2.0];
    rects = [13.5, 6.75, 2.0];
    rect_spacing = 1.75;
    hole_diameter = 6.0;
    epsilon = 0.01;
    
    hole_offset_x = [-1, 1] * (upper[0] / 2 - upper[1] / 2);
    
    module upper() {
        hull() 
            for (x = hole_offset_x)
                translate([x, 0, 0]) 
                    cylinder(d = upper[1], h = upper[2]);
    }
    
    module lower() {
        translate(hadamard(lower, [-0.5, -0.5, 0.0])) 
            cube(lower);
    }
    
    module holes() {
        height = upper[2] + lower[2] + epsilon * 2;
        for (x = hole_offset_x)
            translate([x, 0, -epsilon]) 
                cylinder(d = hole_diameter, h = height);
    }
    
    module rects() {
        for (x = [-1, 0, 1])
            translate([x * (rects[0] + rect_spacing) - rects[0] / 2, 
                    -rects[1] / 2, epsilon])
                cube(rects);
    }

    module positive() {
        lower();
        translate([0, 0, lower[2]]) 
            upper();
    }

    module negative() {
        holes();
        translate([0, 0, lower[2]]) 
            rects();
    }
    
    difference() {
        positive();
        negative();
    }
    
       
}

rustler();
rotate([0,0,90]) chassis();
translate([0,0,56]) rotate([0,0,0]) case(with_exhaust = 0);
translate([0,9,30]) attachment();
//!battery_plate();
!attachment();
    