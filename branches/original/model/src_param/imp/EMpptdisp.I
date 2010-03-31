/* ###################   APOGEE COMPILED   ################## */

class implementation EMSparampt;

/*
   HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification
*/

#include "dimdef.h"
#include "dim.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bscrossp.h"

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1
#define Z 2

method EMdisplay (IGRlong *msg; IGRushort opts;
                  IGRshort *mattyp; IGRmatrix mat;
                  struct IGRdisplay *disp_attr;
                  enum GRdpmode dpmode;
                  struct GRid *win_or_mod_id)
{
  IGRint i, bytes_in, bytes_out;
  IGRlong msg_loc, stat_OM, stat_func;
  IGRdouble *pt, sublength;
  IGRpoint plnpt, pypts[2];
  IGRvector xaxis, yaxis, zaxis;
  struct IGRplane dim_plane;
  struct DMenv_param dm_env_param;
  struct EMSgeomdata ptdata;
  struct IGRdisplay loc_disp_attr;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the point in world coordinates
   */

  if (*mattyp != MAIDMX)
    {
    stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
               mattyp, mat, &ptdata), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    pt = ptdata.point;
    }
  else
    pt = ME.EMSparampt->pt;

  /*
   * Obtain the orientation in which this point's cross-hair representation
   * should be drawn. This is keyed off on the auto-dimension plane for
   * this point.
   */

  dim_plane.normal = zaxis;
  dim_plane.point = plnpt;
  stat_OM = om$send (msg = message EMSparameter.EMgetdimgeom (&msg_loc, NULL,
             mattyp, mat, &dim_plane, xaxis, NULL, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Construct the three line-segments that make up the cross to depict this
   * point. The length of the crosses is keyed off on the dimensioning
   * text-height (just as in v.g. geometric handles). Display these 
   * line-segments.
   */

  if (disp_attr)
    loc_disp_attr = *disp_attr;
  else
    {
    bytes_in = sizeof (struct IGRdisplay);
    gr$get_active_display (msg = &msg_loc, sizbuf = &bytes_in,
     buffer = &loc_disp_attr, nret = &bytes_out);
    }

  stat_func = dm$get_dim_param (type = DM_ENV_PARAM, p_data = &dm_env_param);
  EMerr_hndlr (EMSerror (stat_func), *msg, EMS_E_Fail, ret_end);
  sublength = (1.1 * dm_env_param.txt_heig) / 2.0;

  for (i=X; i<=Z; i++)
    {
    pypts[FIRST][i] = pt[i] - sublength * xaxis[i];
    pypts[SECOND][i] = pt[i] + sublength * xaxis[i];
    }

  EMdisppts (2, pypts, &loc_disp_attr, TRUE, dpmode, win_or_mod_id);

  BScrossp (&msg_loc, zaxis, xaxis, yaxis);
  BSnorvec (&msg_loc, yaxis);
  for (i=X; i<=Z; i++)
    {
    pypts[FIRST][i] = pt[i] - sublength * yaxis[i];
    pypts[SECOND][i] = pt[i] + sublength * yaxis[i];
    }

  EMdisppts (2, pypts, &loc_disp_attr, TRUE, dpmode, win_or_mod_id);

  for (i=X; i<=Z; i++)
    {
    pypts[FIRST][i] = pt[i] - sublength * zaxis[i];
    pypts[SECOND][i] = pt[i] + sublength * zaxis[i];
    }

  EMdisppts (2, pypts, &loc_disp_attr, TRUE, dpmode, win_or_mod_id);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMparampt.EMdisp");
  return (stat_OM);
}

end implementation EMSparampt;
