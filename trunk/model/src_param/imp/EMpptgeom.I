/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method is the override for obtaining the geometry (point) in
    model-space for a parametric point.


  HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification

*/

class implementation EMSparampt;

#include "ma.h"
#include "maptsxfor.h"

method EMgetgeom (IGRlong *msg; IGRushort opts;
                  IGRshort *mattyp; IGRmatrix mat;
                  struct EMSgeomdata *geomdata)
{
  IGRlong one=1;
  IGRlong msg_loc, stat_OM;
  IGRdouble *pt;
  IGRpoint xform_pt;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  pt = ME.EMSparampt->pt;
  if (*mattyp != MAIDMX)
    {
    MAptsxform (&msg_loc, &one, mat, pt, xform_pt);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    pt = xform_pt;
    }

  geomdata->geomtype = GEOMDATA_POINT;
  OM_BLOCK_MOVE (pt, geomdata->point, sizeof (IGRpoint));

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpptgetgeom");
  return (stat_OM);
}

end implementation EMSparampt;
