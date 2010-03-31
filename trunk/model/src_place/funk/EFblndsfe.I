class implementation EMAgenbs;

/*
  HISTORY

	Sudha	06/30/93	Modified for BSprototypes ansification

*/

#include "bsconic.h" /* For BSULEFTBND ... */
#include "bserr.h"   /* For BSERROR */
#include "bssfeval1.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsfndspnarr.h"
#include "bsdotp.h"

IGRint EFplace_blend_surface_exterior(EMmsg, options, 
                                      surf1,
                                      side_1, 
                                      is_side_1_reversed,
                                      blend_direction_1,
                                      surf2,
                                      side_2, 
                                      is_side_2_reversed,
                                      blend_direction_2,
                                      construct_list,
                                      constructed_object)
IGRlong *EMmsg;
unsigned int options;
struct GRlc_info *surf1;
IGRint side_1;
IGRboolean is_side_1_reversed;
IGRpoint blend_direction_1;
struct GRlc_info *surf2;
IGRint side_2;
IGRboolean is_side_2_reversed;
IGRpoint blend_direction_2;
struct GRvg_construct *construct_list;
OM_S_OBJID *constructed_object;

/*
 Abstract

 This method constructs a surface which blends 2 existing surfaces
 along interior curves lying on the surfaces. The constructed object
 is returned in *constructed_object field.

 Arguments

  EMmsg : Completion code.
  Options : Currently can be set to EMSasconst_notassociative if a
            a non-associative blend surface exterior surface is needed.
  surf1
   Locate information for surface 1.
  side_1
   A number representing which side of the surface 1 is to be blended.
   The symbolic names are BSULEFTBND, BSVLEFTBND, BSURIGHTBND, BSVRIGHTBND
   as defined in the math include file "bsconic.h".
  is_side_1_reversed
   Is side_1 reversed?
   This is used in order to prevent twisting of the blending surface.
  blend_direction_1
   A point which determines in which direction the blend will proceed in
   as it leaves surface_1.  Basically it either moves with the natural
   tangent direction or opposite.
  surf2
   Locate information for surface 2.
  side_2
   A number representing which side of the surface 2 is to be blended.
   The symbolic names are BSULEFTBND, BSVLEFTBND, BSURIGHTBND, BSVRIGHTBND
   as defined in the math include file "bsconic.h".
  is_side_2_reversed
   Is side_2 reversed?
   This is used in order to prevent twisting of the blending surface.
  blend_direction_2
   A point which determines in which direction the blend will proceed in
   as it leaves surface_2.  Basically it either moves with the natural
   tangent direction or opposite.
  construct_list
   Standard construction list.
*/
{
 IGRboolean is_blend_reversed;
 IGRlong status;
 IGRint msg_loc, type;
 OMuword constros;
 struct EMSblend_surface_exterior blnd_info;
 struct EMSobject_info list[2];
 blnd_info.props = 0;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 *constructed_object = NULL_OBJID;
 if (is_side_1_reversed)
   blnd_info.props |= EMS_SURF1_REVERSED;
 if (is_side_2_reversed)
   blnd_info.props |= EMS_SURF2_REVERSED;

 blnd_info.side_1 = side_1;
 blnd_info.side_2 = side_2;

 EFret_blend_dirinfo(&msg_loc, 
                     EMS_OPT_RET_BLEND_REV_INFO,
                     side_1,
                     blend_direction_1, 
                     &is_blend_reversed,
                     surf1); 
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 
 if (is_blend_reversed)
  blnd_info.props |= EMS_BLEND1_REVERSED;

 EFret_blend_dirinfo(&msg_loc, 
                     EMS_OPT_RET_BLEND_REV_INFO,
                     side_2,
                     blend_direction_2,
                     &is_blend_reversed,
                     surf2); 
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 if (is_blend_reversed)
  blnd_info.props |= EMS_BLEND2_REVERSED;

 list[0].grid = surf1->located_obj;
 list[0].env = surf1->module_info;
 list[1].grid = surf2->located_obj;
 list[1].env = surf2->module_info;
 
 type = EMS_ASblend_exterior;
 constros = construct_list->env_info->md_id.osnum;

 status = om$construct(classid = OPP_EMAgenbs_class_id,
                       msg = message EMSassoc.EMinit_associative(EMmsg,
                             NULL, 2, list, type,
                             sizeof (struct EMSblend_surface_exterior),
                             (IGRchar *) &blnd_info,
                             construct_list),
                       p_objid = constructed_object,
                       osnum = constros);
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
   *constructed_object = NULL_OBJID;
  }
  
 }
 EMWRAPUP (*EMmsg,status, "In EFplace_blend_surface_exterior error");
 return (status);
}

