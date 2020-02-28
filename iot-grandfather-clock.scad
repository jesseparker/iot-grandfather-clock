// Copyright <senorjp@gmail.com> Jan 2020
//
// Feb 15 version:
// Inadequate clearance for servo wire
// Breaks inserting servo and removing support material
// Hard to install chime
// Not enough clearance for chime
// Could be better hanging coaxially with strike
// Can't get past chime with screwdriver

$fn=40;

// Chime dimensions
chime_od=26;
chime_length=500;
chime_node=chime_length*0.224; // point of least vibration
chime_loop=chime_length/2; // where to hit the chime
chime_drop=chime_od*.75; // distance below the hanging holes

// Servo dimensions
/*
// HS422 
height = 36.5;
width = 20;
length = 40.5;
tab_height = 26;
tab_length = 6.5;
tab_width = 20;
tab_t = 4.5;
shaft_d = 6;
shaft_h = 5;
shaft_inset = 10.25;
arm_center_d=9;
arm_end_d=5;
arm_l=34;
arm_t=2.2;
*/
// SG90
height = 22;
width = 12.5;
length = 23;
tab_height = 15.5;
tab_length = 5;
tab_width = width;
tab_t = 2.6;
shaft_d = 4;
shaft_h = 8.5;
shaft_inset = 7.3;
arm_center_d=6.2;
arm_end_d=3.7;
arm_l=34.1;
arm_t=1.5;

// servo holder base dimensions
base_side_allowance=4;
base_wall_t=3;
base_front_t=1;
base_length_extension=0;
base_back_t=-.01; // not really needed
base_blank_r=8;    
base_blank_length=length+tab_length*2+base_wall_t*2+base_length_extension;

stroke_height = height + shaft_h + base_back_t; // Position for the center of the mallet and chime

// Hammer arm dimensions
arm_extension_length=138; // Adjust this to make things fit
arm_extension_t = 7;
hammer_d=30;
hammer_w=hammer_d;
hammer_t=6;
hammer_chime_neutral_separation=8; // leave extra space for "off position"

// D1 mini microcontroller dimensions
d1_x=27;
d1_y=35;
d1_board_z=2;
// more in the module, below

// pipe hanger
pipe_hanger_h=40; // height of support triangle
pipe_hanger_r=8; 
pipe_hanger_t=8; // thickness of support triangle
pipe_hanger_back_t=11; // thickness of basal platten
pipe_hanger_extra_y=26; 
pipe_hanger_ratio=1.8; // extra clearance around chime

// tuning peg 
tuning_peg_l=pipe_hanger_t+5;
tuning_peg_d1=7;
tuning_peg_d2=5;


module servo_shaft_translate() {
    translate([0,-length/2 + shaft_inset,-height/2])
        children();
}

module right_translate() {
    translate([chime_od/2+hammer_d/2+hammer_chime_neutral_separation,0,0])
        children();
}
module stroke_translate() {
    translate([0,0,stroke_height])
        children();
}

module pipe_translate() {
    right_translate()
        stroke_translate()
            translate([0,-arm_extension_length+hammer_d/2,0])
                rotate(90,[1,0,0])
                    children();
}
module hanger_translate() {
    right_translate()
        translate([0,chime_length/2-arm_extension_length+hammer_d/2-chime_node+chime_drop,0])
            children();
}

module d1mini_hanger_translate() {
    translate([0,pipe_hanger_r-pipe_hanger_h-pipe_hanger_extra_y+2,0])
        rotate(180,[0,0,1])
    d1mini_reg()
            children();
}
module d1mini_translate() {
    hanger_translate()
        d1mini_hanger_translate()
            children();
}

