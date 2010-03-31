/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmkface;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

method EMcheckOverlap(IGRlong *EMmsg; 
                      struct EMSinlist *inlist; 
                      IGRboolean *does_overlap; 
                      IGRushort options)
/*
Description
    This message will determine if this tree node has an overlap of
    surfaces/topology based on the inlist.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added so far. 
        does_overlap - TRUE if an overlap is detected.
        options - EMcheck_overlap_TREAT_SFS_AS_SFMOD - if specified, treat
                  the ids in the sflist as surfs modified.

History
    PP  09/10/93 Setting check overlap to be true as this caused problems
                 in a test case.
    DLB 02/08/91 Used EFcheck_overlap function.
    DLB 02/01/91 Fixed bug where num_edges_in was related to num regions 
                 instead of cum_num_edges_out.
    DLB 11/08/90 Cut out EFis_edge_owned_by_edlp and put it in a seperate file.
    DLB 06/08/89 Creation.
*/
{
  IGRlong               OM_stat=OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *does_overlap = TRUE;
  return(OM_stat);
}
end implementation EMSsfmkface;
