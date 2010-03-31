/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSxsection.h"
#include "OMmacros.h"

/*
  HISTORY

     RC      09/23/88   Creation Date
*/


method EMget_mdsfs_info (
  IGRlong                 *EMmsg;
  struct    GRid          st_nd_GRid, end_nd_GRid;
  struct  EMSsfs_md_info  *md_info;
  struct  GRmd_env        *md_env;
  IGRshort                options)

{
  OM_S_CHANSELECT         to_owners_chan;
  IGRlong                 OM_stat;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  /*
   * I have to be the start_node of the srach. If not somthing
   * went wrong. Pass the message up my owners channel.
   */

  if (IF_EQ_OBJID (st_nd_GRid.objid, my_id) )
  {
    to_owners_chan.type = OM_e_addr;
    to_owners_chan.u_sel.addr = &ME.GRconnector->to_owners;

    OM_stat = om$send (msg = OPPmargs,
                       p_chanselect = &to_owners_chan);
    EMerr_hndlr (!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
  else
   EMerr_hndlr (TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSsubbs.EMget_mdsfs_info");
   return (OM_stat);
}
end implementation EMSsubbs;
