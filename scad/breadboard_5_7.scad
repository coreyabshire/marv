$fn=5;
module breadboard() {
    difference() {
        union() {
            color("limegreen") cube([70,50,1.6]);
            color("silver") for (x=[0:23],y=[0:17]) {
                translate([x*2.54+5.5,y*2.54+3.28,0]) cylinder(d=2.15,h=1.61);
            }
        };
        union() {
            for (x=[0:23],y=[0:17]) {
                translate([x*2.54+5.5,y*2.54+3.28,-2]) cylinder(d=0.75,h=5.6);
            }
        }
    }
}

breadboard();