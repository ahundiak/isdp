/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsf_lift;

#include "EMS.h"
/*
        This method performs all of the processing needed in a lift
        operation.

History   RC    04/2/87    Creation Date
          RC    10/30/87   Modified for version 1.1.0
          RC    03/02/88   Modified arguments to include constraints.
                           Rewrote the code.
          Sudha 06/23/93   Modified for BSprototype ansification

Algorithm
         o If any new surfaces are to be created or exisitng
           surfaces need to be trimmed, save the geometry of the
           surface to be modified.

         o Erase the surface.

         o Modify the surface.

         o Display the modified surface.

         o If there are any edges of the above surface that have
           common edges
           {
             o Create a new surface or trim the common edge's
               surface as per the requirement.

             o If a new surface is created, 
                     - connect it to me.
                     - align its normal correctly.

             o Re-establish the topology.
               
           }

*/

#include <stdio.h>
#include "OMmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bscveval.h"

from EMSsubbs    import EMexeinst;
from EMSedge     import EMget_bcxyz_geom;

extern OMuword   OPP_EMSsolid_class_id;

method EMlift_execute (
        IGRlong                 *EMmsg;
        struct GRmd_env         *md_env;
        struct GRvg_construct   *construct_list;
        struct EMSlft_info      *lift_info;
        IGRushort       dis_options;
        GRobjid                 **display_ids;
        IGRint                  *display_count)

