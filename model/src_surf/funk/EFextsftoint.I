/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include <stdio.h>
%safe
#include "math.h"
%endsafe
#include "OMmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "emsedgedef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsimpdef.h"
#include "emsmapdef.h"
#include "emsmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "EMSsfintsort.h"
#include "msmacros.h"

#include "EMS_M.h"
#include "EMS_I.h"
#include "EMS_E.h"
#include "EMS_F.h"
#include "EMS_P.h"

#include "emsgeteddef.h"
#include "EMSproject.h"
#include "EMSsfparms.h"
#include "EMSssprops.h"
#include "ma.h"
#include "matypemx.h"
#include "matrlmx.h"
#include "marptsxfo.h"
#include "mamulmx.h"
#include "maidmx.h"
#include "bslocalcord.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bsbx2.h"

/*
 ABSTRACT
          The following function extends the surface(s) of projection
          of objects of class EMSproject (except EMScone and EMSpcone),
          EMSprjcompsf and EMSsfsolid such that final geometry encompasses
	      the range of a set of input objects.

 HISTORY
            RC    07/22/89       Creation Date
            NP    08/27/92       Modified for ANSI compliance.
	    Sudha 07/06/93       Modified for BSprototypes ansification

*/

#define BUF_SIZE  10

from GRowner    import  GRget_number_components, GRget_components;
from EMSproject import  EMgetDirection, EMputProjectedFormat;
from EMSsubbs   import  EMgetbsdef, EMget_edges;
from EMSboundary import EMgetsurface_info;
from EMSloopset import  EMpt_location;

extern OMuword OPP_EMSsfsolid_class_id, OPP_EMSprjcompsf_class_id;

void EFextend_sf_to_intersection (EFmsg, op1_elem, op1_elem_env, 
                                  num_op2_elems, op2_elems, op2_elems_env,
                                  extend_info, num_pts, sortpts_info)

 IGRlong                 *EFmsg;
 GRobjid                 op1_elem;
 IGRint                  num_op2_elems;
 GRobjid                 *op2_elems;
 struct GRmd_env         *op1_elem_env, *op2_elems_env;
 struct EMSextend_info   *extend_info;
 IGRint                  *num_pts;
 struct EMSsortpt_info   *sortpts_info; 
{
 OM_S_CHANSELECT            sf_ls_chan, cm_ed_chan;
 OM_S_OBJECT_LINKAGE        ls_list, cm_ed_list;
 struct IGRbsp_curve        *bcap_geom, *base_cv;
 struct IGRbsp_surface      sf_def, *sf_geom;
 struct GRpost_info         post_info;
 union  EMSprojectionFormat prj_data;
 struct EMsurface_params    sf_params;
 struct GRid                *prj_sfs_GRid = NULL, *prj_sf_ed, dum_GRid;
 struct EMSptloc_info       location;
 struct EMSpartolbasis      partolbasis;

 IGRdouble     w_lc_mat[3][3], rot_mat[4][4], tr_mat[4][4],
               align_mat[4][4], range_mat[4][4], op2_range[6],
               temp_range[6], bcap_range[6], bcap_yz_range[4],
               op2_yz_range[4], axis_len, bcap_extension, prj_vector[3],
               ecap_extension, unit_prj_vector[3], 
               bcap_ext_mat[4][4], bcap_ext_vector[3],
               ecap_ext_mat[4][4], ecap_ext_vector[3],
               sortpt_uv[2], temp_double, *cap_tr_mat;

 IGRpoint      y_axis;

 enum GRdpmode DisplayMode = GRbehe;

 IGRlong       rc, mthd_stat, OM_stat, sf_size, sf_alloced_size = 0,
               ed_options;
 IGRint        i, num_prj_sfs, sfix, array_size;
 IGRuint       count;
 IGRshort      four = 4, range_mattyp, cap_tr_mattyp;
 IGRboolean    right_hand = TRUE, status, world = TRUE,
               intersection_possible, prj_sfs_malloced = FALSE,
               v_prj_dir;
 GRobjid       owner_id, cap_sf, dum_id;
 GRspacenum    op1_os;
 
 extern void         EFget_prj_sfs();
 extern IGRlong      EMmake_chanselect();

 /* ************************************************************** */

