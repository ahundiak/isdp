/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRepudir

Description
        This edge patterning function accepts the start, end, and direction
        points of a curve and determines whether the pattern direction is in
        ascending or descending u-parameter order.

Algorithm
        If the curve is open, the start and end u-parameters are compared
        to determine direction.  For closed curves, the start, direction,
        end, and u = 0.0 parameters are compared.  There are six unique
        orderings possible for these four values on closed curves.
        They are:

                1)  zero - start - direction - end      (ascending)
                2)  zero - direction - end - start      (ascending)
                3)  zero - end - start - direction      (ascending)
                4)  zero - start - end - direction      (descending)
                5)  zero - direction - start - end      (descending)
                6)  zero - end - direction - start      (descending)

Synopsis
        IGRint GRepudir (msg, curve, start, dir, end, ascending)

        IGRlong                 *msg;           o return code
        struct IGRbsp_curve     *curve;         i curve to pattern
        struct GRparms          *start;         i start parameter
        struct GRparms          *dir;           i direction parameter
        struct GRparms          *end;           i stop parameter
        IGRshort                *ascending;     o flag indicating direction

Return Values
        on success, () == TRUE, *msg == MSSUCC, *ascending indicates direction;
        on failure, () == FALSE, *msg == MSFAIL, *ascending == -1

History
        mrm     05/25/88    creation
        scw     06/28/92    ANSI conversion
*/

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"

IGRint GRepudir (msg, curve, start, dir, end, ascending)

IGRlong                 *msg;           /* o return code */
struct IGRbsp_curve     *curve;         /* i curve to pattern */
struct GRparms          *start;         /* i start parameter */
struct GRparms          *dir;           /* i direction parameter */
struct GRparms          *end;           /* i stop parameter */
IGRshort                *ascending;     /* o flag indicating direction */

{
    IGRdouble           z, s, d, e;     /* zero, start, direction, & end u */

    *msg = MSSUCC;

    if (!curve->phy_closed)
    {
        *ascending = (start->u <= end->u);
    }
    else
    {
        z = 0.0;
        s = start->u;
        d = dir->u;
        e = end->u;

        if ((z <= s && s <= d && d <= e) ||
            (z <= d && d <= e && e <= s) ||
            (z <= e && e <= s && s <= d))
        {
            *ascending = TRUE;
        }
        else if ((z <= s && s <= e && e <= d) ||
                 (z <= d && d <= s && s <= e) ||
                 (z <= e && e <= d && d <= s))
        {
            *ascending = FALSE;
        }
        else
        {
            *ascending = -1;
            *msg = MSFAIL;
        }
    }

#ifdef DEBUG
    printf ("GRepudir: ascending = %d\n", *ascending);
#endif

    return (*msg == MSSUCC);
}
