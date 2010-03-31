/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"

method EMgetbounds(IGRlong *EMmsg;struct EMSedgebound *bound)
{
  *EMmsg = EMS_S_Success;

   OM_BLOCK_MOVE(ME.EMSpartedge->boundary,bound,
			2*sizeof(struct EMSedgebound));
  return(OM_S_SUCCESS);
}
end implementation EMSpartedge;
