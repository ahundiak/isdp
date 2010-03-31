class specification NMnmmkcompsf (1:0) of COconst;

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
#include "EMSdpb.h"

instance NMnmmkcompsf
{
 IGRint            num_located;             /*total num solids*/ 
 struct GRlc_info  locate_info;             /*located solid info*/
 struct GRlc_stack locate_stack;            /*for locate purposes*/
 struct GRevent    locate_event;            /*for locate purposes*/
 variable struct GRid  surf_info[2];            /*located surf info*/
 struct   GRid     construct_id;            /*constructed composite id*/
 IGRboolean dpb_assoc_flag;
};

override execute, init, wakeup, sleep, delete;

end specification NMnmmkcompsf;
