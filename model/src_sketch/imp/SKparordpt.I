class implementation SKparallel;

/*
   HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "OMmacros.h"
#include "bserr.h"
#include "bsdotp.h"

from SKvariable import SKgetvar;

method SKorder_points(IGRlong *msg; IGRushort options;
                      IGRint num_pts; GRobjid *pt_ids;
                      IGRchar *moreinfo)
{

 IGRdouble   pts[6], ref_vec[3], test_vec[3], dotp;
 IGRlong     OM_stat, mthd_stat, rc;
 IGRint      ptix, i;
 GRobjid     dum_id;


 /* ************************************************************ */

 *msg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 /*
  * o Get vector of first line.
  * o Make sure that the points of the rest of the lines are ordered
  *   such that dot product among these vectors is always +ve.
  */

 for (ptix = 0; ptix < 2; ptix++)
 {
  OM_stat = om$send (msg = message SKvariable.SKgetvar (&mthd_stat, NULL, 
                      NULL, NULL, &pts[3*ptix]),
                   targetid = pt_ids[ptix]);
  EMerr_hndlr(!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, wrapup);

 } /* for (ptix = 0; ptix < 2; ptix++) */

 for (i = 0; i < 3; i++)
  ref_vec[i] = pts[3+i] - pts[i];

 for (ptix = 2; ptix < num_pts; ptix +=2)
 {
  for (i = 0; i < 2; i++)
  {
   OM_stat = om$send (msg = message SKvariable.SKgetvar (&mthd_stat, 
                       NULL, NULL, NULL, &pts[3*i]),
                      targetid = pt_ids[ptix+i]);
   EMerr_hndlr(!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, wrapup);
  }
 
  for (i = 0; i < 3; i++)
   test_vec[i] = pts[3+i] - pts[i];

  dotp = BSdotp (&rc, ref_vec, test_vec);
  EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

  if (dotp < 0)
  {
   dum_id = pt_ids[ptix];
   pt_ids[ptix] = pt_ids[ptix+1];
   pt_ids[ptix+1] = dum_id;
  }

 } /* for (ptix = 2; ptix < num_pts; ptix=+2) */


wrapup:
 EMWRAPUP (*msg, OM_stat, "SKparallel.SKorder_points");
 return (OM_stat);

}
end implementation SKparallel;
