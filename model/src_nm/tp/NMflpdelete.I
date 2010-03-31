/*
Delete only if sender_id is creator id;
*/
class implementation NMfeaturelp;

#include "OMmacros.h"

method delete(int defer_flag)
{
 IGRlong	sts = OM_S_SUCCESS;

 if(IF_EQ_OBJID(ME.EMSboundary->creator_id, sender_id))
  sts = om$send(mode = OM_e_wrt_message, msg = message EMSloop.delete
        (defer_flag), targetid = my_id);

return(sts);
}
end implementation NMfeaturelp;
