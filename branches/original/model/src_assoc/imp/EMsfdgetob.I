class implementation EMSsfdpr;

# include "nddef.h" 
# include <stdio.h>

method NDget_objects(IGRint type;
                     struct GRid *list;
                     IGRint size; 
                     struct GRid **buffer;
		     IGRint ifrom;
                     IGRint ito;
                     IGRint *count)
{
 IGRint i,start_inx,stop_inx;
 IGRlong status,EMmsg;
 IGRint list_size;
 OM_S_CHANSELECT to_components, father;
 IGRint father_count, component_count, temp_count, total_count;
 OM_S_OBJECT_LINKAGE *link_ptr = NULL;
 GRobjid *component_objids = NULL;
 struct GRid *grid_ptr;

/****** Static variable ***********/

 static IGRchar *my_buffer_addr = NULL;
 static IGRint my_buffer_size = 0;

/* ******************************* */

 status = OM_S_SUCCESS;
 EMmsg = EMS_S_Success;
 *count = 0;

 status = om$make_chanselect (channame = "NDfather.father",
                              p_chanselect = &father);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_components);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 if (type & ND_CHILDREN)
 {
   return (om$send (msg = message EMAsurface.NDget_objects(type, list,
                          size, buffer, ifrom, ito, count),
                    mode = OM_e_wrt_message,
                    targetid = my_id));
 }
 status = om$get_channel_count(object = me, p_chanselect = &father, 
			       count = (OMuint *)&father_count);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 status = om$get_channel_count(object = me, p_chanselect = &to_components, 
			       count = (OMuint *)&component_count);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 total_count = component_count + father_count;

 if (total_count)
 {
  link_ptr = (OM_S_OBJECT_LINKAGE *) stackalloc(sizeof(OM_S_OBJECT_LINKAGE) *
            total_count);
  EMerr_hndlr(!link_ptr, EMmsg, EMS_E_DynamicMemoryAllocated,
                wrapup);
 }

 if (component_count)
 {
  temp_count = 0;
  component_objids = (GRobjid *) stackalloc(component_count * sizeof (GRobjid));
  EMerr_hndlr(!component_objids, EMmsg, EMS_E_DynamicMemoryAllocated,
               wrapup);

  status = om$send (msg = message EMSsfdpr.EMget_component_parents(&EMmsg,
                          NULL,component_count, &temp_count, 
                          &component_objids),
                    targetid = my_id);
  EMerr_hndlr (!(1&status&EMmsg), EMmsg, EMS_E_Fail, wrapup);
  component_count = temp_count;
 }

 total_count = component_count + father_count;

 if (father_count)
 {
  status = om$get_channel_objects(object = me, 
                                  p_chanselect = &father, 
			          list = link_ptr,
				  size = total_count,
				  count = (OMuint *)&temp_count);
  EMerr_hndlr (!status, EMmsg, EMS_E_OMerror, wrapup);
 }

 for (i=0;i<component_count;i++)
 {
  link_ptr[father_count+i].S_objid = component_objids[i];
  link_ptr[father_count+i].osnum = OM_Gw_current_OS;
 }

  start_inx = ifrom > 0 ? ifrom : 0;
  stop_inx = ito   < (total_count) ? ito : total_count-1; 

  list_size = stop_inx-start_inx+1;

 
  if(type & ND_IN_BUF)
  { 
    if(list_size>my_buffer_size)
    {
      if(my_buffer_addr != NULL) om$dealloc(ptr = my_buffer_addr);
      my_buffer_addr = NULL;
      my_buffer_size = 0;
      my_buffer_addr = om$malloc(size = list_size*sizeof(struct GRid));
      EMerr_hndlr(!my_buffer_addr,EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

      my_buffer_size = list_size;
    }
      *buffer  = (struct GRid *)my_buffer_addr;
      grid_ptr = (struct GRid*) my_buffer_addr;
   }
   else
   {
      if (list_size > size)
      {
        *count = total_count;
        goto wrapup;
      }
      grid_ptr = list;
   }

   for(i=start_inx;i<=stop_inx;i++)
    {
      grid_ptr->objid = link_ptr[i].S_objid;
      grid_ptr->osnum = link_ptr[i].osnum;
      ++grid_ptr;
    }
    *count = total_count;

 wrapup : 
  if (link_ptr) stackfree (link_ptr);
  EMWRAPUP (EMmsg, status, "In EMSsfdpr:NDget_objects error");
  return(status);
}
end implementation EMSsfdpr;
