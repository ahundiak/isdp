/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h" /* For shared libraries */

%safe
#include <math.h>
%endsafe

#include "emsdattyp.h" /* For EMSdata_select */
#include "bserr.h" /* For math error definitions */
#include "bsparameters.h" /* For BS math errors */
#include "ems_m_inc.h" /* Includes everything */
#include "bsfreecv.h"
#include "bsalloccv.h"

#define BUFF 30 

extern OMuword OPP_GRcompcurve_class_id, OPP_GRbspline_curve_class_id;
extern OMuword OPP_GR3dlineseg_class_id, OPP_GR3dpoint_class_id,
               OPP_GRbcsubbc_class_id;

from GRbspline import EMgetbcdef;
from GRcompcurve import EMaddtocomp,EMmakecomp;
from GRowner import GRget_number_components,GRget_components;

IGRlong EFproject_any_curve_on_planen(msg,construct_list, curve, curve_env,
        pln,projection_vector,output_curve,out_classid)

IGRlong *msg;
struct GRvg_construct *construct_list;
struct GRid *curve;
struct GRmd_env *curve_env;
struct IGRplane *pln;
IGRvector projection_vector;
struct GRid *output_curve;
OMuword *out_classid;

/* **************************************************************************
Description

 This function projects the given curve on the plane along the
 projection vector and returns a new object. The element can either be
 a simple curve or a composite curve.

Arguments
 Input
  construct_list : construction information for the output curve.
  curve : GRid of the curve which has to be projected onto the plane.
  curve_env : environment of the curve.
  plane : The plane on which the curve is projected.
  projection_vector: Vector used for projection

 Output
  output_curve: GRid of the construced object on the plane.
  msg : completion code

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.
 MANOSOLUTION: If no solution was found
 EMS_E_InvalidArg : Probably bad data.
 EMS_E_BSerror: Math error
 EMS_E_OMerror : Error in calling an OM primitive 
 EMS_E_Fail : General failure

History
            PP : 08/08/89	Creation.
            NP : 08/27/92	Modified for ANSI compliance.
	    Sudha 7/06/93	Modified for BSprototypes ansification

***************************************************************************** */
{
 IGRlong loc_msg, sts;
 IGRint count,i;
 IGRdouble dist_tol,cht;
 IGRchar *cv_geom = NULL;
 struct GRid o_ids_buff[BUFF];
 struct GRid *o_ids_ptr = NULL;
 struct GRid work_GRid;
 struct GRlc_info stupid_info;
 OMuword curve_classid;
 OMuword work_classid;
 struct IGRbsp_curve *output_geom = NULL,*comp_curve = NULL,
                     *output_comp_geom = NULL;

 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 BSEXTRACTPAR (&loc_msg, BSTOLLENVEC, dist_tol);
 BSEXTRACTPAR(&loc_msg,BSTOLCHRDHT,cht);
 output_curve->objid = NULL_OBJID;

 sts = om$get_classid (objid = curve->objid,
                       osnum = curve->osnum,
                       p_classid = &curve_classid);
 EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrapup);

 stupid_info.proj_pnt[0] = 0.0;
 stupid_info.proj_pnt[1] = 0.0;
 stupid_info.proj_pnt[2] = 0.0;
 stupid_info.geom_parms.u = 0.0;
 stupid_info.geom_parms.v = 0.0;
 stupid_info.geom_parms.polygon_inx = 3;
 stupid_info.geom_parms.leaf_id.objid = NULL_OBJID;
 stupid_info.geom_parms.leaf_id.osnum = 0;

 output_curve->osnum = construct_list->env_info->md_id.osnum;

 sts = om$is_ancestry_valid(subclassid = curve_classid,
                            superclassid = OPP_GRcompcurve_class_id);
 if (sts == OM_I_INVANCESTRY) /* Assumed to be a simple curve */
 {
  struct IGRbsp_curve dummy;
  OMuword temp_classid,*classid_ptr;

  sts = om$send (msg = message GRbspline.EMgetbcdef(msg,&dummy),
                 senderid = NULL_OBJID,
                 targetid = curve->objid,
                 targetos = curve->osnum);
  EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, wrapup);

  BSalloccv(dummy.order,dummy.num_poles,dummy.rational,0,&output_geom,
            &loc_msg);
  EMerr_hndlr((loc_msg != 0), *msg, EMS_E_BSerror, wrapup);

  stupid_info.located_obj = *curve;
  stupid_info.module_info = *curve_env;

  if (out_classid) classid_ptr = out_classid;
  else classid_ptr = &temp_classid;

  EFproject_curve_onto_plane(&stupid_info,NULL,curve_classid,
    pln,
    projection_vector,
    NULL_OBJID,output_geom,classid_ptr,msg);
  if (*msg == MANOSOLUTION)
  {
   goto wrapup;
  }
  else if (!(1&*msg))
  {
   *msg = EMS_E_Fail;
   goto wrapup;

  }
    EFconstruct_curve(msg,output_geom,construct_list,*classid_ptr,
                      output_curve);
    EMerr_hndlr(!(1&*msg),*msg, EMS_E_Fail,wrapup);
 }
 else if (sts == OM_S_SUCCESS)
 {
  IGRint returned_count;
  IGRlong rotten,comp_so_far=1;
  IGRpoint comp_start,comp_end;
  enum EMSdatatype type;
  OMuword inclassid;
/*
 * See if projecting this composite curve will cause some degenerate condition.
 */
    EMgetvggeom(msg, &curve_env->md_env.matrix_type, curve_env->md_env.matrix,
                curve, &cv_geom, &type);
    EMerr_hndlr(!(1&*msg), *msg, EMS_E_Fail, wrapup);

    EMerr_hndlr((type != EMSdata_curve3d), *msg, EMS_E_InvalidArg, wrapup);

    comp_curve = (struct IGRbsp_curve *)cv_geom;

    BSalloccv(comp_curve->order,comp_curve->num_poles,
              comp_curve->rational,0,&output_comp_geom,
              &loc_msg);
    EMerr_hndlr((loc_msg != 0), *msg, EMS_E_BSerror, wrapup);

    inclassid = OPP_GRbcsubbc_class_id;

    EFproject_curve_onto_plane(NULL,comp_curve,inclassid,pln,
      projection_vector,NULL_OBJID,output_comp_geom,&work_classid,&loc_msg);
    if (*msg == MANOSOLUTION)
     goto wrapup;
    else if (!(1&*msg))
    {
     *msg = EMS_E_Fail;
     goto wrapup;
    }

    if ((work_classid == OPP_GR3dlineseg_class_id) || 
         (work_classid == OPP_GR3dpoint_class_id))
    {
      EFconstruct_curve(msg,output_comp_geom,construct_list,work_classid,
                         output_curve);
      EMerr_hndlr(!(1&*msg),*msg, EMS_E_Fail,wrapup);
      goto wrapup;
    }

    sts = om$send (msg = message GRowner.GRget_number_components(msg, &count),
                   senderid = NULL_OBJID,
                   targetid = curve->objid,
                   targetos = curve->osnum);
    EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrapup);

    if (count > BUFF)
    {
     o_ids_ptr = (struct GRid *) om$malloc(size = sizeof(struct GRid) * count);
     EMerr_hndlr(!o_ids_ptr, *msg, EMS_E_DynamicMemoryAllocated,wrapup);
    }
    else
     o_ids_ptr = o_ids_buff;

    sts = om$send (msg = message GRowner.GRget_components(msg,
                         curve_env,o_ids_ptr,count,&returned_count,0,
                         MAXINT),
                   senderid = NULL_OBJID,
                   targetid = curve->objid,
                   targetos = curve->osnum);
    EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrapup);

    for (i = 0 ;i < count;i++)
    {
      EFproject_any_curve_on_planen(msg,construct_list,&o_ids_ptr[i],
       curve_env,pln,projection_vector,&work_GRid,&work_classid);
      EMerr_hndlr(!(1&*msg), *msg, *msg, wrapup);

/*
 * Should the projected components be points then ignore the same as 
 * continuity would be assured by the preceding and succeeding components.
 */
      if (work_classid == OPP_GR3dpoint_class_id)
      {
        sts = om$send (msg = message GRgraphics.GRdelete(msg,
                              construct_list->env_info),
                       senderid = NULL_OBJID,
                       targetid = work_GRid.objid,
                       targetos = work_GRid.osnum);
        EMerr_hndlr(!(1&*msg), *msg, EMS_E_Fail, wrapup);
        work_GRid.objid = NULL_OBJID;
        continue;
      }

      if (output_curve->objid == NULL_OBJID)
      {
       stupid_info.located_obj = work_GRid;
       stupid_info.module_info = *construct_list->env_info;

       construct_list->geometry = NULL;

       sts = om$construct(classid = OPP_GRcompcurve_class_id,
                          p_objid = &output_curve->objid,
                          osnum = output_curve->osnum,
                          msg = message GRvg.GRconstruct(construct_list));
       EMerr_hndlr(!(1&sts), *msg, EMS_E_Fail, wrapup);

       sts = om$send (msg = message GRcompcurve.EMmakecomp(
                            msg,curve_env,1,&stupid_info,&rotten),
                      senderid = NULL_OBJID,
                      targetid = output_curve->objid,
                      targetos = output_curve->osnum);
       EMerr_hndlr(!(1&sts&*msg), *msg, EMS_E_Fail, wrapup);
      }
      else
      {
        sts = om$send (msg = message GRcompcurve.EMaddtocomp(msg,
                             work_GRid,
                             construct_list->env_info,
                             construct_list->env_info,
                             TRUE, /* inter allowed */
                             MAXFLOAT, /*search tol */
                             dist_tol, /* connect tol */
                             FALSE,
                             comp_start,
                             comp_end,
                             &comp_so_far),
                        senderid = NULL_OBJID,
                        targetid = output_curve->objid,
                        targetos = output_curve->osnum);
        EMerr_hndlr(!(1&sts&*msg), *msg , EMS_E_Fail, wrapup);
      }
    }
