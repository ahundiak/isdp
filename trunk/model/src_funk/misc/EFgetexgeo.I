/* ###################   APOGEE COMPILED   ################## */
/*
Abstract
	This function gets the extended geometry of a curve.

Notes

Arguments

Files
	EFgetexgeo.I

History
	dhm		12/30/87		Creation date.
        Sudha   	07/08/93        	Modified for BSprototypes ansification

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
#include "bspolyxt2sd.h"
#include "bsnorkts.h"
#include "bscv_copy.h"

IGRlong EFget_extended_geom(msg, curve_info, geometry)
  IGRlong	*msg;
  struct	GRlc_info	*curve_info;
  IGRchar	*geometry;

{
  IGRlong	msg_loc, status, EMget_the_geometry();
  struct IGRbsp_curve	*curve, *ext_curve;
  IGRchar	err_msg[EMMAXERRMSG_LEN];
  IGRboolean sts;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  curve = NULL;
  ext_curve = (struct IGRbsp_curve *) geometry;
  strcpy(err_msg, "EFgetexgeom\n");

  /*
   * Get the  geometry of the curve
   */

  status = EMget_the_geometry(curve_info,
                              TRUE, 			/* Is a curve? */
                              NULL,	 		    /* Is directed curve? */
                              FALSE,			/* Separate mallocs? */
                              NULL_OBJID,
                              &curve,			/* The geometry */
                              &msg_loc);
  EMomerr_hndlr(status, ret_end, err_msg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  if (curve->phy_closed)
  {
    /*
     * If the curve is closed, then partition the memory and
     * copy the curve's geometry into the returned geometry pointer.
     */

    GRbc_partition((struct IGRbsp_curve *) geometry, curve->order, 
                   curve->num_poles, curve->rational, 
                   curve->num_boundaries);

    sts = BScv_copy(&msg_loc, curve, (struct IGRbsp_curve *) geometry);
  }
  else
  {
    /*
     * Fill in the ext_curve structure
     */

    ext_curve->order = curve->order;
    ext_curve->periodic = curve->periodic;
    ext_curve->non_uniform = curve->non_uniform;
    ext_curve->num_poles = curve->num_poles + 2 * curve->order - 1;
    ext_curve->num_knots = curve->order + ext_curve->num_poles;
    ext_curve->rational = curve->rational;
    ext_curve->planar = curve->planar;
    ext_curve->phy_closed = curve->phy_closed;
    ext_curve->num_boundaries = curve->num_boundaries;  /* number will
                                                           always be 0 */
    ext_curve->bdrys = NULL;

    /*
     * Partition my memory to have
     * my ext_curve followed by its poles,
     * knots, and weights.
     */

    GRbc_partition(ext_curve, ext_curve->order, ext_curve->num_poles,
                   ext_curve->rational, ext_curve->num_boundaries);

    /*
     * Call the math routine which
     * extends the geometry.
     */

    BSpolyxt2sd(curve, ext_curve, &msg_loc);
    EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

    sts = BSnorkts(&msg_loc, &ext_curve->order, &ext_curve->num_poles,
                   ext_curve->knots);
    EMerr_hndlr( (!sts) || (msg_loc != BSSUCC), *msg, MSFAIL, ret_end);
  }

  ret_end:
    if (curve)  free(curve);
	return(status);
}

end implementation GRcurve;
