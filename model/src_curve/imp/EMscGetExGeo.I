/* ###################   APOGEE COMPILED   ################## */
class implementation GRsubbc;

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "godef.h"
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
	This method gets the extended geometry of a general bspline curve.

Arguments

Files
	EMscgetexgeo.I

History
	dhm		8/27/87		Creation date.
	dhm		12/30/87	Modified to call a function to get the geometry.
    dhm     02/22/88    Added GR_NOTIFY_LISTENERS
    dhm     06/09/88    Took out GR_INQUIRED notification.
*/

{
  IGRlong	msg_loc, status, EFget_extended_geom();
  IGRchar	err_msg[EMMAXERRMSG_LEN];
  struct	GRlc_info	curve_info;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(err_msg, "GRsubbc.GRgetexgeom\n");

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

end implementation GRsubbc;
