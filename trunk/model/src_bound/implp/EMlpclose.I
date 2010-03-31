/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method closes an open loop, maintaining the consistency in the
  direction of its edges. It makes use of the split objects which know
  the appropriate edges(and assumes that the splits are already in place
  with proper connections).
	A flag is returned telling whether the loop was closed (TRUE) or 
  was deleted (FALSE). When a surface has multiple open loops, then during
  closure of some, the other open loops may get used up. When such loops 
  get this message they determine that their aim in life has already been 
  achieved and therefore delete themselves. This flag delivers the news 
  to the caller.

Assumption
	The necessary edges are already split and the split objects
  (splitvertices) are in place with proper edge connections.
	It is also assumed that even if an edge is shared by multiple loops
  only one loop is active at a time. The loop getting this message(open loop)
  is not yet active. After the closing goes through ok, the caller should
  make it active if necessary, taking care of the fact that an edge is
  owned only by one active loop at any given time.

History
	SM	03/05/87	Creation date
	SM	16-Dec-87	If the topological splits are wrong, the
				method used to go into infinite loop in an
				attempt to close the loop (which will never
				happen if splits are wrong.) Fixed this by
				doing the following -
				If the loop tries to connect a edge which
				it has already connected once, it errors
				out. The error code will be
				EMS_E_IntersectOrient.
	SM	30-Dec-87	Instead of checking the EMLP_OPEN bit
				and attempt is made to close the loop
				unconditionally. If the loop is closed
				and has no splits then the first edge
				that it obtains is the goal edge and the
				process terminates. This enables closing
				of geometrically closed loops which need
				to be looked at as open, topologically.
	SM	08-Aug-88	After the loop is closed, avoid the closure
				check during initialization of that loop
				and always make loop property as closed.
	SM	07-Sep-88	Instead sending message 'EMgivenestinfo'
				initialize the nesting structure here
				itself.
	SS      26-Oct-90       On error condition for IntersectOrient
                                (next_edge is invalid), check if the loop
                                props for (OPEN/CLOSE) need to be updated. If
                                so, update the props and repeat the iteration.
                                If the condition has not improved error out.
        NP      05-May-92       Added function calls to time this method.
	AIC	28 Apr 93	Fixed ems$send_loops call, removed
				compiler warnings, and removed EMS.h.
				Compiler warning was that idx was
				potentially being accessed without
				being uninitialized.
*/
class implementation EMSloop;

#include "emsdef.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsgeteddef.h"
#include "emslpinitdef.h"
#include "timerdef.h"
#include "EMStpmacros.h"
#include "EMSutlmacros.h"

from EMSloopset import EMnesting,EMtreemod;
from EMSedge import EMissplit;

extern IGRboolean _use_timers;

method EMcloseyourself( IGRlong *EMmsg;
			GRobjid *loopset;IGRboolean *closed;
			struct EMSpartolbasis *partolbasis)
{
   IGRboolean 		second_try, nxt_edge_from_loop;
   IGRint		idx = -1;
   IGRlong              sts,rc;
   OMuint               lp_count;
   IGRint		count;
   OM_S_CHANSELECT      to_edges,to_owners,to_split_edges;
   GRobjid		goal_edge,nxt_edge,last_edge,split_obj[2];
   IGRboolean           reversed;
   IGRushort	props;
   /*IGRint		EMsend_loops(),EMcount_loops();*/

   if (_use_timers)
     start_timer (T_EMCLOSEYOURSELF);

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   to_edges.type = OM_e_addr;
   to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;
/***************************************************************************
   sts = EMmake_chanselect (EMSedge_to_owner, &to_owners);
***************************************************************************/
   sts = ems$make_chanselect (
                   chan_label = EMSedge_to_owner,
                   chan_selector = &to_owners);  
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
/***************************************************************************
   sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_split_edges);
***************************************************************************/
   sts = ems$make_chanselect (
                   chan_label = EMSbd_owner_to_comps,
                   chan_selector = &to_split_edges);  
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* If I am used by 2 loops then delete myself */
      
   sts = om$send(msg=message EMSboundary.EMget_objid(EMmsg,&goal_edge),
                       p_chanselect =&to_edges,from=NULL,to=NULL);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
/**************************************************************************
   sts = EMcount_loops(&rc,goal_edge,&count,NULL,NULL,NULL,NULL);
**************************************************************************/
   sts = ems$count_loops(msg = &rc,
                         sender_edge = goal_edge,
                         count = &count);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   /* start timer for create loop */
   if (_use_timers)
    start_timer (T21_CREATE_LOOP);

