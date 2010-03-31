class  implementation EMSsfaddraft;

#include "EMS.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_S.h"
#include "msmacros.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "emsgeteddef.h"
#include "EMSbnddef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "ECcmd.h"
#include "ECmsg.h" 
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include  "bsvalues.h"
#include  <math.h>
#include "emsaddraft.h"
#include "EMSssprops.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define SURFACES_AND_EDGES_OR_CVS_OR_SURFS 0
#define PLANE_AND_SURFACES 1 
#define REPLACE_SURFACE  2

/**** STAGES OF SUCCESS ********/
#define DRAFT_SFS_CREATION_START 1
#define DRAFT_SFS_CREATION_END 2
#define AFFECT_SFS_COPY 3
#define DISCONN_OLD_COMMEDGES 4
#define DISPLAY_OLD_NEW_SFS 5
#define CONN_NEW_COMMEDGES 6
#define DISCONN_OLD_SFS 7
#define CONN_NEW_SFS 8
#define CONN_NEW_SFS_END 9


extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSplane_class_id;

from EMSgenbs  import EMdrafted_surface;
from EMSedge import EMget_sf_edges, EMget_bcxyz_geom, EMxyz_endpt;
from EMSloop import EMget_props, EMnext_edge;
from EMSedge import  EMconnect_edges, EMgetsurface_info, EMget_props, EMstitch;
from EMSedge import  EMset_props;
from EMSloopset import  EMpt_location, EMget_loops;
from EMSsubbs import  EMset_props, EMgetbsdef;

