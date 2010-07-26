/* #######################    APOGEE COMPILED   ######################## */
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


LCevselect (rc, args, user_args)
IGRlong *rc;
struct LC_select_args *args;
IGRchar *user_args;
{
    IGRint ret_code;
    struct LC_sd_evselect *my_args;

    my_args = (struct LC_sd_evselect *) user_args;
    ret_code = (my_args->select_handler) (rc, args, my_args->user_args);
    if (ret_code && *rc == LC_OBJ_LOCATED) {
        (args->accept_event->event.button) = *(my_args->button);
    }
    return (ret_code);
}
