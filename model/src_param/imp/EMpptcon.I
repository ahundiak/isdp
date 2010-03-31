/* ###################   APOGEE COMPILED   ################## */
class implementation EMSparampt;

/*
   HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification
*/

#include "OMmacros.h"
#include "ma.h"
#include "maptsxfor.h"
#include "mainvmx.h"

#include "actparam.h"


method EMconstruct (IGRlong *msg; IGRushort opts;
                    IGRshort *mattyp; IGRmatrix mat;
                    struct EMSgeomdata *ptgeom)
{
  IGRboolean stat_func;
  IGRshort four=4;
  IGRlong one = 1;
  IGRlong msg_loc, stat_OM;
  IGRdouble *mypt;
  IGRmatrix invmx;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Put the point (transformed to local co-ordinates) into my instance
   * data
   */

  mypt = ME.EMSparampt->pt;
  
  if (*mattyp != MAIDMX)
  {
    stat_func = MAinvmx (&msg_loc, &four, mat, invmx);
    EMerr_hndlr (!stat_func, *msg, EMS_E_MAerror, ret_end);

    stat_func = MAptsxform (&msg_loc, &one, invmx, ptgeom->point, mypt);
    EMerr_hndlr (!stat_func, *msg, EMS_E_MAerror, ret_end);
  }
  else
    OM_BLOCK_MOVE (ptgeom->point, mypt, sizeof (IGRpoint));

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMparampt.EMconst");
  return (stat_OM);
}

end implementation EMSparampt;
