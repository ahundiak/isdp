/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSerrordef.h"

method EMget_props(IGRlong *EMmsg; IGRushort *props)
/*
History

	AIC	03/18/87	Creation Date

*/
{
  *EMmsg = EMS_S_Success;

  *props  = ME.EMSedge->ed_props;

  return(OM_S_SUCCESS);
}

end implementation EMSedge;
