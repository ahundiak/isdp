/* ###################   APOGEE COMPILED   ################## */
class implementation EMSopenloop;

#include "EMS.h"
method EMlinintgrl(IGRlong 	*msg;
		   struct IGRbsp_surface *surf;
		   IGRchar	*char_surf_info;
		   IGRlong	 option;
		   IGRlong	*loop_counter;
		   IGRdouble	*density;
		   IGRdouble	*lp_int)
{
  *msg = EMS_S_Success;
  return(OM_S_SUCCESS);
}

end implementation EMSopenloop;

