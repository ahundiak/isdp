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
	EMccarea.I
    EFccctrarea.I

History
	dhm		6/9/88		Creation date.
*/

{
 extern  IGRlong  EFget_center_and_area_composite();
  IGRlong     msg_loc, status;
  IGRchar     errmsg[EMMAXERRMSG_LEN];
  IGRpoint    center;
  struct GRid comp_GRid;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRcompcurve.GRarea\n");
  comp_GRid.objid = my_id;
  comp_GRid.osnum = OM_Gw_current_OS;

  /*
   * Call the function to get the center.
   */

  status = EFget_center_and_area_composite(&msg_loc, matrix_type, matrix,
           comp_GRid, center, area);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, ret_end);


ret_end:
  return(status);

}

end implementation GRcompcurve;
