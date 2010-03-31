/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdumedge;

#include "EMS.h"
#include "emsdef.h"

method EMdumedgeinit(IGRlong *EMmsg;
                     GRobjid real_edge;
                     IGRboolean reverse)
{
  IGRlong               sts;
  OM_S_CHANSELECT       to_owner, to_comps, to_common_edge;
  extern OM_S_OBJID     current_creator;


  ME.EMSboundary->creator_id = current_creator;

  sts = EMmake_chanselect (EMSedge_to_owner, &to_owner);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
  sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
  
  sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_OMerror, wrapup);

  sts = om$send(msg = message EMSedge.EMget_props_type
                (EMmsg, &ME.EMSedge->ed_props, &ME.EMSedge->curve_type), 
                        targetid = real_edge);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

  sts = om$send(msg = message EMSedge.EMgetbounds
                        (EMmsg, ME.EMSpartedge->boundary), 
                        targetid = real_edge);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

  sts = om$send(msg = message Root.connect(to_comps, MAXINT, real_edge, 
                        OM_Gw_current_OS, to_owner, MAXINT), 
                        senderid = real_edge, targetid = my_id);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
  
  sts = om$send(msg = message Root.connect(to_common_edge, NULL, real_edge, 
                                OM_Gw_current_OS, to_common_edge, NULL), 
                        senderid = real_edge, targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_OMerror, wrapup);

  if(reverse)
   sts = om$send(msg = message EMSedge.EMreverse(EMmsg), targetid = my_id);

wrapup:
   EMWRAPUP(*EMmsg, sts, "In EMSdumedge.EMdumedgeinit");
   return(sts);
}

end implementation EMSdumedge;
