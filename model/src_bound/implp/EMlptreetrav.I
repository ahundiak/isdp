/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method is used to traverse the loop-tree in a controlled fashion.
    The message carried on the argument-list is applied to the relevant
    objects at the nodes of this tree. The traversal continues down (or up)
    through to the children (or parents) of this loop upto the depth specified
    or to the maximum depth of the tree, whichever is smaller. At each node
    that is so visited a check is made as to whether this node satisfies the,
    combination of properties specified. If the node passes this test the
    specified message is applied to all those objects of this node (including
    itself) that belong to or are subclasses of one of the classes listed. 

    The objects of a node in the loop-tree are - i) itself, ii) the edges
    and iii) the association objects.

    The attempt to send the specified message takes place first on this node
    itself, then on the edges and lastly on the associations.

  ARGUMENTS

    messg		- Input: The message that is to be applied to the
           		  relevant objects visted.
    tree_depth		- Input: The minimum depth in the loop-tree to which
			  this intersection must be carried out. A depth
			  of atleast one should be set (for the visitation of
			  this loop).
    num_classes		- Input: The number of classids specified in the
			  'classids' array.
    classids		- Input: Array containing the classids of the objects
			  at each node visited, which should receive 'messg'.
			  Super-classids may be specified to include a
			  whole gang of types.
    options		- Input: Options indicating the traversal proceeds
			  'down' and/or 'up' the tree.
    all_mask		- Input: Properties mask specifying this node's
     			  properties (specifiable by a bit turned ON) ALL of
			  which MUST be satisfied. If NULL, then ignored.
    any_mask		- Input: Properties mask specifying this node's
     			  properties (specifiable by a bit turned ON) ANY of
			  which MUST be satisfied. If NULL, then ignored.
    none_mask		- Input: Properties mask specifying this node's
     			  properties (specifiable by a bit turned ON) NONE of
			  which MUST be true. If NULL, then ignored.
  
  RETURN VALUE

    The return code will be one of the following:

    Success
    - EMS_S_Success
      All went well

    Error condition
    - EMS_E_InvalidArg
      The tree depth was less than or equal to zero
    - EMS_E_LoopError
      Error encountered in a send to a loop
    - EMS_E_EdgeError
      Error encountered in a send to an edge.

  BUGS

    The classids that can be specified can only be taken from the following
    set - OPP_EMSloop_class_id, OPP_EMSedge_class_id, OPP_EMSgradata_class_id
    or OPP_EMSdpr_class_id. The "down" flag is ignored and the send takes
    place only downward.

  HISTORY

    SS  :  05/01/87  :  Creation
    SS  :  05/25/87  :  Added the tree_depth, classids and the 'down' 
                        arguments.
    SS  :  05/30/87  :  Added the send to objects on the association channel.
                        Also added the property-masks to the argument list.
    SS  :  11/21/88  :  Added the option to traverse up the tree.
   Jack :  07/31/91  :  Added a fix to handle EMShelper objects.
*/
     
class implementation EMSloop;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSloop_class_id, OPP_GRlistener_class_id;
extern GRclassid OPP_EMSedge_class_id, OPP_EMShelper_class_id,
                 OPP_EMSsubbs_class_id;
extern GRclassid OPP_EMSgradata_class_id, OPP_EMSdpr_class_id;