module servo (
    tol=0,
    neg=false,
    right=-1 // left
) {
        cylinder(r=shaft_d/2, h = shaft_h *2, center=true);

        if(neg) {
            //shaft relief right
            hull() {
                cylinder(r=width/2, h=shaft_h*2, center=true);
            translate([0,-width/2,0])
                cylinder(r=width/4, h=shaft_h*2, center=true);
            translate([right*width,0,0])
                cylinder(r=width/2, h=shaft_h*2, center=true);
             translate([right*width,-width/2,0])
                cylinder(r=width/4, h=shaft_h*2, center=true);
               
            }
           
        }
        servo_shaft_translate()
        union() {

        cube([width+tol,length+tol,height+tol], center=true);
        translate([0,0,-height/2 + tab_t/2 + tab_height])
            cube([tab_width+tol,length+tab_length*2+tol,tab_t+tol], center=true);

        if (neg) {
            channel_w=6;
            // wire relief vertical
            //translate([0,length/2+channel_w-.01,0])
            //    cube([channel_w,channel_w*2,height], center=true);
            // wire relief right
            translate([right*width/2,length/2+channel_w/2-.01,-height/2+channel_w/2])
                cube([width+channel_w/2,channel_w,channel_w], center=true);
            // tab clearance right
            translate([right*width/2,0,-height/2 + tab_t/2 + tab_height])
                cube([tab_width+tol,length+tab_length*2+tol,tab_t+tol], center=true);
            // body slot right
            translate([right*width/2,0,0])
            cube([width+tol,length+tol,height+tol], center=true);
        }
    }
    //translate([0,0,shaft_h])
    //    rotate(90,[0,0,1])
    //    servo_arm(neg=neg);
}
//!union() { servo(); %servo(neg=true, tol=1); }


module servo_arm(neg=false, tol=0) {

    
    hull() {
 
        cylinder(r=arm_center_d/2+tol, h=arm_t, center=true);
        translate([arm_l/2-arm_end_d/2,0,0])
            cylinder(r=arm_end_d/2+tol, h=arm_t, center=true);
        translate([-arm_l/2+arm_end_d/2,0,0])
            cylinder(r=arm_end_d/2+tol, h=arm_t, center=true);
    }
    if(neg) {
        translate([0,0,-5])
     hull() {
 
        cylinder(r=arm_center_d/2+tol, h=10, center=true);
        translate([arm_l/2-arm_end_d/2,0,0])
            cylinder(r=arm_end_d/2+tol, h=10, center=true);
        translate([-arm_l/2+arm_end_d/2,0,0])
            cylinder(r=arm_end_d/2+tol, h=10, center=true);
    }
       
    }
    //hub
    translate([0,0,-arm_end_d/2])       
        cylinder(r=arm_center_d/2, h=5, center=true);
    if(neg) {
        //screw clearance
        translate([0,0,10/2-.01])       
            cylinder(r=arm_center_d/2-1, h=10, center=true);
    }
}
//!union() {servo_arm(); %servo_arm(neg=true);}

module arm_extension(length = arm_extension_length, tol=0) {
    difference() {
        
        hull() {
             cylinder(r=13/2+tol/2, h=arm_extension_t+tol, center=true);
            translate([32/2-5/2,0,0])
                cylinder(r=9/2+tol/2, h=arm_extension_t+tol, center=true);
            translate([-length,0,0])
                cylinder(r=6/2+tol/2, h=arm_extension_t+tol, center=true);
           
        }
       translate([0,0,0])
       servo_arm(tol=0.4, neg=true);

        
 //      translate([-length+1,0,0])
 //          rotate(90, [1,0,0])
 //              cylinder(r=2, h=20, center=true);
    }
}

//!arm_extension();

module dong_head(d=hammer_d, wall=hammer_t, length=hammer_w) {
    difference() {
        cylinder(r=d/2, h=length, center=true);
        //translate([0,0,length/2+arm_extension_t/2+wall])
        //cylinder(r=d/2-wall, h=length, center=true);
        //translate([0,0,-length/2-arm_extension_t/2-wall])
        //cylinder(r=d/2-wall, h=length, center=true);
        cylinder(r=d/2-wall, h=length*2, center=true);
        translate([arm_extension_length-d/2,0,0])
        arm_extension(tol=.5);
    }
}

