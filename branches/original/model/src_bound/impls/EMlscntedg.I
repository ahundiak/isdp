/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "EMSerrordef.h"

method EMcount_edges(IGRlong *EMmsg, option; IGRint *count)
/*
Decription

Notes

History
    DLB     11/13/89    Removed the initialization of the count parameter.
                        Did this so the count would be correct if passed by
                        a solid.
    ???     ??/??/??    Creation.
*/    
{
  IGRlong sts;
  OM_S_CHANSELECT to_loops;

  *EMmsg = EMS_S_Success;
  /*    *count = 0; DLB 11/13/89 */
  sts = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
  if(! (1 & sts)) goto wrapup;
  sts = om$send(msg = message EMSboundary.EMcount_edges(EMmsg, option, count),
                p_chanselect = &to_loops);

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSloopset.EMcount_edges")
  return(OM_S_SUCCESS);
}

end implementation EMSloopset;
