/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
Abstract
	This function gets the extended size of a curve.

Arguments

Notes
	Allocated extra memory because green hills compiler aligns doubles
	on quadword boundries.

Files
	EFgetexsiz.I

History
        pp              10/30/90                An exact comparison was
                                                with OPP_GRcompcurve_..
                                                was being done which does
                                                not take care of 
                                                associative composite curve
                                                Also this routine was
                                                freeing memory twice.
        Inasu           09/13/90                pp's modifcation of this
                                                function didnot take care
                                                composite curves. So if the
                                                curve is composite, this 
                                                function would call EMget_..();
                                                (TR 90n2507)
        pp              05/28/90                Sending a EMgetbcdef 
                                                message instead of calling
                                                EMget_the_geometry. Also
                                                this routine in such a case
                                                was not freeing memory. 
	dhm		12/30/87		Creation date.
*/

class implementation GRcurve;

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "gocmacros.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "bserr.h"

extern OMuword OPP_GRbspline_class_id;

from GRbspline import  EMgetbcdef;
IGRlong EFget_extended_size(msg, curve_info, size)
  IGRlong		*msg;
  struct		GRlc_info	*curve_info;
  IGRlong		*size;

{
  IGRlong	msg_loc, status, num_poles, EMget_the_geometry();
  struct IGRbsp_curve	*curve,bs_curve;
  IGRchar	err_msg[EMMAXERRMSG_LEN];
  OMuword classid;
  extern OMuword OPP_GRcompcurve_class_id;
  IGRboolean compcurve = FALSE;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  curve = NULL;
  strcpy(err_msg, "EFgetexsize\n");

  /* Check whether the curve is a composite curve */

  status = om$get_classid ( 
                    osnum     = curve_info->located_obj.osnum,
                    objid     = curve_info->located_obj.objid,
                    p_classid = &classid);
  EMomerr_hndlr(status, ret_end, err_msg);

  status = om$is_ancestry_valid(subclassid = classid,
                                superclassid = OPP_GRbspline_class_id);
  /*
   * Get the geometry of the curve 
   */

  if(status == OM_S_SUCCESS)
  {
   status = om$send (msg = message GRbspline.EMgetbcdef(&msg_loc,&bs_curve),
                     senderid = NULL_OBJID,
                     targetid = curve_info->located_obj.objid,
                     targetos = curve_info->located_obj.osnum);
  }
  else if (status == OM_I_INVANCESTRY)
  {
   compcurve = TRUE;
   status = EMget_the_geometry(curve_info,
                              TRUE, 
                              NULL,
                              FALSE,
                              NULL_OBJID,
                              (IGRchar **)&curve,
                              &msg_loc);
   EMomerr_hndlr(status, ret_end, err_msg);
   EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
   bs_curve.num_poles = curve->num_poles;
   bs_curve.order = curve->order;
   bs_curve.rational = curve->rational;
  }
  else
  {
   msg_loc = MSFAIL;
   goto ret_end;
  }

  /*
   * Allocate size according to what is
   * needed in the math routine, BSpolyxt2sd,
   * which does the extend.
   */

  num_poles = bs_curve.num_poles + 2 * bs_curve.order - 1;
  *size = num_poles * (bs_curve.rational ? 4 : 3);  /* for poles & weights */
  *size += bs_curve.order + num_poles + 20;  /* for knots and extra */
  *size *= sizeof(IGRdouble);
  *size += sizeof(struct IGRbsp_curve);

  ret_end:
   if (curve) free (curve);
  return(status);
}

end implementation GRcurve;
