/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"

from EMSboundary import EMcompress_top;

method EMcompress_top(IGRlong *EMmsg; struct GRmd_env *env)
/*
Description

Return values
    
History
  DLB 4/22/87
  NP  8/24/92  	Modified for ANSI compliance. Changed "count" to "IGRuint" and 
		correctly passed "&partolbasis.tol" to "EMSsubbs.EMpartolbasis"
		instead of  "&partolbasis".
*/
{
 IGRlong OM_stat = OM_S_SUCCESS;
 IGRuint count;
 OM_S_CHANSELECT to_loopset;
 struct EMSpartolbasis partolbasis;
 GRobjid  newobjid; 
 IGRboolean world = TRUE;

 *EMmsg = EMS_S_Success;

 to_loopset.type = OM_e_addr;
 to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

 /*If I have no loopset then all done.*/
 OM_stat = om$get_channel_count(object = me,
                                p_chanselect = &to_loopset,
                                count = &count);
 if (! (1 & OM_stat)) goto wrapup;

 if (! count) goto wrapup;

 OM_stat = om$send(msg=message EMSsubbs.EMpartolbasis(EMmsg,
                       &env->md_env.matrix_type,
                       env->md_env.matrix,&world,
                       FALSE, &partolbasis.tol),
                   targetid = my_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 partolbasis.mattyp = &env->md_env.matrix_type;
 partolbasis.mat = env->md_env.matrix;
 partolbasis.in_world = TRUE;
 partolbasis.is_valid = TRUE;

 OM_stat = om$send(msg = message EMSboundary.EMcompress_top(EMmsg, 
                         &partolbasis, &newobjid),
                   p_chanselect = &to_loopset);
 if (! (1 & OM_stat)) goto wrapup;

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMcompress_top")
  return (OM_stat);
}

end implementation EMSsubbs;
