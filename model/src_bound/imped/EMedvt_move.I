/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSerrordef.h"
#include "EMSlmdef.h"
#include "EMSlm.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "OMmacros.h"

from EMSsfmove import EMloop_add;

method EMmove_vertex (
        IGRlong  *EMmsg;                /* completion code */
        IGRshort option;             /* option for begin or end */
        struct GRmd_env *my_env)
/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_F_Fail if failure
                - EMS_E_EdgeError error in edge method
Assumption

Bugs

History
	
	  gupta 	05/04/87:	design date
                10/19/87:   changed to new class structure and modified
                            for composite surfaces

Algorithm

      get all the edges in the composite sharing the same xyz point
      as my vertex. Take each edge at a time and move its internal
      geometry proportionally through the input vector. Then move
      the vertex (corresponding end point of edge) through the input
      vector and store the loop so that the same vertex doesn't get
      moved by another edge in the same loop.
*/

{
  IGRint                          i, j, cnt, num_edges;
  IGRlong                         stat_OM, msg, msg1;
  IGRdouble                       uvbegpt[2], uvendpt[2];
  IGRboolean                      *right_vtx, vertex_moved, opt;
  GRobjid                         *edge_ids, *vt_loop_ids;
  GRobjid                         loop_id;
  struct EMinstruction_table_info my_it_info;
  IGRint EMsend_loops();

/* ------------------------------------------------------------- */

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  vt_loop_ids = NULL;
  num_edges = j = 0;
  opt = (option == EMS_EDGE_BEG_PT) ? 0 : 1;

  /* get all the edges on various surfaces which is not degenerate and
     shares my xyz vertex point -- begin or end (option) */

  stat_OM = om$send(msg = message EMSedge.EMgetvtxedges(&msg, 
                          EMSvtxedges_nodegenerate,opt,0,
                          &num_edges, &edge_ids, &right_vtx),
                    targetid = my_id);
  EMomerr_hndlr(stat_OM, wrapup, "EMedvt_move.EMvtxedges");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

  vt_loop_ids = (GRobjid *) om$malloc(size = num_edges * sizeof(GRobjid));

  EMerr_hndlr (! vt_loop_ids , *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  for (i=0; i<num_edges; i++)
   {
    /*
     * if the edge is not compatible with respect to its common edge
     * ---- the knot lines on these surfaces do not match, make them
     * compatible by inserting knotlines at appropriate parameters of
     * its surface 
     */
    stat_OM = om$send(msg = message EMSedge.EMmake_compatible(&msg,
                            my_env),
                      targetid = edge_ids[i]);
    EMerr_hndlr(msg == EMS_I_DiffSrfOrder,*EMmsg,EMS_I_DiffSrfOrder,
                wrapup);
    EMomerr_hndlr(stat_OM, wrapup, "EMedvt_move.EMmake_compatible");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
    
    stat_OM = EMsend_loops(&msg,
                       message EMSboundary.EMget_objid (&msg1,
                       &loop_id), edge_ids[i], 0, OM_K_MAXINT,
                       EMLP_ACTIVE, NULL, NULL);
    EMerr_hndlr(EMis_error(msg1), *EMmsg, msg, wrapup);
    EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

    stat_OM = om$send(msg=message EMSedge.EMendpts(
                          &msg,uvbegpt,uvendpt,NULL,NULL,NULL),
                      targetid = edge_ids[i]);
    EMomerr_hndlr(stat_OM, wrapup, "EMedvt_move.EMendpts");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

    my_it_info.move_operation = EMS_MOVE_INT_PRP_EDGE;

    if (right_vtx[i])
      {
        my_it_info.params.end_pts[0] = uvendpt[0];
        my_it_info.params.end_pts[1] = uvendpt[1];

        my_it_info.params.end_pts[2] = uvbegpt[0];
        my_it_info.params.end_pts[3] = uvbegpt[1];
      }
    else
      {
        my_it_info.params.end_pts[0] = uvbegpt[0];
        my_it_info.params.end_pts[1] = uvbegpt[1];

        my_it_info.params.end_pts[2] = uvendpt[0];
        my_it_info.params.end_pts[3] = uvendpt[1];
      }

    stat_OM = om$send(msg=message EMSsfmove.EMloop_add(&msg,
                          my_it_info, loop_id),
                      targetid = sender_id,
                      targetos = sender_os);
    EMomerr_hndlr(stat_OM, wrapup, "EMedvt_move.EMloop_add");
    EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

    vertex_moved = FALSE;

    /*
     * Check to see if the vertex has already been moved for this
     * loop through another edge. If so do not move it else move
     * it and save the loop id in vt_loop_ids[]
     */

    for(cnt=0; cnt<j; cnt++)
     {
      if(loop_id == vt_loop_ids[cnt])
         vertex_moved = TRUE;
     }

    if (! vertex_moved)
     {
      vt_loop_ids[j] = loop_id;
      j++;

      my_it_info.move_operation = EMS_MOVE_LIN_VERTEX;

      my_it_info.params.vt_pt[0] = my_it_info.params.end_pts[0];
      my_it_info.params.vt_pt[1] = my_it_info.params.end_pts[1];
    
      stat_OM = om$send(msg=message EMSsfmove.EMloop_add(&msg,
                            my_it_info, loop_id),
                        targetid = sender_id,
                        targetos = sender_os);
      EMomerr_hndlr(stat_OM, wrapup, "EMedvt_move.EMloop_add");
      EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);
     }
   }

wrapup:

  if(vt_loop_ids) om$dealloc(ptr = vt_loop_ids);
  return(stat_OM);
}

end implementation EMSedge;