method   EMadd_draft(IGRlong *EMmsg;
                      struct GRmd_env *md_env;
                      IGRint num_draft_surfs;
                      IGRint draft_type;
                      GRobjid *replace_surfs;
                      struct GRid *surfs; /*surf to be drafted */
                      GRobjid *hinges; /** in general for:
                                  planes, hinge_edges, hinge_curve_geoms, ****/
                      IGRboolean ang_rev;
                      IGRdouble draft_angles;
                      struct GRvg_construct *const_list)

        {
        IGRlong  msg_loc = EMS_S_Success, stat_OM = OM_S_SUCCESS, rc;
        enum GRdpmode dpmode;
        IGRushort ed_props , e_props, partner_props;
        OMuint  has_commedge, has_owner, surf_index;
        OM_S_OBJECT_LINKAGE owner_link;
        OM_S_CHANSELECT chan_to_comps, to_common, to_owners, to_comps;
        IGRlong ownersIndex;
        struct GRid  obj, my_GRid, owner_id;
        IGRint num_affect_sfs=0;
        IGRint num_affect_lps=0;
        IGRint index=0, ii,kk, jj, ZZZ, inx=0;
        IGRint num_commedges_connected=0,
               num_commedges_disconnected=0;
        OMuint  count;
        struct EMSadj_surf_info  *info_link_list = NULL ,
                                 *info_link_list_loc=NULL,
                                 **adj_sfs_info_list = NULL,
                                 **adj_sf_info_list = NULL,
                                 **cp_sf_info_list = NULL,
                                 **cp_sfs_info_list = NULL;
        union EMSssiSizeData size_data;
        union EMSssi_table *ssibuff = NULL;
        struct EMSaddraftssi_table *myssiinfo = NULL;
        GRobjid the_loop,connect_object, prev_sf;
        GRobjid  *loc_new_commedge_pairs1=NULL, 
                 *loc_new_commedge_pairs2 = NULL,
                 *loc_old_commedge_pairs1=NULL,
                 *loc_old_commedge_pairs2=NULL,
                 *composite_ids=NULL,
                 **affect_surf_matrix=NULL;
        IGRboolean no_error=FALSE, recover=FALSE, composite_id_found=TRUE;
        IGRint num_composites=0;
        IGRint total_loops=0;
        IGRushort option, options=NULL;
        IGRint SUCC_UNTIL;
        struct  GRid active_solid;
        IGRdouble min_angle=0.0, cht_tol;
        GRobjid cancer = NULL_OBJID;
        

      BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);
     
      msg_loc = OM_S_SUCCESS;
      stat_OM = EMS_S_Success;
      SUCC_UNTIL=0;

      ex$message(msgnumb = EMS_I_Processing);

      stat_OM = EMmake_chanselect(EMSedge_to_common_edge, &to_common);
      stat_OM = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
      stat_OM = EMmake_chanselect(GRconnector_to_owners, &to_owners);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *EMmsg, EMS_E_Fail, ret_end);

      stat_OM = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                        &active_solid, NULL),
                senderid = NULL_OBJID,
                targetid = surfs[0].objid,
                targetos = surfs[0].osnum);
        EMerr_hndlr(!(1&stat_OM&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

        the_loop = NULL_OBJID;
        EMget_adj_sfs( &msg_loc,
                       md_env,
                       num_draft_surfs,
                       &surfs[0],
                       &the_loop,
                       TRUE, 
                       NULL,
                       &num_affect_lps,
                       &num_affect_sfs,
                       &info_link_list,
                       min_angle,
                       2);
        EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

        adj_sfs_info_list = (struct EMSadj_surf_info **)om$malloc(
                   size = num_affect_lps*sizeof(struct EMSadj_surf_info *));
        EMerr_hndlr (!adj_sfs_info_list,*EMmsg, EMS_E_NoDynamicMemory,wrapup);

        adj_sf_info_list = (struct EMSadj_surf_info **)om$malloc(
                   size = num_affect_sfs*sizeof(struct EMSadj_surf_info *));
        EMerr_hndlr (!adj_sf_info_list,*EMmsg, EMS_E_NoDynamicMemory,wrapup);

        index=0;
        prev_sf = info_link_list->myself.objid;
        adj_sf_info_list[0] = info_link_list;
        info_link_list_loc = info_link_list;
        for(ZZZ=0; ZZZ<num_affect_lps; ZZZ++)
           {
           adj_sfs_info_list[ZZZ] = info_link_list_loc;
           info_link_list_loc = info_link_list_loc->next;
           if(adj_sfs_info_list[ZZZ]->myself.objid != prev_sf)
              {
              prev_sf = adj_sfs_info_list[ZZZ]->myself.objid;
              adj_sf_info_list[++index] = adj_sfs_info_list[ZZZ];
              }
            }
        num_affect_sfs = index+1;

        EMmark_adj_surfs(&msg_loc,
                         md_env,
                         const_list,
                         hinges,
                         &num_affect_lps,
                         &adj_sfs_info_list, 
                         &min_angle);
        EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

       SUCC_UNTIL = AFFECT_SFS_COPY;

       EMcopy_adj_surfs(&msg_loc,
                         md_env,
                         const_list,
                           num_draft_surfs,
                           surfs,
                           replace_surfs,
                           hinges,
                           draft_type,
                           ang_rev,
                         &num_affect_lps,
                         draft_angles, min_angle,
                         &adj_sfs_info_list,
                         &cp_sfs_info_list);
        EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

        cp_sf_info_list = (struct EMSadj_surf_info **)om$malloc(
                   size = num_affect_sfs*sizeof(struct EMSadj_surf_info *));
        EMerr_hndlr (!cp_sf_info_list,*EMmsg, EMS_E_NoDynamicMemory,wrapup);

        index=0;
        prev_sf = cp_sfs_info_list[0]->myself.objid;
        cp_sf_info_list[0] = cp_sfs_info_list[0];
        for(ZZZ=0; ZZZ<num_affect_lps; ZZZ++)
           {
           if(cp_sfs_info_list[ZZZ]->myself.objid != prev_sf)
              {
              prev_sf = cp_sfs_info_list[ZZZ]->myself.objid;
              cp_sf_info_list[++index] = cp_sfs_info_list[ZZZ];
              }
            }
           if(index+1 != num_affect_sfs)
             printf("ERROR ERROR ERROR ERROR ERROR\n");

        EMint_adj_surfs(&msg_loc,
                         md_env,
                         const_list,
                         &num_affect_lps,
                         adj_sfs_info_list,
                         &cp_sfs_info_list);
        EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
        EMtrim_adj_surfs(&msg_loc,
                         md_env,
                         const_list,
                         &num_affect_lps,
                         &adj_sfs_info_list,
                         &cp_sfs_info_list);
        EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

        EMput_range_adj_sfs(&msg_loc,
                         md_env,
                         &num_affect_lps,
                         adj_sfs_info_list,
                         cp_sfs_info_list);
        EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

/*************************************************************************/
/***************** MODEL MODIFICATION BEGINS *****************************/
/*************************************************************************/
         
      SUCC_UNTIL = DISCONN_OLD_COMMEDGES;

     inx=0;
     num_commedges_disconnected=0;
     for(ii=0;ii<num_affect_lps;ii++)
        {
        for(jj=0; jj<adj_sfs_info_list[ii]->num_adjacent; jj++)
            {
            e_props = NULL;
            if(adj_sfs_info_list[ii]->edges && adj_sfs_info_list[ii]->commedges)
                 if(adj_sfs_info_list[ii]->edges[jj] != NULL_OBJID  &&
                          adj_sfs_info_list[ii]->commedges[jj] != NULL_OBJID)
               {
                stat_OM = om$get_channel_count(
                                 objid = adj_sfs_info_list[ii]->edges[jj],
                                 osnum = adj_sfs_info_list[ii]->myself.osnum,
                                 p_chanselect = &to_common,
                                 count = &has_commedge);
                 if(has_commedge)
                    {
                     stat_OM = om$send( msg = message Root.disconnect
                          (to_common,
                          adj_sfs_info_list[ii]->commedges[jj],
                          OM_Gw_current_OS,
                          to_common),
                     targetid = adj_sfs_info_list[ii]->edges[jj]);

                      if(inx==0)
                        {
                        loc_old_commedge_pairs1 = (GRobjid *)
                              om$malloc(size = 10 * sizeof(GRobjid));
                        EMerr_hndlr (!(loc_old_commedge_pairs1),*EMmsg,
                                       EMS_E_NoDynamicMemory,wrapup);
                        loc_old_commedge_pairs2 = (GRobjid *)
                              om$malloc(size = 10 * sizeof(GRobjid));
                        EMerr_hndlr (!(loc_old_commedge_pairs2),*EMmsg,
                                       EMS_E_NoDynamicMemory,wrapup);
                        }
                      else if(inx>9)
                        {
                        loc_old_commedge_pairs1 = (GRobjid *)
                              om$realloc(ptr = (char *)loc_old_commedge_pairs1,
                                         size = (inx+1) * sizeof(GRobjid));
                        EMerr_hndlr (!(loc_old_commedge_pairs1),*EMmsg,
                                       EMS_E_NoDynamicMemory,wrapup);
                        loc_old_commedge_pairs2 = (GRobjid *)
                              om$realloc(ptr = (char *)loc_old_commedge_pairs2,
                                         size = (inx+1) * sizeof(GRobjid));
                        EMerr_hndlr (!(loc_old_commedge_pairs2),*EMmsg,
                                       EMS_E_NoDynamicMemory,wrapup);
                        }

                      loc_old_commedge_pairs1[inx] = 
                           adj_sfs_info_list[ii]->edges[jj]; 
                      loc_old_commedge_pairs2[inx] = 
                            adj_sfs_info_list[ii]->commedges[jj]; 
                      inx++;
                      num_commedges_disconnected++;
                      }
                 }
            }
        }
        me->num_old_commedge_pairs =  num_commedges_disconnected;

      SUCC_UNTIL = DISPLAY_OLD_NEW_SFS;

   // intentional block
   {
        IGRboolean aflag;
        struct GRmd_env display_env;
        gr$get_module_env(buffer = &display_env);
        aflag = pwIsActivationOn();

     for(ii=0;ii<num_affect_sfs;ii++)
      {
       if(aflag)
       {
        dpmode = GRbehe;
        stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message GRgraphics.GRdisplay (&msg_loc,
                         &display_env.md_env.matrix_type,
                         display_env.md_env.matrix,
                         &dpmode, &display_env.md_id),
                      targetid = adj_sf_info_list[ii]->myself.objid,
                      targetos = adj_sf_info_list[ii]->myself.osnum);
        EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
        stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message EMSsubbs.EMset_props (&msg_loc,
                              EMSIS_INACTIVE, EMS_O_ON),
                      targetid = adj_sf_info_list[ii]->myself.objid,
                      targetos = adj_sf_info_list[ii]->myself.osnum);
        EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

        dpmode = GRbd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message GRgraphics.GRdisplay (&msg_loc,
                         &display_env.md_env.matrix_type,
                         display_env.md_env.matrix,
                         &dpmode, &display_env.md_id),
                      targetid = cp_sf_info_list[ii]->myself.objid,
                      targetos = cp_sf_info_list[ii]->myself.osnum);
        EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
       }
       else
       {
        dpmode = GRbehe;
        stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message GRgraphics.GRdisplay (&msg_loc,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix,
                         &dpmode, &md_env->md_id),
                      targetid = adj_sf_info_list[ii]->myself.objid,
                      targetos = adj_sf_info_list[ii]->myself.osnum);
        EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
        stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message EMSsubbs.EMset_props (&msg_loc,
                              EMSIS_INACTIVE, EMS_O_ON),
                      targetid = adj_sf_info_list[ii]->myself.objid,
                      targetos = adj_sf_info_list[ii]->myself.osnum);
        EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

        dpmode = GRbd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message GRgraphics.GRdisplay (&msg_loc,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix,
                         &dpmode, &md_env->md_id),
                      targetid = cp_sf_info_list[ii]->myself.objid,
                      targetos = cp_sf_info_list[ii]->myself.osnum);
        EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
       }
      }
    }
      SUCC_UNTIL = CONN_NEW_COMMEDGES;
     inx=0;
     num_commedges_connected=0;
     for(ii=0;ii<num_affect_lps;ii++)
        {
        for(jj=0; jj<cp_sfs_info_list[ii]->num_adjacent; jj++)
            {
            if(cp_sfs_info_list[ii]->edges && cp_sfs_info_list[ii]->commedges)
                 if(cp_sfs_info_list[ii]->edges[jj] != NULL_OBJID  &&
                          cp_sfs_info_list[ii]->commedges[jj] != NULL_OBJID)
               {
                stat_OM = om$get_channel_count(
                                 objid = cp_sfs_info_list[ii]->edges[jj],
                                 osnum = cp_sfs_info_list[ii]->myself.osnum,
                                 p_chanselect = &to_common,
                                 count = &has_commedge);
                 if(!has_commedge)
                    {
                   e_props = NULL;
 

                   stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message EMSedge.EMget_props (&msg_loc, &e_props),
                    targetid = cp_sfs_info_list[ii]->commedges[jj],
                    targetos = cp_sfs_info_list[ii]->myself.osnum);
                 EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

                 partner_props = e_props;

                   stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message EMSedge.EMconnect_edges (&msg_loc, 
                          e_props,
                          TRUE,
                          cp_sfs_info_list[ii]->edges[jj],
                          NULL_OBJID, NULL_OBJID,
                          &md_env->md_env),
                    targetid = cp_sfs_info_list[ii]->commedges[jj],
                    targetos = cp_sfs_info_list[ii]->myself.osnum);
                 EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

                   options = e_props&EMED_SUBORDINATE ? EMS_O_ON : EMS_O_OFF;
                   e_props = EMED_SUBORDINATE;
                   stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message EMSedge.EMset_props (&msg_loc, e_props,
                         options),
                    targetid = cp_sfs_info_list[ii]->commedges[jj],
                    targetos = cp_sfs_info_list[ii]->myself.osnum);
                 EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

                   options = options&EMS_O_ON ? EMS_O_OFF : EMS_O_ON;
                   e_props = EMED_SUBORDINATE;
                   stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message EMSedge.EMset_props (&msg_loc, e_props,
                         options),
                    targetid = cp_sfs_info_list[ii]->edges[jj],
                    targetos = cp_sfs_info_list[ii]->myself.osnum);
                 EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);


    {
      struct IGRbsp_curve	my_geom, partner_geom, *cv;
      struct IGRbsp_surface     *surf_geom;
      IGRdouble			sti_tol;
      IGRint			sample_size, num_misses, num_hits, i;
      IGRdouble			bsovlap0[2], bsovlap1[2];

          surf_geom=NULL;
          my_geom.poles = NULL;
          my_geom.knots = NULL;
          my_geom.weights = NULL;
          my_geom.bdrys = NULL;

          stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message EMSedge.EMget_props (&msg_loc, &ed_props),
                    targetid = cp_sfs_info_list[ii]->edges[jj],
                    targetos = cp_sfs_info_list[ii]->myself.osnum);
          EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

          stat_OM = om$send(mode = OM_e_wrt_object,
                msg = message EMSedge.EMget_bcxyz_geom (&msg_loc,
		   	 &md_env->md_env,  &cp_sfs_info_list[ii]->myself, NULL, 
		         0, MAXINT, ed_props & EMED_REVERSED ? TRUE : FALSE,
				 NULL, &my_geom),   
                    targetid = cp_sfs_info_list[ii]->edges[jj],
                    targetos = cp_sfs_info_list[ii]->myself.osnum);
          EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

          partner_geom.poles = NULL;
          partner_geom.knots = NULL;
          partner_geom.weights = NULL;
          partner_geom.bdrys = NULL;
          obj.objid = cp_sfs_info_list[ii]->adj_surfs[jj];
          obj.osnum = cp_sfs_info_list[ii]->myself.osnum;
          stat_OM = om$send(mode = OM_e_wrt_object,
              msg = message EMSedge.EMget_bcxyz_geom (&msg_loc,
		   	 &md_env->md_env, &obj, NULL, 0, MAXINT,
			partner_props & EMED_REVERSED ? TRUE : FALSE,
				 NULL, &partner_geom),   
                    targetid = cp_sfs_info_list[ii]->commedges[jj],
                    targetos = cp_sfs_info_list[ii]->myself.osnum);
           EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

           bsovlap0[0] = bsovlap1[0] = 0;
           bsovlap0[1] = bsovlap1[1] = 1;
           sample_size = 4;
           sti_tol = 2*cht_tol;

            stat_OM = EMvalcv_ovlap(&msg_loc, &my_geom, &partner_geom,
               bsovlap0, bsovlap1, sample_size, &num_hits, &num_misses, sti_tol,
			 NULL, NULL, NULL);
            EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
            if (num_misses > num_hits)
             {
             EMerr_hndlr(TRUE, *EMmsg, EMS_E_Fail, wrapup);
              }

            for(i=0; i<2; i++)
            {
             cv = i ? &my_geom : &partner_geom;
             if(cv->poles) om$dealloc(ptr = cv->poles);
             if(cv->knots) om$dealloc(ptr = cv->knots);
             if(cv->weights && cv->rational) om$dealloc(ptr = cv->weights);
            }
        }

