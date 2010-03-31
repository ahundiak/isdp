/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method trims a loop with respect to the input element.The
objid of the element against which the trim is to take place is passed in.
This could potentailly be a loopset, a loop or an edge. The pairs of 
boundary points representing solid portions on 'me' are returned.These also
have a one-to-one correspondence with the structures which provide the
caller the information about the generation of these boundaries by the
input element.The information includes the edge belonging to the input
element which caused the boundary and the parameter value on that edge.
	There is a link list of structures EMSsfintedpar for each loop and a
corresponding link list for the element against which the trimming is done.
The loop trims itself and sends down the same message to its children.
A common buffer is passed around, which has the addresses of the start of
the link lists for each loop.There is another common buffer passed around,
which has the number of boundaries for each loop and has one to one
correspondence with the link list address buffer.The buffer size remaining
is also passed around to facilitate realloc if necessary.
	The boundary pairs returned for the loop represent its parts in
the area. It should be noted that the two boundaries in a pair for the loop
can be on different edges.The extraction of such boundaries is handled by
the method 'EMextractyourself' which operates on the link list of the
boundaries produced by this method.

Bugs
	The method is defined for loops having linear edge,natural edge or
a partedge using one of those two. It will have to be redefined for a 'bsedge'.
	Also the only input element supported right now is a loopset.The
'parttrim' method will eventually be defined for a loop and an edge also.
When this happens we will be able to trim any boundary element against any
other boundary element.

History
	SM	03/20/87	Creation Date.
	SM	06/03/87	Various bug fixes along the way and changed
				to make use of the new 'point' field in
				the structure EMSsfintedpar.
	SM	27-Sep-88	Use EMScvint fields from successive edges
				for matching bdrys, instead of distance 
				checks. In addition to being optimised, 
				this also sheilds the boundary merging from
				tolerance problems and problems related to
				small gaps between edges by relying on the
				already created topology.
	SM      06-Jun-93       Do not merge any boundaries if there is
     	                        incedence on existing edges. This is to cause
                                maximum splits. This behavior is active only
                                if WANT_POST220_BEHAVIOR is set to TRUE.
        SM      23-Dec-93       Disable maximum split procedure
*/
class implementation EMSloop;

#include "EMS.h"
#include "emsdef.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emssfint.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "emsgeteddef.h"

#define	BUF_INC		5

/* This macro returns the address of a particular node in the link list
   of structures EMSsfintedpar. The node numbers start from 1 and go upto
   num_bdrys*2.
*/

#define NodeAddress(start_add,node_num,address) \
  	 { \
	  IGRint i; \
	  (address) = (start_add); \
	  for(i=0;i<(node_num)-1;i++) \
   	   {\
     		(address) = (address)->next;\
   	   }\
	 }

#define IntLoc(props) \
	((props) & EMS_PYPT_ATMIDDLE) ? EMScvint_middle : \
	((props) & EMS_PYPT_ATSTOP) ? EMScvint_rtend : \
	((props) & EMS_PYPT_ATSTART) ? EMScvint_lfend : \
	((props) & EMS_PYPT_ATEND) ? EMScvint_end : EMScvint_unknown

from EMSedge import EMptatpr,EMtrimyourself;

extern IGRboolean WANT_POST220_BEHAVIOR;

method EMtrimyourself(IGRlong *EMmsg;GRobjid *against;
                      IGRushort options;
		      struct EMSsfintedpar ***against_bdrys,
					   ***lp_bdrys;
		      GRobjid **loopids;
		      IGRint *num_loops,**num_bdrys,*buf_size;
		      struct EMSpartolbasis *partolbasis)
{
  IGRlong		sts,i,rc;
  OM_S_CHANSELECT	to_edges,to_inner;
  struct EMSsfintedpar	*edge_bdrys2,*ele_bdrys2,*new_head;
  struct EMSsfintedpar	*last_lp =      NULL,
                        *sec_last_lp =  NULL,
                        *last_ele =     NULL,
                        *sec_last_ele = NULL;
  IGRint		edge_num_bdrys2,from_idx,to_idx,idx,count;
  IGRdouble		partollen;
  GRobjid		on_edge[2];
  IGRboolean		EFextract_par(),bdry_found_so_far,in_area,in_hole, 
			intersect, contiguous_edges = FALSE;
  extern   void			EMsfintedpar_free();

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  to_inner.type = OM_e_addr;
  to_inner.u_sel.addr = &ME.EMSloop->to_inner;


