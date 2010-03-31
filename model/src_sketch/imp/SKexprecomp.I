class implementation SKexplicit;

#include "dimdef.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimcomplex.h"
#include "nddef.h"

from DMroot import get_info;

method SKrecompute_yourself (IGRlong *msg; struct GRmd_env *md_env;
                             IGRshort *lxy_mattyp; IGRdouble *lxy_mat)
{
  IGRuint count;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  struct diminfo diminfo;
  struct GRid *src;
  OM_S_CHANSELECT chan_to_comps;
  OM_S_OBJECT_LINKAGE dimobj;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_comps,
   count = &count, size = 1, list = &dimobj);
  if (count)
    {
    stat_OM = om$send (msg = message DMroot.get_info ((int *) &msg_loc, 
               md_env, &diminfo), targetid = dimobj.S_objid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    src = &diminfo.list[DIM_CPX_ORIG];
    count = diminfo.count - 3;
    for (i=0; i<count; i++)
      {
      stat_OM = om$send (msg = message NDnode.NDs_compute_node (&msg_loc,
                 ND_COMP, md_env), targetid = src[i].objid);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }

    stat_OM = om$send (msg = message NDnode.NDs_compute_node (&msg_loc,
               ND_COMP, md_env), targetid = dimobj.S_objid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKexplicit.SKrecompute");
  return (stat_OM);
}

end implementation SKexplicit;