/**********

               cancer=NULL_OBJID;
               option=NULL;
               option |= EMSvalidateEdgeMatch;

              EMisedvalid(&msg_loc,
                         md_env, NULL, &cancer,
                         &option, cp_sf_info_list[ii]->edges[jj], ed_props,
                         cp_sf_info_list[ii]->commedges[jj], partner_props),
              EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

              if(msg_loc == EMS_I_EdgeError || cancer!=NULL_OBJID)
                  EMerr_hndlr(TRUE, *EMmsg, EMS_E_Fail, wrapup);
**********/

        if(inx==0)
          {
           loc_new_commedge_pairs1 = (GRobjid *)
                    om$malloc(size = 10 * sizeof(GRobjid));
           EMerr_hndlr (!(loc_new_commedge_pairs1),*EMmsg,
                                       EMS_E_NoDynamicMemory,wrapup);
           loc_new_commedge_pairs2 = (GRobjid *)
                              om$malloc(size = 10 * sizeof(GRobjid));
           EMerr_hndlr (!(loc_new_commedge_pairs2),*EMmsg,
                                       EMS_E_NoDynamicMemory,wrapup);
           }
        else if(inx>9)
           {
           loc_new_commedge_pairs1 = (GRobjid *)
                      om$realloc(ptr = (char *)loc_new_commedge_pairs1,
                                         size = (inx+1) * sizeof(GRobjid));
           EMerr_hndlr (!(loc_new_commedge_pairs1),*EMmsg,
                                       EMS_E_NoDynamicMemory,wrapup);
           loc_new_commedge_pairs2 = (GRobjid *)
                              om$realloc(ptr = (char *)loc_new_commedge_pairs2,
                                         size = (inx+1) * sizeof(GRobjid));
           EMerr_hndlr (!(loc_new_commedge_pairs2),*EMmsg,
                                       EMS_E_NoDynamicMemory,wrapup);
           }

        loc_new_commedge_pairs1[inx] = 
                          cp_sfs_info_list[ii]->edges[jj]; 
        loc_new_commedge_pairs2[inx] = 
                         cp_sfs_info_list[ii]->commedges[jj]; 
        inx++;
        num_commedges_connected++;
                   
        }
       }
      }
     }
    me->num_new_commedge_pairs =  num_commedges_connected;



    /*********************************************************************/
    /***************** processing SSI Info *******************************/
    /*********************************************************************/

   num_composites = 0;
   composite_ids =(GRobjid *)om$malloc(size=(1+num_affect_sfs)*sizeof(GRobjid));
   EMerr_hndlr (!composite_ids,*EMmsg, EMS_E_NoDynamicMemory,wrapup);
   affect_surf_matrix = (GRobjid **)om$malloc(size = 2*sizeof(GRobjid *));
   EMerr_hndlr (!affect_surf_matrix,*EMmsg, EMS_E_NoDynamicMemory,wrapup);
         affect_surf_matrix[0] = affect_surf_matrix[1] = NULL;
     for(ii=0;ii<2;ii++)
       {
        affect_surf_matrix[ii] = 
           (GRobjid *)om$malloc(size = (1+num_affect_sfs) * sizeof(GRobjid));
     EMerr_hndlr (!affect_surf_matrix[ii],*EMmsg, EMS_E_NoDynamicMemory,wrapup);
        for(kk=0;kk<num_affect_sfs+1; kk++)
           affect_surf_matrix [ii][kk] = NULL_OBJID;
      }
     for(ii=0;ii<num_affect_sfs+1;ii++)
        composite_ids[ii] = NULL_OBJID;

     for(ii=0;ii<num_affect_sfs;ii++)
       {
       stat_OM = om$get_channel_objects
                    (objid = adj_sf_info_list[ii]->myself.objid,
                     osnum = adj_sf_info_list[ii]->myself.osnum,
                     p_chanselect = &to_owners,
                     size = 1,
                     list = &owner_link,
                     count = &has_owner);
        

       composite_id_found=TRUE;
       for(jj=0; jj<=num_composites; jj++)
         if(owner_link.S_objid == composite_ids[jj])
             {
              for(kk=0;kk<num_affect_sfs;kk++)
                if(affect_surf_matrix [jj][kk] == NULL_OBJID)
                   break;
                else if(affect_surf_matrix [jj][kk] ==
                                        adj_sf_info_list[ii]->myself.objid)
                   break;
             affect_surf_matrix [jj][kk]= adj_sf_info_list[ii]->myself.objid;
             composite_id_found=FALSE;
             break;
             }
       if( composite_id_found)
          {
          if(num_composites > 1)
             {
             affect_surf_matrix = (GRobjid **)om$realloc
                           (ptr= (char *)affect_surf_matrix,
                                 size = (num_composites+1)* sizeof(GRobjid *));
             EMerr_hndlr (!affect_surf_matrix,*EMmsg,
                                              EMS_E_NoDynamicMemory,wrapup);
             affect_surf_matrix[num_composites] = NULL;
             affect_surf_matrix[num_composites] = 
                (GRobjid *)om$malloc(size = num_affect_sfs * sizeof(GRobjid));
                      EMerr_hndlr (!affect_surf_matrix[num_composites],
                                      *EMmsg, EMS_E_NoDynamicMemory,wrapup);

             for(kk=0;kk<num_affect_sfs; kk++)
                 affect_surf_matrix [num_composites][kk] = NULL_OBJID;
             }
          affect_surf_matrix [num_composites][0] =
              adj_sf_info_list[ii]->myself.objid;
          composite_ids[num_composites] = owner_link.S_objid;
          num_composites++;
          }
       }

     size_data.addrft_info.num_composites = num_composites;
     size_data.addrft_info.num_surfaces_out =
                   num_affect_sfs - (total_loops-num_draft_surfs);
     size_data.addrft_info.num_new_commedge_pairs = num_commedges_connected;
     size_data.addrft_info.num_old_commedge_pairs = num_commedges_disconnected;

     stat_OM = om$send(msg = message EMSdpr.EMgetSSIbuffer( &msg_loc,
                       &size_data, &ssibuff),
                     targetid = my_id,
                     targetos = adj_sf_info_list[0]->myself.osnum);
     EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

     myssiinfo = &ssibuff->addrft_info;
     myssiinfo->num_composites = num_composites;
     
     for(jj=0;jj<num_composites;jj++)
          myssiinfo->composite_ids[jj] = composite_ids[jj];


     SUCC_UNTIL = DISCONN_OLD_SFS;
     inx=0;
     for(ii=0;ii<num_composites;ii++)
       {
        myssiinfo->num_surfaces_out[ii] = 0;
        for(jj=0;affect_surf_matrix[ii][jj] != NULL_OBJID; jj++)
          {
           myssiinfo->surface_out_ids[inx] = affect_surf_matrix[ii][jj];
           myssiinfo->num_surfaces_out[ii] +=1;

           owner_id.objid = composite_ids[ii];
           owner_id.osnum = adj_sf_info_list[0]->myself.osnum;

           stat_OM = om$get_index(objid_c = owner_id.objid,
                              p_chanselect = &to_comps,
                              objid = affect_surf_matrix[ii][jj],
                              indexaddr = &surf_index);

           myssiinfo->composite_indices[inx] = surf_index;

           owner_id.objid = composite_ids[ii];
           owner_id.osnum = adj_sf_info_list[0]->myself.osnum;
           stat_OM = om$send( msg = message GRconnector.GRdisconn (&msg_loc,
                               &owner_id),
                      senderid = owner_id.objid,
                      targetid = affect_surf_matrix[ii][jj]);
            EMerr_hndlr(!(1&stat_OM&msg_loc),*EMmsg,EMS_E_Fail,wrapup);

            inx++;
            }
       }

     myssiinfo->num_new_commedge_pairs = num_commedges_connected;
     for(ii=0;ii<num_commedges_connected;ii++)
        {
           myssiinfo->new_commedge_pairs1[ii] = loc_new_commedge_pairs1[ii];
           myssiinfo->new_commedge_pairs2[ii] = loc_new_commedge_pairs2[ii];
         }
         
     myssiinfo->num_old_commedge_pairs = num_commedges_disconnected;
     for(ii=0;ii<num_commedges_disconnected;ii++)
        {
           myssiinfo->old_commedge_pairs1[ii] = loc_old_commedge_pairs1[ii];
           myssiinfo->old_commedge_pairs2[ii] = loc_old_commedge_pairs2[ii];
         }


     stat_OM = om$send (msg = message EMSdpr.EMputSSI (&msg_loc,
                           ssibuff), 
                     targetid = my_id);
     EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);