   if(count==2) 
    {
      *closed = FALSE;
      sts = om$send(mode=OM_e_wrt_message,msg=message Root.delete(TRUE),
			targetid=my_id);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
    }
    else
    {
      *closed = TRUE;
      sts = om$get_channel_count(object=me,p_chanselect=&to_edges,
                                count=&lp_count);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

      reversed = ME.EMSloop->lp_props & EMLP_REVERSED;
      sts = om$send(msg=message EMSboundary.EMget_objid
				(EMmsg,&last_edge),
			p_chanselect=&to_edges,from=lp_count-1,to=lp_count-1);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

      second_try = FALSE;
      while(TRUE)
       {
	  sts = om$send(msg=message EMSedge.EMissplit(EMmsg,&props,split_obj),
				targetid= last_edge);
	  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

	  /* If my last edge is split at the end and I am not reversed then 
	     get the next connectable edge from the last edge's end split 
	     vertex.
	  */
          nxt_edge_from_loop = FALSE;
	  if((props & EMSedge_EndSplit)&&(!reversed))
	   {
	      sts = om$send(msg=message EMSboundary.EMget_objid
				(EMmsg,&nxt_edge),
  			    senderid=split_obj[END],
			    p_chanselect=&to_split_edges,
			    from=OUTGOING,to=OUTGOING);
	      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	      sts = om$send(msg=message Root.delete(TRUE),
				targetid = split_obj[END]);
	      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
   	   }

	  /* If my last edge is split at the begining and I am reversed then 
	     get the next connectable edge from the last edge's begin split 
	     vertex.
	  */
   	  else if((props & EMSedge_BeginSplit)&&(reversed))
    	   {
	      sts = om$send(msg=message EMSboundary.EMget_objid
				(EMmsg,&nxt_edge),
  			    senderid=split_obj[BEGIN],
			    p_chanselect=&to_split_edges,
			    from=INCOMING,to=INCOMING);
	      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	      sts = om$send(msg=message Root.delete(TRUE),
				targetid = split_obj[BEGIN]);
	      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
    	   }

	  /* If my last edge is not split then get the next connectable edge 
	     from its currently active loop. If the count of ALL the loops 
	     that the edge is connected to is dumcount then the next edge is 
	     to be obtained from the second last loop.
	  */
   	  else
    	   {
	     IGRint dumcount;
	 
             nxt_edge_from_loop = TRUE;
/****************************************************************************
	     sts = EMcount_loops(&rc,last_edge,&dumcount,NULL,NULL,NULL,NULL);
****************************************************************************/
             sts = ems$count_loops(msg = &rc,
                                   sender_edge = last_edge,
                                   count = &dumcount);
 	     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

	     idx = (dumcount < 2) ? 0 : dumcount-2;
	     if(reversed)
/****************************************************************************
	       sts = EMsend_loops(&rc,message EMSloop.EMnext_edge
		      (EMmsg, EMGetEd_Previous, last_edge, &nxt_edge),
		      last_edge, idx, idx, NULL, NULL, NULL);
****************************************************************************/
               sts = ems$send_loops(
                               msg = &rc,
                           message = message EMSloop.EMnext_edge
                      (EMmsg, EMGetEd_Previous, last_edge, &nxt_edge),
                           sender_edge = last_edge,
                               frominx = idx,
                                 toinx = idx); 
	     else
/****************************************************************************
	       sts = EMsend_loops(&rc,message EMSloop.EMnext_edge
			(EMmsg, EMGetEd_Next, last_edge, &nxt_edge),
			last_edge, idx , idx, NULL, NULL, NULL);
****************************************************************************/
               sts = ems$send_loops(
                               msg = &rc,
                           message = message EMSloop.EMnext_edge
                      (EMmsg, EMGetEd_Next, last_edge, &nxt_edge),
                           sender_edge = last_edge,
                               frominx = idx,
                                 toinx = idx);
	     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	   }
	
          if( IF_EQ_OBJID(goal_edge,nxt_edge) ) break;

	  if( (sts = om$is_objid_valid(objid = nxt_edge)) != OM_S_SUCCESS)
           {
            if (nxt_edge_from_loop && !second_try)
             {
/***************************************************************************
	       sts = EMsend_loops(&rc,message EMSloop.EMlpinit
		      (EMmsg, NULL, partolbasis, 
                       EMLpInit_IgnoreInProps | EMLpInit_NoRange |
                       EMLpInit_NoLoopType),
		      last_edge, idx, idx, NULL, NULL, NULL);
***************************************************************************/
               sts = ems$send_loops(
                               msg = &rc,
                            message = message EMSloop.EMlpinit
                      (EMmsg, NULL, partolbasis,
                       EMLpInit_IgnoreInProps | EMLpInit_NoRange |
                       EMLpInit_NoLoopType),
                            sender_edge = last_edge,
                               frominx = idx,
                                  toinx = idx);    
               EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
               second_try = TRUE;
               continue;
             }
            else
             {sts = OM_S_SUCCESS; *EMmsg = EMS_E_IntersectOrient; goto wrapup;}
           }
		
	  /* connect the new edge to me. If the new edge is already connected 
	     to me then error out. This condition indicates wrong split 
	     connections and screwed up topology.
	  */
	     sts = om$is_objid_on_channel(object_c = me, 
					  p_chanselect = &to_edges, 
					  objid = nxt_edge);
	     if(sts == OM_S_SUCCESS)
	      {*EMmsg = EMS_E_IntersectOrient; goto wrapup;}
	     else sts = OM_S_SUCCESS;
	
             sts = om$send(msg=message Root.connect(to_owners,lp_count,my_id,
                         OM_Gw_current_OS,to_edges,MAXINT),
	                  targetid = nxt_edge);
             EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);
             lp_count++;
	     last_edge = nxt_edge;

      } /* while(TRUE) */

/* since I was closed successfully, set my bit value */

