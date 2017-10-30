use <marv_hat.scad>
use <raspberrypi.scad>
use <tft.scad>

p = 2.54;
%pi3();
translate([-2.54*6,0,1.5+2.54+8.5]) rotate([0,0,90])
    %hat(p);
translate([30,0,25]) rotate([0,0,-90]) %tft();
