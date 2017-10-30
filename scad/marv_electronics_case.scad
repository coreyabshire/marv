$fs=0.2;

plate_width = 130.0;
plate_depth = 120.0;
plate_thickness = 2.5;

well_dims = [146,54,29];
well_thick = 3;
pi_dims = [90,60,20];
pi_length = 90;
pi_width = 60;
pi_height = 20;
lipo_2500_dims = [62,50,10];
boost_dims = [37,23,8];
hat_dims = [50,70,22];
screen_dims = [40,60,6];

module lipo_2500() {
    cube(lipo_2500_dims, center=true);
}

module powerboost() {
    cube(boost_dims, 
        center=true);
}

module battery_well() {
    t = (well_thick*2);
    inner_dims = well_dims - [t,t,t/2];
    echo(inner_dims);
    difference() {
        cube(well_dims, center=true);
        translate([0,0, well_thick]) {
            cube(inner_dims, center=true);
        }
    }
}

module raspberry_pi() {
    cube([pi_length, pi_width, pi_height], 
        center=true);
}

module pi_hat() {
    cube(hat_dims, 
        center=true);
}

module screen() {
    cube(screen_dims, center=true);
}

translate([0,0,-(well_dims[2]+well_thick)/2]) {
    color([0.6,0.6,0.6]) %battery_well();
}
layer_1_height = 0;
translate([-boost_dims[0]/2,0,(lipo_2500_dims[2])/2]) {
    rotate([0,0,0]) {
        color([0.8,0.8,0.8]) %lipo_2500();
    }
}
translate([lipo_2500_dims[0]/2,0,(lipo_2500_dims[2])/2]) {
    rotate([0,0,90]) {
        color([0.0,0.8,0.0]) %powerboost();
    }
}
layer_2_height = layer_1_height + lipo_2500_dims[2];
translate([0,0,layer_2_height+(pi_dims[2])/2]) {
    color([1,0,0]) %raspberry_pi();
}
layer_3_height = layer_2_height + pi_dims[2];
translate([screen_dims[0]/2,0,layer_3_height+(hat_dims[2])/2]) {
    color([0,1,0]) %pi_hat();
}
translate([-hat_dims[0]/2,0,layer_3_height+(hat_dims[2])/2]) {
    color([0,1,1]) %screen();
}
