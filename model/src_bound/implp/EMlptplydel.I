/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This loop is to be unconditionally removed from the loop-tree (and
    perhaps deleted). Also, any other boundary that might be bounding this area
    must be removed/deleted.
        
  ARGUMENTS

    numsfs              - The number of surfaces that were affected by
                          this cleanup. Relevant only if 'sfloops' is
                          non-NULL by value.
    sfloops             - The linked list that contains information on
                          the loops that were removed/deleted from each of the
                          surfaces. If NULL (by value) then ignored.
    numowners           - The number of surface-owners that had surfaces
                          removed/deleted from them. Relevant only if
                          'owncomps' is is non-NULL by value.
    owncomps            - The linked list containing information on the
                          surfaces removed from each of the owners.
                          If NULL (by value) then ignored.
    delete              - If TRUE, the cleaned up components are deleted,
                          else they are removed from their owners.


  NOTES

    This method alters the following property bits on the loops that are
    removed:
      EMLP_ACTIVE is turned off
      EMLP_SPLIT  is turned off if it was on.

    Though surfaces may be removed (those left with zero loops), none
    of their property bits are changed. This is left as the responsibilty
    of the caller. Atleast the following bits should be turned off:
      GRIS_LOCATABLE and
      GRIS_DISPLAYABLE 

  ASSUMPTION

    This method assumes that an edge can possibly be connected to only
    one active-loop (which could be new). 

  ALGORITHM

    This loop is removed using the EMtreemod method. If this removal/deletion
    causes this surfaces to have no more loops the surface is itself
    removed/deleted from it's parent. The topologically adjacent loops
    (if they exist) are sent this message.

    If this is a P-loop ("outer" boundary of an area), then any C-loop
    children should be deleted. If this is a C-loop ("inner" boundary of an
    area), then any P-loop parent should be deleted. 
    
    If this loop is a "split" loop, then topologically speaking, it
    is no longer a boundary of an area and the above criteria does not
    apply. Some deliberation will show that a split loop that is a P-loop
    should have it's C-loop children removed/deleted. This is further
    explained in the in-line comments.
    
    In either case, the method exits after removing/deleting this loop and
    passing the message on to loops bounding appropriate, adjacent areas.
    These areas are recognized across the common-edge connections.

  HISTORY

    SS  :  03/01/87  :  Creation
    SM  :  30-Oct-89 :  Support EMtplydel_MaintainSplit option.
			see include/emstplydel.h
*/

class implementation EMSloop;

#include "EMS.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "emstplydel.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define INIT_OBJLIST_SIZE 3

extern GRclassid OPP_EMScomposite_class_id, OPP_EMSdpr_class_id;

from GRconnector import GRdisconn;