method EMtree_traverse (IGRlong *rc; OM_p_MESSAGE messg; IGRint tree_depth;
                        IGRint num_classes; GRclassid *classids;
                        IGRushort options;
		        IGRushort all_mask, any_mask, none_mask)
{
  IGRboolean consider_node, apply_to_self, apply_to_edges;
  IGRboolean apply_to_assocs, apply_to_gradata, apply_to_surf;
  IGRushort props;
  IGRint i;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_edges, chan_to_gradata, chan_to_assocs;
  OM_S_CHANSELECT chan_traverse, chan_to_surf;

  *rc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (tree_depth <= 0, *rc, EMS_E_InvalidArg, ret_end);

  /*
   * Check to see if this node in the loop-tree satisfies the conditions
   * specified by the property masks. Only if it does, should the possibility
   * of sends to it's objects (or itself) be considered.
   */

  props = ME.EMSloop->lp_props;
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
      if (classids[i] == OPP_EMSloop_class_id || 
          om$is_ancestry_valid (subclassid = classids[i],
           superclassid = OPP_EMSloop_class_id) == OM_S_SUCCESS)
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

    /*
     * If the list of classids indicates that the message needs to be
     * applied to edges (or certain class of edges), so be it.
     */
 
    apply_to_edges = FALSE;
    for (i=0; i<num_classes; i++)
      if (classids[i] == OPP_EMSedge_class_id ||
          om$is_ancestry_valid (subclassid = classids[i],
           superclassid = OPP_EMSedge_class_id) == OM_S_SUCCESS)
        {
        apply_to_edges = TRUE;
        break;
        }

    if (apply_to_edges)
      {
      stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);
      EMomerr_exit (stat_OM, ret_end);
  
      stat_OM = om$send (msg = messg, p_chanselect = &chan_to_edges);
      stat_OM = (stat_OM == OM_W_UNKNOWN_MSG ? OM_S_SUCCESS : stat_OM);
      EMomerr_exit (stat_OM, ret_end);
      }

    /*
     * If the list of classids indicates that the message needs to be
     * applied to graphic data  (or certain class of graphic data), 
     * so be it. --RC
     */
 
    apply_to_gradata = FALSE;
    for (i=0; i<num_classes; i++)
      if (classids[i] == OPP_EMSgradata_class_id ||
          om$is_ancestry_valid (subclassid = classids[i],
           superclassid = OPP_EMSgradata_class_id) == OM_S_SUCCESS)
        {
        apply_to_gradata = TRUE;
        break;
        }

    if (apply_to_gradata)
      {
      stat_OM = EMmake_chanselect (EMSrequester_to_helpers, &chan_to_gradata);
      EMomerr_exit (stat_OM, ret_end);
  
      stat_OM = om$send (msg = messg, p_chanselect = &chan_to_gradata);
      stat_OM = (stat_OM == OM_W_UNKNOWN_MSG ? OM_S_SUCCESS : stat_OM);
      EMomerr_exit (stat_OM, ret_end);
      }
    
    /*
     * If the list of classids indicates that the message needs to be
     * applied to objects on the associations channel (or certain class of
     * of such objects), so be it.
     */
  
    apply_to_assocs = FALSE;
    for (i=0; i<num_classes; i++)
      if (om$is_ancestry_valid (subclassid = classids[i],
           superclassid = OPP_GRlistener_class_id) == OM_S_SUCCESS )
        {
        apply_to_assocs = TRUE;
        break;
        }

    if (apply_to_assocs)
      {
      stat_OM = EMmake_chanselect (GRnotify_notification, &chan_to_assocs);
      EMomerr_exit (stat_OM, ret_end);
  
      stat_OM = om$send (msg = messg, p_chanselect = &chan_to_assocs);
      stat_OM = (stat_OM == OM_W_UNKNOWN_MSG ? OM_S_SUCCESS : stat_OM);
      EMomerr_exit (stat_OM, ret_end);
      }
    }

  /*
   * In the transition phase of adding the option to traverse up the
   * tree, the previous disregard to this argument has to be supported.
   * For now, if the the traversal is indicated as "upward" then no
   * traversal "downward" is even attempted. If no "upward" traverse is
   * indicated, it is automatically construed as a downward traversal.
   */

  tree_depth--;
  if (tree_depth)
   {
    OMuword my_classid;  
      
    om$get_classid(objid = my_id,
                   p_classid = &my_classid);
    if (om$is_ancestry_valid (subclassid = my_classid,
        superclassid = OPP_EMShelper_class_id) == OM_S_SUCCESS)
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
        stat_OM = EMmake_chanselect (EMShelper_to_requesters, &chan_to_surf);
        EMomerr_exit (stat_OM, ret_end);

        stat_OM = om$send (msg = messg, p_chanselect = &chan_to_surf);
        stat_OM = (stat_OM == OM_W_UNKNOWN_MSG ? OM_S_SUCCESS : stat_OM);
        EMomerr_exit (stat_OM, ret_end);
        }
      }
    else
    {
     if (options & EMStreetrav_up)
       stat_OM = EMmake_chanselect (EMSloop_to_outter, &chan_traverse);
     else
       stat_OM = EMmake_chanselect (EMSloop_to_inner, &chan_traverse);
     EMomerr_exit (stat_OM, ret_end);

     stat_OM = om$send (msg = message EMSboundary.EMtree_traverse (rc,
                messg, tree_depth, num_classes, classids, options, all_mask,
                any_mask, none_mask), p_chanselect = &chan_traverse);
     EMomerr_exit (stat_OM, ret_end);
     EMerr_hndlr (EMSerror (*rc), *rc, EMS_E_LoopError, ret_end);
    }

   }


 
ret_end:
  EMWRAPUP (*rc, stat_OM, "EMSloop.EMtree_traverse");
  return (stat_OM);
}

end implementation EMSloop;
