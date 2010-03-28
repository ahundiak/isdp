/*
Name
        COputset

Description
        This function deposits the specified graphic set on the software
        event queue.

History
        mrm     01/14/91    creation
        scw     07/10/92    ansi conversion
*/

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "gr.h"
#include "igrdp.h" 
#include "dp.h" 
#include "godef.h"
#include "go.h" 
#include "griodef.h"
#include "grio.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

IGRint COputset (msg, set, mod, window_id, window_os)
IGRint *msg;
OM_S_OBJID set;
struct GRmd_env *mod;
OM_S_OBJID window_id;
OMuword window_os;
{
    IGRint  response;
    IGRlong size;
    struct GRevent event;

    /* fill in dummy info from lastpoint */

    gr$get_last_point (buffer = &event.event.button);

    if (window_id != NULL_OBJID)
    {
        event.event.button.objid = window_id;
        event.event.button.osnum = window_os;
    }

    /* insert graphic set information into the event */

    event.num_id = 1;
    event.located_object[0].located_obj.objid = set;
    event.located_object[0].located_obj.osnum = mod->md_id.osnum;
    event.located_object[0].module_info = *mod;

    /* push the event on the queue */

    size = sizeof (struct GRevent) - (2 * sizeof (IGRlong));
    response = EX_OBJID;

    ex$putque(msg = (IGRlong *)msg,
              response = &response,
              byte = &size,
              buffer = (IGRchar *)&event.event.button);

    return (*msg & 1);
}