 *EFmsg = EMS_S_Success;
 op1_os = op1_elem_env->md_id.osnum;
 sf_geom = NULL;
 post_info.construct_flag = FALSE;
 prj_sf_ed = &dum_GRid;

 /*
  * Get the matrix to align the projection vector along +x axis
  * with the bcap_ref_pt at origin. X_axis point will be ecap_ref_pt.
  * Y_axis point can be any point on the begin_cap curve.
  */

 BScveval (extend_info->bcap_geom, 0.5, 0, (IGRpoint *)y_axis, &rc);
 EMerr_hndlr( rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

 BSlocalcord (&rc, extend_info->bcap_ref_pt, extend_info->ecap_ref_pt, 
               y_axis, &right_hand, w_lc_mat);
 EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

 status = MAidmx (&rc, (IGRdouble *)rot_mat);

 for (i = 0; i < 3; i++)
  OM_BLOCK_MOVE (&w_lc_mat[i][0], &rot_mat[i][0], sizeof(IGRpoint));
 
 /*
  * Get the cumulative range box of the op2_elems in coordinate
  * system defined by origin at bcap_ref_pt along with projection_vector
  * along +x_axis and other point on the beg_cap along y_axis.
  * This can be directly obtained by a matrix (align_mat * md_matrix)
  */

 MAtrlmx (&rc, extend_info->bcap_ref_pt, (IGRdouble *)tr_mat);
 EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_BSerror, wrapup);
 for (i = 0; i < 3; i++)
  tr_mat[i][3] = -tr_mat[i][3];

