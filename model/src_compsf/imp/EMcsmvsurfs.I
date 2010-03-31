/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "emserr.h"

method EMmovesurfs (IGRlong *EMmsg; struct GRid *prim_id; 
                    struct GRmd_env *env)
/*
Description
    This method will move all of its surfaces to the object given in the
    parameter list.

    Since this composite object is no longer of any use, it will be deleted.

Return values 
    EMS_S_Success is returned if all is well.

History:
    DLB 10/31/87 Rewrote for version 1.1.0
    DLB 04/14/87 Creation.
*/
{
 IGRlong         OM_stat;    
 OM_S_CHANSELECT to_comps;

      
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
    
/*Move my listeners channel*/
/**************************************************************
 {
   OM_S_CHANSELECT to_listener; 

   OM_stat = EMmake_chanselect(GRnotify_notification, &to_listener);
   if (! (1 & OM_stat)) goto wrapup;

   OM_stat = om$send(msg = message Root.set_operation(to_listener, my_id,
                           OM_Gw_current_OS, to_listener, prim_id->objid,
                           prim_id->osnum, to_listener, 'U', NULL),
                     targetid = prim_id->objid);
   if (! (1 & OM_stat)) goto wrapup;
 }
***************************************************************/ 

 OM_stat = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
 if (! (1 & OM_stat)) goto wrapup;

 /*Send on to components.*/
 OM_stat = om$send(msg = OPPmargs,
                   p_chanselect = &to_comps);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 /*I not longer have any components so delete me and all below.*/
 OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMScompsurf.EMmovesurfs")
  return (OM_stat);
}
end implementation EMScompsurf;
