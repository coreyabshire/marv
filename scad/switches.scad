module big_toggle_switch () {
    cd = [12.7, 7, 10]; // cube dimensions
    bh = 9; // barrel height
    // bottom part
    color("red") translate([-cd[0] / 2, -cd[1] / 2, 0]) 
        cube(cd);
    // barrel part
    color("silver") translate([0, 0, cd[2]]) 
        cylinder(d=6.09, h=bh);
    // toggle part
    color("silver") translate([0, 0, cd[2]+bh-1]) rotate([0,15,0]) 
        cylinder(d=3, h=10+1);
}

big_toggle_switch();