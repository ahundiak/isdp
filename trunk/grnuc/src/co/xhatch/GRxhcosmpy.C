/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRxh_gen_horiz_points

Description
            These routines generate a polyline passing through the specified
        point and tracing back and forth over the specified range box.  The
        polyline segments are all either vertical or horizontal, and are
        separated by the specified distance.

Synopsis
        IGRint GRxh_gen_ _line (msg, delta, origin, range, polyline)

        IGRlong             *msg;       return code
        IGRdouble           *delta;     distance to separate segments
        IGRdouble           *origin;    that the polyline must pass through
        IGRdouble           *range;     to crisscross
        struct IGRpolyline  *polyline;  returned polyline

Note
            The caller is responsible for deallocating the memory allocated
        for the points of the output polyline.

Return Values
        IGRint ()       TRUE - successful
                        FALSE - unsuccessful
        IGRlong msg     MSSUCC - successful completion
                        MANOMEMORY - memory could not be allocated for
                        the points

History
        mrm     11/11/87    creation
	dlw     07/07/88    changed names
*/

#include "coimport.h"
#include "codebug.h"
#include "igrtypedef.h"
#include "igrmacros.h"
#include "igr.h"
#include "maerr.h"
#include "msdef.h"
#include "OMprimitives.h"
/**/
IGRint GRxh_gen_horiz_points (msg, delta, origin, range, offset, polyline)

IGRlong             *msg;       /* return code */
IGRdouble           *delta;     /* distance to separate segments */
IGRdouble           *origin;    /* that the polyline must pass through */
IGRdouble           *range;     /* to crisscross */
IGRdouble            offset;
struct IGRpolyline  *polyline;  /* returned polyline */

{
    IGRint      a, i;       /* just variables */
    IGRpoint    ul;         /* upper left point of the polyline */
    IGRdouble   x;          /* distance from point to point */

    _m_debug(EX_start_timing();)
    *msg = MSSUCC;

   /* get upper left point */
    ul[0] = range[0] + 10;
    ul[1] = origin[1] + 10;
    if (ul[1] < range[4])
    {
        while (ul[1] < range[4]) ul[1] += *delta;
        ul[1] -= *delta;
    }
    else
    {
        while (ul[1] > range[4]) ul[1] -= *delta;
    }
    ul[2] = origin[2];

    /* allocate for points */

    x = ul[1] - range[1];
    polyline->num_points = ((IGRint)(x / *delta) + 1);
    a = (sizeof (IGRpoint)) * (polyline->num_points);
    if ((polyline->points = (IGRdouble *)om$malloc (size = a)) == NULL)
    {
        *msg = MANOMEMORY;
    }
    else
    {
        /* set up first point */
        polyline->points[0] = ul[0];
        polyline->points[1] = ul[1] + offset;
        polyline->points[2] = origin[2];

        /* generate remaining points */
        for (i = 1; i < polyline->num_points; i++)
        {
            polyline->points[i*3] = ul[0];
            polyline->points[(i*3)+1] = 
                      polyline->points[((i-1)*3)+1] - *delta;
            polyline->points[(i*3)+2] = origin[2];
        }
    }

    _m_debug(EX_end_timing("GRxh_gen_horiz_points");)
    return (*msg == MSSUCC);
}



