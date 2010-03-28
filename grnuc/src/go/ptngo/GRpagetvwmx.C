/* #######################    APOGEE COMPILED   ######################## */



/*
Name
        GRptngetvwmx

Description
        This function returns the world to view rotation matrix for
        the last point entered in the dpb.  Optionally it also returns the
        view to world rotation matrix and the matrix types for both the
        matrices.

Synopsis
        IGRint GRptngetvwmx (msg, wtv, wtv_type, vtw, vtw_type)

        IGRlong             *msg;       return code
        IGRdouble           *wtv;       world to view rotation matrix
        IGRshort            *wtv_type;  wtv matrix type
        IGRdouble           *vtw;       view to world rotation matrix
        IGRshort            *vtw_type;  vtw matrix type

Notes
        The world to view matrix is always returned, if possible.  The
        view to world matrix, world to view matrix type, and view to world
        matrix type will be returned only if the pointers passed in are
        not NULL.

Return Codes
        IGRint ()       TRUE if successful
                        FALSE if unsuccessful
        IGRlong msg     MSSUCC if successful

History
        mrm     11/25/87    creation
        scw     06/28/92    ANSI conversion
*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "ex.h"
#include "msdef.h"

extern IGRboolean MAinvmx();
extern IGRboolean MAtypemx();

IGRint GRpagetvwmx (msg, wtv, wtv_type, vtw, vtw_type)

IGRlong             *msg;       /* return code */
IGRdouble           *wtv;       /* world to view rotation matrix */
IGRshort            *wtv_type;  /* wtv matrix type */
IGRdouble           *vtw;       /* view to world rotation matrix */
IGRshort            *vtw_type;  /* vtw matrix type */

{
    IGRboolean          bsts;           /* return code */
    IGRint              i;              /* index */
    IGRlong             sts;            /* return code */
    IGRlong             error;          /* return code */
    struct EX_button    last_point;     /* from dpb */
    struct var_list     var_list[2];    /* for gragad inquiry */

    sts = TRUE;
    bsts = TRUE;
    *msg = MSSUCC;

    /*
     *  get the world-to-view rotation matrix from the dpb's last point
     */

    i = sizeof (last_point);
    sts = gr$get_last_point (msg = msg,
                             sizbuf = &i,
                             buffer = &last_point,
                             nret = &i);

    if (!(sts & *msg & 1)) goto finish;

    var_list[0].var = WLD_TO_VIEW;
    var_list[0].var_ptr = (IGRchar *)wtv;
    var_list[0].num_bytes = sizeof (IGRmatrix);
    var_list[0].bytes_returned = (IGRlong *)&i;
    var_list[1].var = END_PARAM;

    sts = dp$inq_set_gragad (msg = msg,
                             osnum = last_point.osnum,
                             gragad_objid = last_point.objid,
                             which_error = &error,
                             var_list = var_list);

    if (!(sts & *msg & 1))  goto finish;

    if (wtv_type)
    {
        bsts = MAtypemx (msg, wtv, wtv_type);
        if (!(bsts & *msg & 1)) goto finish;
    }

    if (vtw)
    {
	IGRshort ii = 4;
        bsts = MAinvmx (msg, &ii, wtv, vtw);
        if (!(bsts & *msg & 1)) goto finish;
    }

    if (vtw_type)
    {
        bsts = MAtypemx (msg, vtw, vtw_type);
        if (!(bsts & *msg & 1)) goto finish;
    }

finish:

    return (sts & bsts & *msg & 1);
}