 status = MAmulmx (&rc, &four, &four, &four, (IGRdouble *)rot_mat, (IGRdouble *)tr_mat, (IGRdouble *)align_mat);
 EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_BSerror, wrapup);

 status = MAmulmx (&rc, &four, &four, &four, (IGRdouble *)align_mat, 
                   op2_elems_env[0].md_env.matrix, (IGRdouble *)range_mat);
 EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_BSerror, wrapup);

 status = MAtypemx (&rc, (IGRdouble *)range_mat, &range_mattyp);
 EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_BSerror, wrapup);

 OM_stat = om$send (msg = message GRgraphics.GRgetrang (&mthd_stat,
                     &range_mattyp, (IGRdouble *)range_mat, &world, op2_range),
                    senderid = NULL_OBJID,
                    targetid = op2_elems[0], 
                    targetos = op2_elems_env[0].md_id.osnum);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_SurfaceError,wrapup);

 for (i = 1; i < num_op2_elems; i++)
 {
  status = MAmulmx (&rc, &four, &four, &four, (IGRdouble *)align_mat, 
                    op2_elems_env[i].md_env.matrix, (IGRdouble *)range_mat);
  EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_BSerror, wrapup);

  status = MAtypemx (&rc, (IGRdouble *)range_mat, &range_mattyp);
  EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_BSerror, wrapup);

  OM_stat = om$send (msg = message GRgraphics.GRgetrang (&mthd_stat,
                      &range_mattyp, (IGRdouble *)range_mat, &world, temp_range),
                     senderid = NULL_OBJID,
                     targetid = op2_elems[i], 
                     targetos = op2_elems_env[i].md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_SurfaceError,wrapup);

  for (i = 0; i < 3; i++)
  {
    if (temp_range[i] < op2_range[i]) op2_range[i] = temp_range[i];
    if (temp_range[3+i] > op2_range[3+i]) 
       op2_range[3+i] = temp_range[3+i];
  }

 } /* for (i = 1; i < num_op2_elems; i++) */

 /*
  * Get the range of the begin cap in the new coordinate system.
  */

 bcap_geom = extend_info->bcap_geom;

 status = MArptsxform (&rc, &bcap_geom->num_poles, &bcap_geom->rational,
                      bcap_geom->weights, (IGRdouble *)align_mat, bcap_geom->poles,
                      bcap_geom->poles);
 EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_BSerror, wrapup);

 status = BSbx2 (&rc, &bcap_geom->num_poles, (IGRpoint *)bcap_geom->poles, 
                 bcap_geom->weights, bcap_range, &bcap_range[3]);
 EMerr_hndlr (!status || rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

 /*
  * Now we have the range of the op2_elems and the begin cap
  * in a coordinate system with origin at bcap_ref_pt, +x_axis along
  * vector joining the bcap_ref_pt and ecap_ref_pt.
  * Get the range box of these entities along yz_plane. If theses
  * box intersect, there is a possiblity that there will be
  * intersection among op1 and op2_elems with/without extension.
  */

 for (i = 0; i < 2; i++)
 {
   bcap_yz_range[i] = bcap_range[i+1];
   bcap_yz_range[i+2] = bcap_range[i+4];

   op2_yz_range[i] = op2_range[i+1];
   op2_yz_range[i+2] = op2_range[i+4];

 } 

 if ( EM2dbxbxint (bcap_yz_range, op2_yz_range))
 {
  axis_len = BSdistptpt (&rc, extend_info->bcap_ref_pt, 
                         extend_info->ecap_ref_pt);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

  intersection_possible = TRUE;
  bcap_extension = ecap_extension = 0.;

  switch (extend_info->extension_type)
  {
   case EMSextend_begin_cap:
    if (op2_range[0] < 0.)
     bcap_extension = op2_range[0] - (op2_range[3] - op2_range[0])*.1;
    else
    {
     if (op2_range[0] > axis_len)
      intersection_possible = FALSE;
    }
    break;

   case EMSextend_end_cap:
    if (op2_range[3] < 0.)
      intersection_possible = FALSE;
    else
    {
     if (op2_range[3] > axis_len)
      ecap_extension = op2_range[3] + (op2_range[3] - op2_range[0]) * 0.1 
                       - axis_len;
    }    
    break;

   case EMSextend_both_ends:
    if (op2_range[0] < 0.)
     bcap_extension = op2_range[0] - (bcap_range[3] - bcap_range[0])*.1;

    if (op2_range[3] > axis_len)
      ecap_extension = op2_range[3] + (op2_range[3] - op2_range[0]) * 0.1 
                       - axis_len;
    break;

   default:
    *EFmsg = EMS_E_InvalidArg;
    goto wrapup;

  } /* switch (extend_info->extension_type) */

 } /* if ( EM2dbxbxint (bcap_yz_range, op2_yz_range)) */

 if (intersection_possible)
 {
  /* 
   * o Get The surfaces to be extended.
   */

  EFget_prj_sfs (&rc, op1_elem, op1_elem_env, 
                 extend_info->object_classid, &num_prj_sfs, 
                 &prj_sfs_GRid);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  /*
   * If the operand1 is of subclass EMSproject, it may have its
   * dir_of_projection along u_axis. Determine it and if so,
   * take appropriate action while using direction of projection.
   */

  if (extend_info->object_classid == OPP_EMSproject_class_id)
  {
    OM_stat = om$send (msg = message GRvg.GRgetsize (&mthd_stat,
                        &op1_elem_env->md_env.matrix_type, 
                        op1_elem_env->md_env.matrix, &sf_size),
                       senderid = NULL_OBJID,
                       targetid = prj_sfs_GRid[0].objid,
                       targetos = prj_sfs_GRid[0].osnum);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

    if (sf_alloced_size < sf_size)
    {
       sf_geom = (struct IGRbsp_surface *) om$malloc (size = sf_size);
       EMerr_hndlr (!sf_geom, *EFmsg, EMS_E_NoDynamicMemory, wrapup);
       sf_alloced_size = sf_size;
   }

   OM_stat = om$send (msg = message GRvg.GRgetgeom (&mthd_stat, 
                        &op1_elem_env->md_env.matrix_type, 
                        op1_elem_env->md_env.matrix, (IGRchar *) sf_geom),
                       senderid = NULL_OBJID,
                       targetid = prj_sfs_GRid[0].objid,
                       targetos = prj_sfs_GRid[0].osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

   OM_stat = om$send (msg = message EMSproject.EMgetDirection (
                        &mthd_stat, sf_geom, &v_prj_dir), 
                       senderid = NULL_OBJID,
                       targetid = prj_sfs_GRid[0].objid,
                       targetos = prj_sfs_GRid[0].osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);
      
  } /* if (extend_info->classid == OPP_EMSproject_class_id) */
  else
   v_prj_dir = TRUE;

  if (bcap_extension != 0. || ecap_extension != 0.)
  {
   /*
    * o If the bcap needs to be extended, transform the curves
    *   corresponding to begin cap. If end cap needs to be extended,
    *   extend the projection vector.
    */

   for (i= 0; i < 3; i++)
   {
     prj_vector[i] = extend_info->ecap_ref_pt[i] - 
                     extend_info->bcap_ref_pt[i];
     unit_prj_vector[i] = prj_vector[i] / axis_len;
   }

   if (bcap_extension != 0.)
   {
    for (i = 0; i < 3; i++)
     bcap_ext_vector[i] = unit_prj_vector[i] * bcap_extension;

    MAtrlmx (&rc, bcap_ext_vector, (IGRdouble *)bcap_ext_mat);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_BSerror, wrapup);

    for (i = 0; i < 3; i++)
     prj_vector[i] += -bcap_ext_vector[i];

   }
 
   if (ecap_extension != 0.)
   {
    for (i = 0; i < 3; i++)
     ecap_ext_vector[i] = unit_prj_vector[i] * ecap_extension;

    MAtrlmx (&rc, ecap_ext_vector, (IGRdouble *)ecap_ext_mat);
    EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_BSerror, wrapup);

    for (i = 0; i < 3; i++)
     prj_vector[i] += ecap_ext_vector[i];

    
   } /* if (ecap_extension != 0.) */

   OM_BLOCK_MOVE (prj_vector, prj_data.vector_format.projection,
                  sizeof(IGRdouble)*3);

   /*
    * If bcap_extension is not 0, translate the begin cap curve with
    * with bcap_extension. Post the new curve along with new projection
    * vector.
    */

   for (sfix = 0; sfix < num_prj_sfs; sfix++)
   {
     OM_stat = om$send (mode = OM_e_wrt_message,
                        msg = message EMSproject.EMget_params (&mthd_stat,
                         NULL, op1_elem_env, NULL, &sf_params),
                        senderid = NULL_OBJID,
                        targetid = prj_sfs_GRid[sfix].objid,
                        targetos = prj_sfs_GRid[sfix].osnum);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

     base_cv = &sf_params.params.project.curve;

     if (bcap_extension != 0.)
     {
       status = MArptsxform (&rc, &base_cv->num_poles, 
                  &base_cv->rational, base_cv->weights, 
                  (IGRdouble *)bcap_ext_mat, base_cv->poles, base_cv->poles);
        EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_BSerror, wrapup);
           
     } /* if (bcap_extension != 0.) */

     OM_stat = om$send (msg = message EMSsubbs.EMgetbsdef (&mthd_stat,
                         &sf_def),
                        senderid = NULL_OBJID,
                        targetid = prj_sfs_GRid[sfix].objid,
                        targetos = prj_sfs_GRid[sfix].osnum);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

     OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                         &op1_elem_env->md_env.matrix_type,
                         op1_elem_env->md_env.matrix, &DisplayMode, 
                         &op1_elem_env->md_id),
                        senderid = NULL_OBJID,
                        targetid = prj_sfs_GRid[sfix].objid,
                        targetos = prj_sfs_GRid[sfix].osnum);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

     OM_stat = om$send (msg = message EMSproject.EMputProjectedFormat (
                         &mthd_stat, op1_elem_env, &post_info, 
                         sf_def.pos_orient, base_cv, EMSIS_PJ_VECTOR,
                         &prj_data),
                        senderid = NULL_OBJID,
                       targetid = prj_sfs_GRid[sfix].objid,
                        targetos = prj_sfs_GRid[sfix].osnum);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);
 
     if (base_cv->poles) om$dealloc (ptr = base_cv->poles);
     if (base_cv->knots) om$dealloc (ptr = base_cv->knots);
     if (base_cv->weights) om$dealloc (ptr = base_cv->weights);

   } /* for (sfix = 0; sfix < num_prj_sfs; sfix++) */
    
   /*
    * If the operand1 is of class EMSsfsolid and begin and/or end cap
    * extension is needed, we need to translate the end caps' 
    * geometry. The end_caps are at index 1 and 2 from the sfsoild 
    * object.
    */

   if (extend_info->object_classid == OPP_EMSsfsolid_class_id)
   {
    
    OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
    EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

    for (i = 0; i < 2; i++)
    {
     cap_tr_mat = NULL;

     if (!i)          /* bcap_extension */
     {
      if (bcap_extension != 0.)
      {
       cap_tr_mat = (IGRdouble *)bcap_ext_mat;
       ed_options = v_prj_dir ? EMS_OPT_NAT_LOC3 : EMS_OPT_NAT_LOC0;
      }       
     }           /* bcap_extension */
     else
     {
      if (ecap_extension != 0.)
      {
       cap_tr_mat = (IGRdouble *)ecap_ext_mat;
       ed_options = v_prj_dir ? EMS_OPT_NAT_LOC1 : EMS_OPT_NAT_LOC2; 
      }
     }
   
     if (cap_tr_mat)
     {
      array_size = 1;
      count = 0;
      OM_stat = om$send (msg = message EMSsubbs.EMget_edges (&mthd_stat,
                        MAXINT, ed_options, op1_elem_env, &prj_sf_ed, 
                        &array_size, (IGRint *)&count),
                       senderid = NULL_OBJID,
                       targetid = prj_sfs_GRid[0].objid,
                       targetos = prj_sfs_GRid[0].osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

      OM_stat = om$get_channel_objects (objid = prj_sf_ed->objid, 
                   osnum = op1_os,
                   p_chanselect = &cm_ed_chan, size = 1, 
                   list = &cm_ed_list, count = &count);
      EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
 
      OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info (
                         &mthd_stat, &cap_sf, NULL),
                        senderid = NULL_OBJID,
                        targetid = cm_ed_list.S_objid,
                        targetos = op1_os);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_EdgeError, wrapup);

      status = MAtypemx (&rc, cap_tr_mat, &cap_tr_mattyp);
      EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_BSerror, wrapup);

      OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                         &op1_elem_env->md_env.matrix_type,
                         op1_elem_env->md_env.matrix, &DisplayMode, 
                         &op1_elem_env->md_id),
                        senderid = NULL_OBJID,
                        targetid = cap_sf, targetos = op1_os);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

      OM_stat = om$send ( msg = message GRgraphics.GRxform (&mthd_stat,
                           op1_elem_env, &cap_tr_mattyp, cap_tr_mat, 
                           &dum_id),
                          senderid = NULL_OBJID,
                          targetid = cap_sf, targetos = op1_os);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

    } /* if (cap_tr_mat) */

   } /* for (i = 0; i < 2; i++) */

  } /* if (extend_info->object_classid == OPP_EMSsfsolid_class_id) */