/*************************************************************
Handle case of removing an associative surface from a composite
some cut and paste follows !!!
***************************************************************/

  if (ssibuff)
  {
    struct EMSaddraftssi_table *my_info;
    GRobjid                 *sfout_id;
    IGRint                  ii, jj;

    my_info = &ssibuff->addrft_info;
    sfout_id = my_info->surface_out_ids;

    for(ii=0; ii<my_info->num_composites; ii++)
    {
      for(jj=0; jj<my_info->num_surfaces_out[ii]; jj++, *sfout_id++)
      {
        stat_OM = EFfix_parent_child_relationship(&msg_loc, 
                            *sfout_id, my_info->composite_ids[ii],
                            OM_Gw_current_OS, TRUE, NULL);
        if (!(1 & stat_OM & msg_loc)) goto ret_end;
      }
    }
  }

  /* * Connect the input active solid and the added surfs to this object */

  SUCC_UNTIL = CONN_NEW_SFS;

  chan_to_comps.type = OM_e_addr;
  chan_to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

/******* ????????????????????????? ************************************
The add draft  could have been done by a re-execute in which case the 
component objects would already be there.
************************************************************************/

  stat_OM = om$get_channel_count(object = me,
                                 p_chanselect = &chan_to_comps, 
                                 count = &count);
  /* EMomerr_hndlr (stat_OM, ret_end, errmsg);   */

  {
    OM_S_MESSAGE                        packedRigidconnMessage;
    struct GRconnector_GRrigidconn_Msg  rigidconnArglist;

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    ownersIndex = OM_K_MAXINT;

    rigidconnArglist.msg = &msg_loc;
    rigidconnArglist.owners_id = &my_GRid;
    rigidconnArglist.owners_index = &ownersIndex;
    om$make_message(classname = "GRconnector",
                    methodname = "GRrigidconn",
                    size = sizeof(rigidconnArglist),
                    p_arglist = &rigidconnArglist,
                    p_msg = &packedRigidconnMessage);

   
    for(ii=0;ii<=num_affect_sfs ;ii++)
    {
        if(ii==0)
          connect_object =  active_solid.objid;
        else
          {
          connect_object = cp_sf_info_list[ii-1]->myself.objid;

          for ( kk = ii ; kk < num_affect_sfs ; kk ++ )
             if ( cp_sf_info_list [ ii - 1 ] -> myself . objid ==
                            cp_sf_info_list [ kk ] -> myself . objid )
                continue ;
          }

        stat_OM = om$is_objid_on_channel(object_c = me,
                                         p_chanselect = &chan_to_comps,
                                         objid = connect_object);
        if (stat_OM == OM_S_SUCCESS) continue;
        else stat_OM = OM_S_SUCCESS;

        if(IF_NULL_OBJID(connect_object)) continue;
        stat_OM = om$send(msg = &packedRigidconnMessage,
                          targetid = connect_object);
/*
        EMomerr_hndlr (stat_OM, ret_end, errmsg);
*/
        EMerr_hndlr (EMSerror (msg_loc), msg_loc, EMS_E_Fail, ret_end);
    }

  SUCC_UNTIL = CONN_NEW_SFS_END;

  }

