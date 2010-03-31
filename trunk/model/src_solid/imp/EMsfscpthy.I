/* ###################   APOGEE COMPILED   ################## */

class implementation EMSsfsolid;

#include "EMS.h"
#include "EMSprop.h"
#include "EMScap.h"

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMScompsurf_class_id;
extern OMuword OPP_EMSdpr_class_id;

from EMSloopset import EMget_props;

method EMcap_thyself (IGRlong *EMmsg;
                      struct GRvg_construct *construct_list;
                      GRobjid *surface_objid)

/* *************************************************************************

Description
  This method would try to construct a solid by capping the planar open
  ends if any, when given a surface objectid. The surface given becomes
  a part of the solid if the capping is successful. Should capping be
  unsuccesful for any reason the solid deletes itself. The burden of deleting
  the surface lies on the caller.

  Input
    construct_list - construction information
  
  Output
    EMmsg - completion status
    surface_objid - object id of the surface which needs to be capped.

Notes
  Upon exit the completion code will be one of the following:
  EMS_S_Success : if successful
  EMS_E_NoSolution : if the surface could not be capped because it contained
                     open ends which were not planar.
  EMS_E_Fail : a catch all error message
  EMS_E_Orientation : if the solid could not be oriented, most probably
                      due to the math missing out on intersections.
  EMS_E_DynamicMemoryAllocated : if there is a problem in memory allocation

History
  12/12/87  : PP : Creation
  11/24/92  : AMD : Plugged in support for 'place solid by capping'

/*************************************************************************** */

{

 IGRlong  status,cln_sts;
 IGRlong  index = 0;
 IGRboolean compsurf  = TRUE,
            general_cap = FALSE,
            solid_oriented = FALSE;
 struct EMSdataselect data;
 struct GRid surf_GRid,my_GRid;
 IGRushort ls_props;
 OM_S_CHANSELECT to_loopset;
 OMuword surf_classid, my_classid;
 OMuint  count;
 IGRboolean  recompute = FALSE;
 OM_S_CHANSELECT to_components;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 surf_GRid.objid = *surface_objid;
 surf_GRid.osnum = OM_Gw_current_OS;


 data.datatype = EMSdata_object;
 data.data.object = &surf_GRid;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 status = om$make_chanselect(channame = "GRcmpowner.to_components",
                             p_chanselect = &to_components);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 /**** This piece of code has been added for associative recompute ***/

 status = om$get_classid (objid = my_id,
                          p_classid = &my_classid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$is_ancestry_valid (subclassid = my_classid, 
                         superclassid = OPP_EMSdpr_class_id);                  
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 if(status == OM_S_SUCCESS)
 {
   status = om$get_channel_count ( objid = my_id,
                                   p_chanselect = &to_components,
                                   count = &count);

   if(count) /* Recomputing */
   {
    status = om$get_objid_at_index ( objid = my_id,
                                     p_chanselect = &to_components, 
                                     index = 0,
                                     objidaddr = &surf_GRid.objid,
                                     osnumaddr = &surf_GRid.osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
    recompute = TRUE;
   }
 }

/*
 * Notes: an assumption is being made that if the surface is not
 * a composite surface it is a simple surface
 */
 status = om$get_classid (objid = surf_GRid.objid,
                          p_classid = &surf_classid);
 if (!(1&status)) goto wrapup;

 status = om$is_ancestry_valid (subclassid = surf_classid,
                                superclassid = OPP_EMScompsurf_class_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 if (status == OM_S_SUCCESS)
 {
  OMuint comp_count = 0;
/*
 * Make natural boundary if the incoming object is a composite surface
 * with just one component, because that need not necessarily be true.
 */
  compsurf = TRUE;

  status = om$get_channel_count(p_chanselect = &to_components,
                                objid = surf_GRid.objid,
                                count = &comp_count);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  if (comp_count == 1)
  {
   IGRlong  loc_msg;

   om$send (msg = message EMSsurface.EMmk_nat_bdry(&loc_msg,
                  &(construct_list->env_info->md_env),NULL),
            senderid = surf_GRid.objid,
            p_chanselect = &to_components);
/*
 * Ignore all error messages.
 */
  }

 }
 else if (status == OM_I_INVANCESTRY)
 {
  status = OM_S_SUCCESS;
  compsurf = FALSE;

  status = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  if (!(1&status)) goto wrapup;

  status = om$send (msg = message EMSloopset.EMget_props(EMmsg, &ls_props),
                    senderid = surf_GRid.objid,
                    p_chanselect = &to_loopset);
  if (status == OM_I_CHAN_EMPTY)
  {
    status = OM_S_SUCCESS;
    general_cap = FALSE;
  }
  else if (status == OM_S_SUCCESS)
  {
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, *EMmsg, wrapup);
  
     general_cap = TRUE;
  }
  else
   goto wrapup;
 }

 else
  goto wrapup;

 if (compsurf || general_cap )
 {
   if(!recompute)
   {
    status = om$send (msg = message GRconnector.GRrigidconn (EMmsg,
                            &my_GRid, &index),
                      targetid = surf_GRid.objid);
    if (!(1&status)) goto wrapup;
    EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);
   }

   status = om$send (msg = message EMScompsurf.EMcap_comp(EMmsg,
                           construct_list->env_info,
                           construct_list,
                           FALSE), /* care coincidency is set to FALSE */
                     targetid = my_id);
   if (!(1&status)) goto wrapup;

   if (*EMmsg == EMS_I_Closed)
     *EMmsg = EMS_S_Success;
   else
    if (!(1&*EMmsg))
     goto wrapup;
 }
else
 {
  if(!recompute)
  {
   status = om$send (msg = message GRconnector.GRrigidconn (EMmsg,
                           &my_GRid, &index),
                     targetid = surf_GRid.objid);
   if (!(1&status)) goto wrapup;
   EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);
  }

   status = om$send ( msg = message 
            EMSsfsolid.EMconstruct_solid_by_capping_surface (
                      EMmsg,
                      &data, construct_list->env_info,TRUE,
                      &solid_oriented, 
                      &surf_classid,
                      construct_list),
                    targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);
 }


/*
 * If the solid orientation has not been done yet then use the general
 * mechanism for orientation.
 */

 if (!solid_oriented)
 {
  status = om$send (msg = message EMSsolid.EMorient_yourself (EMmsg,
                          NULL, construct_list->env_info),
                    targetid = my_id);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);
 }

 wrapup:

 EMWRAPUP(*EMmsg, status, "In EMcap_thyself : error");

 if (!(1&status&*EMmsg))
 {
  OM_S_CHANSELECT to_comps;
  IGRlong cln_msg;

  to_comps.type = OM_e_addr;
  to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

  cln_sts = om$send (msg = message GRgraphics.GRdelete (&cln_msg,
                           construct_list->env_info),
                     p_chanselect = &to_comps,
                     from = 1,
                     to = 2);

  cln_sts = om$send (msg = message GRconnector.GRdisconn (&cln_msg,
                           &my_GRid),
                     targetid = surf_GRid.objid);
 
  cln_sts = om$send (msg = message Root.delete(1),
                     targetid = my_id);
 }

 return (status);

}

end implementation EMSsfsolid;
