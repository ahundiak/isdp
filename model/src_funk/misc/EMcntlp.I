/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION:

    This function is usable by any object to count the number of specific
    type of loops owning a specified edge. The edge is specified by it's 
    object-id and the loop-type is specified by a list of properties that
    must be satisfied. Thus, this function serves as a means of breaking up the
    edge-loop channel into user-definable pieces, where it appears that
    only those loops are connected to the edge that are specified via
    the properties masks.

  ARGUMENTS:

    GRobjid             - The edge whose owner-loops are to be queried
     sender_edge

    IGRint		- The returned count of the number of loops
     *count

    OM_S_OBJECT_LINKAGE - If loops (value) is not NULL the loops are
     **loops               returned with the memory malloced in this function.

    IGRushort   - Properties mask specifying properties 
     all_mask		  (specifiable by a bit turned ON) ALL of which
			  MUST be satisfied. If NULL, then ignored.
    IGRushort   - Properties mask specifying properties 
     any_mask		  (specifiable by a bit turned ON) ANY of which
			  MUST be satisfied. If NULL, then ignored.
    IGRushort   - Properties mask specifying properties 
     none_mask		  (specifiable by a bit turned ON) NONE of which
			  MUST be satisfied. If NULL, then ignored.

  RETURN VALUE:

    IGRlong 		- Return code: 
     *rc                    EMS_S_Success
                            EMS_E_NoDynamicMemory
  EXAMPLE:

    For example, if the user would like to count the number of active
      loops (maximum there can be is one), all_mask would be (EMLP_ACTIVE),
      any_mask would be NULL and none_mask would be NULL.
    If a count of all loops was required,
      all_mask would be NULL, any_mask would be NULL and
      none_mask would be NULL.

  HISTORY

    SS  :  03/01/87  :  Creation
*/

class implementation EMSedge;

#include "EMS.h"
#include "OMprimitives.h"

extern GRclassid OPP_EMSloop_class_id;

from EMSloop import EMget_props;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define INIT_OBJLIST_SIZE   5

IGRint EMcount_loops (rc, sender_edge, count, loops, 
                      all_mask, any_mask, none_mask)
IGRlong *rc;
GRobjid sender_edge;
OM_S_OBJECT_LINKAGE **loops;
IGRint *count;
IGRushort all_mask, any_mask, none_mask;
{
  IGRboolean loop_ok, only_active_loop;
  IGRushort props;
  IGRint stat_OM, loc_count, iter, listsize;
  IGRlong msg_loc;
  GRclassid owner_classid;
  OM_S_OBJECT_LINKAGE init_list[INIT_OBJLIST_SIZE], *objlist = NULL;
  OM_S_CHANSELECT chan_to_owner;

  *rc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *count = 0;
  listsize = 0;

  stat_OM = EMmake_chanselect (EMSedge_to_owner, &chan_to_owner);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (p_chanselect = &chan_to_owner,
             objid = sender_edge, count = (OMuint *)&loc_count);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (!loc_count, stat_OM, OM_I_CHAN_EMPTY, ret_end);

  if (loc_count > INIT_OBJLIST_SIZE)
    {
    objlist = (OM_S_OBJECT_LINKAGE *)om$malloc (size = loc_count * 
		sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!objlist, *rc, EMS_E_NoDynamicMemory, ret_end);
    listsize = loc_count;
    }
  else
    {
    objlist = init_list;
    listsize = INIT_OBJLIST_SIZE;
    }

  if (loops)
    {
    *loops = (OM_S_OBJECT_LINKAGE *)om$malloc (size = loc_count * 
		sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!(*loops), *rc, EMS_E_NoDynamicMemory, ret_end);
    }

  stat_OM = om$get_channel_objects (objid = sender_edge, 
             p_chanselect = &chan_to_owner, list = objlist, 
             size = listsize, count = (OMuint *)&loc_count);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * Check if only the count is to take place for
   * an active loop. If so, the processing should
   * stop once the active loop is reached (as there
   * can be only one such loop).
   */

  props = EMLP_ACTIVE;
  if (! (all_mask | any_mask | none_mask) ||
      (all_mask && ((props & all_mask) != all_mask)) ||
      (any_mask && ! (props & any_mask)) ||
      (none_mask && (props & none_mask)))
    only_active_loop = FALSE;
  else
    only_active_loop = TRUE;

  iter = loc_count-1;
  while (iter >= 0)
    {
    stat_OM = om$get_classid (objid = objlist[iter].S_objid, 
               p_classid = &owner_classid);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$is_ancestry_valid (subclassid = owner_classid, 
               superclassid = OPP_EMSloop_class_id);
    if (stat_OM == OM_S_SUCCESS)
      {
      if (all_mask || any_mask || none_mask)
        {
        stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc,
                   &props), targetid = objlist[iter].S_objid,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *rc, EMS_E_LoopError, ret_end);

        /*
         * Check if the conditions requested to be satisfied
         * are indeed satisfied by this loop.
         */

        if (only_active_loop)
          {
          if (! (props & EMLP_ACTIVE))
            loop_ok = FALSE;
          else
            loop_ok = TRUE;
          }
        else if ((all_mask && ((props & all_mask) != all_mask)) ||
                 (any_mask && ! (props & any_mask)) ||
                 (none_mask && (props & none_mask)))
          loop_ok = FALSE;
        else
          loop_ok = TRUE;
        }
      else
        loop_ok = TRUE;

      if (loop_ok)
        {
        if (loops)
          (*loops)[(*count)] = objlist[iter];
        (*count)++;
        }
      }
    iter--;
    }

ret_end:
/*  if (listsize > INIT_OBJLIST_SIZE) */
  if(objlist && (objlist != init_list))
    om$dealloc (ptr = objlist);
  EMWRAPUP (*rc, stat_OM, "EMcount_loops");
  return (stat_OM);
}

end implementation EMSedge;
