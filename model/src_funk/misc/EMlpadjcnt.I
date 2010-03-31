/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This function determines whether two loops on the 
are adjacent to each other based on the 'common_edge' connections between
any of their edges. If atleast one edge of loop1 is connected to an
edge of loop2 then it returns TRUE for the adjacency test. 
	If 'output_pairs' is TRUE, the edge pairs which were found to be
adjacent are returned. The space for the edge ids, if not already allocated
will be allocated in the function and should be freed by the caller.
	If 'output_pairs' is FALSE, then the arguments 'pair1','pair2' and
'num_pairs' are ignored and can be NULL.
	The loops can be of the same surface or of different surfaces.

Assumption
	The common edge connections between coincedent edges must be
in place before invoking this function.

History
	SM	03/31/87	Creation date.
*/

class implementation EMSloop;

#include "EMS.h"

#include "OMmacros.h"

#include "OMprimitives.h"   /* om$malloc    */

IGRint  EMlpadjacent(EMmsg,loop1,loop2,adjacent,output_pairs,pair1,pair2,
			num_pairs)
IGRlong *EMmsg;
GRobjid loop1,loop2,**pair1,**pair2;
IGRboolean *adjacent,output_pairs;
IGRint		*num_pairs;
{
   IGRlong		sts;
   OM_S_CHANSELECT	to_edges,to_common_edge;
   IGRint		count1,count2,i,j,cnt1,cnt2;
   OM_S_OBJECT_LINKAGE	*edge1,*edge2;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
   *adjacent = FALSE;
   edge1 = NULL;
   edge2 = NULL;
   if(output_pairs) *num_pairs = 0;

   sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
   sts = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);


   sts = om$get_channel_count(objid=loop1,p_chanselect=&to_edges,
				count=(OMuint *)&count1);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
   sts = om$get_channel_count(objid=loop2,p_chanselect=&to_edges,
				count=(OMuint *)&count2);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* Allocate space for all the edges of both the loops.
*/
   edge1 = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count1 *
					sizeof(OM_S_OBJECT_LINKAGE));
   EMerr_hndlr(!edge1,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
   edge2 = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count2 *
					sizeof(OM_S_OBJECT_LINKAGE));
   EMerr_hndlr(!edge2,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

  if( (output_pairs)&&(!*pair1))
 	*pair1 = (GRobjid *) om$malloc(size=count1 * sizeof(GRobjid));
  if( (output_pairs) && (!*pair2))
	*pair2 = (GRobjid *) om$malloc(size=count2 * sizeof(GRobjid));

  EMerr_hndlr( (output_pairs) && ( (!*pair1)||(!*pair2)),*EMmsg,
                EMS_E_NoDynamicMemory,wrapup);

/* Get the edges of both the loops.
*/
   sts = om$get_channel_objects(objid=loop1,p_chanselect=&to_edges,
				list=edge1,size=count1,count=(OMuint *)&cnt1);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
   sts = om$get_channel_objects(objid=loop2,p_chanselect=&to_edges,
				list=edge2,size=count2,count=(OMuint *)&cnt2);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* If any edge of loop1 is connected to any edge of loop2 on the common
   edge channel then the two loops are adjacent to each other.
   A given edge can be adjacent to only one other edge. So if edge1[i]
   is found to match with edge2[j], then stop checking any other edge2[j],
   and take up the next edge1[i]. Mark the edge2[j] by NULL_OBJID so that
   it is not checked for any subsequent edge1[i].
		If output pairs are not desired, break as soon as the
   adjacency is determined.
*/

   for(i=0;i<cnt1;i++)
    {
      if( (*adjacent) && (!output_pairs) ) break;

      for(j=0;j<cnt2;j++)
       {
	 if(!IF_NULL_OBJID(edge2[j].S_objid))
	  {
	    sts = om$is_objid_on_channel(objid_c=edge1[i].S_objid,
				p_chanselect=&to_common_edge,
				objid=edge2[j].S_objid);
	    if(sts==OM_S_SUCCESS)
	     {
	       *adjacent = TRUE;
	       if(output_pairs)
	        {
		  (*pair1)[*num_pairs] = edge1[i].S_objid;
		  (*pair2)[(*num_pairs)++] = edge2[j].S_objid;
		   edge2[j].S_objid = NULL_OBJID;
	        }
	       break;
	     }
	    else sts = OM_S_SUCCESS;
	  }
       }
    }

wrapup:
   if(edge1) om$dealloc(ptr=edge1);
   if(edge2) om$dealloc(ptr=edge2);
   EMWRAPUP(*EMmsg,sts,"In EMlpadjacent");
   return(sts);
}

end implementation EMSloop;
