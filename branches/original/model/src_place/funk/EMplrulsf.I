class implementation EMAgenbs;

/*
  HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification

 *
 * This function shall create an associative/non-associative ruled surface
 * object.
 */

#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include "bserr.h"    /* For BSERROR */
#include "bsprptsoncv.h"

IGRint EFplace_ruled_surface(EMmsg, options, cv1info, cv2info,
                             ruled_surface_type, num_cp,
                             curve1_cp, curve2_cp, construct_list,
                             constr_obj)
IGRlong *EMmsg;
IGRuint options;   /* Ubiquitous options field */
struct GRlc_info *cv1info; /* Information about first curve */
struct GRlc_info *cv2info; /* Information about second curve */
IGRlong ruled_surface_type; /* Type of ruled surface to be created 
                               0 - Default
                               1 - Arc length
                               2 - Developable */
IGRint num_cp; /* Number of control points */
IGRdouble *curve1_cp; /* Control points for the first curve */
IGRdouble *curve2_cp; /* Control points for the second curve */
struct GRvg_construct *construct_list; /* Constrution information */
OM_S_OBJID *constr_obj;
{
 unsigned char assoc_type;
 IGRchar *abs_geom = NULL;
 IGRboolean all_on_curve;
 OMuword constros;
 IGRlong status, rc;
 IGRint rlsf_size;
 IGRdouble *param_cv = NULL;
 struct IGRbsp_curve *cv;
 struct GRmdenv_info *cv1env = NULL, *cv2env = NULL;
 struct EMSruled_surface *rlsf = NULL;
 struct EMSobject_info cvinfo[2];
 extern IGRlong EMgetabsg();
 

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 *constr_obj = NULL_OBJID;

 cv1env = &cv1info->module_info.md_env;
 cv2env = &cv2info->module_info.md_env;
 constros = construct_list->env_info->md_id.osnum;

 switch (ruled_surface_type)
 {
  case 0:
   assoc_type = EMS_ASdefault_ruled_surface;
  break;

  case 1:
   assoc_type = EMS_ASarclength_ruled_surface;
  break;

  case 2:
   assoc_type = EMS_ASdevelopable_ruled_surface;
  break;

  default:
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }
 }

 rlsf_size = sizeof(struct EMSruled_surface) + 2*num_cp*sizeof(IGRdouble) -
             sizeof (IGRchar);
 rlsf = (struct EMSruled_surface *) stackalloc(rlsf_size);
 EMerr_hndlr(!rlsf, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 param_cv = (IGRdouble *) stackalloc(num_cp*sizeof(IGRdouble));
 EMerr_hndlr(!param_cv, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 
 rlsf->num_cp = num_cp;
 rlsf->rlsf_props = 0;
 if (cv1info->geom_parms.polygon_inx)
  rlsf->rlsf_props |= EMS_FIRST_CURVE_REVERSED;

 if (cv2info->geom_parms.polygon_inx)
  rlsf->rlsf_props |= EMS_SECOND_CURVE_REVERSED;


 status = EMgetabsg(EMmsg, &cv1env->matrix_type, cv1env->matrix,
                    cv1info->located_obj.osnum,
                    cv1info->located_obj.objid,
                    &abs_geom);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_DynamicMemoryAllocated,
             wrapup);
 cv = (struct IGRbsp_curve *) abs_geom;

 BSprptsoncv(num_cp, (IGRpoint *)curve1_cp, cv, param_cv, &all_on_curve, &rc);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

 OM_BLOCK_MOVE((IGRchar *)param_cv, &rlsf->chardata[0], 
               sizeof(IGRdouble)*num_cp);
 abs_geom = NULL;
 status = EMgetabsg(EMmsg, &cv2env->matrix_type, cv2env->matrix,
                    cv2info->located_obj.osnum,
                    cv2info->located_obj.objid,
                    &abs_geom);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_DynamicMemoryAllocated,
             wrapup);
 cv = (struct IGRbsp_curve *) abs_geom;

 BSprptsoncv(num_cp, (IGRpoint *)curve2_cp, cv, param_cv, &all_on_curve, &rc);
 EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

 OM_BLOCK_MOVE((IGRchar *) param_cv, 
               &rlsf->chardata[num_cp*sizeof(IGRdouble)], 
               sizeof(IGRdouble)*num_cp);

 cvinfo[0].grid = cv1info->located_obj;
 cvinfo[0].env = cv1info->module_info;
 cvinfo[1].grid = cv2info->located_obj;
 cvinfo[1].env = cv2info->module_info;

 status = om$construct(classid = OPP_EMAgenbs_class_id,
                       msg = message EMSassoc.EMinit_associative(EMmsg,
                             NULL, 2, cvinfo, assoc_type,rlsf_size,
                             (IGRchar *) rlsf,
                             construct_list),
                       p_objid = constr_obj,
                       osnum = constros);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (options & EMSasconst_notassociative)
 {
  struct GRid src_GRid;

  src_GRid.objid = NULL_OBJID;
  status = om$send (msg = message NDnode.NDmove_to_root(EMmsg,
                               &src_GRid,construct_list->env_info),
                    senderid = *constr_obj,
                    targetid = *constr_obj,
                    targetos = constros);
  if (1&status&*EMmsg)
   *constr_obj = src_GRid.objid;
  else
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }
 }

wrapup:
 if (rlsf) stackfree (rlsf);
 if (!(1&status&*EMmsg))
 {
  IGRlong cln_sts, cln_msg;

  if (*constr_obj != NULL_OBJID)
  {
   cln_sts = om$send (msg = message GRgraphics.GRdelete(&cln_msg,
                            construct_list->env_info),
                      senderid = NULL_OBJID,
                      targetid = *constr_obj,
                      targetos = constros);
  }
 }
 EMWRAPUP (*EMmsg, status, "In EFplace_ruled_surface error");
 return (status);
}

end implementation EMAgenbs;

