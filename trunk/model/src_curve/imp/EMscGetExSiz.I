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

method GRgetexsize(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                   matrix; IGRlong *size)
/*
Abstract
	This method gets the extended size of a general bspline curve.

Arguments

Notes
	Allocated extra memory because green hills compiler aligns doubles
	on quadword boundries.

Files
	EMscgetexsiz.I

History
	dhm		8/27/87		Creation date.
	dhm		12/30/87	Modified to call a function to get the size.
    dhm     02/22/88    Added GR_NOTIFY_LISTENERS
    dhm     06/09/88    Took out GR_INQUIRED notification.
*/

{
  IGRlong	msg_loc, status, EFget_extended_size();
  IGRchar	err_msg[EMMAXERRMSG_LEN];
  struct	GRlc_info	curve_info;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(err_msg, "GRsubbc.GRgetexsize\n");

  /*
   * Fill in the GRlc_info structure
   */

  curve_info.located_obj.objid = my_id;
  curve_info.located_obj.osnum = OM_Gw_current_OS;
  curve_info.module_info.md_env.matrix_type = *mx_type;
  OM_BLOCK_MOVE(matrix, curve_info.module_info.md_env.matrix,
                sizeof(IGRmatrix));

  status = EFget_extended_size(&msg_loc, &curve_info, size);
  EMomerr_hndlr(status, ret_end, err_msg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  ret_end:
	return(status);
}

end implementation GRsubbc;
