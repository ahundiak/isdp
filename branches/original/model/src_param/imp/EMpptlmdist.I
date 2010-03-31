/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION
  
    This method return the minimum distance between this parametric point
    and a given infinite line. It also returns the parameter on the line
    at which this minimum distance situation occurs.


  HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification

*/

class implementation EMSparampt;

#include "bserr.h"
#include "bsdistptli.h"

method EMlnmindist (IGRlong *msg; IGRushort opts;
                    IGRshort *mattyp; IGRmatrix mat;
                    struct IGRline *line; IGRdouble *mindist)
{
  IGRlong msg_loc, stat_OM;
  struct EMSgeomdata ptgeom;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *mindist = MAXDOUBLE;

  /*
   * Obtain my point geometry
   */

  stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
             mattyp, mat, &ptgeom), targetid = my_id);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  /*
   * Determine the distance between the point and the input line.
   */

  BSdistptli (&msg_loc, ptgeom.point, line->point1, line->point2, mindist);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidArg, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpptlmdist");
  return (stat_OM);
}

end implementation EMSparampt;
