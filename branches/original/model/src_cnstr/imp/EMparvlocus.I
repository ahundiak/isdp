/*
  DESCRIPTION

    This method return the locus of this dimensional constraint
    back to the caller. In this case, it happens to be a vector in the
    world coordinate system.

  HISTORY

    SS  :  07/10/91  :  Creation
    Sudha   06/07/93        modified for BSprototype includes
*/

class implementation EMSparvcnstr;

#include "OMmacros.h"
#include "bserr.h"
#include "bsnorvec.h"

#define X 0
#define Y 1
#define Z 2

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMgetgeomlocus (IGRlong *msg; IGRushort opts;
                       IGRshort *mattyp; IGRmatrix mat;
                       struct EMSgeomdata *geomlocus)
{
  IGRshort parent_mattyp;
  OMuint count;
  IGRint i, j;
  IGRlong msg_loc, stat_OM;
  IGRdouble *vec;
  IGRpoint pts[2];
  IGRvector child_vec;
  IGRmatrix parent_mat;
  struct GRid parentid, my_grid;
  struct IGRbsp_curve *absgcv;
  struct EMSgeomdata vcgeom;
  OM_S_CHANSELECT chan_to_father;
  OM_S_OBJECT_LINKAGE objlist;
  extern IGRlong EMgetabsg();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain my parent.
   */

  EMmake_chanselect (NDfather_father, &chan_to_father);
  stat_OM = om$get_channel_objects (object = me,
             p_chanselect = &chan_to_father, count = &count, size = 1,
             list = &objlist);
  EMerr_hndlr (EMSerror (stat_OM) || count != 1, *msg, EMS_E_InvalidCase,
   ret_end);

  stat_OM = om$send (msg = message NDnode.ASreturn_go (&parentid,
             &parent_mattyp, parent_mat), targetid = objlist.S_objid,
             targetos = objlist.osnum);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * Obtain the vector geometry of the child so that the decision to go
   * with the positive or negative direction of the extracted locus below
   * can be made.
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  stat_OM = EMgetdrivgeom (&msg_loc, EMSsolve_minimum, mattyp, mat, &my_grid,
             FALSE, GEOMDATA_VECTOR, &vcgeom);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, EMS_E_InvalidCase, ret_end);
  OM_BLOCK_MOVE (vcgeom.vector, child_vec, sizeof (IGRvector));

  /*
   * Obtain the geometry of the parent and extract the vector from
   * it. By virtue of the checks during construction of this constraint,
   * one can be assured that the parent-geometry defines a single line.
   */

  stat_OM = EMgetabsg (&msg_loc, &parent_mattyp, parent_mat, parentid.osnum,
             parentid.objid, &absgcv);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  OM_BLOCK_MOVE (absgcv->poles, pts, 2 * sizeof (IGRpoint));
  if (absgcv->rational && absgcv->weights)
    for (i=0; i<2; i++)
      for (j=X; j<=Z; j++)
        pts[i][j] /= absgcv->weights[i];

  vec = geomlocus->vector;
  for (i=X; i<=Z; i++)
    vec[i] = pts[1][i] - pts[0][i];
  BSnorvec (&msg_loc, vec);

 if (ME.EMScnstr->cnstr_props & EMScnstr_negative_axis)
    for (i=X; i<=Z; i++)
      vec[i] = -vec[i];

  geomlocus->geomtype = GEOMDATA_VECTOR;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMparvlocus.I");
  return (stat_OM);
}

end implementation EMSparvcnstr;

