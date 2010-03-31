class implementation EMScnstrgmhn;

#include "dpdef.h"
#include "dp.h"
#include "emsdef.h"
#include "nddef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from EMSimpcnstr import EMgeomhandle;

method NDupdate (IGRint *msg; IGRint cn_type; IGRint count;
                 struct GRid *parents; IGRint *parent_state;
                 struct GRid *context, *new_objid;
                 struct GRmd_env *md_env)
{
  IGRboolean update_error;
  IGRlong msg_loc, stat_OM;
  GRobjid store_md_id;
  enum GRdpmode dpmode;
  OM_S_CHANSELECT chan_to_owners;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  new_objid->objid = my_id;
  new_objid->osnum = OM_Gw_current_OS;
  update_error = FALSE;

  /*
   * Unless inhibited, erase myself.
   */

  if (!(cn_type & ND_COMP_NO_ERASE))
    {
    dpmode = GRbehe;
    om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
     &md_env->md_env.matrix_type, md_env->md_env.matrix, &dpmode,
     &md_env->md_id), targetid = my_id);
    }

  /*
   * Recomputation is being done outside the rtree to simplify the
   * the conflicting demands from macro copy/recomputation and 
   * recomputation when a parent is changed. Further, it ensures that we do not
   * mess up the rtree should the recomputation fail. So first, unless
   * inhibited, remove the object from the R-tree.
   */

  if (!(cn_type & ND_COMP_NO_REM_RT) && (md_env->md_id.objid != NULL_OBJID))
    om$send (msg = message GRgraphics.GRremwrng (&msg_loc, md_env),
     targetid = my_id);

  /*
   * Recompute myself
   */

  msg_loc = EMS_E_Fail;
  EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);
  store_md_id = md_env->md_id.objid;
  md_env->md_id.objid = NULL_OBJID;

  om$send (msg = message EMSimpcnstr.EMgeomhandle (&msg_loc, NULL,
   md_env, NULL), p_chanselect = &chan_to_owners);

  md_env->md_id.objid = store_md_id;
  if (EMSerror (msg_loc))
    update_error = TRUE;

  /*
   * Unless inhibited, redraw myself
   */

  if (!(cn_type & ND_COMP_NO_DISPLAY))
    {
    dpmode = GRbd;
    om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
     &md_env->md_env.matrix_type, md_env->md_env.matrix, &dpmode,
     &md_env->md_id), targetid = my_id);
    }

  /*
   * Unless inhibited, add the object back into the R-tree.
   */

  if (!(cn_type & ND_COMP_NO_ADD_RT) && (md_env->md_id.objid != NULL_OBJID))
    om$send (msg = message GRgraphics.GRaddwrng (&msg_loc, md_env),
     targetid = my_id);

  if (update_error)
    *msg = ND_COMP_FAIL;
  else
    *msg = ND_COMP_SUCC;

  EMWRAPUP (*msg, stat_OM, "EMScnstrgmhn.NDupdate");
  return (stat_OM);
}

end implementation EMScnstrgmhn;

