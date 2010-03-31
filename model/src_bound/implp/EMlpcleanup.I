/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION:
 
    This method is invoked after this loop-tree has been modified by a
    Boolean operation or some other similar operation. The method is 
    typically invoked by the loopset for this loop-tree. It determines 
    if any of the loops (regions) neighboring this one in the loop-tree or
    this loop itself is to be elliminated and sends a topology-delete message
    to such loop(s). The topology-delete method will have the effect of
    removing (and perhaps deleting) all the surfaces regions that are in any
    way adjacent to the region that has been determined to be 
    removable/deletable.

    If a determination cannot be made whether to elliminate any loop or not,
    this method harmlessly exits.

  ARGUMENTS

    numsfs		- The number of surfaces that were affected by
                          this cleanup. Relevant only if the delete option
                          is FALSE.
    sfloops		- The linked list that contains information on
                          the loops that were removed from each of the
                          surfaces. Only if the delete option is FALSE.
    numowners		- The number of surface-owners that had surfaces
                          removed from them. Only if the delete option
                          is FALSE.
    owncomps		- The linked list containing information on the
                          surfaces removed from each of the owners.
                          Only if the delete option is FALSE.
    delete		- If TRUE, the cleaned up components are deleted,
			  else they are removed and returned in the linked
                          lists.

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

    The loop that has pieces of it used up to form new loops, has it's
    split-bit turned on. All newly formed loops have their new-bit turned
    on. The active-bit is on for all the loops that are to be cleaned
    up.

  ALGORITHM

    If this loop is new and:
      i) It is a P-loop - Any parent P-loops that are still active are
         sent a topology-delete message. The reasoning is that the boundary
         operation has caused the original area (P-loop) to shrink.
     ii) It is a C-loop - Any child C-loops that are still active are
         sent a topology-delete message. the reasoning is that the boundary
         operation has caused the hole to enlarge.

    All other combinations for a new loop either require no action or they
    simply cannot occur. This is again based on the knowledge that no area
    can be added into the existing boundary.

    On the other hand, if this loop is split - that is, parts of it are
    used up to make new loops - it needs to be unconditionally elliminated
    by a topology-delete.

  SEE ALSO
   
    The files containing the EMlscleanup and the EMlptplydelete methods.

  HISTORY

    SS  :  03/01/87  :  Creation
    SS  :  05/29/87  :  Changed the method so that it does not propogate
                        down the tree.
    SS  :  02/25/88  :  Modified the send of EMSloop.EMtplydelete by
			indexing, to check for validity of the send.
*/

class implementation EMSloop;

#include "EMS.h"
#include "OMmacros.h"

