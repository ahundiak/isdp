/*
  DESCRIPTION
  
    This method return the minimum distance between the geometric
    representation of this vector and a given infinite line. 


 HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification

*/

class implementation EMSparamvc;

#include <math.h>
#include "ma.h"
#include "ma2pt2di.h"
#include "ma2lnpro.h"
#include "ma2lndis.h"

method EMlnmindist (IGRlong *msg; IGRushort opts;
                    IGRshort *mattyp; IGRmatrix mat;
                    struct IGRline *line; IGRdouble *mindist)
{
  IGRlong msg_loc, stat_OM;
  IGRdouble t1, t2;
  IGRpoint point1, point2;
  struct EMSgeomdata vcgeom;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *mindist = MAXDOUBLE;

  /*
   * Obtain my vector geometry
   */

  stat_OM = om$send (msg = message EMSparameter.EMgetdimgeom (&msg_loc, NULL,
             mattyp, mat, NULL, NULL, &vcgeom, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  /*
   * Determine the distance between the line and the input line.
   */

  MA2lndis (&msg_loc, &vcgeom.line.igr_line, line, mindist);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_InvalidArg, ret_end);
  MA2lnproj(&msg_loc, &vcgeom.line.igr_line, line,point1, point2, &t1, &t2);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_InvalidArg, ret_end);

  if ((t1 < 0.0) || (t1 > 1.0))
  {
   IGRdouble mdistsq;

    if (t1 < 0.0)
    {
      MA2pt2dis(&msg_loc,point1,vcgeom.line.igr_line.point1,&mdistsq);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_InvalidArg, ret_end);
    }
    else
    {
      MA2pt2dis(&msg_loc,point1,vcgeom.line.igr_line.point2,&mdistsq);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_InvalidArg, ret_end);
    }
    *mindist = sqrt(mdistsq);
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpvclmdist");
  return (stat_OM);
}

end implementation EMSparamvc;
