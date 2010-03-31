/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"

method EMextend_geom( IGRlong *EMmsg;
		      IGRdouble *extnd_pt;
		      IGRint *location;
		      IGRboolean replace_endpt;
		      IGRdouble *mindist;
		      struct EMSpypoint *outpypoint;
		      struct IGRpolyline *new_geom;
		      struct EMSpartolbasis *partolbasis;
                      IGRushort option;
                      struct GRid *srf_id;
                      struct IGRbsp_surface *srf_geom;
                      IGRmatrix matrix;
                      IGRshort *mx_type)


{
  *EMmsg = EMS_I_InvalidArg;
  return(OM_S_SUCCESS);
}

end implementation EMSedge;
