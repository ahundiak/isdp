/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSdpr.h"
#if DEBUG
#include "stdio.h"
#endif

method EMtoggleOrient(IGRlong *EMmsg; IGRushort options)
/*
Description
    This message should be overridden by any class that reverses the
    orientation of surfaces.

Return Values
    EMS_S_Success if all is well.

Notes
    This message comes into play during a random access tree operation (namely
    unevaluate and evaluate).

    About parameters:
        options -
          EMtoggle_orient_FLIP_TO_INACTIVE - if set the orientation should
          flipped as if the state were inactive.  If already so, then do
          nothing.

History
    DLB 02/04/90 Creation.
*/
{
  *EMmsg = EMS_S_Success;
  return(OM_S_SUCCESS);
}
end implementation EMSdpr;
