class implementation COplfence;



#include "coimport.h"
#include "grgsmacros.h"
#include "lcmacros.h"
#include "grdpbmacros.h"

from GRvg import GRchgstyle;



method construct_object ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRuchar style;
    IGRint               count;
    OM_S_OBJECT_LINKAGE  list;
    struct GRid          fence_id;

    me->ret = MSSUCC;

    status = om$send(mode = OM_e_wrt_message,
                     msg = message COnpt.construct_object (sts),
                     targetid = my_id);

    me->window_id.objid = me->first_event.event.button.objid;
    me->window_id.osnum = me->first_event.event.button.osnum;

    status = lc$get_channel_objects(p_chanselect = &me->const_chansel,
                                    list = &list, size = 1, count = &count);

    if (count)
    {
        fence_id.osnum = list.osnum;
        fence_id.objid = list.S_objid;

        /* Let the fence have a different style */
  
        style = 4;
        status = om$send(msg = message GRvg.GRchgstyle((IGRlong *)sts, &style),
                         targetid = fence_id.objid,
                         targetos = fence_id.osnum);

        status = gr$gsput_fence(msg = (IGRlong *)sts,
                                mod_env = &me->ModuleInfo,
                                fence_id = &fence_id,
                                window_id = &me->window_id);
    }
    else  /* a fence object was not successfully constructed */
        me->ret = MSFAIL;
quit:
  return OM_S_SUCCESS;
}

method clear_fill_mode ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong                nbytes_in_buffer;
    IGRlong                nbytes_transferred;

    nbytes_in_buffer = sizeof(me->properties);

    gr$get_active_prop(msg = &me->ret,
                       sizbuf = &nbytes_in_buffer,
                       buffer = &me->properties,
                       nret = &nbytes_transferred);

    if (me->properties & GRFILLED_DISPLAY)
    {
        me->properties &= ~GRFILLED_DISPLAY;

        gr$put_active_prop(msg = &me->ret,
                           sizbuf = &nbytes_in_buffer,
                           buffer = &me->properties);

        me->properties |= GRFILLED_DISPLAY;
    }
quit:
  return OM_S_SUCCESS;
}

method restore_fill_mode ()
{
  int		  status = OM_S_SUCCESS;

    if (me->properties & GRFILLED_DISPLAY)
    {
        IGRlong                nbytes_in_buffer;

        nbytes_in_buffer = sizeof(me->properties);

        gr$put_active_prop(msg = &me->ret,
                           sizbuf = &nbytes_in_buffer,
                           buffer = &me->properties);
    }
quit:
  return OM_S_SUCCESS;
}

end implementation COplfence;
