/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"

method EMislmintree(IGRlong *EMmsg; IGRboolean *flag)
/*
Description
   True is returned if a local mod exists in the tree.

History
   DLB    06/8/87   Creation
*/

{
 IGRlong OM_stat;
 OM_S_CHANSELECT to_comps;


 *EMmsg = EMS_S_Success;

 /*Its faster to just set the flag to false every time than to
  * see if I am the active state and then set it.
  */
 *flag = FALSE; 

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

 OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_comps);
 if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
 
 OM_stat = OM_S_SUCCESS;  /*Set return code so WRAPUP doesn't complain*/

 wrapup:
   EMWRAPUP(*EMmsg, OM_stat, "In EMSdpr.EMislmintree")
   return(OM_stat);
}
end implementation EMSdpr;
