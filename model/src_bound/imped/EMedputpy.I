/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
method EMputpygeom (IGRlong *msg; IGRint before_ptinx; IGRboolean reverse;
                    struct IGRpolyline *inpygeom;
		    IGRboolean check_constraints;
		    struct EMSpartolbasis *partolbasis;
		    struct EMSpartedinfo *part;
		    struct EMSdataselect *surf_data;
		    IGRshort *mattyp;
		    IGRmatrix mat)
{
  *msg = EMS_I_InvalidArg;
  return(OM_S_SUCCESS);
}

end implementation EMSedge;
