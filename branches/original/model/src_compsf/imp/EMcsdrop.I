/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "msdef.h"
#include "EMSopt.h"

from EMSsubbs import EMdrop;

extern GRclassid  OPP_EMSmassprop_class_id;

method GRdrop (IGRlong *msg; struct GRmd_env *env)

/*
Description
     This method will drop all of the surfaces from the composite.
     All topology will be compressed.

Return Values
     EMmsg - MSSUCC if all is well.

Notes 

History
  DLB 12/12/91 Added EMdrop_assoc send to clean up associative info.
  SS  11/02/89 Added the notification stuff (absorbed mass/area designator
               processing into it)
  gupta 08/18/89 : delete mass/area designator object if any
  DLB 10/28/87 mod for version 1.1.0
  DLB 04/04/87 creation...
*/
{
 IGRboolean		notify;
 IGRlong                stat_OM;
 OM_S_CHANSELECT        to_comps;

 stat_OM = OM_S_SUCCESS;
 *msg = MSSUCC;

 /*Drop my associativity - DLB 12/12/91*/
 { /*INTENTIONAL*/
   GRobjid newobj;   

   stat_OM = om$send(msg = message EMSassoc.EMdrop_associativity(msg, NULL,
                           env, &newobj),
                     targetid = my_id);
   if (!(1 & stat_OM & *msg)) goto wrapup;
 }

 stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
 if (! (1 & stat_OM)) goto wrapup;

 /*Send on down!!*/

 stat_OM = om$send(msg = OPPmargs, p_chanselect = &to_comps);
 if (!(1 & stat_OM & *msg) && (stat_OM != OM_W_UNKNOWN_MSG)) goto wrapup;

 /*Send to comps to drop/break common edge connections in topology*/

 stat_OM = om$send(msg = message EMSsubbs.EMdrop(msg, env),
                   p_chanselect = &to_comps);
 if (! (1 & stat_OM & *msg)) goto wrapup;

 /*Compress the topology that was left*/

 stat_OM = om$send(msg = message EMSsurface.EMcompress_top(msg, env),
                   p_chanselect = &to_comps);
 if (! (1 & stat_OM & *msg)) goto wrapup;

 /*Drop my comps and delete me*/

 notify = EMcheck_inhibit_postproc();

 stat_OM = om$send(mode = OM_e_wrt_message,
                   msg = message EMScomposite.GRdrop(msg,env),
                   targetid = my_id);


 if (notify)
   {
   IGRlong msg_loc;

   if (!EMSerror (*msg & stat_OM))
     om$send (msg = message EMSsurface.EMpostdelete (&msg_loc,
      EMS_POST_NOCOMPONENTS, env, NULL, NULL), targetid = my_id);
   EMrestore_postproc();
   }
 if (! (1 & stat_OM & *msg)) goto wrapup;

 wrapup:
  EMWRAPUP(*msg, stat_OM, "EMScompsurf.GRdrop")
  return (stat_OM);
}
end implementation EMScompsurf;