{
  OM_S_CHANSELECT              to_comps_chan;
  struct EMSlft_edv0v1_info    edv0v1_info;
  struct EMSlft_edmtch_info    ed_u0s, ed_u1s, last_ed_u1s, 
                               lp_ed_u0s, lp_ed_u1s;
  struct EMSlft_edcn_info      ed_cn_info;
  struct EMSlft_edsp_info      ed_sp_info;
  struct EMSlft_lpmod_info     lps_mod_info;
  struct EMSlft_sfrmvd_info    sfrmvd_info;    
  struct GRid                  cm_ed_sf_GRid, cm_ed_GRid, sf_GRid, 
                               my_GRid;
  struct EMSlft_ed_info        *cur_ed_info;
  struct EMSlft_slp_info       *cur_sublp_info;
  struct EMSlft_lp_info        *cur_lp_info;
  struct IGRbsp_surface        *sf_old_geom, *sf_new_geom, *cm_ed_sfgm;
  struct IGRbsp_curve          cm_ed_oldgm, ed_oldgm, ed_newgm;
  union  EMSssi_table          ssi_table;
  struct EMSlftssi_table    *my_info;
  IGRdouble                    from_pt[3], to_pt[3], move_vec[3];
  IGRlong                      OM_stat;
IGRlong   mthd_stat, sf_size, rc;
  IGRint                       cur_lp, cur_sublp, cur_ed, i, work_ed = 0;
  IGRboolean                   cntinue, overlap_exists, 
                               ad_sf_trimmed = FALSE;
  IGRushort            ed_constraint;
  OMuword                      my_classid;
  enum    GRdpmode             DisplayMode;
  IGRuchar             lift_operation;
  extern void                  EFdoes_new_sf_overlaps_cm_ed_sf (),
                               EFtrim_cm_ed_sf1 (), EFcreate_lft_sf1 (),
                               BScveval(),
                               EFrmv_inacteds_actcm_eds ();

/* ********************************************************* */
                     
OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

ed_cn_info.num_eds = ed_cn_info.array_size = 0;
ed_cn_info.ed_ids = NULL;

ed_sp_info.num_eds = ed_sp_info.eds_arrsz = 0;
ed_sp_info.num_sp_eds = ed_sp_info.sp_eds_arrsz = 0;
ed_sp_info.ed_ids = ed_sp_info.sp_eds = NULL;
ed_sp_info.sp_eds_pred = NULL;

edv0v1_info.num_eds = 0;
edv0v1_info.ed_ids = NULL;

ed_u0s.num_eds = ed_u0s.array_size = 0;
ed_u0s.ed_ids = ed_u0s.sf_ids = NULL;

ed_u1s.num_eds = ed_u1s.array_size = 0;
ed_u1s.ed_ids = ed_u1s.sf_ids = NULL;

last_ed_u1s.num_eds = last_ed_u1s.array_size = 0;
last_ed_u1s.ed_ids = last_ed_u1s.sf_ids = NULL;

lp_ed_u0s.num_eds = lp_ed_u0s.array_size = 0;
lp_ed_u0s.ed_ids = lp_ed_u0s.sf_ids = NULL;

lp_ed_u1s.num_eds = lp_ed_u1s.array_size = 0;
lp_ed_u1s.ed_ids = lp_ed_u1s.sf_ids = NULL;

sf_old_geom = sf_new_geom = NULL;

lps_mod_info.num_sfs = lps_mod_info.sf_arrsz = 0;
lps_mod_info.num_lps_added = lps_mod_info.num_lps_rmvd = 0;
lps_mod_info.lps_added_arrsz = lps_mod_info.lps_rmvd_arrsz = 0;
lps_mod_info.sf_ids = lps_mod_info.lp_added_ids = NULL;
lps_mod_info.lp_rmvd_ids = NULL;
lps_mod_info.lps_added_prsf = lps_mod_info.lps_rmvd_prsf = NULL;

sfrmvd_info.num_compsf = sfrmvd_info.compsf_arrsz = 0;
sfrmvd_info.num_sf_rmvd = sfrmvd_info.sf_arrsz = 0;
sfrmvd_info.compsf_ids = sfrmvd_info.sf_ids = NULL;
sfrmvd_info.num_sf_prcompsf = sfrmvd_info.sf_idx = NULL;

sf_GRid = lift_info->sf_GRid;
lift_operation = lift_info->lift_operation;

my_GRid.objid = my_id;
my_GRid.osnum = OM_Gw_current_OS;

ex$message(msgnumb = EMS_I_ModifyingSurface)

/*
 * If one or more edges of the surface have common edges,
 * some new surfaces will be constructed or the common edges'
 * surfaces will be trimmed. In order to create new surfaces or
 * trim existing surfaces, the surface's old geometry will be
 * needed. Therefore, extract the surface's geomtery
 * and save it.
 */

if (lift_info->num_lps)
{
  OM_stat = om$send (msg = message GRvg.GRgetsize(&mthd_stat,
                &md_env->md_env.matrix_type, md_env->md_env.matrix, 
                &sf_size),
        targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup); 

  sf_old_geom = (struct IGRbsp_surface *) om$malloc ( size = sf_size);
  EMerr_hndlr (!sf_old_geom,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

  OM_stat = om$send ( msg = message GRvg.GRgetgeom(&mthd_stat,
                &md_env->md_env.matrix_type, md_env->md_env.matrix,
                 (IGRchar *) sf_old_geom),
            targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup); 

} /* if (lift_info->num_lps) */

{ /*INTENTIONAL BLOCK*/
  IGRboolean dont_have_it;

  OM_stat = EFwork_the_display(&mthd_stat, dis_options,
                               sf_GRid.objid,
                               display_ids, display_count,
                               &dont_have_it);
  if (!(1 & OM_stat & mthd_stat)) goto wrapup;

  if (dont_have_it)
  {
    /*
     * Erase, modify the surface
     */
    DisplayMode = GRbehe;
    OM_stat = om$send(msg = message GRgraphics.GRdisplay (&mthd_stat,
                            &md_env->md_env.matrix_type,
                            md_env->md_env.matrix, &DisplayMode,
                            &md_env->md_id),
                      targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
  }
}

OM_stat = om$send (msg = message EMSsubbs.EMexeinst (
                    &mthd_stat, me->lift_vector, md_env,
                     me->num_instructions, &sf_GRid.objid, me->move_info),
                   targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_SurfaceError, wrapup);

/*
 * If the lift operation is not EMS_LIFT_FACE and the
 * edges involved have common edges, some
 * ruled surfaces may be constructed or the boundary of
 * the ruled surface may be used to trim an existing surface.
 * In order to construct the ruled surface or trim an
 * existing surface , the modified geomtery of the surface is needed.
 */

if ( lift_operation != EMS_LIFT_FACE && lift_info->num_lps)
{
    sf_new_geom = (struct IGRbsp_surface *) om$malloc ( size = sf_size);
    EMerr_hndlr (!sf_new_geom,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

    OM_stat = om$send ( msg = message GRvg.GRgetgeom(&mthd_stat,
                &md_env->md_env.matrix_type, md_env->md_env.matrix,
                (IGRchar *) sf_new_geom),
            targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup); 

} /* if ( lift_operation != EMS_LIFT_FACE && lift_info->num_lps) */
 
/*
 * Construct new surfaces or trim existing surfaces and
 * reestablish topology if needed.
 */

if (lift_info->num_lps)
{
  /*
   * allocate space to save edges/old_new_cm_ed ids.
   * At the most there will be lift_info->num_eds
   * edges and there will be 4 objid entries per edge.
   */

  edv0v1_info.array_size = (lift_info->num_ed_infos) * 4;
  edv0v1_info.ed_ids = (GRobjid *) om$malloc (
             size = edv0v1_info.array_size * sizeof(GRobjid) );
  EMerr_hndlr (!edv0v1_info.ed_ids,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

  for (cur_lp = 0; cur_lp < lift_info->num_lps; cur_lp++)
  {
    cur_lp_info = &lift_info->lps_info[cur_lp];
    lp_ed_u0s.num_eds = 0;
    lp_ed_u1s.num_eds = 0;

    for (cur_sublp = 0; cur_sublp < cur_lp_info->num_sublps; cur_sublp++)
    {
      cur_sublp_info = &cur_lp_info->sublps_info[cur_sublp];
      
      for (cur_ed = 0; cur_ed < cur_sublp_info->num_edges; cur_ed++)
      {
        cur_ed_info = &cur_sublp_info->ed_info[cur_ed];
        ed_oldgm.poles = ed_oldgm.knots = ed_oldgm.weights = NULL;
        ed_newgm.poles = ed_newgm.knots = ed_newgm.weights = NULL;
        cm_ed_oldgm.poles = cm_ed_oldgm.knots = cm_ed_oldgm.weights =NULL;
        cm_ed_sfgm = NULL;
        work_ed++;

        /*
         * Based upon the constraint, create a new surface or
         * trim the common edge's surface.
         */

        cntinue = TRUE;
        ed_constraint = cur_ed_info->ed_constraint_type;
      
        /*
         * If the surface to be created is a EMS_C_RULED_SF,
         * the vector to be used for coincidence check is 
         * between mid points of
         * edge's old geometry and new geometry rather than
         * the lift_vector.
         */
              
        if (cur_ed_info->ed_sf_type == EMS_C_RULED_SF)
        {
          OM_stat = om$send(msg = message EMSedge.EMget_bcxyz_geom (
                             &mthd_stat, &md_env->md_env, 
                             &sf_GRid, sf_old_geom, NULL, MAXINT, 
                              FALSE, NULL, &ed_oldgm),
                            targetid = cur_ed_info->ed_GRid.objid);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

          OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom(
                                &mthd_stat, &md_env->md_env, &sf_GRid,
                                sf_new_geom, NULL, MAXINT, FALSE, 
                                NULL, &ed_newgm),
                              targetid = cur_ed_info->ed_GRid.objid);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

        } /* if (cur_ed_info->ed_sf_type == EMS_C_RULED_SF) */
    
        while(cntinue)
        {
          switch (ed_constraint)
          {
 
            /*
             * check if the surface to be constructed by the edge
             * is going to be coincident with the common edge's
             * surface. If so, trim the common edge's surface.
             * Otherwise, construct a new surface.
             */

            case EMS_LC_AUTO_COINCIDENCE:
           
              ex$message(msgnumb = EMS_I_CheckEdgeOverlap, var = `work_ed`, 
                         type = "%d")

              /*
               * If the surface to be created is a EMS_C_RULED_SF,
               * the vector to be used for coincidence check is 
               * between mid points of
               * edge's old geometry and new geometry rather than
               * the lift_vector.
               */
              
              if (cur_ed_info->ed_sf_type == EMS_C_RULED_SF)
              {
                BScveval (&ed_oldgm, 0.5, 0, from_pt, &rc);
                EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror,wrapup);

                BScveval (&ed_newgm, 0.5, 0, to_pt, &rc);
                EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror,wrapup);

                for (i = 0; i < 3; i++)
                  move_vec[i] = to_pt[i] - from_pt[i];

              } /* if (cur_ed_info->ed_sf_type == EMS_C_RULED_SF) */
                             
              EFdoes_new_sf_overlaps_cm_ed_sf (&rc, cur_ed_info->ed_GRid,
                   (cur_ed_info->ed_sf_type == EMS_C_RULED_SF ? 
                    move_vec : me->lift_vector), 
                    md_env, &overlap_exists, 
                   &cm_ed_GRid, &cm_ed_sf_GRid, &cm_ed_sfgm, 
                   &cm_ed_oldgm);
              EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

              if (overlap_exists)
              {
	         ex$message(msgnumb = EMS_I_EdgeTrimAdjSf, var = `work_ed`, 
	                    type = "%d")

                 cntinue = FALSE;
                 ad_sf_trimmed = TRUE;
                 EFtrim_cm_ed_sf1 (&rc, cur_ed_info, NULL,  
                     cur_ed_info->ed_GRid, sf_GRid, sf_GRid,
                     sf_new_geom, 
                     (cur_ed_info->ed_sf_type == EMS_C_RULED_SF ?
                      &ed_newgm : NULL),
                     me->lift_vector, cm_ed_GRid,  
                     cm_ed_sf_GRid, cm_ed_sfgm, &cm_ed_oldgm, md_env, 
                     &ed_u0s, &ed_u1s, &last_ed_u1s, 
                      ( (cur_ed == cur_sublp_info->num_edges - 1)  &&
                        (cur_sublp == cur_lp_info->num_sublps - 1))?
                        &lp_ed_u0s : NULL,
                     &edv0v1_info, 
                     &ed_sp_info, &lps_mod_info, &ed_cn_info,
                     &sfrmvd_info,
                     dis_options, display_ids, display_count);

                 EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

              } /* if (overlap_exists) */

              else
                 ed_constraint = NULL;

              break;

            /*
             * If there are no constraints applied on the edge or
             * if the check for the auto coincidence was requested
             * but it does not result in overlapping conditions, 
             * create a lifted surface.
             */

            default:

              ex$message(msgnumb = EMS_I_EdgeCreateSfToFillGap, var =`work_ed`,
                         type = "%d" )

               cntinue = FALSE;
               EFcreate_lft_sf1 (&rc, cur_ed_info, NULL, 
                     cur_ed_info->ed_GRid, my_GRid, 
                     (cur_ed_info->ed_sf_type == EMS_C_RULED_SF ?
                      &ed_oldgm : NULL), 
                     (cur_ed_info->ed_sf_type == EMS_C_RULED_SF ?
                      &ed_newgm : NULL), 
                     sf_old_geom, 
                     sf_new_geom, me->lift_vector, md_env, 
                     construct_list, &edv0v1_info, &ed_u0s, &ed_u1s,
                     dis_options, display_ids, display_count, MAXINT);
               EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
              
          } /* switch (ed_constraint) */

        } /* while(cntinue) */

        /*
         * Now a new surface has been constructed or the 
         * common edge's surface has been trimmed. Next
         * job is to establish topology between ed_u0s
         * of the current edge's sf/cm_ed_trimmed_sf and
         * ed_u1s corresponding the last edge.
         */

        /*
         * The ed_u0s of the first edge may match with ed_u1s 
         * of the last edge of the loop. Therfore save them.
         */

        if (!cur_ed && !cur_sublp && cur_lp_info->match_end_pts_eds &&
            ed_u0s.num_eds )
        {
            EFsave_edges_for_edge_matching (&rc, &ed_u0s, &lp_ed_u0s);
            EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

        } /* if (!cur_ed && !cur_sublp && cur_lp_info->match_end_pts_eds 
                 && ed_u0s.num_eds ) */

        if ( (cur_ed == cur_sublp_info->num_edges-1)   && 
             (cur_sublp == cur_lp_info->num_sublps-1)  &&
              cur_lp_info->match_end_pts_eds           &&
              lp_ed_u0s.num_eds && ed_u1s.num_eds )
        {
            EFsave_edges_for_edge_matching (&rc, &ed_u1s, &lp_ed_u1s);
            EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
 
        } /* if ( (cur_ed == cur_sublp_info->num_edges-1)   && 
             (cur_sublp == cur_lp_info->num_sublps-1)  &&
              cur_lp_info->match_end_pts_eds           &&
              lp_ed_u0s.num_eds && ed_u1s.num_eds ) */
 
        /*
         * If the edge is not the first edge of the loop
         * perform edge matching between last_ed_u1s and
         * current ed_u0s.
         */
       
        if (cur_ed && last_ed_u1s.num_eds && ed_u0s.num_eds)
        {
          EFed_match (&rc, &last_ed_u1s, &ed_u0s, OM_Gw_current_OS, 
                       md_env, &ed_cn_info);
          EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

        } /* if (!cur_ed && last_ed_u1s.num_eds && ed_u0s) */
  
        /*
         * If the edge is not the last edge of the current 
         * subloop, save its ed_u1s
         * as last_ed_u1s. As they will be used to perform
         * edge matching with ed_u0s of the next edge of the 
         * subloop. 
         */

        if ( cur_ed != cur_sublp_info->num_edges-1 && ed_u1s.num_eds)
        {
           EFsave_edges_for_edge_matching (&rc, &ed_u1s, &last_ed_u1s);
           EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

        } /* if(cur_ed !=cur_sublp_info->num_edges-1 && ed_u1s.num_eds)*/
        else
          last_ed_u1s.num_eds = 0;

        ed_u0s.num_eds = 0;
        ed_u1s.num_eds = 0;

        if (ed_oldgm.poles) om$dealloc(ptr=ed_oldgm.poles);
        if (ed_oldgm.knots) om$dealloc(ptr=ed_oldgm.knots);
        if (ed_oldgm.weights) om$dealloc(ptr=ed_oldgm.weights);
        if (ed_newgm.poles) om$dealloc(ptr=ed_newgm.poles);
        if (ed_newgm.knots) om$dealloc(ptr=ed_newgm.knots);
        if (ed_newgm.weights) om$dealloc(ptr=ed_newgm.weights);
        if (cm_ed_oldgm.poles) om$dealloc(ptr=cm_ed_oldgm.poles);
        if (cm_ed_oldgm.knots) om$dealloc(ptr=cm_ed_oldgm.knots);
        if (cm_ed_oldgm.weights) om$dealloc(ptr=cm_ed_oldgm.weights);
        if (cm_ed_sfgm)  om$dealloc (ptr = cm_ed_sfgm);

      } /* for (cur_ed = 0; cur_ed < cur_sublp_info->num_edges;cur_ed++)*/

    }/* for (cur_sublp = 0; cur_sublp < cur_lp_info->num_sublps; 
             cur_sublp++) */

    /*
     * For each loop, perform edge matching between
     * lp_edu0 and lp_edu1 if both have any edges.
     */

    if (lp_ed_u0s.num_eds && lp_ed_u1s.num_eds )
    {
       EFed_match (&rc, &lp_ed_u0s, &lp_ed_u1s, OM_Gw_current_OS, md_env, 
                   &ed_cn_info);
       EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

    } /* if (lp_edu0.num_eds && lp_edu1.num_eds) */

  } /* for (cur_lp = 0; cur_lp < lift_info->num_lps; cur_lps++) */
 
} /* if (lift_info->num_lps) */

/*
 * Redisplay the modified surface and the newly created surfaces
 * if any of the surfaces are trimmed.
 */

if (dis_options & EMS_DO_DISPLAY)
{
  if (!(dis_options & EMS_DONT_REDRAW))
  {
    DisplayMode = GRbd;
    OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                        &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, &DisplayMode,
                        &md_env->md_id),
                       targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
  }

  if (ad_sf_trimmed)
  {
    OMuint  ii, c_cnt;
    GRobjid surf_id;
    OMuword dumosnum;
    extern OMuword OPP_EMSsubbs_class_id;


    to_comps_chan.type = OM_e_addr;
    to_comps_chan.u_sel.addr = &ME.GRcmpowner->to_components;
 
    if (dis_options & EMS_DONT_REDRAW)
    {
      OM_stat = om$get_channel_count(object = me,
                                     p_chanselect = &to_comps_chan,
                                     count = &c_cnt);
      if (!(1 & OM_stat)) goto wrapup;

      for(ii=0; ii<c_cnt; ii++)
      {
        OM_stat = om$get_objid_at_index(object = me,
                                        p_chanselect = &to_comps_chan,
                                        index = ii,
                                        objidaddr = &surf_id,
                                        osnumaddr = &dumosnum);
        if (!(1 & OM_stat)) goto wrapup;
   
        if ((IGRboolean)EFisAncestryValid(&mthd_stat, surf_id,
                                          OM_Gw_current_OS, 
                                          OPP_EMSsubbs_class_id, FALSE))
        { 
          OM_stat = EFwork_the_display(&mthd_stat, dis_options,
                                       surf_id, display_ids,
                                       display_count, NULL);
          if (!(1 & OM_stat & mthd_stat)) goto wrapup;
        }
      }
    }
    else
    {
      OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                                &md_env->md_env.matrix_type,
                                md_env->md_env.matrix, &DisplayMode,
                                &md_env->md_id),
                         p_chanselect = &to_comps_chan);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
    }
  } /* if (ad_sf_trimmed) */
}

