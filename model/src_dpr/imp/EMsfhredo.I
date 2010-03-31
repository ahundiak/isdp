/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfhist;

#include "EMS.h"
#include "EMSopt.h"

method EMredo(IGRlong           *EMmsg;
              IGRushort *option;
              struct GRmd_env   *my_env;
              GRobjid           **display_ids;
              IGRint            *display_count, *involk_count)
/*
Description
    See EMdprredo.I file for a description of this method.

History
   DLB   07/27/89 Removed toggling of ISLOC ISDIS bits.
   DLB   03/14/88 Added selective display code
   DLB   11/06/87 Modified for version 1.1.0
   DLB   05/07/87 Creation
*/

{
 IGRlong             OM_stat;
 OM_S_CHANSELECT     to_comps;
 IGRboolean          action;
 IGRushort   mask;


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 
 /*If I am active then all is well.*/
 if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) goto wrapup;

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

 /*Send on down the tree.*/
 OM_stat = om$send(msg = OPPmargs,
                   p_chanselect = &to_comps);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 if (*EMmsg == EMS_I_BoolFail) return (OM_S_SUCCESS);

 /*Since this particular redo will only occur after a temporary undo has
  * occurred, I only do some simple things.
  */

 /*Turn off last states active state bit*/
 action = FALSE;
 mask = EMSIS_ACTIVE_STATE;
 
 OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, 
                         &mask),
                   p_chanselect = &to_comps);
 if(!(1 & *EMmsg & OM_stat))goto wrapup;

 /*Set my active bits on.*/
 ME.EMSdpr->dpr_props |= (EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH);
 ME.EMSdpr->dpr_props &= ~EMS_PERFORM_REEX;  /*Just in case.*/
   
 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfhist.EMredo")
  return(OM_stat);
}
end implementation EMSsfhist;
