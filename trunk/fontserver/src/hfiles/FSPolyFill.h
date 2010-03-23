/* $RCSfile: fsplyfll.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:14 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef	_POLYFILL
#define	_POLYFILL	0


#include "FSTypes.h"


/*****  DATA STRUCTURES:  *****
 *
 *  IntElem --	List element from a list of x-intercept data
 *		For a given y, where y marks the center of a pixel, there is a
 *		sorted list of all x-intercepts for the active character.
 *	intc --	x-intercept, range -32768 - +32767.999985. The high 16-bits
 *		are the integer part; the low 16 bits are the fractional part.
 *	intNext -- pointer to next x-intercept for the same value of y, or 0
 */

typedef struct _IntElem
{
    Int32		intc;		/* x- or y-intercept, 16 frac bits */
    struct _IntElem	*intNext;	/* pointer to next one, or 0 */
}   IntElem;				/* x- or y-intercept list element */


typedef struct
{
    Int32	xx;		/* endpoint x-coordinate */
    Int32	yy;		/* endpoint y-coordinate */
    Int32	bugFat;		/* bulge-factor, 32-bit signed fraction */
}   ArcType;


typedef struct
{
    Real	xx;	/* ordered pair */
    Real	yy;
    Int		level;	/* recursion level in arc splitting */
}   VectorData;


typedef  struct
{
    Real	xOff;		/* ordered pair */
    Real	yOff;
    Real	xScale;		/* actual scaling */
    Real	yScale;
    Real	xScaleNom;	/* nominal scaling */
    Real	yScaleNom;
    uInt16	*pc;		/* program counter */
}   StackFrame;


typedef struct
{
    Int32	xMin;	/* minimum x extent */
    Int32	xMax;	/* maximum x extent */
    Int32	yMin;	/* minimum y extent */
    Int32	yMax;	/* maximum y extent */
}   BmapExt;


#endif
