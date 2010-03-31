class implementation EMSparamvc;

#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1
#define Z 2

#define REGULAR_STYLE   0
#define DOTDASHED_STYLE 4

method EMdisplay (IGRlong *msg; IGRushort opts;
                  IGRshort *mattyp; IGRmatrix mat;
                  struct IGRdisplay *disp_attr;
                  enum GRdpmode dpmode;
                  struct GRid *win_or_mod_id)
{
  IGRint bytes_in, bytes_out;
  IGRlong msg_loc, stat_OM;
  IGRpoint arrows[2][3];
  struct EMSgeomdata vecgeom;
  struct IGRdisplay loc_disp_attr;
  extern void EMgetarrowheads();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the virtual geometry for this vector. This is determined
   * by the object for which this vector is a parameter.
   */

  stat_OM = om$send (msg = message EMSparameter.EMgetdimgeom (&msg_loc, NULL,
             mattyp, mat, NULL, NULL, &vecgeom, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * The geometry returned must be a line-segment. Display this
   * line-segment. 
   */

  EMerr_hndlr (vecgeom.geomtype != GEOMDATA_LINE, *msg, EMS_E_InvalidCase,
   ret_end);

  if (disp_attr)
    loc_disp_attr = *disp_attr;
  else
    {
    bytes_in = sizeof (struct IGRdisplay);
    gr$get_active_display (msg = &msg_loc, sizbuf = &bytes_in,
     buffer = &loc_disp_attr, nret = &bytes_out);
    }
  loc_disp_attr.style = DOTDASHED_STYLE;

  EMdisppts (2, vecgeom.line.line_pt1, &loc_disp_attr, TRUE, dpmode,
   win_or_mod_id);

  /*
   * Also display the arrow-head(s) at the end-point
   * of this axis.
   */

  EMgetarrowheads (&msg_loc, vecgeom.line.line_pt1, arrows, 0.3);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  loc_disp_attr.style = 0;
  EMdisppts (3, arrows[FIRST], &loc_disp_attr, TRUE, dpmode,
   win_or_mod_id);
  EMdisppts (3, arrows[SECOND], &loc_disp_attr, TRUE, dpmode,
   win_or_mod_id);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMparamvc.EMdisp");
  return (stat_OM);
}

end implementation EMSparamvc;
