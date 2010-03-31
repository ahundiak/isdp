class implementation EMAsurface;

#include "EMS.h"
# define MAX_OBJ 10
# include "nddef.h" /* For ND_ROOT */

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
 IGRint children_count=0,owner_count = 0, total_count = 0, temp_count;
 OM_S_OBJECT_LINKAGE *link_ptr = NULL;
 OM_S_CHANSELECT children,to_owners;
 struct GRid *grid_ptr;

/* Static variable */

 static IGRchar *my_buffer_addr = NULL;
 static IGRint my_buffer_size = 0;

/* *************** */

 status = OM_S_SUCCESS;
 EMmsg = EMS_S_Success;

 *count = 0;
 status = om$make_chanselect (channame = "NDchildren.children",
                              p_chanselect = &children);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect(channame = "GRconnector.to_owners",
                             p_chanselect = &to_owners);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 if( type & ND_ROOT) 
 {
   return(om$send (mode = OM_e_wrt_message,
                    msg = message EMSassoc.NDget_objects(type,list, size,
                          buffer, ifrom, ito, count),
                    targetid = my_id));
 }

 status = om$get_channel_count(object = me, p_chanselect = &children, 
			       count =  (OMuint *)&children_count);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);
 
 if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
  owner_count = 1;
 else
  owner_count = 0;

 total_count = children_count + owner_count;

 if (!total_count)
 {
  *count = 0;
  return (OM_S_SUCCESS);
 }

 link_ptr = (OM_S_OBJECT_LINKAGE *) stackalloc(total_count*
            sizeof(OM_S_OBJECT_LINKAGE));
 EMerr_hndlr (!link_ptr, EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 if (children_count)
 {
  status = om$get_channel_objects(object = me, 
                                  p_chanselect = &children, 
			          list = link_ptr,
				  size = total_count,
				  count = (OMuint *)&temp_count);
  EMerr_hndlr (!status, EMmsg, EMS_E_OMerror, wrapup);
 }

 if (owner_count)
 {
  status = om$get_objid_at_index(objid = my_id,
                                 p_chanselect = &to_owners,
                                 index = 0,
                                 objidaddr = &link_ptr[children_count].S_objid,
                                 osnumaddr = &link_ptr[children_count].osnum);
  EMerr_hndlr (!status, EMmsg, EMS_E_OMerror, wrapup);
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
      *buffer = (struct GRid *)my_buffer_addr;
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
      ++(*count);
    }
    *count = total_count;

 wrapup : 
     if (link_ptr) stackfree (link_ptr);
     EMWRAPUP (EMmsg, status, "In EMAsurface:NDget_objects error");
     return(status);
}
end implementation EMAsurface;
