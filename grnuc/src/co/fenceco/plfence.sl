/*\
Description
   This class is used to place fence graphics objects.  The commands
   must supply class specific attributes to the fence object at 
   construction time.

   This class has Transactions files for the following commands:
      PLACE RECTANGULAR FENCE
      PLACE POLYGONAL FENCE 

History
   Gray Winn    05/18/87    Creation date.
   mrm          06/25/91    change fence line style
   scw          07/10/92    ansi conversion
   WBC          10/14/93    Changing the construct_object action to check to
                            make sure an object was successfully constructed
                            before proceeding (for NAVSEA Log# 3662324).
\*/

class           COplfence
super_class     COnpt
spec_path       "$grnuc/co/spec"
start_state     terminate
product_name    "$SOURCE"
options         "SItc"

state_table
#include "coniindex.h"

specification

instance 
{
   struct GRid         window_id;
   IGRushort   properties;
}

implementation

#include "coimport.h"
#include "grgsmacros.h"
#include "lcmacros.h"
#include "grdpbmacros.h"

from GRvg import GRchgstyle;

action construct_object
{
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
}

/*\
Description
   This action checks to see if the GRFILLED_DISPLAY is set in the dpb and if
   it is, clears the bit and sets me->fillmode on to TRUE.  This is needed so
   fences won't be filled.
\*/

action clear_fill_mode ()
{
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
}

/*\
Description
   This action checks to see if the GRFILLED_DISPLAY is set in the properties
   instance data and if it is, it updates the dpb with the properties.
   The action clear_fill_mode should be called sometime before this action.
\*/

action restore_fill_mode ()
{
    if (me->properties & GRFILLED_DISPLAY)
    {
        IGRlong                nbytes_in_buffer;

        nbytes_in_buffer = sizeof(me->properties);

        gr$put_active_prop(msg = &me->ret,
                           sizbuf = &nbytes_in_buffer,
                           buffer = &me->properties);
    }
}
