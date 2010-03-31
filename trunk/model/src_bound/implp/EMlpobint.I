/* ###################   APOGEE COMPILED   ################## */
/*
  Abstract:

     The input is an object-id of a loopset or any of it's components
   (loop, edge, etc.). This method returns the "cutting" intersection 
   or the "normal" intersection of the input object with itself (the loop) -
   the flag cut_intersect differentiates the two. The intersection(s) on 
   the input object with itself (the loop) and all inner loops, if any. 
   The intersection(s) on the input object is returned as a linked list
   of structures of type EMintparms (other_int) and a similar linked-list 
   is returned for the intersection(s) on me (my_int). 

   If the "my_int" pointer (or the "other_int" pointer) is not NULL, the
   method assumes an existing linked list and appends it's output to the
   end of this list.
*/

class implementation EMSloop;

#include "EMS.h"
#include "emserr.h"
#include "msdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMobint (IGRlong *msg; struct EMSpartolbasis *mytol_basis;
                GRobjid other_obj; struct EMSpartolbasis *othertol_basis;
                IGRushort options;
                IGRint *num_int; struct EMSsfintedpar **my_int, **other_int)
{
  IGRint stat_OM, count;
  OM_S_CHANSELECT chan_to_edges, chan_to_inner;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Passon the message to my edges.
   */

  chan_to_edges.type = OM_e_addr;
  chan_to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_edges);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * Passon the message to my inner loops, if any,
   * so that the intersection can be performed with
   * respect to them too.
   */

  if (stat_OM != OM_I_STOP_SENDING)
    {
    chan_to_inner.type = OM_e_addr;
    chan_to_inner.u_sel.addr = &me^^EMSloop.to_inner;

    stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_inner);
    EMomerr_exit (stat_OM, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMobint");
  return (stat_OM);
}

end implementation EMSloop;
