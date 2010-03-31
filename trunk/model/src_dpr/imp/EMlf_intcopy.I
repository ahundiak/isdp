/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"
#include "EMSrgmod.h"

/*
  This file contains the internal copy implementaion
  of a regular lift operation.

 History	
        RC      06/09/87        Creation Date
        RC      10/29/87        Modified for version 1.1.0
        RC      03/15/88        Rewrote for version 1.2.0
        RC      02/13/89        Donot try to copy the composite
                                ids in the save_state info if 
                                they are NULL_OBJIDS.
	SM	06-Jul-89	Added bdry_options and sf_options arguments
*/

from EMSboundary import EMintcopy;

method EMintcopy(
        IGRlong                 *EMmsg; 
        struct GRmd_env         *obj_mdenv;
        struct GRmd_env         *new_mdenv; 
        GRobjid                 *newobjid;
        struct EMcp_info        *copy_info;
	IGRushort	bdry_options, sf_options)

{
  union EMSssi_table          *ssi;
  struct EMSlftssi_table   *my_info;
  GRobjid                     sf_cp, ed_in_cp, ed_out_cp, ed_cp, lp_in_cp,
                              lp_out_cp, ed_rplcd_cp, cmp_cp;
  IGRint                      i, cur_ed, cur_ed_in, cur_lp_in, cur_cmp,
                              cur_lp_out, cur_sf;
  IGRboolean                  my_copy_exists;
  IGRlong                     OM_stat;
IGRlong   mthd_stat;
  void                        EMcpsearch();

  /* ************************************************************ */

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  ssi = NULL;

  /*
   * find out if I have been already copied or not.
   * If so, return my counter part's objid and I am all done
   */
	
  EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, &my_copy_exists);
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
   * copy the objects used for save state purposes
   */

  OM_stat = om$send (msg = message EMSdpr.EMgetSSI(&mthd_stat, &ssi),
		             targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  if (ssi)
  {
  my_info = &(ssi->lft_info);


  /*
   * copy the composites from which the the surfaces are taken out
   * and the surfaces taken out.
   */

  cur_sf = 0;
  for (cur_cmp = 0; cur_cmp < my_info->num_composites; cur_cmp++)
  {
    /*
     * Incase of single surface lift w draft, the composite id will
     * be NULL_OBJID.
     */

    if (my_info->composite_ids[cur_cmp] != NULL_OBJID)
    {
     OM_stat = om$send (msg = message EMSsurface.EMintcopy(
                         &mthd_stat, obj_mdenv, new_mdenv, &cmp_cp, 
                          copy_info, bdry_options, sf_options),
                       targetid = my_info->composite_ids[cur_cmp]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
     my_info->composite_ids[cur_cmp] = cmp_cp;

    } /* if (my_info->composite_ids[cur_cmp] != NULL_OBJID) */
     
    for (i = 0; i < my_info->num_surfaces_out[cur_cmp]; i++, cur_sf++)
    {
      OM_stat = om$send (msg = message EMSsurface.EMintcopy(
                          &mthd_stat, obj_mdenv, new_mdenv, &sf_cp, 
                           copy_info, bdry_options, sf_options),
                      targetid = my_info->surface_out_ids[cur_sf]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

      my_info->surface_out_ids[cur_sf] = sf_cp;

    }/* for (i = 0; i < my_info->num_surfaces_out[cur_cmp]; i++, 
        cur_sf++) */

  } /* for (cur_cmp = 0; cur_cmp < my_info->num_composites; cur_cmp++) */

  /*
   * copy the surfaces that are lifted
   */

  for (cur_sf = 0; cur_sf < my_info->num_sf_lifted; cur_sf++)
  {
    OM_stat = om$send (msg = message EMSsurface.EMintcopy(
                        &mthd_stat, obj_mdenv, new_mdenv, &sf_cp, 
                         copy_info, bdry_options, sf_options),
                      targetid = my_info->sf_lifted_ids[cur_sf]);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    my_info->sf_lifted_ids[cur_sf] = sf_cp;

  } /* for (cur_sf = 0; cur_sf < my_info->num_sf_lifted; cur_sf++) */

  /*
   * For each surface from which loops were removed/added:
   *  o copy the surface.
   *  o copy the regions in.
   *  o copy the regions out.
   */

  cur_lp_in = cur_lp_out = 0;

  for (cur_sf = 0; cur_sf < my_info->num_sf_affected; cur_sf++)
  {
    OM_stat = om$send (msg = message EMSsurface.EMintcopy(
                        &mthd_stat, obj_mdenv, new_mdenv, &sf_cp, 
                         copy_info, bdry_options, sf_options),
                      targetid = my_info->sf_affctd_ids[cur_sf]);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    my_info->sf_affctd_ids[cur_sf] = sf_cp;

    for (i = 0; i < my_info->num_regions_in[cur_sf]; i++, cur_lp_in++)
    {
      OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                          &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                           new_mdenv->md_id.osnum, FALSE, 
                          &lp_in_cp, copy_info),
                         targetid = my_info->region_in_ids[cur_lp_in]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
      my_info->region_in_ids[cur_lp_in] = lp_in_cp;

    } /* for (i = 0; i < my_info->num_regions_in[cur_sf]; i++, 
              cur_lp_in++) */

    for (i = 0; i < my_info->num_regions_out[cur_sf]; i++, cur_lp_out++)
    {
      OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                          &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                           new_mdenv->md_id.osnum, FALSE, 
                          &lp_out_cp, copy_info),
                         targetid = my_info->region_out_ids[cur_lp_out]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
      my_info->region_out_ids[cur_lp_out] = lp_out_cp;

    } /* for (i = 0; i < my_info->num_regions_in[cur_sf]; i++, 
              cur_lp_out++) */

  } /* for (cur_sf = 0; cur_sf < my_info->num_sf_affected; cur_sf++) */


  /*
   * For each edge replaced:
   * o Copy the edge replaced.
   * o Copy the edges replacing the above edge.
   */

  cur_ed_in = 0;
  for (cur_ed = 0; cur_ed < my_info->num_eds_rplcd; cur_ed++)
  {
    OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                        &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                         new_mdenv->md_id.osnum, FALSE, 
                        &ed_rplcd_cp, copy_info),
                       targetid = my_info->ed_rplcd_ids[cur_ed]);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
    my_info->ed_rplcd_ids[cur_ed] = ed_rplcd_cp;

    for ( i= 0; i < my_info->num_eds_in[cur_ed]; i++, cur_ed_in++)
    {
      OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                          &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                          new_mdenv->md_id.osnum, FALSE, 
                          &ed_in_cp, copy_info),
                         targetid = my_info->ed_in_ids[cur_ed_in]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
      my_info->ed_in_ids[cur_ed_in] = ed_in_cp;

    } /* for ( i= 0; i < my_info->num_eds_in[cur_ed]; i++, 
               cur_ed_in++) */
 
  } /* for (cur_ed = 0; cur_ed < my_info->num_eds_rplcd; cur_ed++) */
 
  /*
   * Copy the edges whose common edges have been modified.
   */

  for (cur_ed = 0; cur_ed < (my_info->num_eds_wcm_md * 4); cur_ed++)
  {
    if (my_info->ed_mcm_ed_ids[cur_ed] != NULL_OBJID)
    {
      OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                          &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                          new_mdenv->md_id.osnum, FALSE, 
                          &ed_cp, copy_info),
                         targetid = my_info->ed_mcm_ed_ids[cur_ed]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
      my_info->ed_mcm_ed_ids[cur_ed] = ed_cp;

    } /* if (my_info->ed_mcm_ed_ids[cur_ed] != NULL_OBJID) */

  } /* for (cur_ed = 0; cur_ed < (my_info->num_eds_wcm_md * 4); 
            cur_ed++) */
 
  /*
   * Copy the edges among which the common edge was moved
   */

  for (cur_ed = 0; cur_ed < (my_info->num_ed_wmv_cm * 2); cur_ed++)
  {
    OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                        &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                        new_mdenv->md_id.osnum, FALSE, 
                        &ed_cp, copy_info),
                       targetid = my_info->ed_ced_ids[cur_ed]);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
    my_info->ed_ced_ids[cur_ed] = ed_cp;

  } /* for (cur_ed = 0; cur_ed < (my_info->num_ed_wmv_cm * 2); 
            cur_ed++) */

  /*
   * Copy the edges which have common edges after the lift process
   * is complete.
   */

 for (cur_ed = 0; cur_ed < (my_info->num_eds_wcm_eds * 2); cur_ed++)
 {
    OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                        &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                        new_mdenv->md_id.osnum, FALSE, 
                        &ed_cp, copy_info),
                       targetid = my_info->ed_cm_ed_ids[cur_ed]);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
    my_info->ed_cm_ed_ids[cur_ed] = ed_cp;

 } /* for (cur_ed = 0; cur_ed < (my_info->num_eds_wcm_eds * 2); 
           cur_ed++) */

  /*
   * post the ssi table to the instance data of my copy.
   */

  OM_stat = om$send (msg = message EMSdpr.EMputSSI(&mthd_stat, ssi),
                targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
 }

wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "In EMSlift.EMintcopy");
    if (ssi) om$dealloc(ptr = ssi);

    return (OM_stat);
}

end implementation EMSlift;