#if DEBUG
     DisplayMode = GRbd;
     OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                         &op1_elem_env->md_env.matrix_type,
                         op1_elem_env->md_env.matrix, &DisplayMode, 
                         &op1_elem_env->md_id),
                        senderid = NULL_OBJID,
                        targetid = op1_elem,
                        targetos = op1_os);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);
#endif

  } /* if (bcap_extension != 0. || ecap_extension != 0.) */

  /*
   * Get the point to be used for sorting out the intersections
   * 
   * o Extend Begin point -- Get the end point 
   * o Extend End point   -- Get the begin point
   * o Extend Both end point -- Get the middle point.
   */

  switch (extend_info->extension_type)
  {
   case EMSextend_begin_cap:
     sortpt_uv[0] = 0.5;
     sortpt_uv[1] = 1.0;
     break;

   case EMSextend_end_cap:
    sortpt_uv[0] = 0.5;
    sortpt_uv[1] = 0.0;
    break;

   case EMSextend_both_ends:
     sortpt_uv[0] = 1.0;
     sortpt_uv[1] = 0.5;
    break;

  } /* switch (extend_info->extension_type) */

  if (!v_prj_dir)
  {
   temp_double = sortpt_uv[0];
   sortpt_uv[0] = sortpt_uv[1];
   sortpt_uv[1] = temp_double;
  }

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

  OM_stat = om$get_channel_objects (osnum = prj_sfs_GRid[0].osnum,
               objid = prj_sfs_GRid[0].objid, p_chanselect = &sf_ls_chan,
               list = &ls_list, size = 1, count = &count);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  partolbasis.is_valid = FALSE;
  partolbasis.in_world = TRUE;
  partolbasis.mattyp = &op1_elem_env->md_env.matrix_type;
  partolbasis.mat = op1_elem_env->md_env.matrix;

  OM_stat = om$send (msg = message EMSloopset.EMpt_location (&mthd_stat,
                      sortpt_uv, &sortpts_info[0].ptloc_info, 
                      &partolbasis),
                    senderid = NULL_OBJID,
                    targetid = ls_list.S_objid, targetos = ls_list.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

  (*num_pts) = 1;
  sortpts_info->md_env = *op1_elem_env;
  sortpts_info->sf_id = prj_sfs_GRid[0].objid;

 } /* if (intersection_possible) */
 else
 {
   *EFmsg = EMS_I_NoIntersection;
   goto wrapup;
 }
 wrapup:
  if (prj_sfs_GRid) om$dealloc (ptr = prj_sfs_GRid);
  if (sf_geom) om$dealloc (ptr = sf_geom);

  return;

} /* EFextend_sf_to_intersection () */


 void EFget_prj_sfs (EFmsg, obj_id, md_env, obj_classid, 
                     num_prj_sfs, prj_sfs_GRid)
  IGRlong           *EFmsg;
  GRobjid           obj_id;
  struct GRmd_env   *md_env;
  OMuword           obj_classid;
  IGRint            *num_prj_sfs;
  struct GRid       **prj_sfs_GRid;