/******************************************************
Set the 'dpr' properties appropriately. Then,
set the 'GRvg' properties using the construct-list
sent in. Some of these properties, need to be propogated
right through to the surface.
*********************************************************/

  /*Set the properties. -DLB*/
  ME.EMSdpr->dpr_props = EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH;    
 
  /*Set the vg props. -DLB*/
  ME.GRgraphics->properties = const_list->properties | 
                        GRIS_LOCATABLE | GRIS_DISPLAYABLE;


   {
/***********************************************************
Set my last states active bits off - these could be primitive
composites so I ignore UNKNOWN_MSG warning. -- DLB
***********************************************************/
    IGRboolean action = FALSE;
    IGRushort mask = EMSIS_ACTIVE_STATE;

    stat_OM = om$send(msg = message EMSdpr.EMsetprops(&msg_loc, &action, 
                            &mask),
                      p_chanselect = &chan_to_comps);
    if(stat_OM != OM_W_UNKNOWN_MSG)
    {
      /* EMomerr_hndlr (stat_OM, ret_end, errmsg); */
      EMerr_hndlr (EMSerror(msg_loc), msg_loc, EMS_E_Fail, ret_end);
    }
    else
      stat_OM = OM_S_SUCCESS; /*fix the return code*/
  }


 no_error = TRUE;
 ret_end:
 recovery:
 wrapup :

