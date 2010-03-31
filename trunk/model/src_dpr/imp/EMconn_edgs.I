/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslsplit;

#include "EMS.h"
/*#include "grdef.h"*/
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "OMmacros.h"

from EMSedge import EMset_props;

IGRboolean EMconn_edges (rc, num_surf, option, edge0, edge1, 
                         pch_edge_ids, comm_edge, reverse) 

 IGRlong *rc;
 IGRint num_surf, option;
 GRobjid *edge0, *edge1;
 GRobjid *pch_edge_ids[], *comm_edge;
 IGRboolean *reverse;
{

 IGRchar  errmsg[EMMAXERRMSG_LEN];
 IGRlong  stat_OM;
 IGRlong  msg;
 IGRint   i, j;
 OM_S_CHANSELECT to_comm_edge;

 *rc = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 strcpy (errmsg, "EMconn_edges");

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_comm_edge);
 EMomerr_hndlr(stat_OM, wrapup, errmsg);

 switch (option)
  {
   case 0:
          if (edge0[0] != NULL_OBJID)
           {
            if (reverse[0])
             {
              for (i=0; i<num_surf; i++)
               {
                for (j=num_surf-1; j>=0; j--)
                 {
                  stat_OM = om$send(msg = message Root.connect(
                                          to_comm_edge, 0, edge0[i],
                                          OM_Gw_current_OS, to_comm_edge,
                                          0),
                                    senderid = NULL_OBJID,
                                    targetid = pch_edge_ids[j][3]);
                  EMomerr_hndlr(stat_OM, wrapup, errmsg);
                 }
               }
             }
            else
             {
              for (i=0; i<num_surf; i++)
                 {
                  stat_OM = om$send(msg = message Root.connect(
                                          to_comm_edge, 0, edge0[i],
                                          OM_Gw_current_OS, to_comm_edge,
                                          0),
                                    senderid = NULL_OBJID,
                                    targetid = pch_edge_ids[i][3]);
                  EMomerr_hndlr(stat_OM, wrapup, errmsg);
                 }
             }
           }

          if (edge1[0] != NULL_OBJID)
           {
            if (reverse[1])
             {
              for (i=0; i<num_surf; i++)
               {
                for (j=num_surf-1; j>=0; j--)
                 {
                  stat_OM = om$send(msg = message Root.connect(
                                          to_comm_edge, 0, edge1[i],
                                          OM_Gw_current_OS, to_comm_edge,
                                          0),
                                    senderid = NULL_OBJID,
                                    targetid = pch_edge_ids[j][1]);
                  EMomerr_hndlr(stat_OM, wrapup, errmsg);
                 }
               }
             }
            else
             {
              for (i=0; i<num_surf; i++)
                 {
                  stat_OM = om$send(msg = message Root.connect(
                                          to_comm_edge, 0, edge0[i],
                                          OM_Gw_current_OS, to_comm_edge,
                                          0),
                                    senderid = NULL_OBJID,
                                    targetid = pch_edge_ids[i][1]);
                  EMomerr_hndlr(stat_OM, wrapup, errmsg);
                 }
             }
           }

          if (comm_edge[0] != NULL_OBJID)
           for (i=0; i<num_surf; i++)
            {
             if (i == 0)
              {
               stat_OM = om$send(msg = message Root.connect(
                                       to_comm_edge, 0, comm_edge[0],
                                       OM_Gw_current_OS, to_comm_edge,
                                       0),
                                 senderid = NULL_OBJID,
                                 targetid = pch_edge_ids[i][0]);
               EMomerr_hndlr(stat_OM, wrapup, errmsg);
              }
             if (i == num_surf-1)
              {
               stat_OM = om$send(msg = message Root.connect(
                                       to_comm_edge, 0, comm_edge[1],
                                       OM_Gw_current_OS, to_comm_edge,
                                       0),
                                 senderid = NULL_OBJID,
                                 targetid = pch_edge_ids[i][2]);
               EMomerr_hndlr(stat_OM, wrapup, errmsg);
              }
             else
              {
               stat_OM = om$send(msg = message Root.connect(
                                      to_comm_edge, 0, pch_edge_ids[i][2],
                                       OM_Gw_current_OS, to_comm_edge,
                                       0),
                                 senderid = NULL_OBJID,
                                 targetid = pch_edge_ids[i+1][0]);
               EMomerr_hndlr(stat_OM, wrapup, errmsg);

               stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                       EMED_REVERSE_CONNECT, EMS_O_ON),
                                 senderid = NULL_OBJID,
                                 targetid = pch_edge_ids[i][2]);
               EMomerr_hndlr(stat_OM, wrapup, errmsg);
               EMerr_hndlr(EMis_error(msg), *rc,EMS_E_EdgeError,wrapup);

               stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                       EMED_REVERSE_CONNECT, EMS_O_ON),
                                 senderid = NULL_OBJID,
                                 targetid = pch_edge_ids[i+1][0]);
               EMomerr_hndlr(stat_OM, wrapup, errmsg);
               EMerr_hndlr(EMis_error(msg), *rc,EMS_E_EdgeError,wrapup);
              }
            }
            break;

   case 1:
          if (edge0[0] != NULL_OBJID)
           {
            if (reverse[0])
             {
              for (i=0; i<num_surf; i++)
               {
                for (j=num_surf-1; j>=0; j--)
                 {
                  stat_OM = om$send(msg = message Root.connect(
                                          to_comm_edge, 0, edge0[i],
                                          OM_Gw_current_OS, to_comm_edge,
                                          0),
                                    senderid = NULL_OBJID,
                                    targetid = pch_edge_ids[j][0]);
                  EMomerr_hndlr(stat_OM, wrapup, errmsg);
                 }
               }
             }
            else
             {
              for (i=0; i<num_surf; i++)
                 {
                  stat_OM = om$send(msg = message Root.connect(
                                          to_comm_edge, 0, edge0[i],
                                          OM_Gw_current_OS, to_comm_edge,
                                          0),
                                    senderid = NULL_OBJID,
                                    targetid = pch_edge_ids[i][0]);
                  EMomerr_hndlr(stat_OM, wrapup, errmsg);
                 }
             }
           }

          if (edge1[0] != NULL_OBJID)
           {
            if (reverse[1])
             {
              for (i=0; i<num_surf; i++)
               {
                for (j=num_surf-1; j>=0; j--)
                 {
                  stat_OM = om$send(msg = message Root.connect(
                                          to_comm_edge, 0, edge1[i],
                                          OM_Gw_current_OS, to_comm_edge,
                                          0),
                                    senderid = NULL_OBJID,
                                    targetid = pch_edge_ids[j][2]);
                  EMomerr_hndlr(stat_OM, wrapup, errmsg);
                 }
               }
             }
            else
             {
              for (i=0; i<num_surf; i++)
                 {
                  stat_OM = om$send(msg = message Root.connect(
                                          to_comm_edge, 0, edge0[i],
                                          OM_Gw_current_OS, to_comm_edge,
                                          0),
                                    senderid = NULL_OBJID,
                                    targetid = pch_edge_ids[i][2]);
                  EMomerr_hndlr(stat_OM, wrapup, errmsg);
                 }
             }
           }

          if (comm_edge[0] != NULL_OBJID)
           for (i=0; i<num_surf; i++)
            {
             if (i == 0)
              {
               stat_OM = om$send(msg = message Root.connect(
                                       to_comm_edge, 0, comm_edge[0],
                                       OM_Gw_current_OS, to_comm_edge,
                                       0),
                                 senderid = NULL_OBJID,
                                 targetid = pch_edge_ids[i][3]);
               EMomerr_hndlr(stat_OM, wrapup, errmsg);
              }
             if (i == num_surf-1)
              {
               stat_OM = om$send(msg = message Root.connect(
                                       to_comm_edge, 0, comm_edge[1],
                                       OM_Gw_current_OS, to_comm_edge,
                                       0),
                                 senderid = NULL_OBJID,
                                 targetid = pch_edge_ids[i][1]);
               EMomerr_hndlr(stat_OM, wrapup, errmsg);
              }
             else
              {
               stat_OM = om$send(msg = message Root.connect(
                                      to_comm_edge, 0, pch_edge_ids[i][1],
                                       OM_Gw_current_OS, to_comm_edge,
                                       0),
                                 senderid = NULL_OBJID,
                                 targetid = pch_edge_ids[i+1][3]);
               EMomerr_hndlr(stat_OM, wrapup, errmsg);

               stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                       EMED_REVERSE_CONNECT, EMS_O_ON),
                                 senderid = NULL_OBJID,
                                 targetid = pch_edge_ids[i][1]);
               EMomerr_hndlr(stat_OM, wrapup, errmsg);
               EMerr_hndlr(EMis_error(msg), *rc,EMS_E_EdgeError,wrapup);

               stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                                       EMED_REVERSE_CONNECT, EMS_O_ON),
                                 senderid = NULL_OBJID,
                                 targetid = pch_edge_ids[i+1][3]);
               EMomerr_hndlr(stat_OM, wrapup, errmsg);
               EMerr_hndlr(EMis_error(msg), *rc,EMS_E_EdgeError,wrapup);
              }
            }
            break;
 } /* switch */ 
wrapup:
  	
   return(stat_OM);
}
end implementation EMSslsplit;

