$fn=100;
module tft() {
    p = 2.54;
    board = [66.01,40.71,1.41];
    slot = [15.57,14.10,1.88];
    screen = [55.20,40,2.93];
    holes = [61,35];
    module board() {
        color([26,55,95]/255)
            hull() for (i=[1,-1],j=[1,-1])
                translate([i*holes[0]/2,j*holes[1]/2,0]) 
                    cylinder(r=p,h=board[2],center=true);
        for (x=[-board[0]/2],y=[0:9])
            translate([x+p,y*p-p*5+p/2,-board[2]/2-.01]) 
                color("gold") cylinder(d=p*.8,h=board[2]+.02);
        color("white") {
            translate([p*12,p*5.5,.3])
                rotate([0,0,-90]) 
                    linear_extrude(0.5)
                        text("240x320 2.2\" TFT w/ILI9340C", size=1.5);
            translate([p*11,p*2.5,.3])
                rotate([0,0,-90]) 
                    linear_extrude(0.5)
                        text("by adafruit!", size=1.5);
        }
    }
    module mount() {
        for (i=[1,-1],j=[1,-1])
            translate([i*holes[0]/2,j*holes[1]/2,0]) 
                cylinder(d=p,h=3,center=true);
    }
    module sdslot() {
        translate([board[0]/2-slot[0]/2,0,-board[2]/2-slot[2]/2])
            color("silver")
                cube(slot, center=true);
    }
    module screen() {
        translate([0,0,board[2]/2+screen[2]/2]) {
            scale([1,1,.95])   color("white") cube(screen, center=true);
            scale([.95,.95,1]) color("black") cube(screen, center=true);
        }
    }
    difference() {
        board();
        mount();
    }
    sdslot();
    screen();
}

tft();
