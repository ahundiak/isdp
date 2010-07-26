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

class implementation GRedgeptn;

#include "grimport.h"
#include "msdef.h"
#include "igrdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grptn.h"

method GRconstruct (struct GRvg_construct *const_args)
{
    IGRint                  i;          /* index */
    IGRlong                 sts;        /* return code */
    struct GRpaconstruct   *pa;         /* construction parameters */
    struct GRepconstruct   *ep;         /* edge ptn constr parameters */

    *const_args->msg = MSSUCC;
    pa = (struct GRpaconstruct *) const_args->class_attr;
    ep = (struct GRepconstruct *) pa->class_spec;

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

    for (i = 0; i < 3; i++)
    {
        me->dir_pt[i] = ep->dir_pt[i];
        me->stop_pt[i] = ep->stop_pt[i];
    }

finish:

#ifdef DEBUG
    if (!(sts & *const_args->msg & 1))
    {
        printf ("GRedgeptn.GRconstruct failed\n");
        printf ("const_args->msg = 0X%X\n", *const_args->msg);
        om$report_error (sts = sts);
    }
#endif

    return (sts);
}
end implementation GRedgeptn;
