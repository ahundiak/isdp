class implementation EMAdatpln;

#include <alloca.h>
#include "bserr.h"
#include "bsparameters.h"
#include "EMSdef.h" /* For EMparms */
#include "EMSconstruct.h"
#include "OMmacros.h"
#include "bs_values.h"
#include "exmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "nddef.h"    /* For ND_NC_NEW */
#include "asmacros.h" /* For as$make_source */
#include "parametric.h"
%safe
#include <math.h>
%endsafe

#include "matypemx.h"
#include "maptlnpro.h"
#include "magrotmx.h"
#include "bststcvfln.h"
#include "bsprj_cv_pl.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsfreecv.h"
#include "bscrossp.h"
#include "bsalloccv.h"

#define INC 1.1

from EMSsubbs import EMss4poles;
from EMSsurface import EMget_point_on_surface;
from EMSsurface import EMalgnnrml;
from EMSdatplnmgr import EMactivate,EMmanage_datum_entry, EMget_info;
from EMSdimdtm import EMautodim;

extern OMuword OPP_EMSdimdtm1_class_id;

method EMconstruct_associative(IGRlong *EMmsg;
                                IGRushort options;
                                GRobjid old_objid;
                                IGRint num_parents;
                                IGRchar *parent_info;
                                IGRint type;
                                IGRchar *recomp_info;
                                struct GRvg_construct *construct_list)