#define OBJECT_BUFF_SIZE 10

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMlpcleanup (IGRlong *msg; IGRint *numsfs; 
                    struct EMSownercomp **sfloops; IGRint *numowners;
                    struct EMSownercomp **owncomps; 
		    IGRushort options)
{
  IGRboolean objlist_malloced;
  IGRushort props;
  OMuint count;
  IGRint stat_OM, i;
  IGRlong msg_loc;
  GRobjid childobj;
  OM_S_OBJECT_LINKAGE *objlist, objlistmem[OBJECT_BUFF_SIZE];
  OM_S_CHANSELECT chan_to_inner, chan_to_outer;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  objlist = NULL;

  chan_to_inner.type = OM_e_addr;
  chan_to_inner.u_sel.addr = &ME.EMSloop->to_inner;

  chan_to_outer.type = OM_e_addr;
  chan_to_outer.u_sel.addr = &ME.EMSloop->to_outter;

  /*
   * A decision, whether to delete a loop or not can be made only
   * with relation to a newly formed loop. The new loop itself is
   * never deleted. Only old loops that satisfy certain conditions
   * w.r.t the new loops can be said to be deletable. The propagation
   * of this delete will ultimately ensure that all the relevant old
   * loops are deleted. 
   *   Further, due to implementation characteristics, loops that have
   * had some pieces used, to form new loops do still continue to exist.
   * These are therefore, unconditional candidates for deletion.
   */

  if (ME.EMSloop->lp_props & EMLP_NEW)
    {
    if (ME.EMSloop->lp_props & EMLP_PLOOP)
      {
      /*
       * This loop is the "outer" bounds of a newly defined area.
       * Any P-loop parent that this loop might have needs to be
       * deleted. The area represented by this P-loop parent has been 
       * shrunk to this P-loop.
       */

      if (! (ME.EMSloop->lp_props & EMLP_EXTERNAL))
        {
        /*
         * The loop has atleast one parent loop on the
         * "to_outer" channel.
         */

        stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc,
                   &props), p_chanselect = &chan_to_outer);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

        if ((props & EMLP_PLOOP) && (props & EMLP_ACTIVE))
          {
          stat_OM = om$send (msg = message EMSloop.EMtplydelete (&msg_loc,
                     numsfs, sfloops, numowners, owncomps, options), 
                     p_chanselect = &chan_to_outer);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
          }
        }
      }
    else
      {
      /*
       * This loop is the "inner" bounds of a newly defined area.
       * All C-loop children that this loop might have, need to be
       * deleted. The holes represented by these C-loop children 
       * have been expanded to this C-loop.
       */

      stat_OM = om$get_channel_count (objid = my_id,
                 p_chanselect = &chan_to_inner, count = &count);
      EMomerr_exit (stat_OM, ret_end);
                 
      if (count)
        {
        /*
         * The loop has atleast one child loop on the
         * "to_inner" channel. After the topology-delete message, the
         * channel composition changes and has to be continually
         * checked. Obtain the list of all the loops nested under this
         * one.
         */

        if (count > OBJECT_BUFF_SIZE)
          {
          objlist = (OM_S_OBJECT_LINKAGE *) om$malloc (size = count *
                     sizeof (OM_S_OBJECT_LINKAGE));
          EMerr_hndlr (!objlist, *msg, EMS_E_NoDynamicMemory, ret_end);
          objlist_malloced = TRUE;
          }
        else
          {
          objlist = objlistmem;
          objlist_malloced = FALSE;
          }

        stat_OM = om$get_channel_objects (object = me, 
                   p_chanselect = &chan_to_inner, list = objlist, 
                   size = count, count = &count);
        EMomerr_exit (stat_OM, ret_end);

        /*
         * If any one of them is a valid C-loop, still hanging off this
         * loop, send a topology-delete message to it.
         */

        for (i=0; i<count; i++)
          {
          childobj = objlist[i].S_objid;
          stat_OM = om$is_objid_valid (objid = childobj);
          if (stat_OM == OM_S_SUCCESS)
            {
            stat_OM = om$is_objid_on_channel (object_c = me,
                       p_chanselect = &chan_to_inner, objid = childobj);
            if (stat_OM != OM_S_SUCCESS)
              childobj = NULL_OBJID;
            }
          else
            childobj = NULL_OBJID;
          stat_OM = OM_S_SUCCESS;
                     
          if (!IF_NULL_OBJID (childobj))
            {
            stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc,
                       &props), targetid = childobj);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

            if (!(props & EMLP_PLOOP) && (props & EMLP_ACTIVE))
              {
              stat_OM = om$send (msg = message EMSloop.EMtplydelete (&msg_loc,
                         numsfs, sfloops, numowners, owncomps, options), 
                         targetid = childobj);
              EMomerr_exit (stat_OM, ret_end);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
              }
            }
          }
        }
      }
    }
  else if ((ME.EMSloop->lp_props & EMLP_SPLIT) && 
           (ME.EMSloop->lp_props & EMLP_ACTIVE))
    {
    /*
     * This loop needs to be looked upon as a loop that has
     * had relevant portions (edges/part-edges) taken out
     * from it and used to form new loop(s). Topologically,
     * this loop no longer exists and must be removed. 
     */
  
    stat_OM = om$send (msg = message EMSloop.EMtplydelete (&msg_loc,
               numsfs, sfloops, numowners, owncomps, options),
               targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
    }

ret_end:
  if (objlist && objlist_malloced)
    om$dealloc (ptr = objlist);
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMlpcleanup");
  return (stat_OM);
}

end implementation EMSloop;
