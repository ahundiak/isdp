/* ###################   APOGEE COMPILED   ################## */
class specification ECreex (1:0) of COconst;

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

instance ECreex
{
 struct GRlc_info   surf_info;         /*located surface information    */
 struct EMdpbinfo   dpb_info;
 struct GRlc_info   local_info;        /*located topology infomation    */
 struct GRlc_stack  locate_stack;      /*for surf locate purposes       */
 struct GRid        active_state_GRid; /*objid and osnum of active state*/
 struct GRid        top_lm_GRid;       /*top of local mod stack GRid    */
 struct GRid        locmod_obj_GRid;   /*newly constructed lift object  */
 struct GRevent     locate_event;      /*for locate purposes            */
 IGRboolean         srf_hi;            /*TRUE if surface is hilited     */
 IGRboolean         top_lm_active;     /* TRUE if top of local mod stack*/
                                       /* is made active                */
 IGRint             num_states;        /*total number of active states  */
 variable struct    GRid state_list[]; /*VLA of active states           */
}; 

override execute, wakeup, sleep;

message ECvalidate(IGRlong *EMmsg);

end specification ECreex;
