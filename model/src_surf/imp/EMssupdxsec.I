/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "msdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "EMSprop.h"
#include "EMSxsection.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"    /* needed for gocmacros.h */
#include "gocmacros.h"
#include "EMSssprops.h"
#include "EMSchatch.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "matypemx.h"
#include "mamulmx.h"
#include "mainvmx.h"
#include "bssfarrevn.h"
#include "bsrev_cv.h"
#include "bsbx2.h"

from EMSedge     import EMdebug_display, EMset_props, EMgetbounds,
                        EMendpts;

from EMSpartedge import EMputbounds;

from EMSloop     import EMperform_xsection_update, EMtreemod, EMset_props;

from EMSboundary import EMget_objid, EMuv_transform;

from EMSloopset  import EMget_loops;

from EMSxsec_st  import EMget_sf_rmvd_eds;

from EMSgradata  import EMget_class_info, EMuv_transform;
 
from EMSchatch   import EMgetdef;

extern OMuword    OPP_EMSpartedge_class_id, OPP_EMSchatch_class_id;

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;


/*
   History
            RC   09/23/88      Creation Date
            RC   03/08/89      Modified arguments of EMSchatch.EMgetdef
            DLB  04/17/89      Added EMset_inactive send to handle pre 
                               1.2.0 OS which doesn't have the inactive 
                               bit set.
            RC   01/03/90      Commented some code used for debugging.
            NP   08/26/92      Modified for ANSI compliance.
           Sudha 07/07/93      Modified for BSprototypes ansification

*/

method EMperform_xsection_update (
       IGRlong                       *EMmsg;
       struct   GRvg_construct       *construct_list;
       struct   GRmd_env             *cs_env, *mdl_env;
       struct   EMSsfs_md_info       *sfs_md_info;
       struct   EMSxsreg_md_info     *reg_md_info;
       struct   EMSxs_assoc_info     *xs_assoc_info;
       GRrange                       mdl_range;
       struct   GRid                 *xs_act_st_GRid;
       IGRboolean                    *is_sf_active)