{
  OM_S_CHANSELECT   to_cmpnts_chan;
  IGRlong           OM_stat, mthd_stat;
  IGRint            count;
  GRobjid           owner_id;
  GRspacenum        cur_os;
  OMuword           owner_classid;
  extern IGRlong    EMmake_chanselect();

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  cur_os = md_env->md_id.osnum;

  if (obj_classid == OPP_EMSproject_class_id)
  {
    (*prj_sfs_GRid) = (struct GRid *) om$malloc (size = 
                                                   sizeof(struct GRid));
    EMerr_hndlr (!(*prj_sfs_GRid), *EFmsg, EMS_E_NoDynamicMemory,wrapup);

    (*prj_sfs_GRid)->objid = obj_id;
    (*prj_sfs_GRid)->osnum = cur_os;
    (*num_prj_sfs) = 1;
   }
   else
   {
    if (obj_classid == OPP_EMSsfsolid_class_id)
    {
     OM_stat = EMmake_chanselect (GRcmpowner_to_components,
                                  &to_cmpnts_chan);
     EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_Fail, wrapup);

     OM_stat = om$get_objid_at_index (objid = obj_id, osnum = cur_os,
                  p_chanselect = &to_cmpnts_chan, index = 0,
                  objidaddr = &owner_id, osnumaddr = &cur_os);
     EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

    } /* if (extend_info->object_classid == OPP_EMSsfsolid_class_id) */
    else
      owner_id = obj_id;