//translate([-arm_extension_length+30/2,0,0])
//dong_head();
//arm_extension();


module d1mini(tol=1, neg=false) {
    translate([0,0,d1_board_z/2])
    cube([d1_x+tol,d1_y+tol,d1_board_z+tol], center=true);
    if(neg) {
        translate([0,0,d1_board_z/2-4])
        cube([d1_x+tol,d1_y+tol,d1_board_z+tol+8], center=true);
    }

    //translate([d1_x/2-7/2,-d1_y/2-7,-d1_z/2+d1_extra_z/2])
       // cube([7,15,d1_z+d1_extra_z+tol], center=true);
    translate([0,(25-d1_y)/2,4/2+d1_board_z])
    cube([16+tol,25+tol,4+tol], center=true);

    translate([0,-(5-d1_y)/2,-d1_board_z])
    cube([8+tol,5+tol,4+tol], center=true);
    if(neg) {
        translate([0,(d1_y)/2,-d1_board_z])
        cube([9+tol,20+tol,6+tol], center=true);
    }
   
}
module d1mini_reg() {
    translate([0,-d1_y/2,5])
        children();
}
//!d1mini_reg() union(){d1mini();%d1mini(neg=true);}


module base_blank(bheight=base_blank_length, width=width+base_wall_t*2, blank_r=base_blank_r, tab_l=6, tab_t=base_back_t, tab_hole_d=4, tab_r=6, tol=1) {
depth=height+base_back_t+base_front_t+tol;
    
    translate([0,-length/2+shaft_inset+base_length_extension/2,0])
    difference() {
       union() {

           translate([0,0,depth/2])
           hull() {
                translate([width/2-blank_r+tol/2,bheight/2-blank_r+tol/2,0])
                    cylinder(r=blank_r, h=depth, center=true);
                translate([-width/2+blank_r-tol/2,bheight/2-blank_r+tol/2,0])
                    cylinder(r=blank_r, h=depth, center=true);
                translate([width/2-blank_r+tol/2,-bheight/2+blank_r-tol/2,0])
                    cylinder(r=blank_r, h=depth, center=true);
                translate([-width/2+blank_r-tol/2,-bheight/2+blank_r-tol/2,0])
                    cylinder(r=blank_r, h=depth, center=true);
            }
            
           /*
            translate([0,0,tab_t/2])
           hull() {
                translate([width/2-tab_r,height/2+tab_l-tab_r/2,0])
                    cylinder(r=tab_r, h=tab_t, center=true);
                translate([-width/2+tab_r,height/2+tab_l-tab_r/2,0])
                    cylinder(r=tab_r, h=tab_t, center=true);
                translate([width/2-tab_r,-height/2-tab_l+tab_r/2,0])
                    cylinder(r=tab_r, h=tab_t, center=true);
                translate([-width/2+tab_r,-height/2-tab_l+tab_r/2,0])
                    cylinder(r=tab_r, h=tab_t, center=true);
            }
            */
        
        }
        /*
        // mount holes
        translate([0,height/2+tab_l/2+tab_r/4,0])
            cylinder(r=tab_hole_d/2, h=tab_t*3, center=true);
        translate([0,-height/2-tab_l/2-tab_r/4,0])
            cylinder(r=tab_hole_d/2, h=tab_t*3, center=true);
        */

    }
}
//!base_blank();


module base(tol=1) {
    difference() {
        base_blank(tol=tol);
        translate([0,0,height+base_back_t])
        servo(tol=tol, neg=true);
    }
}
//!union() { base(); translate([0,0,height+base_back_t]) servo();}

