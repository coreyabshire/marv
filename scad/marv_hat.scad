use <common.scad>
use <teensy32.scad>
use <gps.scad>

module teensy32d() {
    d = [35.56,17.78,1.57];
    translate([d[1]/2-1.27,d[0]/2-1.27,0]) rotate([0,0,-90]) teensy32();
}

module hat(p) {
    bthick = 1.6;
    d = [70,50,bthick];
    rows = 18;
    cols = 24;
    off = [d[0]-p*cols,d[1]-p*rows,0]/2;
    module pos(x,y) translate([x*p+p/2,y*p+p/2,bthick]+off) children();
    module tpos(x,y) translate([0,0,8.5+p]) pos(x,y) children();
    module board() {
        letters = "ABCDEFGHIJKLMNOPQRSTUVWX";
        module label(s) color("white") linear_extrude(.1) text(s,size=1.5);
        module pad() color("silver") cylinder(d=p*0.9,h=bthick+0.02,$fn=10);
        // panel
        color("green") cube(d);
        // pads
        for (x=[0:cols-1],y=[0:rows-1]) 
            translate([0,0,-bthick-0.01]) pos(x,y) pad();
        // labels
        for (i=[0:len(letters)])
         translate([0,0,bthick]) {
            translate([i*p,p*18,0]+off+[.5,.2,0]) 
                label(letters[i]);
            translate([i*p,-p,0]+off+[.5,.5,0]) 
                label(letters[i]);
        }
    }
    module mount() {
        for (i=[0,1],j=[0,1])
            translate([i*(d[0]-2*p)+p,j*(d[1]-2*p)+p,-1]) 
                cylinder(d=p,h=5,$fn=10);
    }
    module theaders() {
        for (x=[0:2],y=[4:16]) pos(x,y) mheader(p); // main i/o
        for (x=[4,10],y=[4:17]) pos(x,y) fheader(p); // teensy main
        for (x=[6:7],y=[4]) pos(x,y) fheader(p); // teensy bottom
        for (x=[8:11],y=[1,2]) pos(x,y) fheader(p); // ultrasonic power
        for (x=[11],y=[5:8]) pos(x,y) fheader(p); // ultrasonic echo/trigger 1
        for (x=[11],y=[11:14]) pos(x,y) fheader(p); // ultrasonic echo/trigger 2
        for (x=[13],y=[0:8]) pos(x,y) fheader(p); // gps
        for (x=[15:20],y=[10]) pos(x,y) fheader(p); // imu 1
        for (x=[16:19],y=[17]) pos(x,y) fheader(p); // imu 2
    }
    module bheaders() {
        for (x=[21:22],y=[-3:16]) pos(x,y) 
            translate([0,0,-bthick]) rotate([0,180,0]) 
                fheader(p);
    }
    
    translate(-[d[0]/2,d[1]/2,0]) {
        difference() { 
            board(); 
            mount(); 
        }
        theaders();
        bheaders();
        tpos(4,4) teensy32d();
        tpos(13,8) rotate([0,0,-90]) gps();
    }
}

p = 2.54;
%hat(p);
//teensy32d();
//mheader(p);