/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"

/*
 History        
        RC      06/09/87        Creation Date
        RC      10/29/87        Modified for version 1.1.0
        DLB     05/31/89        Added code to handle disjoint saveside.
        SM      06-Jul-89       Added bdry_options and sf_options arguments
*/

from EMSboundary  import        EMintcopy;

extern OMuword OPP_EMSsolid_class_id;

method EMintcopy(
        IGRlong         *EMmsg; 
        struct GRmd_env *obj_mdenv;
        struct GRmd_env *new_mdenv; 
        GRobjid         *newobjid;
        struct EMcp_info *copy_info;
        IGRushort bdry_options,  sf_options)
{
  IGRint                i, j , k, l;
  IGRlong               OM_stat;
  IGRlong               mthd_stat;
  IGRboolean            my_copy_exists;

  GRobjid               region_in_cp, region_out_cp, comp_cp, srf_cp;
  union EMSssi_table    *ssi;
  struct EMSboolssi_table *my_info;
  union EMSri_table     *ri;

  void                  EMcpsearch();

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  ssi = NULL;
  ri = NULL;

  /*
   * find out if I have been already copied or not.
   * If so, return my counter part's objid and I am 
   * all done
   */
        
  EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0,
              &my_copy_exists);
                         
  EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

  if (my_copy_exists) goto wrapup;

  /*
   * perform the work that I have to do as a composite surface
   */

  OM_stat = om$send (mode = OM_e_wrt_message,
                     msg = message EMScompsurf.EMintcopy(&mthd_stat,
                      obj_mdenv, new_mdenv, newobjid, copy_info, bdry_options, 
		      sf_options),       
                    targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

  /*
   * copy the objects saved for save state purpsose.
   */

  OM_stat = om$send (msg = message EMSdpr.EMgetSSI(&mthd_stat, &ssi),
                targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  if (ssi)
  {

  my_info = &(ssi->bool_info);

  /*
   * copy the composites
   */

  for(i = 0; i < my_info->num_composites; i ++)
  {
    OM_stat = om$send (msg = message EMSsurface.EMintcopy(
                  &mthd_stat, obj_mdenv, new_mdenv, &comp_cp, copy_info, 
		  bdry_options, sf_options),
                targetid = my_info->composite_ids[i]);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    my_info->composite_ids[i] = comp_cp;
  }

  /*
   * copy the surface_out objects
   */

  l = 0; 
  for (j = 0; j < my_info->num_composites; j++)
  {
    for (k = 0; k < my_info->num_surfaces_out[j]; k++, l++)
    {
      OM_stat = om$send (msg = message EMSsurface.EMintcopy(
                    &mthd_stat, obj_mdenv, new_mdenv, &srf_cp, copy_info, 
		    bdry_options, sf_options),
                 targetid = my_info->surface_out_ids[l]);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

      my_info->surface_out_ids[l] = srf_cp;

    } /* for (k = 0; k < my_info->num_surfaces_out[j]; k++, l++)*/

  } /* for (j = 0; j < my_info->num_composites; j++) */

  /*
   * copy the surfaces affected
   */

  for (j = 0; j < my_info->num_surfaces; j++)
  {
    OM_stat = om$send (msg = message EMSsurface.EMintcopy(
                  &mthd_stat, obj_mdenv, new_mdenv, &srf_cp, copy_info, 
		  bdry_options, sf_options),
               targetid = my_info->surface_ids[j]);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    my_info->surface_ids[j] = srf_cp;
        
  } /* for (j = 0; j < my_info->num_surfaces; j++) */
                  
  /*
   * copy region_in objects
   */
  
  l = 0;
  for (j = 0; j < my_info->num_surfaces; j++)
  {
     for (k = 0; k < my_info->num_regions_in[j]; k++, l++)
     {
       OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                 new_mdenv->md_id.osnum, FALSE, &region_in_cp, copy_info),
              targetid = my_info->region_in_ids[l]);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
        
       my_info->region_in_ids[l] = region_in_cp;

      } /* for (k = 0; k < my_info->num_regions[i]; k++, l++)*/

  } /* for (j = 0; j < my_info->num_surfaces; j++) */

  /*
   * copy region_out objects
   */

  l = 0;
  for (j = 0; j < my_info->num_surfaces; j++)
  {
    for (k = 0; k < my_info->num_regions_out[j]; k++, l++)
    {
       OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                new_mdenv->md_id.osnum, FALSE, &region_out_cp, copy_info),
               targetid = my_info->region_out_ids[l]);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
        
       my_info->region_out_ids[l] = region_out_cp;

     } /* for (k = 0; k < my_info->num_regions_out[j]; k++, l++)*/

  } /* for (j = 0; j < my_info->num_surfaces; j++) */

  /*
   * post the ssi table to the instance data of my copy.
   */

  OM_stat = om$send (msg = message EMSdpr.EMputSSI(&mthd_stat, ssi),
                targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
 }

  /*If saveside on composite surface, copy the RI plane on the vla.*/
  if (!EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                         OPP_EMSsolid_class_id, FALSE))
  {
    /*Get the ri table, copy ri info, and post new ri table to my copy.*/
    ri = NULL;
    OM_stat = om$send(msg = message EMSdpr.EMgetRI(&mthd_stat, &ri),
                      targetid = my_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,mthd_stat,wrapup);

    if (ri)
    {
      OM_stat = om$send(msg = message EMSsurface.EMintcopy(&mthd_stat,
                              obj_mdenv, new_mdenv, &srf_cp, copy_info, 
                              bdry_options, sf_options), 
                        targetid = ri->saveside_info.plane_id);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,mthd_stat,wrapup);

      ri->saveside_info.plane_id = srf_cp;

      OM_stat = om$send(msg = message EMSdpr.EMputRI(&mthd_stat, ri),
                        targetid = *newobjid,
                        targetos = new_mdenv->md_id.osnum);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,mthd_stat,wrapup);
    }
  }

  wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "In EMSsfboolean.EMintcopy");
    if (ssi) om$dealloc(ptr = ssi);
    if (ri) om$dealloc(ptr = ri);
    return (OM_stat);
}
end implementation EMSsfboolean;
