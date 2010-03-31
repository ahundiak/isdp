/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION:

    This function is usable by any object to count the number of specific
    type of partedges owning a specified edge. The edge is specified by it's 
    object-id and the partedge-type is specified by a list of properties that
    must be satisfied. Thus, this function serves as a means of breaking up the
    edge-loop/partedge channel into user-definable pieces, where it appears
    that only those partedges are connected to the edge that are specified via
    the proerties masks.

  ARGUMENTS:

    GRobjid             - The edge whose owner-partedges are to be queried
     sender_edge

    IGRint		- The returned count of the number of partedges
     *count

    OM_S_OBJECT_LINKAGE - If 'edges' (value) is not NULL the partedges are
     **edges               returned with memory malloced in this function.
                          Else, ignored.

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

    For example, if the user would like to count all the partedges,
      all_mask would be NULL, any_mask would be NULL and none_mask
      would be NULL.

  HISTORY

    SS  :  03/01/87  :  Creation
    SM  :  31-OCT_87 :  Changed the check from 'is_ancestry_valid' to
			explicit check to see if the object is of the class
			EMSpartedge.
*/

class implementation EMSedge;

#include "EMS.h"
#include "OMprimitives.h"

extern GRclassid OPP_EMSedge_class_id;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define INIT_OBJLIST_SIZE   5

extern OMuword OPP_EMSpartedge_class_id;

IGRint EMcount_partedges (rc, sender_edge, count, edges,
                          all_mask, any_mask, none_mask)
IGRlong *rc;
GRobjid sender_edge;
IGRint *count;
OM_S_OBJECT_LINKAGE **edges;
IGRushort all_mask, any_mask, none_mask;
{
  IGRboolean edge_ok;
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

  if (loc_count > INIT_OBJLIST_SIZE || edges)
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

  if (edges)
    {
    *edges = (OM_S_OBJECT_LINKAGE *)om$malloc (size = loc_count * 
		sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!(*edges), *rc, EMS_E_NoDynamicMemory, ret_end);
    }

  stat_OM = om$get_channel_objects (objid = sender_edge, 
             p_chanselect = &chan_to_owner, list = objlist, 
             size = listsize, count = (OMuint *)&loc_count);
  EMomerr_exit (stat_OM, ret_end);

  iter = 0;
  while (iter < loc_count)
    {
    stat_OM = om$get_classid (objid = objlist[iter].S_objid, 
               p_classid = &owner_classid);
    EMomerr_exit (stat_OM, ret_end);

/***************************
    stat_OM = om$is_ancestry_valid (subclassid = owner_classid, 
               superclassid = OPP_EMSedge_class_id);
***************************/

    if (owner_classid == OPP_EMSpartedge_class_id)
      {
      if (all_mask || any_mask || none_mask)
        {
        stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                   &props), targetid = objlist[iter].S_objid,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *rc, EMS_E_LoopError, ret_end);

        /*
         * Check if the conditions requested to be satisfied
         * are indeed satisfied by this edge.
         */

        if ((all_mask && ((props & all_mask) != all_mask)) ||
            (any_mask && ! (props & any_mask)) ||
            (none_mask && (props & none_mask)))
          edge_ok = FALSE;
        else
          edge_ok = TRUE;
        }
      else
        edge_ok = TRUE;

      if (edge_ok)
        {
        if (edges)
          (*edges)[(*count)] = objlist[iter];
        (*count)++;
        }
      }
    iter++;
    }

ret_end:
  /*if (listsize > INIT_OBJLIST_SIZE)*/
  if(objlist && (objlist != init_list))    om$dealloc (ptr = objlist);
  EMWRAPUP (*rc, stat_OM, "EMcount_partedges");
  return (stat_OM);
}

end implementation EMSedge;
