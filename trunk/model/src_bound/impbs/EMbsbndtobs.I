/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method convertes an EMSedgebound parameter for an edge into
a bsparameter which is nothing but the value contained in the param field
of the struct EMSedgebound.

History
	PP	05/12/87	Creation Date.
*/

class implementation EMSbsedge;

#include "EMS.h"
#include "emsmacros.h"

method EMbndtobs(IGRlong *EMmsg;IGRint num_param;
		struct EMSedgebound *bnd_param;
		IGRdouble  *bs_param)
{
	IGRlong			status;
        IGRshort		i;


   *EMmsg = EMS_S_Success;
   status = OM_S_SUCCESS;

 for(i=0;i<num_param;i++)
  {
   if (bnd_param[i].span_inx == 0)
   bs_param[i] = bnd_param[i].param;
   else 
     {
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
     }
  }

wrapup:
  EMWRAPUP(*EMmsg,status,"In EMSbsedge.EMbndtobs")
  return(status);
}

end implementation EMSbsedge;
