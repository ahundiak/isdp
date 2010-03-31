class implementation SKcollinear;

#include <math.h>
#include "OMmacros.h"
#include "bserr.h"

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define X 0
#define Y 1

#define MAXDOTPROD  1.0

from SKvariable import SKgetvar;

method SKorder_points(IGRlong *msg; IGRushort options;
                      IGRint num_pts; GRobjid *pt_ids;
                      IGRchar *moreinfo)
{
  IGRshort i, j;
  IGRshort inx_start, inx_mid, inx_stop, mininx_start, mininx_mid, mininx_stop;
  IGRlong msg_loc, stat_OM;
  IGRdouble mindotp, dotp, len1, len2;
  IGRpoint pts[3];
  IGRvector vec1, vec2;
  GRobjid loc_pt_ids[3];
  extern IGRdouble BSdotp();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the values of the points defining
   * the collinearity.
   */

  for (i=FIRST; i<=THIRD; i++)
    {
    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL, 
               NULL, NULL, pts[i]), targetid = pt_ids[i]);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Find an order such that the dot-product between the unit vectors formed
   * by (mid-point -> start-point) and (mid-point -> stop-point) has the
   * algebraically minimum value.
   */

  mindotp = MAXDOTPROD;
  mininx_start = FIRST;
  mininx_mid = SECOND;
  mininx_stop = THIRD;
  for (i=FIRST; i<=THIRD; i++)
    {
    inx_mid = i;
    inx_start = i == FIRST ? SECOND : FIRST;
    inx_stop =  i == THIRD ? SECOND : THIRD;
    
    len1 = len2 = 0.0;
    for (j=X; j<=Y; j++)
      {
      vec1[j] = pts[inx_start][j] - pts[inx_mid][j];
      len1 += vec1[j] * vec1[j];
      vec2[j] = pts[inx_stop][j] - pts[inx_mid][j];
      len2 += vec2[j] * vec2[j];
      }
    len1 = sqrt (len1);
    len2 = sqrt (len2);
    for (j=X; j<=Y; j++)
      {
      vec1[j] /= len1;
      vec2[j] /= len2;
      }
    
    dotp = vec1[X] * vec2[X] + vec1[Y] * vec2[Y];
    if (dotp < mindotp)
      {
      mindotp = dotp;
      mininx_start = inx_start;
      mininx_mid = inx_mid;
      mininx_stop = inx_stop;
      }
    }

  /*
   * Reorder the points for output
   */

  loc_pt_ids[FIRST] = pt_ids[mininx_start];
  loc_pt_ids[SECOND] = pt_ids[mininx_mid];
  loc_pt_ids[THIRD] = pt_ids[mininx_stop];
  OM_BLOCK_MOVE (loc_pt_ids, pt_ids, 3 * sizeof (GRobjid));

ret_end:
 EMWRAPUP (*msg, stat_OM, "SKcollinear:SKorder_points");
 return (stat_OM);
}
end implementation SKcollinear;