module pipe() {
    cylinder(r=chime_od/2, h=chime_length, center=true);
    translate([0,0,-chime_length/2+chime_node])
    rotate(90,[0,1,0])
    cylinder(r=2, h=chime_od*2, center=true);
    rotate(90,[0,1,0])
    cylinder(r=2, h=chime_od*2, center=true);
}
//!pipe();

module pipe_hanger_blank(base_h=pipe_hanger_h, base_r=pipe_hanger_r, base_t=pipe_hanger_t, extra_y=pipe_hanger_extra_y, back_t=pipe_hanger_back_t) {
    base_w=chime_od*pipe_hanger_ratio +base_t*2;
    translate([0,-base_h/2+base_r,0])
   union() {
    hull() {
        translate([base_w/2-base_r, base_h/2-base_r, back_t/2])
        cylinder(r=base_r, h=back_t, center=true);
        translate([-base_w/2+base_r, base_h/2-base_r, back_t/2])
        cylinder(r=base_r, h=back_t, center=true);
        translate([base_w/2-base_r, -base_h/2+base_r-extra_y, back_t/2])
        cylinder(r=base_r, h=back_t, center=true);
        translate([-base_w/2+base_r, -base_h/2+base_r-extra_y, back_t/2])
        cylinder(r=base_r, h=back_t, center=true);
        
        //translate([-base_w/2+base_r, -base_h/2-base_r, base_t/2])
        //translate([0,base_h/2-15,dong_center_z])
        //rotate(90,[1,0,0])
        //cylinder(r=chime_od/2+8, h=15, center=true);
       
    }
    translate([base_w/2-base_t/2,0,0])
    rotate(-90, [0,1,0])
    hull() {
        translate([base_r, base_h/2-base_r, 0])
        cylinder(r=base_r, h=base_t, center=true);
        translate([stroke_height, base_h/2-base_r, 0])
        cylinder(r=base_r, h=base_t, center=true);       
        translate([base_r,-base_h/2+base_r, 0])
        cylinder(r=base_r, h=base_t, center=true);       
    }
    
    
    translate([-base_w/2+base_t/2,0,0])
    rotate(-90, [0,1,0])
    hull() {
        translate([base_r, base_h/2-base_r, 0])
        cylinder(r=base_r, h=base_t, center=true);
        translate([stroke_height, base_h/2-base_r, 0])
        cylinder(r=base_r, h=base_t, center=true);       
        translate([base_r,-base_h/2+base_r, 0])
        cylinder(r=base_r, h=base_t, center=true);       
    }    
}    
}
//!pipe_hanger_blank();

module pipe_hanger(base_h=pipe_hanger_h, base_r=pipe_hanger_r, base_t=pipe_hanger_t, mount_hole_d=5) {
    mount_hole_offset=chime_od/2-chime_od*pipe_hanger_ratio/2 -base_t;
     base_w=chime_od*pipe_hanger_ratio +base_t*2;
    difference() {
    pipe_hanger_blank(base_h=base_h, base_r=base_r, base_t=base_t);
    //notch
    //translate([0,base_h/2,stroke_height])
    //    rotate(45,[1,0,0])
    //        cube([base_w*2, 6, 6], center=true);
    // wire retainer
    translate([0,0,stroke_height])
        rotate(90,[0,1,0])
            cylinder(r=2, h=base_w*2, center=true);
    //translate([0,0,stroke_height-15])
    //    rotate(90,[0,1,0])
    //        cylinder(r=1.5, h=base_w*2, center=true);
    translate([base_w/2-base_t/2-1,0,stroke_height-12])
        rotate(90,[0,1,0])
            cylinder(r2=tuning_peg_d1/2, r1=tuning_peg_d2/2, h=tuning_peg_l, center=true);
    translate([-base_w/2+base_t/2+1,0,stroke_height-12])
        rotate(90,[0,1,0])
            cylinder(r2=tuning_peg_d2/2, r1=tuning_peg_d1/2, h=tuning_peg_l, center=true);

    // Mount holes
    translate([-mount_hole_offset,0,0])
        cylinder(r=mount_hole_d/2, h=pipe_hanger_back_t*3, center=true);
    translate([mount_hole_offset,0,0])
        cylinder(r=mount_hole_d/2, h=pipe_hanger_back_t*3, center=true);
    translate([mount_hole_offset,-base_h-pipe_hanger_extra_y+base_r*2,0])
        cylinder(r=mount_hole_d/2, h=pipe_hanger_back_t*3, center=true);
    translate([-mount_hole_offset,-base_h-pipe_hanger_extra_y+base_r*2,0])
        cylinder(r=mount_hole_d/2, h=pipe_hanger_back_t*3, center=true);
        
    d1mini_hanger_translate()
        d1mini(neg=true);

}
}
//!pipe_hanger();

