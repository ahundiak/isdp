/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsec_st;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSssi.h"
#include "OMprimitives.h"
#include "OMmacros.h"

/*

Description

    This method will delete the saved assoc info that is not currently in
    the topology.  ONLY information that would never get a delete message
    by another path should be deleted.

Return values
    EMS_S_Success if all is well.

History
        RC   10/13/88        Creation Date

*/

method EMsavestatedelete(
       IGRlong           *EMmsg; 
       struct GRmd_env   *md_env;
       union EMSssi_table *ssi)

{
  union     EMSssi_table     *loc_ssi;
  struct    EMSxsssi_table   *my_info;
  IGRlong                    OM_stat, mthd_stat;
  IGRint                     i, j;
  GRobjid                    *lp_out, *lp_in;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (!ssi)
  {
    OM_stat = om$send (msg = message EMSsfregmod.EMgetSSI (&mthd_stat,
                        &loc_ssi), targetid = my_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail,wrapup);
  }
  else
    loc_ssi = ssi;

  my_info = &loc_ssi->xs_info;

 /*
  * If I am in the active path, delete all of the objects
  * which were taken out while performing this operation, namely:
  *
  * o Loops taken out.
  */

 if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
 {
   lp_out = my_info->region_out_ids;
   for (i = 0; i < my_info->num_surfaces; i++)
   {
     for (j = 0; j < my_info->num_regions_out[i]; j++, lp_out++)
     {
       OM_stat = om$send(msg = message Root.delete(NULL),
                         targetid = *lp_out);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_LoopError,wrapup);

     } /* for (j = 0; j < my_info->num_regions_out[i]; j++, lp_out++) */

   } /* for (i = 0; i < my_info->num_surfaces; i++) */

 } /* if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) */

 else                /*  Not active    */
 {
   /*
    * If I am not active, delete all of the objects which
    * have been stored for redo purpose and can not be accessed
    * by anybody else:
    *
    * o Loops added.
    */
   
   lp_in = my_info->region_in_ids;
   for (i = 0; i < my_info->num_surfaces; i++)
   {
     for (j = 0; j < my_info->num_regions_in[i]; j++, lp_in++)
     {
       OM_stat = om$send(msg = message Root.delete(NULL),
                         targetid = *lp_in);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_LoopError,wrapup);

     } /* for (j = 0; j < my_info->num_regions_in[i]; j++, lp_in++) */

   } /* for (i = 0; i < my_info->num_surfaces; i++) */

 } /* else for if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) */

  
 wrapup:
  if (loc_ssi && !ssi) om$dealloc(ptr = loc_ssi);
  EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.EMsavestatedelete");
  return (OM_stat);
}
end implementation EMSxsec_st;