if(!no_error )
 {
  /****************************
  RECOVER MODEL IN CASE OF ERROR
  pardon the huge case statement!
  *****************************/

  switch(SUCC_UNTIL)
   {
   case CONN_NEW_SFS_END:
   case CONN_NEW_SFS:
     for(ii=0;ii<num_affect_sfs;ii++)
        {
        owner_id.objid = adj_sf_info_list[ii]->myself.osnum;
        owner_id.osnum = adj_sf_info_list[ii]->myself.osnum;
        for(jj=0; (jj<num_composites) && 
                  (affect_surf_matrix[jj][ii]!=NULL_OBJID); jj++)
           { 
           stat_OM = om$send( msg = message GRconnector.GRdisconn (&msg_loc,
                               &owner_id),
                      senderid = owner_id.objid,
                      targetid = my_id);
            }
        }
   case DISCONN_OLD_SFS:
    {
     OM_S_MESSAGE                        packedRigidconnMessage;
     struct GRconnector_GRrigidconn_Msg  rigidconnArglist;

     for(ii=num_composites-1; ii>=0; ii--)
       {
        my_GRid.objid = composite_ids[ii];
        my_GRid.osnum = OM_Gw_current_OS;

        for(kk=0; (kk<num_affect_sfs) && 
                  (affect_surf_matrix[ii][kk] != NULL_OBJID); kk++);

        for(jj=kk-1; jj>=0; jj--)
          {
           ownersIndex = myssiinfo->composite_indices[inx];

           rigidconnArglist.msg = &msg_loc;
           rigidconnArglist.owners_id = &my_GRid;
           rigidconnArglist.owners_index = &ownersIndex;
           om$make_message(classname = "GRconnector",
                    methodname = "GRrigidconn",
                    size = sizeof(rigidconnArglist),
                    p_arglist = &rigidconnArglist,
                    p_msg = &packedRigidconnMessage);

           connect_object =  affect_surf_matrix[ii][jj];
           stat_OM = om$is_objid_on_channel(object_c = me,
                                         p_chanselect = &chan_to_comps,
                                         objid = connect_object);
           if (stat_OM == OM_S_SUCCESS) continue;
           else stat_OM = OM_S_SUCCESS;

           if(IF_NULL_OBJID(connect_object)) continue;
           stat_OM = om$send(msg = &packedRigidconnMessage,
                          targetid = connect_object);

        }
       }
      }
   case CONN_NEW_COMMEDGES:
     for(ii=0;ii<num_affect_lps;ii++)
        {
        for(jj=0; jj<cp_sfs_info_list[ii]->num_adjacent; jj++)
            {
            e_props = NULL;
            if(cp_sfs_info_list[ii]->edges && cp_sfs_info_list[ii]->commedges)
                 if(cp_sfs_info_list[ii]->edges[jj] != NULL_OBJID  &&
                          cp_sfs_info_list[ii]->commedges[jj] != NULL_OBJID)
               {
                stat_OM = om$get_channel_count(
                                 objid = cp_sfs_info_list[ii]->edges[jj],
                                 osnum = cp_sfs_info_list[ii]->myself.osnum,
                                 p_chanselect = &to_common,
                                 count = &has_commedge);
                 if(has_commedge)
                    {
                     stat_OM = om$send( msg = message Root.disconnect
                          (to_common,
                          cp_sfs_info_list[ii]->commedges[jj],
                          OM_Gw_current_OS,
                          to_common),
                     targetid = cp_sfs_info_list[ii]->edges[jj]);

                     }
                }
             }
          }

   case DISPLAY_OLD_NEW_SFS:
      {
       IGRboolean aflag = 0;
       struct GRmd_env display_env;
       
       aflag = pwIsActivationOn();
       gr$get_module_env(buffer = &display_env);

     for(ii=0;ii<num_affect_sfs;ii++)
        {
        dpmode = GRbehe;
        stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message GRgraphics.GRdisplay (&msg_loc,
                         aflag?&display_env.md_env.matrix_type:
                               &md_env->md_env.matrix_type,
                         aflag?display_env.md_env.matrix:
                               md_env->md_env.matrix,
                         &dpmode,
                         aflag?&display_env.md_id:
                         &md_env->md_id),
                      targetid = cp_sf_info_list[ii]->myself.objid,
                      targetos = cp_sf_info_list[ii]->myself.osnum);

        stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message EMSsubbs.EMset_props (&msg_loc,
                              EMSIS_INACTIVE, EMS_O_OFF),
                      targetid = adj_sf_info_list[ii]->myself.objid,
                      targetos = adj_sf_info_list[ii]->myself.osnum);

        dpmode = GRbd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                       msg = message GRgraphics.GRdisplay (&msg_loc,
                         aflag?&display_env.md_env.matrix_type:
                               &md_env->md_env.matrix_type,
                         aflag?display_env.md_env.matrix:
                               md_env->md_env.matrix,
                         &dpmode, 
                         aflag?&display_env.md_id:
                               &md_env->md_id),
                      targetid = adj_sf_info_list[ii]->myself.objid,
                      targetos = adj_sf_info_list[ii]->myself.osnum);
        }
       }
   case DISCONN_OLD_COMMEDGES:
        for(ii=0;ii<num_affect_lps;ii++)
        {
        for(jj=0; jj<adj_sfs_info_list[ii]->num_adjacent; jj++)
            {
            e_props = NULL;
            if(adj_sfs_info_list[ii]->edges && adj_sfs_info_list[ii]->commedges)
                 if(adj_sfs_info_list[ii]->edges[jj] != NULL_OBJID  &&
                          adj_sfs_info_list[ii]->commedges[jj] != NULL_OBJID)
               {
                stat_OM = om$get_channel_count(
                                 objid = adj_sfs_info_list[ii]->edges[jj],
                                 osnum = adj_sfs_info_list[ii]->myself.osnum,
                                 p_chanselect = &to_common,
                                 count = &has_commedge);
                 if(!has_commedge)
                    {
                     stat_OM = om$send(mode = OM_e_wrt_object,
                     msg = message EMSedge.EMconnect_edges (&msg_loc, 
                          e_props,
                          TRUE,
                          adj_sfs_info_list[ii]->commedges[jj],
                          NULL_OBJID, NULL_OBJID,
                          &md_env->md_env),
                      senderid = NULL_OBJID,
                      targetid = adj_sfs_info_list[ii]->edges[jj],
                      targetos = adj_sfs_info_list[ii]->myself.osnum);
                    }
                 }
              }
         }

   case AFFECT_SFS_COPY:
   case DRAFT_SFS_CREATION_END:
        for(ii=0;ii<num_affect_sfs;ii++)
         {
         if( cp_sf_info_list && 
               cp_sf_info_list[ii] && 
                  cp_sf_info_list[ii]->myself.objid != NULL_OBJID)
           {
            stat_OM = om$send( msg = message GRgraphics.GRdelete (&msg_loc,
                         md_env),
                      targetid = cp_sf_info_list[ii]->myself.objid,
                      targetos = cp_sf_info_list[ii]->myself.osnum);
           }
         }
        break;
    } /** END SWITCH **/
  }

