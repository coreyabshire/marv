use <marv_hat.scad>
use <raspberrypi.scad>
use <tft.scad>
use <MCAD/boxes.scad>

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

module quadstandoff(dx, dy, h, d1, d2) {
    for (x=[-dx,dx]/2, y=[-dy,dy]/2)
        standoff(x, y, h, d1, d2);
}

module case() {
    std_pitch = 2.54;
    pi_standoff_diameter = 5;
    pi_hull_dimensions = [60, 90, 20];
    hat_hull_dimensions = [72, 50, 28];
    corner_radius = 3;
    wall_thickness = 1.5;
    side_spacing = [5, 10, -10];

    // raspberry pi component support
    pi_standoffs = [49, 58];
    pi_standoff_height = 3;
    pi_offset = [0, -10, 0];

    // marv hat component support
    hat_standoffs = [64.92, 44.92];
    hat_standoff_height = 15.4;
    hat_offset = [0, -15, 0];
    
    // tft component support
    tft_standoffs = [61, 35.56];
    tft_standoff_height = 27.3;
    tft_offset = [0, 34, 0];
    
    standoff_outer = 5;
    standoff_inner = 1.7;
    bottom_offset = [0, 0, wall_thickness];
    case_hull_dimensions = vecmax(pi_hull_dimensions, hat_hull_dimensions) + side_spacing;
    
    module bottom () {
        translate ([0, 0, case_hull_dimensions[2] / 2])
            halfRoundedShell(case_hull_dimensions, corner_radius, wall_thickness);
    }
    
    module sqstandoff(dxdy, h) 
        quadstandoff(dxdy[0], dxdy[1], h, standoff_outer, standoff_inner);
    
    bottom();
    
    translate(pi_offset + bottom_offset) 
        sqstandoff(pi_standoffs, pi_standoff_height);
    translate(hat_offset + bottom_offset) 
        sqstandoff(hat_standoffs, hat_standoff_height);
    translate(tft_offset + bottom_offset) 
        sqstandoff(tft_standoffs, tft_standoff_height);
}


module components () {
    p = 2.54;
    pi3();
    translate([-p*6, 0, 1.5 + p + 8.5]) rotate([0, 0, 90]) hat(p);
    translate([34, 0, 25]) rotate([0, 0, -90]) tft();
}

p = 2.54;

%translate([0,0,4.5]) rotate([0,0,90]) components();

case();