/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"

%safe
extern unsigned char EMS_locate_features;
%endsafe

method GRlocate (struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
/*
  Description
    This override traps the locate send to the dpr and depending
    on how it is owned, decides to either send wrt message the parents
    message or return.

  History
    Open your books to pg. 312 where you will see Washington crossing the
    software...I...I mean the Shareware...I, uh..., mean the Deleware...
*/
{
  IGRlong    OM_stat=OM_S_SUCCESS;
  IGRint     EMmsg=EMS_S_Success;

  if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_STATE || EMS_locate_features)
  {
    /*Eligible for locate...*/
    OM_stat = om$send(mode = OM_e_wrt_message,
                      msg = message EMScomposite.GRlocate(cvl, range_key),
                      targetid = my_id);
  }

  wrapup:
    EMWRAPUP(EMmsg, OM_stat, "EMSdpr.GRlocate");
    return(OM_stat);
}
end implementation EMSdpr;
