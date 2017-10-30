use <common.scad>
$fn=100;

module gps() {
    p = 2.54; // 0.1" pitch in mm
    mmin = p*10; // mm per inch
    d = [1*mmin,1.34*mmin,1.6]; // board dimensions
    patchd = [15,15,5]; // z measures 4.76
    module pad() color("silver") translate([p/2,p/2,-0.01]) cylinder(d=p*.7,h=1.62,$fn=10);
    module board() {
        module patch() {
            cube(patchd);
        }
        module panel() {
            color([26,55,95]/255) {
                hull() {
                    for (x=[p,p*9],y=[p,1.24*mmin])
                        translate([x,y,0]) cylinder(r=p,h=d[2]);
                }
            }
        }
        module mount() {
            for (x=[p,p*9],y=[1.24*mmin])
                translate([x,y,-.01]) cylinder(d=.09*mmin,h=d[2]+.02);
        }
        translate ([-p/2,-.03*mmin,0]) {
            difference() {
                panel();
                mount();
            }
            translate([0.48*mmin-patchd[0]/2,0.69*mmin-patchd[1]/2,d[2]]) patch();
        }
        for (x=[0:8],y=[0]) translate([x*p,y*p,0]) {
            pad();
            dmheader(p);
        }
    }
    translate([-p/2,-p/2,0]) board();
}

gps();