/* ###################   APOGEE COMPILED   ################## */
class implementation EMSptedge;

#include "EMS.h"
#include "OMmacros.h"

method EMgetrange(IGRlong *EMmsg; IGRdouble *range;
		  struct EMSpartedinfo *bnd)
{
   IGRlong	sts, size;

   sts = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   size = 2 * sizeof(IGRdouble);
   OM_BLOCK_MOVE(ME.EMSptedge->point, range, size);
   OM_BLOCK_MOVE(ME.EMSptedge->point, &range[2], size);

wrapup:

   *EMmsg = EMS_I_DegenerateEdge;
   EMWRAPUP(*EMmsg,sts,"In EMSptedge.EMgetrng")
   return(sts);
}
end implementation EMSptedge;
