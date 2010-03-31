/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method determines whether the input loop is nested inside the
  loop which receives this message.If it is nested then the enclosing loop
  sends down the input loop to its children,if it has any, to further
  determine the nesting.The nesting information is exchanged via a
  structure.
  The significance of its fields can be found in ems/include/EMSbnd.h.
  The structure should contain the GRobjid of the loop whose nesting is 
  sought,its range box and its properties.
	The relevant fields in the structure can be initialized by sending
  the message 'EMgivenestinfo' to the loop.
	Upon output, the structure contains the GRobjid of the innermost loop 
  which encloses the input loop,and its properties.
        If it is construed that the loop whose nesting is desired is
  coincident with this loop, then it's nesting is based on it's loop-type
  property (P or C). Loop type is used in order to make a better decision
  than an arbitrary one. It should be noted that this is the only 
  circumstance under which the loop type is used for nesting. If the loop types
  have been set arbitrarily to begin with, the nesting decision will in
  turn be arbitrary. The return code in this case is set to reflect this
  ambiguity. The following table is used for giving the nesting in this
  case:
        This loop              Input loop           Whether nested inside
           P                      P                         T
           P                      C                         T
           C                      P                         F
           C                      C                         F
  The motivation for choosing this table is the fact that most loopset
  operations diminish area.

Assumption
	In the nesting structure the following fields are initialized
  appropriately upon input -
	loopid		GRobjid of the input loop
	range		2D range of the input loop.

	It is also assumed that the two loops donot intersect. The
  intersection check is relatively expensive and in a stable loop tree
  loops do not intersect. So the intersection check is not done here.If
  the caller is not sure about the intersection, check can always be done
  knowing both the objids, before sending this message.

History
	SM	03/05/87	Creation date
	SM	04/02/87	Modified to take care of split loops.
	SM	07-Dec-87	Modified such that if a loop with
				EMSfeaturelp in its ancestry is passed
				in, it is considered to be NOT nested
				in this loop.
	SM	08-Feb-88	Do internal reverse check before stroking the
				edges.
        SS      26-Feb-88       If after all possible tries, the nesting is
                                still ambiguous, the loops in question are
                                considered to be coincident. In this case,
                                the input loop is arbitrarily selected as
                                nested inside this host.
	SM	19-Dec-88	Obtain the edges of the input loop. If any
				coincedent with any of the edges of the 
				host loop, then those edges are useless for
				nesting check. The coincedence is established
				as follows - 

				The edge's common edge being part of
				the host loop.This is done to avoid futile
				nesting checks in an attempt to accomplish
				what is commonly known as optimisation.
	SS	05-May-89	Changed the logic to use loop-type while
				determining nesting of a loop coincident with
				this one. The return code is EMS_I_Ambiguous.
	SM	27-Nov-89	If incoming loop is natural and this
				loop is also natural, conclude ambiguity
				trivially.
	SM	08-Dec-89	I was incorrectly determining a seam
				edge as coincedent.
        NP      05-May-92       Added function calls to time this method.
				
Return Code
   EMS_S_Success		The input loop was nested.
   EMS_I_OutOfBounds		The input loop was not nested.
   EMS_I_Ambiguous		The input loop was construed as coincident
				with this one. The nesting is based on
				loop types as described above.
   EMS_I_Open			The message was sent to an open loop, so
				no loop can be nested inside it.

*/


class implementation EMSloop;

#include "EMS.h"
#include "emsdef.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "timerdef.h"

#define UNKNOWN_NESTING -1
#define BUF_SIZE	20
#define NUM_INTERNAL_PTS 3

from EMSedge import EMgetbounds,EMptatpr,EMendpts,EMgetpygeom, 
			EMget_props;

extern IGRboolean _use_timers;

method EMnesting(IGRlong *EMmsg;struct EMSnest_info *nesting;
		 struct EMSpartolbasis *partolbasis)
{

     IGRlong     		sts,rc;
     OMuint			count;
     IGRint      		i,j,size;
     IGRboolean  		overlap,EFextract_par();
     IGRdouble   		uv[2][2],partollen,box1[4],box2[4],delta;
     struct EMSptloc_info 	location;
     OM_S_CHANSELECT 		to_edges, to_inner, to_common_edge;
     struct IGRpolyline		edge_poly;
     IGRint			nest = FALSE;
     OM_S_OBJECT_LINKAGE	inedge_buf[BUF_SIZE], *inedge = NULL;

   /* start timer for EMnesting */
   if (_use_timers)
     start_timer (T_EMNESTING);

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

   edge_poly.num_points = 0;
   edge_poly.points = NULL;
   inedge = (OM_S_OBJECT_LINKAGE *) inedge_buf;

