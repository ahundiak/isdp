/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"

method EMsavestatedelete(IGRlong *EMmsg; struct GRmd_env *my_env;
                         union EMSssi_table *ssi)
/*
Description
    This method will always be successful. It should be overriden at
    the boolean and certain local mod levels.  Its purpose is to delete
    the save state information that only this state knows about.  Since
    some states don't have information that needs to be deleted, they will
    not override this method in which case when this method is involked it
    will always return success.

Return values
    EMS_S_Success always

History
    DLB 4/8/87 creation.
*/
{
 *EMmsg = EMS_S_Success;
 return(OM_S_SUCCESS);
}

end implementation EMSdpr;
