/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

extern OMuword OPP_EMSsolid_class_id;

method EMgetUnevalIds(IGRlong *EMmsg; GRobjid uneval_sender_id; IGRboolean
                      is_kd_on; IGRushort options;
                      IGRint *num_ids; GRobjid **ids)
/*
Description
    This message returns the array of ids that should have managers added 
    as a result of a deactivation of this state.

Return Values
    EMS_S_Success if all is well.

Notes
    About parameters:
      uneval_sender_id - the id of the node that defines the path of
                         deactivation. 
      is_kd_on  - indicates whether this node recieved a EMdeactivateState
                  message with the KD flag turned on.
      options - currently unused.
      num_ids - number of ids in ids array.
      ids - array of ids malloc'd by this message.  This array should be
            freed using om$dealloc.

History
    DLB 04/09/91 Was not checking for solid save side case. If so just return
                 with nothing as with the composite surface case.
    DLB 03/25/91 If uneval_sender_id is not on my comps chan, then return
                 success.
    DLB 12/13/88 Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  OMuint          num_to_add, uneval_index, i, count;
  OM_S_CHANSELECT to_comps;  
  OMuword         dumosnum;
  enum EMSbooltype exact_type;


  *EMmsg = EMS_S_Success;
  *ids = NULL;
  *num_ids = 0;

  /*See above history comments.*/
  if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                        OPP_EMSsolid_class_id, FALSE))
  {
    OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(
                            EMmsg, NULL, &exact_type, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if(exact_type == EMSbool_saveside) goto wrapup;
  }

  /*If the channel count is 1 then this is may be a saveside op on a composite
   * surface OR one of the sets was removed to to a later operation.  If
   * this is the case then simply return with no ids.
   */
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  OM_stat = om$get_channel_count(object = me,
                                 p_chanselect = &to_comps,
                                 count = &count);
  if (!(1 & OM_stat) || (count == 1)) goto wrapup;

  /*Determine if set 1 or set 2 should be unevaluated.*/
  OM_stat = om$get_index(object_c = me,
                         p_chanselect = &to_comps,
                         objid = uneval_sender_id,
                         indexaddr = &uneval_index);
  if (OM_stat == OM_W_NOTONCHAN)
  {
    OM_stat = OM_S_SUCCESS;
    goto wrapup;
  }
  else if (!(1 & OM_stat)) goto wrapup;                           

  if ( (is_kd_on && !uneval_index) || (!is_kd_on && uneval_index) )
  {
    /*if (dependent state AND sender is NOT in set 2) OR
     *if (NOT dependent state AND sender is in set 2) 
     * unevaluate set 1 (default is unevaluate set 2). 
     */
    num_to_add = 1;
    uneval_index = 0;
  }
  else
  {
    OM_stat = om$get_channel_count(object = me,
                                   p_chanselect = &to_comps,
                                   count = &num_to_add);
    if (!(1 & OM_stat)) goto wrapup;                      

    num_to_add--;
    uneval_index = 1;
  }

  *ids = (GRobjid *) om$malloc(size = num_to_add * sizeof(GRobjid));
  if (!*ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  *num_ids = num_to_add;

  /*Get the ids to add a manager to.*/
  for(i=0; i<num_to_add; i++)
  {
    OM_stat = om$get_objid_at_index(object = me,
                                    p_chanselect = &to_comps,
                                    index = uneval_index++,
                                    objidaddr = &(*ids)[i],
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;                                    
  }

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfboolean.EMgetUnevalIds")
    return(OM_stat);
}
end implementation EMSsfboolean;
