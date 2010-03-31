class implementation EMAdatpln;

/*
  HISTORY

        Sudha   23-june-93      modified for BSprototype ansification
*/

#include "bserr.h"
#include "bsparameters.h"
#include "alloca.h"
#include "EMSdef.h" /* For EMparms */
%safe
#include "math.h" /* For fabs */
%endsafe
#include "EMSconstruct.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "matypemx.h"
#include "maptpldis.h"
#include "maoptsxfo.h"
#include "mamulmx.h"
#include "mainvmx.h"
#include "ma2pt2di.h"
#include "ma2lnise.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bscrossp.h"
#include "madef.h"
#include "maidmx.h"

#define INC 1.1

from EMSsurface import EMget_point_on_surface;
from EMSsurface import EMalgnnrml;
from expression import NDgive_value;

%safe
static int ppdetdir();
%endsafe

IGRlong EFconstruct_parallel_ref_plane(EMmsg, options, num_parents,
        parent_info, type, recomp_info, construct_list,
        cons_GRid)
IGRlong *EMmsg;
IGRushort options;
IGRint num_parents;
IGRchar *parent_info;
IGRint type;
IGRchar *recomp_info;
struct GRvg_construct *construct_list;
struct GRid *cons_GRid;
{
 IGRboolean is_surface;
 IGRboolean bsts, aflag=0;
 IGRchar temp_props;
 BSrc rc;
 IGRlong status,msg_loc;
 IGRint i,x_inx=0,y_inx=0;
 struct IGRline x_line, y_line;
 IGRdouble dist_tol;
 IGRvector x_dir, y_dir, z_dir;
 IGRpoint pt1, pt2, pt3, pt4;
 IGRpoint int_pt;
 union EMSparent_info *roots = NULL;
 IGRuint root_count;
 IGRuint *root_type = NULL;
 IGRpoint plane_point, plane_normal;
 struct IGRplane plane;
 struct GRid *pln_GRid, orig_mdid;
 struct GRmd_env *pln_env;
 struct EMSrefpln_planar_element_info *info;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 aflag = pwIsActivationOn();


 x_line.point1 = pt1;
 x_line.point2 = pt2;

 y_line.point1 = pt3;
 y_line.point2 = pt4;

 BSEXTRACTPAR (&rc,BSTOLBASIS, dist_tol);

