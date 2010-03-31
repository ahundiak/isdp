/* 
  DESCRIPTION

    This method is used to initialize a point_to_point distance constraint
    along a measurement axis.  The constraint is defined by four ptvar
    objects.
  
    pt_ids[0] = Origin pt (ORIGIN).
    pt_ids[1] = Measure pt (MEASURE).
    pt_ids[2:3] = Axis definition pts (AXIS_1 & AXIS_2).
  

  HISTORY
  
    RA 	:  6/8/92   : Creation
    RA  :  7/16/92  : Special case handling when the math routine returns
                      z-axis as the perpendicular vector to y-axis.  Trapped
                      it and changed it to x-axis.
 Sudha  :  07/02/93 : Modified for BSprototypes ansification
    RA  :  12/02/93 : Special case handling when the math routine returns
                      z-axis as the perpendicular vector to x-axis.  Trapped
                      it and changed it to y-axis.
*/

class implementation SKaxisptpt;

#include <math.h>
#include "bserr.h"
#include "bsparameters.h"
#include "bsorthovec.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1

#define ORIGIN  0
#define MEASURE 1
#define AXIS_1  2
#define AXIS_2  3

from SKvariable import SKgetvar;

method SKinit (IGRlong *msg; IGRushort options;
               struct GRmd_env *md_env;
               IGRint num_pts; GRobjid *pt_ids;
               IGRushort cnstr_props;
               GRobjid *geom_handle;
               IGRchar *moreinfo)
{
  IGRboolean 	status;
  int 		i;
  long 		msg_loc, stat_OM;
  double 	dist, lentol;
  IGRpoint 	pts[4];
  IGRvector 	measure_vec, hor_axis, ver_axis;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * We assume that 4 object ids are passed into the constraint.
   */
  EMerr_hndlr (num_pts != 4, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Invoke this objects parents implementation of this message. This
   * implementation establishes the channel connections and sets the 
   * "props".
   */

  stat_OM = om$send (mode = OM_e_wrt_message, msg = message
             SKconstraint.SKinit (&msg_loc, options, md_env, num_pts, pt_ids,
             cnstr_props, geom_handle, moreinfo),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * This object needs to become an expression. Obtain the initial value
   * of this expression as the relevant distance between the two points.
   */

  for (i = ORIGIN; i <= AXIS_2; i++)
  {
    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
               NULL, NULL, pts[i]), targetid = pt_ids[i]);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  /*
   * Obtain the distance that this constraint represents depending on
   * whether it is along the axis or perpendicular to it.
   */

  BSmkvec (&msg_loc, measure_vec, pts[ORIGIN], pts[MEASURE]);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
 
  BSmkvec (&msg_loc, hor_axis, pts[AXIS_1], pts[AXIS_2]);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  status = BSnorvec (&msg_loc, hor_axis);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
 
  if (ME.SKconstraint->props & SK_HORIZONTAL)
  {
    dist = BSdotp (&msg_loc, measure_vec, hor_axis);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  }
  else
  {
    /*
     * Special case handling if the hor_axis is the Y-AXIS ... in that
     * case the orhogonal vector should be X-AXIS and not the Z-AXIS.
     * Similar case when hor_axis is the X-AXIS ... orthovec shd be Y-AXIS.
     */
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
    if ( fabs(hor_axis[0]) <= lentol)
    {
      ver_axis[0] = 1.0;
      ver_axis[1] = ver_axis[2] = 0.0;
    }
    else if ( fabs (hor_axis[1]) <= lentol)
    {
      ver_axis[1] = 1.0;
      ver_axis[0] = ver_axis[2] = 0.0;
    }
    else
    {
      BSorthovec (&msg_loc, hor_axis, ver_axis); 
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }
    dist = BSdotp (&msg_loc, measure_vec, ver_axis);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  }

  dist = fabs(dist);

  if (ME.SKconstraint->props & SK_HALFVALUE)
    dist *= 2.0;

  /*
   *  Initialize myself as an expression (unless inhibited).
   */
  if (! (options & SK_OPT_NO_CREATE_EXPR))
    stat_OM = om$send (msg = message SKexplicit.SKcreate_expression (&msg_loc,
               NULL, dist), targetid = my_id);
  else
    stat_OM = om$send (msg = message SKexplicit.SKputval (&msg_loc, 
               NULL, dist, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKaxisptpt.SKinit");
  return (stat_OM);
}

end implementation SKaxisptpt;
