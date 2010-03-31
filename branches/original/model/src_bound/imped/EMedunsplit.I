/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method undoes a split opeartion during region
	modifications. The message should be sent to the original edge
	which existed at the begining of the operation and replace_edge
	argument should be set that the objid of that edge.
History
	SM  23-Feb-88   Creation date
       Jack 31-May-93   Initialized old_idx to 0 to fix umr (Purify.)
*/


class implementation EMSedge;

#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsgeteddef.h"
#include "EMStpmacros.h"
#include "EMSutlmacros.h"

%safe
static IGRint EMdelete_edge_and_move_partedges();
%endsafe 

from EMSloop import EMmodify_edge;

method EMunsplityourself(IGRlong *EMmsg;
			 GRobjid *replace_edge)
{
  IGRlong			sts,rc;
  OM_S_CHANSELECT		to_owners,to_edges;
  IGRboolean			update_range = TRUE;
  /*IGRint			EMsend_loops(),EMcount_loops();*/ 
  IGRint			deletable = 0, loop_count = 0;
/*IGRint			EMsend_partedges();*/
  IGRint                        my_count;
  GRobjid			my_replace_edge;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  /* The criteria for deleting an edge are as follows -
     1) If the edge is owned by a new loop it is never deletable.
     2) else if the edge is owned by a split loop it is always deletable
     3) else if it is owned by any loop it is never deletable
     4) else if it is not owned by any loop it is always deletable.
  */

  if(!replace_edge)
   {
     my_replace_edge = my_id;
     replace_edge = &my_replace_edge;
   }

  if(IF_EQ_OBJID(my_id, *replace_edge)) deletable = FALSE;
  else
   {
    IGRushort all_mask = EMLP_SPLIT;
/***************************************************************************
    sts = EMcount_loops(&rc, my_id, &deletable, NULL, all_mask, NULL, NULL);
***************************************************************************/
    sts = ems$count_loops(msg = &rc,
                          sender_edge = my_id,
                          count = &deletable,
                          all_mask = all_mask);
    if(!(1&sts)) goto wrapup;
    if(!deletable)
     {
/***************************************************************************
      sts = EMcount_loops(&rc, my_id, &loop_count, NULL, NULL, NULL, NULL);
***************************************************************************/
      sts = ems$count_loops(msg = &rc,
                            sender_edge = my_id,
                            count = &loop_count);
      if(!(1&sts)) goto wrapup;
      deletable = loop_count ? FALSE : TRUE;
     }
   }

  /* Send the message to my partedges.
  */
/**************************************************************************
  sts = EMsend_partedges(&rc,message EMSedge.EMunsplityourself
				(EMmsg, replace_edge),
			my_id, 0, MAXINT, NULL,NULL,NULL);
**************************************************************************/
  sts = ems$send_partedges(msg = &rc,
                           message = message EMSedge.EMunsplityourself
                                     (EMmsg, replace_edge),
                           sender_edge = my_id,
                           toinx = MAXINT);
                           
                          
  if(!(1&*EMmsg&sts)) goto wrapup;

  /* If I am owned by a new loop then replace myself with the
     replace edge in all the loops that are NOT new and set the
     replace edge to NULL_OBJID so that any other edges like me
     will not do the replacement again. If the replace edge is
     already NULL_OBJID and I am owned by a new loop then disconnect
     myself from all the loops that are not new.
  */
/********************************************************************
  sts = EMcount_loops(&rc, my_id, &my_count, NULL, EMLP_NEW,
			    NULL, NULL);
********************************************************************/
  sts = ems$count_loops(msg = &rc,
                        sender_edge = my_id,
                        count = &my_count,
                        all_mask = EMLP_NEW);
  if(!(1&sts)) goto wrapup;
	
  if(my_count)
   {
     if(IF_NULL_OBJID(*replace_edge))
      {
/****************************************************************************
       sts = EMmake_chanselect (EMSedge_to_owner, &to_owners);
       sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
       sts = EMsend_loops(&rc,message Root.disconnect(to_edges,
			my_id, OM_Gw_current_OS, to_owners),
			my_id, 0, MAXINT, NULL, NULL, EMLP_NEW);
****************************************************************************/
       sts = ems$make_chanselect (
                      chan_label = EMSedge_to_owner,
                      chan_selector = &to_owners);
       sts = ems$make_chanselect (
                      chan_label = EMSbd_owner_to_comps,
                      chan_selector = &to_edges);  
       sts = ems$send_loops(msg = &rc,
                            message = message Root.disconnect(to_edges,
                                      my_id, OM_Gw_current_OS, to_owners),
                            sender_edge = my_id,
                            toinx = MAXINT,
                            none_mask = EMLP_NEW);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
     else if(!IF_EQ_OBJID(my_id, *replace_edge))
      {
/****************************************************************************
       sts = EMsend_loops(&rc,message EMSloop.EMmodify_edge
			(EMmsg, EMS_INS_REPLACE, 1, my_id, replace_edge, 
			 update_range),
			my_id, 0, MAXINT, NULL, NULL, EMLP_NEW);
****************************************************************************/
       sts = ems$send_loops(msg = &rc,
                            message = message EMSloop.EMmodify_edge
                               (EMmsg, EMS_INS_REPLACE, 1, my_id, replace_edge,
                                update_range),
                            sender_edge = my_id,
                            toinx = MAXINT,
                            none_mask = EMLP_NEW);   
       if(!(1&*EMmsg&sts)) goto wrapup;
	*replace_edge = NULL_OBJID;
      }
   }
  else if(deletable)
   {
     /* If I am not owned by a new loop and my id is not same as the
        replace edge then delete myself. 
     */
     IGRboolean	delete_common;

     if(!IF_NULL_OBJID(*replace_edge) && !IF_EQ_OBJID(my_id, *replace_edge))
      {
/****************************************************************************
       sts = EMsend_loops(&rc,message EMSloop.EMmodify_edge
			(EMmsg, EMS_INS_REPLACE, 1, my_id, replace_edge, 
			 update_range),
			my_id, 0, MAXINT, NULL, NULL, EMLP_NEW);
****************************************************************************/
       sts = ems$send_loops(msg = &rc,
                            message = message EMSloop.EMmodify_edge
                            (EMmsg, EMS_INS_REPLACE, 1, my_id, replace_edge,
                             update_range),
                            sender_edge = my_id,
                            toinx = MAXINT,
                            none_mask = EMLP_NEW);  
       if(!(1&*EMmsg&sts)) goto wrapup;
       *replace_edge = NULL_OBJID;
      }

     delete_common = ME.EMSedge->ed_props & EMED_SEAM ? FALSE : TRUE;

     sts = EMdelete_edge_and_move_partedges(EMmsg, my_id, delete_common);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
   }

wrapup:
   EMWRAPUP(*EMmsg,sts,"In EMSedge.EMunsplityourself")
   return(sts);
}



static IGRint EMdelete_edge_and_move_partedges (EMmsg, edge_to_delete, 
						delete_common)
  IGRlong	*EMmsg;
  GRobjid	edge_to_delete;
  IGRboolean	delete_common;
{
  IGRlong		sts, rc;
  IGRint		count, i, old_idx = 0, new_idx = 0;
  OM_S_CHANSELECT       to_geom, to_owners, to_common;
  GRobjid		parent, replace_edge;
  GRobjid		splitobj[2];
  IGRushort 	split = NULL;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
/******************************************************************
  sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common);
  sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_geom);
******************************************************************/
  sts = ems$make_chanselect (
                 chan_label = EMSedge_to_common_edge,
                 chan_selector = &to_common);
  sts = ems$make_chanselect (
                 chan_label = EMSbd_owner_to_comps,
                 chan_selector = &to_geom);  
  if(!(1&sts)) goto wrapup;

  sts = om$send(msg=message EMSboundary.EMget_objid
					(EMmsg, &replace_edge),
				  senderid = edge_to_delete, 
				  p_chanselect = &to_geom);
  if(!(1&*EMmsg&sts)) goto wrapup;
  if(IF_NULL_OBJID(replace_edge))	
    goto wrapup;
/************************************************************************
  sts = EMcount_partedges(&rc,edge_to_delete,&count,NULL,NULL,NULL,NULL);
************************************************************************/
  sts = ems$count_partedges(
                        msg = &rc,
                    sender_edge = edge_to_delete,
                          count = &count);  
  if(!(1&sts)) goto wrapup;

  if(count)
   {
/********************************************************************
     sts = EMmake_chanselect (EMSedge_to_owner, &to_owners);
********************************************************************/
     sts = ems$make_chanselect (
                    chan_label = EMSedge_to_owner,
                    chan_selector =  &to_owners);
     if(!(1&sts)) goto wrapup;
     sts = om$get_index(objid_c = replace_edge, p_chanselect = &to_owners, 
			objid = edge_to_delete, indexaddr = (OMuint *)&old_idx);
     if(!(1&sts)) goto wrapup;
   }

  new_idx = old_idx + count - 1;

  for(i=count-1;i>=0;i--)
   {
     /* Disconnect the partedge from edge_to_delete.
     */
/**************************************************************************
     sts = EMsend_partedges(&rc,message EMSboundary.EMget_objid
			(EMmsg,&parent),
			edge_to_delete,i,i, NULL,NULL,NULL);
**************************************************************************/
     sts = ems$send_partedges(msg = &rc,
                              message = message EMSboundary.EMget_objid
                                        (EMmsg,&parent),
                              sender_edge = edge_to_delete,
                              frominx = i,
                              toinx = i);
 
     if(!(1&*EMmsg&sts)) goto wrapup;
     sts = om$send(msg=message Root.disconnect(to_geom,edge_to_delete,
			OM_Gw_current_OS,to_owners), 
			senderid = edge_to_delete, targetid = parent);
     if(!(1&sts)) goto wrapup;

     /* Connect the partedge to the replace edge.
     */
     sts = om$send(msg=message Root.connect
	       (to_geom, new_idx--, replace_edge, OM_Gw_current_OS, 
		to_owners,NULL),
			senderid = replace_edge, targetid = parent);
    if(!(1&sts)) goto wrapup;
   }


  /* If the edge_to_delete is being deleted, then its common edge should
     also be deleted.
  */
  if(delete_common)
   {
     GRobjid com_edid;

     com_edid = NULL_OBJID;
     sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &com_edid), 
				senderid = edge_to_delete, 
				p_chanselect = &to_common);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(!IF_NULL_OBJID(com_edid))
      {
/*************************************************************************
       sts = EMcount_loops(&rc, com_edid, &count, NULL, NULL, NULL, NULL);
*************************************************************************/
       sts = ems$count_loops(msg = &rc,
                             sender_edge = com_edid,
                             count = &count);  
       if(!(1&sts)) goto wrapup;
       if(!count)
	 sts = EMdelete_edge_and_move_partedges(EMmsg, com_edid, FALSE);
      }
   }

  /* before deleting the edge delete its split objects if any, because this
     edge is the only way to get to those split objects.
  */

  split = NULL;
     
  sts = om$send(msg = message EMSedge.EMissplit(EMmsg, &split, splitobj), 
		targetid = edge_to_delete, senderid = edge_to_delete);
  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

  if(split & EMSedge_BeginSplit)
   {
    sts = om$send(msg = message Root.delete(TRUE), targetid = splitobj[0], 
			senderid = splitobj[0]);
    EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
   }

  if(split & EMSedge_EndSplit)
   {
    sts = om$send(msg = message Root.delete(TRUE), targetid = splitobj[1], 
			senderid = splitobj[1]);
    EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
   }

  sts = om$send(msg = message EMSedge.EMset_props
			(EMmsg, EMED_SUBORDINATE, EMS_O_OFF), 
		senderid = edge_to_delete, p_chanselect = &to_common);
		
  sts = om$send(mode=OM_e_wrt_message,msg=message Root.delete(TRUE),
			senderid = edge_to_delete, targetid=edge_to_delete);
			
wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSedge.EMdelete_edge_and_move_partedges");
  return(sts);
}

end implementation EMSedge;
