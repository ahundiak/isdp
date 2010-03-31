/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfhist;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"

/*
 History	
	RC	06/09/87	Creation Date
        RC      10/29/87        Modified for version 1.1.0
	SM	06-Jul-89	Added bdry_options and sf_options arguments
*/

method EMintcopy(
        IGRlong                 *EMmsg; 
        struct GRmd_env         *obj_mdenv;
        struct GRmd_env         *new_mdenv; 
        GRobjid                 *newobjid;
        struct EMcp_info        *copy_info;
	IGRushort       bdry_options,  sf_options)
{
  IGRint                i;
  IGRlong               OM_stat;
IGRlong   mthd_stat;
  IGRboolean            my_copy_exists;
  GRobjid               hist_cp;
  OMuint                chan_count;
  union EMSssi_table    *ssi;
  struct EMShstssi_table *my_info;
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

  my_info = &(ssi->hst_info);

  /*
   * copy the states affected
   */

    OM_stat = om$send (msg = message EMSsurface.EMintcopy (
                  &mthd_stat, obj_mdenv, new_mdenv, &hist_cp, copy_info, 
		  bdry_options, sf_options),
		  targetid = my_info->added_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail,wrapup);

    my_info->added_id = hist_cp;

    OM_stat = om$send (msg = message EMSsurface.EMintcopy (
                  &mthd_stat, obj_mdenv, new_mdenv, &hist_cp, copy_info, 
		  bdry_options, sf_options),
		  targetid = my_info->added_on);
    EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail,wrapup);

    my_info->added_on = hist_cp;


  /*
   * post the ssi table to the instance data of my copy.
   */

  OM_stat = om$send (msg = message EMSdpr.EMputSSI(&mthd_stat, ssi),
                targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
 }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfhist.EMintcopy")
  if (ssi) om$dealloc (ptr = ssi);

  return(OM_stat);
}

end implementation EMSsfhist;
