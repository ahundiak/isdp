/* ###################   APOGEE COMPILED   ################## */
class implementation EMSproject;

#include "EMS.h"
# include "emssfdef.h"
# include "EMSssprops.h"

method EMmodifiedClass(IGRlong *EMmsg; IGRint modif; GRobjid *newobjid)
/*
Abstract

    This method changes the class of the surface such that the
    specified type of modification can be performed.

Arguments

    modif - input
        Modification type. One of the following:
                                EMSuniformTransformation
                                EMSnonuniformTransformation
                                EMSdistortion

    newobjid - the object id of the new object.

Notes

    Surfaces of projection do not change class for non-uniform
    scaling.

History

    10 Mar 88   AIC     Creation Date.
*/
{
  IGRlong   sts = OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;
  *newobjid = my_id;

  switch(modif)
  {
    case EMSuniformTransformation:
    case EMSnonuniformTransformation:
    case EMSscale_of_1:
      break;

    case EMSdistortion:
      /*
       * Change class to EMSgenbs
       */
      break;

    default:
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSproject.EMmodifiedClass")
  return(sts);
}

end implementation EMSproject;
