/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "emsdef.h"
#include "EMSmsgdef.h"

method EMgetCompIndex(IGRlong *EMmsg; 
                      IGRint *num_chan; struct EMchanstruct **chan;
                      IGRushort options)
/*
Description
   Simply send on up.

History
   DLB    05/14/89   Creation
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  OM_S_CHANSELECT to_owners;


  *EMmsg = EMS_S_Success;

  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_owners);
  if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS; 

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "In EMSdpr.EMgetCompIndex")
    return(OM_stat);
}
end implementation EMSdpr;
