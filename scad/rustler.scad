use <main_electronics_case.scad>

$fn = 10;

module chassis() {
    thinwall = 1.6;
    d = [343,136];
    b = 54;
    bh = 11;
    difference() {
        union() {
            translate([-343/2,-54/2,-11]) cube([343,54,11]);
            translate([-343/2,0,0]) linear_extrude(2.2) polygon(points=[
                [0,27],[35,27],[184,68],[255,68],[277,27],[343,27],
                [343,-27],[277,-27],[255,-68],[184,-68],[35,-27],[0,-27],], 
                paths=[[0,1,2,3,4,5,6,7,8,9,10,11]],convexity=10);
            translate([-65,-54/2,]) cube([170,54,20]);
            for (y=[-28,28]) translate([-62+15,y,0]) 
                cylinder(d=7,h=20,$fn=20);
        };
        translate([-345/2,-(54-6)/2,-8]) cube([107,54-6,12]); // frontsub
        translate([105,-(56)/2,-8]) cube([107,56,12]); // backsub
        translate([-62,-48/2,-8]) cube([141,48,50]); // batterysub
        translate([82,-48/2,-8]) cube([20,48,50]);
        for (y=[-28,28]) translate([-62+15,y,0]) 
            cylinder(d=3,h=20,$fn=20);
        hull() {
            translate([-20,0,28]) rotate([90,0,0]) cylinder(d=40,h=60,center=true);
            translate([60,0,23]) rotate([90,0,0]) cylinder(d=30,h=60,center=true);
        }
    }        
}
//34,148,70,22,66
//54,
color("gray")
chassis();
translate([0,0,46]) rotate([0,0,90]) case();

//function cumsum(x, s=0) = (
//    (x == []) ? [] : concat(x[0]+s, cumsum([for (i=[1:len(x)]) x[i]])));
//x = [1,1,1,1];
//echo(cumsum(x));