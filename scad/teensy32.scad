include <common.scad>
p = 2.54;



module teensy32() {
    d = [35.56,17.78,1.57];
    module pad() color("silver") translate([p/2,p/2,-0.01]) cylinder(d=p*.8,h=1.6,$fn=10);
    module board() color([.3,0,.7]) cube(d);
    module headers() {
        for (x=[0:13],y=[0,6]) translate([x*p,y*p,0]) pad();
        for (x=[13],y=[1:5]) translate([x*p,y*p,0]) pad();
        for (x=[0:13],y=[0,6]) translate([x*p,y*p,0]) dmheader(p);
        for (x=[13],y=[2,3]) translate([x*p,y*p,0]) dmheader(p);
    }
    module usb() {
        d = [5,7.5,2.5];
        color("silver") cube(d);
    }
    module reset() {
        translate([1.5,1.5,0.01])
            cylinder(d=3.0,h=2.5,$fn=10);
    }
    translate([-d[0]/2,-d[1]/2,0]) {
        board();
        headers();
        translate([0,d[1]/2-7.5/2,d[2]]) usb();
        translate([29.97,d[1]/2-3/2,d[2]]) reset();
    }
}

teensy32();