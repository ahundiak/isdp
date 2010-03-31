class implementation GRsubbc;

#include "EMS.h"
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
#include "bsctrarplcv.h"

method GRarea(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
              IGRdouble *area)

/*
Abstract
	This method determines the area of a closed, planar
	curve object.

Arguments
     *matrix_type  IGRshort  type of input matrix
     matrix        IGRmatrix local to world transformation matrix
     *msg          IGRlong   completion code
     *area         IGRdouble the area of the object

Return Values
   - MSSUCC if successful     
   - MSFAIL (severe) if other error

Files
	EMscarea.I

History
	dhm		7/6/88		Creation date.
    Sudha  06/16/93     Modified for BSprototype ansification

*/

{
  IGRlong     msg_loc, status, i;
  IGRchar     errmsg[EMMAXERRMSG_LEN];
  IGRpoint    center;
  struct IGRbsp_curve   *crv;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRsubbc.GRarea\n");
  crv = NULL;

  /*
   * Get the abstract geometry.
   */

  GRgetabsg(&msg_loc, matrix_type, matrix, (char **) &crv, i);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Check to see if the curve is closed.
   */

  if (!crv->phy_closed)
  {
    *msg = MSINARG;
    goto ret_end;
  }

  /*
   * Call the function to get the area.
   */

  BSctrarplcv(1, &crv, center, area, &msg_loc);
  EMerr_hndlr((msg_loc != BSSUCC), *msg, MSFAIL, ret_end);


ret_end:
  return(status);

}

end implementation GRsubbc;
