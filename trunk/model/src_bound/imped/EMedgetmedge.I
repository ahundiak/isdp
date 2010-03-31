/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSlmdef.h"
#include "EMSerrordef.h"
#include "emsmacros.h"
#include "OMmacros.h"

from EMSloopset import EMget_props;

method EMis_edge_modif (
        IGRlong    *EMmsg;                /* completion code */
        IGRshort   option,             /* option for type of operation */
                   which_vtx;          /* begin or end vertex */
        IGRboolean *modifiable)        /* TRUE if surface is modifiable
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
	
	  gupta 	06/15/87:	design date

Algorithm
      
      This method will find out if I (edge) am modifiable for
      move operations and accordingly set the boolean
      'modifiable' to TRUE or FALSE. The two operations involved are
 
      EMS_MOVE_EDGE
      EMS_MOVE_VERTEX
  
      for the move edge operation, it will check to see, if all the
      surfaces sharing me and my end points have natural loopsets.
      For vertex, it will check to see if all the surfaces sharing
      the vertex end point are free of non_natural loopsets.
*/

{
  IGRlong                         stat_OM, msg;
  IGRushort               ls_prop, lp_prop, ed_prop;
  IGRboolean                      *right_vtx, opt;
  IGRint                          i, j, num_edge;
  OMuint                          count;
  GRobjid                         *vtx_edges,my_surf,comm_surf,other_surf;
  OM_S_CHANSELECT                 to_common_edge, to_loopset;
  OM_S_OBJECT_LINKAGE             comm_edge_list;
/* ------------------------------------------------------------- */

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  num_edge = 0;
  opt = (which_vtx == 2) ? 1 : 0;  
  *modifiable = TRUE;

  /* channel selectors */

  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  if (! (1 & stat_OM)) goto wrapup;

  to_common_edge.type = OM_e_addr;
  to_common_edge.u_sel.addr = &ME.EMSedge->to_common_edge;

  switch (option)
   {
    case EMS_MOVE_EDGE:

       stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                               (&msg,&my_surf,NULL),
                         targetid = my_id);
       EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, EMS_E_EdgeError,wrapup);

       ls_prop = EMLS_NATURAL | EMLS_NONMODIFIABLE;
       lp_prop = NULL;
       ed_prop = NULL;

       stat_OM = om$send(msg=message EMSloopset.EMcheck_props(&msg,
                             &ls_prop, &lp_prop, &ed_prop),
                         senderid = my_surf,
                         p_chanselect = &to_loopset);
       EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, EMS_E_LoopsetError,
        wrapup);

       stat_OM = om$send(msg = message EMSloopset.EMget_props(&msg,
                               &ls_prop),
                         senderid = my_surf,
                         p_chanselect = &to_loopset);
       EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, EMS_E_LoopsetError,wrapup);
 
       if ((ls_prop & EMLS_NONMODIFIABLE))
         {
           *modifiable = FALSE;
           break;
         }

       stat_OM = om$get_channel_objects (object = me,
                                         p_chanselect = &to_common_edge,
                                         list = &comm_edge_list,
                                         size = 1,
                                         count = &count);
       EMomerr_hndlr(stat_OM,wrapup, "");

       if (count)
        {
         stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                                 (&msg,&comm_surf,NULL),
                           p_chanselect = &to_common_edge);
         EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, EMS_E_EdgeError,wrapup);

         ls_prop = EMLS_NATURAL | EMLS_NONMODIFIABLE;
         lp_prop = NULL;
         ed_prop = NULL;
 
         stat_OM = om$send(msg=message EMSloopset.EMcheck_props(&msg,
                               &ls_prop, &lp_prop, &ed_prop),
                           senderid = comm_surf,
                           p_chanselect = &to_loopset);
         EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, EMS_E_LoopsetError,wrapup);
  
         stat_OM = om$send(msg = message EMSloopset.EMget_props(&msg,
                                 &ls_prop),
                           senderid = comm_surf,
                           p_chanselect = &to_loopset);
         EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, EMS_E_LoopsetError,wrapup);
 
         if ((ls_prop & EMLS_NONMODIFIABLE))
           {
             *modifiable = FALSE;
             break;
           }
        }
       else
        {
         comm_edge_list.S_objid = NULL_OBJID;
        }

       opt = 0;

       for (i=0; i<2; i++)
        {
         num_edge = 0;
         /* get all the edges on various surfaces which is not degenerate
            and shares my xyz vertex point -- begin or end (option) */

         stat_OM = om$send(msg = message EMSedge.EMgetvtxedges(&msg,
                                 EMSvtxedges_nodegenerate,opt,0,
				 &num_edge, &vtx_edges, &right_vtx),
                           targetid = my_id);
         EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, msg,wrapup);

         for (j=0; j<num_edge; j++)
          {
           if (IF_EQ_OBJID(vtx_edges[j],my_id) ||
               IF_EQ_OBJID(vtx_edges[j],comm_edge_list.S_objid))
               continue;
  
           stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                                   (&msg,&other_surf,NULL),
                             targetid = vtx_edges[j]);
           EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, EMS_E_EdgeError,wrapup);


           ls_prop = EMLS_NATURAL | EMLS_NONMODIFIABLE;
           lp_prop = NULL;
           ed_prop = NULL;

           stat_OM = om$send(msg=message EMSloopset.EMcheck_props(&msg,
                                 &ls_prop, &lp_prop, &ed_prop),
                             senderid = other_surf,
                             p_chanselect = &to_loopset);
           EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg,EMS_E_LoopsetError,wrapup);

           stat_OM = om$send(msg = message EMSloopset.EMget_props(&msg,
                                   &ls_prop),
                             senderid = other_surf,
                             p_chanselect = &to_loopset);
           EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg,EMS_E_LoopsetError,wrapup);
 
           if ((ls_prop & EMLS_NONMODIFIABLE))
            {
             *modifiable = FALSE;
             break;
            }
          }
         opt = 1;
        }
       break;

    case EMS_MOVE_VERTEX:

       /* get all the edges on various surfaces which is not degenerate
          and shares my xyz vertex point -- begin or end (option) */

       stat_OM = om$send(msg = message EMSedge.EMgetvtxedges(&msg,
                               EMSvtxedges_nodegenerate,opt,0,
			       &num_edge, &vtx_edges, &right_vtx),
                         targetid = my_id);
       EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, msg,wrapup);

       for (j=0; j<num_edge; j++)
        {
         stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                                 (&msg,&other_surf,NULL),
                           targetid = vtx_edges[j]);
         EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, EMS_E_EdgeError,wrapup);

         ls_prop = EMLS_NATURAL | EMLS_NONMODIFIABLE;
         lp_prop = NULL;
         ed_prop = NULL;

         stat_OM = om$send(msg=message EMSloopset.EMcheck_props(&msg,
                               &ls_prop, &lp_prop, &ed_prop),
                           senderid = other_surf,
                           p_chanselect = &to_loopset);
         EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, EMS_E_LoopsetError,wrapup);

         stat_OM = om$send(msg = message EMSloopset.EMget_props(&msg,
                                 &ls_prop),
                           senderid = other_surf,
                           p_chanselect = &to_loopset);
         EMerr_hndlr(EMSerror(stat_OM&msg), *EMmsg, EMS_E_LoopsetError,wrapup);
 
         if ((ls_prop & EMLS_NONMODIFIABLE))
          {
           *modifiable = FALSE;
           break;
          }
        }
       break;  
   } /* switch */

wrapup:

  return(stat_OM);
}

end implementation EMSedge;
