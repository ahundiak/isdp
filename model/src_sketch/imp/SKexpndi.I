class implementation SKexplicit;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "nddef.h"
#include "ndmacros.h"
#include "maidmx.h"

#define MAX_OBJ 10

from SKmgr import SKsaveolddim, SKmgrprops;

method NDdisplay(IGRint dp_type;enum GRdpmode mode;struct GRmd_env *env)
{
  IGRint status;
  IGRlong EMmsg;
  struct GRid mod_grid;
  IGRshort mat_type;
  IGRmatrix mat_ident;
  IGRdouble *mat;
 
  status = OM_S_SUCCESS;
  EMmsg = EMS_S_Success;


  if(env == NULL)
   {
    mat_type = MAIDMX;
    MAidmx(&EMmsg,mat_ident);
    mat = mat_ident;
   }
  else
   { 
    mat_type = env->md_env.matrix_type;
    mat = env->md_env.matrix;
   }

   GRfindmod(&mod_grid);
   status = om$send(msg = message GRgraphics.GRdisplay(&EMmsg,
        		    &mat_type,mat,&mode,&mod_grid),
                    targetid = my_id);
   EMerr_hndlr (!(1&status&EMmsg), EMmsg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (EMmsg, status, "In SKexplicit:NDdisplay error");
 return(status);
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
 OM_S_CHANSELECT *chan,father, children;
 IGRint total_count,i,start_inx,stop_inx;
 OMuint temp_count = 0;
 int    also_count = 0;
 IGRchar *ptr = NULL;

 status = OM_S_SUCCESS;
 EMmsg = EMS_S_Success;

 status = om$make_chanselect (channame = "NDfather.father",
                              p_chanselect = &father);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect (channame = "NDchildren.children",
                              p_chanselect = &children);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 if( type & ND_ROOT) 
    chan = &father;
 else
    chan = &children;

 {
   OMuint tmp_count;
    
   status = om$get_channel_count(object = me, p_chanselect = chan, 
  			       count = &tmp_count);
   *count = tmp_count;
   EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);
 }

 if (type & ND_ROOT)
  also_count = 0;
 else
  also_count = 1;

 total_count = *count + also_count;

 if( total_count > MAX_OBJ)
 {
   ptr = om$malloc(size = (total_count)*sizeof(OM_S_OBJECT_LINKAGE));
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
    status = om$get_channel_objects(object = me, 
                                  p_chanselect = chan, 
			          list = link_ptr,
				  size = *count,
				  count = &temp_count);
    EMerr_hndlr (!status, EMmsg, EMS_E_OMerror, wrapup);
  }

  if (also_count)
  {
   status = om$send (msg = message SKconstraint.SKgetmgr(&EMmsg, 
                     &link_ptr[*count].S_objid),
                     targetid = my_id);
   EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);
   link_ptr[*count].osnum = OM_Gw_current_OS;
  }

  start_inx = ifrom > 0 ? ifrom : 0;
  stop_inx = ito   < (total_count) ? ito : total_count-1; 

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
   list_size = new_size - (total_count);

   *count = total_count;

 wrapup : 
     EMWRAPUP (EMmsg, status, "In SKexplicit:NDget_objects error");
     if(ptr != NULL) om$dealloc(ptr = ptr);
     return(status);
}


method NDcompute_node (IGRlong *msg; IGRint cn_type;
                       IGRint count; struct GRid list []; 
                       struct GRmd_env *md_env)
{
  IGRlong stat_OM, msg_loc;
  GRobjid mgrobj;
  
  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * If this expression is being updated, the old value of this dimension
   * needs to be recorded as the save state information in the manager.
   * Also, the sketch needs to be marked as out of date. 
   */

  stat_OM = om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &mgrobj),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message SKmgr.SKsaveolddim (&msg_loc, NULL,
             ME.expression->value, my_id), targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message SKmgr.SKmgrprops (&msg_loc, SK_CHGPROPS_ON,
             SK_MGR_OUTOFDATE, NULL), targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, FALSE, ret_end);

  /*
   * Invoke the expression class's default method 
   */

  stat_OM = om$send (mode = OM_e_wrt_message, 
             msg = message expression.NDcompute_node (&msg_loc, cn_type, count,
             list, md_env), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  if (EMSerror (*msg))
    *msg = ND_COMP_FAIL;
  else
    *msg = ND_COMP_SUCC;

  EMWRAPUP (*msg, stat_OM, "SKexplicit.NDcompute_node");
  return (stat_OM);
}

/*

Name
  NDparent_deleted

Abstract

Synopsis

Description
  My parent is deleted.
Return Value

Notes

Index

Keywords

History
  11/24/93 : G Mallikarjuna : created

 */

method NDparent_deleted ( long *msg; int count_deleted; struct GRid list_deleted [];
                          struct GRid *new_obj; struct GRmd_env *md_env)
{
  IGRlong stat_OM, msg_loc;
  enum GRdpmode mode;
  
  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  
  stat_OM = om$send (mode = OM_e_wrt_message, 
                     msg = message expression.NDparent_deleted(&msg_loc,count_deleted,
                           list_deleted, new_obj, md_env ), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
  mode = GRbd;
  stat_OM = om$send (msg = message NDnode.NDdisplay(NULL,mode,md_env),
                     targetid = my_id);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKexplicit.NDparent_deleted");
  return (stat_OM);
}

end implementation SKexplicit;

