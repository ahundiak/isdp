/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"

from EMSboundary  import 	EMintcopy;

method EMintcopy(
        IGRlong                 *EMmsg; 
        struct GRmd_env         *obj_mdenv;
        struct GRmd_env         *new_mdenv; 
        GRobjid                 *newobjid;
        struct EMcp_info        *copy_info;
	IGRushort	bdry_options, sf_options)

{
  IGRint                i, j , k, l;
  IGRlong               OM_stat;
  IGRlong   		mthd_stat;
  IGRboolean            my_copy_exists;
  GRobjid               edge_cp;
  union  EMSssi_table   *ssi = NULL;
  struct EMSstchssi_table *my_info = NULL;
  void                  EMcpsearch();

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

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

  my_info = &(ssi->stch_info);


  /*
   * copy the edge_in objects
   */
  l = 0;
  for (j = 0; j < my_info->num_edges_out; j++)
  {
   for (k = 0; k < my_info->num_edges_in[j]; k++, l++)
    {
     OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                 &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                 new_mdenv->md_id.osnum, FALSE, &edge_cp, copy_info),
              targetid = my_info->edges_in[l]);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
     my_info->edges_in[l] = edge_cp;
    } 
  } 

  /*
   * copy edge_out objects
   */

 for (k = 0; k < my_info->num_edges_out; k++)
  {
   OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                new_mdenv->md_id.osnum, FALSE, &edge_cp, copy_info),
             targetid = my_info->edges_out[k]);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
   my_info->edges_out[k] = edge_cp;
  } 


  /* 
   * Copy the edges connected
   */
 for (k = 0; k < my_info->num_edges_connected; k++)
  {
   OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                new_mdenv->md_id.osnum, FALSE, &edge_cp, copy_info),
             targetid = my_info->edges_connected[k]);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
	
   my_info->edges_connected[k] = edge_cp;
  } 


  /*
   * post the ssi table to the instance data of my copy.
   */

  OM_stat = om$send (msg = message EMSdpr.EMputSSI(&mthd_stat, ssi),
                targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
 }

wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "In EMSsfstitch.EMintcopy");
    if (ssi) om$dealloc(ptr = ssi);
    return (OM_stat);
}

end implementation EMSsfstitch;
