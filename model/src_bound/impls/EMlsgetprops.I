/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "EMSerrordef.h"

method EMget_props(IGRlong *EMmsg; IGRushort *props)
/*
History

	AIC	03/18/87	Creation Date
*/
{
  *EMmsg = EMS_S_Success;

  *props  = (IGRushort) ME.EMSloopset->ls_props;

  return(OM_S_SUCCESS);
}

end implementation EMSloopset;
