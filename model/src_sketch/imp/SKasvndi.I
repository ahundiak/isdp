class implementation SKasvlgrnd;

from SKvariable import SKputvar;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from expression import NDgive_value;

method NDupdate(IGRint *msg;
                IGRint cn_type;
                IGRint parent_count;
	        struct GRid *parents;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
{
  IGRlong msg_loc, stat_OM;
  IGRdouble exp_val;
  OM_S_CHANSELECT chan_to_vars;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  if (new_objid)
  {
   new_objid->objid = my_id;
   new_objid->osnum = OM_Gw_current_OS;
  }

  EMerr_hndlr (parent_count != 1 || !parents, *msg, EMS_E_InvalidArg, ret_end);

  stat_OM = om$send (msg = message expression.NDgive_value (&exp_val),
             targetid = parents->objid, targetos = parents->osnum);
  EMomerr_exit (stat_OM, ret_end);

  om$make_chanselect (channame = "SKconstraint.to_variables",
   p_chanselect = &chan_to_vars);

  stat_OM = om$send (msg = message SKvariable.SKputvar (&msg_loc, NULL,
             NULL, NULL, &exp_val), p_chanselect = &chan_to_vars);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_ASerror, ret_end);

ret_end:
 if (1&stat_OM&*msg)
  *msg = ND_COMP_SUCC;
 else
  *msg = ND_COMP_FAIL;
  EMWRAPUP (*msg, stat_OM, "SKasvlgrnd.NDupdate");
  return (stat_OM);
}



method NDget_objects (IGRint type;
                     struct GRid *list;
                     IGRint size; 
                     struct GRid **buffer;
		     IGRint ifrom;
                     IGRint ito;
                     IGRint *count)
{
 IGRlong status,EMmsg;
 OM_S_OBJECT_LINKAGE link_buffer[10],*link_ptr;
 static IGRchar *my_buffer_addr = NULL;
 static IGRint my_buffer_size = 0;
 struct GRid *grid_ptr;
 IGRint new_size,list_size;
 OM_S_CHANSELECT *chan,father;
 IGRint i,start_inx,stop_inx;
 IGRuint temp_count=0;
 IGRchar *ptr = NULL;

 status = OM_S_SUCCESS;
 EMmsg = EMS_S_Success;

 status = om$make_chanselect (channame = "NDfather.father",
                              p_chanselect = &father);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 if( type & ND_ROOT) 
 {
  chan = &father;

  status = om$get_channel_count(object = me, p_chanselect = chan, 
 			        count = (OMuint *) count);
  EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);
 }
 else
  *count = 1;

 if( *count > 10)
 {
   ptr = om$malloc(size = (*count)*sizeof(OM_S_OBJECT_LINKAGE));
   EMerr_hndlr (!ptr, EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

   link_ptr = (OM_S_OBJECT_LINKAGE *) ptr;
  }
 else
 {
  link_ptr = link_buffer;
  ptr = NULL;
 }

  if (*count)
  {
   if (type & ND_ROOT)
   {
    status = om$get_channel_objects(object = me, 
                                    p_chanselect = chan, 
   			            list = link_ptr,
				    size = (OMuint) *count,
				    count = &temp_count);
    EMerr_hndlr (!status, EMmsg, EMS_E_OMerror, wrapup);
   }
   else
   {
    status = om$send (msg = message SKconstraint.SKgetmgr(&EMmsg, 
                     &link_ptr[0].S_objid),
                     targetid = my_id);
    EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);
    link_ptr[0].osnum = OM_Gw_current_OS;
   }
  }

  start_inx = ifrom > 0 ? ifrom : 0;
  stop_inx = ito   < (*count) ? ito : *count-1; 

  new_size = stop_inx-start_inx+1;

  if(type & ND_IN_BUF)
  { 
    if(new_size>my_buffer_size)
    {
      if(my_buffer_addr != NULL) om$dealloc(ptr = my_buffer_addr);
      my_buffer_addr = NULL;
      my_buffer_size = 0;
      my_buffer_addr = om$malloc(size = new_size*sizeof(struct GRid));
      EMerr_hndlr(!my_buffer_addr,EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

      my_buffer_size = new_size;
    }
      *buffer = (struct GRid *) my_buffer_addr;
      grid_ptr = (struct GRid *) my_buffer_addr;
   }
   else
   {
      if (new_size > size)
        goto wrapup;
      grid_ptr = list;
   }

   for(i=start_inx;i<=stop_inx;i++)
      {
        grid_ptr->objid = link_ptr[i].S_objid;
        grid_ptr->osnum = link_ptr[i].osnum;
        ++grid_ptr;
      }
   list_size = new_size - (*count);


 wrapup : 
     EMWRAPUP (EMmsg, status, "SKasvlgrnd.NDget_objects");
     if(ptr != NULL) om$dealloc(ptr = ptr);
     return(status);
}

end implementation SKasvlgrnd;

