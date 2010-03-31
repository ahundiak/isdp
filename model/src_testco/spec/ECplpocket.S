/* ###################   APOGEE COMPILED   ################## */
class specification ECplpocket (1:0) of COconst;

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

#include "dp.h"         
#include "lcdef.h"    
#include "lc.h"
#include "EMSfeadef.h"  /* for struct pocket_data */

/*
Abstract:

This is a command object class for the construct operation of pocket/boss.
No subclasses should exist from ECplpocket.

History:

BL  10/12/89	Creation date.
BL  06/15/90	Converted the EMmake_pocket message to EMSfea_macro class
		and also moved struct pocket_data to EMSfeadef.h.
Tapadia 04/19/91 Added center_eve, depth_eve. Changed round_radius &
		 draft_angle from IGRdouble to struct GRevent. 
Tapadia 05/01/91 Added associative in the instance data.
Tapadia 07/15/91 Removed update_status.
Tapadia 07/25/91 Option to support more than one pocket removed. Hence removed
		 some variables defined earlier. 
*/
 
instance ECplpocket
{
    IGRboolean	round;  /* for testing if round bottom edges use */
    IGRboolean  drafted;  /* for placing drafted pocket/boss use */
    IGRboolean  associative;  /* for associative placement */
    IGRushort  const_state;	/* for undo, redo state use */
    IGRdouble  active_depth;
    IGRlong  num_parts;
    struct GRevent  round_radius;	/* for rounding bottom edges use */
    struct GRevent  draft_angle; /* for drafted pocket/boss use */
    struct pocket_data	 pocket;
    struct GRlc_stack  locate_stack;	/* for locate purpose */
    struct GRevent  locate_event;	/* for locate purpose */
    struct GRlc_info  surf_info[2];     /* located surf info */
    struct GRid	 solid_id;		/* solid id of the active owner */
    struct GRid  construct_id;		/* final constructed id */
    struct GRevent depth_eve;		/* depth */
};

override
	init, 
	execute, 
	wakeup, 
	sleep, 
	delete;

end specification ECplpocket;
