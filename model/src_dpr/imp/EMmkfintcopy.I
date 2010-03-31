/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmkface;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"
#include "EMSrgmod.h"

/*
 History	
	RC	06/09/87	Creation Date
        RC      10/29/87        Modified for version 1.1.0
	SM	06-Jul-89	Added bdry_options and sf_options arguments
*/

from EMSboundary  import 	EMintcopy;

method EMintcopy(
        IGRlong                 *EMmsg; 
        struct GRmd_env         *obj_mdenv;
        struct GRmd_env         *new_mdenv; 
        GRobjid                 *newobjid;
        struct EMcp_info        *copy_info;
	IGRushort       bdry_options,  sf_options)
{
  IGRint                i, j , k, l;
  IGRlong               OM_stat;
IGRlong   mthd_stat;
  IGRboolean            my_copy_exists;
  GRobjid               region_in_cp, region_out_cp, edge_in_cp, 
                        region_cp, edge_out_cp, edge_cp;
  union	EMSssi_table    *ssi;		
  struct EMSmfssi_table *my_info;
  void                  EMcpsearch();

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  ssi = NULL;

  /*
   * find out if I have been already copied or not.
   * If so, return my counter part's objid and I am 
   * all done
   */
	
  EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, &my_copy_exists);
  EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

  if (my_copy_exists) goto wrapup;

  /*
   * perform the work that I have to do as a composite surface
   */

  OM_stat = om$send (mode = OM_e_wrt_message,
		     msg = message EMScompsurf.EMintcopy(&mthd_stat,
		       obj_mdenv, new_mdenv, newobjid, copy_info,
		bdry_options, sf_options),	
		     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  /*
   * copy the objects used for save state purposes
   */

  OM_stat = om$send (msg = message EMSdpr.EMgetSSI(&mthd_stat, &ssi),
		targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  if (ssi)
  {

  my_info = &(ssi->mf_info);

  /*
   * copy surfaces affected
   */

  l = 0;

  if (my_info->num_surfaces)
  {
    GRobjid             srf_cp;

    for (l = 0; l < my_info->num_surfaces; l++)
    {
      OM_stat = om$send (msg = message EMSsurface.EMintcopy(
                  &mthd_stat, obj_mdenv, new_mdenv, &srf_cp, copy_info, 
		  bdry_options, sf_options),
               targetid = my_info->surface_ids[l]);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

      my_info->surface_ids[l] = srf_cp;
	
    } /* for (l = 0; l < my_info->num_surfaces; l++) */
		  
  } /* if (my_info->num_surfaces) */
  
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
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
        my_info->region_in_ids[l] = region_in_cp;

     } /* for (k = 0; k < my_info->num_regions[j]; k++, l++)*/

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
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
        my_info->region_out_ids[l] = region_out_cp;

     } /* for (k = 0; k < my_info->num_regions_out[j]; k++, l++)*/

  } /* for (j = 0; j < my_info->num_surfaces; j++) */

  /*
   * copy regions affected
   */

  for (j = 0; j < my_info->num_regions; j++)
  {
     OM_stat = om$send (msg = message EMSboundary.EMintcopy(
            &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
            new_mdenv->md_id.osnum, FALSE, &region_cp, copy_info),
         targetid = my_info->region_ids[j]);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
     my_info->region_ids[j] = region_cp;

  } /* for (j = 0; j < my_info->num_regions; j++, i++) */

  /*
   * copy the edge_in objects
   */

  l = 0;
  for (j = 0; j < my_info->cum_num_edges_out; j++)
  {
     for (k = 0; k < my_info->num_edges_in[j]; k++, l++)
     {
       OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                 &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                 new_mdenv->md_id.osnum, FALSE, &edge_in_cp, copy_info),
              targetid = my_info->edge_in_ids[l]);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
       my_info->edge_in_ids[l] = edge_in_cp;

     } /* for (k = 0; k < my_info->num_regions_out[j]; k++, l++)*/

  } /* for (j = 0; j < my_info->num_surfaces; j++) */

  /*
   * copy edge_out objects
   */

  l = 0;
  for (j = 0; j < my_info->num_regions; j++)
  {
     for (k = 0; k < my_info->num_edges_out[j]; k++, l++)
     {
        OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                new_mdenv->md_id.osnum, FALSE, &edge_out_cp, copy_info),
             targetid = my_info->edge_out_ids[l]);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
        my_info->edge_out_ids[l] = edge_out_cp;

     } /* for (k = 0; k < my_info->num_regions_out[j]; k++, l++)*/

  } /* for (j = 0; j < my_info->num_surfaces; j++) */

  /*
   * copy edges whose common edge connections are moved
   */

  for (j = 0; j < 2 * my_info->num_edges_copied; j++)
  {
    OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                new_mdenv->md_id.osnum, FALSE, &edge_cp, copy_info),
             targetid = my_info->ed_cp_ed_ids[j]);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
        my_info->ed_cp_ed_ids[j] = edge_cp;

 } /* for (j = 0; j < 2 * my_info->num_edges_copied; j++) */

   /*
   * post the ssi table to the instance data of my copy.
   */

  OM_stat = om$send (msg = message EMSdpr.EMputSSI(&mthd_stat, ssi),
                targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
 }

wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "In EMSsfmkface.EMintcopy");
    if (ssi) om$dealloc(ptr = ssi);

    return (OM_stat);
}
end implementation EMSsfmkface;
