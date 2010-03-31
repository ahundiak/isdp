/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"

method EMget_put_cht(IGRlong *EMmsg; IGRboolean true_if_put; IGRdouble *cht)
/*
Description
    This message will get or put the cht in the boolean instance data.  If
    the true_if_put parameter is TRUE the cht is put in the instance data,
    otherwise, it is extracted.

Returned values
    EMS_S_Success if all is well.

Notes
    If the cht is put, no recomputation of the boolean will take place.
    If the user wishes for the cht to be reflected in the geometry/topology
    of the boolean then an explicit recompute operation should be initiated.

History
    03/03/89 DLB Creation.
*/ 
{
  *EMmsg = EMS_S_Success;

  if (true_if_put) ME.EMSsfboolean->cht = *cht;
  else             *cht = ME.EMSsfboolean->cht;
  
  return (OM_S_SUCCESS);
}
end implementation EMSsfboolean;
