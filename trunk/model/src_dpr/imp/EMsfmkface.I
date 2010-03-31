/*
History
    RC      4/30/87     Creation Date
    RC      28-Aug-87   Added partolbasis in call to uvtrans.
    SM      28-Aug-87   Added arguments in the call to EMpartsf.
                        (window_loopset - FALSE
                         want_status_messages - FALSE)
    RC      11/2/87     Modified for version 1.1.0
    RC      02/08/87    Modified to handle grouping of ambiguous 
                        loops.
    SAM     02/28/88    Added argument EMpartsf call (NULL : donot send
                         partial surface geometry).
    RC      02/22/90    Added code to handle feature loops.
    DLB     03/25/91    Add dis_options parameter and display_ids,
                        display_count.    
    DLB     05/24/91    Do rigid connect at MAX_INT to support recompute
                        and topology matching.
    DLB     07/15/92    Try to consistently pick which side of incoming curve
                           to make the new surface.
    DLB     07/24/92    Support track point (new parameter).
    DLB     08/12/92    Support pre-2.1 versions of mkface by using old
                        algorithm.
    DLB     08/27/92    Ignore all BSptsdofcv failures.
    NP      09/09/92	EMSgradata.EMinit message is NOT known to a EMSptgralp 
			(point loop), since EMSptgralp in NOT a subclass of 
			class EMSgradata. Return success in such cases.
    Sudha   06/23/93    Modified for BSprototype ansification
*/

class implementation EMSsfmkface;

#include "emserr.h"
#include "emsdef.h"     /* MAXFLOAT, MINFLOAT */
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emsinter.h"
#include "emssfint.h"
#include "EMSopt.h"
#include "bserr.h"
#include <alloca.h>
#include "bsparameters.h"
#include "OMmacros.h"
#if DEBUG
#include "dpmacros.h"
#endif    

#define  BSVOID
#include "bs.h"
#include "bsstk.h"
#include "bsparameters.h"
#include "bsstackalloc.h"
#include "bsmalloc.h"
#include "bstrans2.h"
#include "bsstfrecvfl.h"
#include "bsstallcvfl.h"
#include "bssfarrevn.h"
#include "bsptoldtnw.h"
#include "bsptnorsf.h"
#include "bspt_in_cv.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsmdstptcv.h"
#include "bslftorrght.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsdbgsfree.h"
#include "bsdbgsalloc.h"
#include "bscvoton.h"
#include "bscvkttol2.h"
#include "bscveval.h"
#include "bscv_copy.h"

extern OMuword OPP_EMSloop_class_id, OPP_EMSgradata_class_id;

struct split_ed_info
{
  GRobjid       com_ed_id;
  GRobjid       *part_edges;
  IGRint        num_part_edges;
  GRobjid       lp_id;
};

from EMSsubbs   import          EMget_split_areas,
                                EMpartolbasis,
                                EMpartsf;

from EMSsubbs   import          EMgetbsdef;

from EMSloopset import          EMgetrange, EMupdate_features,
                                EMsplit_into_two_ls,
                                EMmkface_collapse_copy,
                                EMset_props, EMget_loops, EMpt_location;

from EMSboundary import         EMuv_transform, EMget_objid, EMget_edges,
                                EMgetsurface_info, EMtree_traverse,
                                EMtpcopy;

from EMSedge     import         EMget_top_part_edges, EMget_props, 
                                EMset_props;

from EMSloop     import         EMset_props;

from EMSgradata  import         EMchangeSurface, EMinit;
 
/***********************************/
#define MUST_USE_OWN_PTSDOFCV
/***********************************/

