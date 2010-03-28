/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRangle_grid

Description
        This function generates a grid of points over the range specified
        with respect to the view description and angle input by the caller.

Algorithm
        The range is used to form a cube which is rotated by (-angle) in the
        view described by the wtv matrix.  A new range cube is then
        constructed for the rotated cube and GRapgrid is called to generate
        a vertical/horizontal array of points, which are rotated by angle to
        get the desired grid.  The rotated grid is trimmed to get rid of
        any points generated more than a reasonable distance outside the
        range - reasonable being the greater of the two delta values
        passed in to the function.

Notes
        Currently the grid is trimmed only if the curve is order 2 (polygon).

History
        mrm     09/22/88    creation
        scw     06/28/92    ANSI conversion
*/

#include "grimport.h"
#include "bsvalues.h"
#include <math.h>
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "ma.h"
#include "godef.h"
#include "OMprimitives.h"


#ifndef M_PI
#define M_PI	3.14159265358979323846
#endif


extern IGRboolean MAgrotmx(); 
extern IGRboolean MAtypemx();
extern IGRboolean MAptsxform(); 
extern IGRboolean MAoptsxform(); 
extern IGRboolean MAptinpg();
extern IGRint     GRpagrid();

IGRint GRangle_grid (msg, curve, angle, wtv_mxtype, wtv,
                     vtw_mxtype, vtw, origin, range, dx, dy, first,
                     max_pts, more, npts, pts)

IGRlong                *msg;            /* return code */
IGRdouble               angle;          /* of pattern */
struct IGRbsp_curve    *curve;          /* being patterned */
IGRshort               *wtv_mxtype;     /* matrix type flag */
IGRmatrix               wtv;            /* world to view matrix */
IGRshort               *vtw_mxtype;     /* matrix type flag */
IGRmatrix               vtw;            /* view to world matrix */
IGRpoint                origin;         /* grid origin */
IGRdouble               range[];        /* area for grid (view coords) */
IGRdouble               dx, dy;         /* grid deltas */
IGRboolean              first;          /* TRUE if first pass through */
IGRint                  max_pts;        /* max number of pts returned */
IGRboolean             *more;           /* TRUE if not finished */
IGRlong                *npts;           /* number of points generated */
IGRpoint                pts[];          /* grid points */

