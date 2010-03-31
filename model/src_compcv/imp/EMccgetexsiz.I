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

method GRgetexsize(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                   matrix; IGRlong *size)
/*
Abstract
	This method gets the extended size of a composite curve.

Arguments

Notes

Files
	EMccgetexsiz.I

History
	dhm		12/04/87		Creation date.
	dhm		12/30/87		Changed to call a function which get the size.
*/

{
 extern  IGRlong  EFget_extended_size();
  IGRlong	msg_loc, status;
  IGRchar	err_msg[EMMAXERRMSG_LEN];
  struct	GRlc_info	curve_info;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(err_msg, "GRcompcurve.GRgetexsize\n");

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

end implementation GRcompcurve;