/* ****************************************************************

Description
 This method provides the protocol for construction of associative elements
 in EMS.

Arguments
Input
  options: ubiquitous argument. 
  old_objid : Objid of the object which has gotten a recompute message.
              If the same is a construction, then this is initialised
              to NULL_OBJID.
  num_parents : number of parents.
  parent_info : Information about the parents. This information can
                be unraveled by EMget_parent_info message.
  type : Type to interpret the recomputation information.
  recomp_info: Recomputation information. 
  construct_list: construction information.

Output
 EMmsg: Completion code.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

History
 pp : 07/20/91 : creation
 Sudha   23-june-93      modified for BSprototype ansification
 Satish  30/5/95         checking for degeneracy of direction vector

*********************************************************************** */
{
 IGRboolean aflag;
 IGRlong status,msg_loc;
 union EMSparent_info *roots = NULL;
 IGRuint root_count;
 IGRuint *root_type = NULL;
 IGRlong EFget_orientation_from_parent();
 struct GRid my_GRid, orig_mdid;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 aflag = pwIsActivationOn();

 switch (type)
 {
  case EMS_ASparallel_to_planar_element_new:
  {
   EFconstruct_parallel_ref_plane(EMmsg, NULL, num_parents, parent_info, type,
          recomp_info, construct_list, &my_GRid);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
  break;

  case EMS_ASfrom_planar_element:
  case EMS_ASangle_to_planar_element:
  case EMS_ASparallel_to_planar_element:
  {
   IGRboolean is_surface = FALSE, pos_orient, negate;
   IGRushort pos_option;
   IGRint i;
   BSrc   rc;
   IGRpoint origin_pt, line_pt;
   IGRdouble plane_point[3];
   IGRdouble plane_normal[3];
   IGRdouble t;
   IGRdouble *x_dir, *y_dir, *z_dir;
   IGRdouble ln1[6],line_dir[3], temp_dir[3],cross_dir[3],
             pseudo_z[3], dotz;
   IGRdouble vector_length,cross_tol;
   IGRdouble inc;
   struct GRid *pln_GRid;
   struct IGRplane plane;
   struct IGRline  line1;
   struct GRmd_env *pln_env;
   struct EMSdatpln_planar_element_info *info;
   extern void pp_project_onto_plane();
   struct EMparms parms;
   BSEXTRACTPAR (&rc,BSTOLCOLLINVEC, cross_tol);

   root_count = num_parents;
   root_type = (IGRuint *) stackalloc(sizeof(IGRint) * root_count);
   EMerr_hndlr(!root_type, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

   status = om$send (msg = message EMSassoc.EMget_parent_type(EMmsg, 
                         type,
                         root_count,
                         root_type),
                   targetid = my_id);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

   roots = (union EMSparent_info *)stackalloc(root_count*
              sizeof(union EMSparent_info));
   EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

   status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                         root_count,
                         parent_info,root_type, roots),
                   targetid = my_id);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 
   pln_env = &roots[0].lc_info.module_info;
   pln_GRid = &roots[0].lc_info.located_obj;
   plane.point = plane_point;
   plane.normal = plane_normal;
   line1.point1 = ln1;
   line1.point2 = &ln1[3];

   if (EFisAncestryValid(&msg_loc,pln_GRid->objid, pln_GRid->osnum,
                       OPP_EMSsubbs_class_id,FALSE))
    is_surface = TRUE;
   else 
    is_surface = FALSE;

   info = (struct EMSdatpln_planar_element_info *)recomp_info;

/*
 * Get a point and aligned normal of the surface of the solid.
 */
   if (is_surface)
   {
    status = om$send(msg = message EMSsurface.EMget_point_on_surface(&msg_loc,
                          pln_env,0,1, plane_point, &parms),
                     targetid = pln_GRid->objid,
                     targetos = pln_GRid->osnum);
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    pos_option = EMS_GET_POS_ORIENT;
    status = om$send (msg = message EMSsurface.EMalgnnrml(
                           &msg_loc,
                           pos_option,
                           &pos_orient,
                           NULL,
                           NULL),
                     targetid = pln_GRid->objid,
                     targetos = pln_GRid->osnum);
   EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

   if (pos_orient)
   {
     for (i=0;i<3;i++)
      parms.normal[i] *= -1.0;
   }
   OM_BLOCK_MOVE(parms.normal,plane.normal,sizeof (IGRvector));
  }
  else 
  {
   status = EFget_orientation_from_parent(&msg_loc,pln_GRid,pln_env,
                      line_dir,
                      cross_dir,
                      plane.normal,
                      plane.point);
   if (!(1&msg_loc&status)) goto wrapup;
  }


  if ((info->props & EMS_TOP_ELEMENT) ||
      (info->props & EMS_BOTTOM_ELEMENT) ||
      (info->props & EMS_LEFT_ELEMENT) ||
      (info->props & EMS_RIGHT_ELEMENT))
  {
/*
 * Project the incoming line onto the plane.
 */

   pp_project_onto_plane(&msg_loc,&roots[1].lc_info, &plane,&line1);
   EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

   status = MAptlnproj (&msg_loc, plane_point, &line1, line_pt, &t);
   EMerr_hndlr (!status, *EMmsg, EMS_E_MAerror, wrapup);

   z_dir = plane.normal;
 
   status = BSmkvec(&rc, line_dir,line1.point1, line1.point2);
   EMerr_hndlr (!status, *EMmsg, EMS_E_BSerror, wrapup);

   status = BSnorvec(&rc,line_dir);

   status = BSmkvec(&rc, temp_dir,line_pt, plane_point);
   EMerr_hndlr (!status, *EMmsg, EMS_E_BSerror, wrapup);
   status = BSnorvec(&rc,temp_dir);

/**** check for degeneracy of tmp_dir ****/
   if (rc == BSDGENRAT)
   {
	status = BScrossp(&rc, plane.normal, line_dir, temp_dir);
	status  = BSnorvec(&rc, temp_dir);
   }


   status = BScrossp(&rc,line_dir,temp_dir, pseudo_z);

   dotz = pseudo_z[0]*z_dir[0] + pseudo_z[1]*z_dir[1] +
          pseudo_z[2]*z_dir[2];

   negate = FALSE;

   if (info->props &  EMS_TOP_ELEMENT)
   {
     x_dir = line_dir;
     y_dir = cross_dir;
     if (dotz > 0.0) negate = TRUE;
   }
   else if (info->props & EMS_BOTTOM_ELEMENT)
   {
     if (dotz < 0.0) negate = TRUE;
     x_dir = line_dir;
     y_dir = cross_dir;
   }
   else if (info->props & EMS_LEFT_ELEMENT)
   {
     if (dotz > 0.0) negate = TRUE;
     x_dir = cross_dir;
     y_dir = line_dir;
   }
   else if (info->props & EMS_RIGHT_ELEMENT)
   {
     if (dotz < 0.0) negate = TRUE;
     x_dir = cross_dir;
     y_dir = line_dir;
   }

   if (negate)
   {
    for (i=0;i<3;i++)
     line_dir[i] *= -1.0;
   }

   if((info->props & EMS_TOP_ELEMENT) ||
      (info->props & EMS_BOTTOM_ELEMENT))
     status = BScrossp(&rc,z_dir,x_dir,y_dir);
   else
     status = BScrossp(&rc,y_dir,z_dir,x_dir);

   EMerr_hndlr(!status, *EMmsg, EMS_E_BSerror, wrapup);

   vector_length = BSlenvec(&rc,cross_dir);
   if (vector_length < cross_tol)
   {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
   }
   inc = INC;
  }
  else
  {
   if (!is_surface)
   {
    x_dir = line_dir;
    y_dir = cross_dir;
    z_dir = plane.normal;
    OM_BLOCK_MOVE(plane_point, origin_pt, sizeof (IGRpoint));
    inc = 1.0;
   }
   else if ((type == EMS_ASfrom_planar_element) ||
            (type == EMS_ASparallel_to_planar_element))
   {
    IGRint i;
    IGRpoint first_pole,second_pole;
    struct IGRbsp_surface *sf_ptr;

    inc = INC;
    z_dir = plane.normal;
    x_dir = line_dir;
    y_dir = cross_dir;

    status = EMgetabsg(&msg_loc,&pln_env->md_env.matrix_type,
             pln_env->md_env.matrix,pln_GRid->osnum,
             pln_GRid->objid, &sf_ptr);
    if (!(1&status&msg_loc)) goto wrapup;

    if (sf_ptr->rational)
    {
     for (i=0;i<3;i++)
     {
      first_pole[i] = sf_ptr->poles[i]/sf_ptr->weights[0];
      second_pole[i] = sf_ptr->poles[3+i]/sf_ptr->weights[1];
     }
    }
    else
    {
      OM_BLOCK_MOVE(sf_ptr->poles, first_pole, sizeof (IGRpoint));
      OM_BLOCK_MOVE(&sf_ptr->poles[3], second_pole, sizeof (IGRpoint));
    }
    status = BSmkvec(&rc, x_dir,first_pole, second_pole);
    EMerr_hndlr (!status, *EMmsg, EMS_E_BSerror, wrapup);
    status = BSnorvec(&rc,x_dir);
    status = BScrossp(&rc,z_dir,x_dir,y_dir);

   }
   else
   {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
   }
  }
   status =  EFcons_coincident_ref_plane(EMmsg,x_dir,y_dir,z_dir,pln_env,
                                   pln_GRid,&plane,&my_GRid,construct_list);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   if (type == EMS_ASangle_to_planar_element)
   {
    IGRdouble angle,dot_a;
    IGRshort rot_mxtyp;
    IGRmatrix rot_mx;
    OM_S_OBJID newobjid;
    IGRvector p_axis_dir;
/*
 * temp_dir is the direction from the projected point on the axis to
 * the plane point.
 */
    if (info->props & EMS_REVERSE_DIR)
    {
     for (i=0;i<3;i++)
      plane_normal[i] = -plane_normal[i];
    }
  
    status = BScrossp(&rc,temp_dir,plane_normal, p_axis_dir);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_BSerror, wrapup);

    dot_a = p_axis_dir[0]*line_dir[0] + p_axis_dir[1]*line_dir[1] +
            p_axis_dir[2]*line_dir[2];
/*
 * Always take the absolute value of the parameter.
 * pp 10/1/91
 */

    roots[2].value = fabs (roots[2].value);

    if (root_count == 3)
     angle = (roots[2].value) * M_PI/ 180.0;
    else
     angle = 90.0 * M_PI / 180.0;

    if (dot_a < 0.0)
      angle = -angle;


    MAgrotmx(&msg_loc,line_dir,line1.point2,&angle,rot_mx);
    EMerr_hndlr(!(1&msg_loc), *EMmsg, MSFAIL, wrapup);

    MAtypemx (&msg_loc, rot_mx, &rot_mxtyp);
    EMerr_hndlr(!(1&msg_loc), *EMmsg, MSFAIL, wrapup);

    if(aflag)
    {
      /*
       * This is being done as the module id in pln_env in NULL_OBJID, and
       * there will be a problem in updating the rtree for the refplane
       * geometry. The construct_list comes in with the correct id. Use that.
       */
      orig_mdid = pln_env->md_id;
      pln_env->md_id = construct_list->env_info->md_id;
    }

    status = om$send (msg = message GRgraphics.GRxform(&msg_loc,
                            aflag ? pln_env : construct_list->env_info,
                            &rot_mxtyp, rot_mx,&newobjid),
                      targetid = my_id);

    if(aflag)
      pln_env->md_id = orig_mdid;

    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
   }  
   else if (type == EMS_ASparallel_to_planar_element)
   {
    IGRdouble dist,sign;
    IGRshort trans_mxtype;
    IGRint i;
    IGRmatrix trans_mx;
    OM_S_OBJID newobjid;


    dist = roots[num_parents-1].value;
    dist = fabs(dist);
    for (i=0;i<16;i++)
     trans_mx[i] = 0.0;

    trans_mx[0] = trans_mx[5] = trans_mx[10] = trans_mx[15] = 1.0;
    if (info->props & EMS_REVERSE_DIR)
     sign = -1.0;
    else
     sign = 1.0;

    for (i=0;i<3;i++)
     trans_mx[4*i+3] = z_dir[i]*dist*sign;
    MAtypemx (&msg_loc, trans_mx, &trans_mxtype);
    if (!(1&msg_loc)) goto wrapup;

    if(aflag)
    {
      /*
       * This is being done as the module id in pln_env in NULL_OBJID, and
       * there will be a problem in updating the rtree for the refplane
       * geometry. The construct_list comes in with the correct id. Use that.
       */
      orig_mdid = pln_env->md_id;
      pln_env->md_id = construct_list->env_info->md_id;
    }

    status = om$send (msg = message GRgraphics.GRxform(&msg_loc,
                            aflag ? pln_env : construct_list->env_info,
                            &trans_mxtype, trans_mx,&newobjid),
                      targetid = my_id);
    if(aflag)
      pln_env->md_id = orig_mdid;

    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
   }
  }
  break;


  default:
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }
 }

 {
  OM_S_OBJID mgrid;
  OMuword mgros;

  status = ems$get_datum_plane_mgr(msg = &msg_loc,
                                   osnum = &my_GRid.osnum,
                                   mgrid = &mgrid,
                                   mgros = &mgros);
  if (!(1&status&msg_loc)) goto wrapup;

  status = om$send (msg = message EMSdatplnmgr.EMmanage_datum_entry(&msg_loc,
                          EMS_OPT_ADD,my_id),
                    targetid = mgrid,
                    targetos = mgros);
  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  if (!(options & EMSasconst_recompute))
  {
   status = om$send (msg = message EMSdatplnmgr.EMactivate(&msg_loc,
                          NULL, &my_id, NULL),
                    targetid = mgrid,
                    targetos = mgros);
   EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  }
  else
  {
   IGRshort action;
   IGRshort old_props = 0, new_props = 0;
   OM_S_OBJID active_datum;
   OM_S_CHANSELECT to_comps;

   status = om$send (msg = message EMSdatplnmgr.EMget_info(&msg_loc,NULL,NULL,
                         NULL, &active_datum,NULL),
                   targetid = mgrid,
                   targetos = mgros);
   EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

   if (active_datum == old_objid)
   {
     /*
      * If aflag is TRUE, the active file IS a reference file, allow the
      * new plane to be activated.
      */
     if(aflag || !(ex$is_invis(mod_osnum = OM_Gw_current_OS))) 
     {
       status = om$send (msg = message EMSdatplnmgr.EMactivate(&msg_loc,
                             NULL, &my_id, NULL),
                         targetid = mgrid,
                         targetos = mgros);
       EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
     }
   }

/*
 * Manage the displayable and locatable properties 
 */
   EMmake_chanselect (GRcmpowner_to_components, &to_comps);

   status = om$send (msg = message GRgraphics.GRgetprops(&msg_loc,
                           &old_props),
                     p_chanselect = &to_comps,
                     senderid = old_objid);
   if (!(1&status&msg_loc))
   {
    status = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success; 
    old_props = 0;
   }

   new_props = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
   if ((old_props & GRIS_DISPLAYABLE) &&
       (old_props & GRIS_LOCATABLE))
    action = 1;
   else
    action = 0;

   status = om$send (msg = message GRgraphics.GRchgprops(&msg_loc, &action,
                          &new_props),
                    targetid = my_id);
   EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  }
 }

  


