/* ###################   APOGEE COMPILED   ################## */
class implementation EMSptedge;

#include "EMS.h"

method EMbndtobs(IGRlong *EMmsg;IGRint num_param;
		struct EMSedgebound *bnd_param;
		IGRdouble  *bs_param)
{
	IGRlong			sts,i;

 *EMmsg = EMS_I_DegenerateEdge;
 sts = OM_S_SUCCESS;

 for(i=0;i<num_param;i++)
  {
    bs_param[i] = 0;
  }

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSptedge.EMbndtobs")
  return(sts);
}

end implementation EMSptedge;
