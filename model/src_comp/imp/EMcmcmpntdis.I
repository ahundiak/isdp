class implementation EMScomposite;

#include "EMScc.h"
#include "msdef.h" /* MS message codes */
#include "msmacros.h"

method GRcomponent_disconnecting(IGRlong *msg; struct GRmd_env *md_info;
                                 struct GRid *comp_id)
/*
Description 
    This is a dummy method to solve a dummy problem.  

Return values
    *msg  MSSUCC always

Notes
    For Draft version 1.1.2 Gray Winn overrode this method at the GRowner
    class to delete the owner if the number of components is zero.  While
    this may solve all of his problems, it reeks havoc on all of our 
    composite deletion code (the protocol is all screwed up).  So this
    is 'Dave's Solution To The Problems Created By Gray's Solution' (coming
    soon to a theater near you...).

History
    DLB 06/08/88 Creation.
*/
{
 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}
end implementation EMScomposite;
