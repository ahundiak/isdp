
class specification ECtrmcompsf(1:0) of ECboolean;

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "OMlimits.h" 
#include "dp.h"         /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"

/*
Abstract:

Notes:
    This is not an abstract class.

History:
    Vidya  23/07/93     Creation date.
*/
 

instance ECtrmcompsf
{
 IGRint            num_located;              /*total num curves*/ 
 IGRlong		   reverse;		   /* reverse of area */
 struct GRlc_info  surf_info;		     /*located surf or solid info */
 variable struct GRlc_info  lcinfo_curves[10];   /*located curves info*/
 variable struct GRid    win_ids[10]; /* window ids of lcoated curves */
 struct GRlc_stack locate_stack;             /*for locate purposes*/
 struct GRevent    locate_event,             /*for locate purposes*/
                   accept_event;             /*for locate purposes*/
 struct GRid       construct_id;             /*constructed object*/
 GRobjid	   lrgst_compid;	   /* largest curve id */
 IGRint	 	   crv_index;		 /* curve index */
};

override init,execute,
/*
Motivation: 
    This execute method contains the code for the
    implementation of the ECtrmcompsf command object. 
    The execute method is defined in the super_cmd
    class with the idea that it would be overridden
    at the command object class level.               
*/
wakeup,
/*
Motivation:
    The wakeup method is overridden to rehilite.
*/
sleep;
/*
Motivation:
    The sleep method is overridden to dehilite.
*/    
/*
delete
Motivation:
    The surfaces must be restored to their original state.
*/

end specification ECtrmcompsf;
