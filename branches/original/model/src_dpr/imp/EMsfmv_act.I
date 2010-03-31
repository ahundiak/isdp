/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

#include "EMS.h"
#include "emsmacros.h"
#include "OMmacros.h"

method EMactivate (IGRlong *EMmsg;
                   IGRshort *option;
                   struct GRmd_env *my_env;
                   GRobjid **display_ids;
                   IGRint *display_count)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	05/04/87:	design date

Algorithm

      Execute the instruction table by input vector.
*/

{
 IGRpoint       from_pt, to_pt;
 IGRlong 	stat_OM, msg;

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 /*Since the move_execute method changes the instance data, it
  * cannot be passed in so it is first copied.
  */
 OM_BLOCK_MOVE(ME.EMSsfmove->from_point, from_pt, sizeof(IGRpoint));
 OM_BLOCK_MOVE(ME.EMSsfmove->to_point, to_pt, sizeof(IGRpoint));

 stat_OM = om$send (msg = message EMSsfmove.EMmove_execute (&msg,
                          to_pt, from_pt, my_env, option,
                          display_ids, display_count),
                    targetid = my_id);
 EMomerr_hndlr(stat_OM, wrapup, "EMsfmv_act.EMactivate");
 EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

 wrapup:

  return(stat_OM);

}
end implementation EMSsfmove;
