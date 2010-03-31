/*
Same as EMsend_partedges.
*/
class implementation EMSedge;

#include "EMS.h"
extern GRclassid OPP_NMpartedge_class_id;

#include "OMprimitives.h"   /* om$malloc    */

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define INIT_OBJLIST_SIZE   5

extern OMuword OPP_EMSpartedge_class_id;

IGRint NMsend_to_partedges (rc, messg, sender_edge, sender_edgeos, frominx, 
                         toinx, all_mask, any_mask, none_mask)
IGRlong *rc;
OM_p_MESSAGE messg;
GRobjid sender_edge;
GRspacenum sender_edgeos;
IGRint frominx, toinx;
IGRushort all_mask, any_mask, none_mask;
{
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRboolean edge_ok;
  IGRushort props;
  IGRint stat_OM, listsize, relinx, iter, numsent;
  OMuint count;
  IGRlong msg_loc;
  GRclassid owner_classid;
  OM_S_OBJECT_LINKAGE init_list[INIT_OBJLIST_SIZE], *objlist = NULL;
  OM_S_CHANSELECT chan_to_owner;

  *rc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  strcpy (errmsg, "EMsend_partedges");

  listsize = 0;

  if (frominx > toinx)
    {
    *rc = MSINARG;
    stat_OM = OM_E_INVALIDRANGE;
    goto ret_end;
    }
  
  stat_OM = EMmake_chanselect (EMSedge_to_owner, &chan_to_owner);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (p_chanselect = &chan_to_owner,
             objid = sender_edge, osnum = sender_edgeos, count = &count);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (!count, stat_OM, OM_I_CHAN_EMPTY, ret_end);

  if (count > INIT_OBJLIST_SIZE)
    {
    objlist = (OM_S_OBJECT_LINKAGE *) om$malloc (size = count * 
		sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!objlist, *rc, MSNOMEM, ret_end);
    listsize = count;
    }
  else
    {
    objlist = init_list;
    listsize = INIT_OBJLIST_SIZE;
    }

  stat_OM = om$get_channel_objects (objid = sender_edge, osnum = sender_edgeos,
             p_chanselect = &chan_to_owner, list = objlist, 
             size = listsize, count = &count);
  EMomerr_exit (stat_OM, ret_end);

  relinx = 0;
  numsent = 0;
  iter = 0;
  while (iter < count && relinx <= toinx)
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
                   targetos = objlist[iter].osnum, senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *rc, EMS_E_EdgeError, ret_end);

        /*
         * Check if the conditions requested to be satisfied
         * are indeed satisfied by this loop.
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

      if (edge_ok && relinx >= frominx)
        {
        stat_OM = om$send (msg = messg, targetid = objlist[iter].S_objid,
                   senderid = sender_edge, targetos = objlist[iter].osnum);
        EMerr_hndlr (stat_OM == OM_I_STOP_SENDING, stat_OM, OM_S_SUCCESS,
         ret_end);
        EMomerr_exit (stat_OM, ret_end);
        numsent++;
        }
      if (edge_ok)
        relinx++;
      }
    else
      stat_OM = OM_S_SUCCESS;

    iter++;
    }

  if (relinx == 0)
    {
    stat_OM = OM_I_CHAN_EMPTY;
    goto ret_end;
    }
  else if (relinx > 0 && numsent == 0)
    {
    *rc = EMS_E_InvalidArg;
    stat_OM = OM_E_INVALIDRANGE;
    }

ret_end:
  if (listsize > INIT_OBJLIST_SIZE)
    om$dealloc (ptr = objlist);
  EMWRAPUP (*rc, stat_OM, "NMsend_to_partedges");
  return(stat_OM);
}

end implementation EMSedge;
