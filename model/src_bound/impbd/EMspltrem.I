/* ###################   APOGEE COMPILED   ################## */
/*
	SM	24-Aug-89	Creation.
*/
class implementation EMSsplit;
#include "EMS.h"
#include "emsdef.h"

method EMremove(IGRlong *EMmsg; IGRushort option)
{
 IGRlong		sts = OM_S_SUCCESS;
 OM_S_CHANSELECT	to_ed;
 OMuint			attatched = 0;

 *EMmsg = EMS_S_Success;
 EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);
 sts = om$get_channel_count(object = me, p_chanselect = &to_ed, 
			    count = &attatched);
 if( (1&sts) && !attatched)
  sts = om$send(msg = message Root.delete(TRUE), targetid = my_id);

return(OM_S_SUCCESS);
}

end implementation EMSsplit;
