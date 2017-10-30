
module ccube(d) {
    translate(-[d[0]/2,d[1]/2,0]) cube(d);
}

module fheader(p) {
    d = [p,p,8.5];
    color("black") ccube(d);
    color("silver") translate([0,0,-3.5]) cylinder(d=0.4,h=3.5);
}

module mheader(p) {
    d = [p,p,p];
    color("black") ccube(d);
    color("silver") translate([0,0,-3.5]) cylinder(d=0.4,h=12);
}

module dmheader(p) translate([1,1,0]*p/2) rotate([180,0,0]) mheader(p);
