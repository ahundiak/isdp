/* $RCSfile: fsspltrc.c $$Revision: 1.3 $$Date: 1991/02/28 17:51:46 $ Copyright (c) 1990 Intergraph Corp. */


/*****************************************************************************
*									     *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*				Patent Pending				     *
*									     *
*	These programs are the sole property of Bitstream Inc. and	     *
*	  contain its proprietary and confidential information.		     *
*									     *
*	Modified extensively by Intergraph Corp., Huntsville, AL	     *
*									     *
*****************************************************************************/


/************************ F S S p l i t A r c s . c **************************

    Takes an arc specified by 2 endpoints and a bulge factor and returns a
    polygonal approximation to the arc by successive splitting

 ****************************************************************************/



#include "../hfiles/import.h"
#include <math.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSMakeFont.h"
#include "../hfiles/FSPolyFill.h"
#include "../hfiles/FSAlloc.h"



typedef  struct
{
    Real	x1;	/* 2 endpoints */
    Real	y1;
    Real	x2;
    Real	y2;
}   ArcData;


/**  ARC SPLITTING ALGORITHM:

  Let (X1, Y1)  and  (X2, Y2) be the endpoints. Let B be the bulge factor
  The sign of B determines which way the arc bends.

  The midpoint of the arc  (XM, YM) is calculated as
    XM = (X1 + X2) / 2  -  B * (Y2 - Y1) / 2
    YM = (Y1 + Y2) / 2  +  B * (X2 - X1) / 2

  The error, which is the distance from the midpoint of the chord between
  (X1, Y1) and (X2, Y2) and the midpoint of the arc, is simply the absolute
  value of  .5 * chordLength * bulgeFactor

  The bulge factor for the newly split arcs, B(new), is
    B(new) = (sqrt(1 + B*B) - 1) / B
  Note that as B approaches 0, B(new) = .5 * B (approx), and the error will
  diminish by almost a factor of 4 each time.

  These steps can be repeated until the error is acceptably small.
**/


Boolean _FSArcToVects (x1, y1, x2, y2, bugfat, tolerance, vector, splitCount)
Int32		x1, y1;		/* arc endpoint */
Int32		x2, y2;		/* arc endpoint */
Int32		bugfat;		/* unnormalized bulge factor */
Real		tolerance;	/* arc split tolerance in outl relative units */
VectorData	**vector;	/* pointer to vector storage area */
Int32		*splitCount;	/* number of vectors to create */

/* _FSArcToVects
 *  INPUT PARAMETERS:	x1, y1, x2, y2 (in outline resolution units),
 *			bugfat, tolerance
 *  OUTPUT PARAMETERS:	splitCount = number of vectors required to draw arc
 *			with a maximum error of < 'tolerance' pixels
 *			vector = pointer to storage allocation for 'splitCount'
 *			vectors (splitCount + 1 points)
 *  Allocates memory for 'vector' -- 'splitCount' + 1 structures of type
 *    'VectorData'. The calling program deallocates this memory.
 *  CALLED BY:  another module
 */
{
    Real	abvbul;		/* maximum deviation from chord line */
    Int32	iabvbul;	/*              at the center of arc */
    ArcData	arc;		/* 2 arc endpoints */
    Real	bulgeFactor;	/* normalized bulge factor */
    Real	chordLength;	/* distance between arc endpoints */
    Real	dx, dy;
    int		splitShift;	/* number of arc splittings */
    Boolean	rval;

    Int32	_FSIPow();		/* exponentiator */
    Boolean	_FSPutVectors();	/* calculate the arc splitting */


    _FSAssert (bugfat != 0);

    bulgeFactor = (Real)bugfat / TWO32;
    arc.x1 = x1;
    arc.y1 = y1;
    arc.x2 = x2;
    arc.y2 = y2;
    dx = arc.x2 - arc.x1;
    dy = arc.y2 - arc.y1;
    chordLength = sqrt(dx * dx + dy * dy);
    abvbul = ABS (chordLength * bulgeFactor) / 2;

    /** Corrected bulge value  - add 6.25% (1/16) if bulge factor > .2189,
	else add 1.56% (1/64) **/

    if (bulgeFactor > .2189)
	abvbul *= 1.0625;
    else
	abvbul *= 1.015625;
    iabvbul = (Int32) (abvbul / tolerance);

    for (splitShift = 0; iabvbul != 0; iabvbul >>= 2, splitShift++);
    *splitCount = _FSIPow (2, splitShift);

    /* Allocate space for 2**n + 1 vectors */
    *vector = (VectorData *) _FSAlloc ((*splitCount + 1) * sizeof (VectorData));
    rval = _FSPutVectors (&arc, bulgeFactor, *vector, *splitCount, splitShift);
    _FSAssert (rval);

    return (TRUE);
}



