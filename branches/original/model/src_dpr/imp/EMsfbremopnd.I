/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "EMSdpr.h"

method EMremoveOpnd(IGRlong *EMmsg; GRobjid operand_id; 
                    struct GRmd_env *env; GRobjid *new_active_id;
                    GRobjid *remaining_id;
                    IGRushort options)
/*
Description
    This message removes the given operand from the DPR node.  Also, this
    message determine if the DPR node is no longer needed and deletes it.

Return Values
    EMS_S_Success if all is well.

Notes
    About parameters:
      operand_id - the id of the operand of this node to be removed.
      new_active_id - is the new active state id if such a change occurs.
                      NULL_OBJID otherwise.
      remaining_id - is the id of the node that remains in the tree after
                     the removal occurs.  Note that in some cases the tree
                     may disappear as a result of the removal.  In such
                     cases, NULL_OBJID will be returned.
      options - currently unused.

History
    DLB 10/05/89 Changed logic for ipss.  If removing opnd of ipss, delete
                 RI plane only if not part of model.  Otherwise, connect it
                 to owner as normal.  
                 Reason:  Although it seems that the RI plane is no longer
                 useful, it may in fact have dependent nodes above. 
                 Therefore, deleting the RI plane is not a good idea.
    DLB 05/23/89 Added EMrecompinfodelete send.
    DLB 12/17/88 Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS, owner_to_me_index;
  OMuint          count, operand_index;
  GRobjid         other_opnd_id;
  enum EMSbooltype exact_type;
  union EMSri_table *ri;
  struct GRid     my_GRid, my_owner_GRid;
  OM_S_CHANSELECT to_comps, to_owners;
  IGRboolean      mbool=FALSE, set1_opnd=TRUE, have_no_owner=FALSE,
                  set_opnd_active=FALSE, rev_orient = TRUE;
  OMuword         dumosnum;


  *EMmsg = EMS_S_Success;
  *new_active_id = NULL_OBJID;
  *remaining_id = my_id;
  ri = NULL;

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  /*Determine if this is a mbool.*/
  OM_stat = om$get_channel_count(object = me,
                                 p_chanselect = &to_comps,
                                 count = &count);
  if (!(1 & OM_stat)) goto wrapup;                      

  if (count > 2) mbool = TRUE;

  /*Determine if the opnd is in set 2.*/
  OM_stat = om$get_index(object_c = me,
                         p_chanselect = &to_comps,
                         objid = operand_id,
                         indexaddr = &operand_index);
  if (!(1 & OM_stat)) goto wrapup;                           

  if (operand_index) set1_opnd = FALSE;
    
  /* Get the operation type. */
  OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(
                          EMmsg, NULL, &exact_type, NULL, &rev_orient,        
                          NULL, NULL, NULL, NULL, NULL, NULL, NULL), 
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (exact_type == EMSbool_saveside && set1_opnd) 
  {
    /*The set 1 opnd is being removed and this op is an intersect plane save
     * side.  Some special processing needs to be done here since this will
     * have implications on the next state.
     */

    /*Since this node is going to be deleted, make sure the any unused RI
     * info laying around is going to be deleted.  This needs to be the first 
     * thing done since the recompute info may not only be in the vla but 
     * on the to_comps channel (for e.g. saveside).
     *
     * 10/5/89 I changed the option to not delete the ri plane if in the
     *         model.  This is required since next states may depend on the
     *         plane but are  otherwise not affected by the removal.
     * OM_stat = om$send(msg = message EMSdpr.EMrecompinfodelete(EMmsg, env, 
     *                       NULL, NULL),
     *                 targetid = my_id);
     *if (! (1 & OM_stat & *EMmsg)) goto wrapup;                   
     */
    OM_stat = om$send(msg = message EMSdpr.EMgetRI(EMmsg, &ri),
                      targetid = my_id);
    if (! (1 & OM_stat & *EMmsg)) goto wrapup;                   

    if (om$is_objid_on_channel(object_c = me, p_chanselect = &to_comps,
                        objid = ri->saveside_info.plane_id) == OM_W_NOTONCHAN)
    {
      /*Plane is not part of model so delete it.*/
      OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                        targetid = ri->saveside_info.plane_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }                        
  }

  /*Disconnect the operand to remove.*/
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &my_GRid),
                    targetid = operand_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;  

  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  if (!mbool)
  {
    /*Can move the remaining opnd up to my owner.*/
    *remaining_id = NULL_OBJID;

    /*Find the proper index of my owner.*/
    OM_stat = om$get_objid_at_index(object = me,
                                    p_chanselect = &to_owners,
                                    index = 0,
                                    objidaddr = &my_owner_GRid.objid,
                                    osnumaddr = &dumosnum);
    if (OM_stat == OM_E_INVINDEX)
    {
      /*No owner is present.*/
      have_no_owner = TRUE;
      /*Also, the other operand must be set to active.*/
      set_opnd_active = TRUE;
      OM_stat = OM_S_SUCCESS;
    }
    else if (!(1 & OM_stat)) 
      goto wrapup;  
    else
    {
      /*I have an owner so first see if its a dpr.*/
      if (!EFisAncestryValid(EMmsg, my_owner_GRid.objid, OM_Gw_current_OS,
                             OPP_EMSdpr_class_id, FALSE))
      {
        set_opnd_active = TRUE;                             
      }
      else
      {
        *remaining_id = my_owner_GRid.objid;
      }

      /*Now get some info. about its relationship to me.*/
      my_owner_GRid.osnum = OM_Gw_current_OS;

      OM_stat = om$get_index(objid_c = my_owner_GRid.objid,
                             p_chanselect = &to_comps,
                             objid = my_id,
                             indexaddr = (OMuint *) &owner_to_me_index);
      if (!(1 & OM_stat)) goto wrapup;                             

      /*Disconnect me from my owner.*/
      OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, 
                              &my_owner_GRid),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                        
    }

    /*Get the remaining opnd.  If I am to remove myself and the removing node
     * is a set 1 node then the remaining node is in set 2 BUT is on index 0
     * due to the set 1 node already being disconnected.
     */
    OM_stat = om$get_objid_at_index(object = me,
                                    p_chanselect = &to_comps,
                                    index = 0,
                                    objidaddr = &other_opnd_id,
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;                                    

    OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                            &my_GRid),
                      targetid = other_opnd_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
                          
    if (!have_no_owner)
    {
      /*Connect the other opnd to my owner.*/
      OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                              &my_owner_GRid, &owner_to_me_index),
                        targetid = other_opnd_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                        
    }

    if (set_opnd_active)
    {
      IGRboolean action = TRUE;
      IGRushort mask = EMSIS_ACTIVE_STATE;

      /*The other opnd should be active.*/
      OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, 
                              &mask),
                        targetid = other_opnd_id);
      if (!(1 & OM_stat & *EMmsg) && OM_stat != OM_W_UNKNOWN_MSG) 
        goto wrapup;
      OM_stat = OM_S_SUCCESS;

      *new_active_id = other_opnd_id;
    }

    /*Now delete me.*/
    OM_stat = om$send(msg = message Root.delete(NULL),
                      targetid = my_id);
    if (! (1 & OM_stat & *EMmsg)) goto wrapup;                   
  }
  else if (set1_opnd)
  {
    /*Multiple boolean and removed opnd is in set 1 so change this node
     * to a disjoint union boolean type.
     */
    ME.EMSsfboolean->operation = EMSbool_disjointU;
  }

  wrapup:
    if (ri) om$dealloc(ptr = ri);
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfboolean.EMremoveOpnd")
    return(OM_stat);
}
end implementation EMSsfboolean;

#if NO_LONGER_USED_BUT_KEPT_SO_I_KNOW_WHAT_I_DID
  if (exact_type == EMSbool_saveside && set1_opnd) 
  {
    /*Tell my owner to remove me.*/
    *remaining_id = NULL_OBJID;
    OM_stat = om$send(msg = message EMSdpr.EMremoveOpnd(EMmsg, my_id, env,
                            new_active_id, remaining_id, options), 
                      p_chanselect = &to_owners);
    if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;

    if (*EMmsg == EMS_I_RemoveYourself)
      remove_myself = TRUE;
    else
    {
      /*Now delete me.*/
      OM_stat = om$send(msg = message Root.delete(NULL),
                        targetid = my_id);
      if (! (1 & OM_stat & *EMmsg)) goto wrapup;                   

      remove_myself = FALSE;
    }
  }
#endif
