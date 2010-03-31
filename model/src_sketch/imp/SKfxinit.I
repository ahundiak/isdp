class implementation SKfixang;

/*
   HISTORY
	
	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include <values.h>
%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "dimplan.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimcomplex.h"
#include "diminfo.h"
#include "dimangular.h"
#include "bserr.h"
#include "maang2vc.h"
#include "bsnorvec.h"

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1
#define Z 2

#define REVERSE_ORIG  ORIG_START

from DMsrc import DMgive_src_info;
from SKmgr import SKgetornt;
from SKvariable import SKgetvar, SKgetmgr;

method SKinit (IGRlong *msg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)
{
  IGRboolean horizontal, negative_axis, clockwise;
  IGRint i, axis_label;
  IGRlong msg_loc, stat_OM;
  IGRdouble angle, angvals[3];
  IGRpoint pts[2];
  IGRvector mvec, ovec;
  GRobjid loc_pt_ids[2];
  struct GRid axis_id, my_grid;
  struct diminfo *diminfo;
  struct dim_src_info dim_src_info;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (num_pts != 2, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * If "moreinfo" has been passed in a) determine if the orthogonal origin
   * axis is vertical or horizontal, b) if this axis vector is in the negative
   * direction of the natural axes, c) if the measurement is made clockwise
   * from the origin or counter-clockwise. If no "moreinfo" is passed in,
   * the following assumptions are made: a) origin axis is horizontal,
   * b) the axis direction is positive and c) the measurement is 
   * counter-clockwise.
   */

  if (moreinfo)
    {
    diminfo = (struct diminfo *) moreinfo;
    axis_id = diminfo->list[DIM_CPX_ORIG];
    stat_OM = om$send (msg = message DMsrc.DMgive_src_info ((int *) &msg_loc,
               md_env, &dim_src_info), targetid = axis_id.objid,
               targetos = axis_id.osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    axis_label = dim_src_info.var.dm_axis.axis;
    if (axis_label == WIN_X_AXIS || axis_label == ACT_X_AXIS)
      horizontal = TRUE;
    else
      horizontal = FALSE;

    if (diminfo->ang_sector & REVERSE_ORIG)
      negative_axis = TRUE;
    else
      negative_axis = FALSE;

    if (diminfo->ang_sector & CLOCK_WISE)
      clockwise = TRUE;
    else
      clockwise = FALSE;
    }
  else
    {
    horizontal = TRUE;
    negative_axis = FALSE;
    clockwise = FALSE;
    }
  
  if (horizontal)
    cnstr_props |= SK_HORIZONTAL;
  else
    cnstr_props &= ~SK_HORIZONTAL;

  if (negative_axis)
    cnstr_props |= SK_NEGATIVE_AXIS;
  else
    cnstr_props &= ~SK_NEGATIVE_AXIS;

  if (clockwise)
    cnstr_props |= SK_CLOCKWISE_ANGLE;
  else
    cnstr_props &= ~SK_CLOCKWISE_ANGLE;

  /*
   * Invoke this objects parents implementation of this message. This
   * implementation establishes the channel connections and orders the
   * points and fills in the properties.
   */

  OM_BLOCK_MOVE (pt_ids, loc_pt_ids, 2 * sizeof (GRobjid));
  stat_OM = om$send (mode = OM_e_wrt_parent, msg = message SKfixang.SKinit
             (&msg_loc, options, md_env, 2, loc_pt_ids, cnstr_props,
             geom_handle, moreinfo), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * This object needs to become an expression.
   */

  stat_OM = om$send (msg = message SKabsornt.SKgetabsornt (&msg_loc, NULL,
             NULL, loc_pt_ids), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidArg, ret_end);
  
  for (i=FIRST; i<=SECOND; i++)
    {
    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
               NULL, NULL, pts[i]), targetid = loc_pt_ids[i]);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  for (i=X; i<=Z; i++)
    mvec[i] = pts[SECOND][i] - pts[FIRST][i];
  BSnorvec (&msg_loc, mvec);

  if (!horizontal)
    {ovec[Y] = 1.0; ovec[X] = ovec[Z] = 0.0;}
  else
    {ovec[X] = 1.0; ovec[Y] = ovec[Z] = 0.0;}
  
  if (negative_axis)
    for (i=X; i<=Z; i++)
      ovec[i] = -ovec[i];

  MAang2vc (&msg_loc, clockwise ? mvec : ovec, clockwise ? ovec : mvec,
   angvals);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
  angle = angvals[0] * 180.0 / M_PI;

  /*
   * If this expression has a dimension handle, convert the value into
   * the units of the dimension. If a conversion was necessary, then
   * record this in the props field.
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  EMcnvt_db_dim_units (&msg_loc, &my_grid, &angle, GRIO_ANGLE, FALSE);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  if (msg_loc == EMS_I_Modified)
    ME.SKconstraint->props |= SK_UNITSCONVERT;
  
  /*
   * Initialize myself as an expression, unless inhibited
   */

  if (! (options & SK_OPT_NO_CREATE_EXPR))
    stat_OM = om$send (msg = message SKexplicit.SKcreate_expression (&msg_loc,
               NULL, angle), targetid = my_id);
  else
    stat_OM = om$send (msg = message SKexplicit.SKputval (&msg_loc, 
               NULL, angle, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKfixang.SKinit");
  return (stat_OM);
}

end implementation SKfixang;
