class implementation SKasptgrnd;

/*
   HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
	Rajiv  : 12/30/93 : Moved all the code from here into the SKevaluate of this
	                    constraint.
*/

#include "OMmacros.h"
#include "ma.h"
#include "maarendpt.h"
#include "maoptsxfo.h"
#include "matypemx.h"

#define FIRST	0
#define SECOND	1
#define THIRD	2

#define MAX_OBJ 10

from SKmgr import SKmgrprops;

method NDupdate(IGRint *msg;
                IGRint cn_type;
                IGRint count;
	        struct GRid *list;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
{
 IGRlong status, msg_loc;
 GRobjid mgrobj;
 
 status = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;

 /*
  * Mark the dependent SKmgr out-of-date so that it will be forced to recompute.
  */
 status = om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &mgrobj),
           targetid = my_id);
 EMerr_hndlr(!(1&msg_loc&status), *msg, EMS_E_Fail, wrapup);
 
 status = om$send (msg = message SKmgr.SKmgrprops (&msg_loc, SK_CHGPROPS_ON,
           SK_MGR_OUTOFDATE, NULL), targetid = mgrobj);
 EMerr_hndlr(!(1&msg_loc&status), *msg, EMS_E_Fail, wrapup);

wrapup:
 if (1&status&*msg)
  *msg = ND_COMP_SUCC;
 else
  *msg = ND_COMP_FAIL;

 EMWRAPUP (*msg, status, "SKasptgrnd.NDupdate");
 return (status);
}

method NDget_objects(IGRint type;
                     struct GRid *list;
                     IGRint size; 
                     struct GRid **buffer;
		     IGRint ifrom;
                     IGRint ito;
                     IGRint *count)
{
 IGRlong status,EMmsg;
 OM_S_OBJECT_LINKAGE link_buffer[MAX_OBJ],*link_ptr;
 static IGRchar *my_buffer_addr = NULL;
 static IGRint my_buffer_size = 0;
 struct GRid *grid_ptr;
 IGRint new_size,list_size;
 OM_S_CHANSELECT *chan = 0,father;
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
   OMuint tmp_count;
   
  chan = &father;

  status = om$get_channel_count(object = me, p_chanselect = chan, 
 			        count = &tmp_count);
  *count = tmp_count;
  EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);
 }
 else
  *count = 1;

 if( *count > MAX_OBJ)
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
				    size = *count,
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
      grid_ptr = (struct GRid*) my_buffer_addr;
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
     EMWRAPUP (EMmsg, status, "In SKasptgrnd: NDget_objects error");
     if(ptr != NULL) om$dealloc(ptr = ptr);
     return(status);
}
end implementation SKasptgrnd;

