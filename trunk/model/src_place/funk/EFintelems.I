class implementation EMSagrp;

#include "emssfintdef.h"
#include "bserr.h"
#include "bsparameters.h"

extern OMuword OPP_EMSsurface_class_id;
from EMSsurface import EMgetactiveid;

IGRlong EFassociative_intersect_elements(EMmsg, options, trimming_required,
        elem1_info, elem2_info, construct_list, res_id)
IGRlong *EMmsg;
unsigned int options;
IGRboolean trimming_required;
struct GRlc_info *elem1_info;
struct GRlc_info *elem2_info;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 OMuword constros;
 IGRlong status;

 *EMmsg = EMS_S_Success;
 *res_id = NULL_OBJID;
 constros = construct_list->env_info->md_id.osnum;

 if (options & EMSasconst_notassociative)
 {
   IGRushort trimming_options;
   IGRlong            number_of_objects;
   extern	      IGRlong EMintersect_two_element();
   struct             GRid *ids;

   number_of_objects = 0;
   ids = NULL;
   trimming_options = EMSINT_TRIM_HANDLESTOP | 
                       (trimming_required ?
                        EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
                         EMSINT_TRIM_COPLANAR | EMSINT_TRIM_PROCOVERLAP :
                        NULL);
    status = EMintersect_two_element(
           elem1_info,
           elem2_info,
           trimming_options,
           construct_list,
           &number_of_objects,
           &ids,
           EMmsg);
    if (! (1 & status)) goto wrapup;
    if (*EMmsg == EMS_I_Interrupt)
    {
     goto wrapup;
    }
    else if (number_of_objects && ids)
    {
     if (number_of_objects == 1)
      *res_id = ids[0].objid;
     else
     {
       status = EFbuild_graphic_group(
          number_of_objects,
          NULL,
          ids,
          construct_list,
          res_id,
          EMmsg);
     }
     free(ids);
    } /* if (number_of_objects && objects) */

    if (!number_of_objects)
    {
     *EMmsg = EMS_I_NoSolution;
    }
  }
 else
 {
  IGRint rc,type,num_parents, comp_count;
  struct GRid active_state_GRid;
  struct EMSobject_info list[4];
  struct EMSintersect_elements info;
  OM_S_CHANSELECT to_comps;

  BSEXTRACTPAR(&rc, BSTOLCHRDHT, info.cht);
/*
 * The first object in the parent list is the first element that is being
 * intersected. It is followed by the active id of the first element if 
 * the first element is a surface.
 * And the same goes for second element.
 */

  if (trimming_required)
   info.props = EMS_TRIMMING_REQUIRED;

  list[0].grid = elem1_info->located_obj;
  list[0].env = elem1_info->module_info;
  num_parents = 1;

  if (EFisAncestryValid(EMmsg, list[0].grid.objid, list[0].grid.osnum,
                        OPP_EMSsurface_class_id, FALSE))
  {
   status = om$send (msg = message EMSsurface.EMgetactiveid(EMmsg,
                           &active_state_GRid,NULL),
                     senderid = NULL_OBJID,
                     targetid = list[0].grid.objid,
                     targetos = list[0].grid.osnum);
   if (!(1&status&*EMmsg)) goto wrapup;

   list[1].grid = active_state_GRid;
   list[1].env = elem1_info->module_info;
   ++num_parents;
  }

  list[num_parents].grid = elem2_info->located_obj;
  list[num_parents].env = elem2_info->module_info;
  ++num_parents;

  if (EFisAncestryValid(EMmsg, list[num_parents-1].grid.objid, 
                               list[num_parents-1].grid.osnum,
                        OPP_EMSsurface_class_id, FALSE))
  {
   status = om$send (msg = message EMSsurface.EMgetactiveid(EMmsg,
                           &active_state_GRid,NULL),
                     senderid = NULL_OBJID,
                     targetid = list[num_parents-1].grid.objid,
                     targetos = list[num_parents-1].grid.osnum);
   if (!(1&status&*EMmsg)) goto wrapup;

   list[num_parents].grid = active_state_GRid;
   list[num_parents].env = elem2_info->module_info;
   ++num_parents;
  }

  status = om$construct(classid = OPP_EMSagrp_class_id,
                       p_objid = res_id,
                       msg = message EMSassoc.EMinit_associative(EMmsg,
                            NULL, num_parents, list, EMS_ASintersect_elements1,
                             sizeof (struct EMSintersect_elements),
                             (IGRchar *)&info,
                             construct_list),
                       osnum = constros);
  if (*EMmsg == EMS_I_Interrupt)
  {
   om$send (msg = message Root.delete(1),
            senderid = NULL_OBJID,
            targetid = *res_id,
            targetos = constros);
   *res_id = NULL_OBJID;
   goto wrapup;
  }
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  EMmake_chanselect(GRcmpowner_to_components,&to_comps);

  status = om$get_channel_count(objid = *res_id,
                                osnum = constros,
                                p_chanselect = &to_comps,
                                count = (OMuint *)&comp_count);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
  if (comp_count == 0)
  {
    *EMmsg = EMS_I_NoSolution;
  }
 }

wrapup:
 if (!(1&status&*EMmsg) && (*res_id != NULL_OBJID))
 {
  om$send (msg = message Root.delete(1),
            senderid = NULL_OBJID,
            targetid = *res_id,
            targetos = constros);
 }

 EMWRAPUP (*EMmsg, status, "In EMassociative_intersect_elements error");
 return (status);

}
end implementation EMSagrp;

