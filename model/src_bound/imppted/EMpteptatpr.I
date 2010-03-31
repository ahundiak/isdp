/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Any parameter on a degenerate span, has the same uv point.

History
	SM	22-Oct-87   1.1 Genesis

*/

class implementation EMSptedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"

method EMptatpr(IGRlong *EMmsg;IGRint num_param;struct EMSedgebound *edparam;
		IGRdouble  *bs_param;
		IGRdouble *point)
{
	IGRlong			j, i;
	IGRint			size;	

 *EMmsg = EMS_I_Degenerate;
	
 size = 2 * sizeof(IGRdouble);
 for(i=0, j=0; i<num_param; i++, j+=2)
  {
    if(edparam) OM_BLOCK_MOVE(ME.EMSptedge->point, &point[j], size);
    else if(bs_param) OM_BLOCK_MOVE(ME.EMSptedge->point, &point[j], size);
  }

 return(OM_S_SUCCESS);
}

end implementation EMSptedge;
