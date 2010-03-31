class implementation SKvalvar;

#include "DItypedef.h"
#include "DIdef.h" 
#include "DIglob.h" 
#include "DIprims.h"

#define NUM_STATIC_OBJS  10

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from FIdirform import update;

method NDupdate(IGRint *msg;
                IGRint cn_type;
                IGRint parent_count;
	        struct GRid *parents;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
{
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  new_objid->objid = my_id;
  new_objid->osnum = OM_Gw_current_OS;

  EMerr_hndlr (ME.SKvariable->props & SK_VAR_READEXPR, *msg, EMS_E_InvalidCase,
   ret_end);
  EMerr_hndlr (parent_count != 1 || !parents, *msg, EMS_E_InvalidArg,
   ret_end);

ret_end:
 if (1&stat_OM&*msg)
  *msg = ND_COMP_SUCC;
 else
  *msg = ND_COMP_FAIL;
  EMWRAPUP (*msg, stat_OM, "SKvalvar.NDupdate");
  return (stat_OM);
}


method NDget_objects (IGRint type; struct GRid *list; IGRint size; 
                      struct GRid **buffer; IGRint ifrom; IGRint ito;
                      IGRint *count)
{
  static IGRchar *my_buffer_addr = NULL;
  static IGRint my_buffer_size = 0;
  IGRint i, new_size, start_inx, stop_inx;
  OMuint tmp_count;
  IGRlong stat_OM, msg_loc;
  OM_S_OBJECT_LINKAGE objlist_mem[NUM_STATIC_OBJS], *objlist = NULL;
  OM_S_CHANSELECT chan_to_objs;
  struct GRid *grid_ptr;

  msg_loc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the dependent or the parent objects
   */

  if (type & ND_ROOT)
    om$make_chanselect(channame = "SKvariable.to_mgr",
     p_chanselect = &chan_to_objs);
  else
    om$make_chanselect (channame = "NDchildren.children",
     p_chanselect = &chan_to_objs);

  stat_OM = om$get_channel_count (object = me, p_chanselect = &chan_to_objs, 
             count = &tmp_count);
  *count = tmp_count;
  EMomerr_exit (stat_OM, ret_end);

  if (*count > NUM_STATIC_OBJS)
    objlist = (OM_S_OBJECT_LINKAGE *) om$malloc (
               size = *count * sizeof (OM_S_OBJECT_LINKAGE));
  else
    objlist = objlist_mem;
  EMerr_hndlr (!objlist, msg_loc, EMS_E_NoDynamicMemory, ret_end);

  stat_OM = om$get_channel_objects (object = me,
             p_chanselect = &chan_to_objs, list = objlist, size = *count,
             count = &tmp_count);
  *count = tmp_count;
  EMomerr_exit (stat_OM, ret_end);

  /*
   * Format these into the output
   */

  start_inx = ifrom > 0 ? ifrom : 0;
  stop_inx = ito < *count ? ito : *count - 1; 
  new_size = stop_inx - start_inx + 1;

  if (type & ND_IN_BUF)
    { 
    if (new_size > my_buffer_size)
      {
      if (my_buffer_addr)
        my_buffer_addr = om$realloc (ptr = my_buffer_addr, size = new_size *
                          sizeof (struct GRid));
      else
        my_buffer_addr = om$malloc (size = new_size * sizeof (struct GRid));
      EMerr_hndlr (!my_buffer_addr, msg_loc, EMS_E_NoDynamicMemory, ret_end);
      my_buffer_size = new_size;
      }
    *buffer = (struct GRid *) my_buffer_addr;
    grid_ptr = (struct GRid *) my_buffer_addr;
    }
  else
    {
     if (new_size > size)
      goto ret_end;
     grid_ptr = list;
    }

  for (i=start_inx;i<=stop_inx; i++)
    {
    grid_ptr->objid = objlist[i].S_objid;
    grid_ptr->osnum = objlist[i].osnum;
    ++grid_ptr;
    }

ret_end:
  if (objlist && objlist != objlist_mem)
    om$dealloc (ptr = objlist);

  EMWRAPUP (msg_loc, stat_OM, "SKgeometry.NDget_objects");
  return (stat_OM);
}

end implementation SKvalvar;

