/* ###################   APOGEE COMPILED   ################## */
class implementation EMSptedge;

#include "EMS.h"
#include "bserr.h"
#include "OMmacros.h"
#include "emsmacros.h"

method EMbstobnd(IGRlong *EMmsg;IGRint num_param;
		IGRdouble  *bs_param;
		struct EMSedgebound *bnd_param)
{
	IGRlong			sts,i;

 *EMmsg = EMS_I_DegenerateEdge;
 sts = OM_S_SUCCESS;

 for(i=0;i<num_param;i++)
  {
    bnd_param[i].span_inx = 0;
    bnd_param[i].param  = 0.0;
  }

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSptedge.EMbstobnd")
  return(sts);
}

end implementation EMSptedge;
