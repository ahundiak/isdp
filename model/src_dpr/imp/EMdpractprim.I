/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"

method EMactivateprims(IGRlong *EMmsg;
                       IGRushort *option;
                       struct GRmd_env *my_env;
                       struct GRid **active_state; 
                       IGRint *num, *buff_size;
                       GRobjid **display_ids;
                       IGRint *display_count, *involk_count)
/*
Description
    See EMdprundo.I file for a desctription of this method.

History
   DLB    03/14/88   Parameter change.
   DLB    11/02/87   Modified channel for version 1.1.0
   DLB    06/08/87   Creation
*/

{
 IGRlong             OM_stat;
 OM_S_CHANSELECT     to_comps;


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 
 if (! (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_STATE))
 {*EMmsg = EMS_E_InvalidArg; goto wrapup;}

 if (*option & EMS_DO_DISPLAY) (*involk_count)++;

 /*I first send an undo to me then I send on down.  Note that if the last
  * state is not a dpr (its a primitive) then an unknown msg will be
  * returned which I ignore.
  */

 OM_stat = om$send(msg = message EMSdpr.EMundo(EMmsg, option, my_env,
                         active_state, num, buff_size, display_ids, 
                         display_count, involk_count),
                   targetid = my_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

 OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_comps);
 if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;

 OM_stat = OM_S_SUCCESS; /*fix the code so wrapup doesn't complain*/

 if (*option & EMS_DO_DISPLAY)
 {
   if (*involk_count == 1) 
   {
     /*This is the first invocation of this method so redisplay.*/

     /*IMPORTANT NOTE:  If this was an undo delete type operation then
      *                 some surfaces stored in the display_ids array may no
      *                 longer exist.  Therefore each id is checked for
      *                 validity before sent a display message.  It is felt
      *                 that this would be faster and use less code than
      *                 throwing out the bad ids as they are deleted 
      *                 (in deactivate).
      */
     IGRint i;
     enum GRdpmode display_mode=GRbd;  /*DECL*/

     for (i=0; i<*display_count; i++)
     {
       if (om$is_objid_valid(objid = (*display_ids)[i]) == OM_S_SUCCESS)
       {
         OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                                 &my_env->md_env.matrix_type,
                                 my_env->md_env.matrix, &display_mode,
                                 &my_env->md_id),
                           targetid = (*display_ids)[i]);
         if (!(1 & OM_stat & *EMmsg)) goto wrapup;
       }
     }
   }
 }

 wrapup:
  if (*option & EMS_DO_DISPLAY)
  {
    (*involk_count)--;
    if ( !(*involk_count) && *display_ids ) om$dealloc(ptr = *display_ids);
  }

  EMWRAPUP(*EMmsg, OM_stat, "In EMSdpr.EMactivateprims")
  return(OM_stat);
}
end implementation EMSdpr;
