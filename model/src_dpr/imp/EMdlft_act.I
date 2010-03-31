/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdlift;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"

method EMactivate (
IGRlong             *EMmsg;
IGRshort            *option;
struct GRmd_env     *md_env;
GRobjid             **display_ids;
IGRint              *display_count)

/*
    This is a passon message for lift activate. It is an interface
    between the internal lift implementation and the outsider.

    History  RC    04/26/88      Creation Date

*/

{
IGRlong      OM_stat;

OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

OM_stat = om$send (msg = message EMSlift.EMlift_int_activate (EMmsg,
                    option, md_env, display_ids, display_count,
                    NULL, NULL, NULL),
                  targetid = my_id);
EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_Fail, wrapup);

wrapup:

EMWRAPUP (*EMmsg, OM_stat, "In EMSsfdlift.EMactivate");

return (OM_stat);

}

end implementation EMSsfdlift;

