/* ###################   APOGEE COMPILED   ################## */

class implementation EMSptedge;

#include "EMS.h"
#include "OMmacros.h"

method EMputpygeom (IGRlong *EMmsg; IGRint before_ptinx; IGRboolean reverse;
                    struct IGRpolyline *inpygeom;
		    IGRboolean check_constraints;
		    struct EMSpartolbasis *partolbasis;
		    struct EMSpartedinfo *part;
		    struct EMSdataselect *surf_data;
		    IGRshort *mattyp;
		    IGRmatrix mat)
{
  IGRlong	sts = OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;

  if(inpygeom->num_points != 1) {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
  else OM_BLOCK_MOVE(inpygeom->points, ME.EMSptedge->point, 
			2 * sizeof(IGRdouble));
			
wrapup:
  EMWRAPUP(*EMmsg, sts,"In EMSptedge.EMputpygeom");
  return(sts);

}

end implementation EMSptedge;
