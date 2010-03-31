/*
  DESCRIPTION

    This method return the locus of this geometric constraint
    back to the caller. In this case, it is the surface/curve geometry
    of the parent element. In special cases, special geometries are
    returned:
    a) If parent is a planar surface, the plane is returned.
    b) If parent is a line-segment, an infinite line is returned.
    c) If parent is a point, a point is returned.

  HISTORY

    SS  :  06/22/91  :  Creation
*/

class implementation EMSptelcnstr;

#include "parametric.h"

#define X 0
#define Y 1
#define Z 2

method EMgetgeomlocus (IGRlong *msg; IGRushort opts;
                       IGRshort *mattyp; IGRmatrix mat;
                       struct EMSgeomdata *geomlocus)
{
  IGRlong msg_loc, stat_OM;
  struct GRid my_grid;
  extern IGRlong EMgetdrivgeom();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain my parents geometry. This is the locus.
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  stat_OM = EMgetdrivgeom (&msg_loc, NULL, mattyp, mat, &my_grid, TRUE,
             NULL, geomlocus);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMptellocus");
  return (stat_OM);
}

end implementation EMSptelcnstr;

