/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"

method EMrecompinfodelete(IGRlong *EMmsg; struct GRmd_env *my_env;
                          IGRushort options;
                          union EMSri_table *ri)
/*
Description
    This method will always be successful. It should be overriden at
    the boolean and certain local mod levels.  Its purpose is to delete
    the recompute information that only this state knows about.  Since
    some states don't have information that needs to be deleted, they will
    not override this method in which case when this method is involked it
    will always return success.

Return values
    EMS_S_Success always

History
    DLB 06/02/88 Creation.
*/
{
 *EMmsg = EMS_S_Success;
 return(OM_S_SUCCESS);
}

end implementation EMSdpr;
