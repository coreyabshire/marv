module lipo4400(with_wire) {
    d = 18.5;
    h = 67;
    wthick=1.5;
    epsilon=0.01;
    module cell() rotate ([0,90,0]) cylinder(d=d,h=h,center=true);
    module wire() rotate ([0,90,0]) cylinder(d=wthick,h=h,center=true);
    module words(w) color("black") 
        linear_extrude(epsilon) text(w, size=2);

    color("blue") 
        hull() for (i=[1,-1])
            translate([0,i*d/2,0]) cell();
    if (with_wire) {
        translate([-h/2,-wthick,d/2-wthick]) color("red") wire();
        translate([-h/2,wthick,d/2-wthick]) color("black") wire();
    }
    translate([-6,1.5,d/2]) words("PKCELL");
    translate([-17,-1.5,d/2]) words("ICR18650 4400mAh 3.7V");
}

module lipo2000(with_wire) {
    d = 7.12;
    h = 60;
    w = 36.61;
    wthick=1.5;
    epsilon=0.01;
    module cell() rotate ([0,90,0]) cylinder(d=d,h=h,center=true);
    module wire() rotate ([0,90,0]) cylinder(d=wthick,h=h,center=true);
    module words(w) color("black") 
        linear_extrude(epsilon) text(w, size=2);

    color("silver") 
        hull() { 
            for (i=[w/2-d/2,-w/2+d/2])
                translate([0,i,0]) cell();
            translate([0,0,d/4]) rotate([0,0,0]) cube([h,w,d/2], center=true);
        }
    if (with_wire) {
        translate([-h/2,-wthick,d/2-wthick]) color("red") wire();
        translate([-h/2,wthick,d/2-wthick]) color("black") wire();
    }
    translate([-15,2,d/2]) words("- PKCELL LP803860");
    translate([-15,-2,d/2]) words("+ 3.7V 2000mAh");
}

translate([0,20,0]) lipo2000(with_wire=1);
translate([0,-20,0]) lipo4400(with_wire=1);