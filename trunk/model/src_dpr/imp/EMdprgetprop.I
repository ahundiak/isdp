/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"

method EMget_dpr_props(IGRlong *EMmsg; IGRushort *props)
/*
History

    DLB 10/26/87    mod for vers 1.1.0
	AIC	03/18/87	Creation Date

*/
{
  *EMmsg = EMS_S_Success;

  *props = ME.EMSdpr->dpr_props;

  return(OM_S_SUCCESS);
}

end implementation EMSdpr;
