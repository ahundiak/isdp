/* ###################   APOGEE COMPILED   ################## */
/*
Name
        EMSsfmkface.EMresetSSI

Description
        This method is overridden to reset the num values in 
        instance data, and then sending to EMSdpr to zero out
        the vla of ids.

History
        Jack     07/27/93    creation
*/

class implementation EMSsfmkface;

#include "OMerrordef.h"
#include "OMmacros.h"


method EMresetSSI(IGRlong *EMmsg)
{

IGRlong OM_stat = OM_S_SUCCESS;
IGRlong lmsg;

    *EMmsg = EMS_S_Success;
     
     ME.EMSsfmkface->num_regions = 0;
     ME.EMSsfmkface->num_edges_out = 0;
     ME.EMSsfmkface->num_edges_copied = 0;

     om$send(mode = OM_e_wrt_message,
                       msg = message EMSsfdpr.EMresetSSI(&lmsg),
                       targetid = my_id);
return(OM_stat);

}

end implementation EMSsfmkface;

