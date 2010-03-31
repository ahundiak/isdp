/*
  DESCRIPTION

    This method checks the validity of this constraint in that it determines
    if the constraint is over-constraining the children or not. If it is
    then the id's of the constraints that are conflicting with this constraint
    are returned.

  HISTORY

    SS  :  06/24/91  :  Creation
*/

class implementation EMScnstr;

#include "OMmacros.h"
#include "bserr.h"

#define X 0
#define Y 1
#define Z 2

#define PARENT_PT  0
#define CHILD_PT   1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSparamgm import EMsolve;

method EMvalidate (IGRlong *msg; IGRushort opts;
                   struct GRmd_env *md_env;
                   IGRboolean *is_valid_cnstr;
                   IGRint *num_conflict_cnstr; struct GRid conflict_cnstr[3])
{
  OMuint count;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  OM_S_CHANSELECT chan_to_children;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *is_valid_cnstr = TRUE;

  EMmake_chanselect (NDchildren_children, &chan_to_children);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_children,
   count = &count);

  for (i=0; i<count; i++)
    {
    msg_loc = EMS_S_Success;
    om$send (msg = message EMSparamgm.EMsolve (&msg_loc, opts,
     0, NULL, md_env, NULL, num_conflict_cnstr, conflict_cnstr, NULL, NULL),
     p_chanselect = &chan_to_children, from = i, to = i);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (msg_loc == EMS_I_Redundant ||
        msg_loc == EMS_I_NoSolution ||
        msg_loc == EMS_I_Cycle)
      {
      *msg = msg_loc;
      *is_valid_cnstr = FALSE;
      goto ret_end;
      }
    }
  
ret_end:
  EMWRAPUP (*msg, stat_OM, "EMcsvalidate.I");
  return (stat_OM);
}

end implementation EMScnstr;

