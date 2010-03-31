/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
method EMcompress_top(IGRlong *EMmsg; struct GRmd_env *env)
/*
Description
  PPPPPPPPPAAAAAAAASSSSSSSSSSSSSSSS        OOOOOOONNNNNNNN!!!!!!!

Return values
    
History
  DLB 10/29/87 version 1.1.0 conversion
  DLB 4/22/87 Creation
*/
{
 IGRlong OM_stat = OM_S_SUCCESS;
 OM_S_CHANSELECT to_comps;
 
 *EMmsg = EMS_S_Success;

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

 OM_stat = om$send(msg = OPPmargs,
                   p_chanselect = &to_comps);
 if (! (1 & OM_stat)) goto wrapup;

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMScompsurf.EMcompress_top")
  return (OM_stat);
}

end implementation EMScompsurf;