/*
 * It may be possible that some of the edges of the loops taken out
 * or the surfaces taken out are inactive and are still connected
 * active common edges. This will prevent the active common edges from
 * being able to connect to another edge though it should be allowed
 * to. Thus in such a situation, replace the active common edges
 * with their compressed copied in their respective loops. Also,
 * save the replacement information in ed_sp_info.
 *
 * The above mentioned situation exists if the object being worked upon
 * is not a solid. In case of a solid, the above situation can
 * not arise as it will create hole regions and thus violates it
 * closeness property.
 */

OM_stat = om$get_classid (object = me, p_classid = &my_classid);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = om$is_ancestry_valid (subclassid = my_classid, 
                                superclassid = OPP_EMSsolid_class_id);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

if (OM_stat != OM_S_SUCCESS)
{
  EFrmv_inacteds_actcm_eds (&rc, md_env, OM_Gw_current_OS, &sfrmvd_info, 
                            &lps_mod_info, &ed_sp_info);
  EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

} /* if (OM_stat != OM_S_SUCCESS) */

/*
 * Processing is finished. Time to save the information
 * save state purposes.
 * The save state information comprises of:
 *
 * 1. Num of surfaces affected. Num of loops in/out per sf.
 * 2. Num edges affected. Num of edges replaced per edge and their
 *    ids.
 * 3. Num of edges whose common edges moved and their ids.
 * 4. Num of edges whose common edges are replaced by other edges.
 *    and their ids.
 */

 my_info = &ssi_table.lft_info;

 my_info->num_composites = sfrmvd_info.num_compsf;
 my_info->composite_ids = sfrmvd_info.compsf_ids;
 my_info->num_surfaces_out = sfrmvd_info.num_sf_prcompsf;
 my_info->surface_out_ids = sfrmvd_info.sf_ids;
 my_info->composite_indices = sfrmvd_info.sf_idx;

 my_info->num_sf_lifted = 1;
 my_info->sf_lifted_ids = &sf_GRid.objid;
 my_info->num_sf_affected = lps_mod_info.num_sfs;
 my_info->sf_affctd_ids = lps_mod_info.sf_ids;
 my_info->num_regions_in = lps_mod_info.lps_added_prsf;
 my_info->region_in_ids = lps_mod_info.lp_added_ids;
 my_info->num_regions_out = lps_mod_info.lps_rmvd_prsf;
 my_info->region_out_ids = lps_mod_info.lp_rmvd_ids;
 my_info->num_eds_rplcd = ed_sp_info.num_eds;
 my_info->ed_rplcd_ids = ed_sp_info.ed_ids;
 my_info->num_eds_in = ed_sp_info.sp_eds_pred;
 my_info->ed_in_ids = ed_sp_info.sp_eds;
 my_info->num_eds_wcm_md = edv0v1_info.num_eds;
 my_info->ed_mcm_ed_ids = edv0v1_info.ed_ids;
 my_info->num_ed_wmv_cm = ed_cn_info.num_eds;
 my_info->ed_ced_ids = ed_cn_info.ed_ids;
 my_info->num_eds_wcm_eds = 0;
 my_info->ed_cm_ed_ids = NULL;

 OM_stat = om$send (msg = message EMSdpr.EMputSSI( &mthd_stat, 
                     &ssi_table), targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

wrapup:

ex$message(msgnumb = EMS_I_ClearStatusField)
if (edv0v1_info.ed_ids) om$dealloc (ptr = edv0v1_info.ed_ids);

if (ed_u0s.ed_ids) om$dealloc (ptr = ed_u0s.ed_ids);
if (ed_u0s.sf_ids) om$dealloc (ptr = ed_u0s.sf_ids);

if (ed_u1s.ed_ids) om$dealloc (ptr = ed_u1s.ed_ids);
if (ed_u1s.sf_ids) om$dealloc (ptr = ed_u1s.sf_ids);

if (last_ed_u1s.ed_ids) om$dealloc (ptr = last_ed_u1s.ed_ids);
if (last_ed_u1s.sf_ids) om$dealloc (ptr = last_ed_u1s.sf_ids);

if (lp_ed_u0s.ed_ids) om$dealloc (ptr = lp_ed_u0s.ed_ids);
if (lp_ed_u0s.sf_ids) om$dealloc (ptr = lp_ed_u0s.sf_ids);

if (lp_ed_u1s.ed_ids) om$dealloc (ptr = lp_ed_u1s.ed_ids);
if (lp_ed_u1s.sf_ids) om$dealloc (ptr = lp_ed_u1s.sf_ids);

if (ed_cn_info.ed_ids) om$dealloc (ptr = ed_cn_info.ed_ids);

if (ed_sp_info.ed_ids) om$dealloc (ptr = ed_sp_info.ed_ids);
if (ed_sp_info.sp_eds) om$dealloc (ptr = ed_sp_info.sp_eds);
if (ed_sp_info.sp_eds_pred) om$dealloc (ptr = ed_sp_info.sp_eds_pred);

if (lps_mod_info.sf_ids) om$dealloc( ptr = lps_mod_info.sf_ids); 
if (lps_mod_info.lp_added_ids) 
                  om$dealloc( ptr = lps_mod_info.lp_added_ids);
if (lps_mod_info.lp_rmvd_ids) 
                  om$dealloc( ptr = lps_mod_info.lp_rmvd_ids);
if (lps_mod_info.lps_added_prsf) 
                  om$dealloc( ptr = lps_mod_info.lps_added_prsf);
if (lps_mod_info.lps_rmvd_prsf) 
                  om$dealloc( ptr = lps_mod_info.lps_rmvd_prsf);

if (sfrmvd_info.compsf_ids )
                  om$dealloc (ptr = sfrmvd_info.compsf_ids);
if (sfrmvd_info.sf_ids )
                  om$dealloc (ptr = sfrmvd_info.sf_ids);
if (sfrmvd_info.num_sf_prcompsf)
                  om$dealloc (ptr = sfrmvd_info.num_sf_prcompsf);
if (sfrmvd_info.sf_idx)
                  om$dealloc (ptr = sfrmvd_info.sf_idx);

if (sf_old_geom) om$dealloc (ptr = sf_old_geom);
if (sf_new_geom) om$dealloc (ptr = sf_new_geom);

EMWRAPUP(*EMmsg, OM_stat, "In EMSsf_lift. EMlift_execute");

return (OM_stat);

}


end implementation EMSsf_lift;