wrapup:
 EMWRAPUP (*EMmsg, status, "In EMAdatpln:EMconstruct_associative error");
 return (status);
}

void pp_project_onto_plane(msg,obj_info, plane,line)
IGRlong *msg;
struct GRlc_info *obj_info;
struct IGRplane *plane;
struct IGRline *line;
{
 IGRshort is_line;
 IGRlong status,msg_loc,rc;
 struct IGRbsp_curve *cv_ptr = NULL, *proj_curve = NULL;
 struct GRid *obj_GRid;
 struct GRmd_env *env;
 extern IGRboolean EMcnvtpybsn();

 *msg = EMS_S_Success;
 status = OM_S_SUCCESS;
 obj_GRid = &obj_info->located_obj;
 env = &obj_info->module_info;

 status = EMgetabsg(&msg_loc,&env->md_env.matrix_type,
          env->md_env.matrix,obj_GRid->osnum,
          obj_GRid->objid, &cv_ptr);
 if (!(1&status&msg_loc)) goto wrapup;
   
 BSalloccv(cv_ptr->order, cv_ptr->num_poles, cv_ptr->rational,0,
           &proj_curve,&rc);
 EMerr_hndlr(BSERROR(rc), *msg , EMS_E_BSerror, wrapup);
  
 status = BSprj_cv_pl(&rc,cv_ptr,plane->point,
          plane->normal, plane->normal, proj_curve);
 EMerr_hndlr(BSERROR(rc), *msg , EMS_E_BSerror, wrapup);

