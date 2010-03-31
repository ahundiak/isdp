/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "emsdef.h"

method EMupdate_all_xsec(IGRlong *EMmsg; 
                         struct GRmd_env *env;
                         IGRushort options)
/*
Description
    This method will attempt to update all xsections in the tree from bottom
    to top.

Notes
    About parameters:
        options is currently unused.

History
    DLB 01/03/90    Creation.
*/
{
  IGRlong               OM_stat=OM_S_SUCCESS;
  OM_S_CHANSELECT       to_comps;


  *EMmsg = EMS_S_Success;

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  OM_stat = om$send(msg = OPPmargs,
                    p_chanselect = &to_comps);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsurface.EMupdate_all_xsec(EMmsg, env,
                          options),
                    targetid = my_id);

  wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "EMScompsf.EMupdate_all_xsec");
    return (OM_stat);                                           
}
end implementation EMScompsurf;