 root_count = num_parents;
 root_type = (IGRuint *) stackalloc(sizeof(IGRint) * root_count);
 EMerr_hndlr(!root_type, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 roots = (union EMSparent_info *)stackalloc(root_count*
              sizeof(union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 info = (struct EMSrefpln_planar_element_info *) recomp_info;

 for (i=0;i<num_parents;i++)
   root_type[i] = EMSlcinfo;

 temp_props = info->props;

 if (temp_props & EMS_OFFSET_VALUE)
   root_type[num_parents-1] = EMSdistance;
 else if (temp_props & EMS_THRU_POINT)
   root_type[num_parents-1] = EMSpoint;

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                         root_count,
                         parent_info,root_type, roots),
                   senderid = cons_GRid->objid,
                   targetid = cons_GRid->objid,
                   targetos = cons_GRid->osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 pln_env = &roots[0].lc_info.module_info;
 pln_GRid = &roots[0].lc_info.located_obj;
 plane.point = plane_point;
 plane.normal = plane_normal;

 if (EFisAncestryValid(&msg_loc, pln_GRid->objid, pln_GRid->osnum,
          OPP_EMSsurface_class_id, FALSE))
  is_surface = TRUE;
 else
  is_surface = FALSE;

 EFget_oriented_normal(EMmsg,NULL,pln_GRid,pln_env,&plane);
 EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);


/*
 * If x edge is present then it should be the second element in the
 * parent list.
 * If x edge is present then 
 *   if y edge exists it should be the third element in the parent list
 *   else it should be the second element in the parent list.
 */

 if (temp_props & EMS_X_EDGE)
  x_inx = 1;
 else
  x_inx = -1;

 if (temp_props & EMS_X_EDGE)
 {
   if (temp_props & EMS_Y_EDGE)
    y_inx = 2;
   else
    y_inx = -1;
 }
 else
 {
   if (temp_props & EMS_Y_EDGE)
    y_inx = 1;
   else
    y_inx = -1;
 }

/*
 * Project the edges onto the plane just in case if they do not lie on
 * the same.
 */

 if (temp_props & EMS_X_EDGE)
 {
   pp_project_onto_plane(&msg_loc,&roots[x_inx].lc_info, &plane,&x_line);
   EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 }

 if (temp_props & EMS_Y_EDGE)
 {
   pp_project_onto_plane(&msg_loc,&roots[y_inx].lc_info, &plane,&y_line);
   EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 }

/* 
 * If x and y edges exist, then the origin can be determine unambigously
 * in most situations. The origin is the intersection of the x line and
 * the y line. 
 */

 if ((temp_props & EMS_X_EDGE) && (temp_props & EMS_Y_EDGE))
 {
   IGRdouble t1, t2;

   bsts = MA2lnisect(&rc,&x_line,
                         &y_line,
                     &dist_tol,
                     int_pt,
                     &t1, &t2);
/*
 * If for some reason there was an error either because one of the lines
 * has become degenerate of if the two lines are parallel then reduce
 * the condition to just having the primary edge
 */
   if (!(1&rc))
   {
    if (temp_props & EMS_X_EDGE_PRIMARY)
      temp_props &= ~EMS_Y_EDGE;
    else
      temp_props &= ~EMS_X_EDGE;
   }
   else
   {
/*
 * Determine the x and y direction
 */
     status = ppdetdir(&rc,int_pt,x_line,x_dir);
     status = ppdetdir(&rc,int_pt,y_line,y_dir);

     bsts = BScrossp(&rc,x_dir,y_dir,z_dir);

     if (temp_props & EMS_X_EDGE_PRIMARY)
     {
      bsts = BScrossp(&rc,z_dir,x_dir,y_dir);
      bsts = BSnorvec(&rc,y_dir);
     }
     else
     {
      bsts = BScrossp(&rc,y_dir,z_dir,x_dir);
      bsts = BSnorvec(&rc,x_dir);
     }
    }
  }
/*
 * If only x edge has been identified then the x direction is determined
 * from the same. z direction is parallel to the plane normal 
 *
 * If only y edge has been identified then the y direction is determined
 * from the same. z direction is parallel to the plane normal
 *
 */

 if ((temp_props & EMS_X_EDGE) && !(temp_props & EMS_Y_EDGE))
 {
   bsts = BSmkvec(&rc, x_dir,x_line.point1, x_line.point2);
   if (!(1&bsts)) goto wrapup;

   bsts = BSnorvec(&rc,x_dir);
   if (!(1&bsts)) goto wrapup;

   if (temp_props & EMS_EDGE_REV)
    for (i=0;i<3;i++)
      x_dir[i] = -x_dir[i];

   OM_BLOCK_MOVE(plane.normal,z_dir,sizeof(IGRvector));
   bsts = BScrossp(&rc,z_dir,x_dir,y_dir);
   bsts = BSnorvec(&rc,y_dir);
 }
 else if ((temp_props & EMS_Y_EDGE) && !(temp_props & EMS_X_EDGE))
 {
   bsts = BSmkvec(&rc, y_dir,y_line.point1, y_line.point2);
   if (!(1&bsts)) goto wrapup;

   bsts = BSnorvec(&rc,y_dir);
   if (!(1&bsts)) goto wrapup;

   if (temp_props & EMS_EDGE_REV)
    for (i=0;i<3;i++)
      y_dir[i] = -y_dir[i];

   OM_BLOCK_MOVE(plane.normal,z_dir,sizeof(IGRvector));
   bsts = BScrossp(&rc,y_dir,z_dir,x_dir);
   bsts = BSnorvec(&rc,x_dir);
 }
 else if (!(temp_props & EMS_X_EDGE) && !(temp_props & EMS_Y_EDGE))
 {
  if (!is_surface)
  {
   status = EFget_orientation_from_parent(&msg_loc,pln_GRid,pln_env,x_dir,
                           y_dir,z_dir,NULL);
   EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  }
  else
  {
   status = EFget_xyzdir_from_geometry(&msg_loc,pln_env,pln_GRid,&plane,
            x_dir,y_dir, z_dir);
   EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  }
 }

/*
 * At this point x, y and z directions of the reference plane have been
 * determined. It is now time to create a reference plane parallel to
 * the planar element in preparation for the offset if necessary.
 */
 status =  EFcons_coincident_ref_plane(&msg_loc,x_dir,y_dir,z_dir,pln_env,
                   pln_GRid, &plane,cons_GRid, construct_list);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

/*
 * Now we are ready to create the offset plane if necessary.
 */

 if ((temp_props & EMS_THRU_POINT) ||
     (temp_props & EMS_OFFSET_VALUE))
 {
  IGRdouble dist,sign;
  IGRshort trans_mxtype;
  IGRint i;
  IGRmatrix trans_mx;
  OM_S_OBJID newobjid;

  if (temp_props & EMS_OFFSET_VALUE)
  {
   dist = roots[num_parents-1].value;
   dist = fabs(dist);
   if (temp_props & EMS_PLANE_REV)
   sign = -1;
   else sign = 1;
  }
  else
  {
   IGRvector temp_dir; /* To store the vector from the plane to the
                          offset point */

   bsts = BSmkvec(&rc, temp_dir,plane.point,roots[num_parents-1].point);
   EMerr_hndlr(!bsts, *EMmsg, EMS_E_Fail, wrapup);

   bsts = BSnorvec(&rc,temp_dir);
   EMerr_hndlr(!bsts, *EMmsg, EMS_E_Fail, wrapup);

   if ((temp_dir[0]*plane.normal[0] +
       temp_dir[1]*plane.normal[1] +
       temp_dir[2]*plane.normal[2]) < 0.0)
     sign = -1;
   else
     sign = 1;
   

   bsts = MAptpldis(&rc,roots[num_parents-1].point,&plane,&dist);
  }
  for (i=0;i<16;i++)
    trans_mx[i] = 0.0;

  trans_mx[0] = trans_mx[5] = trans_mx[10] = trans_mx[15] = 1.0;

  for (i=0;i<3;i++)
     trans_mx[4*i+3] = plane.normal[i]*dist*sign;
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
                      senderid = NULL_OBJID,
                      targetid = cons_GRid->objid,
                      targetos = cons_GRid->osnum);
  if(aflag)
    pln_env->md_id = orig_mdid;

  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  cons_GRid->objid = newobjid;
 }

wrapup:
 return (status);

}


