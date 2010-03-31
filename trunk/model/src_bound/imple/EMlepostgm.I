class implementation EMSlinedge;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "PWminimum.h"
#include "PWgmdata.h"

method EMpostgeom
(
  IGRchar *edgeom
)
{
  struct PWpoly2d *p_poly=NULL;

  p_poly = (struct PWpoly2d *) edgeom;

  ME.EMSedge->ed_props = 0;
  ME.EMSedge->curve_type = 0;

  ME.EMSlinedge->num_points = p_poly->num_pts;

  om$vla_set_dimension (varray = ME.EMSlinedge->points,
                        size = p_poly->num_pts * 2);
  OM_BLOCK_MOVE (p_poly->p_pts, ME.EMSlinedge->points, p_poly->num_pts * 2 *
                 sizeof (double));

  return (OM_S_SUCCESS);
}

end implementation EMSlinedge;

