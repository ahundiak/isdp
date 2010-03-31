/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
from EMSedge import EMexecuteCurveFunction;

method EMexecuteCurveFunction(IGRlong *EMmsg;struct IGRbsp_surface *surf;
                              IGRshort *mx_type; IGRmatrix mx;
                              GRobjid surf_id;IGRint (*f)();IGRchar *args;
			      IGRushort eligible_edge_type)
{
  IGRboolean        first_edge = TRUE;
  IGRlong           sts;
  OM_S_CHANSELECT   to_edges;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &me^^EMSbd_owner.to_comps;
  sts = om$send(msg = message EMSedge.EMexecuteCurveFunction(EMmsg,
                surf, mx_type, mx, surf_id, f, args, &first_edge, 
		eligible_edge_type),
                p_chanselect = &to_edges);

wrapup:
  EMSmsgReport(sts, "EMSloop.EMexecuteCurveFunction", FALSE);
  if EMSmsgReport(*EMmsg, "EMSloop.EMexecuteCurveFunction", FALSE)
    sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSloop;
