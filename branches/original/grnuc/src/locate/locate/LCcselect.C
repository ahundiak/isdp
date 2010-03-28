/* #######################    APOGEE COMPILED   ######################## */


/*
Name
        LCcselect

Description
        This function, called when objects eligible for locate are in the
        stack, checks whether an accept/reject cycle has been requested
        and calls the appropriate select handler.

Return Values
        IGRint ()       0 - error or no objects accepted
                        1 - objects accepted or in stack
        IGRlong *rc     see lcdef.h for values
                        LC_NO_OBJ_LOCATED
                        LC_OBJ_LOCATED
                        LC_OBJS_IN_STACK
                        LC_RELOCATE
                        LC_UNKNOWN_TYPE
                        LC_BACKUP             

History
	rc      07/20/87    Started documentation
	        08/25/87    Modified for locate stack of one
        mrm     11/14/89    Changed to always call LCselect
        scw     07/13/92    Ansi conversion
*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "lcpriv.h"

extern IGRint LCselect ();

IGRint LCcselect (rc, args)
IGRlong *rc;
struct LC_select_args *args;
{
    IGRint sts = 1;

    *rc = 1;

    /*
     *	Check to see if the accept and reject cycle should be done.
     */

    args->scale_flag = 0;

    if (args->display_flag & NO_ACC_REJ_CYCLE)
    {
        *rc = LC_OBJS_IN_STACK;
        sts = 1;
    }
    else
    {
        sts = LCselect (rc, &args->eventmask, args->eventsize, 
                        &args->display_flag, args->is_bore, args->response, 
                        args->response_data, args->accept_event, 
                        args->acc_event1, args->obj_hilighted, args->stack, 
                        args->dyn, args->acc_prompt, args->mode,
                        args->hilight_mode, args->acc_key, args->nbytes,
                        args->value_type, args->scale_flag);

        sts = (sts) ? 1 : 0;
    }

    return (sts);
}