{
    IGRshort            mxtype;         /* matrix type */
    IGRshort            rel;            /* point relation to curve */
    IGRint              i, j;           /* index */
    IGRdouble          *cube = NULL;    /* range cube points */
    IGRdouble           ang, neg_ang;   /* rotation angles */
    IGRdouble           two_pi;         /* 2 x PI */
    IGRdouble           tol;            /* for origin inside prism */
    IGRpoint           *opts;           /* either input or allocated pts */
    IGRpoint           *apts = NULL;    /* allocate tmp pts for polygons */
    IGRmatrix           mx;             /* rotation matrix */
    static IGRdouble    rot_range[6];   /* range of rotated range box */

    IGRdouble           temp_vec[3];    
    IGRdouble           temp_origin[3];
    IGRint              temp_cnt=0;

    temp_vec[0] = 0.0;
    temp_vec[1] = 0.0;
    temp_vec[2] = 1.0;    

    temp_cnt = 1;
    if (!(MAoptsxform (msg, &temp_cnt, wtv_mxtype, wtv, origin, temp_origin)))
    {
#ifdef DEBUG
        printf ("GRangle_grid: MAoptsxform failed\n");
#endif
        goto finish;
    }


    

    if (first)
    {
        /*
         *  form a cube from the range
         */

        if (!(cube = (IGRdouble *)om$malloc (size = sizeof (IGRdouble) * 24)))
        {
#ifdef DEBUG
            printf ("GRangle_grid: om$malloc (cube) failed\n");
#endif
            *msg = MANOMEMORY;
            goto finish;
        }

        cube[0] = range[0];         cube[12] = range[0];
        cube[1] = range[1];         cube[13] = range[4];
        cube[2] = range[2];         cube[14] = range[5];
        cube[3] = range[3];         cube[15] = range[0];
        cube[4] = range[1];         cube[16] = range[1];
        cube[5] = range[2];         cube[17] = range[5];
        cube[6] = range[3];         cube[18] = range[3];
        cube[7] = range[4];         cube[19] = range[1];
        cube[8] = range[2];         cube[20] = range[5];
        cube[9] = range[0];         cube[21] = range[3];
        cube[10] = range[4];        cube[22] = range[4];
        cube[11] = range[2];        cube[23] = range[5];



        /*
         *  rotate the cube by the negative of the desired angle
         */

        ang = angle;
        two_pi = 2.0 * M_PI;
        while (ang > two_pi)
        {
            ang -= two_pi;
        }
        neg_ang = 0.0 - ang;

/*        if (!(MAgrotmx (msg, &wtv[8], origin, &neg_ang, mx))) */
        if (!(MAgrotmx (msg, temp_vec, temp_origin, &neg_ang, mx)))
        {
#ifdef DEBUG
            printf ("GRangle_grid: MAgrotmx (neg_ang) failed\n");
#endif
            goto finish;
        }

        i = 8;
        if (!(MAptsxform (msg, &i, mx, cube, cube)))
        {
#ifdef DEBUG
            printf ("GRangle_grid: MAptsxform failed\n");
#endif
            goto finish;
        }

        /*
         *  calculate a new range box
         */

        rot_range[0] = rot_range[1] = rot_range[2] = GRDGNLIMITS_MAX_D;
        rot_range[3] = rot_range[4] = rot_range[5] = GRDGNLIMITS_MIN_D;

        for (i = 0; i < 24; i += 3)
        {
            if (cube[i] < rot_range[0]) rot_range[0] = cube[i];
            if (cube[i + 1] < rot_range[1]) rot_range[1] = cube[i + 1];
            if (cube[i + 2] < rot_range[2]) rot_range[2] = cube[i + 2];
            if (cube[i] > rot_range[3]) rot_range[3] = cube[i];
            if (cube[i + 1] > rot_range[4]) rot_range[4] = cube[i + 1];
            if (cube[i + 2] > rot_range[5]) rot_range[5] = cube[i + 2];
        }

#ifdef DEBUG
        printf ("GRangle_grid: rot_range = %g, %g, %g; %g, %g, %g\n",
                rot_range[0], rot_range[1], rot_range[2],
                rot_range[3], rot_range[4], rot_range[5]);
#endif
    }

    if (curve->order == 2)
    {
        /*
         *  allocate a temporary buffer for the points
         */

        if (!(apts = (IGRpoint *)om$malloc
                     (size = (max_pts * sizeof (IGRpoint)))))
        {
#ifdef DEBUG
            printf ("GRangle_grid: om$malloc (apts) failed\n");
#endif
            *msg = MANOMEMORY;
            goto finish;
        }
        opts = apts;
    }
    else
    {
        opts = pts;
    }

    /*
     *  get points
     */

    if (!(GRapgrid (msg, wtv_mxtype, wtv, vtw_mxtype, vtw, origin, rot_range,
                    dx, dy, first, max_pts, more, npts, opts)))
    {
#ifdef DEBUG
        printf ("GRangle_grid: GRapgrid failed\n");
#endif
        goto finish;
    }

    /*
     *  rotate the points by the desired angle
     */

/*    if (!(MAgrotmx (msg, &wtv[8], origin, &angle, mx))) */
    if (!(MAgrotmx (msg, temp_vec, temp_origin, &angle, mx)))    
    {
#ifdef DEBUG
        printf ("GRangle_grid: MAgrotmx (ang) failed\n");
#endif
        goto finish;
    }

    MAtypemx (msg, mx, &mxtype);

    if (!(MAoptsxform (msg, npts, &mxtype, mx, opts, opts)))
    {
#ifdef DEBUG
        printf ("GRangle_grid: MAoptsxform failed\n");
#endif
        goto finish;
    }


    /*
     * transform the points back to world coordinates.  this used
     * to be done in GRapgrid.
     */
    if (!(MAoptsxform (msg, npts, vtw_mxtype, vtw, opts, opts)))
    {
#ifdef DEBUG
        printf ("GRangle_grid: MAoptsxform failed\n");
#endif   
        goto finish;
    }


    if (curve->order == 2)
    {
        /*
         *  kick out unnecessary points - MAptinpg can only handle polygons
         */

        tol = (dx > dy) ? dx : dy;

        for (i = 0, j = 0; i < *npts; i++)
        {
            if (MAptinpg (msg, opts[i], curve, &tol, &rel))
            {
                if (rel > -1)
                {
                    pts[j][0] = opts[i][0];
                    pts[j][1] = opts[i][1];
                    pts[j++][2] = opts[i][2];
                }
#ifdef DEBUG
                else
                    printf ("GRangle_grid: %d booted\n", i);
#endif
            }
#ifdef DEBUG
            else
                printf ("GRangle_grid: MAptinpg failed\n");
#endif
        }
        *npts = j;
    }

finish:

    if (cube) om$dealloc (ptr = cube);
    if (apts) om$dealloc (ptr = apts);

#ifdef DEBUG
    if (!(*msg & 1)) printf ("GRangle_grid: msg = %#x\n", *msg);
#endif

    return (*msg & 1);
}
