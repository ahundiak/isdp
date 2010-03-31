/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include <stdio.h>

extern GRclassid OPP_EMSloopset_class_id;

IGRint EMdebug_send ()
{
  IGRlong stat_OM, msg_loc;
  struct GRid lsid;
  extern IGRlong EMgettrshobj();
 
  EMgettrshobj (&msg_loc, OPP_EMSloopset_class_id, 1, &lsid);

  stat_OM = om$send (msg = message EMSloopset.EMdebug_send (&msg_loc),
             targetid = lsid.objid, targetos = lsid.osnum,
             senderid = NULL_OBJID);
  EMWRAPUP (msg_loc, stat_OM, "EMdebug_send");             
  return (stat_OM);
}

end implementation EMSloopset;
