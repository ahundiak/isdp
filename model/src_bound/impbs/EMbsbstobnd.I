/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
#include "emsmacros.h"

method EMbstobnd(IGRlong *EMmsg;IGRint num_param;
		IGRdouble  *bs_param;
		struct EMSedgebound *bnd_param)
/* *********************************************

   This method when given a bspline parameter returns the same in an
   edgebound format
 
   It may be noted that the span index for a bs edge is always 0.

History
           PP : 05/12/87       Creation date


   ********************************************** */
{
  IGRshort i;
  IGRlong status;
   
  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  for (i=0 ; i < num_param ; i++)
  {
	bnd_param[i].span_inx = 0;
	bnd_param[i].param  = bs_param[i];
  }

wrapup:

  EMWRAPUP(*EMmsg,status,"In EMSbsedge.EMbstobnd")
  return(status);
}

end implementation EMSbsedge;
