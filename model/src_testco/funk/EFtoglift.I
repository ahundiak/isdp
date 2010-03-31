class implementation EMSsfdlift;

#include <stdio.h>
#include "EMSopt.h"
#include "OMmacros.h"
#include "codef.h"
#include "ECdfh.h"
#include "EMSbnddef.h"
#include "EMSmsgdef.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "dpmacros.h"
#include "grdpbmacros.h" 
#include "exmacros.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMStypedef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "emsdef.h"
#include <alloca.h>

#define LIFT_SF_INX  1

from EMSpointer import EMinit;

IGRboolean EFis_objid_below(EMmsg, tree_id, tree_os, search_id, options) 
IGRlong         *EMmsg;
GRobjid         tree_id;
OMuword         tree_os;
GRobjid         search_id;
OMuword         options;
{
  IGRint              OM_stat=OM_S_SUCCESS, ii;
  OMuint              count;
  OM_S_OBJECT_LINKAGE *comp_ids;
  OM_S_CHANSELECT     to_comps;
  extern OMuword      OPP_GRowner_class_id;


  *EMmsg = EMS_S_Success;

  if (!EFisAncestryValid(EMmsg, tree_id, tree_os, OPP_GRowner_class_id, 
                         FALSE)) return(FALSE);

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  OM_stat = om$is_objid_on_channel(objid_c = tree_id,
                                   osnum_c = tree_os,
                                   p_chanselect = &to_comps,
                                   objid = search_id,
                                   osnum2 = tree_os);
  if (OM_stat == OM_S_SUCCESS) return(TRUE);
  else if (!(1 & OM_stat) && (OM_stat != OM_W_NOTONCHAN)) goto wrapup;

  OM_stat = OM_S_SUCCESS;

  OM_stat = om$get_channel_count(objid = tree_id,
                                 osnum = tree_os,
                                 p_chanselect = &to_comps,
                                 count = &count);
  if (!(1 & OM_stat)) goto wrapup;

  if (!count) return(FALSE);

  comp_ids = (OM_S_OBJECT_LINKAGE *) alloca
             (count * sizeof(OM_S_OBJECT_LINKAGE));

  OM_stat = om$get_channel_objects(objid = tree_id,
                                   osnum = tree_os,
                                   p_chanselect = &to_comps,
                                   list = comp_ids,
                                   size = count,
                                   count = &count);
  if (!(1 & OM_stat)) goto wrapup;

  for(ii=0; ii<count; ii++)
  {
    if (EFis_objid_below(EMmsg, 
                         comp_ids[ii].S_objid, tree_os, search_id,
                         options)) return(TRUE);
    else if (!(1 & *EMmsg)) goto wrapup;
  }                                   

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFis_objid_below")
  return(FALSE);
}


IGRlong EFtoggle_lift_to_other_surf(EMmsg, lift_id, lift_os, surf_to_lift_id,
                                    env, options) 
IGRlong         *EMmsg;
GRobjid         lift_id;
OMuword         lift_os;
GRobjid         surf_to_lift_id;
struct GRmd_env *env;
OMuword         options;
{
  IGRint          OM_stat=OM_S_SUCCESS;
  GRobjid         ptr_id, creator_id;
  OM_S_CHANSELECT to_father, to_children;
  struct GRid     tmp_grid;
  extern OMuword  OPP_EMSpointer_class_id, OPP_NDnode_class_id;


  *EMmsg = EMS_S_Success;

  OM_stat = EFget_creator_id(EMmsg, surf_to_lift_id, lift_os, &creator_id,
                             NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  EMmake_chanselect(NDfather_father, &to_father);
  EMmake_chanselect(NDchildren_children, &to_children);

  tmp_grid.osnum = lift_os;

  if (surf_to_lift_id != creator_id)
  {
    if (!EFisAncestryValid(EMmsg, creator_id, lift_os, OPP_NDnode_class_id,
                           FALSE))
    {*EMmsg = EMS_I_InvalidCase; goto wrapup;}

    OM_stat = om$construct(classid = OPP_EMSpointer_class_id,
                           obj_osnum = lift_os,
                           osnum = lift_os,
                           p_objid = &ptr_id);
    if (!(1 & OM_stat)) goto wrapup;

    tmp_grid.objid = creator_id;

    OM_stat = om$send(msg = message EMSpointer.EMinit(EMmsg, NULL,
                                    &tmp_grid, NULL, surf_to_lift_id),
                      senderid = NULL_OBJID,
                      targetid = ptr_id,
                      targetos = lift_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      

    tmp_grid.objid = ptr_id;
  }
  else 
  {
    /*See if the surface to lift is associative. If not transform it*/
    if (!EFisAncestryValid(EMmsg, surf_to_lift_id, lift_os,
                           OPP_NDnode_class_id, FALSE))
    {
      OM_stat = om$send(msg = message EMSsurface.EMtransform_to_associative
                                      (EMmsg, &surf_to_lift_id),
                        senderid = NULL_OBJID,
                        targetid = surf_to_lift_id,
                        targetos = lift_os);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    tmp_grid.objid = surf_to_lift_id;
  }

  OM_stat = om$send(msg = message Root.range_disconnect(to_father,
                                  LIFT_SF_INX, LIFT_SF_INX),
                    senderid = NULL_OBJID,
                    targetid = lift_id,
                    targetos = lift_os);
  if (!(1 & OM_stat)) goto wrapup;

  /*Should use NDconnect but need to connect on a specific index of lift_id
   * so I will use Root.connect
   */
  OM_stat = om$send(msg = message Root.connect(to_father, 0, 
                                       tmp_grid.objid, lift_os,
                                       to_children, LIFT_SF_INX),
                    senderid = NULL_OBJID,
                    targetid = lift_id,
                    targetos = lift_os);
  if (!(1 & OM_stat)) goto wrapup;                      

  {/*INTENTIONAL*/
    IGRint      comp_type;
    struct GRid lift_grid;

    comp_type = ND_COMP;
 
    lift_grid.objid = lift_id;
    lift_grid.osnum = lift_os;

    nd$wait_batch(type = GR_GEOM_POSTED,
                  nb_obj = 1,
                  l_object = &lift_grid,
                  l_obj_info = &comp_type);

    /*Compute if not deferred.*/
    nd$exec_batch();
  }
  
wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFtoggle_lift_to_other_surf")
  return(OM_stat);
}

end implementation EMSsfdlift;
