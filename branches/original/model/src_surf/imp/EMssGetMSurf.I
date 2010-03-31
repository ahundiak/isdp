/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSerrordef.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "emsdef.h"

from EMSloopset import EMcheck_props;
from EMSloopset import EMget_props;
from EMSboundary import EMget_edges;
from EMSboundary import EMgetsurface_info;

method EMis_surf_modif (
        IGRlong         *EMmsg;       /* completion code */
        IGRshort        option;       /* option for type of operation */
        IGRboolean      *modifiable)  /* TRUE if surface is modifiable
                                          else FALSE
/*  
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
                        - EMS_E_Fail (severe) if failure
                - EMS_E_LoopsetError -- error in loopset method
                - EMS_E_EdgeError -- error in edge method
Assumption

Bugs

History
          NP		08/25/92	Modified for ANSI compliance. Changed 
					"lpset_count" and "c_e_count" to "IGRuint".
          DLB           08/17/88:       Added check for no loopset for
                                        face ops.
          gupta         05/04/87:       design date

Algorithm
      
      This method will find out if I (surface) am modifiable for
      certain local operations and accordingly set the boolean
      'modifiable' to TRUE or FALSE. The various local operation
      options are
      EMS_LIFT_FACE
      EMS_LIFT_EDGE
      EMS_LIFT_VERTEX
      EMS_SPLIT_SURFACE
      EMS_MOVE_FACE
  
      for the move face operations, it will check to see, if myself
      along with all my adjacent surfaces have natural loopset (no
      imposed boundaries). If so then I am modifiable. For the rest of
      the operations, it will just check, if I have a natural loopset.
      If so, then I am modifiable
*/

{
  IGRlong                         stat_OM, msg;
  IGRushort               ls_prop, lp_prop, ed_prop;
  IGRushort               test_options;
  IGRint                          j, surf_edge_num;
  IGRint                          arr_size;
  IGRuint 		 lpset_count, c_e_count;
  GRobjid                         comm_surf;
  struct GRid                     *surf_edges;
  OM_S_CHANSELECT                 to_comm_edge, to_loopset;

/* ------------------------------------------------------------- */

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  surf_edge_num = arr_size = 0;

  switch (option)
   {
    case EMS_LIFT_FACE:

         break;
    
    case EMS_LIFT_EDGE:
    case EMS_LIFT_VERTEX:
    case EMS_SPLIT_SURFACE:
 
     /* channel selectors */
  
     stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
     if (! (1 & stat_OM)) goto wrapup;

     *modifiable = TRUE;

     stat_OM = om$get_channel_count(object = me,
                                    p_chanselect = &to_loopset,
                                    count = &lpset_count);
     if (! (1 & stat_OM)) goto wrapup;                                    

     if (!lpset_count) break;

     stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_comm_edge);
     if (! (1 & stat_OM)) goto wrapup;

     ls_prop = EMLS_NATURAL | EMLS_NONMODIFIABLE;
     lp_prop = NULL;
     ed_prop = NULL;

     stat_OM = om$send(msg=message EMSloopset.EMcheck_props(&msg,
                           &ls_prop, &lp_prop, &ed_prop),
                       p_chanselect = &to_loopset);
     EMomerr_hndlr(stat_OM, wrapup, "EMssgetmsurf.EMcheck_props");
     EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_LoopsetError, wrapup);

     stat_OM = om$send(msg=message EMSloopset.EMget_props(&msg, &ls_prop),
                       p_chanselect = &to_loopset);
     EMomerr_hndlr(stat_OM, wrapup, "EMssgetmsurf.EMget_props");
     EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_LoopsetError, wrapup);

     if ((ls_prop & EMLS_NONMODIFIABLE))
         *modifiable = FALSE;
     break;

    case EMS_MOVE_FACE:
  
     /* channel selectors */
  
     stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
     if (! (1 & stat_OM)) goto wrapup;

     stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_comm_edge);
     if (! (1 & stat_OM)) goto wrapup;

     *modifiable = TRUE;
   
     ls_prop = EMLS_NATURAL | EMLS_NONMODIFIABLE;
     lp_prop = NULL;
     ed_prop = NULL;

     stat_OM = om$send(msg=message EMSloopset.EMcheck_props(&msg,
                           &ls_prop, &lp_prop, &ed_prop),
                       p_chanselect = &to_loopset);
     EMomerr_hndlr(stat_OM, wrapup, "EMssgetmsurf.EMcheck_props");
     EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_LoopsetError, wrapup);

     stat_OM = om$send(msg=message EMSloopset.EMget_props(&msg, &ls_prop),
                       p_chanselect = &to_loopset);
     EMomerr_hndlr(stat_OM, wrapup, "EMssgetmsurf.EMget_props");
     EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_LoopsetError, wrapup);

     if ((ls_prop & EMLS_NONMODIFIABLE))
       {
         *modifiable = FALSE;
         break;
       } 
     /* get the edge ids */

     stat_OM = om$send(msg = message EMSboundary.EMget_edges(&msg,
                             MAXINT, EMS_OPT_NONDEG_NONSEAM, &surf_edges, 
                             &arr_size, &surf_edge_num),
                       p_chanselect = &to_loopset);
     EMomerr_hndlr(stat_OM, wrapup, "EMssgetmsurf.EMget_edges");
     EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

     for (j=0; j<surf_edge_num; j++)
      {
       stat_OM = om$get_channel_count(objid = surf_edges[j].objid,
                                      p_chanselect = &to_comm_edge,
                                      count = &c_e_count);
       if (! (1 & stat_OM)) goto wrapup;
       
       if (c_e_count)
        {
         stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                                 (&msg,&comm_surf,NULL),
                           senderid = surf_edges[j].objid,
                           p_chanselect = &to_comm_edge);
         EMomerr_hndlr(stat_OM, wrapup, "EMssgetmsurf.EMgetsurf_info");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

         ls_prop = EMLS_NATURAL | EMLS_NONMODIFIABLE;
         lp_prop = NULL;
         ed_prop = NULL;

         stat_OM = om$send(msg=message EMSloopset.EMcheck_props(&msg,
                               &ls_prop, &lp_prop, &ed_prop),
                           senderid = comm_surf,
                           p_chanselect = &to_loopset);
         EMomerr_hndlr(stat_OM, wrapup, "EMssgetmsurf.EMcheck_props");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_LoopsetError, wrapup);

         stat_OM = om$send(msg = message EMSloopset.EMget_props(&msg,
                                 &ls_prop),
                           senderid = comm_surf,
                           p_chanselect = &to_loopset);
         EMomerr_hndlr(stat_OM, wrapup, "EMssgetmsurf.EMget_props");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_LoopsetError, wrapup);
 
         if ((ls_prop & EMLS_NONMODIFIABLE))
           {
             *modifiable = FALSE;
             break;
           }
        }
     }
     break;
   } /* switch */

wrapup:

  return(stat_OM);
}
end implementation EMSsubbs;
