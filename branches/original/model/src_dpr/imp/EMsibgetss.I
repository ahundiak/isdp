/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfimpbnd;

#include "EMS.h"
extern OMuword OPP_EMSsfimpbnd_class_id;

method EMget_subbs(IGRlong *EMmsg; GRobjid *sfid)
{
  IGRlong		sts;
  OM_S_CHANSELECT	to_comps;
  OMuword		sf_class;

  to_comps.type = OM_e_addr;
  to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

  sts = om$send(msg = message EMSsurface.EMgetGRobjid(EMmsg, sfid), 
			p_chanselect = &to_comps);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

  sts = om$get_classid(objid= *sfid,p_classid=&sf_class);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  if(sf_class == OPP_EMSsfimpbnd_class_id)
    sts = om$send(msg = OPPmargs, p_chanselect = &to_comps);

wrapup:

  EMWRAPUP(*EMmsg, sts, "In EMSsfimpbnd.EMget_subbs");
  return(sts);
}

end implementation EMSsfimpbnd;
