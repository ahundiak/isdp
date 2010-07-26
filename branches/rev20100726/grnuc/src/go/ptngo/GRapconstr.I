/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRareaptn.GRconstruct

Description
        This method sends the construct message to its parent
        class (GRpa), then initializes the instance data for this class.

History
        sdm     04/01/87    creation
        mrm     11/30/87    use parent's message
        scw     06/28/92    ANSI conversion
*/

class implementation GRareaptn;

#include "grimport.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grptn.h"
#include "msdef.h"

method GRconstruct (struct GRvg_construct *const_args)
{
    IGRlong                 sts;        /* return code */
    struct GRpaconstruct   *pa;         /* construction parameters */
    struct GRapconstruct   *ap;         /* area ptn constr parameters */

    *const_args->msg = MSSUCC;
    pa = (struct GRpaconstruct *) const_args->class_attr;
    ap = (struct GRapconstruct *) pa->class_spec;

    /*
     *  use parent's method
     */

    sts = om$send (mode = OM_e_wrt_message,
                   msg = message GRpa.GRconstruct (const_args),
                   targetid = my_id);

    if (!(sts & *const_args->msg & 1)) goto finish;

    /*
     *  fill in instance data
     */

    me->dy = ap->dy;

finish:

#ifdef DEBUG
    if (!(sts & *const_args->msg & 1)) 
    {
        printf ("GRareaptn.GRconstruct failed\n");
        printf ("const_args->msg = 0X%X\n", *const_args->msg);
        om$report_error (sts = sts);
    }
#endif

    return (sts);
}
end implementation GRareaptn;
