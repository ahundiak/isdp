/* ###################   APOGEE COMPILED   ################## */
/*
Description

   This method is the degenerate case of the tree-traverse method
   implemented at EMSloopset and EMSloop. It simply applies the 
   message (which it is carrying) to itself (the edge). 

   The purpose of this implementation is to allow the sender to
   send the message to any topology object (including edges).


Files

   See the documentation in EMlptreetrav.I for description on the arguments

History

    RV		02/24/88	Creation
    SS		11/21/88	Added the option to traverse up the tree.

*/

class implementation EMSedge;

#include "EMS.h"
#include "EMSopt.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMtree_traverse (IGRlong *rc; OM_p_MESSAGE messg; IGRint tree_depth;
                        IGRint num_classes; GRclassid *classids;
                        IGRushort options;
		        IGRushort all_mask, any_mask, none_mask)
{
  IGRboolean consider_node, apply_to_self;
  IGRushort props;
  IGRlong i, send_rc, stat_OM;
  extern IGRlong EMsend_loops();

  *rc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (tree_depth <= 0, *rc, EMS_E_InvalidArg, ret_end);

  /*
   * Check to see if this node in the loop-tree satisfies the conditions
   * specified by the property masks. Only if it does, should the possibility
   * of a send to itself be considered.
   */

  props = ME.EMSedge->ed_props;
  if (all_mask || any_mask || none_mask)
    {
    if ((all_mask && ((props & all_mask) != all_mask)) ||
        (any_mask && ! (props & any_mask)) ||
        (none_mask && (props & none_mask)))
      consider_node = FALSE;
    else
      consider_node = TRUE;
    }
  else
    consider_node = TRUE;

  if (consider_node)
    {
    /*
     * If the list of classids passed in indicates that the
     * message is to be sent to my_self, so be it.
     */

    apply_to_self = FALSE;
    for (i=0; i<num_classes; i++)
      if (classids[i] == OPP_EMSedge_class_id || 
          om$is_ancestry_valid (subclassid = classids[i],
           superclassid = OPP_EMSedge_class_id) == OM_S_SUCCESS)
        {
        apply_to_self = TRUE;
        break;
        }
    if (apply_to_self)
      {
      stat_OM = om$send (msg = messg, targetid = my_id);
      stat_OM = (stat_OM == OM_W_UNKNOWN_MSG ? OM_S_SUCCESS : stat_OM);
      EMomerr_exit (stat_OM, ret_end);
      }
    }

  /*
   * If the options indicate that an upward traversal is needed and if
   * the tree-depth is sufficient, send the message out to the owner
   * loop.
   */

  tree_depth--;
  if (tree_depth && options & EMStreetrav_up)
    {
    stat_OM = EMsend_loops (&send_rc, message EMSboundary.EMtree_traverse (rc,
               messg, tree_depth, num_classes, classids, options, all_mask,
               any_mask, none_mask), my_id, 0, 0, EMLP_ACTIVE, NULL, NULL);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (*rc & send_rc), *rc, EMS_E_LoopError, ret_end);
    }
 
ret_end:
  EMWRAPUP (*rc, stat_OM, "EMSedge.EMtree_traverse");
  return (stat_OM);
}

end implementation EMSedge;