/*
 * The direction of the vector is determined to be from the intersection
 * point to the closest point on the line.
 */
static int ppdetdir(rc,int_pt,line,dir)
IGRint *rc;
IGRpoint int_pt;
struct IGRline line;
IGRvector dir;
{

 IGRboolean bssts;
 IGRlong i,msg_loc;
 IGRdouble dist1, dist2;

 *rc = 1;

 bssts = BSmkvec((IGRlong *)rc, dir,line.point1, line.point2);
 if (bssts)
 {

  MA2pt2dis(&msg_loc,int_pt,line.point1,&dist1);
  MA2pt2dis(&msg_loc,int_pt,line.point2,&dist2);

  if (dist1 > dist2)
   for (i=0;i<3;i++)
    dir[i] = -dir[i];

   bssts = BSnorvec((IGRlong *)rc,dir);
 }
 else
  *rc = 0;

 return (1);
}


EFget_oriented_normal(EMmsg,options,pln_GRid,pln_env,plane)
IGRlong *EMmsg;
IGRint options;
struct GRid *pln_GRid;
struct GRmd_env *pln_env;
struct IGRplane *plane;
{
 IGRint i;
 IGRlong status,msg_loc;
 IGRboolean pos_orient;
 IGRushort pos_option;
 struct EMparms parms;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if ((EFisAncestryValid(&msg_loc, pln_GRid->objid, pln_GRid->osnum,
          OPP_EMSsurface_class_id, FALSE)))
 {
  status = om$send(msg = message EMSsurface.EMget_point_on_surface(&msg_loc,
                        pln_env,0,1, plane->point, &parms),
                   senderid = NULL_OBJID,
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
                     senderid = NULL_OBJID,
                     targetid = pln_GRid->objid,
                     targetos = pln_GRid->osnum);
  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 if (pos_orient)
 {
    for (i=0;i<3;i++)
     parms.normal[i] *= -1.0;
  }
  OM_BLOCK_MOVE(parms.normal,plane->normal,sizeof (IGRvector));
 }
 else
 {
  status =  EFget_orientation_from_parent(&msg_loc,pln_GRid,pln_env,
        NULL,NULL,plane->normal,plane->point);
  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 }

wrapup:
 return (status);

}

