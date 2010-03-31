class implementation EMSptedge;

#include "OMminimum.h"
#include "OMmacros.h"

#include "PWminimum.h"

method EMpostgeom
(
  IGRchar *edgeom
)
{
  PWpoint2d *p_pt;

  p_pt = (PWpoint2d *) edgeom;

  ME.EMSedge->ed_props = 0;
  ME.EMSedge->curve_type = 0;

  OM_BLOCK_MOVE (p_pt, ME.EMSptedge->point, 3 * sizeof (IGRdouble));
  
  return (OM_S_SUCCESS);
}

end implementation EMSptedge;

