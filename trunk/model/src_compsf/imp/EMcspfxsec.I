/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxscompsf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"

/*

 DESCRIPTION
    This is pass on method used in evaluating a cross section.

 HISTORY

    RC    10/12/88     Creation Date
*/

method EMperform_xsection(
       IGRlong                   *EMmsg;
       struct GRvg_construct     *construct_list;
       struct GRmd_env           *cs_env;
       struct GRid               *model_GRid;
       struct GRmd_env           *model_env;
       struct EMSxs_assoc_info   *xs_assoc_info)
{
  OM_S_CHANSELECT  to_cmpnt_chan;
  IGRlong          OM_stat;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
 
  to_cmpnt_chan.type = OM_e_addr;
  to_cmpnt_chan.u_sel.addr = &ME.GRcmpowner->to_components;

  OM_stat = om$send (msg = OPPmargs,
                     p_chanselect = &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat & *EMmsg),*EMmsg,EMS_E_SurfaceError, wrapup);

 wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSxscompsf.EMperform_xsection");
  return (OM_stat);
}
end implementation EMSxscompsf;
