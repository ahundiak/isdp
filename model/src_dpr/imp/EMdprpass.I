/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"

method EMpass(IGRlong *EMmsg; IGRint options; OM_p_MESSAGE mssg;
              IGRint *tree_depth)
/* *******************************************************************

Description
 This method applies the message contained in mssg field when the variable
 *tree_depth becomes 0. Currently this message is only sent downward. So
 for applying the mssg to an id immediately below a target DPR object,
 *tree_depth should be set to 1 and so on.

Arguments
 EMmsg : O : Return code
 options : I : Currently set to NULL.
 mssg    : I : Input message that needs to be applied to a given DPR
               node.
 tree_depth: I : The tree depth at which the message needs to be applied.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well
 EMS_E_Fail   : Otherwise

History
     Creation : PP : 05/25/90
   ******************************************************************* */

{
 IGRlong status;
 OM_S_CHANSELECT to_comps;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;
 
 if (*tree_depth == 0)
 {
  status = om$send (msg = mssg,
                    targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 }
 else 
 {
  -- (*tree_depth);
  status = om$send (msg = OPPmargs,
                    p_chanselect = &to_comps);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 }

wrapup:
 return (status);
} 
end implementation EMSdpr;

