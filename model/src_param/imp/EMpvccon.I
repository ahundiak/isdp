/* ###################   APOGEE COMPILED   ################## */
class implementation EMSparamvc;

/*
   HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification
*/

#include "OMmacros.h"
#include "bserr.h"
#include "maptsxfor.h"
#include "mainvmx.h"
#include "bsnorvec.h"

#include "actparam.h"

method EMconstruct (IGRlong *msg; IGRushort opts;
                    IGRshort *mattyp; IGRmatrix mat;
                    struct EMSgeomdata *vecgeom)
{
  IGRboolean stat_func;
  IGRshort four=4;
  IGRlong  one = 1;
  IGRlong msg_loc, stat_OM;
  IGRdouble *myvec;
  IGRmatrix invmx, rotmx;

  IGRboolean aflag;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Put the vector (transformed to local co-ordinates) into my instance
   * data. For transformation purposes, the vector is treated as a point.
   * in world-space.
   */

  myvec = ME.EMSparamvc->vec;

  if (*mattyp != MAIDMX)
  {
    memcpy(rotmx, mat, sizeof(IGRmatrix));

    aflag = pwIsActivationOn();
    if(aflag)
    {
      rotmx[3] = rotmx[7] = rotmx[11] = 0.0;
    }

    stat_func = MAinvmx (&msg_loc, &four, rotmx, invmx);
    EMerr_hndlr (!stat_func, *msg, EMS_E_MAerror, ret_end);

    stat_func = MAptsxform (&msg_loc, &one, invmx, vecgeom->vector, myvec);
    EMerr_hndlr (!stat_func, *msg, EMS_E_MAerror, ret_end);
  }
  else
    OM_BLOCK_MOVE (vecgeom->vector, myvec, sizeof (IGRvector));

  /*
   * Store the vector as normalized
   */

  BSnorvec (&msg_loc, myvec);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMparamvc.EMconst");
  return (stat_OM);
}

end implementation EMSparamvc;
