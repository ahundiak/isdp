/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method propagates the loop type setting process throught the
 loopset. Knowing the loop type of one loop, all other types can therefore
 be set. The boolean flag P_loop tells the loop type of a loop.
	If the sender_obj is on any of the channels of this loop, it will
 not get the message. Also, the message will never reach a loopset.
	If the sender happens to be on any channel and it is intended that
 the toggling message reach it, then a NULL_OBJID should be passed as
 sender_obj.

Assumption
        It is assumed that in a valid loopset, the loop types are toggled.
  A P loop has only C loops nested inside it and a C loop has only P loops
  nested inside it. It is also assumed that if two loops have a coincedent
  edge (i.e if they share an edge) then those edges are connected across
  the common edge channel. The method assumes that all the loops in the
  loopset have been initialized as far as their properties are concerned.

History
	SM	07-Dec-88	Argument change. Made all boolean flags into
				options. Added functionality for exclusive
				existence of adjacent loops.
	SM	03-Feb-88	Send across common edge only on the same
				surface. Do not toggle across surfaces-to
				avoid screwing up a composite.
	SS	01/24/88	Added the no_action, numtogloops, togloops
				arguments
	SM	03/26/87	Creation date.

*/

class implementation EMSloop;

#include "EMS.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSopt.h"
#include <stdio.h>

#define NotOnChan	-1
#define OnChan		 0

#define BUFF_INCR	6

from EMSedge import EMget_props;
from EMSloopset import EMget_loops;

static IGRboolean EMreceived(num, r_loops, loop)
IGRint		num;
GRobjid		*r_loops, loop;
{
 IGRint		i;
 IGRboolean	received = FALSE;

 if(!r_loops) return(FALSE);

 for(i=0; i<num; i++)
  if(IF_EQ_OBJID(r_loops[i], loop)) {received = TRUE; break;}
 return(received);
}

method EMtoggle_type(IGRlong *EMmsg; IGRboolean P_loop;
		      IGRboolean deletable;
		      GRobjid sender_obj;
		      IGRushort options;
		      IGRint *numtogloops; GRobjid **togloops;
		      IGRint *numdelloops; GRobjid **delloops;
		      IGRint *num_loops_received; GRobjid **loops_received)
 {
    IGRlong		sts, rc;
    OM_S_CHANSELECT	to_edges, to_inner,to_outter, to_common;
    IGRboolean		me_p_loop;
    IGRint		i;
    OMuint		count;
    IGRint              outter_index, inner_index;
    IGRboolean		send_inner, send_outter, send_adjacent, no_action, 
                        send_sibs, isseam;
    IGRint		loc_num_loops_received = 0, num_sibs = 0, 
                        sib_bufsize = 0, num_contiguous = 0;
    GRobjid		*loc_loops_received = NULL, *sibs = NULL, 
                        *contiguous = NULL;
    IGRushort	edprops = NULL;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
   send_inner = options & EMTogType_SendInner ? TRUE : FALSE;
   send_outter = options & EMTogType_SendOuter ? TRUE : FALSE;
   send_adjacent = options & EMTogType_SendAdjacent ? TRUE : FALSE;
   send_sibs = options & EMTogType_SendExternalSiblings ? TRUE : FALSE;
   if(send_sibs && (ME.EMSloop->lp_props & EMLP_EXTERNAL))
    options &= ~EMTogType_SendExternalSiblings;

   no_action = options & EMTogType_NoAction ? TRUE : FALSE;
   if(!num_loops_received) num_loops_received = &loc_num_loops_received;
   if(!loops_received) loops_received = &loc_loops_received;

   if(EMreceived(*num_loops_received, *loops_received, my_id))
     goto wrapup;
   else
    {
     if (! ((*num_loops_received) % BUFF_INCR))
      {
       if (! *num_loops_received)
        *loops_received = (GRobjid *) om$malloc (size = BUFF_INCR *
                         sizeof (GRobjid));
       else
        *loops_received = (GRobjid *)om$realloc (ptr =(char *)*loops_received, 
		size = (*num_loops_received + BUFF_INCR) * sizeof (GRobjid));
       EMerr_hndlr (! *loops_received, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
      }
     (*loops_received)[(*num_loops_received)] = my_id;
     (*num_loops_received)++;
    }

   sts = EMmake_chanselect(EMSloop_to_inner, &to_inner);
   sts = EMmake_chanselect(EMSloop_to_outter, &to_outter);
   sts = EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);
   sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common);
      
   me_p_loop = ME.EMSloop->lp_props & EMLP_PLOOP;