IGRint EFret_blend_dirinfo (EMmsg, options, side, blend_direction_point, 
                            is_blend_reversed, surf)
IGRlong *EMmsg; /* Completion code */
unsigned int options; /* Currently if set to 
                         EMS_OPT_RET_BLEND_POINT :A blend direction 
                         point is computed and returned based on the
                         blend reversal info 
                         EMS_OPT_RET_BLEND_REV_INFO: The blend reversal
                         info is computed and returned based on the blend
                         direction point */
IGRint side;    /* Boundary where the blend is taking place */
IGRpoint blend_direction_point; /* Blend direction point */
IGRboolean *is_blend_reversed;  /* Is blend reversed */
struct GRlc_info *surf;         /* GRlc info of the surface */
{
  IGRboolean bssts;
  IGRlong rc, status;
  IGRshort ubound;
  IGRdouble par1, par2;
  IGRpoint  result[2][2];
  IGRdouble *eval_pt, *eval_tangent;
  IGRint uspn, vspn;
  struct IGRbsp_surface *surf_ptr;
  struct GRmdenv_info *mdenv_info;
  IGRchar *char_ptr;

  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  mdenv_info = &surf->module_info.md_env;
  status = om$send(
   msg = message GRvg.GRgenabsg(
     EMmsg,
    &mdenv_info->matrix_type,
     mdenv_info->matrix,
    &char_ptr),
   senderid = NULL_OBJID,
   targetid = surf->located_obj.objid,
   targetos = surf->located_obj.osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

  surf_ptr = (struct IGRbsp_surface *) char_ptr;
  ubound = 0;
  eval_pt = result[0][0];

  if(side == BSULEFTBND)
  {
    ubound = TRUE;
    par1 = surf_ptr->u_knots[surf_ptr->u_order - 1];
    par2 = 0.5;
    eval_tangent = result[0][1];
  }
  else if(side == BSURIGHTBND)
  {
    ubound = TRUE;
    par1 = surf_ptr->u_knots[surf_ptr->u_num_poles];
    par2 = 0.5;
    eval_tangent = result[0][1];
  }
  else if(side == BSVLEFTBND)
  {
    par1 = 0.5;
    par2 = surf_ptr->v_knots[surf_ptr->v_order - 1];
    eval_tangent = result[1][0];
  }
  else if(side == BSVRIGHTBND)
  {
    par1 = 0.5;
    par2 = surf_ptr->v_knots[surf_ptr->v_num_poles];
    eval_tangent = result[1][0];
  }

  BSfndspnarr(surf_ptr->u_order, surf_ptr->u_num_poles,
              1, &par1, surf_ptr->u_knots, &uspn, &rc);
  EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

  BSfndspnarr(surf_ptr->v_order, surf_ptr->v_num_poles,
              1, &par2, surf_ptr->v_knots, &vspn, &rc);
  EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

  BSsfeval1(surf_ptr, par1, par2, uspn, vspn, result, &rc);
  EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

  bssts = BSnorvec(&rc, eval_tangent);
 
  if (options & EMS_OPT_RET_BLEND_REV_INFO)
  {
   IGRvector dir_vec;
   IGRdouble dotp;

   bssts = BSmkvec(&rc, dir_vec, eval_pt, blend_direction_point);
   bssts = BSnorvec(&rc, dir_vec);
   dotp = BSdotp(&rc, eval_tangent, dir_vec);
   if (dotp > 0.0) *is_blend_reversed = 0; 
    else *is_blend_reversed = 1;
  }
  else if (options & EMS_OPT_RET_BLEND_POINT)
  {
   IGRint reversed,i;
   if (*is_blend_reversed)
    reversed = -1;
   else
    reversed = 1;

   for (i=0;i<3;i++)
    blend_direction_point[i] = eval_pt[i] + eval_tangent[i]*reversed;
  }

wrapup:
 EMWRAPUP (*EMmsg, status, "IN EFret_blend_dir_info error");
 return (status);
}

end implementation EMAgenbs;

