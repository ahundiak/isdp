class implementation SKptpt;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

%safe
#include <math.h>
%endsafe

#include "bserr.h"
#include "bsdistptpt.h"

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1

extern GRclassid OPP_SKhvptpt_class_id;

from SKvariable import SKgetvar;

method SKinit (IGRlong *msg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)
{
  IGRint 	i;
  IGRlong 	msg_loc, stat_OM;
  IGRdouble 	dist;
  IGRpoint 	pts[2];
  struct GRid 	my_grid;
  GRclassid 	myclass;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (num_pts != 2, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Invoke this objects parents implementation of this message. This
   * implementation establishes the channel connections and sets the 
   * "props".
   */

  stat_OM = om$send (mode = OM_e_wrt_parent, msg = message
             SKptpt.SKinit (&msg_loc, options, md_env, num_pts, pt_ids,
             cnstr_props, geom_handle, moreinfo),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * This object needs to become an expression. Obtain the initial value
   * of this expression as the relevant distance between the two points.
   */

  for (i=FIRST; i<=SECOND; i++)
    {
    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
               NULL, NULL, pts[i]), targetid = pt_ids[i]);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Obtain the distance that this constraint represents and initialize myself
   * as an expression.
   */

  om$get_classid (object = me, p_classid = &myclass);
  if (om$is_ancestry_valid (subclassid = myclass,
       superclassid = OPP_SKhvptpt_class_id) == OM_S_SUCCESS)
    {
    if (ME.SKconstraint->props & SK_HORIZONTAL)
      dist = fabs (pts[SECOND][X] - pts[FIRST][X]);
    else
      dist = fabs (pts[SECOND][Y] - pts[FIRST][Y]);
    }
  else
    {
    dist = BSdistptpt (&msg_loc, pts[FIRST], pts[SECOND]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }
  if (ME.SKconstraint->props & SK_HALFVALUE)
    dist *= 2.0;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  EMcnvt_db_dim_units (&msg_loc, &my_grid, &dist, GRIO_DISTANCE, FALSE);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  if (msg_loc == EMS_I_Modified)
    ME.SKconstraint->props |= SK_UNITSCONVERT;

  if (! (options & SK_OPT_NO_CREATE_EXPR))
    stat_OM = om$send (msg = message SKexplicit.SKcreate_expression (&msg_loc,
               NULL, dist), targetid = my_id);
  else
    stat_OM = om$send (msg = message SKexplicit.SKputval (&msg_loc, 
               NULL, dist, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKptpt.SKinit");
  return (stat_OM);
}

end implementation SKptpt;
