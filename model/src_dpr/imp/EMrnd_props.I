/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "emsmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emssfint.h"
#include "emsinter.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "OMmacros.h"

from EMSedge import EMget_top_part_edges;
from EMSloop import EMset_props;
from EMSloopset import EMset_props;
from EMSboundary import EMget_objid;

method EMset_tply_props (IGRlong                   *EMmsg;
                         IGRboolean                partner_props;
                         struct EMSsfintedpar      **trim_info;
                         IGRint                    num_trim_info;
                         IGRint                    num_loops_added;
                         GRobjid                   *loops_added;
                         GRobjid                   surface_id;
                         struct EMround_save_state *svst_info)

{

 IGRlong            stat_OM, msg;
 OMuint             i, comm_edge_cnt;
 IGRint             buf_size, num_pe;
 IGRushort  props;
 GRobjid            com_edge, *p_edges;
 OM_S_CHANSELECT    to_loopset,
                    to_common_edge;

/*-------------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
 if (! (1 & stat_OM)) goto wrapup;

 props = EMLP_NATURAL;

 for (i=0; i<num_loops_added; i++)
  {
   stat_OM = om$send(msg = message EMSloop.EMset_props (&msg,
                          props, EMS_O_OFF),
                     targetid = loops_added[i]);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
  }

 props = EMLS_NATURAL;
 stat_OM = om$send (msg = message EMSloopset.EMset_props (&msg, props,
                          EMS_O_OFF),
                    senderid = surface_id,
                    p_chanselect = &to_loopset);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopsetError, wrapup);

 if (partner_props)
  {
   p_edges = NULL;
   num_pe = buf_size = 0;

   stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);

   svst_info->edge_out_ids = (GRobjid *) om$malloc(size =
                                 num_trim_info * 10 * sizeof (GRobjid));
   svst_info->num_edges_in = (IGRint *) om$malloc(size =
                                  num_trim_info * 10 * sizeof (IGRint));
   svst_info->edge_in_ids = (GRobjid **) om$malloc(size =
                               num_trim_info * 10 * sizeof (GRobjid *));

   for (i=0; i<num_trim_info; i++)
    {
     if ((trim_info[i]->intloc == EMScvint_middle) &&
         (trim_info[i]->edgeid != NULL_OBJID))
      {
       stat_OM = om$get_channel_count(osnum = OM_Gw_current_OS,
                                      objid = trim_info[i]->edgeid,
                                      p_chanselect = &to_common_edge,
                                      count = &comm_edge_cnt);

       if (comm_edge_cnt)
        {
         stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                                 &com_edge),
                           senderid = trim_info[i]->edgeid,
                           p_chanselect = &to_common_edge);
         EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg,EMS_E_EdgeError,wrapup);

         stat_OM = om$send (msg = message EMSedge.EMget_top_part_edges(
                                  &msg, &p_edges, &num_pe, &buf_size),
                            targetid = com_edge);
         EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);

         stat_OM = EMsend_loops(&msg,
                                message EMSloop.EMset_props (&msg,
                                EMLP_NATURAL, EMS_O_OFF),
                                (num_pe) ? p_edges[0] : com_edge, 0,
                                OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
         EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg,EMS_E_LoopError,wrapup);

         svst_info->edge_out_ids[svst_info->num_edges_out] = com_edge;
         svst_info->num_edges_in[svst_info->num_edges_out] = num_pe;
         svst_info->edge_in_ids[svst_info->num_edges_out] = p_edges;
         svst_info->num_edges_out += 1;

         p_edges = NULL; num_pe = buf_size = 0;
        }
      }

     if ((trim_info[i]->next->intloc == EMScvint_middle) &&
         (trim_info[i]->next->edgeid != NULL_OBJID))
      {
       stat_OM = om$get_channel_count(osnum = OM_Gw_current_OS,
                                   objid = trim_info[i]->next->edgeid,
                                   p_chanselect = &to_common_edge,
                                   count = &comm_edge_cnt);

       if (comm_edge_cnt)
        {
         stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                                 &com_edge),
                           senderid = trim_info[i]->next->edgeid,
                           p_chanselect = &to_common_edge);
         EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg,EMS_E_EdgeError,wrapup);

         stat_OM = om$send (msg = message EMSedge.EMget_top_part_edges(
                                  &msg, &p_edges, &num_pe, &buf_size),
                            targetid = com_edge);
         EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);

         stat_OM = EMsend_loops(&msg,
                                message EMSloop.EMset_props (&msg,
                                EMLP_NATURAL, EMS_O_OFF), 
                                (num_pe) ? p_edges[0] : com_edge, 0,
                                OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
         EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg,EMS_E_LoopError,wrapup);

         svst_info->edge_out_ids[svst_info->num_edges_out] = com_edge;
         svst_info->num_edges_in[svst_info->num_edges_out] = num_pe;
         svst_info->edge_in_ids[svst_info->num_edges_out] = p_edges;
         svst_info->num_edges_out += 1;

         p_edges = NULL; num_pe = buf_size = 0;
        }
      }
    }   
  }

 wrapup:
  
  EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMset_tply_props");
  return(stat_OM);
}

end implementation EMSsfround;
