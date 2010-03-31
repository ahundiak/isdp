/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxscompsf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"

/*
  DESCRIPTION

      This is a pass on method used while updating a cross section.

  HISTORY
      
      RC   10/05/88     Creation Date

*/

method EMperform_xsection_update (
       IGRlong                       *EMmsg;
       struct   GRvg_construct       *construct_list;
       struct   GRmd_env             *cs_env, *mdl_env;
       struct   EMSsfs_md_info       *sfs_md_info;
       struct   EMSxsreg_md_info     *reg_md_info;
       struct   EMSxs_assoc_info     *xs_assoc_info;
       GRrange                       mdl_range;
       struct   GRid                 *xs_act_st_GRid;
       IGRboolean                    *is_sf_active)

{
   OM_S_CHANSELECT   to_cmpnt_chan;
   IGRlong           OM_stat;

   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   OM_stat = om$send (msg = OPPmargs, p_chanselect = &to_cmpnt_chan);
   EMerr_hndlr (!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

 wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMScompsurf.EMperform_xsection_update");

  return (OM_stat);

}
end implementation EMSxscompsf;