/***************************
DEALLOCATE ALL LOCAL MEMORY
****************************/
Exit :
        if(composite_ids)
            om$dealloc(ptr= composite_ids);
        if(loc_new_commedge_pairs1)
            om$dealloc(ptr= loc_new_commedge_pairs1);
        if(loc_new_commedge_pairs2)
            om$dealloc(ptr= loc_new_commedge_pairs2);
        if(loc_old_commedge_pairs1)
            om$dealloc(ptr= loc_old_commedge_pairs1);
        if(loc_old_commedge_pairs2)
            om$dealloc(ptr= loc_old_commedge_pairs2);
        if(affect_surf_matrix)
          for(ii=0;ii<num_composites;ii++)
            om$dealloc(ptr= affect_surf_matrix[ii]);
        if(affect_surf_matrix)
            om$dealloc(ptr= affect_surf_matrix);

        EMinfo_free_both(&msg_loc, &adj_sfs_info_list[0] ,
                                   &cp_sfs_info_list[0], num_affect_lps);

        if(adj_sf_info_list)
          om$dealloc(ptr = adj_sf_info_list);
        if(cp_sf_info_list)
          om$dealloc(ptr = cp_sf_info_list);
        if(adj_sfs_info_list)
          om$dealloc(ptr = adj_sfs_info_list);
        if(cp_sfs_info_list)
          om$dealloc(ptr = cp_sfs_info_list);

        EMWRAPUP( *EMmsg, stat_OM, "EMadd_draft");
        return (stat_OM);
       }


end implementation EMSsfaddraft;



