/* ###################   APOGEE COMPILED   ################## */
class implementation EMAgenbs;

#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include "REgencompsf.h"

extern OMuword OPP_EMSgencompsf_class_id;

IGRint EFblend_3_or_more_curves (EMmsg, options, number_of_curves,
                                 cvinfo, sfinfo, dist_par, center_point,
                                 normal_vector, construct_list,
                                 constructed_object)
IGRlong *EMmsg;
IGRuint options;
IGRint number_of_curves;
struct GRlc_info *cvinfo[];
struct GRlc_info *sfinfo[];
struct EMSvalue_info *dist_par;
IGRpoint center_point;
IGRvector normal_vector;
struct GRvg_construct *construct_list;
OM_S_OBJID *constructed_object;
{
 OMuword constros;
 unsigned char type;
 IGRchar *save_geom_ptr;
 IGRlong status;
 IGRint nb_root, i;
 struct EMSobject_info *list = NULL;
 struct EMSblend_curve_surface_ret_info *more_info = NULL;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 list = (struct EMSobject_info *)stackalloc( 
          sizeof(struct EMSobject_info) * (2 * number_of_curves + 1));
 EMerr_hndlr(!list, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);
 
 constros = construct_list->env_info->md_id.osnum;

 status = EMgetparval_object (EMmsg, constros, NULL, dist_par,
               &list[0]);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 nb_root = 1;

 for (i=0;i<number_of_curves;i++)
 {
  list[nb_root].grid = cvinfo[i]->located_obj;
  list[nb_root].env = cvinfo[i]->module_info;
  nb_root++;
  if (sfinfo[i])
  {
   list[nb_root].grid = sfinfo[i]->located_obj;
   list[nb_root].env = sfinfo[i]->module_info;
   nb_root++;
  }
 }

/*
 * Use the geometry pointer in construct_list to return information
 * about center point and the normal vector. Since this is something
 * which is non-standard, I decided not to add an argument to
 * EMinit_associative and EMconstruct_associative and makedo with
 * the existing arguments.
 */

 type = EMS_ASblend_curve_surface;
 save_geom_ptr = construct_list->geometry; 
 status = om$construct(classid = OPP_EMSgencompsf_class_id,
                       p_objid = constructed_object,
                       osnum = constros);
 if (1 & status)
 {
   extern OM_S_OBJID current_creator;
   current_creator = *constructed_object;
   status = om$send(msg = message EMSassoc.EMinit_associative(EMmsg,
                          NULL, nb_root, list, type,0,NULL,
                          construct_list),
                    senderid = NULL_OBJID,
                    targetid = *constructed_object,
                    targetos = constros);
   current_creator = NULL_OBJID;
 }                    
 if (construct_list->geometry)
 {
  more_info = (struct EMSblend_curve_surface_ret_info *) construct_list->
              geometry;
  OM_BLOCK_MOVE(more_info->center_point, center_point , sizeof (IGRpoint));
  OM_BLOCK_MOVE(more_info->normal_vector,normal_vector, sizeof (IGRvector));
 }
 construct_list->geometry = save_geom_ptr;
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (options & EMSasconst_notassociative)
 {
  struct GRid src_GRid;

  src_GRid.objid = NULL_OBJID;
  status = om$send (msg = message NDnode.NDmove_to_root(EMmsg,
                               &src_GRid,construct_list->env_info),
                    senderid = *constructed_object,
                    targetid = *constructed_object,
                    targetos = constros);
  if (1&status&*EMmsg)
   *constructed_object = src_GRid.objid;
  else
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }
 }
                      
wrapup:
 if (!(1&status&*EMmsg))
 {
  IGRlong cln_sts, cln_msg;

  if (*constructed_object != NULL_OBJID)
  {
   cln_sts = om$send (msg = message GRgraphics.GRdelete(&cln_msg,
                            construct_list->env_info),
                      senderid = NULL_OBJID,
                      targetid = *constructed_object,
                      targetos = constros);
  }
 }
 if (list) stackfree (list);
 if (more_info) free (more_info);
 EMWRAPUP (*EMmsg, status, "In EFblend_3_or_4_curves error");
 return (status);
}
end implementation EMAgenbs;

