/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRcsmgr.GRrigid_connecting

Description
        Ask Gray
*/

class implementation GRcsmgr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"

method GRrigid_connecting (IGRlong *msg; struct GRid *go_id)
{
    *msg = MSSUCC;
    return (OM_S_SUCCESS);
}

end implementation GRcsmgr;
