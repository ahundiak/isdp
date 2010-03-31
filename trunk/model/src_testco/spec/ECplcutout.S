/* ###################   APOGEE COMPILED   ################## */
class specification ECplcutout (1:0) of COconst;

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
#include "lcdef.h"    
#include "lc.h"
#include "EMSfeadef.h"  /* for struct hole_data */

/*
Abstract:

This is a command object class for the construction of profile hole(s).
No subclasses should exist from ECplcutout

History:

07/28/92  Rustagi  Created this file from its parent file 'ECplhole.S'
                   for 'PLACE CUTOUT'command.
*/

instance ECplcutout
{
    IGRboolean  associative; /* for associative placement */
    IGRushort  form_displayed; /* Field for indicating whether the 
				status display form is activated or not */
    IGRushort  const_state; /* for undo, redo state use */
    IGRushort  depth_type; /* 0: thr_all, 1: thru_until, 2: thru_next,
					3: arbitrary */
    IGRint      num_holes;
    IGRdouble	hole_depth;
    IGRdouble	axis_dir[3]; /* the axis unit vector */
    variable struct EMShole	hole[10];
    struct GRlc_stack  locate_stack;	/* for locate purpose */
    struct GRevent  locate_event;	/* for locate purpose */
    struct GRlc_info  surf_info[3];     /* for located surface info */
    struct GRid	 solid_id;		/* solid id of the active owner */
    struct GRid  construct_id;		/* obj id after boolean op */
    Form   form1;
    variable struct GRevent center_eve[10]; /* center & dia */
    struct GRevent depth_eve, dia_eve;	/* hole depth & diameter */
};

override 
    status_disp,
    init, 
    execute, 
    wakeup, 
    sleep, 
    delete;


message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);
/*
ABSTRACT:
    This method sets up the instance data needed by the form_input method
FILE:
       EMcutoutform.I
*/

end specification ECplcutout;