   if(ME.EMSloop->lp_props & EMLP_OPEN) 
    {
      *EMmsg = EMS_I_Open;
      goto wrapup;
    }

   /* If the incoming loop has EMSfeaturelp in its ancestry then exit
    */
   if(nesting->lp_props & EMLP_NOAREA_NOHOLE) 
    {
      *EMmsg = EMS_I_OutOfBounds;
      goto wrapup;
    }

   sts = EMmake_chanselect (EMSloop_to_inner, &to_inner);
   if(!(1&sts)) goto wrapup;

/* If this loop is split, then ignore it because it is going to go out
   of the loopset. Ignoring the loop means just pass on the message to
   its children.
*/

  if(ME.EMSloop->lp_props & EMLP_SPLIT)
   {
       sts = om$send(msg = message EMSloop.EMnesting
				(EMmsg,nesting,partolbasis),
                             p_chanselect = &to_inner);
       EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
	goto wrapup;
   }

  if( (ME.EMSloop->lp_props & EMLP_NATURAL) && 
      (nesting->lp_props & EMLP_NATURAL))
   {
    nest = UNKNOWN_NESTING;
    overlap = FALSE;
   }
  else
   {
    /* Get the proper tolerance 
    */
    if(!partolbasis->is_valid)
     {
      sts = om$send(msg=message EMSboundary.EMgetsurface_info
			(EMmsg,NULL,partolbasis),targetid=my_id);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
     }

    sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);
  


    /* min-max box check 
    */
    size = 4 * sizeof(IGRdouble);
    OM_BLOCK_MOVE(ME.EMSloop->range,box1,size);
    OM_BLOCK_MOVE(nesting->range,box2,size);

    /* Decrease my range box and increase the incoming range box to avoid
       tolerancing problems
    */
    delta = partollen/2.0;
    EM2dbxdec(box1,delta);
    EM2dbxinc(box2,delta);

