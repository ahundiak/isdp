/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

#include "EMS.h"
#include "msdef.h"
#include "EMSopt.h"

method GRdrop (IGRlong *msg; struct GRmd_env *env)
/*
Description
     This method will perform a delete of its save state info then involk
     EMScompsurfs method to do the rest.

Return Values
     EMmsg - MSSUCC if all is well.

History
  SS  11/02/89 Added the notification stuff
  DLB 11/19/87 creation...
*/
{
 IGRboolean	 notify;
 IGRlong         OM_stat;


 OM_stat = OM_S_SUCCESS;
 *msg = MSSUCC;

 /*Delete my save state info*/
 OM_stat = om$send(msg = message EMSdpr.EMsavestatedelete(msg, env, NULL),
                   targetid = my_id);
 if (! (1 & OM_stat & *msg)) goto wrapup;

 /*Delete my recompute info*/
 OM_stat = om$send(msg = message EMSdpr.EMrecompinfodelete(msg, env, NULL,
                         NULL), 
                   targetid = my_id);
 if (! (1 & OM_stat & *msg)) goto wrapup;

 /*Do EMScompsurfs method*/

 notify = EMcheck_inhibit_postproc();

 OM_stat = om$send(mode = OM_e_wrt_message,
                   msg = message EMScompsurf.GRdrop(msg, env),
                   targetid = my_id);
 if (notify)
   {
   IGRlong msg_loc;

   if (!EMSerror (*msg & OM_stat))
     om$send (msg = message EMSsurface.EMpostdelete (&msg_loc,
      EMS_POST_NOCOMPONENTS, env, NULL, NULL), targetid = my_id);
   EMrestore_postproc();
   }
 if (!(1 & OM_stat & *msg)) goto wrapup;

 wrapup:
  EMWRAPUP(*msg, OM_stat, "EMSsfdpr.GRdrop")
  return (OM_stat);
}
end implementation EMSsfdpr;
