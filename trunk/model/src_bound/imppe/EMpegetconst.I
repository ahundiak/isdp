/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method gets all the parameters on a span of a linear edge where
a partedge begins/ends. The term 'constraints' refers to the fact that while
changing geometry of a linear edge by inserting some points in an existing
span, one has to make sure that the resultant geometry encompasses the 
existing uv points where any partedges begin/end on that span. If this
is not done, parametric gaps (possibly greater than the tolerance) will result
within a loop when the partedge bounds are calculated wrt the new
geometry. These constraints refer to partedges begining/ending in the middle
of an existing span. The points at the end points of a span need not be
considered as constraints since those points are already present in the 
linear edge geometry.

Arguments

 span_inx		input	The span index of the linear edge for which the
				constraints are sought.
 num_constraints	output  Just what it says.
 params			output	parameters for the partedge bounds which
				lie on the input span. These are sorted
				in ascending order upon output. Memory is
				malloced/realloced as the chain execution
				continues for all the partedges owning the
				particular edge.
 partedids		output	Objids of the partedge for which the params
				are being returned. If both the bounds
				of a partedge lie on the span in
				question then both params are returned
				and the objid will appear twice in this
				array. Not interested ? NULL : non NULL.
 buf_size		input	If no memory malloced upon input this value
				must be zero.
				
History
	SM	12-Mar-88	Creation.
	SM	21-Feb-89	Do explicit send on to_owners channel instead 
				of using EMsend_partedges function so that 
				dummy edges get the message too.
	
*/

class implementation EMSpartedge;

#include "EMS.h"
#define DEBUG	0

#if DEBUG
#define BUF_INC	1
#else
#define BUF_INC	2
#endif

#include "OMmacros.h"
#include "emsdef.h"

method EMget_span_constraints(IGRlong *EMmsg;
			      IGRint	span_inx;
			      IGRint *num_constraints;
			      struct EMSedgebound **params;
			      GRobjid **partedids;
			      IGRint *buf_size)
{
  IGRlong 		sts;
  struct EMSedgebound   temp_bnd, my_bnd;
  GRobjid		temp_objid;
  IGRint		i, j, bdry;
  OM_S_CHANSELECT	to_owners;
  IGRint		numowners = 0;


  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  /* If my bounds lie on the span index in question, return them as the
     constraints.
  */
 
  for(bdry=0; bdry<2; bdry++) 
   {
     my_bnd = ME.EMSpartedge->boundary[bdry];
     if(my_bnd.span_inx != span_inx) continue;
     if( (my_bnd.param == 0.0) || (my_bnd.param == 1.0)) continue;

     if(!*buf_size)
      {
	if(params && *params)
	  *params = (struct EMSedgebound *) om$realloc(ptr = (IGRchar *)*params, 
		   size = (*num_constraints + BUF_INC) * 
						sizeof(struct EMSedgebound));
	else if(params) *params = (struct EMSedgebound *) om$malloc(size = 
					BUF_INC * sizeof(struct EMSedgebound));
					
	if(partedids && *partedids)
   *partedids = (GRobjid *) om$realloc(ptr = (IGRchar *)*partedids, size = 
		     (*num_constraints + BUF_INC) * sizeof(GRobjid));
	else if(partedids) *partedids = (GRobjid *) om$malloc(size = BUF_INC *
					sizeof(GRobjid));
	*buf_size = BUF_INC;
	
      } /* if(!*buf_size) */

     if(params)
        OM_BLOCK_MOVE(&my_bnd, 
		   &(*params)[*num_constraints], sizeof(struct EMSedgebound));
     if(partedids) (*partedids)[*num_constraints] = my_id;
     (*buf_size)--;
     (*num_constraints)++;
     
     /* Sort the constraints in ascending order.
     */
     for(i=0; i+1 < *num_constraints; i++)
      {
	for(j = i + 1; j< *num_constraints; j++)
	 {
	   if(params && ((*params)[i].param > (*params)[j].param))
	    {
	      temp_bnd = (*params)[i];
	      if(partedids)temp_objid = (*partedids)[i];
	      (*params)[i] = (*params)[j];
	      if(partedids) (*partedids)[i] = (*partedids)[j];
	      (*params)[j] = temp_bnd;
	      if(partedids) (*partedids)[j] = temp_objid;
	    }
	 }
	
      } /* sort */

   } /* for(bdry=0; bdry<2; bdry++) */

  sts = EMmake_chanselect (EMSedge_to_owner, &to_owners);
  sts = om$get_channel_count (object = me, p_chanselect = &to_owners,
             			   count = (OMuint *)&numowners);

  for(i=0; i<numowners; i++)
   {
    sts = om$send(msg = message EMSpartedge.EMget_span_constraints
	    (EMmsg, span_inx, num_constraints, params, partedids, buf_size), 
		from = i, to = i, p_chanselect = &to_owners);
    if(sts == OM_W_UNKNOWN_MSG)		/* could be a loop */
		sts = OM_S_SUCCESS;
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
   }

wrapup:
	EMWRAPUP(*EMmsg, sts, "In EMSpartedge.EMget_constraints");
	return(sts);
}

end implementation EMSpartedge;
