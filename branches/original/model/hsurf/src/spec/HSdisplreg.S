class specification HSdisplreg (1:0) of CEO_GSLOCATE;



#include "FI.h"
#include "OMtypes.h"
#include "dp.h"
#include "dpstruct.h"


instance HSdisplreg
{
        IGRchar 		style;        /* region style */
        IGRint 			orig_style;   /* original style */
	Form 			form_ptr;
	struct  		GRevent point_1;
	struct  		GRevent *events[2];
	OMuword 		classid;  
	OM_S_OBJID		objid;
	OMuword			osnum;
        struct DPdit_range  	reg_rng;
	IGRint			switch1;
        IGRint                  save_restore;
        IGRint                  get_point2_on;
};


message which_state ( long * sts );

message store_1st_event ( long * sts );

override dynamics;

message HSdisplreg_init ( long * sts );

message display_prompt1 ( long * sts );

message display_prompt2 ( long * sts );

message set_form_defaults ( long * sts );

message set_check_marks ( long * sts );

message adjust_form_buttons ( long * sts );

override form_notification;

message make_region ( long * sts );

message draw_region ( long * sts );

message reset_display ( long * sts );

message point2_on ( long * sts );

message point2_off ( long * sts );

end specification HSdisplreg;
