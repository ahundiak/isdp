/* ###################   APOGEE COMPILED   ################## */
class implementation EMSnatedge;

#include "EMS.h"
#include "bserr.h"
#include "OMmacros.h"
#include "emsmacros.h"

method EMbstobnd(IGRlong *EMmsg;IGRint num_param;
		IGRdouble  *bs_param;
		struct EMSedgebound *bnd_param)
{
	IGRlong			sts,i;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;

/* For a natural edge the bsparam and the bndparam are same since
   there is only one span involved.
*/
 for(i=0;i<num_param;i++)
  {
    bnd_param[i].span_inx=0;
    OM_BLOCK_MOVE(&bs_param[i],&bnd_param[i].param,sizeof(IGRdouble));
  }

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSnatedge.EMbstobnd")
  return(sts);
}

end implementation EMSnatedge;
