/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"

/*
NAME

EFplaneOfPointSets -- derive a plane from sets of coplanar points

ARGUMENTS

numSets:  the number of sets of points.

numPoints:  array containing the number of points in each set.

pointSet:  arrays of pointers to arrays of points.

weightSet:  arrays of either NULL pointers or pointers to arrays of
weights; cann be mixed.

plane:  the derived plane.  EFplaneOfPointSets generates a second
order non-rational plane with four knots in each of the u and v
directions and four poles.  This space must be allocated by the
caller.

RETURNED VALUES

EMS_S_Success for no problems.

EMS_E_InsufficientDynamicMemory if there was a problem aquiring
enough memory.

EMS_E_PossibleMathError if some BSpl_of_pts did not behave as
expected.

HISTORY

23 May 1988 jBk Genesis.
27 Aug 1992 NP  Modified for ANSI compliance. Added typecasts.
07/06/93    Sudha Modified for BSprototypes ansification

*/

/* OM_BLOCK_MOVE */
# include "OMmacros.h"

/* om$malloc om$dealloc */
# include "OMprimitives.h"

/* IGRlong IGRpoint IGRdouble */
# include "igrtypedef.h"

/* struct IGRbsp_surface */
# include "igr.h"

/* EMS_E_InsufficientDynamicMemory EMS_E_PossibleMathError */
# include "EMS_E.h"

/* EMS_S_Success */
# include "EMSmsgdef.h"

/* EMSrc */
# include "EMStypedef.h"

/* EMSokay */
# include "EMSlogic.h"

/* BSrc BSERROR */
# include "bserr.h"

#include "bspl_of_pts.h"

/* for local buffer of points and weights */
# define NUMPTS 1024

EMSrc EFplaneOfPointSets (
    numSets,
    numPoints,
    pointSets,
    weightSets,
    plane
)
    IGRint numSets;
    IGRlong numPoints[];
    IGRpoint *pointSets[];
    IGRdouble *weightSets[];
    struct IGRbsp_surface plane[1];
{
    EMSrc rc = EMS_S_Success;
    IGRpoint pointsArray[NUMPTS];
    IGRdouble weightsArray[NUMPTS];
    IGRpoint *points = pointsArray;
    IGRdouble *weights = NULL;
    int weighted = FALSE;
    int pointsAllocated = FALSE, weightsAllocated = FALSE;
    IGRlong dimension = 0;
    int ii;

    /* intentional block */
    {
        IGRlong *np;

        for (np = numPoints, ii = 0; ii < numSets; ii++)
        {
            dimension += *np++;
        }
    }

    if (weightSets)
    {
        IGRdouble *wp;

        for (wp = (IGRdouble *)weightSets, ii = 0; ii < numSets; ii++)
        {
            weighted = weighted OR wp++;
        }

        if (weighted) weights = weightsArray;
    }

    if (dimension > NUMPTS)
    {
        points = (IGRpoint *)om$malloc (
            size = (dimension * sizeof (IGRpoint))
        );

        if (points)
        {
            pointsAllocated = TRUE;
            if (weighted)
            {
                weights = (IGRdouble *)om$malloc (
                    size = (dimension * sizeof (IGRdouble))
                );
                if (weights)
                {
                    weightsAllocated = TRUE;
                }
                else
                {
                    rc = EMS_E_InsufficientDynamicMemory;
                }
            }
        }
        else
        {
            rc = EMS_E_InsufficientDynamicMemory;
        }
    }

    if (EMSokay (rc))
    {
        int soFar = 0;

        for (ii = 0; ii < numSets; ii++)
        {
            int howMany;

            howMany = numPoints[ii];

            OM_BLOCK_MOVE (
                pointSets[ii],
                points[soFar],
                (unsigned int)(howMany * sizeof (IGRpoint))
            );

            if (weighted)
            {
                if (weightSets[ii])
                {
                    OM_BLOCK_MOVE (
                        weightSets[ii],
                        &weights[soFar],
                        (unsigned int)(howMany * sizeof (IGRdouble))
                    );
                }
                else /* this set is not weighted, so use 1.0 */
                {
                    int ww = 0;
                    IGRdouble *wptr;

                    wptr = &weights[soFar];

                    while (ww++ < howMany) *wptr++ = 1.0;
                }
            }

            soFar += howMany;
        }

        /* could not go noticeably wrong during the preceding
            code so proceeding to determine plane of points */

        /* intentional block */
        {
            BSrc bsrc;

            BSpl_of_pts (
                /* numpts = */  dimension,
                /* points = */  (IGRdouble *)points,
                /* weights = */ weights,
                /* plane = */   plane,
                /* rc = */      &bsrc
            );

            if (BSERROR (bsrc)) rc = EMS_E_PossibleMathError;
        }
    }

    if (pointsAllocated) om$dealloc (ptr = points);
    if (weightsAllocated) om$dealloc (ptr = weights);

    return rc;
}
