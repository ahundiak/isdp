/*
  DESCRIPTION

    This method swaps in a new, given variable-object in place of this
    one. Optionally (SK_UPDATE_DELETEOLD), it will delete this object
    after the swap-in.

    The new, variable coming in is assumed to be connected to this
    sketch's manager. It's constraints are maintained and that of this
    object's. This object is then freed from all constraints.
   
    This object's connections to geometry are transferred onto the
    new object. The new object's connections to any geometry are also
    maintained. This object is then freed from all geometry.

    The instance data of the new-object comes into being.
*/

class implementation SKvariable;

#include "OMmacros.h"
#include "EMSopt.h"
#include <alloca.h>

#define TO_CNSTR 0
#define TO_GEOM  1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method SKswap (IGRlong *msg; IGRushort opts; GRobjid new_var)
{
  IGRint inx1, *inx2, chantype;
  OMuint count;
  IGRlong stat_OM, msg_loc;
  GRobjid this_mgr, new_mgr;
  OM_S_CHANSELECT chan1, chan2;
  OM_p_OBJECT_LINKAGE objlist;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain this variable sketch-manager
   */

  stat_OM = om$send (msg = message SKvariable.SKgetmgr (&msg_loc, &this_mgr),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  new_mgr = NULL_OBJID;
  stat_OM = om$send (msg = message SKvariable.SKgetmgr (&msg_loc, &new_mgr),
             targetid = new_var);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  EMerr_hndlr (this_mgr != new_mgr, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Transfer all connections from my (to_constraints and to_geometries)
   * channel, onto the new objects corresponding channel. Append it to
   * any existing connections.
   */

  for (chantype=TO_CNSTR; chantype<=TO_GEOM; chantype++)
    {
    if (chantype == TO_CNSTR)
      {
      EMmake_chanselect (SKvariable_to_constraints, &chan1);
      EMmake_chanselect (SKconstraint_to_variables, &chan2);
      }
    else
      {
      EMmake_chanselect (SKvariable_to_geometries, &chan1);
      EMmake_chanselect (SKgeometry_to_defpts, &chan2);
      }
 
    stat_OM = om$get_channel_count (object = me, p_chanselect = &chan1, 
     count = &count);
    EMomerr_exit (stat_OM, ret_end);

    if (!count)
      continue;

    objlist = (OM_p_OBJECT_LINKAGE) alloca (count *
               sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!objlist, *msg, EMS_E_NoStackMemory, ret_end);

    inx2 = (IGRint *) alloca (count * sizeof (IGRint));
    EMerr_hndlr (!inx2, *msg, EMS_E_NoStackMemory, ret_end);

    stat_OM = om$get_channel_objects (object = me, p_chanselect = &chan1,
               count = &count, size = count, list = objlist);
    EMomerr_exit (stat_OM, ret_end);

    for (inx1=0; inx1<count; inx1++)
    {
      OMuint tmp_index;

      stat_OM = om$get_index (objid_c = objlist[inx1].S_objid,
                 p_chanselect = &chan2, objid = my_id,
                 indexaddr = &tmp_index );
      inx2 [inx1] = tmp_index;
      EMomerr_exit (stat_OM, ret_end);
    }

    stat_OM = om$send (msg = message Root.wild_disconnect (chan1),
               targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);

    for (inx1=0; inx1<count; inx1++)
      {
      stat_OM = om$send (msg = message Root.connect (chan1, inx2[inx1],
                 objlist[inx1].S_objid, OM_Gw_current_OS, chan2, 0),
                 targetid = new_var);
      EMomerr_exit (stat_OM, ret_end);
      }
    }

  /*
   * Give all my  properties to the new object
   */

  stat_OM = om$send (msg = message SKvariable.SKchgprops (&msg_loc, EMS_O_SET,
             ME.SKvariable->props), targetid = new_var);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  /*
   * Delete myself, if that option is set.
   */

  if (opts & SK_UPDATE_DELETEOLD)
    {
    stat_OM = om$send (msg = message Root.delete (TRUE), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKvariable.SKswap");
  return (stat_OM);
}

end implementation SKvariable;