method EMmake_face_execute (
        IGRlong                 *EMmsg;
        struct  GRid            srf_GRid;
        struct  GRmd_env        *srf_env;
        IGRlong                 num_of_objects;
        struct  GRlc_info       object_info[];
        struct  GRvg_construct  *construct_list;
        IGRlong                 *num_of_bad_points;
        IGRpoint                **bad_points;
        IGRboolean              want_bad_curves;
        IGRlong                 *num_of_bad_curves;
        IGRlong                 bad_curve_indices[];
        IGRboolean              want_status_message;
        IGRlong                 process_phase;
        IGRchar                 *grouping_info;
        IGRushort               dis_options;
        GRobjid                 **display_ids;
        IGRint                  *display_count;
        IGRpoint                track_pt)
{
   IGRboolean                   lp_exists,
                                status,
                                world_flag, recover_on_error = FALSE;

   IGRint                       buf_size = 0, depth, 
                                i, j, k,l, lk,jj,
                                sts, *num_amb_lps,
                                taken_out_lps_array_size = 0,
                                edcon_array_size = 0,
                                num_com_ed_lps = 0,
                                num_edcon_entries = 0,
                                num_imp_lps = 0,
                                num_lps_taken_out,
                                num_part_edges = 0,
                                num_sped_entries = 0,
                                num_split_edges = 0,
                                *num_sf_org_lps, *num_trim_info,
                                *num_new_lps_added, array_size,
                                num_seam_eds, num_flps = 0;
   IGRuint                      my_assoc_type;
   OMuint                       chan_count;
   IGRushort            props, *sf_org_lp_props;

   IGRlong                      OM_stat, 
                                mthd_stat, owners_index;

   GRobjid                      cm_ed_srf, cp_ed_id,
                                *gr1_ls_id, *gr2_ls_id,
                                **amb_lps,
                                *imp_lps_ids,
                                *lps_taken_out,
                                *com_ed_lps,
                                org_srf_ls,
                                part_srf_id = NULL_OBJID,
                                part_srf_ls, **sf_org_lps, *sf_org_ls, 
                                *split_edges, **new_lps_added, 
                                cm_ed_sf, *flps = NULL, *flps_copy = NULL,
                                flp_cur_ls;

   IGRdouble                    gr1_uv_area,
                                gr2_uv_area,
                                gr1_ls_range[4],
                                gr2_ls_range[4],
                                trans_mat[16],
                                mid_par[2],
                                new_range[4],
                                *part_srf_range;

   struct  GRid                 my_GRid, *seam_eds = NULL;

   struct  EMSsfintedpar        ***loops_trim_info;

   struct  EMSownercomp         **sf_lps_removed;
   struct  EMSmkf_grouping_info *grp_info;
   struct  EMSpartolbasis       partolbasis;
   struct  EMSmkf_edcon_info    *ed_con_info;
   struct  IGRbsp_surface       surface;
   struct  split_ed_info        *sped_info;
   union   EMSssiSizeData       ssi_size;
   union   EMSssi_table         *ssi_table;
   struct  EMSmfssi_table       *my_info;

   OM_S_CHANSELECT              srf_ls_chan,
                                com_ed_chan,
                                lp_ls_chan,
                                ls_srf_chan,
                                ls_lp_chan;

   enum GRdpmode                DisplayMode;

   void                         EMsfintedpar_free(),
                                EMownercomp_free(), EMget_sp_edges();

   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   grp_info = (struct EMSmkf_grouping_info *) grouping_info;
   gr1_ls_id = &grp_info->gr1_ls_id;
   gr2_ls_id = &grp_info->gr2_ls_id;
   amb_lps = &grp_info->amb_lps;
   num_amb_lps = &grp_info->num_amb_lps;
   sf_org_lps = &grp_info->sf_org_lps;
   num_sf_org_lps = &grp_info->num_sf_org_lps;
   sf_org_ls = &grp_info->sf_org_ls;
   loops_trim_info = &grp_info->loops_trim_info;
   num_trim_info = &grp_info->num_trim_info;
   sf_lps_removed = &grp_info->sf_lps_removed;
   num_new_lps_added = &grp_info->num_new_lps_added;
   new_lps_added = &grp_info->new_lps_added;

   mid_par[0] = 0;
   mid_par[1] = 0;

   num_lps_taken_out = 0;

   *num_of_bad_points = 0;
   *num_of_bad_curves = 0;

   sf_org_lp_props = NULL;
   com_ed_lps = NULL;
   ed_con_info = NULL;
   imp_lps_ids = NULL;
   lps_taken_out = NULL;
   sped_info = NULL;
   split_edges = NULL;
   ssi_table = NULL;

   OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &srf_ls_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = EMmake_chanselect (EMSloopset_to_surface, &ls_srf_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &com_ed_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = EMmake_chanselect (EMSloop_to_outter, &lp_ls_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   world_flag = TRUE;

   partolbasis.in_world = TRUE;
   partolbasis.is_valid = TRUE;
   partolbasis.mattyp = &srf_env->md_env.matrix_type;
   partolbasis.mat = srf_env->md_env.matrix;

   OM_stat = om$send (msg = message EMSsubbs.EMpartolbasis (&mthd_stat,
                         &srf_env->md_env.matrix_type, 
                          srf_env->md_env.matrix, &world_flag, FALSE,
                         &partolbasis.tol),
                        targetid = srf_GRid.objid,
                        targetos = srf_GRid.osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

   { /*INTENTIONAL BLOCK*/
     IGRboolean dont_have_it;

     OM_stat = EFwork_the_display(&mthd_stat, dis_options,
                                  srf_GRid.objid, 
                                  display_ids, display_count,
                                  &dont_have_it);
     if (!(1 & OM_stat & mthd_stat)) goto wrapup;

     if (dont_have_it)
     {
       /*
        * Erase the surface to be modified 
        */
       DisplayMode = GRbe;
       OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                           &srf_env->md_env.matrix_type,
                            srf_env->md_env.matrix, &DisplayMode,
                           &srf_env->md_id),
                         targetid = srf_GRid.objid, 
                         targetos = srf_GRid.osnum);                       
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
     }
   }

   if (process_phase == EMS_PROCESS_PHASE1)
   {

     *num_amb_lps = 0;
     *amb_lps = NULL;
     *sf_org_lps = NULL;
     *loops_trim_info = NULL;         
     *num_trim_info = 0;
     *sf_lps_removed = NULL;
     *new_lps_added = NULL;
     *num_new_lps_added = 0,
     *num_of_bad_points = 0;
     *num_of_bad_curves = 0;

     /*
      * check if I have a loopset or not. If not, make a natural 
      * loopset.
      */

     OM_stat = om$get_channel_count (objid = srf_GRid.objid,
                                   osnum = srf_GRid.osnum, 
                                   p_chanselect = &srf_ls_chan,
                                   count = &chan_count);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     if (!chan_count)
     {
       OM_stat = om$send (msg = message EMSsubbs.EMmk_nat_bdry ( 
                           &mthd_stat, &srf_env->md_env, NULL),
                      targetid = srf_GRid.objid, 
                      targetos = srf_GRid.osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
    }

    /*
     * Collect surface's loopset id and the original loop ids.
     * If make face fails, they will be used for graceful exit.
     */

    OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                       sf_org_ls), senderid = srf_GRid.objid,
                       p_chanselect = &srf_ls_chan);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_LoopsetError,wrapup);

    *gr1_ls_id = *sf_org_ls;
    *gr2_ls_id = NULL_OBJID;

    depth = MAXINT;
    buf_size = *num_sf_org_lps = NULL;
    OM_stat = om$send (msg = message EMSloopset.EMget_loops (&mthd_stat,
                       EMS_OPT_ALL, &depth, sf_org_lps, &sf_org_lp_props,
                       &buf_size, num_sf_org_lps), targetid = *sf_org_ls);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
    
    if (sf_org_lp_props) om$dealloc (ptr = sf_org_lp_props);
             
    /* 
     * split the surface under consideration using the
     * incoming objects as boundaries.
     */

    OM_stat = om$send (msg = message EMSsubbs.EMget_split_areas(
                        &mthd_stat, srf_env, num_of_objects,
                         object_info, num_of_bad_points, bad_points,
                         want_bad_curves, num_of_bad_curves,
                         bad_curve_indices, &num_imp_lps, &imp_lps_ids,
                         loops_trim_info, num_trim_info, 
                         sf_lps_removed, num_new_lps_added,
                         new_lps_added, want_status_message),
                       targetid = srf_GRid.objid,
                       targetos = srf_GRid.osnum);

     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,mthd_stat,wrapup);

     /****** SM 10/29/92
      The existing surface has not been modified upto this point. If an
      error condition occured in EMSloopset.EMsplityourself (called via
      EMget_split_areas above), that method would restore the loopset.
      Any error condition AFTER this point requires recovery mechanism to
      kick in.
     ***********/
     
     recover_on_error = TRUE;  /* DO NOT move this statement around wrt the
                                  EMget_split_areas message send.
                               */

    /*
     * surface is now split into areas. 
     * Split this loopset into two loopsets.
     * One loopset will remain on the surface
     * while the other will be used to create a
     * a partial surface for the face to be made.
     */
 
     OM_stat = om$send (msg = message EMSloopset.EMsplit_into_two_ls(
                         &mthd_stat, num_imp_lps, imp_lps_ids, srf_env,
                         &partolbasis, gr1_ls_id, gr2_ls_id, amb_lps,
                          num_amb_lps),
                        senderid = srf_GRid.objid,
                        p_chanselect = &srf_ls_chan);

     if (mthd_stat == EMS_I_NeedGrpInfo) 
     {
        *EMmsg = EMS_I_NeedGrpInfo;
        if (imp_lps_ids) om$dealloc (ptr = imp_lps_ids);
        imp_lps_ids = NULL;
        return (OM_stat);
     }

     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_MkfGrouping,wrapup);
         
   } /* if (process_phase == EMS_PROCESS_PHASE1) */

   /*
    * Now the loopset has been divided into two loopsets.
    * Next thing to decide is which loopset is to be left
    * onto the original surface and which one is to be 
    * used to create the new face.
    *
    * The selection criteria should be such that it satisfies
    * the following conditions:
    *
    * o The surface area of the new surface created to make face
    *   is minimum possible.
    * o The storage requirements for the new surface should be 
    *   minimized.
    *
    * In the current implementation the above criteria may not
    * be satisfied. In this implementation, the (u,v) space areas
    * for gr1-ls_id and gr2_ls_id are computed. The one with
    * the smaller area is chosen to be used to construct the
    * partial surface. This selection criterion will result
    * in correct results if the surface's geometry is uniformally
    * distributed. If the surface retains its natural p-loop after
    * splitting, this criterion will choose, the group without the
    * the natural loop to create the partial surface. In such a case,
    * the current implementation will satisfy the above criteria.
    *
    */

    OM_stat = om$send (msg = message EMSsubbs.EMgetbsdef ( &mthd_stat,
                        &surface),
                       targetid = srf_GRid.objid,
                       targetos = srf_GRid.osnum);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    OM_stat = om$send (msg = message EMSloopset.EMgetrange( &mthd_stat,
                        gr1_ls_range),
                       targetid = *gr1_ls_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
    
    OM_stat = om$send (msg = message EMSloopset.EMgetrange( &mthd_stat,
                        gr2_ls_range),
                       targetid = *gr2_ls_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

    /*
     * If the surface is planar(rect, sq or parellelogram), 
     * the boundaries may be
     * imposed as BS-edges. In such a situation, the range
     * of the loopset may be outside the range of (0, 1).
     * This will happen if the bs_edge polygon's poles
     * are outside the range of the surface.
     * In such a case reduce the range to (0,1) range.
     * The only check is done by looking at planar bit.
     * This is not the whole test. Nevertheless if the
     * range of the loopset is outside (0,1), and the
     * surface is not one of the above mentioned ones,
     * somebody goofed up.
     */

    if (surface.planar)
    {
       for (i = 0; i < 4; i++)
       {
          if (gr1_ls_range[i] < 0) gr1_ls_range[i] = 0.;
          if (gr1_ls_range[i] > 1.0) gr1_ls_range[i] = 1.;
          if (gr2_ls_range[i] < 0) gr2_ls_range[i] = 0.;
          if (gr2_ls_range[i] > 1.0) gr2_ls_range[i] = 1.;
        }
     }          

    gr1_uv_area = (gr1_ls_range[2] - gr1_ls_range[0]) * 
                  (gr1_ls_range[3] - gr1_ls_range[1]);

    gr2_uv_area = (gr2_ls_range[2] - gr2_ls_range[0]) * 
                  (gr2_ls_range[3] - gr2_ls_range[1]);

    /*DLB 8/12/92 - support pre-2.1 version of mkface*/
    OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL, 
                            &my_assoc_type, NULL, NULL),
                      targetid = my_id);                          
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (my_assoc_type == EMS_ASno_type && !track_pt)
    {
      /*Pre-2.1 version of make face with no track point.  Just default
       * to first loopset on original surface.
       */
      org_srf_ls = *gr1_ls_id;
      part_srf_ls = *gr2_ls_id;
      part_srf_range = gr2_ls_range;
    }
    else
    {
#     define MAXTRY     100
#     define RIGHT_SIDE 1
#     define ON_CURVE   2

      /*Determine which loopset goes on the original*/
      IGRdouble             u, v, proj_cv_par, dist_tol, proj_dist;
      IGRpoint              area_point, proj_pt_unused, sf_nrml;
      IGRlong               bsrc, num_bytes;
      OMuint                ii, cur_curve=0;
      IGRint                point_side=RIGHT_SIDE;
      struct GRid           *p_curve_grid;
      struct GRmd_env       *p_curve_env;
      struct IGRbsp_curve   *p_curve_geom;
      struct IGRbsp_surface *p_surf_geom;
      IGRboolean            use_next_curve;

      extern void           DLB_BSptsdofcv();

#     if   DEBUG
        dp$erase_hilite(msg = EMmsg);
#     endif

      /*Connect up one of the new loopsets*/
      OM_stat = om$send(msg = message Root.wild_disconnect(srf_ls_chan),
                        targetid = srf_GRid.objid);
      if (!(1 & OM_stat)) goto wrapup;
    
      OM_stat = om$send(msg = message Root.connect(srf_ls_chan, NULL, 
                              *gr1_ls_id, OM_Gw_current_OS,
                              ls_srf_chan, NULL),
                        targetid = srf_GRid.objid);
      if (!(1 & OM_stat)) goto wrapup;                      




      /*Get the surface pos_orient normal*/
      OM_stat = om$send(msg = message GRvg.GRgetsize(EMmsg, 
                              &srf_env->md_env.matrix_type,
                              srf_env->md_env.matrix,
                              &num_bytes), 
                        targetid = srf_GRid.objid);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      p_surf_geom = (struct IGRbsp_surface *) alloca(num_bytes);

      OM_stat = om$send(msg = message GRvg.GRgetgeom(EMmsg, 
                              &srf_env->md_env.matrix_type,
                              srf_env->md_env.matrix,
                              (IGRchar *) p_surf_geom),
                        targetid = srf_GRid.objid);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (!track_pt)
      {
        if (!p_surf_geom->planar)
        {
          /*Will get better results if planar but still able to proceed.*/
          /*NOOP*/
        }

        u = v = 0;
        BSsfarrevn(&bsrc, p_surf_geom, 1, &u, 1, &v, proj_pt_unused,  
                   sf_nrml); 
        if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 
        BSnorvec(&bsrc, sf_nrml);
        if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}
 
        if (!p_surf_geom->pos_orient)
        {
          sf_nrml[0] *= -1;
          sf_nrml[1] *= -1;
          sf_nrml[2] *= -1;
        }

        BSEXTRACTPAR(&bsrc, BSTOLLENVEC, dist_tol);
  
        do
        {
          use_next_curve = FALSE;
  
          /*Get the curve geom*/
          p_curve_grid = &object_info[cur_curve].located_obj;
          p_curve_env = &object_info[cur_curve++].module_info;
    
          OM_stat = om$send(msg = message GRvg.GRgetsize(EMmsg, 
                                  &p_curve_env->md_env.matrix_type,
                                  p_curve_env->md_env.matrix,
                                  &num_bytes), 
                            targetid = p_curve_grid->objid, 
                            targetos = p_curve_grid->osnum); 
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    
          p_curve_geom = (struct IGRbsp_curve *) alloca(num_bytes);
    
          OM_stat = om$send(msg = message GRvg.GRgetgeom(EMmsg, 
                                  &p_curve_env->md_env.matrix_type,
                                  p_curve_env->md_env.matrix,
                                  (IGRchar *) p_curve_geom),
                            targetid = p_curve_grid->objid, 
                            targetos = p_curve_grid->osnum); 
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    
          if (!p_curve_geom->planar)
          {
#           if DEBUG
              fprintf(stderr, "curve %d not planar\n", cur_curve);
#           endif
  
            use_next_curve = TRUE;
            continue;
          }
    
#         if DEBUG
          { /*Display the first curve*/
            enum GRdpmode dpmode=GRhd;
            om$send(msg =message GRgraphics.GRdisplay(EMmsg,
                                 &p_curve_env->md_env.matrix_type,
                                 p_curve_env->md_env.matrix,
                                 &dpmode, &p_curve_env->md_id),
                    targetid = p_curve_grid->objid, 
                    targetos = p_curve_grid->osnum); 
          }
#         endif
    
          /*Iterate, picking area points to see if point is on left or right of
           * loopset.
           */
          for(ii=0; ii<MAXTRY; ii++)
          {
            OM_stat = om$send(msg = message EMSsurface.EMget_point_on_surface
                                    (EMmsg, srf_env, ii, 1, area_point, NULL),
                              targetid = srf_GRid.objid);
            if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    
#           if DEBUG
            {
              struct IGRdisplay display;
    
              display.weight = 1;
              display.style = 0;
              display.color = ii+1;
              fprintf(stderr, "%d try at side pick\n", ii);
              ECdisplayPointSetByBuffer(EMmsg, display, *srf_env,
                                        NULL_OBJID, 1, area_point, TRUE);
            }
#           endif
    
            /*Check to see that the area_point picked does not snap to the end
             * of the curve.
             */
            (void) BSmdstptcv(p_curve_geom, area_point, 
                              &proj_cv_par, proj_pt_unused, &proj_dist, &bsrc);
            if (BSERROR(bsrc) && bsrc!=BSINARG)
            {*EMmsg=EMS_E_BSerror; goto wrapup;}
    
            if (proj_cv_par == 1.0 || proj_cv_par == 0.0) 
            {
#             if DEBUG
              {
                fprintf(stderr, "proj to %lf - bad area_point picked\n", 
                        proj_cv_par);
              }         
#             endif         
              continue;
            }            
    
            DLB_BSptsdofcv(p_curve_geom, area_point, sf_nrml, &point_side, &bsrc);
    
#           if DEBUG
            {
              if (bsrc==BSINARG) fprintf(stderr, "BSINARG - Bad area_point\n");
              else if (point_side==RIGHT_SIDE)
                fprintf(stderr, "RIGHT_SIDE pick\n");
              else if (point_side==ON_CURVE)fprintf(stderr, "ON_CURVE pick\n");
              else fprintf(stderr, "LEFT_SIDE pick\n");
              fprintf(stderr, "\n");
            }
#           endif
    
            if (BSERROR(bsrc))
            {
              bsrc = BSINARG;
            }
    
            if (bsrc != BSINARG)
            {
              if (point_side != ON_CURVE || p_curve_geom->phy_closed) break;
            }
          }
      
          if (ii == MAXTRY)
          {
#           if DEBUG
             fprintf(stderr, "BSptsdofcv failed %d times\n", ii);
#           endif
          
            use_next_curve = TRUE;  
          }
        } 
        while(use_next_curve && cur_curve < num_of_objects);
  
        /*If only 1 curve & use_next_curve is TRUE then just pick a lpset
         * since don't have a good curve to use.
         */

        if (point_side == RIGHT_SIDE) /*point on the right side...*/
        {
#         if DEBUG
            fprintf(stderr, "side calc - 1st loopset on orig sf\n"); 
#         endif
          org_srf_ls = *gr1_ls_id;
          part_srf_ls = *gr2_ls_id;
          part_srf_range = gr2_ls_range;
        }
        else
        {
#         if DEBUG
            fprintf(stderr, "side calc - 2nd loopset on orig sf\n");
#         endif
          org_srf_ls = *gr2_ls_id;
          part_srf_ls = *gr1_ls_id;
          part_srf_range = gr1_ls_range;
        }      
      }
      else /*Have an incoming track point*/
      {
        IGRdouble             min_proj_uv[2];
        IGRint                num_pt;
        struct EMSpartolbasis partolbasis;
        struct EMSptloc_info  location_info;
        IGRboolean            orig_is_1st;


        (void) BSptnorsf(p_surf_geom, track_pt, &num_pt,
                         &min_proj_uv[0], &min_proj_uv[1], 
                         proj_pt_unused, &proj_dist, &bsrc);
        if (BSERROR(bsrc))
        {*EMmsg = EMS_E_BSerror; goto wrapup;}

        partolbasis.mattyp = &srf_env->md_env.matrix_type;
        partolbasis.mat = srf_env->md_env.matrix;
        partolbasis.is_valid = FALSE;
        partolbasis.in_world = TRUE;

        OM_stat = om$send(msg = message EMSloopset.EMpt_location(EMmsg,
                                min_proj_uv, &location_info, &partolbasis),
                          targetid = *gr1_ls_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        
        if (location_info.location == EMS_L_OUTSIDE ||
            location_info.location == EMS_L_UNKNWN)
        {
          orig_is_1st = TRUE;
        }
        else if (location_info.location == EMS_L_INAREA)
        {
          orig_is_1st = FALSE;
        }
        else /*in_hole or on_edge*/
        {
          /*There are 2 possibilities here. 
           * 1 - the point is in the area of the 2nd ls.
           * 2 - the point is in a real hole region or is on an edge.
           * 
           * In the 1st case, the orig sf should get the 1st ls.
           * In the 2nd case, the point is in an AMBIGUOUS location which
           *  means I can't determine which ls to put on the orig sf.  So
           *  arbitrarily but the the 1st ls on the orig sf.  
           *
           * So, in either case above, put the 1st ls on the orig sf.
           */
          orig_is_1st = TRUE;
        }

#       if DEBUG
        {
          if (orig_is_1st)
            fprintf(stderr, "track_pt - 1st loopset on orig sf\n"); 
          else
            fprintf(stderr, "track_pt - 2nd loopset on orig sf\n");
        }
#       endif

        if (orig_is_1st)
        {
          org_srf_ls = *gr1_ls_id;
          part_srf_ls = *gr2_ls_id;
          part_srf_range = gr2_ls_range;
        }
        else
        {
          org_srf_ls = *gr2_ls_id;
          part_srf_ls = *gr1_ls_id;
          part_srf_range = gr1_ls_range;
        }      
      }

      /*Reconnect the old loopset*/
      OM_stat = om$send(msg = message Root.wild_disconnect(srf_ls_chan),
                          targetid = srf_GRid.objid);
      if (!(1 & OM_stat)) goto wrapup;
  
      OM_stat = om$send(msg = message Root.connect(srf_ls_chan, NULL, 
                              *sf_org_ls, OM_Gw_current_OS,
                              ls_srf_chan, NULL),
                        targetid = srf_GRid.objid);
      if (!(1 & OM_stat)) goto wrapup;                      
    } /*END INTENTIONAL BLOCK*/

    /*
     * o Get the feature loops present on the surface.
     * o For each of these feature loops,
     *   o Disconnect it from its loopset.
     *   o Connect it to org_sf_ls.
     *   o Copy it and attach its copy to the partial sf ls
     *   o Update the flps as well as their copies w.r.t their
     *     respective loopsets.
     *   o Save the update information for flps for save state
     *     purposes.
     */

    depth = 1;
    buf_size = num_flps = 0;
    OM_stat = om$send (msg = message EMSloopset.EMget_loops (&mthd_stat,
                        EMS_OPT_FEATURES, &depth, &flps, NULL,
                        &buf_size, &num_flps),
                       senderid = srf_GRid.objid,
                       p_chanselect = &srf_ls_chan);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

    if (num_flps)
    {
     OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                         &flp_cur_ls),
                        senderid = flps[0],
                        p_chanselect = &lp_ls_chan);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

     if (!IF_EQ_OBJID(flp_cur_ls, org_srf_ls))
     {
      for (i = 0; i < num_flps; i++)
      {
       OM_stat = om$send (msg = message Root.wild_disconnect (lp_ls_chan),
                          targetid = flps[i]);
       EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

       OM_stat = om$send (msg = message Root.connect (lp_ls_chan,
                          MAXINT, org_srf_ls, OM_Gw_current_OS,
                          ls_lp_chan, NULL),
                         targetid = flps[i]);
       EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      } /* for (i = 0; i < num_flps; i++) */

     } /* if (!IF_EQ_OBJID(flp_cur_ls, org_srf_ls)) */

    } /* if (num_flps) */

    /*
     * disconnect the orginal surface from its
     * existing loopset (gr1_ls_id or gr2_ls_id).
     * Connect the original surface with org_srf_ls.
     */

    OM_stat = om$send (msg = message Root.wild_disconnect (srf_ls_chan),
                        targetid = srf_GRid.objid);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    OM_stat = om$send (msg = message Root.connect (
                        srf_ls_chan, NULL, org_srf_ls, OM_Gw_current_OS,
                        ls_srf_chan, NULL),
                       targetid = srf_GRid.objid);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    /*
     * Now the part_srf_ls is decided. This loopset will
     * be used to construct the partial surface. This
     * loopset may have some loops which were originally on 
     * the original surafce. Since these moved loops
     * have to be saved for deactivate purposes, they have to
     * be copied and placed in the part_srf_ls. Also since
     * the (u,v) space of the part_srf_ls will be transformed,
     * the its edges will be a part of the new (u,v) space. 
     * If any of these edges are shared by a loop other than
     * the loop of the part_srf_ls, they have to be copied.
     * To perform a method is written to collapse (if necessary)
     * and copy (if necessary) the loops and edges.
     */

    OM_stat = om$send (msg = message EMSloopset.EMmkface_collapse_copy(
                        &mthd_stat, &partolbasis, *new_lps_added,
                        num_new_lps_added, &lps_taken_out,
                        &num_lps_taken_out, &taken_out_lps_array_size,
                        &ed_con_info, &num_edcon_entries,
                        &edcon_array_size),
                       targetid = part_srf_ls);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_MkfCollapse,wrapup);

 /*
     * the EMLP_EXTERNAL bit of the external loops may
     * not be set.
     *

    {
       props = EMLP_EXTERNAL;
      
       OM_stat = om$send (msg = message EMSloop.EMset_props (&mthd_stat,
                           props, EMS_O_ON),
                        senderid = part_srf_ls,
                        p_chanselect = &ls_lp_chan);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

       OM_stat = om$send (msg = message EMSloop.EMset_props (&mthd_stat,
                           props, EMS_O_ON),
                        senderid = org_srf_ls,
                        p_chanselect = &ls_lp_chan);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

     }

*/

    /*
     * extract a partial surface corresponding to the 
     * range of the loopset to be imposed on this new surface.
     */

   if (surface.u_phy_closed || surface.v_phy_closed)
   {
        mid_par[0] = (part_srf_range[0] + part_srf_range[2])/2.;
        mid_par[1] = (part_srf_range[1] + part_srf_range[3])/2.;
   }
        
   OM_stat = om$send (msg = message EMSsubbs.EMpartsf( &mthd_stat,
                       construct_list, &part_srf_range[0], mid_par,
                       &part_srf_range[2], 2, &part_srf_id, NULL, FALSE,
                       FALSE),
                      targetid = srf_GRid.objid,
                      targetos = srf_GRid.osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

 /***********************************************************************
  *KLUDGE BECAUSE GRAPHICS LOOPS PROCESSING ADDS A NATURAL BNDRY TO THE
  * PART SURFACE.
  ***********************************************************************/

  OM_stat = om$send(msg = message Root.delete(NULL),
                    senderid = part_srf_id,
                    p_chanselect = &srf_ls_chan);
  if (!(1 & *EMmsg)) goto wrapup;                    

  /***********************************************************************
   *END KLUDGE
   **********************************************************************/

   OM_stat = om$send (msg = message Root.connect( srf_ls_chan, NULL,
                       part_srf_ls, OM_Gw_current_OS, ls_srf_chan,
                       NULL),
                      targetid = part_srf_id);
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    /*
     * Some of the garphic data objects corresponding to the
     * partial surface may still be connected
     * to the original surface. Move them to the partial
     * surface.
     */

    OM_stat = om$send (msg = message EMSboundary.EMtree_traverse( 
                        &mthd_stat, 
                        message EMSgradata.EMchangeSurface(
                          &mthd_stat, part_srf_id), MAXINT, 1, 
                          &OPP_EMSgradata_class_id, TRUE,
                          EMLP_PLOOP, NULL, NULL),
                        senderid = part_srf_ls,
                        p_chanselect = &ls_lp_chan);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
 
   /*
    * The c-loops in the original loopset and the newly
    * created partial surface loopset may have EMLP_DUMMY_CLOOP
    * bit left on during splitting loopset process. This bit
    * should turned off.
    */

    OM_stat = om$send (msg = message EMSboundary.EMtree_traverse( 
                        &mthd_stat, 
                        message EMSloop.EMset_props( &mthd_stat, 
                         EMLP_DUMMY_CLOOP, EMS_O_OFF), 
                        MAXINT, 1, &OPP_EMSloop_class_id, TRUE, 
                        EMLP_DUMMY_CLOOP, NULL, NULL),
                       senderid = part_srf_ls,
                       p_chanselect = &ls_lp_chan);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
    
    OM_stat = om$send (msg = message EMSboundary.EMtree_traverse( 
                        &mthd_stat, 
                       message EMSloop.EMset_props( &mthd_stat, 
                        EMLP_DUMMY_CLOOP, EMS_O_OFF), 
                       MAXINT, 1, &OPP_EMSloop_class_id, TRUE, 
                       EMLP_DUMMY_CLOOP, NULL, NULL),
                      senderid = org_srf_ls,
                      p_chanselect = &ls_lp_chan);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
    
    if (num_flps)
    {
     IGRint   num_features = 0, numowners = 0, num_sfs;
     GRobjid  *features = NULL;
     struct EMSownercomp    *owncomps = NULL;

     flps_copy = (GRobjid *) om$malloc (size= num_flps * sizeof(GRobjid));
     EMerr_hndlr (!flps_copy, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     for (i = 0; i < num_flps; i++)
     {
      OM_stat = om$send (msg = message EMSboundary.EMtpcopy (&mthd_stat,
                          NULL, OM_Gw_current_OS, OM_Gw_current_OS, NULL,
                         &flps_copy[i]),
                         targetid = flps[i]);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

      OM_stat = om$send (msg = message Root.connect (lp_ls_chan,
                          MAXINT, part_srf_ls, OM_Gw_current_OS,
                          ls_lp_chan, NULL),
                         targetid = flps_copy[i]);  
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      OM_stat = om$send (msg = message EMSgradata.EMinit (&mthd_stat,
                          part_srf_id, NULL_OBJID),
                         targetid = flps_copy[i]);
      /* Patch for point loops.
       * NP 09/09/92
       */
      if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

     } /* for (i = 0; i < num_flps; i++) */

     num_sfs = (*sf_lps_removed) ? 1 : 0;

     OM_stat = om$send (msg = message EMSloopset.EMupdate_features (
                         &mthd_stat, &features, &num_features, &num_sfs,
                         sf_lps_removed, &numowners, &owncomps, TRUE, 
                         &partolbasis),
                        targetid = org_srf_ls);
     EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_LoopsetError,wrapup);
 
     if (num_features)
     {
      if (*num_new_lps_added)
      {
        *new_lps_added = (GRobjid *) om$realloc 
                         (ptr = (IGRchar *) *new_lps_added,
                          size = (*num_new_lps_added + num_features) *
                                 sizeof(GRobjid));
        EMerr_hndlr(!(*new_lps_added),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
        OM_BLOCK_MOVE (features, &(*new_lps_added)[*num_new_lps_added],
                       sizeof(GRobjid) * num_features);
        (*num_new_lps_added) += num_features;
     }
      else
      {
       *num_new_lps_added = num_features;
       *new_lps_added = features;
       features = NULL;
      }
    
     } /* if (num_features) */

     if (features)   om$dealloc (ptr = features);

     num_features = 0;
     features = NULL;
          OM_stat = om$send (msg = message EMSloopset.EMupdate_features (
                         &mthd_stat, &features, &num_features, NULL,
                         NULL, &numowners, &owncomps, TRUE, &partolbasis),
                        targetid = part_srf_ls);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

     if (features) om$dealloc (ptr = features);

   } /* if (num_flps) */


   /*
    * The geometry of the loopset to be connected 
    * to the above constructed partial surface is in (u,v) space
    * of the original surface. It is therefore needed to 
    * transform the loopset's geometry to the partial surface's
    * geometry.
    */

    new_range[0] = 0.;
    new_range[1] = 0.;
    new_range[2] = 1.;
    new_range[3] = 1.;

    status = EFget_uv_trans_mat (&mthd_stat, part_srf_range, new_range,
                                  trans_mat);
    EMerr_hndlr ((!status || !(1&mthd_stat)),*EMmsg,EMS_E_Fail,wrapup);

    OM_stat = om$send (msg = message EMSboundary.EMuv_transform(
                        &mthd_stat, trans_mat, &partolbasis, TRUE, 
                        NULL, NULL),
                       targetid = part_srf_ls);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

   /*
    * connect the newly constructed partial surface
    * to me.
    */

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;
    owners_index = OM_K_MAXINT;
    OM_stat = om$send (msg = message GRconnector.GRrigidconn ( &mthd_stat,
                        &my_GRid, &owners_index),
              targetid = part_srf_id);
    EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
         
    if (dis_options & EMS_DO_DISPLAY &&
        !(dis_options & EMS_DONT_REDRAW))
    {
      /*
       *display the modified surface
       */
  
      DisplayMode = GRbd;
      OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                          &srf_env->md_env.matrix_type,
                           srf_env->md_env.matrix, &DisplayMode,
                          &srf_env->md_id),
                        targetid = srf_GRid.objid, 
                        targetos = srf_GRid.osnum);                       
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
    }

    /*
     * All of the processing is done for making a face
     * process. Now is the time to save all the information
     * needed to for deactivate and activate processes.
     *
     * The following information is needed to be saved:
     *
     *  1) the loops that are taken out. This will
     *     include the loops taken out during 
     *     splitting process and the loops whose
     *     copies were moved on to the partial surface
     *     constructed for make face. This information
     *     will be stored through SSI instance data
     *     and EMSdpr.ids[] vla.
     *
     *  2) Some of the edges were split during
     *     loops trimming process. At the same 
     *     time the common edges of these edges, if
     *     any, were also split. Then the original
     *     edges common edges were replaced by their
     *     partedges in their respective loops.
     *     This information about common edges and
     *     and their part edges will be stored through
     *     SSI inastance data and EMSdpr.ids[] vla.
     *
     *   3) The loops that were moved/(copied and moved) on the
     *      partial surface. Since the (u,v) space of the the
     *      partial surface is different from that of original
     *      surface (u,v) space, they have to be tranformed to 
     *      the new (u,v) space. If the edge had more than
     *      one owner, its copy was made. If the edge was
     *      connected to another edge across its common edge
     *      channel, it was discconectd and its copy was
     *      connected to the common edge.
     *      This information is also stored in SSI instance date
     *      EMSdpr.ids[] vla.
     *
     *      The edges are stored in the following manner:
     *          EMSdpr.ids[x]            - x)    ed1,
     *                                     x+1)  ed1_cp,
     *                                     x+2)  ed2,
     *                                     x+3)  ed2_cp,
     *                                     x+4)  ed3,
     *                                     x+5)  ed3_cp
     *                                          .
     *                                          .
     *                                          . 
     */

   /*
    * Get the edges of the original surface that were split.
    */

   EMget_sp_edges (&mthd_stat, *loops_trim_info, *num_trim_info,
                   (*sf_lps_removed) ? (*sf_lps_removed)->num_comps : 0, 
                   (*sf_lps_removed) ? (*sf_lps_removed)->comps : NULL,  
            &split_edges, &num_split_edges);
   EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

   /*
    * now we have all of the edges of the origunal surface
    * that were split. Next job is to find out their common
    * edges and the top part edges of these common edges.
    * These top part edges replaced the the common edges
    * during splitting process and we need to save
    * this information for the save state purposes.
    */

  if (num_split_edges)
  {
    OM_stat = EMmake_chanselect (EMSloop_to_outter, &lp_ls_chan);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    sped_info = (struct split_ed_info *) om$malloc(size =
                num_split_edges * sizeof(struct split_ed_info));
    EMerr_hndlr(!sped_info,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

    com_ed_lps = (GRobjid *) om$malloc(size =
                num_split_edges * sizeof(GRobjid));
    EMerr_hndlr(!com_ed_lps,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

    num_com_ed_lps = 0;
    for (i = 0; i < num_split_edges; i++)
    {

           OM_stat = om$send (msg = message EMSboundary.EMget_objid(
                               &mthd_stat,
                               &(sped_info[num_sped_entries].com_ed_id)),
                              senderid = split_edges[i],
                              p_chanselect = &com_ed_chan);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

          sped_info[num_sped_entries].part_edges = NULL;
          sped_info[num_sped_entries].num_part_edges = 0;
          buf_size = 0;
          OM_stat = om$send (msg = message EMSedge.EMget_top_part_edges(
                             &mthd_stat,
                             &(sped_info[num_sped_entries].part_edges),
                            &(sped_info[num_sped_entries].num_part_edges),
                            &buf_size),
                targetid = sped_info[i].com_ed_id);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
        sts = EMsend_loops(&mthd_stat,
                           message EMSboundary.EMget_objid( &mthd_stat,
                            &(sped_info[num_sped_entries].lp_id)),
                            sped_info[num_sped_entries].part_edges[0],
                            NULL, OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
         EMerr_hndlr(!(1&sts&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
        
         num_part_edges +=sped_info[num_sped_entries++].num_part_edges;

        /*
         * It may be possible that the loop is the same as
         * that of another sped_info entry. In this case 
         * donot increase num_com_ed_lps
         */
        
        lp_exists = FALSE;

        if (num_sped_entries > 1)
        {       
          IGRint cur_entry = 0;

          do
          {
            if (sped_info[cur_entry].lp_id == 
                sped_info[num_sped_entries - 1].lp_id) lp_exists = TRUE;
            else cur_entry++;
          } while (cur_entry < (num_sped_entries-1) && !lp_exists);
        
        } /* if (num_sped_entries > 1) */

        if (!lp_exists) com_ed_lps[num_com_ed_lps++] 
                = sped_info[num_sped_entries - 1].lp_id;

         /*
          * It may be possible that the loop of the common edge
          * was a natural one before splitting and after splitting
          * has become non natural. It is therefore needed to
          * turn EMLP_NATURAL off. Also turn off the EMLS_NATURAL
          * bit of the loopset owning this loop.
          */

         if (!lp_exists) 
         {
          props = EMLP_NATURAL;
          OM_stat = om$send (msg = message EMSloop.EMset_props(
                        &mthd_stat, props, EMS_O_OFF),
                   targetid = sped_info[num_sped_entries-1].lp_id);

          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

          OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info(
                                &mthd_stat, &cm_ed_srf, NULL),
                           targetid= sped_info[num_sped_entries-1].lp_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
        
          props = EMLS_NATURAL;
          OM_stat = om$send (msg = message EMSloopset.EMset_props (
                        &mthd_stat, props, EMS_O_OFF),
                        senderid = cm_ed_srf,
                        p_chanselect = &srf_ls_chan);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
          } /* if (!lp_exists) */

    } /* for (i = 0; i < num_split_edges; i++) */

  } /* if (num_split_edges) */

  /*
   * now all of the information is ready, time to save it.
   * fill SSI table and call putSSI
   */
    
  ssi_size.mf_info.num_surfaces = 1;
  ssi_size.mf_info.num_regions_in = *num_new_lps_added;
  if (*sf_lps_removed) ssi_size.mf_info.num_regions_out = 
                        (*sf_lps_removed)->num_comps + num_lps_taken_out;
  else
       ssi_size.mf_info.num_regions_out = num_lps_taken_out;

  ssi_size.mf_info.num_regions =  num_com_ed_lps;
  ssi_size.mf_info.num_edges_in = num_part_edges;
  ssi_size.mf_info.num_edges_out = num_sped_entries;
  ssi_size.mf_info.num_edges_copied = num_edcon_entries;

  OM_stat = om$send (msg = message EMSdpr.EMgetSSIbuffer(
                      &mthd_stat, &ssi_size, &ssi_table),
                     targetid = my_id);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
  
  /*
   * fill the buffer
   */

  my_info = &ssi_table->mf_info;
  my_info->num_surfaces = 1;
  my_info->surface_ids[0] = srf_GRid.objid;
  my_info->num_regions_in[0] = *num_new_lps_added;

  for (i = 0; i < *num_new_lps_added; i++)
        my_info->region_in_ids[i] = (*new_lps_added)[i];

  if (*sf_lps_removed) my_info->num_regions_out[0] =  
                        (*sf_lps_removed)->num_comps + num_lps_taken_out;
  else
      my_info->num_regions_out[0] = num_lps_taken_out;

    i = 0;
    if (*sf_lps_removed)
     for (i = 0; i < (*sf_lps_removed)->num_comps; i++)
       my_info->region_out_ids[i] = (*sf_lps_removed)->comps[i];

    for (j = 0; j < num_lps_taken_out; j++, i++)
        my_info->region_out_ids[i] = lps_taken_out[j];

    my_info->num_regions = num_com_ed_lps;
    my_info->cum_num_edges_out = num_sped_entries;

    for (i = 0; i < num_com_ed_lps; i++)
        my_info->region_ids[i] = com_ed_lps[i];

     k = l = lk = 0;

     for (i = 0; i < num_com_ed_lps; i++)
     {
        my_info->num_edges_out[i] = 0;

        for (j = 0; j < num_sped_entries; j++)
        {
          if (sped_info[j].lp_id == com_ed_lps[i])
          {
            my_info->num_edges_in[k++] = 
                        sped_info[j].num_part_edges;
            my_info->num_edges_out[i] += 1;

            for (jj = 0; jj < sped_info[j].num_part_edges; jj++)
             my_info->edge_in_ids[l++] = sped_info[j].part_edges[jj];

            my_info->edge_out_ids[lk++] = sped_info[j].com_ed_id;

          } /* if (sped_info[j].lp_id == com_ed_lps[i]) */

        } /* for (j = 0; j < num_sped_entries; j++) */

     } /* for (i = 0; i < num_com_ed_lps; i++) */

     /*
      * get the edge id and its common edge id from the
      * ed_con_info. From the common edge, get the 
      * edge's copy id. The reason for saving edge's
      * common edge instead of edge' copy id is that
      * copied id might have changed during transformation
      * of the partial surface loopset due to the change in
      * copied edge class.
      */

     my_info->num_edges_copied = num_edcon_entries;

     k = 0;
     for (i = 0; i < num_edcon_entries; i++)
     {
       my_info->ed_cp_ed_ids[k++] = ed_con_info[i].ed_id;
       
       /*
        * get the copied edge and save it
        */

       OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                           &mthd_stat, &cp_ed_id),
                          senderid = ed_con_info[i].cm_ed_id,
                          p_chanselect = &com_ed_chan);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       my_info->ed_cp_ed_ids[k++] = cp_ed_id;
     }
       

    /*
     * Post the ssi table
     */

    OM_stat = om$send (msg = message EMSdpr.EMputSSI( &mthd_stat, 
                        ssi_table), targetid = my_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

    if (dis_options & EMS_DO_DISPLAY)
    {
      if (dis_options & EMS_DONT_REDRAW)
      {
        OM_stat = EFwork_the_display(&mthd_stat, dis_options, part_srf_id,
                                     display_ids, display_count, NULL);
        if (!(1 & OM_stat & mthd_stat)) goto wrapup;                  
      }
      else
      {
        /*
         *display the  newly constructed surface
         */
        DisplayMode = GRbd;
        OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                            &srf_env->md_env.matrix_type,
                             srf_env->md_env.matrix, &DisplayMode,
                            &srf_env->md_id),
                          targetid = part_srf_id);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
      }
    }
 
    /*
     * If the surface used is physically closed and the new surface
     * created is no longer physically closed, some of its edges
     * corresponding to the seam edges of the original surface
     * may incorrectly be marked as seam. For example, if a face
     * is made on a cylinder with boundary parallel to its axis,
     * it will be broken into half cylinder. After face is made,
     * the edges corresponding to original cylinders seam, will no
     * be seam but will still be marked as seam. 
     * o For each of these edges,
     *   o If its common edge does not belong to the made face, turn
     *     its as well as its common edge's seam property bit off.
     */

    array_size = num_seam_eds = 0;
    OM_stat = om$send (msg = message EMSboundary.EMget_edges (&mthd_stat,
                        OM_K_MAXINT, EMS_OPT_SEAM, &seam_eds, &array_size,
                        &num_seam_eds),
                       senderid = part_srf_id,
                       p_chanselect = &srf_ls_chan);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

    for (i = 0; i < num_seam_eds; i++)
    {
     OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info (
                         &mthd_stat, &cm_ed_sf, NULL),
                        senderid = seam_eds[i].objid,
                        p_chanselect = &com_ed_chan);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     if (!IF_EQ_OBJID(part_srf_id, cm_ed_sf))
     {
      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                          EMED_SEAM, EMS_O_OFF),
                         targetid = seam_eds[i].objid);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                          EMED_SEAM, EMS_O_OFF),
                         senderid = seam_eds[i].objid,
                         p_chanselect = &com_ed_chan);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     } /* if (!IF_EQ_OBJID(part_srf_id, cm_ed_sf)) */

    } /* for (i = 0; i < num_seam_eds; i++) */

