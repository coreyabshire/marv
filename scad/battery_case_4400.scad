use <batteries.scad>
use <powerboost.scad>
use <rustler.scad>
use <MCAD/boxes.scad>

module battery_case_4400() {
    thin = 1.5;
    thick = 6;
    standoff = 3;
    boost = [36,8,22];
    lipo = [69,22,38];
    inner = [lipo[0],lipo[1]+boost[1],lipo[2]];
    outer = inner + [thin,thin,thick] * 2;
    module whole(c) {
        module supports() {
            module add() {
                for (x=[1:3])
                    translate([x*outer[0]/4,1,1]) cube([thin,outer[1]-2,outer[2]-2]);
                for (x=[1,3],y=[16],z=[3.2,46.8])
                    translate([(x*outer[0]/4)+thin/2,y,z]) 
                        rotate([90,0,0]) cylinder(d=6,h=inner[1]+thin+.02,center=true,$fn=20);
            }
            module sub() {
                translate([0,5,25]-[-outer[0]/2,-outer[1]/2,0]) 
                    rotate([-90,180,0]) lipo4400(with_wire=0);
                translate([10,thin+.01,12]) cube([50,inner[1],25]);
            }
            difference() { add(); sub(); }
        }
        module shell() {
            difference() {
                color(c, alpha=1) translate(outer/2) roundedBox(outer, thin, $fn=15);
                translate((inner + [0,0,(thick-thin)*2])/2) translate([thin,thin,thin])
                    roundedBox(inner + [0,0,(thick-thin)*2], thin, $fn=15);
            }
        }
        difference() {
            union() {
                shell();
                supports();
            }
            for (x=[1,3],y=[18],z=[3,47])
                translate([(x*outer[0]/4)+thin/2,y,z]) 
                    rotate([90,0,0]) cylinder(d=2.8,h=inner[1]+thin+.02,center=true,$fn=20);
            for (x=[1,3],y=[18],z=[3.1,46.9])
                translate([(x*outer[0]/4)+thin/2,y,z]) 
                    rotate([90,0,0]) cylinder(d=4,h=2,center=true,$fn=20);
        }
        color("red") for (x=[1,3],y=[32],z=[3.1,46.9])
            translate([(x*outer[0]/4)+thin/2,y,z]) 
                rotate([90,0,0]) cylinder(d=4,h=2,center=true,$fn=20);
        //translate([35,20,0]) rotate([90,0,0]) cylinder(d=7,h=inner[1]-thin/2,center=true);
    }
    module back() {
        difference() {
            whole("orange");
            translate([-10,-28,-10]) {
                cube([100,50,100]);
            }
        }
    }
    module front() {
        difference() {
            union () {
                whole("blue");
                translate([11,7.5,14.5]) rotate([90,0,0]) cylinder(d=3,h=6,$fn=40);
                translate([8,7.5,14.5]) rotate([90,0,0]) cylinder(d=3,h=6,$fn=40);
                translate([7.2,7.5,34]) rotate([90,0,0]) cylinder(d=2,h=6,$fn=40);
                translate([36,7.5,14.5]) rotate([90,0,0]) cylinder(d=3,h=6,$fn=40);
            }
            translate([-10,22,-10]) {
                cube([100,50,100]);
            }
            translate([-5,5,20])cube([10,4,9]);
            translate([67,8,outer[2]/2]) rotate([0,90,0]) cylinder(d=6.25,h=8,$fn=30);

            translate([11,8,14.5]) rotate([90,0,0]) cylinder(d=1,h=10,$fn=40);
            translate([8,8,14.5]) rotate([90,0,0]) cylinder(d=1,h=10,$fn=40);
            translate([7.2,8,34]) rotate([90,0,0]) cylinder(d=1,h=10,$fn=40);
            translate([36,8,14.5]) rotate([90,0,0]) cylinder(d=1,h=10,$fn=40);
        }
        // mounts
        difference() {
            union() {
                translate([5,8.5,15]) rotate([90,0,0]) cylinder(d=4,h=7,$fn=40);
                translate([5,8.5,15+2.54*7]) rotate([90,0,0]) cylinder(d=4,h=7,$fn=40);
            }
            translate([5,9,15]) rotate([90,0,0]) cylinder(d=2.7,h=8,$fn=40);
            translate([5,9,15+2.54*7]) rotate([90,0,0]) cylinder(d=2.7,h=8,$fn=40);
        }
    }
    translate([-outer[0]/2,-outer[1]/2,0]) {
        back();
        //front();
    }
}

//translate([-40,46,-2]) %chassis();
translate([0,5,25]) {
    //rotate([-90,180,0]) %lipo4400(with_wire=1);
    //translate([-34.5,-9-3,-12]) rotate([-90,180,180])
    //    %powerboost1000c();
}

battery_case_4400();