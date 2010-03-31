/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"

from EMSedge import EMset_props;

IGRboolean EMconn_split_edges (EMmsg, split_num, option, edges,
                               patch_edges, full_edge, num_full_edge,
                               reverse, pos, uv_closed) 

 IGRlong *EMmsg;
 IGRint split_num, option;
 GRobjid *edges, *patch_edges, *full_edge;
 IGRint num_full_edge;
 IGRshort pos;
 IGRboolean reverse, *uv_closed;
{

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure
                - EMS_E_EdgeError error in edge method
Assumption

Bugs

History
	
	  gupta 	05/05/87:	design date

Algorithm
      
      This method merely connects the edges of split surfaces and split 
      edges of the common edge of the surface which was split. These 
      split edges are in 'edges'. The natural edges of the split surfaces
      fall into four different categories --

      o  full edge      -- these edges were not split at all and are
                           natural edges
      o  patch_edges[0] -- this resulted from a natural edge which had
                           to be split and the part edge towards the
                           end point of the natural edge had to be kept
      o  patch_edges[1] -- this resulted from a natural edge which had 
                           to be split and the part edge towards the 
                           begin point of the natural edge had to be kept
      o  patch_edges[2] -- this resulted from a natural edge being split
                           at two different parameters and the portion
                           in the middle had to be kept

      This method also sets the EMS_REVERSED_CONNNECT bit for full_edge
      and patch_edges[] if their counterpart had this bit ON

*/

 IGRlong  stat_OM;
 IGRlong  msg;
 IGRint   i, j, first, last;
 OM_S_CHANSELECT to_comm_edge;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 first = 0;
 last = split_num;

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_comm_edge);
 EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.make_chanselect");

 if (option == 0 && uv_closed[1])
     return (stat_OM);
 if (option == 1 && uv_closed[0])
     return (stat_OM);
 if (num_full_edge == 0)
     last = 0;

 if (! IF_NULL_OBJID (patch_edges[2]))
  {
   stat_OM = om$send(msg = message Root.connect(to_comm_edge, 0,
                           edges[0], OM_Gw_current_OS, to_comm_edge, 0),
                     senderid = NULL_OBJID,
                     targetid = patch_edges[2]);
   EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.connect");

   if (reverse)
    {
     stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                             EMED_REVERSE_CONNECT, EMS_O_ON),
                       senderid = NULL_OBJID,
                       targetid = patch_edges[2]);
     EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.EMset_props");
     EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }
   last = 0;
  }

 if (! IF_NULL_OBJID (patch_edges[0]))
  {
   if ((pos == 2 || pos == 3))
    {
     stat_OM = om$send(msg = message Root.connect(to_comm_edge, 0,
                             edges[split_num-1], OM_Gw_current_OS,
                             to_comm_edge, 0),
                       senderid = NULL_OBJID,
                       targetid = patch_edges[0]);
     EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.connect");
     last = split_num - 1;
    }
   else
    {
     stat_OM = om$send(msg = message Root.connect(to_comm_edge, 0,
                             edges[0], OM_Gw_current_OS, to_comm_edge, 0),
                       senderid = NULL_OBJID,
                       targetid = patch_edges[0]);
     EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.connect");
     first = 1;
    }
   if (reverse)
    {
     stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                             EMED_REVERSE_CONNECT, EMS_O_ON),
                       senderid = NULL_OBJID,
                       targetid = patch_edges[0]);
     EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.EMset_props");
     EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }
  }

 if (! IF_NULL_OBJID (patch_edges[1]))
  {
   if ((pos == 2 || pos == 3))
    {
     stat_OM = om$send(msg = message Root.connect(to_comm_edge, 0,
                             edges[0], OM_Gw_current_OS,
                             to_comm_edge, 0),
                       senderid = NULL_OBJID,
                       targetid = patch_edges[1]);
     EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.connect");
     first = 1;
    }
   else
    {
     stat_OM = om$send(msg = message Root.connect(to_comm_edge, 0,
                             edges[split_num-1], OM_Gw_current_OS,
                             to_comm_edge, 0),
                       senderid = NULL_OBJID,
                       targetid = patch_edges[1]);
     EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.connect");
     last = split_num - 1;
    }
   if (reverse)
    {
     stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                             EMED_REVERSE_CONNECT, EMS_O_ON),
                       senderid = NULL_OBJID,
                       targetid = patch_edges[1]);
     EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.EMset_props");
     EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }
  }

 j = 0;

 for (i=first; i<last; i++)
  {
   stat_OM = om$send(msg = message Root.connect(to_comm_edge, 0,
                           edges[i], OM_Gw_current_OS,
                           to_comm_edge, 0),
                     senderid = NULL_OBJID,
                     targetid = full_edge[j]);
   EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.connect");

   if (reverse)
    {
     stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                             EMED_REVERSE_CONNECT, EMS_O_ON),
                       senderid = NULL_OBJID,
                       targetid = full_edge[j]);
     EMomerr_hndlr(stat_OM, wrapup, "EMcon_spl_ed.EMset_props");
     EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }
   j++;
  }

wrapup:
  	
   return(stat_OM);
}
end implementation EMSsfsplit;

