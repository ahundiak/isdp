/* ###################   APOGEE COMPILED   ################## */
class specification ECplslot (1:0) of COconst;

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
#include "EMSfeadef.h"  /* for struct slot */

/*
Abstract:

This is a command object class for the construct operation of slot.
No subclasses should exist from ECplslot.

History:

Tapadia 07/28/91  Creation date.
*/
 
instance ECplslot
{
    IGRboolean  associative; 	/* for associative placement */
    IGRushort  form_displayed; /* Field for indicating whether the 
					status display form is activated or 
					not */
    IGRushort  const_state; 	/* for undo, redo state use */
    IGRushort  depth_type; 	/* 0: thr_all, 1: thru_until, 
					2: thru_next, 3: finite */
    IGRboolean dir_rev;		   	/* direction of slot reversed = 1 
					else dir_rev = 0 */
    IGRboolean pro_nor_rev;		/* direction of profile normal reversed
					= 1 else = 0 */
    struct EMSslot slot; 
    struct GRlc_stack  locate_stack;	/* for locate purpose */
    struct GRevent  locate_event;	/* for locate purpose */
    struct GRlc_info  surf_info[3];     /* for located surface info */
    struct GRid	 solid_id;		/* solid id of the active owner */
    struct GRid  construct_id;		/* obj id after boolean op */
    Form   form1;
    struct GRevent center_eve; 		/* center */
    struct GRevent depth_eve; 		/* slot depth for finite slots */
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

Abstract:
    This method sets up the instance data needed by the form_input method
File:
	EMslotform.I
*/

end specification ECplslot;
