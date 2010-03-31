/* ###################   APOGEE COMPILED   ################## */
class implementation EMScone;

#include "EMS.h"
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

    The cone will behave according to its storage format.

History

    31 Mar 88   AIC     Creation Date.
*/
{
  IGRlong   sts = OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;
  *newobjid = my_id;

  switch(me^^EMSsubbs.ss_props & EMSformat)
  {
    case EMSbsplineFormat:
      sts = om$send(msg = message EMSsubbs.EMmodifiedClass(EMmsg, modif,
                    newobjid), mode = OM_e_wrt_message,targetid = my_id);
      break;

    case EMSprojectedFormat:
      sts = om$send(msg = message EMSproject.EMmodifiedClass(EMmsg, modif,
                    newobjid), mode = OM_e_wrt_message,targetid = my_id);
      break;

    case EMSrevolvedFormat:
      sts = om$send(msg = message EMSrevol.EMmodifiedClass(EMmsg, modif,
                    newobjid), mode = OM_e_wrt_message,targetid = my_id);
      break;

    default:
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMScone.EMmodifiedClass")
  return(sts);
}

end implementation EMScone;
