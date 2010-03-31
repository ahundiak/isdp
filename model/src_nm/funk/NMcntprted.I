class implementation EMSedge;

#include "EMS.h"
#include "OMprimitives.h"

extern GRclassid OPP_NMpartedge_class_id;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define INIT_OBJLIST_SIZE   5

extern OMuword OPP_EMSpartedge_class_id;

IGRint NMcount_nmpartedges (rc, sender_edge, sender_edgeos, count, edges,
                          all_mask, any_mask, none_mask)
IGRlong *rc;
GRobjid sender_edge;
GRspacenum sender_edgeos;
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
             objid = sender_edge, osnum = sender_edgeos, 
             count = (OMuint *) &loc_count);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (!loc_count, stat_OM, OM_I_CHAN_EMPTY, ret_end);

  if (loc_count > INIT_OBJLIST_SIZE || edges)
    {
    objlist = (OM_S_OBJECT_LINKAGE *) om$malloc (
		size = loc_count * sizeof (OM_S_OBJECT_LINKAGE));
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
    *edges = (OM_S_OBJECT_LINKAGE *) om$malloc (size = loc_count * 
		sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!(*edges), *rc, EMS_E_NoDynamicMemory, ret_end);
    }

  stat_OM = om$get_channel_objects (objid = sender_edge, osnum = sender_edgeos,
             p_chanselect = &chan_to_owner, list = objlist, 
             size = listsize, count = (OMuint *) &loc_count);
  EMomerr_exit (stat_OM, ret_end);

  iter = 0;
  while (iter < loc_count)
    {
    stat_OM = om$get_classid (objid = objlist[iter].S_objid, 
              osnum = objlist[iter].osnum, 
               p_classid = &owner_classid);
    EMomerr_exit (stat_OM, ret_end);

    if (owner_classid == OPP_NMpartedge_class_id)
      {
      if (all_mask || any_mask || none_mask)
        {
        stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                   &props), targetid = objlist[iter].S_objid,
                   targetos = objlist[iter].osnum, 
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
   if(objlist && (objlist != init_list))
    om$dealloc (ptr = objlist);
  EMWRAPUP (*rc, stat_OM, "NMcount_nmpartedges");
  return (stat_OM);
}

end implementation EMSedge;
