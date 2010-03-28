/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRbuild_cvprism

Description
        This function builds a curve clipping prism for area patterning,
        using the curve being patterned, the world-to-view and view-to-world
        transformation matrices of the view the pattern is to appear in, the
        origin of the pattern, and the extents of the symbol making up the
        pattern.  The height of the prism will be the height of the symbol.

Notes
        This routine does NOT allocate memory for the poles, etc, of the
        prism curve.  The memory pointed to by the input curve is also used
        by the prism, so the input curve is not valid upon exit.

Algorithm
        The components of the prism are generated as described below:

        prism.matrix    The matrix is set up as a local to world
                        transformation using the transpose of the rotation
                        contained in the world-to-view matrix, but using the
                        input prism origin as the local origin.  Because
                        of problems with the range check routines used in
                        clip, the origin actually used is projected back into
                        the view so that the pattern will not lie in the same
                        plane as the back face of the prism.

        prism.curve     The curve is identical to the input curve with the
                        exception that the poles of the curve are transformed
                        to the local coordinate system of the prism.  As noted,
                        the memory used by the input curve is also used by
                        the prism curve, so the input curve is invalidated.

        prism.height    Ideally, the height should be the same as the height
                        of the symbol used in the pattern, but problems with
                        the range check and clip routines have been avoided
                        by adding some leeway to the prism height.

Synopsis
        IGRint GRbuild_cvprism (msg, world_to_view, view_to_world, origin,
                                extents, curve, prism)

        IGRlong             *msg;           return code
        IGRdouble           *world_to_view; transformation matrix; contains
                                            translation and rotation

        IGRdouble           *view_to_world; inverse of world_to_view; NULL
                                            causes local matrix to be created
        IGRdouble           *origin;        origin for prism (in world coords)
        IGRdouble           *extents;       of the symbol - to determine height
        struct IGRbsp_curve *curve;         curve to construct prism from
        struct IGRcv_prism  *prism;         output prism

Return values
        IGRint  ()  = TRUE    successful completion
                      FALSE   failure
        IGRlong msg = MSSUCC  successful completion
                      MSFAIL  failure

History
        mrm     05/15/87    creation
                06/22/88    revised for iso view
        scw     06/28/92    ANSI conversion
*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "msdef.h"

extern IGRboolean MAtypemx();
extern IGRboolean MAptsxform();
extern IGRboolean MAoptsxform();
extern IGRboolean MArptsxform();
extern IGRboolean MAinvmx();

IGRint GRbuild_cvprism (msg, world_to_view, view_to_world, origin,
                        extents, curve, prism)

IGRlong             *msg;           /* return code */
IGRdouble           *world_to_view; /* transformation matrix; contains */
                                    /* translation and rotation */
IGRdouble           *view_to_world; /* inverse of world_to_view; NULL */
                                    /* causes local matrix to be created */
IGRdouble           *origin;        /* origin for prism (in world coords) */
IGRdouble           *extents;       /* of the symbol - to determine height */
struct IGRbsp_curve *curve;         /* curve to construct prism from */
struct IGRcv_prism  *prism;         /* output prism */
{
    IGRshort        i;                  /* index */
    IGRshort        matrix_type;        /* for optimization */
    IGRlong          j;                  /* index */
    IGRboolean      status;             /* return status */
    IGRdouble       *mx;                /* points to view-to-world mx */
    IGRdouble       prism_origin[3];    /* origin of prism's coord sys */
    IGRdouble       world_to_prism[16]; /* world to prism */
    IGRdouble       vtw[16];            /* transform matrix */

    status = TRUE;
    *msg = MSSUCC;

    /*
     *  get the origin of the prism coordinate system -- drop back in view
     *  by an arbitrary value to keep pattern off face of prism
     */

    j = 1;
    status = MAptsxform (msg, &j, world_to_view, origin, prism_origin);

    prism_origin[2] -= 100;     /* KLUDGE */

    i = 4;

    if (view_to_world)
    {
        mx = view_to_world;
    }
    else
    {
        status = MAinvmx (msg, &i, world_to_view, vtw);
        mx = vtw;
    }

    status = MAptsxform (msg, &j, mx, prism_origin, prism_origin);

    /*
     *  get the height of the prism -- make sure it goes past the plane
     *  of the pattern
     */

    prism->height = extents[5] - extents[2];

    prism->height += 200;       /* KLUDGE */

    /*
     *  set up the prism matrix as a local-to-world matrix
     */

    prism->matrix[0]  =  world_to_view[0];
    prism->matrix[1]  =  world_to_view[4];
    prism->matrix[2]  =  world_to_view[8];
    prism->matrix[3]  =  prism_origin[0];
    prism->matrix[4]  =  world_to_view[1];
    prism->matrix[5]  =  world_to_view[5];
    prism->matrix[6]  =  world_to_view[9];
    prism->matrix[7]  =  prism_origin[1];
    prism->matrix[8]  =  world_to_view[2];
    prism->matrix[9]  =  world_to_view[6];
    prism->matrix[10] =  world_to_view[10];
    prism->matrix[11] =  prism_origin[2];
    prism->matrix[12] =  world_to_view[12];
    prism->matrix[13] =  world_to_view[13];
    prism->matrix[14] =  world_to_view[14];
    prism->matrix[15] =  world_to_view[15];

    /*
     *  set up the prism's curve
     */

    prism->curve = *curve;

    /*
     *  build a world-to-local matrix for the prism
     */

    status = MAinvmx (msg, &i, prism->matrix, world_to_prism);

    /*
     *  zero out the third row of the world-to-prism matrix to project the
     *  curve to the back of the prism
     */

    world_to_prism[8] = 0.0;
    world_to_prism[9] = 0.0;
    world_to_prism[10] = 0.0;
    world_to_prism[11] = 0.0;

    /*
     *  transform the points from the world coordinate system to the 
     *  local coordinate system of the prism
     */
       
    if (!curve->rational)
    {
        status = MAtypemx (msg, world_to_prism, &matrix_type);
        status = MAoptsxform (msg, &curve->num_poles, &matrix_type, 
                              world_to_prism, curve->poles,
                              prism->curve.poles);
    }
    else
    {
        status = MArptsxform (msg, &curve->num_poles, &curve->rational,
                              curve->weights, world_to_prism,
                              curve->poles, prism->curve.poles);
    }

    return ((IGRint)status);
}
