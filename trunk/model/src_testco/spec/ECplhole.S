/* ###################   APOGEE COMPILED   ################## */
class specification ECplhole (1:0) of COconst;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

#include "ex.h"
#include "igr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "FI.h"

#include "dp.h"         
#include "dpstruct.h"         
#include "lcdef.h"    
#include "lc.h"
#include "EMSfeadef.h"  /* for struct hole_data */

/*
Abstract:
    This is a command object class for the construct operation of hole(s).
    No subclasses should exist from ECplhole.
History:
    Tapadia 6/8/92 - Genesis
*/
 
instance ECplhole
{
    IGRboolean  pick_center; 	/* for locating base center use */
    IGRboolean  show_bottom;	/* for display bottom gadgets use */
    IGRboolean	show_angle; 	/* for display v_bottom's angle gadgets use */
    IGRboolean  show_center; 	/* for display center point use */
    IGRboolean  show_status; 	/* index for display active diameter status */
    IGRboolean  associative; 	/* for associative placement */
    IGRushort   form_displayed; /* Field for indicating whether the 
				status display form is activated or not */
    IGRushort   const_state; 	/* for undo, redo state use */
    IGRboolean  axis_normal; 
    IGRushort   depth_type; 	/* 0: thr_all, 1: thru_until, 2: thru_next,
					3: arbitrary */
    IGRboolean  v_bottom; 
    IGRboolean  ref_plane; 
    IGRboolean  end_ref_plane; 
    IGRdouble	v_angle; 	/* the angle of v_bottom */
    IGRint      num_holes;
    IGRdouble	hole_depth;
    IGRdouble   active_dia;
    IGRdouble   active_depth;
    IGRdouble	axis_dir[3]; 	/* the axis unit vector */
    variable struct EMShole	hole[10];
    struct GRlc_stack  	locate_stack;	/* for locate purpose */
    struct GRevent  	locate_event;	/* for locate purpose */
    struct GRlc_info  	surf_info[3];   /* for located surface info */
    struct GRid	 	solid_id;	/* solid id of the active owner */
    struct GRid  	construct_id;	/* obj id after boolean op */
    struct GRid		win_id;		/* window id */
    Form   form1;
    variable struct GRevent center_eve[10]; 	/* center */
    struct GRevent depth_eve, dia_eve;		/* hole depth & diameter */
};

override 
	status_disp,
	init, 
	execute, 
	wakeup, 
	sleep, 
	delete;

/*
Abstract:
    	This method sets up the instance data needed by the form_input method
File:
	EMmodhlform.I
*/

message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);

/* Hole action handler */
message hole_action_handler(struct hole_loc_acthndlr_args *hole_act; 
		struct GRlc_info *new_entry; struct LC_action_args *loc_args;
		enum GRlocate_action *action);

/* perform dynamics for displaying the reference plane direction */
message hole_dynamics(struct GRid *grid; struct GRevent *event; 
		struct GRid *cmd);


end specification ECplhole;
