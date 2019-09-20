//
// Sturo Tower parametric model
//
// MIT License (see LICENSE file)
// (c) Russell Smith 2019
// https://github.com/ukd1/openscad-sutro-tower
//
// All distances / lengths are in meters.
//
// Deets from:
// https://www.sutrotower.com/PDF/Sutro%20Tower%20DEIR%2008-0517(1).pdf
// https://en.wikipedia.org/wiki/Sutro_Tower

height = 297.8;             // currently doeas shit
level_1_spacing = 45.7;     // from wikipedia
level_4_spacing = 18.3;     // "
level_6_spacing = 30.5;     // "

leg_radius = 1.5;           // guess, it looks kinda right
legs = 3;                   // observations, but this is useful for debug
base = 50;                  // change depending on what you want. 0 or less disables
show_wip_features = false;  // you wanna see work-in-progress stuff? enable this and maybe help? Note, these
                            // should not be indented properly, aka, -1 level, just to keep diffs low / because

//
// Level settings
// 
// some are estimates, based on guessing they're the same size as
// known levels. prolly dumb but easy to fix.
//

// unknown_level_thickness = level_4_top - level_4_bottom;
unknown_level_thickness = 4.6;

// level details from https://www.sutrotower.com/PDF/Sutro%20Tower%20DEIR%2008-0517(1).pdf page 20
// converted from ft to meters (x 0.3048)
//
level_6_top = 232.3;    // 762ft
level_6_bottom = level_6_top - unknown_level_thickness; // estimate

level_5_top = 200.2;    // 657ft
level_5_bottom = level_5_top - unknown_level_thickness; // estimate

level_4_top = 169.8;    // 557ft
level_4_bottom = 165.2; // 542ft

level_3_top = 116.4;    // 382ft
level_3_bottom = level_3_top - unknown_level_thickness; // estimate

level_2_top = 57.0;     // 187ft
level_2_bottom = level_2_top - unknown_level_thickness; // estimate


//
// Draw the base / floor
//
if (base > 0) {
    translate([-(base/2),-(base/2),0])cube([base,base,1]);
}


//
// Bottom "legs" of tower; L1 --> L4 waist
//

// work out the mid-point distance assuming the whole triangle is equilateral
function distance_to_center(spacing) = (spacing/2) * (sin(30) / sin(60));

level_1_distance_to_center = distance_to_center(level_1_spacing);
level_4_distance_to_center = distance_to_center(level_4_spacing);

offset_between_level_1_and_level_4 = level_1_distance_to_center - level_4_distance_to_center;

// now caculate the angle between adjacent and hypotenuse, plus the len
// of hypotenuse (aka, the leg) for a right-triangle as now we know
// the height to level 4, plus the offset distance from the bottom
// of level 1 to level 4.
leg_angle_level_1_to_level_4 = atan(offset_between_level_1_and_level_4/(level_4_bottom - 0));
leg_len_level_1_to_level_4 = sqrt(pow(offset_between_level_1_and_level_4, 2) + pow(level_4_bottom,2));

// for each leg bottom leg
for(leg=[1:legs]) {
    // spin each one 120 deg
    rotate([0,0,leg*120])
        // move the leg out by the distane to center
        translate([0,level_1_distance_to_center,0])
        // rotate it by the angle
        rotate([leg_angle_level_1_to_level_4,0,0])
        // make a cyl the right len (shrug on the radius)
        cylinder(r=leg_radius,h=leg_len_level_1_to_level_4);
}


//
// Top "legs" of tower; L4 --> L6 waist
//

level_6_distance_to_center = distance_to_center(level_6_spacing);
offset_between_level_4_and_level_6 = level_4_distance_to_center - level_6_distance_to_center;
echo(offset_between_level_4_and_level_6, " offset_between_level_4_and_level_6");

// Now caculate the angle between adjacent and hypotenuse, plus the len
// for a right-triangle as now we know
// the height to level 4, plus the offset distance from the bottom
// of level 4 to level 6.
level_4_to_6_height = (level_4_bottom-level_6_bottom);

leg_angle_level_4_to_level_6 = atan(offset_between_level_4_and_level_6/level_4_to_6_height);
leg_len_level_4_to_level_6 = sqrt(pow(offset_between_level_4_and_level_6, 2) + pow(level_4_to_6_height,2));

for(leg=[1:legs]) {
    // move everything to level_4_bottom
    translate([0,0,level_4_bottom]) {
        // spin each one 120 deg
        rotate([0,0,leg*120])
            // move the leg out by the distane to center
            translate([0,level_4_distance_to_center,0])
            // rotate it by the angle
            rotate([-leg_angle_level_1_to_level_4,0,0])
            // make a cyl the right len (shrug on the radius)
            cylinder(r=leg_radius,h=leg_len_level_4_to_level_6);
    }
}


//
// Platforms
//

for(leg=[1:legs]) {
    // spin each one 120 deg
    rotate([0,0,leg*120]) {
        //
        // Level 3 [WIP]
        //
        if (show_wip_features) {
        level_3_spacing=1;
        leg_angle_level_6_to_level_4 = 180 - 90 - leg_angle_level_1_to_level_4;
        level_3_distance_to_center = sin(90)*((level_4_bottom-level_3_bottom)/leg_angle_level_6_to_level_4);
        echo("xx: ", leg_angle_level_1_to_level_4, leg_angle_level_6_to_level_4, level_3_distance_to_center);

        translate([0,0,level_3_bottom]) {
            translate([0,level_3_distance_to_center,0])
            rotate([0,0,-60])
            cube([level_3_spacing/2,1.5,(level_3_top-level_3_bottom)]);
        }
        }
        
        //
        // Level 4
        //
        translate([0,0,level_4_bottom]) {
            translate([0,level_4_distance_to_center,0])
            rotate([0,0,-60])
            cube([level_4_spacing/2,1.5,(level_4_top-level_4_bottom)]);
        }
        
        
        //
        // Level 6 [WIP]
        //
        if (show_wip_features) {
        translate([0,0,level_6_bottom]) {
            translate([0,level_6_distance_to_center,0])
            rotate([0,0,-60])
            cube([(level_6_spacing/2)*1.5,1.5,unknown_level_thickness]);
        }
        }
    }
}