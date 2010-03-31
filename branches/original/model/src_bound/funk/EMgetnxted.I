class implementation EMSedge;

#include "EMSopt.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsgeteddef.h"
#include "maidmx.h"

#define BUFF_INCR 6

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloop import EMnext_edge;

IGRlong EMgetnxtedges (msg, opts, ref_edge, os, at_stop,
                       return_upto, num_ret, nbh_edge, ed_props, num_skipped)
IGRlong *msg;
IGRushort opts;
GRobjid ref_edge;
GRspacenum os;
IGRboolean at_stop;
IGRint return_upto, *num_ret;
GRobjid *nbh_edge;
IGRushort *ed_props;
IGRint *num_skipped;
{
  IGRboolean include_nodegenerate;
  IGRboolean last_found, degenerate;
  IGRushort props;
  IGRuint total_num_edges;
  IGRint inx, num_visited;
  IGRlong stat_OM, msg_loc, msg_loc1, msg_loc2;
  GRobjid edge, act_lp;
  IGRint EMsend_loops(); 
  OM_S_CHANSELECT to_edges;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *num_ret = 0;
  *num_skipped = 0;

  include_nodegenerate = opts & EMSvtxedges_nodegenerate;

  act_lp = NULL_OBJID;
  EMsend_loops (&msg_loc1, message EMSboundary.EMget_objid (&msg_loc2,
   &act_lp), ref_edge, 0, 0, EMLP_ACTIVE, NULL, NULL);
  EMerr_hndlr (IF_NULL_OBJID (act_lp), *msg, EMS_I_NotFound, ret_end);

  EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);
  total_num_edges = 0;
  om$get_channel_count(objid = act_lp, osnum = os, p_chanselect = &to_edges,
   count = &total_num_edges);
  EMerr_hndlr (!total_num_edges, *msg, EMS_I_NotFound, ret_end);

  inx = 0;
  last_found = FALSE;
  num_visited = 0;

  do
    {
    num_visited++;  
    edge = NULL_OBJID;
    stat_OM = EMsend_loops (&msg_loc1, message EMSloop.EMnext_edge
               (&msg_loc2, at_stop ? EMGetEd_Next : EMGetEd_Previous,
               ref_edge, &edge), ref_edge, 0, 0, EMLP_ACTIVE, NULL, NULL);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc1 & msg_loc2), *msg, EMS_E_Fail,
     ret_end);
    EMerr_hndlr (IF_NULL_OBJID (edge), *msg, EMS_I_NotFound, ret_end);

    stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc, &props),
               targetid = edge, targetos = os, senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

    degenerate = props & EMED_DEGENERATE ? TRUE : FALSE;
    if (!include_nodegenerate || !degenerate)
      {
      nbh_edge[inx] = edge;
      ed_props[inx] = props;
      (*num_ret)++;
      if (!degenerate)
        last_found = TRUE;
      inx++;
      }
    else
      (*num_skipped)++;

    /* If the next edge found was the same as the ref_edge, we have certainly
       found the last edge. This can happen for a valid loop with only one 
       edge.
       SM 3/23/93
    */
    if(IF_EQ_OBJID(ref_edge, edge))
     last_found = TRUE;

    ref_edge = edge;
    }
  while (!last_found && inx<return_upto && num_visited<total_num_edges);
  
ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetnxtedges");
  return (stat_OM);
}

end implementation EMSedge;
