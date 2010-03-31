/*
  DESCRIPTION

    This method return the locus of this dimensional constraint
    back to the caller. In this case, it happens to be a plane perpendicular
    to the X (or Y) axis of the dimension that this constraint owns. This
    plane is positioned this expression (D) distance away from the parent
    point.

  HISTORY

    SS  :  06/22/91  :  Creation
    Sudha   06/07/93 :  Modified for BSprototype includes
    Satya   07/21/95 :  Resetting the bit EMS_cnstr_negative bit, in case
                        it is not set properly. TR# 119424719  
*/

class implementation EMSlndmcnstr;

#include "OMmacros.h"
#include "ndmacros.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bsdotp.h"

#define X 0
#define Y 1
#define Z 2

#define PARENT_PT  0
#define CHILD_PT   1

from DMroot import get_info;

method EMgetgeomlocus (IGRlong *msg; IGRushort opts;
                       IGRshort *mattyp; IGRmatrix mat;
                       struct EMSgeomdata *geomlocus)
{
  IGRboolean is_xaxis;
  IGRshort pln_mattyp;
  IGRint i;
  IGRlong msg_loc, stat_OM, stat_func;
  IGRdouble *pln_mat, *dim_axis;
  IGRdouble *plane_pt, *plane_vec, dist;
  IGRpoint parent_pt;
  struct GRmd_env md_env;
  struct EMSgeomdata ptgeom;
  struct GRid my_grid;
  struct diminfo diminfo;
  OM_S_CHANSELECT chan_to_comps;
  IGRpoint child_pt;
  IGRvector child_vec;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the oriented plane-matrix w.r.t which the dimension
   * has been constructed. From this matrix, derive the dimension-axis
   * along which the measurement is done. If no dimension exists,
   * this is an invalid constraint. Recover, by putting this constraint
   * into the delete batch and return GEOMDATA_NULL as the locus.
   */

  if ((md_env.md_env.matrix_type = *mattyp) != MAIDMX)
    OM_BLOCK_MOVE (mat, md_env.md_env.matrix, sizeof (IGRmatrix));
  stat_func = ex$get_modid (mod_osnum = OM_Gw_current_OS, 
               mod_id = &md_env.md_id.objid);
  EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
  md_env.md_id.osnum = OM_Gw_current_OS;
  
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  msg_loc = EMS_E_Fail;
  stat_OM = om$send (msg = message DMroot.get_info ((IGRint *)&msg_loc, &md_env,
             &diminfo), p_chanselect = &chan_to_comps);
  if (EMSerror (stat_OM & msg_loc))
    {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    nd$wait_batch (type = GR_DELETED, nb_obj = 1, l_object = &my_grid);

    *msg = EMS_I_NoSolution;
    stat_OM = OM_S_SUCCESS;
    geomlocus->geomtype = GEOMDATA_NULL;
    goto ret_end;
    }

  if (diminfo.lin_axis == WIN_X_AXIS || diminfo.lin_axis == WIN_Y_AXIS)
    {
    pln_mattyp = diminfo.plan_info.win_plan.matrix_type;
    pln_mat = diminfo.plan_info.win_plan.matrix;
    is_xaxis = diminfo.lin_axis == WIN_X_AXIS;
    }
  else
    {
    pln_mattyp = diminfo.plan_info.act_plan.matrix_type;
    pln_mat = diminfo.plan_info.act_plan.matrix;
    is_xaxis = diminfo.lin_axis == ACT_X_AXIS;
    }
  dim_axis = &pln_mat[is_xaxis ? 0 : 4];

  /*
   * Obtain the parent point in world co-ordinates
   */
 
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  stat_OM = EMgetdrivgeom (&msg_loc, NULL, mattyp, mat, &my_grid, TRUE,
             GEOMDATA_POINT, &ptgeom);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  OM_BLOCK_MOVE (ptgeom.point, parent_pt, sizeof (IGRpoint));

  stat_OM = EMgetdrivgeom (&msg_loc, NULL, mattyp, mat, &my_grid, FALSE,
             GEOMDATA_POINT, &ptgeom);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  OM_BLOCK_MOVE (ptgeom.point, child_pt, sizeof (IGRpoint));
  for (i=X; i<=Z; i++)
    child_vec[i] = child_pt[i] - parent_pt[i];

  if(BSdotp(&msg_loc,child_vec,dim_axis) < 0.0)
    ME.EMScnstr->cnstr_props |= EMScnstr_negative_axis;
  else
    ME.EMScnstr->cnstr_props &= ~EMScnstr_negative_axis;


  /*
   * Construct the plane perpendicular to dimension-axis at a distance D
   * from the parent point. D is the value of this expression. The direction
   * of the dimension-axis vector is chosen based upon the property stored
   * at the time of creation.
   */

  plane_vec = geomlocus->plane.plane_vec;
  OM_BLOCK_MOVE (dim_axis, plane_vec, sizeof (IGRvector));
  BSnorvec (&msg_loc, plane_vec);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

  if (ME.EMScnstr->cnstr_props & EMScnstr_negative_axis)
    for (i=X; i<=Z; i++)
      plane_vec[i] = -plane_vec[i];

  plane_pt = geomlocus->plane.plane_pt;
  OM_BLOCK_MOVE (parent_pt, plane_pt, sizeof (IGRpoint));
  dist = ME.expression->value;
  if (ME.EMScnstr->cnstr_props & EMScnstr_half_value)
    dist /= 2.0;

  if (ME.EMScnstr->cnstr_props & EMScnstr_convert_units)
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &dist, GRIO_DISTANCE, TRUE);
  for (i=X; i<=Z; i++)
    plane_pt[i] += dist * plane_vec[i];

  geomlocus->geomtype = GEOMDATA_PLANE;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMlndmlocus.I");
  return (stat_OM);
}

end implementation EMSlndmcnstr;

