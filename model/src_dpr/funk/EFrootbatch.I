/*
Name: void EFget_roots_and_batch()

Abstract: This routine takes some parent in a dpr state tree and finds all
          the root nodes for that tree.  Then all of the root nodes are 
          put on the batch to be recomputed.
          
Notes:    This routine calls EFget_roots().


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
#include "nddef.h"
#include "ndmacros.h"


IGRlong EFget_roots_and_batch(EMmsg, parent)
IGRlong             *EMmsg;
struct GRid          *parent;
{

IGRlong         OM_stat   = OM_S_SUCCESS;      
IGRint          ii = 0;
GRobjid        *root_ids  = NULL;
IGRint          loc_count = 0;       
struct GRid     loc_root;

extern IGRlong EFget_roots();

/*
 * get the roots of this parent, they will all be in
 * the parent object space
 */
OM_stat = EFget_roots(EMmsg,
                      parent->osnum,
                      parent->objid,
                     &loc_count,
                     &root_ids);   
if(!(1 & OM_stat & *EMmsg)) 
     goto wrapup;



/* if there were no parents, I am a root node, put myself on the batch */
if(loc_count == 0) 
   {
     nd$wait_batch(type       =  GR_GEOM_POSTED,
                   nb_obj     =  1,
                   l_object   =  parent);

     /*
      * execute the batch
      */
     nd$exec_batch();

   }
else
   {
      /*
       * there are some roots, put them on the batch
       */
      loc_root.osnum = parent->osnum;
      for(ii=0; ii < loc_count; ii++)
        {
        loc_root.objid = root_ids[ii];

        nd$wait_batch(type       = GR_GEOM_POSTED,
                      nb_obj     = 1,
                      l_object   = &loc_root);
        }

        /*
         * execute the batch
         */
        nd$exec_batch();


   } /* else, there are some roots */  


  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EFget_roots_and_batch")

    /*
     * deallocate any roots passed back from EFget_roots
     */
    if(root_ids)
      om$dealloc(ptr = root_ids);
 
    return(OM_stat);
}

end implementation EMSdpr;

