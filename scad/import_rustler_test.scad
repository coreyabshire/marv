use <main_electronics_case.scad>

module rustler() {
    rotate([-90,180,-90]) scale([1,1,1]*10) color("gray")
        import("r-slash-c-car/RC CAR.stl", convexity=3);
}    

module attachment() {
    battery_slot_inner = [48,141,0];
    translate(-battery_slot_inner / 2)
        cube(battery_slot_inner + [0, 0, 2]);
}

rustler();
translate([0,0,56]) rotate([0,0,0]) case();
translate([0,11,30]) attachment();
    