{
 OM_S_CHANSELECT            sf_ls_chan, ls_sf_chan, ls_lp_chan,
                            to_gd_chan, to_owners_chan, to_cmpnt_chan;
 struct EMSxh_info          xh_info;
 struct EMSfnmgr_info       ofnmgr_info, rfnmgr_info;
 struct EMSxs_tp_upd_info   xs_tp_info;
 struct EMSxs_ed_match_info ed_match_info;
 struct EMSedgebound        bounds[2], tmp_bound;
 struct GRid                ls_GRid, my_GRid, *mdl_sfs, *sf_eds = NULL,
                            owner_GRid;
 struct EMSuvtrans_info     rpl_info;
 struct EMSdataselect       model_data;
 struct EMSinters           *xp_inters, *mdl_inters, *mdl_inters_ptr;
 struct EMSxs_assoc_info    my_assoc_info, md_sfs_old_int;
 struct EMSintobj           *intobj_ptr;
 struct EMSpartolbasis      partolbasis;
 struct EMSintobj           ***elems[2];
 struct IGRbsp_surface      *my_gm, pl_gm;
 struct GRpost_info         post_info;
 struct EMSxs_lp_info       *lp_info;
 struct EMSnest_info        nesting;
 
 GRrange                    my_range, pl_range;

 enum   GRdpmode            DisplayMode;

 IGRdouble                  dis_tol, u_knots[4], v_knots[4], u, v, 
                            seg_pts[6], pl_nrml[3], win_zvec[3], 
                            rot_mat[16], xform_mat[16], md_algn_mat[16], 
                            xh_mat[16], poles[12], 
                            *ed_u0_pts = NULL, *ed_u1_pts = NULL, *pnts,
                            temp_double, beg_pt[2], end_pt[2], *ned_pts;
  

 IGRlong                    OM_stat, mthd_stat, num_inters = 0, rc, 
                            num_pts;
 extern IGRlong             EMsspbtol_by_geom();

 IGRint                     num_mdl_sfs, stat, i, j, cur_sf, arrsz, depth,
                            num_lps, *num_eds_sf, num_lps_rmvd = 0,
                            num_lps_added = 0, num_grps[2], 
                            *num_sgrps_grp[2],
                            **num_elems_sgrp[2], INITIAL_SIZE, BUF_INC,
                            my_assoc_ed_inx,
                            sf_inx, /*nat_bd_inx,*/ num_old_eds = 0,
                            num_ed_u0_pts = 0, num_ed_u1_pts = 0, 
                            num_pnts, cur_lp, cur_ed, num_ned_pts, 
                            ned_inx, oed_inx, osf_inx, nsf_inx, 
                            old_eds_arrsz = 0, num_svst_eds = 0,
                            svst_ed_arrsz = 0, num_sf_eds = 0,
                            sf_ed_arrsz = 0, cm_inx;
 IGRuint		    composite_inx; /*om$get_index needs ptr to IGRuint*/
 extern IGRint              EMfix_and_refine_intdata();

 OMuword                    ed_classid, gd_classid;

 IGRshort                   dim = 4, rot_mattyp, md_algn_mattyp;

 GRobjid                    *lp_added_ids, *sfs_list, *eds_list, dum_id, 
                            newobjid, ed_id, *old_eds = NULL, 
                            *svst_eds = NULL;

 IGRushort          outworld_options, trim_options, 
                            outparam_options, inters_options;

 IGRboolean                 **sgrp_rev[2], status,
                            xp_non_aligned = FALSE, world_flag = TRUE,
                            ***elem_rev[2], *grp_clsd[2], **sgrp_clsd[2],
                            open_grps_exist, my_gm_md = FALSE,
                            lp_md, sf_erased, old_nat_eds_exist,
                            xh_exists = FALSE, cm_sf_exists, blksize,
                            pl_mdl_int;

extern IGRboolean EFsrf1uv_to_srf2uv() ;

 IGRchar                    *cache_ptr = NULL;

 IGRboolean                 save_pathway_trim, save_pathway_orient;

 extern IGRlong             EMintersect_surfaces();
 extern void                EMsfinttrace(), EFmk_xsec_lps(),
                            EFmemory_allocation(), EMsfinttrace_free(),
                            EFconstruct_xs_plane(),
                            EFcreate_eds_to_cls_grps(),
                            EFperform_old_new_int_correlation (),
                            EFsave_xs_assoc_info(),
                            EFget_grp_end_pts_matching_w_ed_U0_U1(),
                            EFadd_ed_to_trace_list(), EFupdate_new_int(),
                            EFupdate_assoc_inters(), 
                            EFperform_tp_correaltion(),
                            EFfnmgr_manipulation(), EMinters_data_free(),
                            EMinters_free(), EFget_xhatch_tr_mat ();

 /*************************************************************/


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 my_assoc_info.sf_list = my_assoc_info.ed_list = NULL;
 my_assoc_info.num_eds_sf = NULL;
 my_assoc_info.sf_list_arrsz = my_assoc_info.num_sfs = 0;
 my_assoc_info.ed_list_arrsz = my_assoc_info.num_eds = 0;

 md_sfs_old_int.sf_list = md_sfs_old_int.ed_list = NULL;
 md_sfs_old_int.num_eds_sf = NULL;
 md_sfs_old_int.sf_list_arrsz = md_sfs_old_int.num_sfs = 0;
 md_sfs_old_int.ed_list_arrsz = md_sfs_old_int.num_eds = 0;

 xs_tp_info.num_lps = 0;
 xs_tp_info.lps_info = NULL;

 ed_match_info.num_eds = ed_match_info.eds_arrsz = 0;
 ed_match_info.old_ed_ids = ed_match_info.new_ed_ids = NULL;
 ed_match_info.match_type = NULL;
 ed_match_info.ed_bnds = 0;
 
 xp_inters = mdl_inters = NULL;
 my_gm = NULL;
 lp_added_ids = NULL;
 
 rpl_info.ed_ids = rpl_info.rpl_ed_ids = NULL;
 rpl_info.num_eds = rpl_info.eds_arrsz = 0;

 /*
  * If I am inactive surface, I am erased too.
  */

 { /*Intentional block. -DLB*/
   IGRlong dlb_loc_msg;
   IGRboolean did_set_inactive;
   OM_stat = om$send(msg = message EMSsubbs.EMset_inactive(
                           &dlb_loc_msg, &did_set_inactive),
                     targetid = my_id);
 }

 sf_erased = ( me->ss_props & EMSIS_INACTIVE ) ? TRUE : FALSE;

 BSEXTRACTPAR (&rc, BSTOLLENVEC,dis_tol);
 
 OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 OM_stat = EMmake_chanselect (EMSloopset_to_surface, &ls_sf_chan);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 OM_stat = EMmake_chanselect (GRconnector_to_owners, &to_owners_chan);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 partolbasis.in_world = partolbasis.is_valid = TRUE;
 partolbasis.mattyp = &cs_env->md_env.matrix_type;
 partolbasis.mat = cs_env->md_env.matrix;

 OM_stat = om$send (msg = message EMSsubbs.EMpartolbasis ( &mthd_stat,
                    &cs_env->md_env.matrix_type, cs_env->md_env.matrix,
                    &world_flag, FALSE, &partolbasis.tol),
                  targetid = my_id);
 EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

 ls_GRid.objid = NULL_OBJID; 
 ls_GRid.osnum = OM_Gw_current_OS;
 if ( !(me->ss_props & EMSIS_INACTIVE) )
 {
  OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                      &ls_GRid.objid), p_chanselect = &sf_ls_chan);
  EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_LoopsetError, wrapup);

 } /* if ( !(me->ss_props & EMSIS_INACTIVE) ) */

 /*
  * If I have been translated and/or rotated for alignemnt
  * purposes, transform me back to orientation to be used
  * cross_section.
  */

 OM_stat = om$send (msg = message EMSxsplane.EMget_alignment_matrix (
                     &mthd_stat, cs_env, rot_mat, &rot_mattyp),
                    targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

 if (rot_mattyp != MAIDMX)
 {
   xp_non_aligned = TRUE;

   OM_stat = om$send (msg = message EMSxsection.EMxsec_int_xform (
                       &mthd_stat, cs_env, &rot_mattyp, rot_mat, 
                       NULL, &newobjid, TRUE),
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

/*
  THE FOLLOWING DISPLAY IS FOR DISPLAY ONLY 
*/
/*
     DisplayMode = GRbd;
     OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                          &cs_env->md_env.matrix_type,
                          cs_env->md_env.matrix, &DisplayMode,
                          &cs_env->md_id),
                         targetid = my_id);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
*/
   /*
    * If the cross section plane is non_aligned, it will be transformed
    * back after the update is over. Also, in case of non_aligned
    * case, when the surface is erased, it should use module matrix
    * which brings it to aligned format.
    */

   status = MAinvmx (&rc, &dim, rot_mat, rot_mat);
   EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
   
   status = MAtypemx (&rc, rot_mat, &rot_mattyp);
   EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

   status = MAmulmx (&rc, &dim, &dim, &dim, 
                     cs_env->md_env.matrix, rot_mat, md_algn_mat);
   EMerr_hndlr (!status || !(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   status = MAtypemx (&rc, md_algn_mat, &md_algn_mattyp);
   EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

 } /* if (rot_mattyp != MAIDMX) */

 /*
  * If the surfaces have been added/geometrically modified,
  * it may be possible that my geometry is not large enough to
  * cover the model. In such a case, 
  *  
  *  o stretch my geometry.
  *  o transform my boundaries to correspond to the modified
  *    geometry.
  */

 if (sfs_md_info->num_sfs_added || sfs_md_info->num_sfs_gm_md) 
 {
   GRgetabsg (&rc, &cs_env->md_env.matrix_type, cs_env->md_env.matrix,
              &cache_ptr, i);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_SurfaceError, wrapup);

   my_gm = (struct IGRbsp_surface *) cache_ptr;

   u = 0;
   v = 0;
   BSsfarrevn (&rc, my_gm, 1, &u, 1, &v, seg_pts, pl_nrml);
   EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   OM_BLOCK_MOVE (&my_gm->poles[3], &seg_pts[3], sizeof(IGRpoint));

   pl_gm.poles = poles;
   pl_gm.u_knots = u_knots;
   pl_gm.v_knots = v_knots; 

   for (i = 0; i < 3; i++)
    win_zvec[i] = my_gm->poles[6+i] - my_gm->poles[i];

   EFconstruct_xs_plane (&rc, mdl_range, seg_pts, pl_nrml, win_zvec,
                         1.05, &pl_gm, &pl_mdl_int);
   EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

   if (pl_mdl_int)
   {
    num_pts = 4;
    status = BSbx2 (&rc, &num_pts, (IGRpoint *)my_gm->poles, NULL, my_range,
                    &my_range[3]);
    EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 
    status = BSbx2 (&rc, &num_pts, (IGRpoint *)pl_gm.poles, NULL, pl_range,
                    &pl_range[3]);
    EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 
    if ((pl_range[0] < my_range[0] && (my_range[0]-pl_range[0]) > dis_tol)
                                  || 
       (pl_range[1] < my_range[1] && (my_range[1]-pl_range[1]) > dis_tol)
                                  ||
       (pl_range[2] < my_range[2] && (my_range[2]-pl_range[2]) > dis_tol)
                                  || 
       (pl_range[3] > my_range[3] && (pl_range[3]-my_range[3]) > dis_tol)
                                  ||
       (pl_range[4] > my_range[4] && (pl_range[4]-my_range[4]) > dis_tol)
                                  || 
       (pl_range[5] > my_range[5] && (pl_range[5]-my_range[5]) > dis_tol))
 
    {
     my_gm_md = TRUE;
     status = EFsrf1uv_to_srf2uv (my_gm, &pl_gm, xform_mat, &rc);
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

     /*
      * Some of my loops may be stored in save_state info.
      * Get the edges of these loops, transform them and update fan manger
      * tips ids if any of the edges have been replaced.
      */

     if (!(ME.EMSsubbs->ss_props & EMSIS_INACTIVE))
     {
       OM_stat = om$send (msg = message EMSsubbs.EMget_edges (&mthd_stat,
                           MAXINT, EMS_OPT_ALL, cs_env, &sf_eds,
                           &sf_ed_arrsz, &num_sf_eds),
                          targetid = my_id);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
     } /* if (!(ME.EMSsubbs->ss_props & EMSIS_INACTIVE)) */

     OM_stat = om$send (msg = message EMSxsec_st.EMget_sf_rmvd_eds (
                         &mthd_stat, my_id, sf_eds, num_sf_eds, 
                         &svst_eds, &num_svst_eds, &svst_ed_arrsz),
                        targetid = xs_act_st_GRid->objid,
                        targetos = xs_act_st_GRid->osnum);
     if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_Fail, wrapup);

     for (i = 0; i < num_svst_eds; i++)
     {
      OM_stat = om$send (msg = message EMSboundary.EMuv_transform (
                          &mthd_stat, xform_mat, &partolbasis, 
                          EMS_TF_TRANSFORM_NE | EMS_TF_NO_PE_TRANSFORM, 
                          (IGRchar *)my_gm, (IGRchar *)&rpl_info),
                         targetid = svst_eds[i]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
     
     } /* for (i = 0; i < num_svst_eds; i++) */

     if ( !(ME.EMSsubbs->ss_props & EMSIS_INACTIVE) )
     {
      OM_stat = om$send (msg = message EMSboundary.EMuv_transform (
                         &mthd_stat, xform_mat, &partolbasis, 
                         EMS_TF_TRANSFORM_NE | EMS_TF_NO_PE_TRANSFORM, 
                         (IGRchar *)my_gm, (IGRchar *)&rpl_info),
                        targetid = ls_GRid.objid);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

      /*
       * My graphic data object refer to my old geometry. Need
       * to transform also.
       * If the graphics data is of cross_hatch type, we need
       * to calculate a transformation matrix to go from original
       * rotated plane to tranformed rotated plane.
       */

      OM_stat = EMmake_chanselect (EMSrequester_to_helpers, &to_gd_chan);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      OM_stat = om$send (msg = message EMSgradata.EMget_class_info (
                          &mthd_stat, &gd_classid, NULL),
                         p_chanselect = &to_gd_chan);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

      OM_stat = om$is_ancestry_valid (subclassid = gd_classid,
                                   superclassid = OPP_EMSchatch_class_id);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
 
      if (OM_stat == OM_S_SUCCESS)
      {
       xh_exists = TRUE;
       OM_stat = om$send (msg = message EMSchatch.EMgetdef (&mthd_stat,
                           &xh_info),
                          p_chanselect = &to_gd_chan, from = 0, to = 0);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

       EFget_xhatch_tr_mat (&rc, xh_info.angle, my_gm, &pl_gm, xh_mat);
       EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_Fail, wrapup);
                              
      } /* if (OM_stat == OM_S_SUCCESS) */

      OM_stat = om$send (msg = message EMSgradata.EMuv_transform (
                          &mthd_stat, xh_exists ? xh_mat : xform_mat, 
                          &partolbasis, NULL),
                         p_chanselect = &to_gd_chan);
      EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

     } /* if ( !(ME.EMSsubbs->ss_props & EMSIS_INACTIVE) ) */

     /*
      * If any of the edges have been reaplced, update the 
      * fan_manager association information.
      */

     if (rpl_info.num_eds)
     {
      ofnmgr_info.tips = rpl_info.ed_ids;
      rfnmgr_info.tips = rpl_info.rpl_ed_ids;
      ofnmgr_info.num_tips = rfnmgr_info.num_tips = rpl_info.num_eds;

      EFfnmgr_manipulation (&rc, OM_Gw_current_OS, EMSlabel_xsection,
                            EMSFM_MANIP_RPL, EMSFM_KEY_TIP, 
                            &ofnmgr_info, &rfnmgr_info);
      EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

     } /* if (rpl_info.num_eds) */

     /*
      * Post my new geometry.
      */

     post_info.construct_flag = FALSE;
  
     OM_stat = om$send (msg = message GRvg.GRpostabsg (&mthd_stat,
                         cs_env, &post_info, (IGRchar *) &pl_gm,
                         &dum_id),
                        targetid = my_id);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    }

    if (cache_ptr) GRabsg_del(cache_ptr);
    my_gm = NULL;
    cache_ptr = NULL;

   } /* if (pl_mdl_int) */

 } /* if (sfs_md_info->num_sfs_added || sfs_md_info->num_sfs_gm_md) */

 /*
  * Disconnect the loopset from the surface before performing 
  * intersections with the added/modified surfaces. This is to
  * avoid trimming of the new intersections w.r.t existing plane
  * intersections.
  */

 if ( !(me->ss_props & EMSIS_INACTIVE) )
 {
   OM_stat = om$send (msg = message Root.wild_disconnect (sf_ls_chan),
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 } /* if ( !(me->ss_props & EMSIS_INACTIVE) ) */

 /*
  * For all of the surfaces that are added, geometrically/topologically
  * modified:
  *  1. Perform the intersection between surface and me.
  *  2. trace the intersection.
  *  3. refine the intersection.
  */

 if (pl_mdl_int)
 {
  outparam_options = NULL | EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT;
  outworld_options = NULL | EMSINT_OUTPUT_WORLD | EMSINT_ORIENT_OUTPUT |
                     EMSINT_ORIENT_RIGHT;
  trim_options = NULL | EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA;
  inters_options = EMS_SFINT_MUSTORIENT |
                   EMS_SFINT_DOUBLECHECK |
                   EMS_SFINT_MUSTNOAMBIGUOUS | EMS_SFINT_NOREFINE;

  model_data.datatype = EMSdata_object;

  ex$message(msgnumb = EMS_I_EvalModSfNewInt)

  for (i = 0; i < 3; i++)
  {
   switch (i)
   {
     /*
      * Newly added surfaces.
      */
     case 0:
      mdl_sfs = sfs_md_info->sfs_added;
      num_mdl_sfs = sfs_md_info->num_sfs_added;
     break;

     /*
      * Geometrically modified surfaces.
      */
     case 1:
      mdl_sfs = sfs_md_info->sfs_gm_md;
      num_mdl_sfs = sfs_md_info->num_sfs_gm_md;
     break;

     /*
      * Topologically modified surfaces.
      */
     case 2:
      mdl_sfs = sfs_md_info->sfs_tp_md;
      num_mdl_sfs = sfs_md_info->num_sfs_tp_md;
     break;

   } /* switch (i) */


   for (cur_sf = 0; cur_sf < num_mdl_sfs; cur_sf++)
   {
     model_data.data.object = &mdl_sfs[cur_sf];

     save_pathway_trim = _pathway_trim;
     save_pathway_orient = _pathway_orient;
     _pathway_trim = 0;
     _pathway_orient = 0;
     
     OM_stat = EMintersect_surfaces (&mthd_stat, &my_GRid, cs_env, 1,
                  &model_data, mdl_env, inters_options, outworld_options,
                  outparam_options, trim_options, construct_list, 
                  &num_inters, &xp_inters, &mdl_inters, NULL, NULL,
                  NULL, NULL, NULL);

     _pathway_trim = save_pathway_trim;
     _pathway_orient = save_pathway_orient;

     EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

   } /* for (cur_sf = 0; cur_sf < num_mdl_sfs; cur_sf++) */

  } /* for (i = 0; i < 3; i++) */

 }/* if (pl_mdl_int) */

 /*
  * Connect the surface to the loopset.
  */

 if ( !(me->ss_props & EMSIS_INACTIVE) )
 {
  OM_stat = om$send (msg = message Root.connect (sf_ls_chan, NULL,
                      ls_GRid.objid, ls_GRid.osnum, ls_sf_chan, NULL),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 } /*  if ( !(me->ss_props & EMSIS_INACTIVE) ) */

 /*
  * Trace and refine the interseaction data
  */

 if (num_inters)
 {
   num_sgrps_grp[0] = num_sgrps_grp[1] = NULL;
   num_elems_sgrp[0] = num_elems_sgrp[1] = NULL;
   elems[0] = elems[1] = NULL;
   sgrp_rev[0] = sgrp_rev[1] = NULL;
   elem_rev[0] = elem_rev[1] = NULL;
   grp_clsd[0] = grp_clsd[1] = NULL;
   sgrp_clsd[0] = sgrp_clsd[1] = NULL;

   EMsfinttrace (&rc, &cs_env->md_env.matrix_type, 
                 cs_env->md_env.matrix, xp_inters, NULL, 
                 &dis_tol, &num_grps[0], &num_sgrps_grp[0], 
                 &num_elems_sgrp[0], &elems[0], &sgrp_rev[0], 
                 &elem_rev[0], &grp_clsd[0], &sgrp_clsd[0]);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   EMsfinttrace (&rc, &mdl_env->md_env.matrix_type, 
                 mdl_env->md_env.matrix, mdl_inters, NULL, 
                 &dis_tol, &num_grps[1], &num_sgrps_grp[1], 
                 &num_elems_sgrp[1], &elems[1], &sgrp_rev[1], 
                 &elem_rev[1], &grp_clsd[1], &sgrp_clsd[1]);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   stat = EMfix_and_refine_intdata (&rc, &cs_env->md_env.matrix_type,
                 cs_env->md_env.matrix, 
                 &mdl_env->md_env.matrix_type,
                 mdl_env->md_env.matrix, construct_list, 
                 xp_inters, mdl_inters, NULL, &dis_tol, NULL, 
                 num_grps, num_sgrps_grp, num_elems_sgrp, elems, sgrp_rev,
                 elem_rev, grp_clsd, sgrp_clsd, inters_options, 
                 outworld_options, outparam_options, trim_options);
   EMerr_hndlr (!(1&rc&stat), *EMmsg, EMS_E_Fail, wrapup);

   /*
    * Get the end points of the groups that lie on
    * EDGE U0 and EDGE U1
    */

   EFget_grp_end_pts_matching_w_ed_U0_U1 ( &rc, num_grps[0], 
                   grp_clsd[0], num_sgrps_grp[0], num_elems_sgrp[0], 
                   elems[0], partolbasis.tol, &ed_u0_pts, &ed_u1_pts, 
                   &num_ed_u0_pts, &num_ed_u1_pts);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   for (i = 0; i < 2; i++)
    EMsfinttrace_free(&rc, num_grps[i], num_sgrps_grp[i],
        num_elems_sgrp[i], elems[i], sgrp_rev[i], elem_rev[i], 
        grp_clsd[i], sgrp_clsd[i]);

   /*
    * If any of the new intersections are marked as reversed in
    * its intobj struture, modify its uv_data/xyz_data such that
    * it is not marked reversed any more.
    */

   intobj_ptr = xp_inters->cvs;
   while (intobj_ptr)
   {
    if (intobj_ptr->reversed)
    {
      /*
       * Reverse the edge.
       */

      ed_id = intobj_ptr->this_uvintobj.data.object->objid;

      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                          EMED_REVERSED, EMS_O_TOGGLE),
                         targetid = ed_id);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      OM_stat = om$get_classid (objid = ed_id, 
                                p_classid = &ed_classid);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      OM_stat = om$is_ancestry_valid (subclassid = ed_classid,
                        superclassid = OPP_EMSpartedge_class_id);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      if (OM_stat == OM_S_SUCCESS)
      {
        OM_stat = om$send (msg = message EMSedge.EMgetbounds (
                            &mthd_stat, bounds),
                           targetid = ed_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        tmp_bound = bounds[0]; bounds[0] = bounds[1];
        bounds[1] = tmp_bound;

        OM_stat = om$send (msg = message EMSpartedge.EMputbounds (
                            &mthd_stat, bounds),
                           targetid = ed_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      } /* if (OM_stat == OM_S_SUCCESS) */

      /*
       * Reverse the model space data.
       */

      if (intobj_ptr->this_xyzintobj.datatype == EMSdata_curve3d)
      {
       status = BSrev_cv (&rc, intobj_ptr->this_xyzintobj.data.curve);
       EMerr_hndlr (!status || rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

      } /* if (intobj_ptr->this_xyzintobj.datatype == EMSdata_curve3d) */
      else
      {
        num_pnts = intobj_ptr->this_xyzintobj.data.poly->num_points - 1;
        pnts = intobj_ptr->this_xyzintobj.data.poly->points;

        for (i = 0; i < num_pnts/2 +1; i++)
        {
          for (j = 0; j < 3; j++)
          {
            temp_double = pnts[(num_pnts-i)*3+j];
            pnts[(num_pnts-i)*3+j] = pnts[i*3+j];
            pnts[i*3+j] = temp_double;
          }
        }
      } /* else for 
           if (intobj_ptr->this_xyzintobj.datatype == EMSdata_curve3d) */

      intobj_ptr->reversed = FALSE;

    } /* if (intobj_ptr->reversed) */

    intobj_ptr = intobj_ptr->next;

   } /* while (intobj_ptr) */

   /*
    * Collect the my edges/mdl_surfaces association 
    * information.
    */

   ex$message(msgnumb = EMS_I_CollectingAssocInf)

   num_mdl_sfs = sfs_md_info->num_sfs_gm_md + sfs_md_info->num_sfs_tp_md +
                 sfs_md_info->num_sfs_added + 
                 1;                    /* to store my_id as md sf */

   my_assoc_info.sf_list = (GRobjid *) om$malloc (size = num_mdl_sfs 
                              * sizeof(GRobjid));
   EMerr_hndlr(!my_assoc_info.sf_list, *EMmsg, EMS_E_NoDynamicMemory,
               wrapup);

   my_assoc_info.num_eds_sf = (IGRint *) om$malloc (size = 
                                num_mdl_sfs * sizeof(IGRint));
   EMerr_hndlr (!my_assoc_info.num_eds_sf, *EMmsg, EMS_E_NoDynamicMemory,
                wrapup);

   my_assoc_info.ed_list = (GRobjid *) om$malloc (size = num_inters *
                             sizeof (GRobjid) );
   EMerr_hndlr ( !my_assoc_info.ed_list, *EMmsg, EMS_E_NoDynamicMemory,
                 wrapup);
   my_assoc_info.sf_list_arrsz = num_mdl_sfs;
   my_assoc_info.ed_list_arrsz = num_inters;
   

   mdl_inters_ptr = mdl_inters;
   sfs_list = my_assoc_info.sf_list;
   eds_list = my_assoc_info.ed_list;
   num_eds_sf = my_assoc_info.num_eds_sf;

   while (mdl_inters_ptr)
   {
     intobj_ptr = mdl_inters_ptr->cvs;
     while (intobj_ptr)
     { 
      *eds_list =
           intobj_ptr->other_intobj_node->this_uvintobj.data.object->objid;
      eds_list++;
      intobj_ptr = intobj_ptr->next;

     } /* while (intobj_ptr) */
   
     *num_eds_sf = mdl_inters_ptr->num_cvs;
     my_assoc_info.num_eds += mdl_inters_ptr->num_cvs;
     num_eds_sf++;
     *sfs_list = mdl_inters_ptr->this_obj.objid;
     sfs_list++;
     my_assoc_info.num_sfs++;
     mdl_inters_ptr = mdl_inters_ptr->next;

   } /* while (mdl_inters_ptr) */
  
 } /* if (num_inters) */

 if (xp_inters)
     my_gm = (struct IGRbsp_surface *) xp_inters->more_info;
 else
 {
     GRgetabsg (&rc, &cs_env->md_env.matrix_type, cs_env->md_env.matrix,
                &cache_ptr, i);
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_SurfaceError, wrapup);

     my_gm = (struct IGRbsp_surface *) cache_ptr;

 } /* else for if (xp_inters) */

 /*
  * If the surface is active, it has some old intersections. In
  * such a case, need to validate the old intersections.
  */

if ( !(ME.EMSsubbs->ss_props & EMSIS_INACTIVE))
{
 depth = MAXINT;
 OM_stat = om$send (msg = message EMSloopset.EMget_loops (&mthd_stat,
                     EMS_OPT_ALL, &depth, NULL, NULL, NULL, &num_lps),
                    targetid = ls_GRid.objid, targetos = ls_GRid.osnum);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_LoopsetError, wrapup);

 /*
  * send the message to the loops to update its
  * boundaries w.r.t. the new intersections.
  */

 /*
  * It may be possible that my current boundaries have some
  * edges that are/or part of my natural edges. Need to take out
  * these edges. These may be used to determine their overlaps
  * with the new natural/pare_of natural edges to be put later on.
  * Thus put my id as topologically modified surface if my geometry
  * is not modified, otherwise add me as a geometrically modified sf.
  */

 INITIAL_SIZE = 1; BUF_INC = 0;
 if (my_gm_md)
 {
  if ((sfs_md_info->num_sfs_gm_md+1) > sfs_md_info->sfs_gm_md_arrsz)
  {
   EFmemory_allocation (&rc, (IGRchar **) &sfs_md_info->sfs_gm_md,
                       sfs_md_info->num_sfs_gm_md+1, 
                       &sfs_md_info->sfs_gm_md_arrsz, sizeof(struct GRid),
                       INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
  }
  sfs_md_info->sfs_gm_md[sfs_md_info->num_sfs_gm_md++] = my_GRid;

 } /* if (my_gm_md) */
 else
 {
  if ((sfs_md_info->num_sfs_tp_md+1) > sfs_md_info->sfs_tp_md_arrsz)
  {
   EFmemory_allocation (&rc, (IGRchar **) &sfs_md_info->sfs_tp_md,
                       sfs_md_info->num_sfs_tp_md+1, 
                       &sfs_md_info->sfs_tp_md_arrsz, sizeof(struct GRid),
                       INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
  }  
  sfs_md_info->sfs_tp_md[sfs_md_info->num_sfs_tp_md++] = my_GRid;

 } /* else for if (my_gm_md) */

 /*
  * Put myself in the association information. Take it out after
  * loops have been updated.
  */

 EFsave_xs_assoc_info (&rc, &my_assoc_info, my_id, &dum_id, 1);
 EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

 ex$message(msgnumb = EMS_I_CollectingUnaffecBdrys)

 xs_tp_info.lps_info = (struct EMSxs_lp_info *) om$malloc (
                        size = num_lps * sizeof (struct EMSxs_lp_info) );
 EMerr_hndlr(!xs_tp_info.lps_info, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

 OM_stat = om$send (msg = message EMSloop.EMperform_xsection_update (
                     &mthd_stat, &xs_tp_info, &my_assoc_info, 
                     &md_sfs_old_int, sfs_md_info),
                    senderid = ls_GRid.objid, p_chanselect = &ls_lp_chan);
 EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_LoopError, wrapup);

 /*
  * take out my_id from my_assoc_info.
  */

 (my_assoc_info.num_sfs)--; (my_assoc_info.num_eds)--;

 /*
  * If there are any new intersections and some of old intersections
  * are marked as modified,
  *
  *  o Find out if any of new_int/old_int overlap fully/partially.
  */

 if (num_inters && md_sfs_old_int.num_sfs)
 {
   ed_match_info.new_ed_ids = (GRobjid *) om$malloc (size = num_inters *
                                                     sizeof(GRobjid));
   EMerr_hndlr (!ed_match_info.new_ed_ids,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
  
   ed_match_info.old_ed_ids = (GRobjid *) om$malloc (size = num_inters *
                                                     sizeof(GRobjid));
   EMerr_hndlr (!ed_match_info.old_ed_ids,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
  
   ed_match_info.match_type = (IGRshort *) om$malloc (size = num_inters *
                                              sizeof(IGRshort) );
   EMerr_hndlr (!ed_match_info.match_type, *EMmsg, EMS_E_NoDynamicMemory, 
                wrapup);

   ed_match_info.ed_bnds = (struct EMSedgebound *) om$malloc (size =
                   num_inters * sizeof(struct EMSedgebound) * 2 );
   EMerr_hndlr (!ed_match_info.ed_bnds, *EMmsg, EMS_E_NoDynamicMemory,
                wrapup);
   ed_match_info.eds_arrsz = num_inters;

   EFperform_old_new_int_correlation ( &rc, OM_Gw_current_OS,
       &my_assoc_info, &md_sfs_old_int, sfs_md_info, &partolbasis, 
       &ed_match_info);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);     
  
 } /* if (num_inters && md_sfs_old_int) */

 /*
  * For each loop marked as modified, 
  * o Check if all of the old edges completely overlap new_edges.
  *  o If so, check if there are any edges of that loop that
  *    correspond to the edges U0 or U1 of the plane.
  *   o If so, determine if any of these edges are affected.
  *   o If not loop is not modified.
  *  else loop is modified and take appropriate action.
  */

if (xs_tp_info.num_lps)
{
 INITIAL_SIZE = BUF_INC = 10;
 EFmemory_allocation (&rc, (IGRchar **)&reg_md_info->reg_out_ids,
                      reg_md_info->num_reg_out + xs_tp_info.num_lps, 
                      &reg_md_info->reg_out_arrsz, sizeof(GRobjid),
                      INITIAL_SIZE, BUF_INC);
 EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

 /*
  * The following malloc is used for debugging purposes only.
  */

 if (ed_match_info.num_eds)
 {
   old_eds = (GRobjid *) om$malloc (size = ed_match_info.num_eds *
                                    sizeof(GRobjid));
   EMerr_hndlr (!old_eds, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   old_eds_arrsz = ed_match_info.num_eds;
 } 

 for (cur_lp = 0; cur_lp < xs_tp_info.num_lps; cur_lp++)
 {
  lp_info = &xs_tp_info.lps_info[cur_lp];
  lp_md = FALSE;

  for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++)
  {
   if (lp_info->ed_status[cur_ed] == EMSED_MD && 
       lp_info->ed_sf_ids[cur_ed] != my_id)
   {
    for (i = 0; i < ed_match_info.num_eds; i++)
    {
     if (ed_match_info.old_ed_ids[i] == lp_info->ed_ids[cur_ed] )
     {
      if (ed_match_info.match_type[i] != EMSXS_OLD_NEW_ED_MATCH_FULLY)
       lp_md = TRUE;
      break;

     } /* if (ed_match_info.old_ed_ids[i] ==lp_info->ed_ids[cur_ed]) */
 
    } /* for (i = 0; i < ed_match_info.num_eds; i++) */

    if (i == ed_match_info.num_eds) lp_md = TRUE;

   } /* if (lp_info->ed_status[cur_ed] == EMSED_MD && 
            lp_info->ed_sf_ids[cur_ed] != my_id) */

   else if (lp_info->ed_status[cur_ed] == EMSED_RMVD) lp_md = TRUE;
     
   if (lp_md) break;

  } /* for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++) */
    
  /*
   * If the none of edges generated by model surfaces have been
   * modified, check if the loop has any edges that are part of
   * edge U0 or U1 of the cross section plane. If so, if any
   * of these edges are modified. If not, loop is not modified.
   *
   * If the loop is not modified,
   *  o Take the intobjs from the xp_inters that correspond to 
   *    new edges which matched with the old edges of the loop.
   *
   * If the loop is modified,
   *  o Replace the edge id of the intobj with old edge id with
   *    which it fully matched. In case of partial match, 
   *    create a partial edge(s) and put their ids in appropriate
   *    intobjs.
   */

   if (!lp_md)
   {
     for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++)
     {
       if (lp_info->ed_sf_ids[cur_ed] == my_id)
       {
        OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                             beg_pt, end_pt, NULL, NULL, NULL),
                            targetid = lp_info->ed_ids[cur_ed]);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        if (end_pt[1] < beg_pt[1])
        {
          temp_double = end_pt[1];
          end_pt[1] = beg_pt[1];
          beg_pt[1] = temp_double;
        }
        beg_pt[1] += partolbasis.tol;
        end_pt[1] -= partolbasis.tol;

        if (beg_pt[0] == 0.)
        {
          num_ned_pts = num_ed_u0_pts;
          ned_pts = ed_u0_pts;
        }
        else
        {
          num_ned_pts = num_ed_u1_pts;
          ned_pts = ed_u1_pts;
        }

        for (i = 0; i < num_ned_pts; i++)
        {
          if (ned_pts[2*i+1] > beg_pt[1] && ned_pts[2*i+1] < end_pt[1])
          {
            lp_md = TRUE;     break;
          }
        } /* for (i = 0; i < num_new_nat_ed_pts; i++) */

       } /* if (lp_info->ed_sf_ids[cur_ed] == my_id) */
      
       if (lp_md) break;

     } /* for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++) */

   } /* if (!lp_md) */

   if (lp_md)
   {
    for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++)
    {
     if (lp_info->ed_status[cur_ed] == EMSED_UNMD)
     {
       EFadd_ed_to_trace_list (&rc, lp_info->ed_ids[cur_ed], &my_GRid,
                               my_gm, cs_env, &xp_inters);
       EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

     } /* if (lp_info->ed_status[cur_ed] == EMSED_UNMD) */

     else if (lp_info->ed_status[cur_ed] == EMSED_MD)
     {
      for (ned_inx = 0; ned_inx < ed_match_info.num_eds; ned_inx++)
      {
        if (lp_info->ed_ids[cur_ed] == ed_match_info.old_ed_ids[ned_inx])
        {
          EFupdate_new_int (&rc, ed_match_info.old_ed_ids[ned_inx],
                            ed_match_info.new_ed_ids[ned_inx], 
                            ed_match_info.match_type[ned_inx], 
                            &ed_match_info.ed_bnds[ned_inx*2],
                            xp_inters, &my_assoc_info, 
                            lp_info->ed_sf_ids[cur_ed], OM_Gw_current_OS,
                            old_eds, &num_old_eds);
          EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

        } /* if (lp_info->ed_ids[cur_ed] == 
                 ed_match_info.old_ed_ids[ned_inx]) */

      } /* for (ned_inx = 0; ned_inx < ed_match_info; ned_inx++) */
       
 
 
     } /* else if (lp_info->ed_status[cur_ed] == EMSED_MD) */

    } /* for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++) */

    /*
     * Erase the surface if not done yet.
     */
    
    if (!sf_erased)
    {
     DisplayMode = GRbe;
     OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                         xp_non_aligned ? &md_algn_mattyp :
                          &cs_env->md_env.matrix_type,
                         xp_non_aligned ? md_algn_mat :
                          cs_env->md_env.matrix, &DisplayMode,
                          &cs_env->md_id),
                         targetid = my_id);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

     sf_erased = TRUE;

    } /* if (!sf_erased) */

    /*
     * Take out the modified loop from the loopset and save
     * it for save state information.
     */

    OM_stat = om$send (msg = message EMSloop.EMtreemod (&mthd_stat,
                        &nesting, EXTRACT, &partolbasis),
                       targetid = lp_info->lp_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_LoopError, wrapup);

    OM_stat = om$send (msg = message EMSloop.EMset_props (&mthd_stat,
                        EMLP_ACTIVE, EMS_O_OFF),
                       targetid = lp_info->lp_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_LoopError, wrapup);

    reg_md_info->reg_out_ids[reg_md_info->num_reg_out++] = lp_info->lp_id;
    num_lps_rmvd++;

   } /* if (lp_md) */
   else
   {
    for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++)
    {
     if (lp_info->ed_status[cur_ed] == EMSED_MD &&
         lp_info->ed_sf_ids[cur_ed] != my_id)
     {
      for (ned_inx = 0; ned_inx < ed_match_info.num_eds; ned_inx++)
       if (lp_info->ed_ids[cur_ed] == ed_match_info.old_ed_ids[ned_inx]) 
        break;

      /*
       * Take out the new_ed from the my_assoc_info as well as
       * from xp_inters.
       */

      EFupdate_assoc_inters (&rc, xp_inters, &my_assoc_info, TRUE, TRUE, 
                        ed_match_info.new_ed_ids[ned_inx],
                        ed_match_info.old_ed_ids[ned_inx], 
                        lp_info->ed_sf_ids[cur_ed], OM_Gw_current_OS);
      EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
  
     } /* if (lp_info->ed_status[cur_ed] == EMSED_MD &&
              lp_info->ed_sf_ids[cur_ed] != my_id) */
  
    } /* for (cur_ed = 0; cur_ed < lp_info->num_eds; cur_ed++) */

   } /* else for if (lp_md) */
   
  } /* for (cur_lp = 0; cur_lp < xs_tp_info->num_lps; cur_lp++) */

 } /* if (xs_tp_info.num_lps) */

} /* if ( !(ME.EMSsubbs->ss_props & EMSIS_INACTIVE)) */

 /*
  * If there are any new intersections, trace them and make new
  * loops.
  */

 num_inters = xp_inters ? xp_inters->num_cvs : 0;

 if (num_inters)
 {
   EMsfinttrace (&rc, &cs_env->md_env.matrix_type, 
                cs_env->md_env.matrix, xp_inters, NULL, 
                &dis_tol, &num_grps[0], &num_sgrps_grp[0], 
                &num_elems_sgrp[0], &elems[0], &sgrp_rev[0], 
                &elem_rev[0], &grp_clsd[0], &sgrp_clsd[0]);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   /*
    * In case of jogged cross section where each cross_section
    * plane may not be cutting across the model, it is possible
    * that the groups are not closed. These groups should be
    * merged if needed and closed w.r.t natural boundaries of
    * cross_section plane. The cross section plane is constructed
    * in a way such that the open groups should only close w.r.t
    * natural edges u=0 and u=1. If not, there is actually
    * an intersection closure problem.
    */

   open_grps_exist = FALSE;
   for (i = 0; i < num_grps[0]; i++)
   {
     if (!grp_clsd[0][i])
     {
       open_grps_exist = TRUE;
       break;
     }
   } /* for (i = 0; i < num_grps[0]; i++) */

   if (open_grps_exist)
   {
    /*
     * o Get the end points of the open groups. There will be
     *   only one subgroup/group. Therefore, end point of a group
     *   is the same as that of its subgroup.
     * o sort these end points on u=0 and u=1 edge.
     * o Create part of natural edges for each pair of sorted list
     *   of end points. The end points should be sorted in increasing
     *   value of v for u=0 and in decreasing value of v for u = 1.
     * o Trace the intersections again.
     */

    EFcreate_eds_to_cls_grps (&rc, num_grps[0], grp_clsd[0], 
            num_sgrps_grp[0], num_elems_sgrp[0], elems[0],
            &my_assoc_info, &my_GRid, my_gm, partolbasis.tol, 
            cs_env, &xp_inters, TRUE);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    EMsfinttrace_free(&rc, num_grps[0], num_sgrps_grp[0],
         num_elems_sgrp[0], elems[0], sgrp_rev[0], elem_rev[0], 
         grp_clsd[0], sgrp_clsd[0]);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    /*
     * Trace the intersections again.
     */

    EMsfinttrace( &rc, &cs_env->md_env.matrix_type, cs_env->md_env.matrix,
                 xp_inters, NULL, &dis_tol, &num_grps[0], 
                 &num_sgrps_grp[0], &num_elems_sgrp[0], &elems[0], 
                 &sgrp_rev[0], &elem_rev[0], &grp_clsd[0], 
                 &sgrp_clsd[0] );
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    /*
     * Some of the above constructed edge U0 and U1 intersections 
     * may be overlapping old edge U0 and U1 intersections. In such
     * a case take an appropriate action.
     */

    old_nat_eds_exist = FALSE;
    oed_inx = 0;
    for (osf_inx = 0; osf_inx < md_sfs_old_int.num_sfs; osf_inx++)
    {
      if (md_sfs_old_int.sf_list[osf_inx] == my_id)
      {
        old_nat_eds_exist = TRUE;   break;
      }
      else
       oed_inx += md_sfs_old_int.num_eds_sf[osf_inx];

    } /* for (osf_inx = 0; osf_inx < md_sfs_old_int.num_sfs; osf_inx) */

    if (old_nat_eds_exist)
    {
      ed_match_info.num_eds = 0;
      ned_inx = 0;
      for (nsf_inx = 0; nsf_inx < my_assoc_info.num_sfs; nsf_inx++)
      {
        if (my_assoc_info.sf_list[nsf_inx] == my_id) break;
        else ned_inx += my_assoc_info.num_eds_sf[nsf_inx];
         
      } /* for (nsf_inx = 0; nsf_inx < my_assoc_info.num_sfs;nsf_inx++) */
 
      if (!my_gm_md)
      {
        if (my_assoc_info.num_eds_sf[nsf_inx] > ed_match_info.eds_arrsz)
        {
          arrsz = ed_match_info.eds_arrsz;
          EFmemory_allocation (&rc, (IGRchar **)&ed_match_info.old_ed_ids,
                       my_assoc_info.num_eds_sf[nsf_inx],
                       &arrsz, sizeof(GRobjid),
                       my_assoc_info.num_eds_sf[nsf_inx], 0);
          EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

          arrsz = ed_match_info.eds_arrsz;
          EFmemory_allocation (&rc, (IGRchar **)&ed_match_info.new_ed_ids,
                       my_assoc_info.num_eds_sf[nsf_inx],
                       &arrsz, sizeof(GRobjid),
                       my_assoc_info.num_eds_sf[nsf_inx], 0);
          EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

          arrsz = 2 * ed_match_info.eds_arrsz;
          EFmemory_allocation (&rc, (IGRchar **)&ed_match_info.match_type,
                       my_assoc_info.num_eds_sf[nsf_inx],
                       &ed_match_info.eds_arrsz, sizeof(IGRshort),
                       my_assoc_info.num_eds_sf[nsf_inx], 0);
          EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

          EFmemory_allocation (&rc, (IGRchar **)&ed_match_info.ed_bnds,
                       my_assoc_info.num_eds_sf[nsf_inx] * 2,
                       &arrsz, sizeof(struct EMSedgebound),
                       my_assoc_info.num_eds_sf[nsf_inx] * 2, 0);
          EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

        } /* if (my_assoc_info.num_eds_sf[nsf_inx] > 
                 ed_match_info.eds_arrsz) */

        EFperform_tp_correlation (&rc, my_id, OM_Gw_current_OS, 
                                  md_sfs_old_int.num_eds_sf[osf_inx], 
                                  &md_sfs_old_int.ed_list[oed_inx], 
                                  my_assoc_info.num_eds_sf[nsf_inx], 
                                  &my_assoc_info.ed_list[ned_inx], 
                                  &partolbasis, &ed_match_info);
        EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);     

      } /* if (!my_gm_md) */

      /*
       * The following malloc/realloc is only for debugging purposes.
       */

      if ( (num_old_eds + ed_match_info.num_eds) > old_eds_arrsz)
      {
        EFmemory_allocation (&rc, (IGRchar **) &old_eds,
                             num_old_eds+ed_match_info.num_eds, 
                             &old_eds_arrsz, sizeof(GRobjid), 
                             num_old_eds+ed_match_info.num_eds, 0);
        EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

      } /* if ( (num_old_eds + ed_match_info.num_eds) > old_eds_arrsz) */

      for (cur_ed = 0; cur_ed < ed_match_info.num_eds; cur_ed++)
      {
        EFupdate_new_int ( &rc, ed_match_info.old_ed_ids[cur_ed],
                           ed_match_info.new_ed_ids[cur_ed],
                           ed_match_info.match_type[cur_ed], 
                           &ed_match_info.ed_bnds[2*cur_ed],
                           xp_inters, &my_assoc_info, my_id, 
                           OM_Gw_current_OS, old_eds, &num_old_eds);
        EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
        
      } /* for (cur_ed = 0; cur_ed < ed_match_info.num_eds; cur_ed++) */

    } /* if (old_nat_eds_exist) */

   } /* if (open_grps_exist) */
  
   /*
    * o Erase the surface if not done yet.
    * o make loops out of intersection data.
    * o Nest these new loops.
    * o Toggle the loops appropriately.
    */

   if (!sf_erased)
   {
     DisplayMode = GRbe;
     OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                         xp_non_aligned ? &md_algn_mattyp :
                          &cs_env->md_env.matrix_type,
                         xp_non_aligned ? md_algn_mat :
                          cs_env->md_env.matrix, &DisplayMode,
                          &cs_env->md_id),
                         targetid = my_id);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

     sf_erased = TRUE;

   } /* if (!sf_erased) */

   ex$message(msgnumb = EMS_I_AddingModBdToXsec)

   /*
    * It may be possible that some the groups are closed in model
    * space but are open parametric space. In such cases, refine
    * these subgroups and try merge them in a single subgroup.
    */

   stat = EMfix_and_refine_intdata (&rc, &cs_env->md_env.matrix_type,
                 cs_env->md_env.matrix, NULL, NULL, construct_list, 
                 xp_inters, NULL, NULL, &dis_tol, NULL, 
                 num_grps, num_sgrps_grp, num_elems_sgrp, elems, sgrp_rev,
                 elem_rev, grp_clsd, sgrp_clsd, inters_options, 
                 outworld_options, outparam_options, trim_options);
   EMerr_hndlr (!(1&rc&stat), *EMmsg, EMS_E_Fail, wrapup);

   EFmk_xsec_lps ( &rc, cs_env, OM_Gw_current_OS, num_grps[0], 
                   num_sgrps_grp[0], num_elems_sgrp[0], elems[0], 
                   sgrp_rev[0], elem_rev[0], grp_clsd[0], sgrp_clsd[0], 
                   &partolbasis, &ls_GRid.objid, my_id, &num_lps_added, 
                   &lp_added_ids);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  /*
   * In case the cross section plane is not cutting through
   * the solid, some of its boundaries are made up of natural
   * edges. It is assumed that this situation will arise only if
   * there are other cross plane(s) which along with this plane
   * cut through the model. Therefore, these natural boundaries,
   * which are not real boundaries on the model, should be supressed
   * for display.
   */
