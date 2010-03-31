class implementation NMpartedge;

#include "EMS.h"
#define	INITIAL_SIZE	4
#define	INCREMENT	4


method EMget_top_part_edges (
IGRlong	     *EMmsg;
GRobjid	     **part_edges;
IGRint       *num_part_edges;
IGRint       *buf_size)

/*
 Notes
	This method returns a list of ids corresponding
	to the top NM part edge owners of a given edge.

	The caller can allocate the space for list of objids or
	can be allocated here.

	If the space is to be alloacted, it is the responsibility
	of the caller to,
	
	i) initialize *part_edges to NULL.
	ii) initialize *num_part_edges (value) to NULL.
	iii) initialize *buf_size (value) to NULL.
	iv) Deallocate memeory.
	
*/

{

  IGRlong               OM_stat;
  IGRlong   		mthd_stat;

  IGRint                EMcount_partedges (), i, num_part_ed_owners, 
                        status;

  OM_S_OBJECT_LINKAGE   *part_ed_owners;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  part_ed_owners = NULL;

  /*
   * get my owner part edges if any.
   */

  status = NMcount_nmpartedges (&mthd_stat, my_id, OM_Gw_current_OS, 
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
    * Though I am the top part edge, it may be possible that
    * I do not have any active loop as my owner. In such a case
    * do not put me on the stack
    */

   IGRint  num_act_loops, EMcount_loops();
   
   status = EMcount_loops (&mthd_stat, my_id, &num_act_loops, NULL,
                            EMLP_ACTIVE, NULL, NULL);
   EMerr_hndlr (!status ||!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

   if (num_act_loops)
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
            size = (unsigned) (*buf_size) * sizeof(GRobjid));

       EMerr_hndlr (!(*part_edges),*EMmsg,EMS_E_NoDynamicMemory,wrapup);
     }

     (*part_edges)[(*num_part_edges)++] = my_id;

   } /* if (num_act_loops) */

 } /* else for  if (num_part_ed_owners) */

wrapup:
 EMWRAPUP (*EMmsg, OM_stat, "in NMpartedge.EMget_top_part_edges");
 if (part_ed_owners) om$dealloc(ptr = part_ed_owners);

return(OM_stat);
}

end implementation NMpartedge;