method EMtplydelete (IGRlong *msg; IGRint *numsfs; 
                     struct EMSownercomp **sfloops; IGRint *numowners;
                     struct EMSownercomp **ownercomps; 
                     IGRushort options)
{
  IGRboolean list_extended, deletable_area, delete;
  IGRboolean this_loop_p, delloop_p, delloop_active;
  IGRint stat_OM, i, newlp_count;
  OMuint count, delloops_count, commed_count;
  IGRushort all_mask, any_mask, none_mask, props;
  IGRlong msg_loc, store_msg, send_msg;
  GRobjid sfid, edid, compid, commedid;
  GRspacenum dumosnum;
  GRclassid compclassid;
  struct EMSnest_info nestinfo;
  struct GRmd_env mdenv;
  OM_S_OBJECT_LINKAGE commed_objlist, *delloops_objlist;
  OM_S_OBJECT_LINKAGE objlist_mem[INIT_OBJLIST_SIZE];
  OM_S_CHANSELECT chan_to_edges, chan_to_commedge;
  OM_S_CHANSELECT chan_to_inner, chan_to_outer;
  OM_S_CHANSELECT chan_to_cpx, chan_to_comps, delete_channel;
  void EMmkownlist(); 
  IGRint EMcount_loops(), EMsend_loops();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  delloops_objlist = NULL;

  delete = options & EMtplydel_DeleteElems ? TRUE : FALSE;

  EMerr_hndlr (ME.EMSloop->lp_props & EMLP_NEW, *msg, EMS_I_Fail, ret_end);

  /*
   * At this stage in the method, only the list of loop-ids of loops
   * connected to this loop and which are to be sent the
   * topological-delete message are obtained. The actual
   * removal/deletion takes place AFTER this loop is removed/deleted.
   * This step is necessary at this stage, since the loop-tree connections
   * are destroyed once this loop is removed/deleted. Following is the
   * logic governing the decision to remove/delete some of the other loops
   * in this loop-tree, towards accomplishing a topology delete:
   *
   * Consider the two kinds of loops - i) Non-split loops and ii) Split
   * loops:
   *
   *   i) Non-split loops are the boundaries of regions. The fact that
   *      this boundary is being deleted implies that this region (that is
   *      bounded by this loop) is itself deletable. Hence the other boundaries
   *      of this region are to be removed/deleted too. In other words, if this
   *      is a P-loop, it's C-loop children are to be deleted and if it's a
   *      C-loop it's P-loop parents are to be deleted.
   *  ii) Split loops do not bound any region. Parts of them have been
   *      used up in creating new loops. If this is a split-loop, 
   *      topologically speaking, this loop is the remains of a loop that
   *      got used up in such a manner. Nesting relative to a split loop
   *      cannot be accurate and should be seen only as a temporary
   *      situation. The effect of the removal/deletion of such a loop is
   *      merely to cause the nesting of it's children under it's parent:
   *        a) A split P-loop means that a smaller, new P-loop has resulted
   *           from this split. Ignoring this split P-loop in the nesting,
   *           some of this loop's erstwhile children, which didn't get nested
   *           under the new P-loop, are now exposed to the parent C-loop
   *           or become external. Thus, all the child C-loops must be
   *           removed/deleted.
   *        b) On the other hand, a split C-loop means a larger, new C-loop has
   *           resulted from this split. Ignoring this split C-loop in
   *           the nesting, all of this loop's erstwhile children are
   *           nested under the new C-loop. Thus, no further action need be
   *           taken.
   */

  if (ME.EMSloop->lp_props & EMLP_PLOOP)
    {
    chan_to_inner.type = OM_e_addr;
    chan_to_inner.u_sel.addr = &ME.EMSloop->to_inner;

    stat_OM = om$get_channel_count (objid = my_id, 
               p_chanselect = &chan_to_inner, count = &count);
    EMomerr_exit (stat_OM, ret_end);

    delete_channel = chan_to_inner;
    }  
  else if (! (ME.EMSloop->lp_props & EMLP_SPLIT))
    {
    if (! (ME.EMSloop->lp_props & EMLP_EXTERNAL))
      {
      chan_to_outer.type = OM_e_addr;
      chan_to_outer.u_sel.addr = &ME.EMSloop->to_outter;

      stat_OM = om$get_channel_count (objid = my_id, 
                 p_chanselect = &chan_to_outer, count = &count);
      EMomerr_exit (stat_OM, ret_end);
  
      delete_channel = chan_to_outer;
      }
    else
      count = 0;
    }
  else
    count = 0;

  if (count)
    {
    if (count > INIT_OBJLIST_SIZE)
      {
      delloops_objlist = (OM_p_OBJECT_LINKAGE) om$malloc (size = 
                           count * sizeof (OM_S_OBJECT_LINKAGE));
      EMerr_hndlr (!delloops_objlist, *msg, EMS_E_NoDynamicMemory,
       ret_end);
      }
    else
      {
      count = INIT_OBJLIST_SIZE;
      delloops_objlist = objlist_mem;
      }

    stat_OM = om$get_channel_objects (objid = my_id, p_chanselect = 
               &delete_channel, list = delloops_objlist, size = count,
               count = &delloops_count);
    EMomerr_exit (stat_OM, ret_end);
    }
  else
    delloops_count = 0;

  /*
   * Remove myself from the loop-tree and append my objid onto
   * the argument list if so indicated by a non-NULL argument. Also set
   * my active-bit off.
   */
   
  stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
             &sfid, NULL), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

  stat_OM = om$send (msg = message EMSloop.EMtreemod (&store_msg, 
             &nestinfo, EXTRACT, NULL), 
             targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

  if (sfloops)
    {
    EMmkownlist (&msg_loc, sfloops, sfid, NULL, my_id, FALSE,
     &list_extended); 
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_DynamicMemoryAllocated,
     ret_end);

    if (list_extended && numsfs)
      (*numsfs)++;
    }    
 
  ME.EMSloop->lp_props &= ~EMLP_ACTIVE;

  if (store_msg == EMS_I_NoMoreLoops && !IF_NULL_OBJID (sfid))
    {
    /*
     * The removal of this loop caused the surface to
     * be left without any loops. Therefore, this surface
     * itself needs to be deleted/extracted from the composite-
     * surface owner (if any).
     */

    stat_OM = EMmake_chanselect (GRconnector_to_owners, &chan_to_cpx);    
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$get_channel_count (objid = sfid, 
               p_chanselect = &chan_to_cpx, count = &count);
    EMomerr_exit (stat_OM, ret_end);

    for (i=0; i<count; i++)
      {
      stat_OM = om$get_objid_at_index (objid = sfid, 
                 p_chanselect = &chan_to_cpx, index = i, objidaddr = &compid,
                 osnumaddr = &dumosnum);
      EMomerr_exit (stat_OM, ret_end);

      stat_OM = om$get_classid (objid = compid, p_classid = &compclassid);
      EMomerr_exit (stat_OM, ret_end);

      /*
       * Determine what kind of object owns this surface and get
       * this owners channel that connects to the surface.
       * This is a temporary kluge and should go away, when even the
       * EMSdpr class becomes a subclass of EMScomposite.
       */

      stat_OM = om$is_ancestry_valid (subclassid = compclassid,
                 superclassid = OPP_EMScomposite_class_id); 
      if (stat_OM == OM_S_SUCCESS)
        {
        stat_OM = EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);    
        EMomerr_exit (stat_OM, ret_end);
        }
      else if (stat_OM == OM_I_INVANCESTRY)
        {
        stat_OM = om$is_ancestry_valid (subclassid = compclassid,
                   superclassid = OPP_EMSdpr_class_id); 
        if (stat_OM == OM_S_SUCCESS)
          {
          stat_OM = EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);    
          EMomerr_exit (stat_OM, ret_end);
          }
        }
      else
        EMomerr_exit (stat_OM, ret_end);

      /*
       * Disconect or delete this surface from it's owner if a valid
       * owner was found.
       */

      if (stat_OM != OM_I_INVANCESTRY)
        {

        OMuint ownerindex;  /*DECL BY DLB*/

        if (! delete)
          {
            struct GRid owner_id;
        
          stat_OM = om$get_index(objid_c = compid,
                                 p_chanselect = &chan_to_comps,
                                 objid = sfid,
                                 indexaddr = &ownerindex);
          EMomerr_exit (stat_OM, ret_end);

/******************
          stat_OM = om$send (msg = message Root.disconnect (chan_to_comps, 
                     sfid, OM_Gw_current_OS, chan_to_cpx), targetid = compid,
                     senderid = sfid);
*****************/
          owner_id.objid = compid, 
          owner_id.osnum = OM_Gw_current_OS;

          stat_OM = om$send (msg = message GRconnector.GRdisconn
                    (&msg_loc, &owner_id), 
                     targetid = sfid, senderid = compid);
          EMomerr_exit (stat_OM, ret_end);
          }
        else
          {
          mdenv.md_id.osnum = OM_Gw_current_OS;
          stat_OM = ex$get_modid (mod_osnum = OM_Gw_current_OS,
                     mod_id = &mdenv.md_id.objid);
          EMomerr_exit (stat_OM, ret_end);
                    
          EMidmatrix (&msg_loc, &mdenv.md_env.matrix_type, 
           mdenv.md_env.matrix);

          stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc,
                     &mdenv), targetid = sfid);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
          }

        if (ownercomps)
          {
          EMmkownlist (&msg_loc, ownercomps, compid, ownerindex, sfid, 
           FALSE, &list_extended);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

          if (list_extended && numowners)
            (*numowners)++;
          }

        break;        
        }
      else
        EMomerr_exit (stat_OM, ret_end);
      }
    }
  
  /*
   * Since the region this loop represents is to be deleted, it
   * also follows that all the adjacent regions must also be
   * deleted. Send the topology-delete message to neighboring loops
   * (determined by looking across to common edges). This message
   * needs to be sent only if they have not already been
   * deleted/deactivated. 
   *   In the case when this loop is a "split" loop, some pieces of 
   * the loop might not be deletable. In general, the propogation of
   * this method needs to take place only across those edges that are
   * not owned by newly formed loops.
   *   This propagation is supressed if the option EMtply_NoCommonEdge
   * is specified by the caller.
   */

  if(!(options & EMtplydel_NoCommonEdge))
   {
    chan_to_edges.type = OM_e_addr;
    chan_to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

    stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_commedge);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$get_channel_count (objid = my_id, 
				    p_chanselect = &chan_to_edges,
             			    count = &count);
    EMomerr_exit (stat_OM, ret_end);

    for (i=0; i<count; i++)
     {
      stat_OM = om$get_objid_at_index (objid = my_id, 
               p_chanselect = &chan_to_edges, index = i, objidaddr = &edid,
               osnumaddr = &dumosnum);
      EMomerr_exit (stat_OM, ret_end);

      if (ME.EMSloop->lp_props & EMLP_SPLIT)
      {
        stat_OM = EMcount_loops (&msg_loc, edid, &newlp_count, NULL,
                 all_mask = EMLP_NEW, any_mask = NULL, none_mask = NULL);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
        deletable_area = newlp_count ? FALSE : TRUE;
      }
      else
        deletable_area = TRUE;

      if (deletable_area)
       {
         stat_OM = om$get_channel_objects (objid = edid, 
                 p_chanselect = &chan_to_commedge, list = &commed_objlist, 
                 size = 1, count = &commed_count);
         EMomerr_exit (stat_OM, ret_end);
         if (commed_count)
          {
            commedid = commed_objlist.S_objid;
  
            stat_OM = EMsend_loops (&send_msg, message EMSloop.EMtplydelete
                   (&msg_loc, numsfs, sfloops, numowners, ownercomps, options),
                   commedid, 0, 0, all_mask = EMLP_ACTIVE, any_mask = NULL,
                   none_mask = EMLP_NEW);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (send_msg | msg_loc), *msg,
             EMS_E_LoopError, ret_end);
          }
        }
      }

    }  /* if(!(options & EMtplydel_NoCommonEdge)) */


  /*
   * If this was a split-loop, the property-bit indicating this
   * is no longer useful or relevant. Hence, it should be turned
   * off.
   */

  if ( (ME.EMSloop->lp_props & EMLP_SPLIT) &&
      !(options & EMtplydel_MaintainSplit))
    ME.EMSloop->lp_props &= ~EMLP_SPLIT;

  /*
   * Also, since this loop has been deleted, any other boundary
   * that might be bounding this area must also be deleted. The loop-ids
   * collected at the beginning of this method are the ids of 
   * potential candidates for removal/deletion. A preliminary check
   * of whether the ids still remain valid, is performed.
   */

  if (delloops_count)
    {
    for (i=0; i<delloops_count; i++)
      {
      stat_OM = om$is_objid_valid (objid = delloops_objlist[i].S_objid);
      if (stat_OM == OM_S_SUCCESS)
        {
        stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc,
                   &props), targetid = delloops_objlist[i].S_objid);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

        this_loop_p = ME.EMSloop->lp_props & EMLP_PLOOP;
        delloop_p = props & EMLP_PLOOP;
        delloop_active = props & EMLP_ACTIVE;
        if (delloop_active && ((this_loop_p && !delloop_p) ||
                              (!this_loop_p && delloop_p)))
          { 
          stat_OM = om$send (msg = message EMSloop.EMtplydelete (&msg_loc,
                   numsfs, sfloops, numowners, ownercomps, options),
                   targetid = delloops_objlist[i].S_objid);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
          }
        }
      else
        stat_OM = OM_S_SUCCESS;
      }
    }

  /*
   * If the argument list indicates that this loop is to
   * be deleted, send a delete message to myself.
   */

  if (delete)
    {
    stat_OM = om$send (msg = message Root.delete (TRUE), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    }

ret_end:
  if (delloops_objlist && delloops_count > INIT_OBJLIST_SIZE)
    om$dealloc (ptr = delloops_objlist);
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMtplydelete");
  return (stat_OM);
}

end implementation EMSloop;
