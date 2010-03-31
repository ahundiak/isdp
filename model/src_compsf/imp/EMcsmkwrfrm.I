/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
# include "emseligible.h"

method EMmake_wire_frame(IGRlong *EMmsg; struct GRmd_env *md_env;
                         struct EMScurveinfo *curve_info;
                         IGRushort eligible_edge_type)
{
  IGRlong           sts = OM_S_SUCCESS;
  OM_S_CHANSELECT   to_components;
 
  *EMmsg = EMS_S_Success;

  to_components.type = OM_e_addr;
  to_components.u_sel.addr = &ME.GRcmpowner->to_components;

  eligible_edge_type |= EMSeligible_NonSeamEdge | EMSeligible_NonSubEdge;
  sts = om$send(msg = message EMSsurface.EMmake_wire_frame(EMmsg, md_env,
                curve_info, eligible_edge_type),
                p_chanselect = &to_components);

wrapup:

  EMWRAPUP(*EMmsg, sts, "In EMScompsurf.EMmake_wire_frame");
  return(sts);
}

end implementation EMScompsurf;