 BStstcvfln(proj_curve, &is_line,
            line->point1, line->point2, &rc);
 EMerr_hndlr(BSERROR(rc), *msg , EMS_E_BSerror, wrapup);
 if (is_line != 1)
 {
  *msg = EMS_E_InvalidArg;
  goto wrapup;
 }

wrapup:
 if (proj_curve) BSfreecv(&msg_loc,proj_curve);
 return;
}


method EMget_parent_type(IGRlong *EMmsg;
                         IGRint primitive_type;
                         IGRuint root_count;
                         IGRuint *root_type)
{
 IGRlong status;
 IGRint i;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
  
 switch (primitive_type)
 {
  case EMS_ASfrom_planar_element:
  {
   for (i=0;i<root_count;i++)
    root_type[i] = EMSlcinfo;
  }
  break;

  case EMS_ASparallel_to_planar_element:
   for (i=0;i<root_count-1 ;i++)
    root_type[i] = EMSlcinfo;
   root_type[root_count-1] = EMSdistance;
  break;

  case EMS_ASangle_to_planar_element:
   for (i=0;i<2 ;i++)
    root_type[i] = EMSlcinfo;
   if (root_count == 3)
   root_type[2] = EMSangle;
  break;

  default:
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }
 }

wrapup:
 EMWRAPUP (status, *EMmsg, "In EMAdatpln:EMget_parent_type error"); 
 return (status);
}

