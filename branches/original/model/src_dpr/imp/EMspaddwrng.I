/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfsplit;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"
#include "EMSrgmod.h"

/*
 History	
        DLB     04/03/91      Dont do my stuff if im uneval'd/
        RC      1/3/88        Creation Date
*/

method GRaddwrng(IGRlong *EMmsg; struct GRmd_env *md_env)
{
  IGRboolean   world = FALSE;
  IGRint       i;
  IGRlong      OM_stat=OM_S_SUCCESS;
  IGRlong      mthd_stat;
  GRrange      range;
  struct EMSsspssi_table *my_info;
  union  EMSssi_table    *ssi=NULL;


  *EMmsg = EMS_S_Success;
  
  /*
   * perform the work that I have to do as an owner.
   */

  OM_stat = om$send (mode = OM_e_wrt_message,
                     msg = message GRowner.GRaddwrng (&mthd_stat,
                      md_env),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_Fail,wrapup);

  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    /*
     * Get the save state table
     */
  
    OM_stat = om$send (msg = message EMSdpr.EMgetSSI(&mthd_stat, &ssi),
                  targetid = my_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
  
    my_info = &(ssi->spl_info);
  
    /*
     * add the range of surfaces that are split.
     */
  
    for (i = 0; i < my_info->num_srf; i++)
    {
      OM_stat = om$send (msg = message GRgraphics.GRaddwrng(&mthd_stat,
                            md_env),
                 targetid = my_info->srf_ids[i]);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
  
    } /* for (i = 0; i < my_info->num_srf_owners; i++) */
  }

wrapup:
  if(ssi) om$dealloc (ptr = ssi);
  EMWRAPUP (*EMmsg, OM_stat, "sfsplt.addwrng");
  return (OM_stat);
}
end implementation EMSsfsplit;
