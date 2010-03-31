/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"

#define INITIAL_SIZE	8
#define INCREMENT	4


from EMSboundary import EMget_edges;

method EMgetedges(IGRlong *EMmsg;
		   IGRlong option;
		   struct GRid **edges;
		   IGRint *buf_size,
			  *num_edges;
		   GRobjid **surf_list;
		   IGRint  **numed_list;
		   IGRint  *list_size,
			   *num_in_list)


/*
Description
    
    This method is an interface to its counterpart at loopset level.
    It effectively puts all its edges in the array 'edges'. All 
    conventions about allocation of memory / initializations etc. 
    must be followed as specified in the method at loopset level.

    In addition to acting as the above interface, this method optionally
    returns the surface-id and the number of edges contributed, in the
    surf_list and numed_list arrays resp. list_size  and num_in_list
    are analogous to buf_size and num_edges resp. If this info is not
    required, NULLs must be passed for surf_list, numed_list, list_size,
    num_in_list. 

Return values 

    EMS_S_Success is returned if all is well.

Change history:

    RV	09/01/87	Creation
    NP  08/25/92 	Modified for ANSI compliance. Added typecasts for realloc.

*/

{
 IGRlong	     OM_stat;    
 OM_S_CHANSELECT     to_loopset;
 IGRint 	     num_before;

 num_before = *num_edges;
      
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
    
 to_loopset.type = OM_e_addr;
 to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

 OM_stat = om$send(msg = message EMSboundary.EMget_edges(EMmsg,
                    MAXINT,
					option,
					edges,
					buf_size,
					num_edges),
			 p_chanselect = &to_loopset);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);	

 if (*num_edges > num_before && surf_list)
 {
   if (! (*list_size))
   {
     *surf_list = (GRobjid *) om$malloc (size = (INITIAL_SIZE * sizeof (GRobjid)));
     *list_size = INITIAL_SIZE;
     EMerr_hndlr (!(*surf_list),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
     if (numed_list)
     {
       *numed_list = (IGRint *) om$malloc (size = (INITIAL_SIZE * sizeof (IGRint)));
       EMerr_hndlr (!(*numed_list),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

     }
   }
   else if (! (*list_size > *num_in_list))
   {
     (*list_size) += INCREMENT;
     *surf_list = (GRobjid *) om$realloc (ptr = (IGRchar *)(*surf_list), 
		size = (unsigned) (*list_size) * sizeof(GRobjid));

     EMerr_hndlr (!(*surf_list),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
     if (numed_list)
     {
       *numed_list = (IGRint  *) om$realloc (ptr = (IGRchar *)(*numed_list), 
		size = (unsigned) (*list_size) * sizeof(IGRint));
       EMerr_hndlr (!(*numed_list),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
     }
   }
   (*surf_list)[*num_in_list] = my_id;
   if (numed_list) (*numed_list)[*num_in_list] = *num_edges - num_before;
   (*num_in_list)++;
 }

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMgetedges")
  return (OM_stat);
}
end  implementation EMSsubbs;
