module powerboost1000c (usb_out=0) {
    p = 2.54;
    d = [36.2,22.86,1.6];
    ind = [5.5,8,3];
    outd = [14.5,15,8];
    jstd = [8,6,5.5];
    holeoff = (d[1] - 17.65) / 2;
    pin1x = -p*4+21.72;
    // board
    module board() {
        // plate
        color([26,55,95]/255*1.5) cube(d);
        // pads
        translate([pin1x,0,0]) for (x=[0:7]) color("silver")
            translate([x*p+p/2,p/2,-.01]) cylinder(d=2,h=d[2]+.02,$fn=10);
    }
    difference() {
        board();
        // holes
        for (y=[holeoff,d[1]-holeoff])
            translate([holeoff,y,-1]) cylinder(d=2.5,h=3,$fn=10);
    }
    // usb in
    translate([0,d[1]/2-ind[1]/2,d[2]])
        color("silver") cube(ind);
    // usb out
    if (has_usb_out)
        translate([30,d[1]/2-outd[1]/2,d[2]])
            color("silver") cube(outd);
    // battery in
    translate([10.67-jstd[0]/2,d[1]-jstd[1],d[2]])
        color("black") cube(jstd);
    // label
    color("white") translate([d[0]-20,d[1]-2,d[2]])
        linear_extrude(0.01) text("PowerBoost 1000C", size=1.25);
    // leds
    color("blue") translate([33,1,d[2]]) cube([2,1,1]); // power
    color("red") translate([4.5,d[1]-3,d[2]]) cube([1,2,1]); // low
    color("yellow") translate([8,1,d[2]]) cube([2,1,1]); // charge
    color("green") translate([4.5,1,d[2]]) cube([2,1,1]); // full
}

powerboost1000c();