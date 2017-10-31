use <marv_hat.scad>
use <batteries.scad>
use <raspberrypi.scad>
use <tft.scad>
use <MCAD/boxes.scad>
use <powerboost.scad>
use <switches.scad>

$fn=20;

function vecmax (a,b) = [for (i=[0:len(a)]) max(a[i],b[i])];

module halfRoundedBox(d, r) {
    epsilon = 0.01;
    difference() {
        roundedBox(d, r);
        translate([-epsilon, -epsilon, d[2]/2])
            cube([d[0] + epsilon * 4, 
                d[1] + epsilon * 4, 
                d[2]], center=true);
    }
}

module halfRoundedShell(d, r, t) {
    difference() {
        halfRoundedBox(d, r);
        translate([0,0,t]) halfRoundedBox([d[0]-t*2,d[1]-t*2,d[2]], r);
    }
}

module standoff(x, y, h, d1, d2) {
    translate([x, y, 0]) {
        difference() {
            cylinder(d=d1, h=h);
            cylinder(d=d2, h=h);
        }
    }
}

module wall_standoff(x, y, z, rz, w, h1, h2, d1, d2) {
    epsilon = 0.01;
    translate([x, y, z]) rotate([0, 0, rz]) {
        difference() {
            hull() {
                cylinder(d=d1, h=h1);
                translate([-d1/2,0,0]) cube([d1, w, h1]);
                translate([-d1/2,w,-h2]) cube([d1, w, h2]);
            }
            translate([0, 0, h1-h2]) cylinder(d=d2, h=h2);
            translate([-d1/2 - epsilon, w, -h2 - epsilon]) 
                cube([d1 + 2 * epsilon, w + epsilon, h1 + h2 + 2 * epsilon]);
        }
    }
}

module quadstandoff(dx, dy, h, d1, d2) {
    for (x=[-dx,dx]/2, y=[-dy,dy]/2)
        standoff(x, y, h, d1, d2);
}

module case(with_exhaust = 1) {
    std_pitch = 2.54;
    pi_standoff_diameter = 5;
    pi_hull_dimensions = [60, 90, 20];
    hat_hull_dimensions = [72, 50, 28];
    corner_radius = 1;
    wall_thickness = 1.5;
    side_spacing = [5, 14, 38];

    // raspberry pi component support
    pi_standoffs = [49, 58];
    pi_standoff_height = 5;
    pi_offset = [0, -14, 0];

    // marv hat component support
    hat_standoffs = [64.92, 44.92, 17.4];
    hat_standoff_height = 17.4;
    hat_offset = [0, -19, 0];
    
    // tft component support
    tft_standoffs = [61, 35.56, 26.3];
    tft_standoff_height = 27.3;
    tft_offset = [-3, 26, 0];
    
    standoff_outer = 5;
    standoff_inner = 1.75;
    bottom_offset = [0, 0, wall_thickness];
    case_hull_dimensions = vecmax(pi_hull_dimensions, hat_hull_dimensions) + side_spacing;
    
    module fan_cutout(x, z, r, s) {
        $fn = 50;
        epsilon = 0.01;
        screw_inner = 2.4;
        h = wall_thickness * 3 + 2 * epsilon;
        translate([0, 0, 0])
            cylinder(h = h, r = r);
        for (x = [-s, s], y = [-s, s])
            translate([x, y, 0])
                cylinder(d = screw_inner, h = h);
    }
    
    module exhaust_cutout() {
        for (x = [-11 : 11], y = [-4 : 4]) {
            translate([x * 3, y * 3, 0])
                cylinder(d = 2, h = 4);
        }
    }
    
    module bottom_screwholes(dx, dy) {
        for (x = [-dx/2, dx/2], y = [-dy/2, dy/2]) {
            translate([x, y, 0])
                cylinder(d = 2.9, h = 3);
        }
    }
    
    module bottom () {
        difference() {
            translate ([0, 0, case_hull_dimensions[2] / 2])
                halfRoundedShell(case_hull_dimensions, corner_radius, wall_thickness);
            translate([0, -48, 18]) rotate([90, 0, 0])
                fan_cutout(0, 0, 12.1, 10);
            if (with_exhaust) {
                color("red") translate([0, 53, 16]) rotate([90, 0, 0])
                    exhaust_cutout();
            }
            color("red") translate([0, 0, -1])
                bottom_screwholes(35, 70);
        }
    }
    
