/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"

/*
 History        
        DLB     04/03/91      Dont do my stuff if im uneval'd/
        RC      1/3/88        Creation Date
*/

extern OMuword OPP_EMSsolid_class_id;

method GRaddwrng(IGRlong *EMmsg; struct GRmd_env *md_env)
{
  IGRboolean   world = FALSE;
  IGRint       j, k, l;
  IGRlong      OM_stat=OM_S_SUCCESS;
  IGRlong      mthd_stat;
  GRrange      range;
  struct EMSboolssi_table *my_info;
  union  EMSssi_table     *ssi=NULL;
  union EMSri_table       *ri=NULL;


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
  
    my_info = &(ssi->bool_info);
  
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
  
    /*This code is added for the saveside on composite surface
     * or disjoint saveside special case.  The plane is stored on the end of
     * the vla and was used to recompute the saveside.
     */
    if (!EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS, 
                           OPP_EMSsolid_class_id, FALSE))
    {
      ri = NULL;
      OM_stat = om$send(msg = message EMSdpr.EMgetRI(&mthd_stat, &ri),
                        targetid = my_id);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,mthd_stat,wrapup);
  
      if (ri)
      {
        OM_stat = om$send(msg = message GRgraphics.GRaddwrng(&mthd_stat,
                                  md_env),
                          targetid = ri->saveside_info.plane_id);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,mthd_stat,wrapup);
      }
    }
  }

wrapup:
  if (ri) om$dealloc(ptr = ri);
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP (*EMmsg, OM_stat, "sfb.addwrng")
  return (OM_stat);
}
end implementation EMSsfboolean;
