/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsolid;

#include "EMS.h"
#include <stdio.h>

method GRlocate (struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
/*
  Description
    This override traps the locate send to the solid and depending
    on how it is owned, decides to either send wrt message the parents
    message or return.

  History
    Open your books to pg. 312 where you will see Washington crossing the
    software...
*/
{
  IGRlong    OM_stat=OM_S_SUCCESS;
  IGRlong    EMmsg=EMS_S_Success;
  IGRboolean active_state=FALSE;

  OM_stat = om$send(msg = message EMSsurface.EMisactive(&EMmsg,
                          &active_state, NULL), 
                    targetid = my_id);
  if (! (1 & EMmsg & OM_stat)) goto wrapup;

  if(active_state)
  {
    /*Eligible for locate...*/
    OM_stat = om$send(mode = OM_e_wrt_message,
                      msg = message EMScompsurf.GRlocate(cvl, range_key),
                      targetid = my_id);
  }

  wrapup:
    EMWRAPUP(EMmsg, OM_stat, "EMSsolid.GRlocate");
    return(OM_stat);
}
end implementation EMSsolid;