  if(!partolbasis->is_valid)
   {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info
			(EMmsg,NULL, partolbasis),targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
   }
  sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);


/* If the common buffersize is 0 and if no memory has been allocated 
   so far then allocate memory for the various lists and set the proper
   buffer size.
*/
  if(!*buf_size && !(*num_loops))
    {
       *against_bdrys = (struct EMSsfintedpar **) om$malloc(size=
				sizeof(struct EMSsfintedpar *) * BUF_INC);
       EMerr_hndlr(!(*against_bdrys),*EMmsg,EMS_E_DynamicMemoryAllocated,
						wrapup);
       *lp_bdrys = (struct EMSsfintedpar **) om$malloc(size=
				sizeof(struct EMSsfintedpar *) * BUF_INC);
       EMerr_hndlr(!(*lp_bdrys),*EMmsg,EMS_E_DynamicMemoryAllocated,
						wrapup);
       *loopids = (GRobjid *) om$malloc(size=sizeof(GRobjid) * BUF_INC);
       EMerr_hndlr(!loopids,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
       
       *num_bdrys = (IGRint *) om$malloc(size=sizeof(IGRint) * BUF_INC);
       EMerr_hndlr(!num_bdrys,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
       *buf_size = BUF_INC;
    }
  else if(!*buf_size)
    {
/* If the common buffer size has dropped to 0 and some memory was already
   allocated then reallocate the buffer with size=current size + BUF_INC.
*/
       *against_bdrys = (struct EMSsfintedpar **) om$realloc(
				ptr = (char *)*against_bdrys,size=
			sizeof(struct EMSsfintedpar *)*(BUF_INC + *num_loops));
       EMerr_hndlr(!(*against_bdrys),*EMmsg,EMS_E_DynamicMemoryAllocated,
						wrapup);
       *lp_bdrys = (struct EMSsfintedpar **) om$realloc(
				ptr = (char *)*lp_bdrys,size=
		       sizeof(struct EMSsfintedpar *)* (BUF_INC + *num_loops));
       EMerr_hndlr(!(*lp_bdrys),*EMmsg,EMS_E_DynamicMemoryAllocated,
						wrapup);
       *loopids = (GRobjid *) om$realloc(ptr = (char *)*loopids,
				size=sizeof(GRobjid)*(BUF_INC + *num_loops));
       EMerr_hndlr(!loopids,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
       *num_bdrys = (IGRint *) om$realloc(ptr=(char *)*num_bdrys,
				size=sizeof(IGRint)*(BUF_INC + *num_loops));
       EMerr_hndlr(!num_bdrys,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
       *buf_size = BUF_INC;
    }

/* Initialize the output lists. If this loop has no (positive) boundaries
   then the corresponding lp_bdrys and against_bdrys in the output list
   will be NULL and num_bdrys for that loop will remain 0.
*/
    (*loopids)[*num_loops] = my_id;
    (*lp_bdrys)[*num_loops] = NULL;
    (*against_bdrys)[*num_loops] = NULL;
    (*num_bdrys)[*num_loops] = 0;
    (*buf_size)--;
    bdry_found_so_far = FALSE;

/* Trim each loop and get the boundaries on it.Some processing is
   required to decide the boundaries on the loop. If a vertex(point
   where two edges meet) is inside an area, then 'parttrim' on the two
   edges results in both edges having positive boundaries at that point.
   For the loop, such duplicate boundaries should not be included in the
   final result. When the boundaries from an edge are obtained then if the
   second boundary in the last pair for the previous edge, matches with
   the first boundary in the first pair of the next edge then both those
   boundaries are merged.
	By doing this each pair of boundaries returned by the loop 
   represents its part in the area.
	The coincedent boundaries are removed only if they lie 'inside'
   area. If they lie on some edge of the loopset against which they were
   trimmed, then they are retained.

   18-Oct-88 --
   If the loop has more than one edge and one of it's edges is closed
   (eg: a lollipop-like loop), the edge-trim method should ignore this
   closure as it is taken care of at this loop level. - SS
*/

   sts = om$get_channel_count(object=me,p_chanselect=&to_edges,
				count=(OMuint *)&count);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   from_idx = ME.EMSloop->lp_props&EMLP_REVERSED ? count-1 : 0;
   to_idx =ME.EMSloop->lp_props&EMLP_REVERSED ? -1 : count;

/* The trim message is sent to all the edges in the order of the loop's
   direction.
	The variables in_area and in_hole are used to generate the
   info regarding the loop  being completely in area/hole or partially
   in area/hole. Initially they are both set to TRUE. If an edge is 
   completely in area the variable in_hole is set to FALSE and vice
   versa. If an edge is partially in area/hole then both are set to
   FALSE.
*/

  idx = from_idx;
  bdry_found_so_far = FALSE;
  in_area = TRUE;
  in_hole = TRUE;
  intersect = FALSE;
  while(TRUE)
   {
     if(idx == to_idx) break;

     edge_num_bdrys2 = 0;
     ele_bdrys2 = NULL;
     edge_bdrys2 = NULL;

     if (count > 1)
       options |= EMS_INTER_CLOSEOVERRIDE;
     sts = om$send(msg=message EMSedge.EMtrimyourself(EMmsg,against,options,
				&ele_bdrys2,&edge_bdrys2,&edge_num_bdrys2,
				NULL,partolbasis),p_chanselect=&to_edges,
				from=idx,to=idx);
     if (count > 1)
       options &= ~EMS_INTER_CLOSEOVERRIDE;

     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
     if(*EMmsg == EMS_I_IntersectTrim) 
	{ intersect = TRUE; in_area = FALSE; in_hole = FALSE;}
     else if(*EMmsg == EMS_I_InAreaTrim) 
	  in_hole = FALSE;
     else if(*EMmsg == EMS_I_InHoleTrim) 
	  in_area = FALSE; 
	
/* If the last bdry of the previous edge matches the first bdrys of the
   next edge, then do not include either of them in the bdrys for the loop.
   The boundaries are matched by matching the UV points at those parameter
   values on the edge.
*/
     if(edge_num_bdrys2)
      {
	if(bdry_found_so_far)
	 {
	   OM_BLOCK_MOVE(&ele_bdrys2[0].edgeid, &on_edge[1], sizeof(GRobjid));
	
/* If the boundaries match, link the second last boundary with the second
   boundary returned by this edge and delete the common boundaries.
*/
	
	   if( (IF_NULL_OBJID(on_edge[0]) ||
 	        IF_NULL_OBJID(on_edge[1]) || 
		(IF_EQ_OBJID(on_edge[0], on_edge[1]) /*&& !WANT_POST220_BEHAVIOR*/)) &&
	       (last_lp->intloc == EMScvint_rtend) &&
	       (edge_bdrys2[0].intloc == EMScvint_lfend) && contiguous_edges
	     )
	    {
	      struct EMSsfintedpar *temp_lp, *temp_ele;
	   
	      sec_last_lp->next = edge_bdrys2[0].next;
	      sec_last_ele->next = ele_bdrys2[0].next;
	      temp_lp = edge_bdrys2[0].next;
	      temp_ele = ele_bdrys2[0].next;
	      EMsfintedpar_free(last_lp,1);
	      EMsfintedpar_free(last_ele,1);
	      EMsfintedpar_free(edge_bdrys2,1);
	      EMsfintedpar_free(ele_bdrys2,1);
	      (*num_bdrys)[*num_loops] += (edge_num_bdrys2-1);

/* If the new edges num_bdrys is 1, sec_last pointers in the link list
   remain same and the last pointers now point to the second node for
   the new edge.
*/
	      if(edge_num_bdrys2 == 1)
	       {
	         last_lp = temp_lp;
	         last_ele = temp_ele;
	       }
	      else
	       {
	         NodeAddress(temp_lp,2*edge_num_bdrys2-1,last_lp);
	         NodeAddress(temp_lp,2*edge_num_bdrys2-2,sec_last_lp);
	         NodeAddress(temp_ele,2*edge_num_bdrys2-1,last_ele);
	         NodeAddress(temp_ele,2*edge_num_bdrys2-2,sec_last_ele);
	       }
	    }

/* If the boundaries do not match then append the boundaries returned by
   this edge to the list of boundaries for the loop.
*/
	   else
	    {
	      last_lp->next = edge_bdrys2;
	      last_ele->next = ele_bdrys2;
	      (*num_bdrys)[*num_loops] += edge_num_bdrys2;
	      NodeAddress(edge_bdrys2,2*edge_num_bdrys2,last_lp);
	      NodeAddress(edge_bdrys2,2*edge_num_bdrys2-1,sec_last_lp);
	      NodeAddress(ele_bdrys2,2*edge_num_bdrys2,last_ele);
	      NodeAddress(ele_bdrys2,2*edge_num_bdrys2-1,sec_last_ele);
	    }
/* Get the UV for the last boundary generated and put it into
   match[0].
*/

           OM_BLOCK_MOVE(&last_ele->edgeid, &on_edge[0], sizeof(GRobjid));
	
        } /* if bdry_found_so_far */
       else
        {
/* If this is the first boundary found so far , put it into the output
   list and initialize the pointers to the last and second last nodes.
*/
	  (*lp_bdrys)[*num_loops] = edge_bdrys2;
	  (*against_bdrys)[*num_loops] = ele_bdrys2;
	  (*num_bdrys)[*num_loops] = edge_num_bdrys2;

          NodeAddress((*lp_bdrys)[*num_loops],2*(*num_bdrys)[*num_loops],
								last_lp);
          NodeAddress((*lp_bdrys)[*num_loops],2*(*num_bdrys)[*num_loops]-1,
								sec_last_lp);
          NodeAddress((*against_bdrys)[*num_loops],2*(*num_bdrys)[*num_loops],
								last_ele);
          NodeAddress((*against_bdrys)[*num_loops],
				2*(*num_bdrys)[*num_loops]-1,sec_last_ele);

/* Get the UV point for the last node of the first boundary.
*/
					
	  OM_BLOCK_MOVE(&last_ele->edgeid, &on_edge[0], sizeof(GRobjid));
	
	  bdry_found_so_far = TRUE;
        }
       contiguous_edges = TRUE;
     
     } /* if edge_num_bdrys2 */

    else contiguous_edges = FALSE;

    idx = ME.EMSloop->lp_props&EMLP_REVERSED ? idx -1 : idx +1;

   }  /* While (TRUE) */


/* After all the boundaries have been accumulated some more 
   processing is necessary to complete the circular check between the
   boundaries of the consequtive edges. This check however,is needed
   only for closed loops and if total number of boundary pairs is more
   than one.
	For a closed loop say the boundary pairs formed were as 
   follows -
        S1-A  P-Q  R-T B-S2.
	each letter representing a node in the link list. Then if S1 and
   S2 are coincedent and they do not end on any edge of the loopset then they 
   are deleted and the new pair formed is
   B-A. The head of the link list is also changed accordingly.
   corrsponding change also needs to be done in the output list representing
   boundaries on the 'against' element.

   28-Nov-87 --
   This removal of boundaries should take place only if it is at the endpoints
   of the edges. The internal duplicate boundaries might (and should) occur
   if there are coincedent edges in the loopset.

   30-Dec-87 --
   Removal of boundaries only if they are 'dangling' in space and have no
   intersections on the edges of the loop/loopset and addition to being
   coincedent.
*/
   if( (!(ME.EMSloop->lp_props&EMLP_OPEN)) &&
       ((*num_bdrys)[*num_loops] > 1))
    {
/* Get the UV points for S1 and S2
*/
	
	if( (IF_NULL_OBJID( (*against_bdrys)[*num_loops]->edgeid) ||
	    IF_NULL_OBJID( last_ele->edgeid) ||
	    (IF_EQ_OBJID((*against_bdrys)[*num_loops]->edgeid, last_ele->edgeid
	    ) /*&& !WANT_POST220_BEHAVIOR*/)) &&
	    ((*lp_bdrys)[*num_loops]->intloc == EMScvint_lfend) &&
	    (last_lp->intloc == EMScvint_rtend)
	  )
	 {
	   GRobjid	first, last;
	
	   sts = om$send(msg = message EMSloop.EMnext_edge
		(EMmsg, EMGetEd_First, NULL_OBJID, &first), targetid = my_id);
	   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	   sts = om$send(msg = message EMSloop.EMnext_edge
		(EMmsg, EMGetEd_Last, NULL_OBJID, &last), targetid = my_id);
	   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

	   if(IF_EQ_OBJID(first, (*lp_bdrys)[*num_loops]->edgeid) &&
	      IF_EQ_OBJID(last, last_lp->edgeid))
	    {
	     NodeAddress((*lp_bdrys)[*num_loops],3,new_head);
	     sec_last_lp->next = (*lp_bdrys)[*num_loops]->next;
	     (*lp_bdrys)[*num_loops]->next->next = NULL;
	     EMsfintedpar_free((*lp_bdrys)[*num_loops],1);
	     EMsfintedpar_free(last_lp,1);
	     (*lp_bdrys)[*num_loops] = new_head;
	     (*num_bdrys)[*num_loops]--;
	     NodeAddress((*against_bdrys)[*num_loops],3,new_head);
	     sec_last_ele->next = (*against_bdrys)[*num_loops]->next;
	     (*against_bdrys)[*num_loops]->next->next = NULL;
	     EMsfintedpar_free((*against_bdrys)[*num_loops],1);
	     EMsfintedpar_free(last_ele,1);
	     (*against_bdrys)[*num_loops] = new_head;
	    }
	 }
    }

/* Increment the num_loops counter and send the message down to my
   children(if any).
*/
    if(!( (*num_bdrys)[*num_loops])) 
      { in_area = FALSE; in_hole = TRUE; intersect = FALSE;}
    else if( (*num_bdrys)[*num_loops] > 1)
      { in_area = FALSE; in_hole = FALSE; intersect = TRUE;}
	
    if(!in_area && !in_hole) intersect = TRUE;

/* If this loop was not completely in area then each of its boundaries
   must have a intersection on an edge of the loopset/loop against which
   it was trimmed. If this is not the case then attempt a more precise
   trimming unless the caller has indicated not to do so or such an attempt
   has already been made.
*/
   if(intersect && (!(options & EMS_INTER_NO_MOREPRECISE)) &&
		   (!(options & EMS_INTER_MOREPRECISE)))
    {
      struct EMSsfintedpar *this_bdry;
      IGRboolean	precise_trim = FALSE;

      this_bdry = (*against_bdrys)[*num_loops];

      for(i=0; i< 2 * (*num_bdrys)[*num_loops]; i++)
       {
	 if(IF_NULL_OBJID(this_bdry->edgeid))
	      {precise_trim = TRUE; break;}
	 if(this_bdry)this_bdry = this_bdry->next;
	
       } /* for all bdrys */
    
      if(precise_trim)
       {
	 /* Free the memory allocated for the link lists during the first
	    attempt at trimming. Also undo all other variables and send the
	    same message to this loop, this time with the option for
	    precise trimming set.
	 */
	
	 EMsfintedpar_free((*lp_bdrys)[*num_loops], NULL);
	 EMsfintedpar_free((*against_bdrys)[*num_loops], NULL);
	 (*lp_bdrys)[*num_loops] = (*against_bdrys)[*num_loops] = NULL;
	 (*num_bdrys)[*num_loops] = 0;
	 (*loopids)[*num_loops] = NULL_OBJID;
	 (*buf_size)++;
	 
	 sts = om$send(msg = message EMSloop.EMtrimyourself
			(EMmsg, against, options | EMS_INTER_MOREPRECISE, 
			 against_bdrys, lp_bdrys, loopids, num_loops, 
			 num_bdrys, buf_size, partolbasis), 
			targetid = my_id);
	 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	 goto wrapup;
       }

    } /* if(intersect) */


    (*num_loops) ++;
     sts = om$send(msg=message EMSloop.EMtrimyourself
			(EMmsg,against,options,against_bdrys,lp_bdrys,loopids,
			 num_loops,num_bdrys,buf_size,partolbasis),
			p_chanselect = &to_inner);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

/* The caller may want to know whether this particular loop was partially
   in area , completely in area or completely in hole. Convey this information
   via the return code.
*/
   if(in_area) *EMmsg = EMS_I_InAreaTrim;
   else if(in_hole) *EMmsg = EMS_I_InHoleTrim;
   else *EMmsg = EMS_I_IntersectTrim;

wrapup:
   EMWRAPUP(*EMmsg,sts,"In EMSloop.EMtrimyourself");
   return(sts);
}

end implementation EMSloop;
