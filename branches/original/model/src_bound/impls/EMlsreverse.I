/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloop import EMreverse;

method EMreverse (IGRlong *msg)
{
  IGRint num_loops, depth, buff_size, i;
  IGRushort *dum_props;
  IGRlong msg_loc, stat_OM;
  GRobjid *loops;
  OM_S_CHANSELECT chan_to_loops;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  dum_props = NULL;
  loops = NULL;

  chan_to_loops.type = OM_e_addr;
  chan_to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  depth = MAXINT;
  buff_size = 0;
  stat_OM = om$send (msg = message EMSloopset.EMget_loops (&msg_loc, 
             EMS_OPT_ALL, &depth, &loops, &dum_props, &buff_size, 
             &num_loops), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);

  for (i=0; i<num_loops; i++)
    {
    stat_OM = om$send (msg = message EMSloop.EMreverse (&msg_loc),
               targetid = loops[i]);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
    }

ret_end:
  if (dum_props)
    om$dealloc (ptr = dum_props);
  if (loops)
    om$dealloc (ptr = loops);
  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMreverse");
  return (stat_OM); 
}

end implementation EMSloopset;
