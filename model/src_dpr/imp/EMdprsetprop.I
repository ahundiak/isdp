/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"

method EMsetprops(IGRlong *EMmsg; IGRboolean *action; 
                  IGRushort *mask)
/*
Description
    This method will change the bits in the DPR properties word.

Return Values
    EMS_S_Success always returned.

Notes

History
   DLB    03/25/87: creation date
*/

{
 *EMmsg = EMS_S_Success;

 if (*action) ME.EMSdpr->dpr_props |= *mask;
 else ME.EMSdpr->dpr_props &= ~(*mask);

 return(OM_S_SUCCESS);
}
end implementation EMSdpr;
