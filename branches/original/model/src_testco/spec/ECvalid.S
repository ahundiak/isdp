/* ###################   APOGEE COMPILED   ################## */
class specification ECvalid (1:0) of COconst;

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


instance ECvalid
{
 IGRint            num_located;              /*total num elements*/ 
 struct GRlc_stack locate_stack;            /*for locate purposes*/
 struct GRevent    locate_event;            /*for locate purposes*/
 variable struct GRlc_info  locate_info[2];     /*located eleinfo*/
 IGRchar           filename[MAX_CHAR]; 
 IGRboolean	   stdreportonly;
};

override init, execute, wakeup, sleep;

end specification ECvalid;
