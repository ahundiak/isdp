/* ###################   APOGEE COMPILED   ################## */
/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"

extern OMuword OPP_EMSsubbs_class_id;

from EMSsubbs import EMvariable_fillet_surface,
                     EMget_edges;
from EMSedge import EMconnect_edges;

method EMfillet_auto_trim (IGRlong               *EMmsg;
                           struct GRmd_env       *my_env;
                           GRobjid               surface1_id,
                                                 surface2_id;
                           IGRboolean            s1_nat_norm,
                                                 s2_nat_norm;
                           IGRpoint              starting_point;
                           IGRdouble             starting_radius;
                           IGRpoint              ending_point;
                           IGRdouble             ending_radius;
                           IGRdouble             rho;
                           IGRboolean            *add_s1_to_tree,
                                                 *add_s2_to_tree;
                           struct GRvg_construct *construct_list)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	08/24/88:	design date
      RC        01/31/90    Fixed bugs regarding composite surface
                            autotrim code addition

Algorithm

*/

{
 IGRlong                   stat_OM, msg, msg1, i;
 IGRshort                  dis_option;
 IGRboolean                response_taken,
                           exit_gracefully;
 IGRint                    arr_size;
 OMuint                    count;
 IGRint                    ls_count, num_pair_info;
 IGRint                    num_edges0=0, buff_size0=0;
 IGRint                    num_edges1=0, buff_size1=0;
 IGRint                    num_surfs0, num_surfs1, num_surf_ids;
 enum GRdpmode             display_mode = GRbd;
 struct EMedge_round_info  my_info;
 struct EMedge_con_info    *pair_info;
 struct EMround_save_state svst_info;
 struct GRid               temp_id, *surf_ids;
 OM_S_OBJECT_LINKAGE       surf_owner;
 OM_S_CHANSELECT           to_cpx, to_loopset, to_comps;

/*----------------------------------------------------------------*/
 
 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 arr_size = 50;
 num_pair_info = 0;
 response_taken = FALSE;
 exit_gracefully = TRUE;
 pair_info = NULL;
 surf_ids = NULL; 
 ME.EMSsfround->operation_type = EMS_RND_AUTOTRIM;

 svst_info.num_surfaces = 0;
 svst_info.num_edges_out = 0;
 svst_info.num_edges_in = NULL;
 svst_info.edge_in_ids = NULL;
 svst_info.edge_out_ids = NULL;
 svst_info.num_edges_rounded = 0;
 svst_info.rounded_edge_ids = NULL;
 svst_info.surface_ids = NULL;
 svst_info.num_regions_in = NULL;
 svst_info.num_regions_out = NULL;
 svst_info.region_in_ids = NULL;
 svst_info.region_out_ids = NULL;

 pair_info = (struct EMedge_con_info *) om$malloc (size =   
                    arr_size * sizeof(struct EMedge_con_info)); 

 stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
 stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
 stat_OM = EMmake_chanselect (GRconnector_to_owners, &to_cpx);
 if (! (1 & stat_OM)) goto wrapup;

 stat_OM = om$get_channel_count(objid = surface1_id,
                                p_chanselect = &to_loopset,
                                count = &count);
 if (! (1 & stat_OM)) goto wrapup;

 if(!count)
  {
   stat_OM = om$send(msg = message EMSsurface.EMmk_nat_bdry (&msg, 
                           &my_env->md_env, NULL), 
                     targetid = surface1_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }

 stat_OM = om$get_channel_count(objid = surface2_id,
                                p_chanselect = &to_loopset,
                                count = &count);
 if (! (1 & stat_OM)) goto wrapup;

 if(!count)
  {
   stat_OM = om$send(msg = message EMSsurface.EMmk_nat_bdry (&msg, 
                           &my_env->md_env, NULL), 
                     targetid = surface2_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }

 temp_id.objid = my_id;
 temp_id.osnum = OM_Gw_current_OS;
 
 my_info.edge_type = EMS_CONVEX_EDGE;
 my_info.edge_id = NULL_OBJID;
 my_info.radius = starting_radius;
 my_info.surface_id = surface1_id;
 my_info.comm_surface_id = surface2_id;

 stat_OM = om$send(msg = message EMSsubbs.EMvariable_fillet_surface (&msg,
                         my_env,
                         &temp_id.objid,
                         s1_nat_norm,
                         s2_nat_norm,
                         starting_point,
                         starting_radius,
                         ending_point,
                         ending_radius,
                         construct_list,
                         &my_info,
                         &my_info.fillet_id),
                   targetid = my_info.surface_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 /* connect the fillet_surface to the Round dpr */

 i = 0;
 stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg,
                          &temp_id, &i),
                    targetid = my_info.fillet_id,
                    targetos = OM_Gw_current_OS);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                         &my_env->md_env.matrix_type, 
                         my_env->md_env.matrix, &display_mode,
                         &my_env->md_id),
                   targetid = my_info.fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, msg, wrapup);

 stat_OM = om$get_channel_objects(osnum = OM_Gw_current_OS,
                                  objid = surface1_id,
                                  p_chanselect = &to_cpx,
                                  list = &surf_owner,
                                  size = 1,
                                  count = &count);
 if (! (1 & stat_OM)) goto wrapup;

 if (count)
 {
  num_surfs0 = 0;
  stat_OM = om$send(msg = message GRowner.GRget_number_components(
                         &msg, &num_surfs0),
                   targetos = surf_owner.osnum,
                   targetid = surf_owner.S_objid);
  if (! (1 & stat_OM & msg)) goto wrapup;

 } /* if (count) */
 else
  num_surfs0 = 1;

 
  stat_OM = om$get_channel_objects(osnum = OM_Gw_current_OS,
                                  objid = surface2_id,
                                  p_chanselect = &to_cpx,
                                  list = &surf_owner,
                                  size = 1,
                                  count = &count);
 if (! (1 & stat_OM)) goto wrapup;

 if (count)
 {
  num_surfs1 = 0;
  stat_OM = om$send(msg = message GRowner.GRget_number_components(
                         &msg, &num_surfs1),
                   targetos = surf_owner.osnum,
                   targetid = surf_owner.S_objid);
  if (! (1 & stat_OM & msg)) goto wrapup;

 } /* if (count) */
 else
  num_surfs1 = 1;

 stat_OM = om$send(msg = message EMSsubbs.EMget_edges(&msg, MAXINT,
                         EMS_OPT_NON_DEG_STITCHED, my_env, NULL,
                         &buff_size0, &num_edges0),
                   targetid = surface1_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 stat_OM = om$send(msg = message EMSsubbs.EMget_edges(&msg, MAXINT,
                         EMS_OPT_NON_DEG_STITCHED, my_env, NULL,
                         &buff_size1, &num_edges1),
                   targetid = surface2_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 ls_count = OM_DIMENSION_OF(ME.EMSdpr->ids);

 svst_info.surface_ids = (GRobjid *) om$malloc(size =
                      ME.EMSsfround->no_of_boundaries * sizeof (GRobjid));
 svst_info.num_regions_in = (IGRint *) om$malloc(size =
                       ME.EMSsfround->no_of_boundaries * sizeof (IGRint));
 svst_info.region_in_ids = (GRobjid **) om$malloc(size =
                    ME.EMSsfround->no_of_boundaries *
                    ME.EMSsfround->no_of_boundaries * sizeof (GRobjid *));
 svst_info.num_regions_out = (IGRint *) om$malloc(size =
                       ME.EMSsfround->no_of_boundaries * sizeof (IGRint));
 svst_info.region_out_ids = (GRobjid **) om$malloc(size =
                    ME.EMSsfround->no_of_boundaries *
                    ME.EMSsfround->no_of_boundaries * sizeof (GRobjid *));
 svst_info.rounded_edge_ids = (GRobjid *) om$malloc(size =
                        3 * (num_surfs0 + num_surfs1) * sizeof (GRobjid));
 svst_info.edge_out_ids = (GRobjid *) om$malloc(size =
                           (num_edges0 + num_edges1) * sizeof (GRobjid));
 svst_info.num_edges_in = (IGRint *) om$malloc(size =
                           (num_edges0 + num_edges1) * sizeof (IGRint));
 svst_info.edge_in_ids =  (GRobjid **) om$malloc(size =
                           (num_edges0 + num_edges1) * sizeof(GRobjid *));

 for (i=0; i<ls_count; i++)
  {
   svst_info.num_regions_in[i] = 0;
   svst_info.num_regions_out[i] = 0;
  }

 dis_option = EMS_DO_DISPLAY;

 stat_OM = om$send (msg = message EMSsfround.EMround_execute (&msg,
                          my_env,
                          &my_info,
                          NULL,
                          &num_pair_info, 
                          pair_info,
                          NULL,
                          NULL,
                          &dis_option,
                          &svst_info,
                          add_s1_to_tree,
                          add_s2_to_tree,
                          &response_taken,
                          &exit_gracefully,
                          EMS_DO_DISPLAY,
                          NULL, NULL),
                    targetid = my_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 if (msg == EMS_I_RndGrExit)
  {
   *EMmsg = EMS_I_RndGrExit;
   goto wrapup;
  }

 for (i=0; i<num_pair_info; i++)
  {
   stat_OM = om$send (msg = message EMSedge.EMconnect_edges (&msg,
                            NULL, TRUE, 
                            pair_info[i].comm_edge,
                            pair_info[i].edge_surf,
                            pair_info[i].comm_edge_surf,
                            &my_env->md_env),
                      targetid = pair_info[i].edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 UI_status(" ");


wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMfillet_auto_trim");

 if (! (1 & stat_OM & msg) && (msg != EMS_E_RndGrExit))
  { 
   if (! response_taken)
       EMdecide_grexit(&msg, &exit_gracefully);

   if (exit_gracefully)
    {
     stat_OM = om$send(msg = message EMSsfround.EMround_graceful_exit (
                             &msg, my_env, temp_id, NULL, NULL, NULL,
                             &svst_info),
                       targetid = my_id);
     if (! (1 & stat_OM & msg)) *EMmsg = EMS_E_RndGrExit;
     else *EMmsg = EMS_I_RndGrExit;
    }
   else
    {
     stat_OM = OM_S_SUCCESS;
     msg = EMS_S_Success;

     if (1 & (stat_OM = om$is_objid_valid(objid = my_id)))
      {
       EFgetobjids (&msg1, &temp_id, &to_comps, &surf_ids, &num_surf_ids, 
                    OPP_EMSsubbs_class_id, NULL, 0);

       stat_OM = om$send(msg = message EMSsfround.EMround_cleanup (&msg,
                               my_env, &num_surf_ids, surf_ids),
                         targetid = my_id);
      }
     else
      stat_OM = OM_S_SUCCESS;
    }
  }

 if (pair_info) om$dealloc (ptr = pair_info);
 if (surf_ids) om$dealloc(ptr = surf_ids);

 if (svst_info.surface_ids) om$dealloc(ptr = svst_info.surface_ids);
 if (svst_info.num_regions_in) om$dealloc(ptr = svst_info.num_regions_in);
 if (svst_info.region_in_ids) om$dealloc(ptr = svst_info.region_in_ids);
 if (svst_info.num_regions_out)
                             om$dealloc(ptr = svst_info.num_regions_out);
 if (svst_info.region_out_ids) om$dealloc(ptr = svst_info.region_out_ids);
 if (svst_info.edge_in_ids) om$dealloc(ptr = svst_info.edge_in_ids);
 if (svst_info.edge_out_ids) om$dealloc(ptr = svst_info.edge_out_ids);
 if (svst_info.rounded_edge_ids)
     om$dealloc(ptr = svst_info.rounded_edge_ids);

 return(stat_OM);
}

end implementation EMSsfround;
