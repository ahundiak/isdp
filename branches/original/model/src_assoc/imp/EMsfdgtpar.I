class implementation EMSsfdpr;

method EMget_component_parents (IGRlong *EMmsg;
                                IGRuint options;
                                IGRint list_size;
                                IGRint *count;
                                GRobjid **component_objids)
{
 IGRlong status;
 IGRboolean found;
 IGRint num_in_geom_ids, component_count,i,j;
 GRobjid *in_geom_ids = NULL;
 OM_S_OBJECT_LINKAGE *link_ptr = NULL;
 OM_S_CHANSELECT to_components;
 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 *count = 0;

 status = om$send (msg = message EMSdpr.EMgetInGeomIds(EMmsg,NULL_OBJID,
                         FALSE, &num_in_geom_ids, &in_geom_ids,NULL),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 status = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_components);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
 
 status = om$get_channel_count(object = me, p_chanselect = &to_components, 
			       count = (OMuint *) &component_count);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 link_ptr = (OM_S_OBJECT_LINKAGE *) stackalloc(sizeof(OM_S_OBJECT_LINKAGE) *
                                    component_count);
 EMerr_hndlr(!link_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 status = om$get_channel_objects(object = me, 
                                  p_chanselect = &to_components, 
			          list = link_ptr,
				  size = component_count,
				  count = (OMuint *) &component_count);
 EMerr_hndlr (!status, *EMmsg, EMS_E_OMerror, wrapup);

 if (component_objids)
 {
  if (!(*component_objids))
  {
   *component_objids = (GRobjid *) om$malloc (size = sizeof (GRobjid) *
                                   component_count);
   EMerr_hndlr(!(*component_objids), *EMmsg, EMS_E_DynamicMemoryAllocated, 
                wrapup);

  }
 }

 for (i=0;i<component_count;i++)
 {
   found = FALSE;
   j=0;
   while (!found && (j < num_in_geom_ids))
   {
     if (link_ptr[i].S_objid == in_geom_ids[j])
      found = TRUE;
     else
      j++;
   }

   if (!found)
   { 
     if (component_objids)
     {
      (*component_objids)[*count] = link_ptr[i].S_objid;
     }
     ++(*count);
   }
 }

wrapup:
 if (link_ptr) stackfree (link_ptr);
 if (in_geom_ids) om$dealloc(ptr = in_geom_ids);
 EMWRAPUP (*EMmsg, status, "In EMSsfdpr: In EMget_component_parents error");
 return (status);
}
end implementation EMSsfdpr;

