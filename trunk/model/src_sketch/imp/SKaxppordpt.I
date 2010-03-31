/*
  DESCRIPTION

    This method orders the object ids associated with the Distance along
    a measurement axis constraint.  It swaps the Origin and Measure in
    case Measure is either Axis_1 or Axis_2.  

  HISTORY

    6/29/92   Rajiv Agrawal     Creation
*/

class implementation SKaxisptpt;

#include "OMmacros.h"

#define ORIGIN  0
#define MEASURE 1
#define AXIS_1  2
#define AXIS_2  3

method SKorder_points(IGRlong *EMmsg; unsigned short options;
                      IGRint num_pts; GRobjid *pt_ids;
                      IGRchar *moreinfo)
{
 IGRlong status;
 GRobjid tempid;
 
 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 if (num_pts != 4)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }
 
 /*
  * Do 3-point processing ... if AXIS_1 or AXIS_2 is the same as MEASURE
  * and the other AXIS point is not the same as ORIGIN (i.e. its not a 2-obj
  * case), then swap ORIGIN and MEASURE.  This way the missing object will
  * always be in the ORIGIN position.
  */
 if ((pt_ids[AXIS_1] == pt_ids[MEASURE] && pt_ids[AXIS_2] != pt_ids[ORIGIN]) ||
     (pt_ids[AXIS_2] == pt_ids[MEASURE] && pt_ids[AXIS_1] != pt_ids[ORIGIN]))
 {
   tempid = pt_ids[ORIGIN];
   pt_ids[ORIGIN] = pt_ids[MEASURE];
   pt_ids[MEASURE] = tempid;
 }
 
wrapup:
 EMWRAPUP (*EMmsg, status, "SKaxisptpt.SKorder_points");
 return (status);
}

end implementation SKaxisptpt;
