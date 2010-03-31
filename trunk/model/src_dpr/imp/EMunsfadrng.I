class implementation EMSsfunitesf;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"

/*
 HISTORY 

   07/14/92  :  AMD :  Creation       

*/

extern OMuword OPP_EMSsolid_class_id;

method GRaddwrng(IGRlong *EMmsg; struct GRmd_env *md_env)
{
  IGRboolean   world = FALSE;
  IGRint       j, k, l;
  IGRlong      OM_stat=OM_S_SUCCESS;
  IGRlong      mthd_stat;
  GRrange      range;
  struct EMSunssi_table *my_info;
  union  EMSssi_table     *ssi=NULL;


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
  
    my_info = &(ssi->un_info);
  
    /*
     * add the range of taken out surfaces.
     */
  
    l = 0; 
    for (j = 0; j < my_info->num_composites; j++)
    {
      for (k = 0; k < my_info->num_surfaces_out[j]; k++, l++)
      {
        OM_stat = om$send (msg = message GRgraphics.GRaddwrng(&mthd_stat,
                            md_env),
                          targetid = my_info->surface_out_ids[l]);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
  
      } /* for (k = 0; k < my_info->num_surfaces_out[j]; k++, l++)*/
  
    } /* for (j = 0; j < my_info->num_composites; j++) */
  
  }

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP (*EMmsg, OM_stat, "EMSsfunitesf.addwrng")
  return (OM_stat);
}
end implementation EMSsfunitesf;
