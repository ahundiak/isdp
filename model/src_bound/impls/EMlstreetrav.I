/* ###################   APOGEE COMPILED   ################## */
/*
Description

   This method performs in a similar manner as the EMtree_traverse method
   overriden at EMSloop.It checks to see if EMSloopset is one the eligible
   class ids and if the masks supplied match with the loopset properties
   then the message that is passed in through messg field is applied to the
   loopset. If not EMtree_traverse message is passed on to the loop tree.

   To make sure this message reaches the topmost loop under the loopset, tree
   depth should be set to 2.

Files
   See the documentation in EMlptreetrav.I for description on the arguments

History
   PP : 12/14/87       Creation
   SS : 11/21/88       Added the option to go upwards towards surface.
   SM : 13-Oct-89      send to self only if(apply_to_self).
*/

class implementation EMSloopset;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSsubbs_class_id;

method EMtree_traverse (IGRlong *rc; OM_p_MESSAGE messg; IGRint tree_depth;
                        IGRint num_classes; GRclassid *classids;
                        IGRushort options;
	                IGRushort all_mask, any_mask, none_mask)
{
  IGRboolean consider_node, apply_to_self, apply_to_surf;
  IGRushort props;
  IGRlong i, stat_OM;
  OM_S_CHANSELECT chan_to_loops, chan_to_surf;

  *rc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (tree_depth <= 0, *rc, EMS_E_InvalidArg, ret_end);

  /*
   * Check to see if this node in the loop-tree satisfies the conditions
   * specified by the property masks. Only if it does, should the possibility
   * of sends to it's objects (or itself) be considered.
   */

  props = ME.EMSloopset->ls_props;
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
      if (classids[i] == OPP_EMSloopset_class_id || 
          om$is_ancestry_valid (subclassid = classids[i],
           superclassid = OPP_EMSloopset_class_id) == OM_S_SUCCESS)
        {
        apply_to_self = TRUE;
        break;
        }
    if(apply_to_self)
     {
      stat_OM = om$send (msg = messg, targetid = my_id);
      stat_OM = (stat_OM == OM_W_UNKNOWN_MSG ? OM_S_SUCCESS : stat_OM);
      EMomerr_exit (stat_OM, ret_end);
     }
   }

  tree_depth--;
  if (tree_depth)
    {
    if (options & EMStreetrav_up)
      {
      apply_to_surf = FALSE;
      for (i=0; i<num_classes; i++)
        if (om$is_ancestry_valid (subclassid = classids[i],
             superclassid = OPP_EMSsubbs_class_id) == OM_S_SUCCESS)
          {
          apply_to_surf = TRUE;
          break;
          }
      if (apply_to_surf)
        {
        stat_OM = EMmake_chanselect (EMSloopset_to_surface, &chan_to_surf);
        EMomerr_exit (stat_OM, ret_end);

        stat_OM = om$send (msg = messg, p_chanselect = &chan_to_surf);
        stat_OM = (stat_OM == OM_W_UNKNOWN_MSG ? OM_S_SUCCESS : stat_OM);
        EMomerr_exit (stat_OM, ret_end);
        }
      }
    else
      {
      stat_OM = EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
      EMomerr_exit (stat_OM, ret_end);

      stat_OM = om$send (msg = message EMSboundary.EMtree_traverse (rc,
                 messg, tree_depth, num_classes, classids, options, all_mask,
                 any_mask, none_mask), p_chanselect = &chan_to_loops);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (*rc), *rc, EMS_E_LoopError, ret_end);
      }
    }
 
ret_end:
  EMWRAPUP (*rc, stat_OM, "EMSloopset.EMtree_traverse");
  return (stat_OM);
}

end implementation EMSloopset;
