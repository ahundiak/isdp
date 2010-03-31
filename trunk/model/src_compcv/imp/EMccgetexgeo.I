/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include <stdio.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "gocmacros.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "bserr.h"

method GRgetexgeom(IGRlong *msg; IGRshort *matrix_type; IGRmatrix
                   matrix; IGRchar *geometry)
/*
Abstract
	This method gets the extended geometry of composite curve.

Notes
	I just copied the method from the GRsubbc class and changed the class.

Arguments

Files
	EMccgetexgeo.I

History
	dhm		12/04/87		Creation date.
	dhm		12/30/87		Changed to call a function to get the geom.
*/

{
 extern  IGRlong  EFget_extended_geom();
  IGRlong	msg_loc, status;
  IGRchar	err_msg[EMMAXERRMSG_LEN];
  struct	GRlc_info  curve_info;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(err_msg, "GRcompcurve.GRgetexgeom\n");


  /*
   * Fill in the GRlc_info structure
   */

  curve_info.located_obj.objid = my_id;
  curve_info.located_obj.osnum = OM_Gw_current_OS;
  curve_info.module_info.md_env.matrix_type = *matrix_type;
  OM_BLOCK_MOVE(matrix, curve_info.module_info.md_env.matrix,
                sizeof(IGRmatrix));

  status = EFget_extended_geom(&msg_loc, &curve_info, geometry);
  EMomerr_hndlr(status, ret_end, err_msg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);


  ret_end:
	return(status);
}

end implementation GRcompcurve;
