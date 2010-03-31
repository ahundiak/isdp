/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "OMmacros.h"
#include "EMSxsection.h"

/*
   DESCRIPTION
      This method is used while updating a cross section. It returns
      the information about the model in regard to what surfaces
      have been added/removed/modified.

   HISTORY

      RC     10/19/88     Creation Date
      
*/

method EMget_mdsfs_info (
  IGRlong                 *EMmsg;
  struct    GRid          st_nd_GRid, end_nd_GRid;
  struct  EMSsfs_md_info  *sfs_md_info;
  struct  GRmd_env        *md_env;
  IGRshort                options)

{
 OM_S_CHANSELECT         to_owners_chan;
 struct          GRid    my_GRid, sender_GRid;
 IGRlong                 OM_stat, rc;

 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 /*
  * 1. If I am not the st_pt_GRid, Get all of the surafces
  *    I own except the one coming from the senderid. These will be
  *    the new surfaces added in going from my sender's state to me.
  * 2. If I am not the end node for query, pass the message to my owner.
  */

  if (!IF_EQ_OBJID(st_nd_GRid.objid, my_id))
  {
    if (options & EMS_O_NEW_SFS)
    {
      my_GRid.objid = my_id;
      my_GRid.osnum = OM_Gw_current_OS;
      sender_GRid.objid = sender_id;
      sender_GRid.osnum = OM_Gw_current_OS;

      EFadd_new_sfs (&rc, sfs_md_info, md_env, my_GRid, sender_GRid);
      EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    } /* if (options & EMS_O_NEW_SFS) */
    
  } /* if (!IF_EQ_OBJID(st_pt_GRid.objid, my_id)) */

  if (!IF_EQ_OBJID(end_nd_GRid.osnum, my_id))
  {
    to_owners_chan.type = OM_e_addr;
    to_owners_chan.u_sel.addr = &ME.GRconnector->to_owners;

    OM_stat = om$send (msg = OPPmargs, p_chanselect = &to_owners_chan);
    EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
  }

 wrapup:
  EMWRAPUP (OM_stat, *EMmsg, "In EMSsurface.EMget_mdsfs_info");
  return (OM_stat);
}

end implementation EMScompsurf;
