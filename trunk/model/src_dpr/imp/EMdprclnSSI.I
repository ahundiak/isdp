/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "EMSdpr.h"
#include "emsdef.h"

method EMcleanSSI(IGRlong *EMmsg; struct GRmd_env *env;
                  IGRushort options)
/*
Description
    This method will traverse up the dpr tree deleting SSI info in uneval'd
    nodes.

Return Values
    EMS_S_Success if all is well

Notes
    About parameters:
        options - EMclean_ssi_DONT_SEND_UP will prevent this message from 
                  going on up the tree.

History
   DLB 10/11/89  Turn off ACTIVE_PATH bit before deleting SSI.
   DLB 07/24/89  Added DONT_SEND_UP options.
   DLB 12/21/88  Creation.  Dashing thru the snow...
*/
{
 IGRlong         OM_stat=OM_S_SUCCESS;
 OM_S_CHANSELECT to_owners;


 *EMmsg = EMS_S_Success;

 if (!(options & EMclean_ssi_DONT_SEND_UP))
 {
   /*Send on up!.*/
   EMmake_chanselect(GRconnector_to_owners, &to_owners);

   OM_stat = om$send(msg = message EMSdpr.EMcleanSSI(EMmsg, env, options),
                     p_chanselect = &to_owners);
   if (! (1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
   else OM_stat = OM_S_SUCCESS;
 }

 if (ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE)
 {
   /*The svst stuff processes based on the ACTIVE_PATH bit so toggle it off
    * if applicable
    */
   IGRboolean active_path_off=FALSE;

   if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
   {
     ME.EMSdpr->dpr_props &= ~EMSIS_ACTIVE_PATH;
     active_path_off = TRUE;
   }

   /*Delete my save state info.*/
   OM_stat = om$send(msg = message EMSdpr.EMsavestatedelete(EMmsg, env, NULL),
                     targetid = my_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
    
   OM_stat = om$send(msg = message EMSdpr.EMresetSSI(EMmsg),
                     targetid = my_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;                     

   ME.EMSdpr->dpr_props |= EMS_NULL_STATE;

   if (active_path_off)
   {
     ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_PATH;
   }
 }

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.EMcleanSSI")
  return(OM_stat);
}
end implementation EMSdpr;
