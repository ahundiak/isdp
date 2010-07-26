/* #######################    APOGEE COMPILED   ######################## */

/*
Abstract
	This function will send an end transition to the graphics set.
	This means that the current context will have no more elments
	added to it.

	It is called from LCnmlocate (a routine to handle locate by name).

Notes

History
	7/30/87	Creation Date.
  scw  07/13/92 Ansi conversion
*/
class implementation Root;



#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "grgsmacros.h"
#include "igr.h"
#include "exdef.h"
#include "ex.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"

from GRgrset import GSend_transition;

LCgsend (gs_id, mod, stack)
struct GRid     *gs_id;
struct GRmd_env *mod;
struct GRlc_stack *stack;
{
    IGRlong sts, msg;
    IGRint ret_code = 0;

/*
 *	Tell the grset to end the transition.
 */

    sts = om$send (msg = message GRgrset.GSend_transition (&msg, NULL),
                   senderid = NULL_OBJID,
                   targetid = gs_id->objid,
                   targetos = gs_id->osnum);
    if (!(1&sts)) {
        om$report_error (sts = sts);
        goto WRAP;
    }

/*
 *	Post the grapics set as the most recently used select set.
 */

    sts = gr$gsput_select_set (msg = &msg, mod_env = mod,
                               select_set_id = gs_id);
    if (!(1&sts)) {
        goto WRAP;
    }

    /*
     *	Set up information for accept/reject cycle
     */

    stack->entry[0].located_obj = *gs_id;
    stack->entry[0].module_info = *mod;
    stack->module = mod->md_id;
    stack->num_entries = 1;

    ret_code = 1;
WRAP:
    return (ret_code);
}

end implementation Root;
