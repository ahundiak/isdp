/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfhist;

#include "EMS.h"

method EMcheckOverlap(IGRlong *EMmsg;
                      struct EMSinlist *inlist;
                      IGRboolean *does_overlap; IGRushort options)
/*
Description
    This message will determine if this tree node has an overlap of
    surfaces/topology based on the inlist.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added so far. 
        does_overlap - TRUE if an overlap is detected.
        options - currently unused.

History
    DLB 06/12/89 Creation.
*/
{
  *EMmsg = EMS_S_Success;
  *does_overlap = FALSE;
  return(OM_S_SUCCESS);
}
end implementation EMSsfhist;
