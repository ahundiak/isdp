class implementation SKrelornt;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include <math.h>
#include <values.h>
#include "bsvalues.h"
#include "OMmacros.h"
#include "SKdef.h"
#include "maang2vc.h"

#define FIRST  0
#define SECOND 1
#define THIRD  2
#define FOURTH 3

#define X 0
#define Y 1
#define Z 2

extern GRclassid OPP_SKexplicit_class_id;

from SKvariable import SKgetvar;
from SKexplicit import SKcreate_expression, SKputval;

%safe
static void swapobj();
%endsafe

static void swapobj (ids, inx1, inx2)
GRobjid *ids;
IGRint inx1, inx2;
{
  GRobjid tmpobj;

  tmpobj = ids[inx1];
  ids[inx1] = ids[inx2];
  ids[inx2] = tmpobj;

  return;
}


method SKinit (IGRlong *msg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)
{
  IGRboolean dupfound, supplement_angle;
  IGRint i, j;
  IGRlong stat_OM, msg_loc;
  IGRdouble angle, angvals[3];
  IGRpoint pts[2][2];
  IGRvector vec[2];
  GRobjid loc_pt_ids[4], tmp_pt_ids[4], ptobjs[2][2], dupptobj;
  GRclassid myclass;
  struct GRid my_grid;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  dupptobj = NULL_OBJID;
  dupfound = 0;
  i = 0;
  j = 0;

  EMerr_hndlr (num_pts < 3 || num_pts > 4, *msg, EMS_E_InvalidArg, ret_end);

  /*
   *   In the case where there are four points input, the angle is formed
   * between the two segments made up by successive segments. The relative
   * ordering of the points within the segment determines the vector being
   * used to obtain the angle. The information on how to order these
   * points is indirectly available in the "diminfo" being passed in as
   * moreinfo. If these four points are unique, the relative ordering can be
   * stored via the channel connections made to these points. This ordering
   * would reflect the correct quadrant. 
   *   But, if the points have the vertex duplicated to form the segments,
   * then there are really three points and since channel connection can be
   * made only to unique objects, this quadrant information would be lost.
   * In this case, all we need to store is whether the quadrant chosen gave
   * a supplement of the included angle or not. So this information is
   * obtained beforehand and stored as a property-bit. The three points are
   * then connected as noted above. While obtaining the angle, it's supplement
   * is obtained.
   */

  OM_BLOCK_MOVE (pt_ids, loc_pt_ids, num_pts * sizeof (GRobjid));
  supplement_angle = FALSE;
  if (num_pts == 4)
    {
    dupfound = FALSE;
    for (i=0; i<num_pts-1; i++)
      {
      for (j=i+1; j<num_pts; j++)
        if (loc_pt_ids[i] == loc_pt_ids[j])
          {
          dupfound = TRUE;
          dupptobj = loc_pt_ids[i];
          break;
          }
      if (dupfound)
        break;
      }

    if (dupfound)
      {
      OM_BLOCK_MOVE (pt_ids, tmp_pt_ids, num_pts * sizeof (GRobjid));
      stat_OM = om$send (msg = message SKconstraint.SKorder_points (&msg_loc,
                 NULL, num_pts, tmp_pt_ids, moreinfo), 
                 targetid = my_id);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

      if (tmp_pt_ids[SECOND] == dupptobj)
        supplement_angle = !supplement_angle;
      if (tmp_pt_ids[FOURTH] == dupptobj)
        supplement_angle = !supplement_angle;
      }
    }

  /*
   * If there are four points and the vertex point is repeated twice in the
   * list, get rid of this duplication. The point that was repeated is made
   * the first point only unique points allowed to be connected up.
   */

  if (num_pts == 4)
  {
    if (dupfound)
    {
      swapobj (loc_pt_ids, j, num_pts-1);
      swapobj (loc_pt_ids, i, 0);
      num_pts--;
    }
  }

  /*
   * Invoke this objects parents implementation of this message. This
   * implementation establishes the channel connections and performs other
   * initializations.
   */

  stat_OM = om$send (mode = OM_e_wrt_parent, msg = message SKrelornt.SKinit
             (&msg_loc, options, md_env, num_pts, loc_pt_ids,
             cnstr_props | (supplement_angle ? SK_SUPPLEMENT : NULL),
             geom_handle, moreinfo), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * This object needs to become an expression if it is subclassed from
   * the expression class. If the angle to be computed was a supplement,
   * the sense of the rotation may have gotten toggled. This would result in
   * a negative value. So always take the absolute value.
   */

  om$get_classid (object = me, p_classid = &myclass);
  if (om$is_ancestry_valid (subclassid = myclass,
       superclassid = OPP_SKexplicit_class_id) == OM_S_SUCCESS)
    {
    stat_OM = om$send (msg = message SKrelornt.SKgetrelornt (&msg_loc, NULL,
               NULL, ptobjs), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidArg,
     ret_end);
   
    for (i=0; i<2; i++)
      {
      for (j=0; j<2; j++)
        {
        stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
                   NULL, NULL, pts[i][j]), targetid = ptobjs[i][j]);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidArg,
         ret_end);
        }
      for (j=X; j<=Z; j++)
        vec[i][j] = pts[i][1][j] - pts[i][0][j];
      }

    MAang2vc (&msg_loc, vec[FIRST], vec[SECOND], angvals);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
    angle = angvals[0] * 180.0 / M_PI;
    if (supplement_angle)
      angle = 180-angle;
    angle = fabs (angle);

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
      stat_OM = om$send (msg = message SKexplicit.SKcreate_expression
                 (&msg_loc, NULL, angle), targetid = my_id);
    else
      stat_OM = om$send (msg = message SKexplicit.SKputval (&msg_loc, 
                 NULL, angle, NULL), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKrelornt.SKinit");
  return (stat_OM);
}

end implementation SKrelornt;