IGRint EFget_xyzdir_from_geometry(EMmsg,pln_env,pln_GRid,plane, x_dir,y_dir,
       z_dir)
IGRlong *EMmsg;
struct GRmd_env *pln_env;
struct GRid *pln_GRid;
struct IGRplane *plane;
IGRvector x_dir;
IGRvector y_dir;
IGRvector z_dir;
{
 IGRboolean bsts;
 IGRlong status,rc, msg_loc;
 IGRint i;
 IGRdouble inc;
 IGRpoint first_pole,second_pole;
 struct IGRbsp_surface *sf_ptr;

 inc = INC;
 OM_BLOCK_MOVE(plane->normal,z_dir,sizeof(IGRvector));

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

  bsts = BSmkvec(&rc, x_dir,first_pole, second_pole);
  EMerr_hndlr (!bsts, *EMmsg, EMS_E_BSerror, wrapup);
  bsts = BSnorvec(&rc,x_dir);
  bsts = BScrossp(&rc,z_dir,x_dir,y_dir);
  bsts = BSnorvec(&rc,y_dir);

wrapup:
 return (status);
}

IGRint EFcons_coincident_ref_plane(EMmsg,x_dir,y_dir,z_dir,pln_env,pln_GRid,
                                   plane,cons_GRid, construct_list)
IGRlong *EMmsg;
IGRvector x_dir;
IGRvector y_dir;
IGRvector z_dir;
struct GRmd_env *pln_env;
struct GRid *pln_GRid;
struct IGRplane *plane;
struct GRid *cons_GRid;
struct GRvg_construct *construct_list;
{
 IGRboolean in_world, range_obtained, aflag=0;
 IGRshort four = 4;
 IGRshort xform_mattyp, pw_mattyp;
 IGRshort index = 4;
 IGRint i;
 IGRlong status,msg_loc,num_pts;
 IGRdouble grobj_range[6],origin_pt[3],inc;
 IGRdouble x_size, y_size;
 IGRmatrix wp_mat,xform_mat, pw_mat;
 extern OMuword OPP_EMSsubbs_class_id;
 struct GRmd_env save_env;

 status = OM_S_SUCCESS;
 inc = INC;
 aflag = pwIsActivationOn();

 for (i=0;i<16;i++)
  wp_mat[i] = 0.0;

 wp_mat[15] = 1.0;

 OM_BLOCK_MOVE(x_dir, &wp_mat[0],sizeof (IGRvector));
 OM_BLOCK_MOVE(y_dir, &wp_mat[4],sizeof (IGRvector));
 OM_BLOCK_MOVE(z_dir, &wp_mat[8],sizeof (IGRvector));

 wp_mat[3]  = -plane->point[0];
 wp_mat[7]  = -plane->point[1];
 wp_mat[11] = -plane->point[2];

