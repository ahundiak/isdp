/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSprop.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"

from EMSsubbs    import EMcomp_traverse;
from EMSedge     import EMgetsurface_info,
                        EMget_top_part_edges;
from EMSboundary import EMget_objid;

method EMcleanup_surfaces (IGRlong                   *EMmsg;
                           struct GRmd_env           *my_env;
                           IGRint                    num_out_loops;
                           GRobjid                   *out_loops;
                           IGRint                    num_trim_info;
                           struct EMSsfintedpar      **trim_info;
                           struct EMedge_round_info  *my_info;
                           struct EMround_save_state *svst_info)

/*
History

      gupta     11/29/89:   design date

 
This method figures out the surfaces which needs to be cleaned out for
fillet with autotrim when the composite becomes disjoint. It also stores
the common edges that were split and their resultant part edges in the 
save state info.

*/

{
 IGRlong                   stat_OM, msg;
 IGRint                    i, j, k;
 IGRint                    num_part_edges, buf_size;
 IGRint                    num_surfs, arr_size;
 OMuint                    num_edges, num_loops;
 OMuint                    count, owner_index;
 IGRshort                  mask;
 IGRboolean                skip, action;
 GRobjid                   edge_id, adj_surface_id;
 GRobjid                   *surface_ids, *part_edges;
 GRobjid                   com_edge;
 struct GRid               temp_id;
 enum GRdpmode             display_mode = GRbehe;
 OM_S_OBJECT_LINKAGE       surf_owner;
 OM_S_CHANSELECT           to_edges, to_cpx;
 OM_S_CHANSELECT           to_comps, to_common_edge;
 IGRint                    EMcount_loops();

/*----------------------------------------------------------------*/
 
 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 stat_OM = EMmake_chanselect (GRconnector_to_owners, &to_cpx);
 stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
 if (! (1 & stat_OM)) goto wrapup;
 
 for (i=0; i<num_out_loops; i++)
  {
   stat_OM = om$get_channel_count(objid = out_loops[i],
                                  count = &num_edges,
                                  p_chanselect = &to_edges);
   if (! (1 & stat_OM)) goto wrapup;

   for (j=0; j<num_edges; j++)
    {
     stat_OM = om$send (msg = message EMSboundary.EMget_objid (&msg,
                              &edge_id),
                        senderid = out_loops[i],
                        p_chanselect = &to_edges,
                        from = j,
                        to = j);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

     skip = FALSE;

     for(k=0; k<num_trim_info; k++)
      {
	   if(IF_EQ_OBJID(trim_info[k]->edgeid, edge_id) ||
          (trim_info[k]->next ? 
          IF_EQ_OBJID(trim_info[k]->next->edgeid, edge_id) : NULL))
        {
         stat_OM = om$send(msg = message EMSboundary.EMget_objid (&msg,
                                 &com_edge),
                           senderid = edge_id,
                           p_chanselect = &to_common_edge);
         EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);

         if (stat_OM == OM_S_SUCCESS)
          {
           svst_info->edge_out_ids[svst_info->num_edges_out] = com_edge;

           part_edges = NULL;
           num_part_edges = buf_size = 0;

           stat_OM = om$send (msg = message EMSedge.EMget_top_part_edges(
                                    &msg, &part_edges, &num_part_edges,
                                    &buf_size),
                              targetid = com_edge);
           EMerr_hndlr(!(1 &stat_OM &msg),*EMmsg,EMS_E_EdgeError,wrapup);

           svst_info->num_edges_in[svst_info->num_edges_out] =
                                                          num_part_edges;
           svst_info->edge_in_ids[svst_info->num_edges_out] = part_edges;
           (svst_info->num_edges_out)++;
          }

         skip = TRUE;
         break;
        }
      }

     if (skip) continue;

     stat_OM = EMcount_loops (&msg, edge_id, &num_loops, NULL,
                              EMLP_ACTIVE, NULL, NULL);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

     if (! num_loops)
      {
       stat_OM = om$get_channel_count(objid = edge_id,
                                      count = &count,
                                      p_chanselect = &to_common_edge);
       if (! (1 & stat_OM)) goto wrapup;

       if (! count) continue;

       stat_OM = om$send(msg = message EMSedge.EMgetsurface_info (&msg,
                               &adj_surface_id, NULL),
                         senderid = edge_id,
                         p_chanselect = &to_common_edge);
       EMerr_hndlr (! (1 & stat_OM), *EMmsg, EMS_E_EdgeError, wrapup);

       if (stat_OM == OM_I_CHAN_EMPTY)
        {
         stat_OM = OM_S_SUCCESS;
         continue;
        }

       if ((adj_surface_id != my_info->surface_id) &&
           (adj_surface_id != my_info->comm_surface_id))
        {
         arr_size = 0;
         num_surfs = 0;
         surface_ids = NULL;

         stat_OM = om$send(msg = message EMSsubbs.EMcomp_traverse (&msg,
                                 &surface_ids, &num_surfs, &arr_size),
                           targetid = adj_surface_id);
         EMerr_hndlr (! (1 & stat_OM), *EMmsg, EMS_E_SurfaceError,wrapup);

         for (k=0; k<num_surfs; k++)
          {
           stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                                   &my_env->md_env.matrix_type,
                                   my_env->md_env.matrix, 
                                   &display_mode, 
                                   &my_env->md_id),
                             targetid = surface_ids[k]);
           EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);

           mask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
           action = FALSE;

           stat_OM = om$send (msg = message GRvg.GRchgprops (&msg,
                                    &action, &mask),
                              targetid = surface_ids[k]);
           EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, msg, wrapup);

           stat_OM = om$get_channel_objects(osnum = OM_Gw_current_OS,
                                            objid = surface_ids[k],
                                            p_chanselect = &to_cpx,
                                            list = &surf_owner,
                                            size = 1,
                                            count = &count);
           if (! (1 & stat_OM)) goto wrapup;

           stat_OM = om$get_index(objid_c = surf_owner.S_objid,
                                  p_chanselect = &to_comps,
                                  objid = surface_ids[k],
                                  indexaddr = &owner_index);
           if (! (1 & stat_OM)) goto wrapup;
            
           svst_info->rounded_edge_ids[(svst_info->num_edges_rounded)++] =
                                        surface_ids[k]; 
           svst_info->rounded_edge_ids[(svst_info->num_edges_rounded)++] =
                                        surf_owner.S_objid; 
           svst_info->rounded_edge_ids[(svst_info->num_edges_rounded)++] =
                                        owner_index; 
           temp_id.objid = surf_owner.S_objid;
           temp_id.osnum = surf_owner.osnum;

           stat_OM = om$send (msg = message GRconnector.GRdisconn (&msg,
                                    &temp_id),
                              senderid = surf_owner.S_objid,
                              targetid = surface_ids[k]);
           EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, msg, wrapup);
          }

         if (surface_ids) om$dealloc(ptr = surface_ids);         
        }
      }
    }
  }

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMcleanup_surfaces");

 return(stat_OM);
}

end implementation EMSsfround;