    OM_stat = om$get_classid (objid = owner_id, osnum = cur_os,
                              p_classid = &owner_classid);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

    OM_stat = om$is_ancestry_valid (subclassid = owner_classid,
                      superclassid = OPP_EMSprjcompsf_class_id);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

    if (OM_stat == OM_S_SUCCESS)
    {
     OM_stat = om$send (msg = message GRowner.GRget_number_components (
                         &mthd_stat, num_prj_sfs),
                        senderid = NULL_OBJID,
                        targetid = owner_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_Fail,wrapup);

     (*prj_sfs_GRid) = (struct GRid *) om$malloc (size = (*num_prj_sfs) *
                                         sizeof(struct GRid));
     EMerr_hndlr (!(*prj_sfs_GRid), *EFmsg, EMS_E_NoDynamicMemory,wrapup);
 
    OM_stat = om$send (msg= message GRowner.GRget_components (&mthd_stat,
                        md_env, *prj_sfs_GRid, *num_prj_sfs, &count, 0,
                        MAXINT),
                       senderid = NULL_OBJID,
                       targetid = owner_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_Fail, wrapup);

    } /* if (OM_stat == OM_S_SUCCESS) */
    else
    {
     (*prj_sfs_GRid) = (struct GRid *) om$malloc (size = 
                                                   sizeof(struct GRid));
     EMerr_hndlr (!(*prj_sfs_GRid), *EFmsg, EMS_E_NoDynamicMemory,wrapup);

     (*prj_sfs_GRid)->objid = owner_id;
     (*prj_sfs_GRid)->osnum = cur_os;
     (*num_prj_sfs) = 1;

    } /* owner is a single surface */
     
   } /* if (extend_info->object_classid == OPP_EMSproject_class_id) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "EFget_prj_sfs");
  return;

} /*  void EFget_prj_sfs () */


end implementation EMSsurface;