    module sqstandoff(dxdy, h) 
        quadstandoff(dxdy[0], dxdy[1], h, standoff_outer, standoff_inner);
    
    bottom();
    
    translate(pi_offset + bottom_offset) 
        sqstandoff(pi_standoffs, pi_standoff_height);
    
    module hat_standoffs(pos) {
        h = 4;
        w = 5;
        wall_standoff(pos[0]/2, pos[1]/2, pos[2] - h, -90, w, h, h, 
            standoff_outer, standoff_inner);
        wall_standoff(-pos[0]/2, pos[1]/2, pos[2] - h, 90, w, h, h, 
            standoff_outer, standoff_inner);
        wall_standoff(-pos[0]/2, -pos[1]/2, pos[2] - h, 90, w, h, h, 
            standoff_outer, standoff_inner);
        wall_standoff(pos[0]/2, -pos[1]/2, pos[2] - h, -90, w, h, h, 
            standoff_outer, standoff_inner);
    }
    
    //translate(hat_offset + bottom_offset) 
    //    sqstandoff(hat_standoffs, hat_standoff_height);
    translate(hat_offset + bottom_offset) 
        hat_standoffs(hat_standoffs);
    
    module tft_wall_standoff(x, y, z, rz) 
        wall_standoff(x, y, z, rz, 8, 4, 8, 
            standoff_outer, standoff_inner);
    
    module tft_wall_standoffs(pos) {
        wall_standoff(pos[0]/2, pos[1]/2, pos[2], -90, 10, 4, 8, 
            standoff_outer, standoff_inner);
        wall_standoff(-pos[0]/2, pos[1]/2, pos[2], 90, 4, 4, 4, 
            standoff_outer, standoff_inner);
        wall_standoff(-pos[0]/2, -pos[1]/2, pos[2], 90, 4, 4, 4, 
            standoff_outer, standoff_inner);
        wall_standoff(pos[0]/2, -pos[1]/2, pos[2], -90, 10, 4, 8, 
            standoff_outer, standoff_inner);
    }
    
    module gps_wall_standoffs() {
        for (y=[2.27, -0.27-(2.54*7)]) 
            wall_standoff(-33.27, y, 27.3, 90, 4, 4, 4, 
                standoff_outer, standoff_inner);
    }
    
    //translate(tft_offset + bottom_offset) 
    //    sqstandoff(tft_standoffs, tft_standoff_height);
    translate(tft_offset + bottom_offset) 
        tft_wall_standoffs(tft_standoffs);

    gps_wall_standoffs();

    module faceplate_standoffs(pos) {
        h = 4;
        w = 2;
        wall_standoff(pos[0]/2, pos[1]/2, pos[2] - h, -90, w, h, h, 
            standoff_outer, standoff_inner);
        wall_standoff(-pos[0]/2, pos[1]/2, pos[2] - h, 90, w, h, h, 
            standoff_outer, standoff_inner);
        wall_standoff(-pos[0]/2, -pos[1]/2, pos[2] - h, 90, w, h, h, 
            standoff_outer, standoff_inner);
        wall_standoff(pos[0]/2, -pos[1]/2, pos[2] - h, -90, w, h, h, 
            standoff_outer, standoff_inner);
    }
    
    
    
    faceplate_standoffs([case_hull_dimensions[0] - 6, 
        case_hull_dimensions[1] - 6, side_spacing[2] - 5]);
}


module components () {
    p = 2.54;
    pi3();
    translate([-p*6, 0, 1.5 + p + 8.5]) rotate([0, 0, 90]) hat(p);
    translate([30, 3, 26]) rotate([0, 0, -90]) tft();
    //translate([20, -50, 16]) rotate([90, 0, 0]) lipo2000(with_wire=1);
    //translate([-45, -50, 34]) rotate([90, 90, 0]) powerboost1000c(has_usb_out=0);
    //translate([37, -30, 7]) rotate([0, 90, 0]) big_toggle_switch();
}

p = 2.54;

%translate([0,-4,6.5]) rotate([0,0,90]) components();
case();

