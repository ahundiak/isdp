/* ###################   APOGEE COMPILED   ################## */
class specification ECspbool (1:0) of COconst;

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
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "EMSsfintsort.h"

instance ECspbool
{
 struct GRlc_stack               locate_stack;
 struct GRevent                  locate_event, accept_event;
 struct EMSextend_info           extend_info;
 IGRdouble                       sf_xyz_pt[3];
 IGRint                          last_response;
 IGRint                          num_located_objs;
 IGRint                          num_sfs;
 IGRint                          num_pts;
 IGRint                          num_pts_this_sf;
 IGRboolean                      pt_on_que;
 IGRboolean                      pt_highlighted;
 variable struct GRmd_env        located_obj_envs[5];
 variable struct GRid            located_obj_GRids[5];
 variable struct EMSsortpt_info  sortpts_info[5];
};

override execute,
         wakeup,
         sleep;

end specification ECspbool;
