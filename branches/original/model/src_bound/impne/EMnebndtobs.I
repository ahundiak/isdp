/* ###################   APOGEE COMPILED   ################## */
class implementation EMSnatedge;

#include "EMS.h"
#include "bserr.h"
#include "OMmacros.h"
#include "emsmacros.h"

method EMbndtobs(IGRlong *EMmsg;IGRint num_param;
		struct EMSedgebound *bnd_param;
		IGRdouble  *bs_param)
{
	IGRlong			sts,i;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

/* For a natural edge the bsparam and the bndparam are same since
   there is only one span involved.
*/
 for(i=0;i<num_param;i++)
  {
    OM_BLOCK_MOVE(&bnd_param[i].param,&bs_param[i],sizeof(IGRdouble));
  }

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSnatedge.EMbndtobs")
  return(sts);
}

end implementation EMSnatedge;
