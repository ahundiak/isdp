/* ###################   APOGEE COMPILED   ################## */
/*
   Considering the point edge to be a degenerate segment, two identical points
   are returned.
*/

class implementation EMSptedge;

#include "EMS.h"
#include "OMmacros.h"


method EMgetpygeom (IGRlong *EMmsg; IGRint from_spaninx; IGRint num_spans;
                    IGRboolean reverse; struct EMSpartedinfo *partinfo;
                    struct IGRpolyline *pygeom;
                    struct EMSpartolbasis *partolbasis;
                    IGRushort options)
{
  IGRint sts, size;
  
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  size = 2 * sizeof(IGRdouble);

  if (!pygeom->points)
    pygeom->points = (IGRdouble *) om$malloc (size = 4 * sizeof (IGRdouble));
  EMerr_hndlr (!pygeom->points, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  OM_BLOCK_MOVE(ME.EMSptedge->point, pygeom->points, size);
  OM_BLOCK_MOVE(ME.EMSptedge->point, &pygeom->points[2], size);
  pygeom->num_points = 2;


wrapup:

  if(1&*EMmsg&sts) *EMmsg = EMS_I_DegenerateEdge;
  EMWRAPUP(*EMmsg, sts, "In EMSptedge.EMgetpygeom");
  return(sts);
}

end implementation EMSptedge;
