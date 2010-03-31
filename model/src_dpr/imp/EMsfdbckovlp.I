class implementation EMSsfrembnd;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

method EMcheckOverlap(IGRlong          *EMmsg; 
                      struct EMSinlist *inlist; 
                      IGRboolean       *does_overlap; 
                      IGRushort options)
/*
Description
    This message will determine if this tree node has an overlap of
    surfaces/topology based on the inlist or outlist.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added/removed  so
                  far.          
        does_overlap - TRUE if an overlap is detected.
        options - EMcheck_overlap_TREAT_SFS_AS_SFMOD - if specified, treat
                  the ids in the sflist as surfs modified.

    For the special case of a non-intersecting boolean (disjoint or hollow),
    this method will always report an overlap.  

    For the special case of a non-intersection intersect plane - save side,
    this method will always report an overlap.

History

 DLB        01/13/93 : Always return an overlap.
 August, 1991  : AMD : Creation

*/

{
  *EMmsg = EMS_S_Success;
  *does_overlap = TRUE;
  return(OM_S_SUCCESS);
}
end implementation EMSsfrembnd;