    /* A trivial box check can be performed for nesting - If the range
       boxes do not intersect (i.e the boxes are completely disjoint) then
       the incoming loop is not nested inside this loop. If a range box is
       completely inside the other, then it is regarded as an
       intersection.
    */
    nest = FALSE;
    overlap = FALSE;
    overlap = EM2dbxbxint(box1,box2);

   } /* if not both natural */

   if(overlap)
    {
     OM_S_OBJECT_LINKAGE	comm;
     OMuint			iscomm = 0;

     sts = EMmake_chanselect(EMSbd_owner_to_comps,&to_edges);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

     sts = EMmake_chanselect(EMSedge_to_common_edge,&to_common_edge);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

     sts = om$get_channel_count(objid = nesting->loopid,
                                    p_chanselect = &to_edges,count = &count);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

     /* Create a list of edges of the input loop, which will be useful in
	nesting determination. An edge of the input loop which is a common
	edge of one of my edges, is useless for nesting decision since
	it is coincedent.
	This criteria is valid only for non seam edges. Seam edges inspite
	of being common edges, are non coincedent in UV space.
     */
     if(count > BUF_SIZE)
	inedge = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count *
					sizeof(OM_S_OBJECT_LINKAGE));
     EMerr_hndlr(!inedge, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     sts = om$get_channel_objects(objid = nesting->loopid, 
				  p_chanselect = &to_edges, 
				  list = inedge, size = count, 
				  count = &count);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
     for(i=0; i<count; i++)
      {
       sts = om$get_channel_objects(objid = inedge[i].S_objid, 
					p_chanselect = &to_common_edge, 
					list = &comm, size = 1, 
					count = &iscomm);
       EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
       if(!iscomm) continue;
       sts = om$is_objid_on_channel(object_c = me, p_chanselect = &to_edges, 
				    objid = comm.S_objid);
       if(sts == OM_S_SUCCESS)
	{
	 IGRushort	edprops;
	
	 sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
			targetid = inedge[i].S_objid);
         EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError,wrapup);
	 if(!(edprops & EMED_SEAM)) inedge[i].S_objid = NULL_OBJID;
	}
       else sts = OM_S_SUCCESS;
      }

     /************************* CHECK 1 - EDGE ENDPOINTS **************/

      nest = UNKNOWN_NESTING;
      location.options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP;
      
      for(i=0;i<(IGRint)count;i++)
       {
	if(IF_NULL_OBJID(inedge[i].S_objid)) continue;
        sts = om$send(msg = message
                           EMSedge.EMendpts(EMmsg, NULL, uv[0],NULL,NULL,NULL),
                           targetid = inedge[i].S_objid);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
  
       /* start timer for pt_location */
       if (_use_timers)
        start_timer (T24_PT_LOCATION);

        sts = om$send(msg = message EMSloop.EMpt_location
				(EMmsg,uv[0],&location,partolbasis),
                               targetid = my_id);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

       /* stop timer for pt_location */
       if (_use_timers)
        stop_timer (T24_PT_LOCATION, FALSE, "");


        if(location.location==EMS_L_OUTSIDE){nest=FALSE;break;}
        else if(location.location==EMS_L_INSIDE) {nest=TRUE;break;}
	
       } /* for(i=0;i<(IGRint)count;i++) */

       /* If the nesting is still unknown then do a reverse check not already
          done -
          Give myself to the incoming loop for nesting check. If the incoming 
	  loop unambiguously makes a decision then my decision is just reverse 
	  of that. This reverse check is done only if the sender id is not the 
	  incoming loopid to avoid infinite loop problems.
       */

       /************************* CHECK 2 - REVERSE CHECK *****************/

      if( (nest==UNKNOWN_NESTING) && 
	  (!IF_EQ_OBJID(sender_id, nesting->loopid)))
        {
	  struct EMSnest_info	mynesting;
	 
	  mynesting.loopid = my_id;
	  mynesting.lp_props = ME.EMSloop->lp_props;
	  mynesting.parent = NULL_OBJID;
	  mynesting.parent_props = NULL;
	  OM_BLOCK_MOVE(ME.EMSloop->range, mynesting.range, 
					4*sizeof(IGRdouble));
	  sts = om$send(msg = message EMSloop.EMnesting(
					EMmsg, &mynesting, partolbasis), 
				targetid = nesting->loopid);
	  EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
	
	  /* If I am nested inside the incoming loop then it is definately
	     not nested inside me. This judgement
	     is true only if the determination has been made
	     unambiguously.
	  */
	  if(*EMmsg == EMS_S_Success)
		nest = FALSE;
	  else nest = UNKNOWN_NESTING;
	
	} /* if(nest==UNKNOWN_NESTING) */
	
       /* If the nesting is still unknown evaluate a point at mid bound of the
          edges of the loop in question. This point being inside or
          outside the loop would tell the nesting
       */

       /********************* CHECK 3 - EDGE MIDPOINT CHECK ****************/

      if(nest==UNKNOWN_NESTING)
        {
	  struct EMSedgebound bnd[2],eval;
	  IGRdouble p1,p2,p3;

          for(i=0;i<(IGRint)count;i++)
           {
	    if(IF_NULL_OBJID(inedge[i].S_objid)) continue;
	      sts = om$send(msg=message EMSedge.EMgetbounds(EMmsg,bnd),
				targetid = inedge[i].S_objid);
	      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	      p1 = bnd[0].span_inx + bnd[0].param;
	      p2 = bnd[1].span_inx + bnd[1].param;
	      p3 = (p1+p2)/2;
	      eval.span_inx = p3;
	      eval.param = p3 - eval.span_inx;
	      sts = om$send(msg=message EMSedge.EMptatpr(EMmsg,1,&eval,NULL,
			    uv[0]),
			targetid = inedge[i].S_objid);
	      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
       
             /* start timer for pt_location */
             if (_use_timers)
               start_timer (T24_PT_LOCATION);

              sts = om$send(msg = message
                            EMSloop.EMpt_location
				(EMmsg,uv[0],&location,partolbasis),
                               targetid = my_id);
              EMerr_hndlr(!(1 & *EMmsg &sts),*EMmsg,EMS_E_LoopError,wrapup);

              /* stop timer for pt_location */
              if (_use_timers)
               stop_timer (T24_PT_LOCATION, FALSE, "");

              if(location.location==EMS_L_OUTSIDE){nest=FALSE;break;}
              else if(location.location==EMS_L_INSIDE) {nest=TRUE;break;}
	
            } /* for(i=0;i<(IGRint)count;i++) */

        } /* if(nest==UNKNOWN_NESTING) */

       /* If the nesting is still unknown then go for the expensive process of
          getting the polyline geometry of each edge and checking each point
          in that polyline (except the endpoints).
       */

       /******************** CHECK 4 - STROKE EACH EDGE *****************/

      if(nest==UNKNOWN_NESTING)
        {
          for(i=0;i<(IGRint)count;i++)
           {
	    if(IF_NULL_OBJID(inedge[i].S_objid)) continue;
	      sts = om$send(msg=message EMSedge.EMgetpygeom
			   (EMmsg,0,MAXINT,FALSE,NULL,&edge_poly,
                            partolbasis, NULL),
				targetid = inedge[i].S_objid);
	      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
	
	      for(j=2; j<2*(edge_poly.num_points -1) ; j+=2)
	       {
       
                /* start timer for pt_location */
                if (_use_timers)
                 start_timer (T24_PT_LOCATION);

                 sts = om$send(msg = message EMSloop.EMpt_location
			    (EMmsg,&edge_poly.points[j],&location,partolbasis),
                               targetid = my_id);
                 EMerr_hndlr(!(1 & *EMmsg &sts),*EMmsg,EMS_E_LoopError,wrapup);
       
                 /* stop timer for pt_location */
                 if (_use_timers)
                  stop_timer (T24_PT_LOCATION, FALSE, "");


                 if(location.location==EMS_L_OUTSIDE){nest=FALSE;break;}
                 else if(location.location==EMS_L_INSIDE) {nest=TRUE;break;}
	
	       } /* for(j=2; j<2*(edge_poly.num_points -1) ; j+=2) */
	
	      if(edge_poly.points) om$dealloc(ptr = edge_poly.points);
	      edge_poly.num_points = 0;
	      edge_poly.points = NULL;
	      if( (nest==TRUE)||(nest==FALSE)) break;
	
            } /* for(i=0;i<(IGRint)count;i++) */

         } /* if(nest == UNKNOWN_NESTING) */

       /******************** CHECK 5 - INSIDE POINT TEST  *****************/

        /* If the nesting is still unknown, use points inside the
           incoming loop to check against this loop. For the incoming
           loop to be nested inside this loop, any point inside it must be 
           inside this loop. Lack of this condition is a definitive no-nesting.
           However, all sample points inside the input loop being inside
           this loop does not guarantee nesting of the input loop inside
           this loop. This criteria simply determines no-nesting condition.
        */
        if( (nest == UNKNOWN_NESTING) && !(nesting->lp_props & EMLP_OPEN))
         {
	  IGRdouble mindist, ptins[3];
	
	  for(i=0; i<NUM_INTERNAL_PTS; i++)
	   {
	    sts = om$send(msg = message EMSloop.EMptinside(EMmsg,
	          (IGRuint *)&i, partolbasis, 1, (IGRdouble *) ptins, 
	          &mindist), targetid = nesting->loopid);
            EMerr_hndlr(!(1 & *EMmsg &sts),*EMmsg,EMS_E_LoopError,wrapup);

            sts = om$send(msg = message EMSloop.EMpt_location
	          (EMmsg, ptins, &location, partolbasis), targetid = my_id);
            EMerr_hndlr(!(1 & *EMmsg &sts),*EMmsg,EMS_E_LoopError,wrapup);

            /* Point inside the incoming loop being outside this loop is
               the only definitive test. If the point is inside this loop, 
               do not reach any conclusion.
            */
            if(location.location==EMS_L_OUTSIDE){nest=FALSE;break;}
	   }
        }

    }  /* if(overlap) */

   /* If the nesting has remained unknown, it may be deduced that the two loops
      are coincident. In this case, the decision about nesting is made
      according to the loop-types as explained in the description above. The
      return code is set to indicate the ambiguity that existed. Also, no
      more searching for nesting needs to be performed, so terminate the
      channel sends by setting return code to stop-sending.
   */
  
   if(nest == UNKNOWN_NESTING)
    {
      if (ME.EMSloop->lp_props & EMLP_PLOOP)
        {
          nesting->parent = my_id;
          nesting->parent_props = ME.EMSloop->lp_props;
        }

      *EMmsg = EMS_I_Ambiguous;
      sts = OM_I_STOP_SENDING;
    }

   /* If the loop is nested inside me, fill my info and send the structure
      down to my children. Since a loop cannot be nested under two siblings
      simultaneously, set the return sts, so that the sender will not send to
      my siblings in the loop tree.
   */
   else if(nest == TRUE)
    {
     nesting->parent = my_id;
     nesting->parent_props = ME.EMSloop->lp_props;

     sts = om$send(msg = message EMSloop.EMnesting
				(EMmsg,nesting,partolbasis),
                             p_chanselect = &to_inner);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

     sts = OM_I_STOP_SENDING;
    }

   /* If the nesting is FALSE, indicating that the input-loop does not belong
      under here or under any of it's children, the return code is set to
      so reflect it. The nesting-info is untouched.
   */
   else
    {
       *EMmsg = EMS_I_OutOfBounds;
       sts = OM_S_SUCCESS;
    }

wrapup:
    if(edge_poly.points) om$dealloc(ptr = edge_poly.points);
    if(inedge && (inedge != inedge_buf)) om$dealloc(ptr = inedge);

   /* stop timer for EMnesting */
   if (_use_timers)
     stop_timer (T_EMNESTING, FALSE, "");

    EMWRAPUP(*EMmsg,sts,"In EMSloop.EMnesting")
    return(sts);

}
    
end implementation EMSloop;
