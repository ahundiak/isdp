/* ###################   APOGEE COMPILED   ################## */
/*
  Abstract:

     The input is a polyline of parametric points (inpoly) in the uv-space of
   this surface. These points are assumed to be 2D. The range box of the
   polyline can be optionally input. This method then returns the "cutting" 
   intersection of the linestring with itself (the loopset). The intersection
   on the polyline is returned as a linked list of structures of type 
   EMSpypoint . The intersection on the loop itself (and it's children if any) 
   is returned as a linked list of type EMsfintedpar.

   If the "*myinters" pointer is not NULL, the method assumes an existing
   linked list and appends it's output at the end of this list. The same
   for the "*polyinters" pointer. But if the "myinters" (value) itself
   is NULL ("polyinters" in this case is assumed to be NULL too), no
   computation of the intersection points is done and the method will return
   soon after it finds the first intersection. If no interection is found
   num_inters returned is zero (if an intersection is found the num_inters
   returned is non-zero).
*/

class implementation EMSloopset;

#include "EMS.h"
#include "emsdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloop import EMlppytrimint;

method EMlspytrimint (IGRlong *msg; struct IGRpolyline *inpoly;
                       IGRdouble *inpoly_range; 
                       struct EMSpartolbasis *partol_basis;
                       IGRushort options;
                       IGRint *num_inters;
                       struct EMSsfintedpar **myinters;
                       struct EMSpypoint  **polyinters) 
{
  IGRint stat_OM;
  IGRlong msg_loc;
  OM_S_CHANSELECT chan_to_loops;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  chan_to_loops.type = OM_e_addr;
  chan_to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  stat_OM = om$send (msg = message EMSloop.EMlppytrimint (&msg_loc,
             inpoly, inpoly_range, partol_basis, MAXINT, options,
             num_inters, myinters, polyinters),
             p_chanselect = &chan_to_loops);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg,EMS_E_LoopError,ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMlspytrimint");
  return (stat_OM);
}
end implementation EMSloopset;
