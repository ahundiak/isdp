class implementation NMtrim;

#include "EMSopt.h"

method NDmove_to_root (IGRlong *EMmsg; struct GRid *src_grid;
			  struct GRmd_env *md_env)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRushort 	undo_opt = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
 IGRint 		buff_size = 0, display_count = 0, 
			invoke_count = 0;
 GRobjid 		*display_ids = NULL;

 *EMmsg = EMS_S_Success;

 sts = om$send(msg = message EMSdpr.EMundo
       (EMmsg, &undo_opt, md_env, NULL, NULL, &buff_size, &display_ids, 
       &display_count, &invoke_count), 
       targetid = my_id);

EMWRAPUP(*EMmsg, sts, "In NMtrim.NDmove_to_root");
return(sts);
}

end implementation NMtrim;
