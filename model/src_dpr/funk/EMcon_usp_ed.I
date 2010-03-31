/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "EMSbnddef.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"

from EMSedge import EMget_props, 
                    EMset_props;

IGRboolean EMconn_unsplit_edges (EMmsg, num_surf, option, pch_edge_ids,
                                 arr_size,comm_edge_copy,insurf_edge_copy,
                                 uv_closed) 

 IGRlong *EMmsg;
 IGRint num_surf, option;
 GRobjid (*pch_edge_ids)[4];
 IGRint arr_size;
 GRobjid *comm_edge_copy, *insurf_edge_copy;
 IGRboolean *uv_closed;
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

     This method merely connects the edges of the split surfaces
     which are not related to outside surfaces (A). The split surface
     edges on the extreme(B) end are also connected to their counterparts.
     Also if the split surfaces are closed, the process of splitting
     the surface will not result in splitting the common edges and 
     so these edges(C) of the split surfaces are also connected.

                 C       C    C    C
                ---     ---  ---  ---
                | |     | |  | |  | |
             B->| |<-A->| |  | |  | |<-B
                | |     | |  | |  | |
                ---     ---  ---  ---
                 C       C    C    C 

*/

 IGRlong               stat_OM, msg;
 IGRint                i;
 IGRushort     edge_prop;
 OM_S_CHANSELECT       to_comm_edge;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_comm_edge);
 EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.make_chanselect");

 switch (option)
  {   
   case 0:
          if (uv_closed[0])
           {
            stat_OM = om$send(msg = message Root.connect(
                                    to_comm_edge, 0, pch_edge_ids[0][0],
                                    OM_Gw_current_OS, to_comm_edge,
                                    0),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[num_surf-1][2]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.connect");

            stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                    EMED_REVERSE_CONNECT, EMS_O_ON),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[0][0]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
            EMerr_hndlr(EMis_error(msg),*EMmsg,EMS_E_EdgeError,wrapup);

            stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                    EMED_REVERSE_CONNECT, EMS_O_ON),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[num_surf-1][2]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
            EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
           }
          else
           {
            for (i=0; i<arr_size; i++)
             {
              if (comm_edge_copy[i] != NULL_OBJID)
              {
               stat_OM = om$send(msg = message Root.connect(
                                       to_comm_edge, 0, comm_edge_copy[i],
                                       OM_Gw_current_OS, to_comm_edge,
                                       0),
                                 senderid = NULL_OBJID,
                                 targetid = insurf_edge_copy[i]);
               EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.connect");

               stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                                       &edge_prop),
                                 senderid = NULL_OBJID,
                                 targetid = insurf_edge_copy[i]);
               EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMget_props");
               EMerr_hndlr(EMis_error(msg),*EMmsg,EMS_E_EdgeError,wrapup);

               if (edge_prop & EMED_REVERSE_CONNECT)
                {
                 stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                         EMED_REVERSE_CONNECT, EMS_O_ON),
                                   senderid = NULL_OBJID,
                                   targetid = comm_edge_copy[i]);
                 EMomerr_hndlr(stat_OM,wrapup,"EMcon_usp_ed.EMset_props");
                 EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError,
                             wrapup);
                }
              }
             }
           }

          if (uv_closed[1])
           {
            for (i=0; i<num_surf; i++)
             {
              stat_OM = om$send(msg = message Root.connect(
                                      to_comm_edge, 0, pch_edge_ids[i][1],
                                      OM_Gw_current_OS, to_comm_edge,
                                      0),
                                senderid = NULL_OBJID,
                                targetid = pch_edge_ids[i][3]);
              EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.connect");

              stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                      EMED_REVERSE_CONNECT, EMS_O_ON),
                                senderid = NULL_OBJID,
                                targetid = pch_edge_ids[i][1]);
              EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
              EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);

              stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                      EMED_REVERSE_CONNECT, EMS_O_ON),
                                senderid = NULL_OBJID,
                                targetid = pch_edge_ids[i][3]);
              EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
              EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
             }
           }

          for (i=0; i<(num_surf-1); i++)
           {
            stat_OM = om$send(msg = message Root.connect(
                                    to_comm_edge, 0, pch_edge_ids[i][2],
                                    OM_Gw_current_OS, to_comm_edge,
                                    0),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[i+1][0]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.connect");

            stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                    EMED_REVERSE_CONNECT, EMS_O_ON),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[i][2]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
            EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);

            stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                    EMED_REVERSE_CONNECT, EMS_O_ON),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[i+1][0]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
            EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
           }
          break;

   case 1:
          if (uv_closed[1])
           {
            stat_OM = om$send(msg = message Root.connect(
                                    to_comm_edge, 0, pch_edge_ids[0][3],
                                    OM_Gw_current_OS, to_comm_edge,
                                    0),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[num_surf-1][1]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.connect");

            stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                    EMED_REVERSE_CONNECT, EMS_O_ON),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[0][3]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
            EMerr_hndlr(EMis_error(msg),*EMmsg,EMS_E_EdgeError,wrapup);

            stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                    EMED_REVERSE_CONNECT, EMS_O_ON),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[num_surf-1][1]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
            EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
           }
          else
           {
            for (i=0; i<arr_size; i++)
             {
              if (comm_edge_copy[i] != NULL_OBJID)
              {
               stat_OM = om$send(msg = message Root.connect(
                                       to_comm_edge, 0, comm_edge_copy[i],
                                       OM_Gw_current_OS, to_comm_edge,
                                       0),
                                 senderid = NULL_OBJID,
                                 targetid = insurf_edge_copy[i]);
               EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.connect");

               stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                                       &edge_prop),
                                 senderid = NULL_OBJID,
                                 targetid = insurf_edge_copy[i]);
               EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMget_props");
               EMerr_hndlr(EMis_error(msg),*EMmsg,EMS_E_EdgeError,wrapup);

               if (edge_prop & EMED_REVERSE_CONNECT)
                {
                 stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                         EMED_REVERSE_CONNECT, EMS_O_ON),
                                   senderid = NULL_OBJID,
                                   targetid = comm_edge_copy[i]);
                 EMomerr_hndlr(stat_OM,wrapup,"EMcon_usp_ed.EMset_props");
                 EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError,
                             wrapup);
                }
              }
             }
           }

          if (uv_closed[0])
           {
            for (i=0; i<num_surf; i++)
             {
              stat_OM = om$send(msg = message Root.connect(
                                      to_comm_edge, 0, pch_edge_ids[i][0],
                                      OM_Gw_current_OS, to_comm_edge,
                                      0),
                                senderid = NULL_OBJID,
                                targetid = pch_edge_ids[i][2]);
              EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.connect");

              stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                      EMED_REVERSE_CONNECT, EMS_O_ON),
                                senderid = NULL_OBJID,
                                targetid = pch_edge_ids[i][0]);
              EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
              EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);

              stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                      EMED_REVERSE_CONNECT, EMS_O_ON),
                                senderid = NULL_OBJID,
                                targetid = pch_edge_ids[i][2]);
              EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
              EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
             }
           }

          for (i=0; i<(num_surf-1); i++)
           {
            stat_OM = om$send(msg = message Root.connect(
                                    to_comm_edge, 0, pch_edge_ids[i][1],
                                    OM_Gw_current_OS, to_comm_edge,
                                    0),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[i+1][3]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.connect");

            stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                    EMED_REVERSE_CONNECT, EMS_O_ON),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[i][1]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
            EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);

            stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                    EMED_REVERSE_CONNECT, EMS_O_ON),
                              senderid = NULL_OBJID,
                              targetid = pch_edge_ids[i+1][3]);
            EMomerr_hndlr(stat_OM, wrapup, "EMcon_usp_ed.EMset_props");
            EMerr_hndlr(EMis_error(msg), *EMmsg,EMS_E_EdgeError,wrapup);
           }
          break;

  } /* end swith */

wrapup:
  	
   return(stat_OM);
}
end implementation EMSsfsplit;