/*  
  if (open_grps_exist)
  {
    nat_bd_inx = 0;
    for (sf_inx = 0; sf_inx < my_assoc_info.num_sfs; sf_inx++)
    {
      if (my_assoc_info.sf_list[sf_inx] == my_id) break;
      else
        nat_bd_inx += my_assoc_info.num_eds_sf[sf_inx];

    }*/ /* for (sf_inx = 0; sf_inx < my_assoc_info.num_sfs; sf_inx++) */
/*
    if (sf_inx < my_assoc_info.num_sfs)
    { 
     for (i = 0; i < my_assoc_info.num_eds_sf[sf_inx]; i++, nat_bd_inx++)
     {
      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                          EMED_SUBORDINATE, EMS_O_ON),
                         targetid = my_assoc_info.ed_list[nat_bd_inx]);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     }*/ /* for (i = 0; i < my_assoc_info.num_eds_sf[sf_inx]; i++) */

/*    }*/ /* if (sf_inx < my_assoc_info.num_sfs) */
 
 /*  }*/ /* if (open_grps_exist) */

 } /* if (num_inters) */

 /*
  * take out my_id from sfs_md_info and my_assoc_info.
  */

 if ( !(ME.EMSsubbs->ss_props & EMSIS_INACTIVE) )
 {
  if (my_gm_md)
    sfs_md_info->num_sfs_gm_md--;
  else 
   sfs_md_info->num_sfs_tp_md--;
 }

 /*
  * Update reg mod table
  */

  if (num_lps_rmvd || num_lps_added)
  {
   arrsz = reg_md_info->sf_arrsz;
   EFmemory_allocation (&rc, (IGRchar **) &reg_md_info->sf_ids, 
            reg_md_info->num_sfs+1, &arrsz, sizeof(GRobjid), 
            5, 5);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   arrsz = reg_md_info->sf_arrsz;
   EFmemory_allocation (&rc, (IGRchar **) &reg_md_info->num_reg_sf_in, 
            reg_md_info->num_sfs+1, &arrsz, sizeof(IGRint), 
            5, 5);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   EFmemory_allocation (&rc, (IGRchar **) &reg_md_info->num_reg_sf_out, 
            reg_md_info->num_sfs+1, &reg_md_info->sf_arrsz, 
            sizeof(GRobjid), 5, 5);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   EFmemory_allocation (&rc, (IGRchar **) &reg_md_info->reg_in_ids, 
            reg_md_info->num_reg_in+num_lps_added, 
            &reg_md_info->reg_in_arrsz, sizeof(GRobjid), 
            10, 5);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   reg_md_info->sf_ids[reg_md_info->num_sfs] = my_id;
   reg_md_info->num_reg_sf_in[reg_md_info->num_sfs] = num_lps_added;
   reg_md_info->num_reg_sf_out[reg_md_info->num_sfs++] = num_lps_rmvd;

   OM_BLOCK_MOVE (lp_added_ids, 
                  &reg_md_info->reg_in_ids[reg_md_info->num_reg_in],
                  sizeof(GRobjid) * num_lps_added);

   reg_md_info->num_reg_in += num_lps_added;

  } /* if (num_lps_rmvd || num_lps_added) */

  /*
   * If I donot have any loops left, 
   *  o I was inactive to start with. Nothing needs to be done.
   *  o I was active to start with. Make myself inactive. Disconnect
   *    myself from my owner. Add myself SSI surfaces removed list.
   *
   * else I have one or more loops,
   *  o I was inactive to start with. Make myself active. 
   *  o I was active to start with. Nothing needs to be done.
   */

  num_lps = 0;
  if (!IF_NULL_OBJID(ls_GRid.objid))
  {
   depth = MAXINT;
   OM_stat = om$send (msg = message EMSloopset.EMget_loops (&mthd_stat,
                     EMS_OPT_ALL, &depth, NULL, NULL, NULL, &num_lps),
                    targetid = ls_GRid.objid, targetos = ls_GRid.osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_LoopsetError, wrapup);

  } /* if (!IF_NULL_OBJID(ls_GRid.objid)) */

  if (num_lps)
  {
    if (ME.EMSsubbs->ss_props & EMSIS_INACTIVE )
    {
     EFsetsfstate (&rc, my_id, OM_Gw_current_OS, EMS_O_ON);
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
    }
  }
  else
  {
    if (!(ME.EMSsubbs->ss_props & EMSIS_INACTIVE) )
    {

     /*
      * delete the loopset since loopset without any loops may create
      * problems.
      */

     OM_stat = om$send (msg = message Root.delete (1),
                      targetid = ls_GRid.objid, targetos = ls_GRid.osnum);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

     if (me->properties & GR_RIGID_RELATIONSHIP)
     {
       OM_stat = om$get_objid_at_index (object = me, 
                    p_chanselect = &to_owners_chan,
                    index = 0, objidaddr = &owner_GRid.objid,
                    osnumaddr = &owner_GRid.osnum);
       EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

       OM_stat = om$get_index (osnum_c = owner_GRid.osnum,
                    objid_c = owner_GRid.objid, 
                    p_chanselect = &to_cmpnt_chan,
                    objid = my_id, osnum2 = OM_Gw_current_OS,
                    indexaddr = &composite_inx);
       EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

       OM_stat = om$send (msg = message GRconnector.GRdisconn (&mthd_stat,
                           &owner_GRid),
                          targetid = my_id);
       EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

     } /* if (me->properties & GR_RIGID_RELATIONSHIP) */
     else
     {
       owner_GRid.objid = NULL_OBJID;
       composite_inx = NULL;
     } /* else for if (me->properties & GR_RIGID_RELATIONSHIP) */
 
     cm_sf_exists = FALSE;
     sf_inx = 0;
     for (cm_inx = 0; cm_inx < reg_md_info->num_cmsf; cm_inx++)
     {
       sf_inx += reg_md_info->num_sf_rmvd_cmsf[cm_inx];
       if (reg_md_info->cmsf_ids[cm_inx] == owner_GRid.objid)
       {
         cm_sf_exists = TRUE;     break; 
       }
     } /* for (i = 0; i < reg_md_info->num_cmsf; i++) */

     if (!cm_sf_exists)
     {
      if ( (reg_md_info->num_cmsf + 1) > reg_md_info->cmsf_arrsz)
      {
        arrsz = reg_md_info->cmsf_arrsz;
        EFmemory_allocation (&rc, (IGRchar **) &reg_md_info->cmsf_ids,
          reg_md_info->num_cmsf+1, &arrsz, sizeof(GRobjid), 2, 2);
        EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

        EFmemory_allocation (&rc, 
          (IGRchar **) &reg_md_info->num_sf_rmvd_cmsf, 
          reg_md_info->num_cmsf+1, &reg_md_info->cmsf_arrsz, 
          sizeof(IGRint), 2, 2);
        EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

      } /* if ( (reg_md_info->num_cmsf + 1) > reg_md_info->cmsf_arrsz) */

      reg_md_info->num_sf_rmvd_cmsf[cm_inx] = 1;
      reg_md_info->cmsf_ids[cm_inx] = owner_GRid.objid;
      reg_md_info->num_cmsf++;
      
     } /* if (!cm_sf_exists) */
     else
      reg_md_info->num_sf_rmvd_cmsf[cm_inx]++;

     if ( (reg_md_info->num_rmvd_sfs + 1 ) > reg_md_info->rmvd_sf_arrsz)
     {
      arrsz = reg_md_info->rmvd_sf_arrsz;
      EFmemory_allocation (&rc, (IGRchar **) &reg_md_info->rmvd_sf_ids,
        reg_md_info->num_rmvd_sfs+1, &arrsz, sizeof(GRobjid), 5, 2);
      EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

      EFmemory_allocation (&rc, (IGRchar **) &reg_md_info->rmvd_sf_idx,
        reg_md_info->num_rmvd_sfs+1, &reg_md_info->rmvd_sf_arrsz, 
        sizeof(IGRint), 5, 2);
      EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

     } /* if((reg_md_info->num_rmvd_sfs+1)>reg_md_info->rmvd_sf_arrsz) */
 
     blksize = reg_md_info->num_rmvd_sfs - sf_inx;
     if (blksize)
     {
       OM_BLOCK_MOVE (&reg_md_info->rmvd_sf_ids[sf_inx],
          &reg_md_info->rmvd_sf_ids[sf_inx+1], blksize * sizeof(GRobjid));

       OM_BLOCK_MOVE (&reg_md_info->rmvd_sf_idx[sf_inx], 
          &reg_md_info->rmvd_sf_idx[sf_inx+1], blksize * sizeof(IGRint));
     } /* if (blksize) */
     
     reg_md_info->rmvd_sf_ids[sf_inx] = my_id;
     reg_md_info->rmvd_sf_idx[sf_inx] = composite_inx;
     reg_md_info->num_rmvd_sfs++;

     EFsetsfstate (&rc, my_id, OM_Gw_current_OS, EMS_O_OFF);
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    } /* if (!(ME.EMSsubbs->ss_props & EMSIS_INACTIVE) ) */

  } /* else for if (num_lps) */

  /*
   * Update the model-surface/xsection-edge association info.
   */

  if (my_assoc_info.num_sfs)
  {
   my_assoc_ed_inx = 0;
   for (i = 0; i < my_assoc_info.num_sfs; i++)
   {
     EFsave_xs_assoc_info (&rc, xs_assoc_info, my_assoc_info.sf_list[i],
                           &my_assoc_info.ed_list[my_assoc_ed_inx],
                           my_assoc_info.num_eds_sf[i]);
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

     my_assoc_ed_inx += my_assoc_info.num_eds_sf[i];
           
   } /* for (i = 0; i < my_assoc_info.num_sfs; i++) */
 
  } /* if (my_assoc_info.num_sfs) */

 /*
  * If the surface was non_aligned, align it back.
  */

 if (xp_non_aligned)
 {
   OM_stat = om$send (msg = message EMSxsection.EMxsec_int_xform (
                       &mthd_stat, cs_env, &rot_mattyp, rot_mat, 
                       NULL, &newobjid, TRUE),
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

 } /* if (xp_non_aligned) */

 /*
  * If the surface was erased, display it.
  */

 if (sf_erased && (!(me->ss_props & EMSIS_INACTIVE)) )
 {
   DisplayMode = GRbd;
   OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                       &cs_env->md_env.matrix_type,
                       cs_env->md_env.matrix, &DisplayMode,
                       &cs_env->md_id),
                      targetid = my_id);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

 } /* if (sf_erased) */

 /*
  * The following edge display is used for debuggin purposes.
  * should be taken out for release.
  */

