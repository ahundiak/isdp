class implementation EMSassoc;

#include "EMSopt.h"
#include "EMSasmacros.h"
#include "OMmacros.h"

from EMSsubbs import EMproject_curve_onto_surface;
extern OMuword OPP_EMSagrp_class_id;

/*
 * The following definitions are used for the purpose of recomputing
 * the projected curve.
 */

#define EMS_TRIMMING_NOT_REQUIRED 0x1

IGRint EFproject_curve(EMmsg, options, old_objid, new_objid,num_parents,
                     parent_info, recomp_info, construct_list, mod_new_id)
IGRlong *EMmsg;
IGRuint options;
GRobjid old_objid;
GRobjid new_objid;
IGRint num_parents;
IGRchar *parent_info;
IGRchar *recomp_info;
struct GRvg_construct *construct_list;
GRobjid *mod_new_id;
/*
  Description
  This is the recomputation/placement function that implements the associative
  projection of a curve onto a surface. This is intially called during
  during placement and whenever any of the parents that are listed
  get modified.

  Arguments
   These are standard for any recomputation/placement function.

  Notes
   Upon exit the completion code will be one of the following:
   EMS_S_Success : If all goes well
   EMS_E_Fail    : If there is failure of sorts.

  WARNING
   The name of this function should not change ever since the same is stored
   in the instance data of objects. If we have to change the name of the object
   then we need to provide a conversion mechanism to the new name.

  History:
    Creation : PP : 10/25/93
 ********************************************************************** */
{
 OMuword constros;
 IGRlong status;
 IGRlong i;
 IGRshort mattyp;
 IGRdouble *matrix;
 union EMSparent_info *roots = NULL;
 IGRuint root_count;
 IGRuint root_type[4];
 IGRlong num_obj;
 OM_S_OBJID *obj = NULL;
 IGRboolean trimming_required;
 struct GRid new_GRid;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 constros = construct_list->env_info->md_id.osnum;
 root_count = num_parents;
 new_GRid.objid = new_objid;
 new_GRid.osnum = constros;

 roots = (union EMSparent_info *)stackalloc(root_count*
         sizeof(union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

 if (root_count > 3)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 root_type[0] = EMSlcinfo;
 root_type[1] = EMSlcinfo;
 root_type[2] = EMSvector;

/*
 * Message which gets the real parents of the object.
 */

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
                   root_count, parent_info, root_type,roots),
                   senderid = new_objid,
                   targetid = new_objid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

 mattyp = construct_list->env_info->md_env.matrix_type;
 matrix = construct_list->env_info->md_env.matrix;


 if (recomp_info[0] & EMS_TRIMMING_NOT_REQUIRED)
  trimming_required = 0;
 else
  trimming_required = 1;

 status = om$send (msg = message EMSsubbs.EMproject_curve_onto_surface(
                         &roots[0].lc_info, &roots[1].lc_info,
                         construct_list, roots[2].vector, FALSE,
                         trimming_required, &num_obj, &obj, EMmsg),
                   senderid = new_objid,
                   targetos = roots[1].lc_info.located_obj.osnum,
                   targetid = roots[1].lc_info.located_obj.objid);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (!EFisAncestryValid(EMmsg, new_objid,constros, OPP_EMSagrp_class_id,
     FALSE))
 {
  status = om$change_class (objid = new_objid,
                            osnum = construct_list->env_info->md_id.osnum,
                            classname = "EMSagrp");
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 }

 for (i=0;i<num_obj;i++)
 {
  status = om$send (msg = message GRconnector.GRrigidconn(EMmsg,
                    &new_GRid, &i),
           senderid = new_GRid.objid,
           targetid = obj[i]);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

 *mod_new_id = new_GRid.objid;
wrapup:

 if (obj) om$dealloc (ptr = obj);

 if (!(1&status&*EMmsg))
 {
  IGRlong l_msg;
  if (num_obj && obj)
  {
   for (i=0;i<num_obj;i++)
   {
    om$send (msg = message GRgraphics.GRdelete(&l_msg,
             construct_list->env_info),
             senderid = NULL_OBJID,
             targetid = obj[i]);

    om$send ( msg = message Root.delete(1),
             senderid = NULL_OBJID,
             targetid = new_GRid.objid);
   }
  }
  
 }
 if (!(1&status&*EMmsg)) *mod_new_id = NULL_OBJID;
 return (status);
}

IGRlong EFproject_curve_along_vector_onto_surface(EMmsg, options, 
                                curve_info,
                                surf_info,
                                vector,
                                trimming_required,
                                construct_list, res_id)
IGRlong *EMmsg;
unsigned int options;
struct GRlc_info *curve_info;
struct GRlc_info *surf_info;
IGRvector vector;
IGRboolean trimming_required;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 OMuword constros;
 IGRlong msg_loc;
 IGRint num_parents;
 IGRdouble *mat;
 IGRshort mattyp;
 IGRlong status;
 IGRchar recomp_info=0;
 struct EMSobject_info list[4];
 struct EMSvector_info  direction;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 *res_id = NULL_OBJID;

 num_parents = 3;

 list[0].grid = curve_info->located_obj;
 list[0].env = curve_info->module_info;
 list[1].grid = surf_info->located_obj;
 list[2].env = surf_info->module_info;
 direction.type = EMSdatainfo_numeric;
 OM_BLOCK_MOVE (vector, direction.vec, sizeof (IGRvector));
 BSnorvec (&msg_loc, direction.vec);

 mattyp = construct_list->env_info->md_env.matrix_type;
 mat = construct_list->env_info->md_env.matrix;

 constros = construct_list->env_info->md_id.osnum;

 status = EMgetparvec_object (&msg_loc, mattyp, mat, constros, &direction,
                   &list[3]);
 EMerr_hndlr(!(1&msg_loc&status), *EMmsg, EMS_E_Fail, wrapup);

 if (!trimming_required)
  recomp_info = EMS_TRIMMING_NOT_REQUIRED;
 else
  recomp_info = 0;


 status = ems$associative_element_by_function(msg = EMmsg,
                associative = (options & EMSasconst_notassociative ? FALSE : 
                               TRUE),
                num_parents = num_parents,
                parents = list,
                info_size = sizeof (IGRchar),
                info = &recomp_info,
                function_name = "EFproject_curve",
                construct_list = construct_list,
                created_id = res_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, *EMmsg, wrapup);


wrapup:
 return (status);
}
end implementation EMSassoc;

