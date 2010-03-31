/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    Used to determine the alternate parameter to the one given, which
    represents the same model-space point. Such an alternate parameter
    exists only for physically closed surfaces and when the given parameter
    lies on the seam edge. The output parameter argument can point to the
    same memory as the input.

  RETURN VALUES

    The return code in msg is one of the following:
     - EMS_I_Found if such a paramter was found
     - EMS_I_NotFound if not found

  HISTORY

    SS  :  12/01/87  :  Creation
    NP  :  08/26/92  :  Modified for ANSI compliance. Added typecast in GRgetabsg.
*/

class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include "OMmacros.h"
#include "gocmacros.h"
#include "emserr.h"
#include "EMSssprops.h"

#define U 0
#define V 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method  EMaltparams (IGRlong *msg; IGRdouble *uvpt; IGRdouble partol;
                     IGRint *numaltpts; IGRdouble *altuvpts)
{
  IGRboolean uphyclosed, vphyclosed;
  IGRint dumdum;
  IGRshort mattyp;
  IGRmatrix mat;
  IGRlong stat_OM, msg_loc;
  IGRdouble u_low, u_high, v_low, v_high;
  IGRdouble *u_knots, *v_knots;
  struct IGRbsp_surface *srf, sfprops;
  void EMidmatrix();
  IGRint EM2dtpyaltpt();

  *msg = EMS_I_NotFound;
  stat_OM = OM_S_SUCCESS;

  /*
   * Check if this surface is a candidate for an alternate parameter.
   * It must be either physically closed in U or V direction.
   */

  stat_OM = om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc, &sfprops), 
             targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  uphyclosed = sfprops.u_phy_closed;
  vphyclosed = sfprops.v_phy_closed;

  if (uphyclosed || vphyclosed)
    {
    /*
     * Obtain this surfaces geometry.
     */

    EMidmatrix (&msg_loc, &mattyp, mat);
    GRgetabsg (&msg_loc, &mattyp, mat, (IGRchar **)&srf, dumdum);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    srf->num_boundaries = 0;

    u_knots = srf->u_knots;
    v_knots = srf->v_knots;
    u_low = u_knots[srf->u_order-1];
    u_high = u_knots[srf->u_num_poles];
    v_low = v_knots[srf->v_order-1];
    v_high = v_knots[srf->v_num_poles];

    *numaltpts = EM2dtpyaltpt (u_low, u_high, v_low, v_high,
                  uphyclosed, vphyclosed, partol, uvpt, altuvpts);
    if (*numaltpts)
      *msg = EMS_I_Found;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMaltparam");
  return (stat_OM);
}

end implementation EMSsubbs;

