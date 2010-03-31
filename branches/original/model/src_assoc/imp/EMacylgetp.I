/* ###################   APOGEE COMPILED   ################## */
class implementation EMAcylindr;

/*
   History

	Sudha   06/01/93    modified to handle BSprototype headers
*/

#include "OMmacros.h"
#include "maidmx.h"

from EMSparamgm import EMgetgeom;
from expression import NDgive_value;

method EMgetparam (IGRlong *msg; IGRushort opts;
                   struct EMSparams *params)
{
  IGRshort mattyp;
  IGRint i, count;
  IGRlong msg_loc, stat_OM;
  IGRdouble *pt;
  IGRmatrix mat;
  struct EMSgeomdata geomdata;
  OM_S_CHANSELECT chan_to_parents;
  OM_S_OBJECT_LINKAGE objlist[3];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (NDfather_father, &chan_to_parents);

  om$get_channel_objects (object = me, p_chanselect = &chan_to_parents,
   count = (OMuint *)&count, size = 3, list = objlist);

  /*
   * Get the basept and the heightpt
   */

  mattyp = MAIDMX;
  MAidmx (&msg_loc, mat);
  for (i=0; i<2; i++)
    {
    stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
               &mattyp, mat, &geomdata), targetid = objlist[i].S_objid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if (i == 0)
      {
      params->parms.cyl.basept.type = EMSdatainfo_numeric;
      pt = params->parms.cyl.basept.pt;
      }
    else
      {
      params->parms.cyl.heightpt.type = EMSdatainfo_numeric;
      pt = params->parms.cyl.heightpt.pt;
      }
    OM_BLOCK_MOVE (geomdata.point, pt, sizeof (IGRpoint));
    }

  stat_OM = om$send (msg = message expression.NDgive_value (
             &params->parms.cyl.radius.val), targetid = objlist[2].S_objid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  params->parms.cyl.radius.type = EMSdatainfo_numeric;

  params->type = EMS_AScylinder;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMAcylindr.EMgetparam");
  return (stat_OM);
}

end implementation EMAcylindr;

