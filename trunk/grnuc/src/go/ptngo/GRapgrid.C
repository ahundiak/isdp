/*
Name
        GRapgrid

Description
        This function generates a grid of points dx, dy apart over the
        specified range.  The function will return at most max_pts per
        call, but may be called repeatedly to completely cover the desired
        area.

History
        sdm     03/01/87    creation
        mrm     09/19/88    rework, check for "infinite" deltas
        scw     06/28/92    ANSI conversion
*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "ma.h"
#include "godef.h"

extern IGRboolean MAoptsxform();

#argsused
IGRint GRapgrid (msg, wtv_mxtype, wtv, vtw_mxtype, vtw,
                 origin, range, dx, dy, first, max_pts, more, npts, pts)

IGRlong     *msg;           /* O return code */
IGRshort    *wtv_mxtype;    /* I matrix type flag */
IGRmatrix   wtv;            /* I world to view matrix */
IGRshort    *vtw_mxtype;    /* I matrix type flag */
IGRmatrix   vtw;            /* I view to world matrix */
IGRpoint    origin;         /* I grid origin */
IGRdouble   range[];        /* I area for grid (view coords) */
IGRdouble   dx, dy;         /* I grid deltas */
IGRboolean  first;          /* I TRUE if first pass through */
IGRint      max_pts;        /* I max number of pts returned */
IGRboolean  *more;          /* O TRUE if not finished */
IGRlong     *npts;          /* O number of points generated */
IGRpoint    pts[];          /* O grid points */

{
    IGRlong              i, j;               /* integer variables */
    IGRdouble           maxdelta;           /* signifies infinite delta */
    IGRdouble           ystart;             /* grid origin */
    IGRpoint            local_origin;       /* input origin in local coords */
    static IGRint       pts_generated;      /* total through repeated calls */
    static IGRint       numx, numy;         /* grid dimensions */
    static IGRint       row;                /* row index */
    static IGRdouble    xstart;             /* grid origin */
    static IGRdouble    x, y, z;            /* grid points */

    if (dx <= 0.0 || dy <= 0.0)
    {
        *msg = MSINARG;
    }
    else
    {
        *msg = MSSUCC;

        if (first)
        {
            /* initialize xstart & ystart   */

            i = 1;
            MAoptsxform (msg, &i, wtv_mxtype, wtv, origin, local_origin);

            maxdelta = 2 * GRDGNLIMITS_MAX_D;

            if (dx >= maxdelta)
            {
                xstart = local_origin[0];
                numx = 1;
            }
            else
            {
                i = ((local_origin[0] - range[0]) / dx) + 1;
                xstart = local_origin[0] - (i * dx);
                numx = (MAabsolute (xstart - range[3]) / dx) + 2;
            }

            if (dy >= maxdelta)
            {
                ystart = y = local_origin[1];
                numy = 1;
            }
            else
            {
                i = ((local_origin[1] - range[1]) / dy) + 1;
                ystart = y = local_origin[1] - (i * dy);
                numy = (MAabsolute (ystart - range[4]) / dy) + 2;
            }

            z = local_origin[2];
            pts_generated = 0;
            row = 0;

#ifdef DEBUG
            printf ("GRapgrid: numx = %d, numy = %d\n", numx, numy);
            printf ("GRapgrid: xstart = %g, ystart = %g\n", xstart, ystart);
#endif
        }
            
        for (i = row, *npts = 0;
             (i < numy) && ((*npts + numx) <= max_pts);
             i++, y += dy, row++)
        {
            for (j = 0, x = xstart; j < numx; j++, x += dx, (*npts)++)
            {
                pts[*npts][0] = x;
                pts[*npts][1] = y;
                pts[*npts][2] = z;
            }
        }

        pts_generated += *npts;
        *more = (i < numy);

        /*
         *  transform points back to world cordinates

  ***   don't do this here anymore, the caller should do this ****
        MAoptsxform (msg, npts, vtw_mxtype, vtw, pts, pts);
         */
    }


    return (*msg & 1);
}
