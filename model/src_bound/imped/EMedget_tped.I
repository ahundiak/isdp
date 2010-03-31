/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#define	INITIAL_SIZE	4
#define	INCREMENT	4

%safe
static IGRint recurse_lev = 0;
%endsafe

method EMget_top_part_edges (
IGRlong	     *EMmsg;
GRobjid	     **part_edges;
IGRint       *num_part_edges;
IGRint       *buf_size)

/*
 Notes
	This method returns a list of ids corresponding
	to the top part edge owners of a given edge.

	The caller can allocate the space for list of objids or
	can be allocated here.

	If the space is to be alloacted, it is the responsibility
	of the caller to,
	
	i) initialize *part_edges to NULL.
	ii) initialize *num_part_edges (value) to NULL.
	iii) initialize *buf_size (value) to NULL.
	iv) Deallocate memeory.
	
History  
         RC      05/08/87    Creation Date
         RC      08/02/87    Modified such that the top part edge
                             is put on the stack only if it is a part
                             of an active loop.	
         RC      11/03/87    Modified for version 1.1.0
        Jack     07/07/93    Changed to return at least the original 
                             edge in the part_edge list rather than
                             nothing in the case where the original
                             edge had a part edge owner that was part
                             of an inactive loop.

 Algorithm

    1. get the number of my part edge owners.
    2. If none, I am the top part edge and put myself on the stack.
    3. Otherwise, pass this message to my part edge owners.

*/

{

  IGRlong               OM_stat;
  IGRlong               mthd_stat;
  IGRint                EMcount_partedges (), i, num_part_ed_owners = 0, 
                        status;

  OM_S_OBJECT_LINKAGE   *part_ed_owners;
  IGRint  num_act_loops= 0;
  IGRint  EMcount_loops();

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  recurse_lev++;

  part_ed_owners = NULL;

  /*
   * get my owner part edges if any.
   */

  status = EMcount_partedges (&mthd_stat, my_id, 
               &num_part_ed_owners, &part_ed_owners, NULL, NULL, NULL);
  EMerr_hndlr ((!status || !(1&mthd_stat)),*EMmsg,EMS_E_Fail,wrapup);

 if (num_part_ed_owners)
 {
     for (i = 0; i < num_part_ed_owners; i++)
     {
        OM_stat = om$send (msg = message EMSedge.EMget_top_part_edges(
                            &mthd_stat, part_edges, num_part_edges, 
                            buf_size),
                           targetid = part_ed_owners[i].S_objid,
                           targetos = part_ed_owners[i].osnum);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
     }

 } /* if (num_part_ed_owners) */
 else  
 {
   /*
    * Since I am the top part edge, see if I have any active loops as
    * owners.
    */   

   status = EMcount_loops (&mthd_stat, my_id, &num_act_loops, NULL,
                            EMLP_ACTIVE, NULL, NULL);
   EMerr_hndlr (!status ||!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);


 } /* else for  if (num_part_ed_owners) */


 /*
  * if I have any active loops or I am about to return out of the
  * recursion without having filled out any part_edges, put my_id
  * into the list of part_edges.  Note: recurse_lev == 1 means that
  * this is the first level call to this method.
  */
 if ((num_act_loops) || ((! *part_edges) && (recurse_lev == 1)))
 {
   if (! *part_edges)	
   {
      *part_edges = NULL;
      *part_edges = (GRobjid *) om$malloc (size = (unsigned) 
		           (INITIAL_SIZE * sizeof (GRobjid)));
                                   *buf_size = INITIAL_SIZE;
       EMerr_hndlr (!(*part_edges),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
   }

   else if ((*num_part_edges + 1) > *buf_size)
   {
     (*buf_size) += INCREMENT;
     *part_edges = (GRobjid *) om$realloc (ptr = (IGRchar *)*part_edges, 
          size = (unsigned) (*buf_size) * sizeof(GRobjid ));

     EMerr_hndlr (!(*part_edges),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
   }

   (*part_edges)[(*num_part_edges)++] = my_id;

 } /* if (num_act_loops) */


wrapup:
 EMWRAPUP (*EMmsg, OM_stat, "in EMSedge.EMget_top_part_edges");
 if (part_ed_owners) om$dealloc(ptr = part_ed_owners);

 /*
  * decrement the recursion level
  */
 if (recurse_lev > 0)
   recurse_lev--;
   
return(OM_stat);
}

end implementation EMSedge;
