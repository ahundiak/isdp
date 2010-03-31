/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include "OMminimum.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ma.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"

method GRcentcurv(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
                  struct GRparms *parms; IGRpoint center)
/*
Abstract
	This method determines the center of curvature of a composite curve.

Arguments
     *matrix_type  IGRshort  type of input matrix
     matrix        IGRmatrix local to world transformation matrix
     *msg          IGRlong   completion code
     *parms        GRparms   parameter value of point that the center
                             is desired.
     center        IGRpoint  the returned center value.

Notes
    The leaf_id of the struct GRparms must be filled in for this method
    to work correctly.

Return Values
   - MSSUCC if successful     
   - MSFAIL (severe) if other error

Files
    EMcccentcurv.I

History
	dhm		6/28/88		Creation date.
*/

{
  IGRlong     msg_loc, status, index;
  IGRchar     errmsg[EMMAXERRMSG_LEN];

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRcompcurve.GRcentcurv\n");

  /*
   * Send the GRcentcurv message to the desired component.
   */

  status = om$send(msg = message GRcurve.GRcentcurv(msg, matrix_type,
                         matrix, parms, center),
                   targetid = parms->leaf_id.objid,
                   targetos = parms->leaf_id.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);

ret_end:
  return(status);

}

end implementation GRcompcurve;
