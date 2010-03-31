/* ###################   APOGEE COMPILED   ################## */
class implementation EMScone;

#include "EMS.h"
# include "msdef.h"         /* MS message codes             */
# include "EMSssprops.h"    /* formats                      */

method EMgetbsdef(IGRlong *EMmsg; struct IGRbsp_surface *surface)
/*
Abstract

    This method generates the control information for cones.

Arguments

    surface - output
        Surface control information.

Return Status

    EMS_S_Success       - Success
    EMS_E_InvalidCase   - Surface object has bad format value.

History

    31 Mar 88   AIC     Creation Date
*/
{
  IGRlong   sts = OM_S_SUCCESS;

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;

  switch(me^^EMSsubbs.ss_props & EMSformat)
  {
    case EMSbsplineFormat:
      sts = om$send(msg = message EMSsubbs.EMgetbsdef(EMmsg, surface),
                    mode = OM_e_wrt_message, targetid = my_id);
      break;

    case EMSprojectedFormat:
      sts = om$send(msg = message EMSproject.EMgetbsdef(EMmsg, surface),
                    mode = OM_e_wrt_message, targetid = my_id);
      break;

    case EMSrevolvedFormat:
      sts = om$send(msg = message EMSrevol.EMgetbsdef(EMmsg, surface),
                    mode = OM_e_wrt_message, targetid = my_id);
      break;

    default:
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;
  }

wrapup:
  return(OM_S_SUCCESS);
}

end implementation EMScone;