 MAmulmx (&msg_loc, &four, &four, &four, wp_mat,
    pln_env->md_env.matrix, xform_mat);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_MAerror, wrapup);

 MAtypemx (&msg_loc, xform_mat, &xform_mattyp);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_MAerror, wrapup);

 if (EFisAncestryValid(&msg_loc,pln_GRid->objid, pln_GRid->osnum,
                     OPP_EMSsubbs_class_id,FALSE))
 {
  status = EMgetredrange(&msg_loc,&xform_mattyp,
             xform_mat, pln_GRid, grobj_range);
  if (!(1&status&msg_loc))
  { 
   in_world = TRUE;
   status = om$send (msg = message GRgraphics.GRgetrang(&msg_loc,
                            &xform_mattyp,
                            xform_mat, &in_world,
                            grobj_range),
                      senderid = NULL_OBJID,
                      targetid = pln_GRid->objid,
                      targetos = pln_GRid->osnum);
  }
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    range_obtained = TRUE;
 }
 else if (EFisAncestryValid(&msg_loc,pln_GRid->objid, pln_GRid->osnum,
                     OPP_EMSdatpln_class_id,FALSE))
 {
  in_world = TRUE;
  status = om$send (msg = message GRgraphics.GRgetrang(&msg_loc,
                            &xform_mattyp,
                            xform_mat, &in_world,
                            grobj_range),
                      senderid = NULL_OBJID,
                      targetid = pln_GRid->objid,
                      targetos = pln_GRid->osnum);
  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    range_obtained = TRUE;
 }
 else 
 {
  OMuword expid;
  OM_S_OBJID expos;
  IGRdouble def_size;

  
  x_size = y_size = 5;

  range_obtained = FALSE;
  status = di$translate(objname="def_refpln_size",
                       p_objid = (DIobjid *) &expid,
                       p_osnum = (DIspacenum *)&expos);
  if (status == DIR_S_SUCCESS)
  {
  status = om$send (msg = message expression.NDgive_value(&def_size),
                          senderid = NULL_OBJID,
                          targetid = expid,
                          targetos = expos);
  x_size = y_size = def_size;
  }

  OM_BLOCK_MOVE(plane->point, origin_pt, sizeof (IGRpoint));
 }

 if (range_obtained)
 {
 for (i=0;i<3;i++)
    origin_pt[i] = (grobj_range[i] + grobj_range[3+i])/2.0;

 x_size = inc*fabs(grobj_range[0] - grobj_range[3]);
 y_size = inc*fabs(grobj_range[1] - grobj_range[4]);
 
 index = 4;
 status = MAinvmx(&msg_loc, &index, wp_mat, pw_mat);
 EMerr_hndlr(!status, *EMmsg, EMS_E_BSerror, wrapup);

 MAtypemx (&msg_loc, pw_mat, &pw_mattyp);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_MAerror, wrapup);

 num_pts = 1;
 status = MAoptsxform(&msg_loc, &num_pts, &pw_mattyp, 
                        pw_mat, origin_pt, origin_pt);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_MAerror, wrapup);
 }

 /*
  * Changed the md_env going into this method to pln_env from that sent
  * in with the construct_list. We don't know what comes in with const_list.
  */
 status = om$send (msg = message EMSdatpln.EMput_pln_info(&msg_loc,
                          EMS_OPT_SET_EXTERNAL_CONSTRAINT,
                          aflag ? pln_env : construct_list->env_info,
                          x_dir,y_dir,z_dir,origin_pt,NULL),
                   senderid = NULL_OBJID,
                   targetid = cons_GRid->objid,
                   targetos = cons_GRid->osnum);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 if(aflag)
 {
   /*
    * Here we have to ensure that an identity matrix goes in as the method
    * EMcreate_resize_handle() works directly on the instance of the plane,
    * and not on the transformed master space data. It is being enforced here
    * it is not certain when construct_list will come in with a non-identity
    * matrix. 
    */
   memcpy(&save_env, &construct_list->env_info->md_env,
          sizeof(struct GRmd_env));

   MAidmx(&msg_loc, construct_list->env_info->md_env.matrix);
   construct_list->env_info->md_env.matrix_type = MAIDMX;
 }

 status = om$send (msg = message EMSdatpln.EMcreate_resize_handle(&msg_loc,
                           EMS_OPT_DISPLAY_HANDLE, construct_list->env_info,
                           construct_list,
                           x_size, y_size,
                           NULL),
                   senderid = NULL_OBJID,
                   targetid = cons_GRid->objid,
                   targetos = cons_GRid->osnum);

 if(aflag)
 {
   memcpy(&construct_list->env_info->md_env, &save_env,
          sizeof(struct GRmd_env));
 }

 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 wrapup:
  return(status);

}
end implementation EMAdatpln;