/* if (my_assoc_info.num_sfs)
 {
   for (i = 0; i < my_assoc_info.num_eds; i++)
   {
     new_ed = TRUE;
     for (j = 0; j < num_old_eds; j++)
     {
      if (old_eds[j] == my_assoc_info.ed_list[i])
      {
        new_ed = FALSE;
        break;
      }
     }
     if (new_ed)
     { 
      OM_stat = om$send (msg = message EMSedge.EMdebug_display(&mthd_stat,
                         cs_env, NULL, GRbd),
                        targetid = my_assoc_info.ed_list[i]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_EdgeError,wrapup);
     }

   }*/ /* for (i = 0; i < my_assoc_info.num_eds; i++) */
 
 /* } */ /* if (my_assoc_info.num_sfs) */

  *is_sf_active = (me->ss_props & EMSIS_INACTIVE) ? FALSE : TRUE;
 wrapup:
 
  EMWRAPUP (*EMmsg, OM_stat, "In EMSxsplane.EMperform_xsection_update");

  if (cache_ptr) GRabsg_del(cache_ptr);
  if (xp_inters)
  {
    EMinters_data_free (&rc, xp_inters, NULL, NULL, NULL);
    EMinters_free (xp_inters, NULL);
  }

  if (mdl_inters)
  {
    EMinters_data_free (&rc, mdl_inters, NULL, NULL, NULL);
    EMinters_free (mdl_inters, NULL);
  }
    
  if (lp_added_ids) om$dealloc (ptr = lp_added_ids);

  if (my_assoc_info.sf_list) om$dealloc (ptr = my_assoc_info.sf_list);
  if (my_assoc_info.ed_list) om$dealloc (ptr = my_assoc_info.ed_list);
  if (my_assoc_info.num_eds_sf) om$dealloc (ptr=my_assoc_info.num_eds_sf);

  if (md_sfs_old_int.sf_list) om$dealloc (ptr = md_sfs_old_int.sf_list);
  if (md_sfs_old_int.ed_list) om$dealloc (ptr = md_sfs_old_int.ed_list);
  if (md_sfs_old_int.num_eds_sf) 
     om$dealloc (ptr=md_sfs_old_int.num_eds_sf);

  if (old_eds) om$dealloc (ptr = old_eds);
  if (ed_u0_pts) om$dealloc (ptr = ed_u0_pts);
  if (ed_u1_pts) om$dealloc (ptr = ed_u1_pts);

  if (xs_tp_info.lps_info)
  {
   for (i = 0; i < xs_tp_info.num_lps; i++)
   {
    om$dealloc (ptr = xs_tp_info.lps_info[i].ed_ids);
    om$dealloc (ptr = xs_tp_info.lps_info[i].ed_sf_ids);
    om$dealloc (ptr = xs_tp_info.lps_info[i].ed_status);
   }
   om$dealloc (ptr = xs_tp_info.lps_info);

  } /* if (xs_tp_info.lps_info) */

  if (ed_match_info.old_ed_ids) om$dealloc (ptr=ed_match_info.old_ed_ids);
  if (ed_match_info.new_ed_ids) om$dealloc (ptr=ed_match_info.new_ed_ids);
  if (ed_match_info.match_type) om$dealloc (ptr=ed_match_info.match_type);
  if (ed_match_info.ed_bnds) om$dealloc (ptr = ed_match_info.ed_bnds);
 
  if (rpl_info.ed_ids) om$dealloc (ptr = rpl_info.ed_ids);
  if (rpl_info.rpl_ed_ids) om$dealloc (ptr = rpl_info.rpl_ed_ids);

  if (svst_eds) om$dealloc (ptr = svst_eds);

  if (sf_eds) om$dealloc (ptr = sf_eds);
  
  return (OM_stat);

}

end implementation EMSxsplane;