wrapup:

  EMWRAPUP (*EMmsg, OM_stat, "In EMSsfmkface.EMmake_face_execute");

  if (seam_eds) om$dealloc (ptr = seam_eds);

  /*
   * if make face fails, bring the model to the state
   * it was before starting make face
   */

  if (!(1&OM_stat&*EMmsg))
  {
     OM_stat = om$send (msg = message EMSsfmkface.EMgraceful_exit (
                         &mthd_stat, &partolbasis, srf_env, 
               recover_on_error ? *loops_trim_info : NULL, 
               recover_on_error ? *num_trim_info : NULL,
                         ed_con_info, 
                         num_edcon_entries, *gr1_ls_id, *gr2_ls_id, 
                         srf_GRid, *sf_org_ls, *sf_org_lps, 
                         *num_sf_org_lps, part_srf_id, dis_options),
                        targetid = my_id);

   if (!(1&OM_stat&mthd_stat)) *EMmsg = EMS_E_MkfGrExit;

  } /* if (!(1&OM_stat&*EMmsg)) */
        

  /*
   * free memory
   */

  if (*amb_lps) om$dealloc (ptr = *amb_lps);
  if (imp_lps_ids) om$dealloc (ptr = imp_lps_ids);
  if (*sf_org_lps) om$dealloc (ptr = *sf_org_lps);
  if (lps_taken_out) om$dealloc (ptr = lps_taken_out);
  if (*new_lps_added) om$dealloc (ptr = *new_lps_added);
  if (ed_con_info) om$dealloc (ptr = ed_con_info);
  if (ssi_table) om$dealloc(ptr = ssi_table);
  if (com_ed_lps) om$dealloc (ptr = com_ed_lps);
  if (flps) om$dealloc (ptr = flps);
  if (flps_copy) om$dealloc (ptr = flps_copy);
  
  if (sped_info)
  {
      for (i = 0; i < num_sped_entries; i++)
         if (sped_info[i].part_edges) 
                        om$dealloc (ptr = sped_info[i].part_edges);

      om$dealloc (ptr = sped_info);
  }

  if (split_edges) om$dealloc(ptr = split_edges);
  if (*sf_lps_removed) EMownercomp_free(*sf_lps_removed,NULL);
  if (*loops_trim_info)
  {
        for (i = 0; i < *num_trim_info; i++)
          EMsfintedpar_free((*loops_trim_info)[i],2);
        
        om$dealloc(ptr = *loops_trim_info);
  }

  return (OM_stat);

}

