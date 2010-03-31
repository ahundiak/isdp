/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsf_lift;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"

method EMdeactivate (
IGRlong	            *EMmsg;
IGRshort            *option;
struct GRmd_env     *md_env;
GRobjid             **display_ids;
IGRint              *display_count)

/*
    This is a passon message for lift deactivate. It is an interface
    between the internal lift implementation and the outsider.

History	  RC    03/26/88        Creation Date

*/

{
  IGRlong  OM_stat;

OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

OM_stat = om$send (msg = message EMSlift.EMlift_int_deactivate (EMmsg,
                    option, md_env, display_ids, display_count,
                    me->lift_vector, 
                    &me->num_instructions, me->move_info),
                  targetid = my_id);
EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_Fail, wrapup);

wrapup:

EMWRAPUP (*EMmsg, OM_stat, "In EMSsf_lift.EMdeactivate");

return (OM_stat);

}

end implementation EMSsf_lift;

