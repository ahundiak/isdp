/* ###################   APOGEE COMPILED   ################## */
class specification ECboolean (1:0) of COconst;

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
    DLB  01/06/87     Creation date.
    rlw  05/13/87     Removed inclusion of EMlc.h
*/
 

instance ECboolean
{
 IGRint            num_located;              /*total num solids*/ 
 struct GRlc_info  locate_info;              /*located obj info*/
 struct GRlc_stack locate_stack;             /*for locate purposes*/
 struct GRevent    locate_event,             /*for locate purposes*/
                   accept_event;             /*for locate purposes*/
 struct GRid       construct_id;             /*constructed object*/
 IGRdouble         chttol;                   /*saved tolerance*/
 IGRboolean        newtol;                   /*is there a saved tol?*/
 IGRboolean        got_solid;                /*located a solid obj*/
 IGRboolean        got_all_solids;           /*located all solids*/
 IGRboolean        got_curve;                /*curve boolean*/
 IGRboolean        is_hilited;               /*got ids but not hilited*/
 variable GRobjid  located_ids[2];           /*located objids*/
 variable IGRushort changed[2];      /*located surf changes*/
 IGRboolean        hist_asked, 
                   keep_history,
                   associative;
};

override execute,
/*
Motivation: 
    This execute method contains the code for the
    implementation of the ECboolean command object. 
    The execute method is defined in the super_cmd
    class with the idea that it would be overridden
    at the command object class level.               
*/
wakeup,
/*
Motivation:
    The wakeup method is overridden to rehilite.
*/
sleep,
/*
Motivation:
    The sleep method is overridden to dehilite.
*/    
delete;
/*
Motivation:
    The surfaces must be restored to their original state.
*/

end specification ECboolean;