#ifdef MUST_USE_OWN_PTSDOFCV

void DLB_BSptsdofcv(curve,pt,vec,side,rc)

struct IGRbsp_curve      *curve;
IGRpoint                 pt;
IGRvector                vec;
IGRint                   *side;
BSrc                     *rc;
{
  struct IGRbsp_curve    *cv;
  IGRdouble              dist,dist_tol;
  IGRpoint               p,base;
  IGRdouble              dot,dot_tol;
  IGRpoint               p1,p2;
  IGRdouble              pars;
  IGRint                 num_deriv;
  IGRint                 i;
  IGRboolean             status;
  IGRint                 xcord,ycord,turn;
  IGRdouble              par1,par2;
  IGRdouble              knot_tol;
  IGRpoint               Q;
  IGRdouble              q[6];
  IGRvector              v,d_vec;
  IGRboolean             right_hand = TRUE;
  IGRdouble              tmat[3][3];
  IGRpoint               origin;
  IGRdouble              s = 1;
  IGRint                 ind;
  IGRboolean             pos_orient;
  BSrc                   rc1;

  *rc = BSSUCC;
  cv = NULL;
  origin[0] = 0;
  origin[1] = 0;
  origin[2] = 0;

  BSEXTRACTPAR(rc,BSTOLLENVEC,dist_tol);
  BSEXTRACTPAR(rc,BSTOLORTHOVEC,dot_tol);

  BScvkttol2(curve->order,curve->knots,curve->num_poles,curve->poles,
             curve->weights,&knot_tol,rc);
  if (BSERROR(*rc))
    goto wrapup;

  status = BSnorvec(rc,vec);
  if (!status)
    goto wrapup;

  BSstkallocv(rc,cv,curve->num_poles,curve->rational,curve->num_knots,
                                                curve->num_boundaries);
  if (BSERROR(*rc))
    goto wrapup;

  status = BScv_copy(rc,curve,cv);
  if (!status)
    goto wrapup;


  if ( ABS(1 - vec[2]) > dist_tol)
  {
    /* transform the input curve and point to 
       new cordinate with vec as z axis */

    BStrans2(vec,right_hand,tmat,rc);
    if (BSERROR(*rc))
      goto wrapup;
 
    status = BScvoton(rc,origin,tmat,&s,curve,cv);
    if (!status)
      goto wrapup;
  
    status = BSptoldtnw(rc,origin,tmat,&s,pt,p);
    if (!status)
      goto wrapup;
    p[2] = 0.0;
  }
  else
  {
    p[0] = pt[0];
    p[1] = pt[1];
    p[2] = 0;
  }
  
  /* project cv to xy_plane */

  for (i = 0; i < cv->num_poles; ++i)
  {
    cv->poles[i * 3 + 2] = 0;
  }

  /* if curve is closed, call BSpt_in_cv */

  if (curve->phy_closed)
  {
    BSpt_in_cv(cv,p,FALSE,&pos_orient,&ind,rc);
    if (BSERROR(*rc))
      goto wrapup;

    if (ind == 2)
      *side = 2;
    else if ((pos_orient && ind == 1) || (!pos_orient && ind == 0))
      *side = 0;
    else
      *side = 1;
    goto wrapup;
  }

  /* Find point on cv with minmum distance from p */
  
  BSmdstptcv(cv,p,&pars,base,&dist,rc);
  if (BSERROR(*rc))
    goto wrapup;

  if (dist < dist_tol)
  {
    *side = 2;
    goto wrapup;
  } 

  if ( ABS(pars - cv->knots[cv->order - 1]) < knot_tol )
  {
    num_deriv = 1;
    BScveval(cv,pars,num_deriv,(IGRpoint *)q,rc);
    if (BSERROR(*rc))
      goto wrapup;
    status = BSnorvec(rc,&q[3]);
    if (!status)
      goto wrapup;
    status = BSmkvec(rc,v,&q[0],p);
    if (!status)
      goto wrapup;
    status = BSnorvec(rc,v);
    if (!status)
      goto wrapup;
    dot = BSdotp(rc,&q[3],v);
    if (dot > dot_tol)
    {
      *rc = BSINARG;
      goto wrapup;
    }
    else
    {
      par1 = pars;
      par2 = pars + 10 * knot_tol;
    }
  }
  else if (ABS(pars - cv->knots[cv->num_poles]) < knot_tol)
  {
    num_deriv = 1;
    BScveval(cv,pars,num_deriv,(IGRpoint *)q,rc);
    if (BSERROR(*rc))
      goto wrapup;
    status = BSnorvec(rc,&q[3]);
    if (!status)
      goto wrapup;
    status = BSmkvec(rc,v,&q[0],p);
    if (!status)
      goto wrapup;
    status = BSnorvec(rc,v);
    if (!status)
      goto wrapup;
    dot = BSdotp(rc,&q[3],v);
    if (dot < -dot_tol)
    {
      *rc = BSINARG;
      goto wrapup;
    }
    else
    {
      par1 = pars - 10 * knot_tol;
      par2 = pars;
    }
  }
  else
  {       
    par1 = pars - 10 * knot_tol;
    par2 = pars + 10 * knot_tol;
    num_deriv = 0;
    BScveval(cv,pars,num_deriv,(IGRpoint *)q,rc);
    if (BSERROR(*rc))
      goto wrapup;
  }

  for (i = 0; i < 3; ++i)
  {
    d_vec[i] = p[i] - q[i];
  }
  status = BSnorvec(rc,d_vec);
  if (!status)
    goto wrapup;
  num_deriv = 0;
  BScveval(cv,par1,num_deriv,(IGRpoint *)p1,rc);
  if (BSERROR(*rc))
    goto wrapup;
  BScveval(cv,par2,num_deriv,(IGRpoint *)p2,rc);
  if (BSERROR(*rc))
    goto wrapup;
  dist = BSdistptpt(rc,p1,p2);
  for (i = 0; i < 3; ++i)
  {
    Q[i] = q[i] + d_vec[i] * dist;
  }
  xcord = 0;
  ycord = 1;
  status = BSlftorrght(rc,p1,Q,p2,&xcord,&ycord,&turn);
  if (!status)
    goto wrapup;
  if (turn == 1 )
  {
    *side = 1;
  }
  else if (turn == 2 )
  {
    *side = 0;
  }
  else
  {
    *side = 2;
  }

  wrapup:
    if (cv)
      BSstkfreecv(&rc1,cv);

    {
    return;
    }

}
#endif

end implementation  EMSsfmkface;
                                  
