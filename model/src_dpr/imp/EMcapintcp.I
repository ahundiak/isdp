class implementation EMSsfcapsf;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"

/*

HISTORY

    AMD  :  11/14/92 :  Creation 

*/

from EMSboundary  import        EMintcopy;

extern OMuword OPP_EMSsolid_class_id;

method EMintcopy( IGRlong          *EMmsg; 
                  struct GRmd_env  *obj_mdenv;
                  struct GRmd_env  *new_mdenv; 
                  GRobjid          *newobjid;
                  struct EMcp_info *copy_info;
                  IGRushort        bdry_options,  sf_options)
{
  IGRint                i;
  IGRlong               OM_stat;
  IGRlong               mthd_stat;
  IGRboolean            my_copy_exists;

  GRobjid               srf_cp, edges_cp;
  union EMSssi_table    *ssi;
  struct EMScapssi_table *my_info;

  void                  EMcpsearch();

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  ssi = NULL;

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

  my_info = &(ssi->cap_info);

  for (i = 0; i < my_info->num_edges; i++)
   {
     if(my_info->edges_connected[i] == NULL_OBJID)
        edges_cp = NULL_OBJID;
     else
       {
        OM_stat = om$send (msg = message EMSboundary.EMintcopy(
                           &mthd_stat, NULL, obj_mdenv->md_id.osnum, 
                           new_mdenv->md_id.osnum, FALSE, &edges_cp, 
                           copy_info),
                  targetid = my_info->edges_connected[i]);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
       }

     my_info->edges_connected[i] =  edges_cp;
   }

  OM_stat = om$send (msg = message EMSdpr.EMputSSI(&mthd_stat, ssi),
                targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
 }


 wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "In EMSsfcapsf.EMintcopy");
    if (ssi) om$dealloc(ptr = ssi);
    return (OM_stat);
}
end implementation EMSsfcapsf;
