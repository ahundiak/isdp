/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmkface;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "EMSxsection.h"
#include "OMmacros.h"
/*
 
DESCRIPTION

      This method returns the information regarding surfaces added/
       modified/removed in a make face operation.

HISTORY

      RC   09/22/88   Creation date
*/


method EMget_mdsfs_info (
  IGRlong                 *EMmsg;
  struct    GRid          st_nd_GRid, end_nd_GRid;
  struct  EMSsfs_md_info  *md_info;
  struct  GRmd_env        *md_env;
  IGRshort                options)

{
 OM_S_CHANSELECT               to_owners;
 struct    EMSmfssi_table      *my_info;
 struct    GRid                my_GRid, sender_GRid;
 union     EMSssi_table        *ssi;
 IGRlong                       OM_stat, mthd_stat, rc;
 extern void                   EFadd_tp_md_sfs(), EFadd_new_sfs();

 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 ssi = NULL;

 /*
  * 1. Get the surfaces added to the model.
  * 2. Get my SSI table.
  * 3. Get the sfs removed. If any of these removed sfs are in the
  *    addition list, take it out. Also, if the surface is geometrically
  *    modified, take it out.
  * 4. Get the sfs topologically modified.
  * 5. Get the sfs geometrically modified.
  */

 if (!IF_EQ_OBJID(st_nd_GRid.objid, my_id))
 {
   if (options & EMS_O_NEW_SFS)
   {
     my_GRid.objid = my_id;
     sender_GRid.objid = sender_id;
     my_GRid.osnum = sender_GRid.osnum = OM_Gw_current_OS;

     EFadd_new_sfs (&rc, md_info, md_env, my_GRid, sender_GRid);
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   } /* if (options & EMS_O_NEW_SFS) */

   if ( options & EMS_O_TP_MD_SFS )
   {
     OM_stat = om$send (msg = message EMSsfregmod.EMgetSSI (&mthd_stat,
                         &ssi), targetid = my_id);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
     my_info = &ssi->mf_info;

     /*
      * Get the topologically modified surfaces.
      */

     EFadd_tp_md_sfs (&rc, md_info, my_info->surface_ids,
                      my_info->num_surfaces, OM_Gw_current_OS);
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   } /* if ( options & EMS_O_TP_MD_SFS ) */

 } /* if (!IF_EQ_OBJID(st_pt_GRid.objid, my_id)) */

 /*
  * pass the message to my owners if I am not last node for query.
  */

 if (!IF_EQ_OBJID(end_nd_GRid.objid, my_id))
 {
  to_owners.type = OM_e_addr;
  to_owners.u_sel.addr = &ME.GRconnector->to_owners;

  OM_stat = om$send (msg = OPPmargs, p_chanselect = &to_owners);
  EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
 }

wrapup:

 if (ssi) om$dealloc (ptr = ssi);
 EMWRAPUP (OM_stat, *EMmsg, "In EMSsfmkface.EMget_mdsfs_info");
 
 return (OM_stat);

}

end implementation EMSsfmkface;