/* If I am not of the type which is sent in then reverse myself
*/
    if( (me_p_loop && !P_loop) || (!me_p_loop && P_loop) )
      {
      /*
       * If a toggling action is desired, then send a reverse message
       * to this loop.
       */

      if (! no_action)
        {
        sts = om$send (msg = message EMSloop.EMreverse(EMmsg), 
               targetid = my_id);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
        }

      /*
       * If the list of all the loops that have to be toggled is requested
       * malloc memeory for the buffer if needed and update the output
       * list.
       */

      if (numtogloops && togloops)
        {
	 IGRboolean	present = FALSE;
	 for(i=0; i<*numtogloops; i++)
	  if(IF_EQ_OBJID((*togloops)[i], my_id)) {present = TRUE; break;}
	 if(!present)
	  {
           if (! ((*numtogloops) % BUFF_INCR))
            {
             if (! *numtogloops)
              *togloops = (GRobjid *) om$malloc (size = BUFF_INCR *
                         sizeof (GRobjid));
             else
              *togloops = (GRobjid *)om$realloc (ptr =(char *)*togloops,size = 
                         (*numtogloops + BUFF_INCR) * sizeof (GRobjid));
             EMerr_hndlr (! *togloops, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
            }
           (*togloops)[(*numtogloops)] = my_id;
           (*numtogloops)++;
	  }
        }
      }

     if(deletable && numdelloops && delloops)
      {
	IGRboolean	present = FALSE;
        for(i=0; i<*numdelloops; i++)
	  if(IF_EQ_OBJID((*delloops)[i], my_id)) {present = TRUE; break;}
	 if(!present)
	  {
           if (! ((*numdelloops) % BUFF_INCR))
            {
             if (! *numdelloops)
              *delloops = (GRobjid *) om$malloc (size = BUFF_INCR *
                         sizeof (GRobjid));
             else
              *delloops = (GRobjid *)om$realloc (ptr =(char *)*delloops,size = 
                         (*numdelloops + BUFF_INCR) * sizeof (GRobjid));
             EMerr_hndlr (! *delloops, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
            }
           (*delloops)[(*numdelloops)] = my_id;
           (*numdelloops)++;
	  }
      }


/* Send the toggled loop type across to the common edge's loop. If the
   message came from that loop then do not send.
*/
   if(send_adjacent)
    {
      GRobjid my_edge, com_edge, com_loop, just_sent, my_surf, com_surf;

      sts = om$get_channel_count(object = me, p_chanselect = &to_edges, 
				 count = &count);
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
      just_sent = NULL_OBJID;
      for(i=0; i<count; i++)
       {
	 /* Get objid of my edge */
	 sts = om$send(msg = message EMSboundary.EMget_objid
				(EMmsg, &my_edge), 
			p_chanselect = &to_edges, from = i, to = i);
	 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	
	 sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
				targetid = my_edge);
	 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

	 /* if(edprops & EMED_SEAM) continue; */
	
	 isseam = edprops & EMED_SEAM ? TRUE : FALSE;
	
	 com_edge = NULL_OBJID;
	
	 /* Get objid of my edge's common edge */
	 sts = om$send(msg = message EMSboundary.EMget_objid
				(EMmsg, &com_edge), 
			p_chanselect = &to_common, senderid = my_edge);
	 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	
	 if(IF_NULL_OBJID(com_edge)) continue;
	 
	
	 /* Get objid of common edge's active loop */
	 com_loop = NULL_OBJID;
	 sts = EMsend_loops(&rc, message EMSboundary.EMget_objid
				(EMmsg, &com_loop), com_edge, 0, MAXINT, 
				EMLP_ACTIVE, NULL, NULL);
	 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	 if(EMreceived(*num_loops_received, *loops_received, com_loop))
		continue;

	 /* Send toggled loop type to the common loop if there is one
	    present and if the message had not come from it.
	    If the edge is a seam edge then we might end up sending to the
	    same loop again. Also dont send to the loop to which the message
	    was sent during previous iteration. Do not send the message
	    across surfaces.
	 */
	 if(!IF_NULL_OBJID(com_loop) && !IF_EQ_OBJID(com_loop, sender_obj) &&
	    !IF_EQ_OBJID(com_loop, my_id) && !IF_EQ_OBJID(com_loop, just_sent))
	  {
	    my_surf = com_surf = NULL_OBJID;
	    sts = om$send(msg = message EMSloop.EMgetsurface_info
				(EMmsg, &my_surf, NULL), 
				targetid = my_id);
	    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

	    sts = om$send(msg = message EMSloop.EMgetsurface_info
				(EMmsg, &com_surf, NULL), 
				targetid = com_loop);
	    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	
	    if(IF_EQ_OBJID(my_surf, com_surf))
	     {
	       sts = om$send(msg = message EMSloop.EMtoggle_type
   		     (EMmsg, isseam ? P_loop : !P_loop, 
		      isseam ? deletable : !deletable, my_id, options, 
                        numtogloops, togloops, numdelloops, delloops, 
			num_loops_received, loops_received), 
		targetid = com_loop);
	       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	       just_sent = com_loop;
	     }
	  }
       }
    }

   if(send_inner)
    {
      IGRushort loc_options;

      loc_options = options & (~EMTogType_SendOuter);
      sts = om$get_channel_count(object=me,p_chanselect=&to_inner,
				count=&count);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
      if(count)
       {
         sts = om$get_index(object_c=me,p_chanselect=&to_inner,
		    objid=sender_obj, indexaddr = (OMuint *)&inner_index);
         if(sts==OM_W_NOTONCHAN) { inner_index = NotOnChan;sts=OM_S_SUCCESS;}
         else EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
       }

      /* Send the message to all my inner loops. If I got the message from one
        of my children, don't send to that child again. 
	Since my children have only me as parent set the 'send_outter' flag
	to FALSE when sending down.
      */
      for(i=0;i<count;i++)
       {
         if(i!=inner_index)
          {
	    sts = om$send(msg=message EMSloop.EMtoggle_type
			(EMmsg,!P_loop, deletable, my_id, loc_options, 
			 numtogloops, togloops, numdelloops, delloops, 
			 num_loops_received, loops_received),
		  p_chanselect=&to_inner,from=i,to=i);
	    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
          }
       }
    }
   
   if(send_outter)
    {
      sts = om$is_objid_on_channel(object_c = me,p_chanselect=&to_outter,
				objid=sender_obj);
      if(sts==OM_S_SUCCESS) outter_index = OnChan;
      else {outter_index = NotOnChan; sts = OM_S_SUCCESS;}
	
      /* Send the toggled loop type to my parent. If I have
         got the message from my parent, then don't send to the parent again.
      */
      if(outter_index==NotOnChan)
       {
         if(!(ME.EMSloop->lp_props & EMLP_EXTERNAL))
           sts = om$send(msg=message EMSloop.EMtoggle_type
			(EMmsg,!P_loop, deletable, my_id, options, 
			 numtogloops, togloops, numdelloops, delloops, 
			 num_loops_received, loops_received),
		  p_chanselect=&to_outter);

         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
       }
    }

   /* Propagate the message to external siblings. This processing should
      be done by one external loop only.
   
      All external siblings are kept. If external siblings are contiguous
      (via common edge connection) then the choice is arbitrary. For now
      the first such loop getting the message will be kept. This choice
      can perhaps be improved upon later to make the result more intutive 
      or controllble by the caller.
   */
   if(send_sibs && (ME.EMSloop->lp_props & EMLP_EXTERNAL))
    {
     IGRint depth = 1, i, j, m;
     GRobjid thised, thiscomed, thiscomlp;
     IGRdouble keypt[2], *keyptptr = NULL;

     sts = om$send(msg = message EMSloopset.EMget_loops(EMmsg, EMS_OPT_ALL, 
           &depth, &sibs, NULL, &sib_bufsize, &num_sibs), 
           p_chanselect = &to_outter);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);

     /* Maximum contiguous loops for a sibling will be the total number of
        siblings.
     */
     if(num_sibs)
      {
       contiguous = (GRobjid *) om$malloc(size = num_sibs * sizeof(GRobjid));
       EMerr_hndlr(!contiguous, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }

     for(i=0; i<num_sibs; i++)
      {
       if(IF_EQ_OBJID(sibs[i], my_id)) continue;
       if(EMreceived(*num_loops_received, *loops_received, sibs[i]))
	continue;
       num_contiguous = 0;

       /* How many contiguous loops does this sibling have?
       */
       sts = om$get_channel_count(objid = sibs[i], p_chanselect = &to_edges, 
				 count = &count);
       EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
       for(j=0; j<count; j++)
        {
	 sts = om$send(msg = message EMSboundary.EMget_objid
				(EMmsg, &thised), senderid = sibs[i], 
			p_chanselect = &to_edges, from = j, to = j);
	 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	 thiscomed = NULL_OBJID;
	 sts = om$send(msg = message EMSboundary.EMget_objid
				(EMmsg, &thiscomed), 
			p_chanselect = &to_common, senderid = thised);
	 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
	 if(IF_NULL_OBJID(thiscomed)) continue;
	 
	 thiscomlp = NULL_OBJID;
	 sts = EMsend_loops(&rc, message EMSboundary.EMget_objid
	       (EMmsg, &thiscomlp), thiscomed, 0, MAXINT, 
		EMLP_ACTIVE, NULL, NULL);
	 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	
	 /* If this edge's common edge is in a different loop but on the
	    same surface, then the sibling under consideration is not disjoint.
	 */
	 if(IF_NULL_OBJID(thiscomlp) || IF_EQ_OBJID(thiscomlp, sibs[i])) 
	  continue;
	 else
	  {
	   for(m=0; m<num_sibs; m++)
            if(IF_EQ_OBJID(sibs[m], thiscomlp))
             contiguous[num_contiguous++] = thiscomlp;
	  }
	
        } /* for(j=0; j<count; j++) */

       /* Different type of propagation based on disjointness.
       */
       if(!num_contiguous)
        {
         sts = om$send(msg = message EMSloop.EMtoggle_type(EMmsg, TRUE, FALSE,
               my_id, options, numtogloops, togloops, numdelloops, delloops, 
               num_loops_received, loops_received), targetid = sibs[i]);
	 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
        }
       else
        {
	 IGRdouble mindist = MAXDOUBLE;
         struct EMSptloc_info location;
         GRobjid nstlp = NULL_OBJID;
         struct EMSpartolbasis partol;
         IGRshort mxtyp;
         IGRmatrix mx;

	 /* Take a point inside myself and find the closest sibling out of
	    the contiguous set.
	 */
         contiguous[num_contiguous++] = sibs[i];
         if(!keyptptr)   /* obtained once only */
          {
	   IGRuint callinx = 3;

           EMidmatrix(EMmsg, &mxtyp, mx);
           partol.is_valid = FALSE;
           partol.mattyp = &mxtyp;
           partol.mat = mx;

	   sts = om$send(msg = message EMSloop.EMptinside(EMmsg, &callinx, 
	         &partol, 1, keypt, NULL), targetid = my_id);
	   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	   keyptptr = keypt;
          }
         location.options = NULL;
         for(m=0; m<num_contiguous; m++)
          {
	   sts = om$send(msg = message EMSloop.EMpt_location(EMmsg, keypt, 
	         &location, &partol), targetid = contiguous[m]);
	   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	   if(location.edge[0].nst_pt.dist < mindist)
	    {
	     mindist = location.edge[0].nst_pt.dist;
	     nstlp = contiguous[m];
	    }
          }
         sts = om$send(msg=message EMSloop.EMtoggle_type
	       (EMmsg, P_loop, deletable, my_id, options, numtogloops, 
	        togloops, numdelloops, delloops, num_loops_received, 
	        loops_received), targetid = nstlp);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

        } /* if(num_contiguous) */

      } /* for(i=0; i<num_sibs; i++) */

    } /* if(send_sibs && (ME.EMSloop->lp_props & EMLP_EXTERNAL)) */

wrapup:

  if(loc_loops_received) om$dealloc(ptr = loc_loops_received);
  if(sibs) om$dealloc(ptr = sibs);
  if(contiguous) om$dealloc(ptr = contiguous);

  EMWRAPUP(*EMmsg,sts,"In EMSloop.EMtoggle_type");
  return(sts);
 }

end implementation EMSloop;

