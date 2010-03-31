/*

Name
  EMinit

Abstract
  Create a 3-D dimensional constraint.
  
Synopsis

Description

Return Value

Notes

Index

Keywords
  associative,dimension, 3-D constraint

History
  ???????? : SS            : creation
  04/06/93 : Rajiv Agrawal : Added a dimension plane as the parent of the constraint so
                             the assoc graph updates properly.  (TR#119300858)
  Sudha   06/07/93        modified for BSprototype includes

  Satya   07/21/95         : In case of dimensions placed along measurement
                             axis, the EMS_cnstr_negative bit is not set
                             properly. This is corrected.

 */
class implementation EMSlndmcnstr;

#include "OMmacros.h"
#include "dimsrc.h"
#include "diminfo.h"
#include "EMSasopts.h"
#include "bserr.h"
#include "bsdotp.h"

#define X 0
#define Y 1
#define Z 2

#define PARENT_1  0
#define PARENT_2  1
#define CHILD     0

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSparameter import EMpasschild;
from EMSassoc import EMexternal_constraint_changed;

method EMinit (IGRlong *msg; IGRushort opts;
               struct GRmd_env *md_env;
               IGRint num_parents; 
               struct GRid *parents; 
               IGRushort cnstr_props; IGRchar *moreinfo;
               IGRint num_children;
               struct GRid *children)
{
  IGRboolean stat_func;
  IGRchar *nameptr, name_mem[DI_PATH_MAX], valchar[25];
  IGRshort s_msg_loc;
  IGRlong inx;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  IGRdouble dist, *dim_axis;
  IGRpoint parent_pt, child_pt;
  IGRvector child_vec;
  struct GRid my_grid, ptids[2];
  struct EMSlndminfo *lndminfo;
  struct EMSgeomdata ptgeom;
    
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (num_parents != 1 || num_children != 1, *msg, EMS_E_InvalidArg,
   ret_end);

  /*
   * Obtain the distance between the parent and the child point.
   */

  lndminfo = (struct EMSlndminfo *) moreinfo;
  dist = lndminfo->diminfo.dim_value;
  if (cnstr_props & EMScnstr_half_value)
    dist *= 2.0;

  /*
   * Establish the owner-component relationship between this constraint
   * and the dimension handle if requested.
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  if (opts & EMScnstr_connect_geomhandle)
  {
    inx = 0;
    stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
               &my_grid, &inx), targetid = lndminfo->dim.objid,
               targetos = lndminfo->dim.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  /*
   * If this expression has a dimension handle, convert the value into
   * the units of the dimension. If a conversion was necessary, then
   * record this in the props field.
   */

  EMcnvt_db_dim_units (&msg_loc, &my_grid, &dist, GRIO_DISTANCE, FALSE);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  if (msg_loc == EMS_I_Modified)
    cnstr_props |= EMScnstr_convert_units;
  
  /*
   * Create myself as an expression with this value
   */
  
  if (!lndminfo->name)
  {
    nameptr = name_mem;
    stat_func = EMdefnewname (nameptr, OM_Gw_current_OS, EMSscalar);
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);
  }
  else
    nameptr = lndminfo->name;

  sprintf (valchar, "%20.9lf", dist);

  stat_OM = om$send (msg = message expression.create (nameptr, valchar,
             &s_msg_loc), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & s_msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Establish the parent-child connections
   */

  ptids[PARENT_1] = *parents;
  ptids[PARENT_2] = lndminfo->diminfo.list[DIM_ROOT_PLAN];
  stat_OM = om$send (msg = message NDnode.NDconnect (2, ptids,
             NULL_GRID, ND_ADD), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

  ptids[CHILD] = *children;
  stat_OM = om$send (msg = message NDnode.NDconnect (1, &my_grid, NULL_GRID,
             ND_ADD), targetid = ptids[CHILD].objid,
             targetos = ptids[CHILD].osnum);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * Initialize properties indicating whether this constraint is along
   * the horizontal or vertical. Also, determine if the dimension is 
   * directed in the positive or the negative direction of the axis.
   */

  ME.EMScnstr->cnstr_props = cnstr_props;
  if (lndminfo->diminfo.lin_axis == WIN_X_AXIS ||
      lndminfo->diminfo.lin_axis == ACT_X_AXIS)
  {
    ME.EMScnstr->cnstr_props |= EMScnstr_horizontal;
    inx = XAXIS_PLANEMAT_INX;
  }
  else
    inx = YAXIS_PLANEMAT_INX;

  stat_OM = EMgetdrivgeom (&msg_loc, NULL, &md_env->md_env.matrix_type,
             md_env->md_env.matrix_type, &my_grid, TRUE,
             GEOMDATA_POINT, &ptgeom);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  OM_BLOCK_MOVE (ptgeom.point, parent_pt, sizeof (IGRpoint));

  stat_OM = EMgetdrivgeom (&msg_loc, NULL, &md_env->md_env.matrix_type,
             md_env->md_env.matrix_type, &my_grid, FALSE,
             GEOMDATA_POINT, &ptgeom);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  OM_BLOCK_MOVE (ptgeom.point, child_pt, sizeof (IGRpoint));
  
  for (i=X; i<=Z; i++)
    child_vec[i] = child_pt[i] - parent_pt[i];
  /* The dim_axis was being computed from win_plan instead of act_plan
     so for the dimensions placed along measurement axis, the negative
     bit got wrongly set   - Satya 
  */
  dim_axis = &lndminfo->diminfo.plan_info.act_plan.matrix[inx];


  if(BSdotp (&msg_loc, child_vec, dim_axis) < 0.0) 
    ME.EMScnstr->cnstr_props |= EMScnstr_negative_axis;

  /*
   * The addition of this constraint causes the child object to be
   * externally constrained. Record this fact.
   */

  om$send (msg = message EMSparameter.EMpasschild (&msg_loc, NULL,
   message EMSassoc.EMexternal_constraint_changed (&msg_loc,
   EMext_const_chg_CONSTRAINT_ADDED)), targetid = children->objid,
   targetos = children->osnum);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSlndmcon.I");
  return (stat_OM);
}

end implementation EMSlndmcnstr;
