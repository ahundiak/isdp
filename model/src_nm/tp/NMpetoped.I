class implementation NMpartedge;

#include "EMS.h"
#include "emsdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMgettopedge (IGRlong *msg; struct EMSedgebound *par; 
                     struct EMSpartolbasis *partol_basis; GRobjid *topedge)
{
  IGRboolean on_intvl, in_middle, on_left;
  IGRint stat_OM;
  IGRlong msg_loc;
  IGRint EMsend_partedges(), active_loop = 0;
  void EMpar_on_edintvl();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMpar_on_edintvl (&msg_loc, my_id, ME.EMSpartedge->boundary, NULL,
   &ME.EMSpartedge->boundary[1], NULL, par, NULL, partol_basis, 
   &on_intvl, &in_middle, &on_left);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
  EMerr_hndlr (!on_intvl, *msg, EMS_I_OutOfBounds, ret_end);

  stat_OM = EMcount_loops(&msg_loc, my_id, &active_loop, NULL, EMLP_ACTIVE, 
			 NULL, NULL);
  EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_EdgeError, ret_end);
  if (!active_loop)
    {
    /*
     * The topmost edge being requested is one of the
     * two split-children of this edge.
     */
      stat_OM = NMsend_to_partedges (&msg_loc, OPPmargs, my_id, 
                OM_Gw_current_OS, 0, MAXINT, NULL, NULL, NULL);
      EMerr_hndlr (EMSerror (msg_loc | *msg), *msg, EMS_E_EdgeError, ret_end);
      EMomerr_exit (stat_OM, ret_end);
      if(*msg == EMS_I_Found) stat_OM = OM_I_STOP_SENDING;
    }
  else
    {
    /*
     * Since this edge is not split further,
     * this edge itself is the topmost edge
     * requested. 
     */

    *topedge = my_id;
    stat_OM = OM_I_STOP_SENDING;
    *msg = EMS_I_Found;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "NMpartedge.EMgettopedge");
  return (stat_OM);
}

end implementation NMpartedge;
