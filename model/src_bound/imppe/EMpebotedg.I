/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "EMSbnddef.h"
#include "emsmacros.h"

method EMget_bottom_edge(IGRlong *EMmsg; GRobjid *bottom_edge)

{

  IGRlong			stat_OM,msg;
  OM_S_CHANSELECT		to_comps;

/*-------------------------------------------------------------------*/
 
  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  to_comps.type = OM_e_addr;
  to_comps.u_sel.addr = &ME.EMSbd_owner->to_comps;

  stat_OM = om$send(msg = message EMSedge.EMget_bottom_edge(&msg,
                          bottom_edge),
                    p_chanselect = &to_comps);
  EMomerr_hndlr(stat_OM, wrapup, "EMSpartedge.EMget_bottom_edge");
  EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

  wrapup:

  return(stat_OM);
}

end implementation EMSpartedge;
