/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

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

from EMSboundary import EMintcopy;

method EMintcopy(
        IGRlong         *EMmsg; 
        struct GRmd_env *obj_mdenv;
        struct GRmd_env *new_mdenv; 
        GRobjid         *newobjid;
        struct EMcp_info *copy_info;
	IGRushort       bdry_options,  sf_options)
{
  IGRboolean		my_copy_exists;
  IGRlong 		OM_stat;
IGRlong   mthd_stat;
  IGRint                i;
  GRobjid               lp_cp;
  union  EMSssi_table   *ssi;
  struct EMSmvssi_table *my_info;
  void 			EMcpsearch();

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

  ssi = NULL;

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

  my_info = &(ssi->mv_info);

  /*
   * copy the loops used for save state
   */

  for (i = 0; i < my_info->num_loops; i++)
  {
    OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                 &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                 new_mdenv->md_id.osnum, FALSE, &lp_cp, copy_info),
              targetid = my_info->loop_ids[i]);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
    my_info->loop_ids[i] = lp_cp;

  } /* for (i = 0; i < my_info->num_loops; i++) */

  /*
   * post the ssi table to the instance data of my copy.
   */

  OM_stat = om$send (msg = message EMSdpr.EMputSSI(&mthd_stat, ssi),
                targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "In EMSsfmove.EMintcopy");
    if (ssi) om$dealloc(ptr = ssi);

    return (OM_stat);
}

end implementation EMSsfmove;
