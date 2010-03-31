/* ###################   APOGEE COMPILED   ################## */
/*
Name
        EMSsfdpr.EMresetSSI

Description
        This method is overridden to reset the known vla's to zero.

History
        mrm     03/26/91    creation
*/

class implementation EMSsfdpr;

#include "OMmacros.h"

method EMresetSSI(IGRlong *EMmsg)
{
    *EMmsg = EMS_S_Success;
    om$vla_set_dimension(varray = ME.EMSdpr->ids, size = 0);
    return(OM_S_SUCCESS);
}

end implementation EMSsfdpr;
