/*
  DESCRIPTION

    This method return the locus of this geometric constraint
    back to the caller. It is a plane in the world coordinate system.

  HISTORY

    SS  :  02/26/92  :  Creation
    Sudha   06/07/93        modified for BSprototype includes
*/

class implementation EMShvcnstr;

#include "OMmacros.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bscrossp.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1
#define Z 2

method EMgetgeomlocus (IGRlong *msg; IGRushort opts;
                       IGRshort *mattyp; IGRmatrix mat;
                       struct EMSgeomdata *geomlocus)
{
  IGRlong msg_loc, stat_OM;
  IGRint i;
  IGRdouble *pt, *vec;
  IGRpoint origin, parent_pt;
  IGRvector xaxis, yaxis, zaxis;
  struct GRid my_grid;
  struct EMSgeomdata geomdata;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the parent x-axis and y-axis from the plane matrix. If none is
   * forthcoming, return with an error code.
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  stat_OM = EMgetdrivgeom (&msg_loc, NULL, 
             mattyp, mat, &my_grid, TRUE, GEOMDATA_COORD, &geomdata);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, EMS_E_InvalidCase, ret_end);

  OM_BLOCK_MOVE (geomdata.plane.plane_pt, origin, sizeof (IGRpoint));
  OM_BLOCK_MOVE (geomdata.vector, xaxis, sizeof (IGRvector));
  OM_BLOCK_MOVE (geomdata.plane.plane_vec, zaxis, sizeof (IGRvector));
  BScrossp (&msg_loc, zaxis, xaxis, yaxis);
  BSnorvec (&msg_loc, yaxis);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Obtain the parent point (if any). If no parent point exists, then
   * use the plane-origin.
   */

  stat_OM = EMgetdrivgeom (&msg_loc, NULL, mattyp, mat, &my_grid,
             TRUE, GEOMDATA_POINT, &geomdata);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  if (msg_loc == EMS_I_NotFound)
    OM_BLOCK_MOVE (origin, parent_pt, sizeof (IGRpoint));
  else
    OM_BLOCK_MOVE (geomdata.point, parent_pt, sizeof (IGRpoint));

  /*
   * Output the plane that is perpendicular to the above plane and also
   * hor/ver to the axis. The plane-normal is such the it points to
   * +ve X-axis in the case of a vertical or a +ve Y-axis in the case
   * of a horizontal. These direction are flipped if the negative-axis
   * property is on.
   */

  pt = geomlocus->plane.igr_plane.point = geomlocus->plane.plane_pt;
  vec = geomlocus->plane.igr_plane.normal = geomlocus->plane.plane_vec;
  OM_BLOCK_MOVE (parent_pt, pt, sizeof (IGRpoint));
  if (ME.EMScnstr->cnstr_props & EMScnstr_horizontal)
    OM_BLOCK_MOVE (yaxis, vec, sizeof (IGRvector));
  else
    OM_BLOCK_MOVE (xaxis, vec, sizeof (IGRvector));
  if (ME.EMScnstr->cnstr_props & EMScnstr_negative_axis)
    for (i=X; i<=Z; i++)
      vec[i] = -vec[i];
  BSnorvec (&msg_loc, vec);

  geomlocus->geomtype = GEOMDATA_PLANE;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMhvlocus");
  return (stat_OM);
}

end implementation EMShvcnstr;
