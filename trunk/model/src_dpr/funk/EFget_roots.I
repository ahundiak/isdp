/*
Name: IGRlong EFget_roots()

Abstract: This function will get the root nodes of a dpr state tree
          given the parent state to start from.  It will not go outside
          of the object space passed in to this function.  Once these are 
          gotten the caller will be able to put the leaves on the batch
          and the whole dpr tree will get recomputed.  Pretty neat, huh?

          Initialize 'roots' to NULL, I will allocate the memory, you free it.
          Initialize 'num_roots' to 0.

History
    Jack 29-Jan-93 Creation
*/
class implementation EMSdpr;

#include "EMS.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSdpr.h"
#include "OMmacros.h"
#include "GMdef.h"
#include "nddef.h"  /* ND_ROOT, ND_IN_BUF */


extern void EFrealloc_if_needed();

from EMSsfdpr import NDget_objects;

IGRlong EFget_roots(EMmsg, parent_os, parent_id, num_roots, roots)
IGRlong             *EMmsg;
GRspacenum           parent_os;
GRobjid              parent_id;
IGRint              *num_roots;
GRobjid            **roots; 
{

IGRlong         OM_stat   = OM_S_SUCCESS;      
struct GRid    *loc_roots = NULL;
IGRint          loc_count = 0;       
IGRint          ii = 0;
struct GRid    *save_loc_roots = NULL;
IGRint          duplicate = 0;

/*
 * get the parents of this passed in parent 
 */
OM_stat = om$send ( msg = message EMSsfdpr.NDget_objects(
                                        (ND_ROOT | ND_IN_BUF),
                                         NULL,
                                         0,
                                        &loc_roots,
                                         NULL,         /* from */
                                         OM_K_MAXINT,  /* to */
                                        &loc_count),
                    targetos = parent_os, 
                    targetid = parent_id, 
                    senderid = NULL_OBJID );
if(!(1 & OM_stat & *EMmsg)) 
     goto wrapup;



if(loc_count == 0) /* if there were no parents, I am a root node */
    {

      /*
       * first, make sure I am not in the list already.
       */
      duplicate = 0;
      for(ii=0; ii < (*num_roots); ii++)
       {
         if((*roots)[ii] == parent_id)
           duplicate = 1;
       }
      
      if(!duplicate)
       { 
        if((*roots)==NULL)
          { /* if we are just starting, start with 15 slots */
           (void) EFrealloc_if_needed(EMmsg, roots, 0, 15, sizeof(GRobjid));
           if(!(1 & *EMmsg)) goto wrapup; 
          }
        else
          { /* otherwise, see if we have room for 1 more, else bump it by 15 */
           (void) EFrealloc_if_needed(EMmsg, roots, *num_roots, 15, sizeof(GRobjid));
           if(!(1 & *EMmsg)) goto wrapup; 
          }

         /* add this parent to the list of root nodes and bump the counter */ 
       (*roots)[(*num_roots)] = parent_id;
       (*num_roots)++;
       } 
    }
else
    {

      /*
       * save the roots passed back from NDget_objects since that memory will 
       * get reused by that routine.
       */
      save_loc_roots = (struct GRid *) alloca(loc_count * sizeof(struct GRid));
      OM_BLOCK_MOVE(loc_roots,save_loc_roots,(loc_count * sizeof(struct GRid)));

      /* there are some parents, get their roots */
      for(ii=0; ii < loc_count; ii++)
       {
         if(save_loc_roots[ii].osnum == parent_os) /* stay in the main parents os */
          {
           OM_stat = EFget_roots(EMmsg,
                                 parent_os,
                                 save_loc_roots[ii].objid,
                                 num_roots,
                                 roots);
           if(!(1 & OM_stat & *EMmsg)) 
             goto wrapup;
          }
       } /* for each parent */ 
    } /* else, there are some parents */  

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EFget_roots")
    return(OM_stat);
}

end implementation EMSdpr;