method EMautodim (IGRlong             *EMmsg;
                  struct GRmd_env     *mod_env )
{
 IGRlong status;
 OM_S_OBJID dim_id;
 struct GRid original, my_GRid;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 original.objid = NULL_OBJID;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 status = om$construct (classid = OPP_EMSdimdtm1_class_id,
                        p_objid = &dim_id,
                        msg = message NDnode.NDconnect(1, &my_GRid,
                              original, ND_ADD));
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$send (msg = message EMSdimdtm.EMautodim(EMmsg, mod_env),
                   targetid = dim_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (*EMmsg, status, "EMSdimdtm: NDconnect error");
 return (status);
}


/*

Name
   EFget_orientation_from_parent

Keywords
  function

History
  ??-xxx-91 : Prasad   Created
  22-Feb-93 : Jack     Modified to handle planes that are not reference planes.
                       For this case, only the zdir and point are returned.

 */

IGRlong EFget_orientation_from_parent(msg,pln_GRid,pln_env,
        xdir,ydir,zdir,point)
IGRlong *msg;
struct GRid *pln_GRid;
struct GRmd_env *pln_env;
IGRpoint point;
IGRvector xdir;
IGRvector ydir;
IGRvector zdir;
{
 IGRlong msg_loc, status;
 struct GRid source;
 IGRvector loc_vector;
 IGRpoint loc_point; 
 struct IGRplane loc_plane;
 

 struct ret_struct ret_struct;

 *msg = EMS_S_Success;
 status = OM_S_SUCCESS;

 ret_struct.type = NULL;

 as$make_source(go_grid = *pln_GRid,
                as_os = pln_GRid->osnum,
                as_grid = &source);

 status = om$send (msg = message NDnode.NDgive_structure(&msg_loc,
                         &ret_struct, pln_env),
                   senderid = NULL_OBJID,
                   targetid = source.objid,
                   targetos = source.osnum);
 EMerr_hndlr(!(1&status&msg_loc),*msg, EMS_E_Fail, wrapup);

  if (ret_struct.type == ref_generic)
    {
      int i,j;
      IGRmatrix trans_mat;
      double *mat;

      mat = ret_struct.var.ref_st.t;
      for (i=0;i<4;i++)
       for (j=0;j<4;j++)
         trans_mat[4*i+j] = mat[4*j+i];
/*
 * Use the transpose of the matrix returned by NDgive_structure to
 * get consistent results with coordinate systems, and other entities
 * that respond to NDgive_structure etc.
 * pp 12/9/91
 */
      if (point)
       OM_BLOCK_MOVE(&trans_mat[12],point, sizeof (IGRpoint));

      if (xdir)
       OM_BLOCK_MOVE(&trans_mat[0],xdir, sizeof (IGRpoint));

      if (ydir)
       OM_BLOCK_MOVE(&trans_mat[4],ydir, sizeof (IGRpoint));

      if (zdir)
       OM_BLOCK_MOVE(&trans_mat[8],zdir, sizeof (IGRpoint));
    }
  else
    {
      /*
       * if we don't have a reference plane, try assuming it is a
       * regular plane.
       */
      loc_plane.normal = loc_vector;
      loc_plane.point  = loc_point;

      status = om$send (msg = message GRvg.GRdetplane(
                              &msg_loc,
                              &pln_env->md_env.matrix_type,
                               pln_env->md_env.matrix,
                              &loc_plane),
                        senderid = NULL_OBJID,
                        targetid = pln_GRid->objid,
                        targetos = pln_GRid->osnum);
      EMerr_hndlr(!(1&status&msg_loc),*msg, EMS_E_Fail, wrapup);

      /*
       * Note: since this is a regular plane, we only return back the
       * point and normal vector of the plane.
       */

      if (point)
       OM_BLOCK_MOVE(loc_plane.point,point, sizeof (IGRpoint));

      if (zdir)
       OM_BLOCK_MOVE(loc_plane.normal,zdir, sizeof (IGRvector));

    }
    
    
wrapup:
 return(status);
}
        
end implementation EMAdatpln;