Boolean _FSPutVectors (arc, bulgeFactor, vector, splitCount,
				splitShift)
ArcData		*arc;		/* arc endpoints */
Real		bulgeFactor;
VectorData	*vector;	/* pointer to array of vector structures */
int		splitCount;	/* number of vectors created */
int		splitShift;	/* nbr of splittings = log2(splitCount)  */

/* _FSPutVectors
 *   INPUT PARAMETERS:  arc, bulgeFactor, splitCount, splitShift
 *   OUTPUT PARAMETERS: vector - a group of 2**N + 1 points
 *   X-Y coordinates are stored in an array of structures
 *	vector[0], ... , vector[splitCount]
 *   CALLED BY:  _FSArcToVects
 */
{
    Real	bf[20];		/* bulge factors */
    Real	*bfPtr, *bfEnd;
    Int32	stack[20], *stackPtr, *stack2;
    VectorData	*vector1, *vector2, *vector3;
    int		level1, level3;
    Int32	ii;


    bf[0] = bulgeFactor;
    bfEnd = &bf[splitShift + 1];
    for (bfPtr = bf; bfPtr < bfEnd; bfPtr++)	/* precompute bulge factors */
	bfPtr[1] = (sqrt ((1.0 + *bfPtr * *bfPtr)) - 1.0) / *bfPtr;

    vector->xx = arc->x1;
    vector->yy = arc->y1;
    vector->level = 0;

    vector1 = &vector[splitCount];
    vector1->xx = arc->x2;
    vector1->yy = arc->y2;
    vector1->level = 0;

    if (splitCount == 1)
	return (TRUE);

    /* This section computes 'splitCount' vectors */
    /* splitCount must be a power of 2 for this algorithm to work */
    stackPtr = &stack[2];
    stack[0] = 0;
    stack[1] = splitCount;
    stack2 = &stack[2];
    while (stackPtr >= stack2)
    {
	if (((ii = stackPtr[-1]) & 1) == 0)
	{
	    stackPtr[-1] = stackPtr[-2];
	    stackPtr[-2] = ii;
	    stackPtr[0] = (stackPtr[-1] + stackPtr[-2]) / 2;
	    stackPtr++;
	}
	else
	{
	    stackPtr -= 2;
	    if (stackPtr < stack2)
		break;

	    stackPtr[0] = (stackPtr[-1] + stackPtr[-2]) / 2;
	    stackPtr++;
	}

	/* find midpoint */
	vector1 = &vector[stackPtr[-2]];
	vector2 = &vector[stackPtr[-1]];
	vector3 = &vector[stackPtr[-3]];

	/* .level tells which bulge factor to use */
	level1 = vector1->level;
	level3 = vector3->level;
	vector2->level = MAX (level1, level3) + 1;

	vector2->xx = .5 * (vector1->xx + vector3->xx -
			    bf[vector2->level - 1] *
			    (vector3->yy - vector1->yy));
	vector2->yy = .5 * (vector1->yy + vector3->yy +
			    bf[vector2->level - 1] *
			    (vector3->xx - vector1->xx));
    }

    /** Check for impossible stack state **/
    _FSAssert ((stackPtr == &stack[1]) && (stack[0] == splitCount));

    return (TRUE);
}
