class implementation SKgeometry;

/*
   HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "nddef.h"
#include "ndmacros.h"
#include "msdef.h"
#include "SKdef.h"
#include "SKinc.h"
#include <stdio.h>
#include "parametric.h"
#include "EMSas.h"
#include "maidmx.h"


#define MAX_OBJ 10

from GRbspline import GRxform;
from SKmgr import SKreturn_yourself, SKgetornt;

extern OMuword OPP_SKcompcurve_class_id;

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
   status = om$send(msg = message GRcurve.GRdisplay(&EMmsg,
        		    &mat_type,mat,&mode,&mod_grid),
                    targetid = my_id);
   EMerr_hndlr (!(1&status&EMmsg), EMmsg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (EMmsg, status, "In SKgeometry:NDdisplay error");
 return(status);
}

method NDupdate(IGRint *EMmsg;
                IGRint cn_type;
                IGRint count;
	        struct GRid *list;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
{
  *EMmsg = ND_COMP_SUCC;
  new_objid->objid = my_id;
  new_objid->osnum = OM_Gw_current_OS;
  return (OM_S_SUCCESS);
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
 OM_S_CHANSELECT *chan,*chan1 = 0,father, children,to_components,to_owners;
 IGRint i,start_inx,stop_inx;
 OMuint temp_count=0,also_count = 0,total_count = 0;
 IGRchar *ptr = NULL;

 status = OM_S_SUCCESS;
 EMmsg = EMS_S_Success;


 status = om$make_chanselect (channame = "NDfather.father",
                              p_chanselect = &father);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect (channame = "NDchildren.children",
                              p_chanselect = &children);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_components);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect(channame = "GRconnector.to_owners",
                             p_chanselect = &to_owners);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 if( type & ND_ROOT) 
    chan = &father;
 else
    chan = &children;

 if (type & ND_ROOT)
  chan1 = &to_owners;
 else
 {
  OMuword my_classid;

  status = om$get_classid (objid = my_id,
                           p_classid = &my_classid);
  EMerr_hndlr(!(1&status), EMmsg, EMS_E_OMerror, wrapup);

  status = om$is_ancestry_valid(subclassid = my_classid,
                                superclassid = OPP_SKcompcurve_class_id);
  if (status == OM_S_SUCCESS)
   chan1 = &to_components;
  else if (status == OM_I_INVANCESTRY)
  {
   chan1 = NULL;
   status = OM_S_SUCCESS;
  }
  EMerr_hndlr(!(1&status), EMmsg, EMS_E_OMerror, wrapup);
 }

 {
   OMuint tmp_count;
   
   status = om$get_channel_count(object = me, p_chanselect = chan, 
			       count = &tmp_count);
   *count = tmp_count;
   EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);
 }

 if (chan1)
 {
 status = om$get_channel_count(object = me, p_chanselect = chan1,
			       count = &also_count);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);
 }
 else also_count = 0;

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
  status = om$get_channel_objects(object = me, 
                                  p_chanselect = chan1, 
			          list = &link_ptr[*count],
				  size = also_count,
				  count = &temp_count);
  EMerr_hndlr (!status, EMmsg, EMS_E_OMerror, wrapup);
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
      grid_ptr = (struct GRid*) my_buffer_addr;
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
     EMWRAPUP (EMmsg, status, "In SKgeometry:NDget_objects error");
     if(ptr != NULL) om$dealloc(ptr = ptr);
     return(status);
}

method ASreturn_go(struct GRid *go;IGRshort *mat_type;IGRdouble *matrix)
{
 IGRlong EMmsg;

 if (mat_type && matrix)
   {
   *mat_type = MAIDMX;
   MAidmx(&EMmsg,matrix);
   }

 go->objid = my_id;
 go->osnum = OM_Gw_current_OS;

 return (OM_S_SUCCESS);
}

method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                         struct GRmd_env *md_env )
{
  IGRlong stat_func, stat_OM;

  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;

  str->type = curve_generic;
  stat_func = ASgo_give_structure (my_id, OM_Gw_current_OS, md_env ,str);
  if (EMSerror (stat_func))
    stat_OM = OM_E_ABORT;

  return (stat_OM);
}

method NDmake_source(IGRlong *msg;
			struct GRid *located_obj,*context;char *path;
			GRspacenum as_osnum; struct GRid *as)
{
 IGRlong sts, loc_msg;

 *msg = EMS_S_Success;
 sts = loc_msg = OM_S_SUCCESS;

 as->objid = NULL_OBJID;

 if (context->objid != NULL_OBJID)
 {
  sts = ASmake_source_from_go(&loc_msg, located_obj,context,
                                 as_osnum, as);
  if (!(1&sts&loc_msg)) *msg = MSFAIL;
 }
 else
  *as = *located_obj;

 return (OM_S_SUCCESS);
}

method GRmksource ( long *msg; struct GRid *context; GRspacenum target_os;
		    struct GRid *source; int option )
{
  struct GRid my_grid;
  
  my_grid.osnum = OM_Gw_current_OS;
  my_grid.objid = my_id;
  om$send ( msg = message NDnode.NDmake_source ( msg, &my_grid, context, NULL, 
      target_os, source ), targetid = my_id );

  return OM_S_SUCCESS;  
}

end implementation SKgeometry;

