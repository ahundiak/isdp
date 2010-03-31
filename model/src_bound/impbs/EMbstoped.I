/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
#include "emsdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMgettopedge (IGRlong *msg; struct EMSedgebound *par; 
                     struct EMSpartolbasis *partol_basis; GRobjid *topedge)
{
  IGRint stat_OM, active_loop = 0;
  IGRlong msg_loc;
  IGRint EMsend_partedges();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

   if (par->span_inx >= 0 && par->param >= 0.0 && par->param <= 1.0)
    {
     stat_OM = EMcount_loops(&msg_loc, my_id, &active_loop, NULL, EMLP_ACTIVE, 
			 NULL, NULL);
     EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_EdgeError, ret_end);

    if (!active_loop)
      {
        stat_OM = EMsend_partedges (&msg_loc, OPPmargs, my_id, 0, MAXINT, 
                   NULL, NULL, NULL);
        EMerr_hndlr (EMSerror (msg_loc | *msg), *msg, EMS_E_EdgeError, 
         ret_end);
        EMomerr_exit (stat_OM, ret_end);
      }
    else
      *topedge = my_id;
    }
  else
    *msg = EMS_I_OutOfBounds;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSbsedge.EMgettopedge");
  return (stat_OM);
}

end implementation EMSbsedge;
