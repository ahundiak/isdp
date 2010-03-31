class implementation EMSpartedge;

#include "OMminimum.h"
#include "OMmacros.h"

method EMpostgeom
(
  IGRchar *edgeom
)
{
  struct EMSedgebound *p_bounds=NULL;

  p_bounds = (struct EMSedgebound *) edgeom;

  OM_BLOCK_MOVE (p_bounds, ME.EMSpartedge->boundary, 
                 2 * sizeof (struct EMSedgebound));

  return (OM_S_SUCCESS);
}

end implementation EMSpartedge;

