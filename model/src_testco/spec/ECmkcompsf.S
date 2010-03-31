/* ###################   APOGEE COMPILED   ################## */
class specification ECmkcompsf (1:0) of COconst;

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
    This is the command object class for the mkcompsf operation.
    No subclasses should exist from ECmkcompsf.

Notes:
    This is not an abstract class.

History:
    DLB  11/xx//87     Creation date.
*/
 

instance ECmkcompsf
{
 IGRint            num_located;             /*total num solids*/ 
 struct GRlc_info  locate_info;             /*located solid info*/
 struct GRlc_stack locate_stack;            /*for locate purposes*/
 struct GRevent    locate_event;            /*for locate purposes*/
 variable GRobjid  surf_info[2];            /*located surf info*/
 struct   GRid     construct_id;            /*constructed composite id*/
 IGRboolean        got_solid;               /*Indicated conv. sol to cs.*/
 IGRchar           newclass[OM_K_MAXCLASS_LEN]; 
 IGRboolean        is_associative;
};

override execute,
/*
Motivation: 
    This execute method contains the code for the
    implementation of the ECmkcompsf command object. 
    The execute method is defined in the super_cmd
    class with the idea that it would be overridden
    at the command object class level.               
*/
wakeup,
/*
Motivation:
    The wakeup method is overridden to rehilite the located
    solids if the flag is set indicating so.
*/
sleep;
/*
Motivation:
    The sleep method is overridden to dehilite the located
    solids before leaving the command.
*/    

end specification ECmkcompsf;
