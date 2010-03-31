/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "emsdef.h"

from EMSxsection import EMupdate;

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
  IGRlong               OM_stat=OM_S_SUCCESS, tmp_msg;
  OM_S_CHANSELECT       notification;
  struct GRvg_construct construct_list;


  *EMmsg = EMS_S_Success;

  EMmake_chanselect(GRnotify_notification, &notification);

  construct_list.env_info = env;
  construct_list.msg = &tmp_msg;

  om$send(msg = message EMSxsection.EMupdate(&tmp_msg, env, &construct_list),
          p_chanselect = &notification);

  wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "EMSsurface.EMupdate_all_xsec");
    return (OM_stat);                                           
}
end implementation EMSsurface;