      ME.EMSloop->lp_props &= ~EMLP_OPEN;

    } /* if count !=2 */

  

  /* stop timer for create loop */
  if (_use_timers)
   stop_timer (T21_CREATE_LOOP, FALSE, "");


  /* start timer for create loop */
  if (_use_timers)
   start_timer (T21_NEST_LOOP);

  if(*closed)
   {

/* Send a initialize message to myself.
   This will update my range box and set my type based on my direction. Skip
   the geometrical check between end points for closure property of the loop
   and always turn the EMLP_OPEN bit off.
*/
   ME.EMSloop->lp_props &= ~EMLP_OPEN;
   sts = om$send(msg=message EMSloop.EMlpinit
		(EMmsg, ME.EMSloop->lp_props, partolbasis,
		 EMLpInit_NoClosureTest), targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

/* If the caller has specified a loopset, then put myself into its looptree
*/
   if(loopset)
    {
      struct EMSnest_info	nesting;

      nesting.loopid = my_id;
      nesting.lp_props = ME.EMSloop->lp_props;
      nesting.parent = NULL_OBJID;
      nesting.parent_props = NULL;
      OM_BLOCK_MOVE(ME.EMSloop->range, nesting.range, 4 * sizeof(IGRdouble));

      sts = om$send(msg=message EMSloopset.EMnesting
				(EMmsg,&nesting,partolbasis),
			targetid = *loopset);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
      if(IF_EQ_OBJID(*loopset,nesting.parent))
       {
	sts = om$send(msg=message EMSloopset.EMtreemod
			(EMmsg,&nesting,ADD_CHILD,partolbasis),
			targetid = nesting.parent);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }
      else
       {
	sts = om$send(msg=message EMSloop.EMtreemod
			(EMmsg,&nesting,ADD_CHILD,partolbasis),
			targetid = nesting.parent);
	EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
       }

     } /* If loopset */

    }  /* If(*closed) */

   /* stop timer for create loop */
   if (_use_timers)
    stop_timer (T21_NEST_LOOP, FALSE, "");

/* Thus this loop was closed and it lived happily ever after
   (till next intersection)*/
    
wrapup:

   /* stop timer for EMcloseyourself */
   if (_use_timers)
     stop_timer (T_EMCLOSEYOURSELF, FALSE, "");

   EMWRAPUP(*EMmsg,sts,"EMSloop.EMcloseyourself")
   return(sts);
}

end implementation EMSloop;