/*
 * Try to close the composite.
 */

   if (output_curve->objid != NULL_OBJID)
   {
/*
 * If the composite has only one component then delete the composite object
 * and return the component.
 */
    if (comp_so_far == 1)
    {
     struct GRid temp_GRid;
     IGRint returned_count;

      sts = om$send (msg = message GRowner.GRget_components(msg,
                         construct_list->env_info,
                         &temp_GRid,1,&returned_count,0,
                         0),
                   senderid = NULL_OBJID,
                   targetid = output_curve->objid,
                   targetos = output_curve->osnum);
      EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrapup);

      sts = om$send (msg = message Root.delete(1),
                     senderid = NULL_OBJID,
                     targetid = output_curve->objid,
                     targetos = output_curve->osnum);
      EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrapup);

      *output_curve = temp_GRid;

      if (out_classid)
      {
       sts = om$get_classid (objid = output_curve->objid,
                             osnum = output_curve->osnum,
                             p_classid = out_classid);
       EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrapup);
     }
    }
    else if (comp_so_far > 1)
    {
     sts = EMclose_composite(msg,construct_list->env_info,*output_curve,
                             cht,dist_tol);
     EMerr_hndlr(!(1&sts&*msg), *msg , EMS_E_Fail, wrapup);

     if (out_classid)
      *out_classid = OPP_GRcompcurve_class_id;
    }
    else
    {
     *msg = EMS_E_InvalidCase;
     goto wrapup;
    }
   }
 }
 else
 {
  *msg = EMS_E_OMerror;
  goto wrapup;
 }