dong_center_z=chime_od/2+stroke_height;

module main_blank(tol=1) {
    difference() {
        union() {
            base_blank(tol=tol);
            hanger_translate()
                pipe_hanger();  
        }
        // servo slot
        translate([0,0,height+base_back_t+tol/2])
            servo(neg=true, tol=tol); 
        // servo wire channel
        hanger_translate()
            translate([-31,-24,0])
                rotate(82,[0,0,1])
                    cube([10,70,6], center=true);       

        }

}
//!main_blank();

module bodysplit_hanger() {
    difference() {
        main_blank();
        translate([0,0,-0.05])
            base_blank(tol=1.1);
    }
}
module bodysplit_base() {
    intersection() {
        main_blank();
        translate([0,0,-.05])
        base_blank(tol=0.9);
    }
}

module tuning_peg() {
    translate([0,0,tuning_peg_l/2])
    difference() {
        cylinder(r2=tuning_peg_d2/2, r1=tuning_peg_d1/2, h=tuning_peg_l, center=true);
        translate([0,0,-tuning_peg_l/2])
            cube([2,5,4], center=true);
        translate([0,0,-3])
        rotate(90,[0,1,0])
            cylinder(r=1, h=20, center=true);
    }
}
//!tuning_peg();

module assembly(tol=1) {
    main_blank();
    d1mini_translate()
    color("green")
        d1mini();
//!rotate(-90, [0,1,0]) base();
   // base();
        translate([0,0,height+base_back_t+tol/2])
    color("black")
        servo();

rotate(90,[0,0,1])
translate([0,0,stroke_height]) {
translate([-arm_extension_length+hammer_d/2,0,0])
dong_head();
arm_extension();
}
color("silver")
pipe_translate()
pipe();


}
assembly();


//!main_blank();
//!rotate(180, [1,0,0]) arm_extension();
// Print arm and dong_head
module to_print(soluble=false) { // print all parts at once
    !union() {
        translate([0,0,arm_extension_t/2])
            rotate(180, [1,0,0])
                arm_extension();
        translate([-arm_extension_length/2-height, hammer_d/2+arm_extension_t,hammer_w/2])
            dong_head();
        if (soluble) { // single part body (lots of support, hard to remove)
        translate([-chime_od*pipe_hanger_ratio,pipe_hanger_extra_y+arm_extension_t,0])
            main_blank();
        }
        else { // must glue together
         translate([-chime_od*pipe_hanger_ratio,pipe_hanger_extra_y+arm_extension_t,0])
            bodysplit_hanger();
         translate([-chime_od*pipe_hanger_ratio-height/2-base_front_t-pipe_hanger_t*1.5,pipe_hanger_extra_y+arm_extension_t,width/2+base_blank_r/2-1/2])
            rotate(90,[0,1,0])
                bodysplit_base();
           
        }
        translate([-arm_extension_length+hammer_d/2,arm_extension_t+tuning_peg_d2,0])
            tuning_peg();
        translate([-arm_extension_length+hammer_d/2-tuning_peg_d2*2,arm_extension_t+tuning_peg_d2,0])
            tuning_peg();
    }
}

//to_print(soluble=false);



