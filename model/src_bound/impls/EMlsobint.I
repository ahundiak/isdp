/* ###################   APOGEE COMPILED   ################## */
/*
  Abstract:

     The input is an object-id of a loopset or any of it's components
   (loop, edge, etc.). This method returns either the "cutting" intersection
   or the "normal" intersection of the input object with itself (the loopset) -
   the flag cut_intersect differentiates the two. The intersection(s) on the
   input object is returned as a linked list of structures of type
   EMintparms (other_int) and a similar linked-list is returned for the 
   intersection(s) on me (my_int). 

   If the "my_int" pointer (or the "other_int" pointer) is not NULL, the
   method assumes an existing linked list and appends it's output to the
   end of this list.
*/

class implementation EMSloopset;

#include "EMS.h"
#include "emserr.h"
#include "emssfint.h"
#include "msdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMobint (IGRlong *msg; struct EMSpartolbasis *mytol_basis;
                GRobjid other_obj; struct EMSpartolbasis *othertol_basis;
                IGRushort options;
                IGRint *num_int; struct EMSsfintedpar **my_int, **other_int)
{
  IGRint stat_OM;
  OM_S_CHANSELECT chan_to_loops;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  chan_to_loops.type = OM_e_addr;
  chan_to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_loops);
  EMomerr_exit (stat_OM, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMobjint");
  return (stat_OM);
}

end implementation EMSloopset;
