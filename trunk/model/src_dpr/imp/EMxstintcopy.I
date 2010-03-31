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

History
        RC        12/02/88       Creation Date
	SM	  06-Jul-89	 added bdry_options and sf_options arguments
*/

from EMSboundary import EMintcopy;

method EMintcopy(
        IGRlong         *EMmsg; 
        struct GRmd_env *obj_mdenv;
        struct GRmd_env *new_mdenv; 
        GRobjid         *newobjid;
        struct EMcp_info *copy_info;
	IGRushort bdry_options, sf_options)

{
  union EMSssi_table      *ssi = NULL;
  struct EMSxsssi_table   *my_info;
  IGRlong                 OM_stat, mthd_stat, rc;
  IGRint                  cur_sf, cur_cmp, cur_lp_in, cur_lp_out, i;
  GRobjid                 cmp_cp, sf_cp, lp_in_cp, lp_out_cp;

  IGRboolean          my_cp_exists;
  extern void         EMcpsearch();

  /* ************************************************************* */

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * find out if I have been already copied or not.
   * If so, return my counter part's objid and I am 
   * all done
   */
	
  EMcpsearch (&rc, my_id, newobjid, copy_info, 0, &my_cp_exists);
  EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  if (my_cp_exists) goto wrapup;

  /*
   * o Do whatever my parent EMSxscompsf wants to do.
   * o Copy save state.
   */

  OM_stat = om$send (mode = OM_e_wrt_message,
                     msg = message EMSxscompsf.EMintcopy (&mthd_stat,
                      obj_mdenv, new_mdenv, newobjid, copy_info, 
		      bdry_options, sf_options),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError,wrapup);

  /*
   * copy the objects used for save state purposes
   */

  OM_stat = om$send (msg = message EMSdpr.EMgetSSI(&mthd_stat, &ssi),
		targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  my_info = &(ssi->xs_info);

  /*
   * copy the composites from which the the surfaces are taken out
   * and the surfaces taken out.
   */

  cur_sf = 0;
  for (cur_cmp = 0; cur_cmp < my_info->num_composites; cur_cmp++)
  {
    OM_stat = om$send (msg = message EMSsurface.EMintcopy(
                        &mthd_stat, obj_mdenv, new_mdenv, &cmp_cp, 
                         copy_info, bdry_options, sf_options),
                      targetid = my_info->composite_ids[cur_cmp]);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    my_info->composite_ids[cur_cmp] = cmp_cp;
                          
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
   * For each surface from which loops were removed/added:
   *  o copy the surface.
   *  o copy the regions in.
   *  o copy the regions out.
   */

  cur_lp_in = cur_lp_out = 0;

  for (cur_sf = 0; cur_sf < my_info->num_surfaces; cur_sf++)
  {
    OM_stat = om$send (msg = message EMSsurface.EMintcopy(
                        &mthd_stat, obj_mdenv, new_mdenv, &sf_cp, 
                         copy_info, bdry_options, sf_options),
                      targetid = my_info->surface_ids[cur_sf]);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    my_info->surface_ids[cur_sf] = sf_cp;

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
   * post the ssi table to the instance data of my copy.
   */

  OM_stat = om$send (msg = message EMSdpr.EMputSSI(&mthd_stat, ssi),
                targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);


  wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.EMintcopy");
  if (ssi) om$dealloc (ptr = ssi);
  return (OM_stat);

}  

end implementation EMSxsec_st;