wrapup:
 EMWRAPUP (sts, *msg, "In EFproject_any_curve_onto_plane error");
 if (!(1&sts&*msg))
 {
  IGRlong cln_sts;
  IGRlong loc_msg;

  if (output_curve->objid != NULL_OBJID)
  {
   cln_sts = om$send (msg = message GRgraphics.GRdelete(msg,
                            construct_list->env_info),
                      senderid = NULL_OBJID,
                      targetid = output_curve->objid,
                      targetos = output_curve->osnum);
  }
 }

 if (cv_geom) om$dealloc(ptr = cv_geom);
 if (output_comp_geom) BSfreecv(&loc_msg,output_comp_geom);
 if (output_geom) BSfreecv(&loc_msg,output_geom);
 if (o_ids_ptr && (o_ids_ptr != o_ids_buff))
  om$dealloc(ptr = o_ids_ptr);
 return (sts);
}

EFconstruct_curve(msg,geom,construct_list,classid,curve_GRid)
IGRlong *msg;
struct IGRbsp_curve *geom;
struct GRvg_construct *construct_list;
OMuword classid;
struct GRid *curve_GRid;
{
 struct IGRdisplay local_display, *saved_display;
 IGRint sts;

 *msg = EMS_S_Success;
 curve_GRid->osnum = construct_list->env_info->md_id.osnum;
 curve_GRid->objid = NULL_OBJID;

  saved_display = NULL;
  if ((classid == OPP_GR3dpoint_class_id) &&
      (construct_list->display->weight < 3))
   {
    local_display = *(construct_list->display);
    local_display.weight = 3;
    saved_display = construct_list->display;
    construct_list->display = &local_display;
   }

   construct_list->geometry = (IGRchar *)geom;

   sts = om$construct(classid = classid,
                     p_objid = &curve_GRid->objid,
                     osnum = curve_GRid->osnum,
                     msg = message GRvg.GRconstruct(construct_list));
   if (saved_display) construct_list->display = saved_display;
   EMerr_hndlr(!(1&sts&*construct_list->msg),*msg, EMS_E_Fail,
                wrapup);
 
wrapup:
 if (!(1&sts&*msg))
 {
  sts = om$send (msg = message Root.delete(1), 
                 senderid = NULL_OBJID,
                 targetid = curve_GRid->objid,
                 targetos = curve_GRid->osnum);
  curve_GRid->objid = NULL_OBJID;
 }
 return;
}
end implementation EMSsubbs;

