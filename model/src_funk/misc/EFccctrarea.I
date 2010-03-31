/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
class implementation GRcompcurve;

#include "EMS.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "msdef.h"
#include "godef.h"
#include "go.h"
#include "gr.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsctrarplcv.h"


EFget_center_and_area_composite(msg, matrix_type, matrix, comp_GRid,
                                center, area)
IGRlong          *msg;
IGRshort         *matrix_type;
IGRmatrix        matrix;
struct GRid      comp_GRid;
IGRpoint         center;
IGRdouble        *area;

/*
Abstract
	This function returns the center and area of a closed composite curve.

Arguments

Notes

Files
	EFccctrarea.I

History
	dhm		6/9/88		Creation date.
        Sudha         07/08/93          Modified for BSprototypes ansification

*/

{
  IGRlong     msg_loc, status, size;
  IGRint      count, i;
  IGRchar     errmsg[GR_MAX_CHAR];
  struct IGRbsp_curve    **curves;
  OM_S_CHANSELECT        to_comps;
  struct GRprops         props;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"EFget_center_and_area_composite\n");
  curves = NULL;

  /*
   * If composite isn't closed, then return an error.
   */

  status = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                         matrix_type, matrix, &props),
                   senderid = NULL_OBJID,
                   targetid = comp_GRid.objid,
                   targetos = comp_GRid.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  if (!props.phy_closed)
  {
    *msg = MSINARG;
    goto ret_end;
  }

  /*
   * Initialize the channel selector
   */

  status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Get the number of components on the composite channel.
   */

  status = om$get_channel_count(objid = comp_GRid.objid,
                                osnum = comp_GRid.osnum,
                                p_chanselect = &to_comps,
                                count = (OMuint *)&count);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Allocate curves array.
   */

  curves = (struct IGRbsp_curve **) om$malloc( size = count * sizeof(struct
                                    IGRbsp_curve) );
  EMerr_hndlr(!curves, *msg, MSNOMEM, ret_end);

  /*
   * Initialize each curve to NULL.
   */

  for (i = 0; i < count; i++)
    curves[i] = NULL;

  /*
   * Get the geometry of each curve on the composite channel.
   */

  for (i = 0; i < count; i++)
  {
    status = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                           matrix_type, matrix, &size),
                   senderid = comp_GRid.objid,
                   p_chanselect = &to_comps,
                   from = i, to = i);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    curves[i] = (struct IGRbsp_curve *) om$malloc(size = size);
    EMerr_hndlr(!(curves[i]), *msg, MSNOMEM, ret_end);

    status = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                           matrix_type, matrix, (IGRchar *)curves[i]),
                   senderid = comp_GRid.objid,
                   p_chanselect = &to_comps,
                   from = i, to = i);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
  }

  /*
   * Call the math routine.
   */

  BSctrarplcv(count, curves, center, area, &msg_loc);
  EMerr_hndlr((msg_loc != BSSUCC), *msg, MSFAIL, ret_end);


ret_end:
  if (curves)
  {
    for (i = 0; i < count; i++)
    {
      if (curves[i])  om$dealloc(ptr = curves[i]);
    }

    om$dealloc(ptr = curves);
  }

  return(status);

}

end implementation GRcompcurve;
