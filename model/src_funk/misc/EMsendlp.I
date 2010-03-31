/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION:

    This function is usable by any object to send a message to specific
    loop(s) owning a specified edge. The edge is specified by it's object
    id and the loop is specified by a list of properties that must be
    satisfied. Thus, this function serves as a means of breaking up the
    edge-loop channel into user-definable pieces, where it appears that
    only those loops are connected to the edge that are specified via
    the proerties masks.

  ARGUMENTS:

    IGRlong 		- Return code: 
     *rc
                           EMS_S_Success
                           EMS_E_InvalidArg if 'frominx' greater than
                                            'toinx' or if frominx greater
                                            than the number of valid loops
                           EMS_E_NoDynamicMemory
    OM_p_MESSAGE	- Message to be sent to the valid loop(s)
     messg
    GRobjid 		- The edge whose loops are the targets for the
     sender_edge	  message send.
    IGRint		- The starting relindex on the edge-loop
     frominx              channel if there were only valid loops on it.
    IGRint		- The ending relindex on the edge-loop
     toinx		  channel if there were only valid loops on it.
    IGRushort   - Properties mask specifying properties 
     all_mask		  (specifiable by a bit turned ON) ALL of which
			  MUST be satisfied. If NULL, then this condition
                          is ignored.
    IGRushort   - Properties mask specifying properties 
     any_mask		  (specifiable by a bit turned ON) ANY of which
			  MUST be satisfied. If NULL, then this condition
                          is ignored.
    IGRushort   - Properties mask specifying properties 
     none_mask		  (specifiable by a bit turned ON) NONE of which
			  MUST be satisfied. If NULL, then this condition
                          is ignored.

  NOTES:

    For example, if the user would like to send to the active loop(s), 
      frominx would be 0, toinx could be any number greater than 0,
      all_mask would be (EMLP_ACTIVE), any_mask would be NULL and
      none_mask would be NULL.
    If a send to all loops was required,
      frominx would be 0, toinx could be MAXINT,
      all_mask would be NULL, any_mask would be NULL and
      none_mask would be NULL.

    An important characteristic to be noted is that the "sends" take place
    in the reverse order of channel connections if the conditions specified
    indicate that one of the properties required to be satisfied is that the
    loop be active. Every other condition causes the "sends" to take place
    in the natural order. This is done in the hope that if an active loop
    is being sought, it is found mostly at the (n-1)th index and that there
    is only one active loop. If the frominx and toinx are 0 and 0, 
    respectively, the target active loop is found and no more processing
    needs to be done. But if toinx is larger then the search continues
    for other loops on the channel that might satisfy these conditions.
*/

class implementation EMSedge;

#include "EMS.h"
#include "OMprimitives.h"   /* om$malloc    */

extern GRclassid OPP_EMSloop_class_id;

from EMSloop import EMget_props;

#define INIT_OBJLIST_SIZE   5

IGRint EMsend_loops (rc, messg, sender_edge, frominx, toinx, all_mask,
                     any_mask, none_mask)
IGRlong *rc;
OM_p_MESSAGE messg;
GRobjid sender_edge;
IGRint frominx, toinx;
unsigned short all_mask, any_mask, none_mask;
{
  IGRboolean loop_ok, must_be_active;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRushort props;
  IGRint stat_OM, count, numsent, relinx, iter, listsize;
  IGRlong msg_loc;
  GRclassid owner_classid;
  OM_S_OBJECT_LINKAGE init_list[INIT_OBJLIST_SIZE], *objlist;
  OM_S_CHANSELECT chan_to_owner;

  *rc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  strcpy (errmsg, "EMsend_loops");

  listsize= 0;

  if (frominx > toinx)
    {
    *rc = EMS_E_InvalidArg;
    stat_OM = OM_E_INVALIDRANGE;
    goto ret_end;
    }
  
  stat_OM = EMmake_chanselect (EMSedge_to_owner, &chan_to_owner);
  EMomerr_hndlr (stat_OM, ret_end, errmsg);

  stat_OM = om$get_channel_count (p_chanselect = &chan_to_owner,
             objid = sender_edge, count = (OMuint *)&count);
  EMomerr_hndlr (stat_OM, ret_end, errmsg);
  EMerr_hndlr (!count, stat_OM, OM_I_CHAN_EMPTY, ret_end);

  if (count > INIT_OBJLIST_SIZE)
    {
    objlist = (OM_S_OBJECT_LINKAGE *) om$malloc (size = count * 
		sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!objlist, *rc, EMS_E_NoDynamicMemory, ret_end);
    listsize = count;
    }
  else
    {
    objlist = init_list;
    listsize = INIT_OBJLIST_SIZE;
    }

  stat_OM = om$get_channel_objects (objid = sender_edge, 
             p_chanselect = &chan_to_owner, list = objlist, 
             size = listsize, count = (OMuint *)&count);
  EMomerr_hndlr (stat_OM, ret_end, errmsg);

  /*
   * Check if the send is to take place only to
   * an active loop. If so, the owner-channel
   * is processed in reverse, since it is more likely
   * to find the active-loop at this end.
   */

  props = EMLP_ACTIVE;
  if ((all_mask  ? props & all_mask : FALSE) ||
      (any_mask  ? ((props & any_mask) == any_mask) : FALSE))
    must_be_active = TRUE;
  else
    must_be_active = FALSE;

  relinx = 0;
  numsent = 0;
  iter = must_be_active ? count-1 : 0;
  while ((must_be_active ? iter>=0 : iter<=count-1) && relinx <= toinx)
    {
    stat_OM = om$get_classid (objid = objlist[iter].S_objid, 
               p_classid = &owner_classid);
    EMomerr_hndlr (stat_OM, ret_end, errmsg);

    stat_OM = om$is_ancestry_valid (subclassid = owner_classid, 
               superclassid = OPP_EMSloop_class_id);
    if (stat_OM == OM_S_SUCCESS)
      {
      if (all_mask || any_mask || none_mask)
        {
        stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc,
                   &props), targetid = objlist[iter].S_objid,
                   senderid = NULL_OBJID);
        EMomerr_hndlr (stat_OM, ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *rc, EMS_E_EdgeError, ret_end);

        /*
         * Check if the conditions requested to be satisfied
         * are indeed satisfied by this loop.
         */

        if ((all_mask && ((props & all_mask) != all_mask)) ||
            (any_mask && ! (props & any_mask)) ||
            (none_mask && (props & none_mask)))
          loop_ok = FALSE;
        else
          loop_ok = TRUE;
        }
      else
        loop_ok = TRUE;

      if (loop_ok && relinx >= frominx)
        {
        stat_OM = om$send (msg = messg, targetid = objlist[iter].S_objid,
                   senderid = sender_edge);
        EMerr_hndlr (stat_OM == OM_I_STOP_SENDING, stat_OM, OM_S_SUCCESS,
         ret_end);
        EMomerr_hndlr (stat_OM, ret_end, errmsg);
        numsent++;
        }
      if (loop_ok)
        relinx++;
      }
    else
      stat_OM = OM_S_SUCCESS;

    iter = must_be_active ? iter-1 : iter+1;
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
  return (stat_OM);
}

end implementation EMSedge;
