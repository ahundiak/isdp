/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "EMSxsection.h"
#include "OMmacros.h"

/*
 
DESCRIPTION

      This method returns the information regarding surfaces added/
       modified/removed in a lift operation.

HISTORY

      RC   09/22/88   Creation date
*/


from EMSboundary import EMgetsurface_info;

method EMget_mdsfs_info (
  IGRlong                 *EMmsg;
  struct    GRid          st_nd_GRid, end_nd_GRid;
  struct  EMSsfs_md_info  *md_info;
  struct  GRmd_env        *md_env;
  IGRshort                options)
 
{
 OM_S_CHANSELECT               to_owner_chan;
 struct    EMSmvssi_table      *my_info;
 union     EMSssi_table        *ssi;
 IGRlong                       OM_stat, mthd_stat, rc;
 IGRint                        i;
 GRobjid                       *md_sf_ids;
 extern void                   EFadd_gm_md_sfs();

 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 ssi = NULL;
 md_sf_ids = NULL;

 /*
  * 1. Get my SSI table.
  * 2. Get the sfs geometrically modified.
  */

 if (!IF_EQ_OBJID(st_nd_GRid.objid, my_id))
 {
   if ( options & EMS_O_GM_MD_SFS )
   {
     OM_stat = om$send (msg = message EMSdpr.EMgetSSI (&mthd_stat,
                         &ssi), targetid = my_id);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
     my_info = &ssi->mv_info;

     md_sf_ids = (GRobjid *) om$malloc (size = my_info->num_loops *
                                        sizeof(GRobjid));
     EMerr_hndlr (!md_sf_ids, *EMmsg, EMS_E_OMerror, wrapup);

     for (i = 0; i < my_info->num_loops; i++)
     {
       OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info (
                           &mthd_stat, &md_sf_ids[i], NULL),
                          targetid = my_info->loop_ids[i]);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

     } /* for (i = 0; i < my_info->num_loops; i++) */

     EFadd_gm_md_sfs (&rc, md_info, md_sf_ids, my_info->num_loops,
                      OM_Gw_current_OS);
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   } /* if ( options & EMS_O_GM_MD_SFS ) */

 } /* if (!IF_EQ_OBJID(st_nd_GRid.objid, my_id)) */

 /*
  * pass the message to my owners if I am not last node for query.
  */

 if (!IF_EQ_OBJID(end_nd_GRid.objid, my_id))
 {
  to_owner_chan.type = OM_e_addr;
  to_owner_chan.u_sel.addr = &ME.GRconnector->to_owners;

  OM_stat = om$send (msg = OPPmargs, p_chanselect = &to_owner_chan);
  EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
 }

wrapup:

 if (ssi) om$dealloc (ptr = ssi);
 if (md_sf_ids) om$dealloc (ptr = md_sf_ids);

 EMWRAPUP (OM_stat, *EMmsg, "In EMSsfmove.EMget_mdsfs_info");
 
 return (OM_stat);

}

end implementation EMSsfmove;
