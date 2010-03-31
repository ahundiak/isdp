/* ###################   APOGEE COMPILED   ################## */
class specification EClocalmod (1:0) of COconst;

# include "igetypedef.h"
# include "igrtypedef.h"
# include "godef.h"
# include "gr.h"
# include "igr.h"
# include "igrdp.h"
# include "go.h"
#include "OMlimits.h"   /* for ex.h     */
#include "ex.h"         /* for grio.h   */
#include "griodef.h"    /* for grio.h   */
#include "grio.h"       /* for lc.h     */
#include "dp.h"         /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"
#include "EMSdpb.h"

/*
Abstract:
    This is the command object class for Lift/Move face, edge, and vertex
    of a solid. No subclasses should exist from EClocalmod. 

Notes:
    This is not an abstract class.

History:
    scw 08/08/91     Converted to use gr$dpb associative flag
    DLB 03/27/91     Added from_pt_event, to_pt_event;
    DLB 08/12/88     Added ECvalidate message.
    RC  04/01/87     Creation date.
*/
 
instance EClocalmod
{
 struct GRlc_info   surf_info;         /*located surface information    */
 struct EMdpbinfo   dpb_info;
 struct GRlc_info   local_info;        /*located topology infomation    */
 struct GRlc_stack  locate_stack;      /*for surf locate purposes       */
 struct GRid        active_state_GRid; /*objid and osnum of active state*/
 struct GRid        top_lm_GRid;       /*top of local mod stack GRid    */
 struct GRid        locmod_obj_GRid;   /*newly constructed lift object  */
 struct GRevent     locate_event,      /*for locate purposes            */
                    from_pt_event,
                    to_pt_event;
 IGRdouble          project_pt[2];     /*u,v values of surface project pt*/
 IGRpoint           from_pt,           /*from point                     */
                    to_pt;             /*to point                       */
 IGRshort           ed_vt_display_flag;
 IGRboolean         srf_hi;            /*TRUE if surface is hilited     */
 IGRboolean         edvt_hi;           /*TRUE if edge/vertex is hilited */
 IGRboolean         top_lm_active;     /* TRUE if top of local mod stack*/
                                       /* is made active                */
 IGRboolean         single_sf_lift;
 IGRboolean         associative_flag;  
 IGRint             num_states;        /*total number of active states  */
 variable struct    GRid state_list[]; /*VLA of active states           */
}; 

override execute,
/*
Motivation: 
    This execute method contains the code for the
    implementation of the EClocalmod command object. 
    The execute method is defined in the super_cmd
    class with the idea that it would be overridden
    at the command object class level.               
*/
wakeup,
/*
Motivation:
    The wakeup method is overridden to rehilite the located
    local solid piece if the flag is set indicating so.
    Also make the top of local mod stack object active state if
    the flag is set indicating so.
*/
sleep;
/*
Motivation:
    The sleep method is overridden to dehilite the located
    local solid piece before leaving the command.
    Also make the top of the local mod stack object inactive
    stack and the active state object active if the flag
    is set indicating so.
*/    

message ECvalidate(IGRlong *EMmsg; IGRushort val_option);
/*
  Added as a means to reuse/reduce code.  This is a VERY specific 
  method for a VERY specific problem.
*/

end specification EClocalmod;
