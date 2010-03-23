/* $RCSfile: fsdofunc.c $$Revision: 1.2 $$Date: 1992/10/25 09:56:04 $ Copyright (c) 1990 Intergraph Corp. */


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


/************************ D O _ F U N C T I O N S . C ************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 1)   1-May-85  jsc	module created as a result of moving constraint
			function operators from rules.c into a separate file.
			Added the operator definitions:
				_FSDoBZON()
				_FSDoBZON1()
				_FSDoLZON()
				_FSDoLZON1()
				_FSDoCFFLB()
				_FSDoCFFRB()
				_FSDoCFSLB()
				_FSDoCFSRB()
				_FSDoXHtAdj()

 2)   6-Oct-86  jsc	Updated cfflb(), cffrb(), cfslb() and cfsrb() to
			operate correctly when sum of left and right side-
			bearings are zero pixels.

 *****************************************************************************
 **************** Constraint function operators ******************************

   The constraint function operators in the module are called by _FSGetPixels.
   All pop their parameters from the stack and push their result back onto
   the stack.

 ****************************************************************************/


#include "../hfiles/import.h"
#include <math.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"


_FSDoCO(stack)
Real **stack;
/* A CO function takes three arguments from the execution stack and returns a whole
   number of pixels.  The three arguments (in the order pushed onto the stack)
   are threshold, fpixelsSelf and pixelsOther.  If fpixelsSelf differs from
   pixelsOther by less than threshold, pixelsOther is returned; otherwise,
   fpixels is rounded to the nearest number of whole pixels and returned.  */
{
    Real pixelsOther;
    Real fpixelsSelf;
    Real threshold;
    Real diff;

    pixelsOther = *(--(*stack));
    fpixelsSelf = *(--(*stack));
    threshold = *(--(*stack));
    diff = fpixelsSelf - pixelsOther;
    if (fabs(diff) < threshold)
	*((*stack)++) = pixelsOther;
    else
	*((*stack)++) = floor(fpixelsSelf + 0.5);
}


_FSDoCF(stack)
Real **stack;
/*  A CF function takes three arguments from the execution stack and returns a whole
    number of pixels.  The three arguments (in the order pushed onto the stack) are
    threshold, fpixelsSelf and fpixelsOther.  If fpixelsSelf differs from
    fpixelsOther by less than the threshold, the average value of fpixelsSelf and
    fpixelsOther is rounded to the nearest whole number of pixels and returned as
    the result.  Otherwise, a combination of rounding up or down for fpixelsSelf
    and fpixelsOther is chosen whose ratio most closely approximates the ratio
    of the unrounded values.  */
{
    Real fpixelsOther;
    Real fpixelsSelf;
    Real threshold;
    Real ratio, pixels;
    Real selfDown, selfUp, otherDown, otherUp;
    Real error, minError;

    fpixelsOther = *(--(*stack));
    fpixelsSelf = *(--(*stack));
    threshold = *(--(*stack));
    if (fabs(fpixelsSelf - fpixelsOther) < threshold)
	pixels = floor((fpixelsSelf + fpixelsOther) * 0.5 + 0.5);
    else
    {
	ratio = fpixelsSelf / fpixelsOther;
	selfDown = floor(fpixelsSelf);
	selfUp = selfDown + 1;
	otherDown = floor(fpixelsOther);
	otherUp = otherDown + 1;
	minError = fabs(selfUp / otherDown - ratio);
	pixels = selfUp;
	error = fabs(selfUp / otherUp - ratio);
	if (error < minError)
	{
	    minError = error;
	}
	error = fabs(selfDown / otherDown - ratio);
	if (error < minError)
	{
	    pixels = selfDown;
	    minError = error;
	}
	error = fabs(selfDown / otherUp - ratio);
	if (error < minError)
	{
	    pixels = selfDown;
	}
    }
    *((*stack)++) = pixels;
}


_FSDoRRFS(stack)
Real **stack;
/*  An RRFS function takes three arguments from the execution stack and returns a
    whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are pixelsOtherFootspace, pixelsMyHeight, pixelsOtherHeight.  The
    value of pixelsOtherFootspace is reduced by half the difference between pixels
    myHeight and pixelsOtherHeight. The result is rounded up to the next whole
    number and pushed onto the stack.  */
{
    Real pixelsOtherHeight;
    Real pixelsMyHeight;
    Real pixelsOtherFootspace;
    Real extra;

    pixelsOtherHeight = *(--(*stack));
    pixelsMyHeight = *(--(*stack));
    pixelsOtherFootspace = *(--(*stack));
    extra = pixelsMyHeight - pixelsOtherHeight;
    *((*stack)++) = floor(pixelsOtherFootspace - (extra * 0.5) + 0.75);
}


_FSDoRRFS1(stack)
Real **stack;
/*  An RRFS1 function takes three arguments from the execution stack and returns a
    whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are pixelsOtherFootspace, pixelsMyHeight, pixelsOtherHeight.  The
    value of pixelsOtherFootspace is reduced by half the difference between pixels
    myHeight and pixelsOtherHeight. The result is rounded down to the next whole
    number and pushed onto the stack.  */
{
    Real pixelsOtherHeight;
    Real pixelsMyHeight;
    Real pixelsOtherFootspace;
    Real extra;

    pixelsOtherHeight = *(--(*stack));
    pixelsMyHeight = *(--(*stack));
    pixelsOtherFootspace = *(--(*stack));
    extra = pixelsMyHeight - pixelsOtherHeight;
    *((*stack)++) = floor(pixelsOtherFootspace - (extra * 0.5) + 0.25);
}


_FSDoRRHS(stack)
Real **stack;
/*  An RRHS function takes three arguments from the execution stack and returns a
    whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are pixelsOtherHeadspace, pixelsMyHeight, pixelsOtherHeight.  The
    value of pixelsOtherHeadspace is reduced by half the difference between pixels
    myHeight and pixelsOtherHeight. The result is rounded down to the next whole
    number and pushed onto the stack.  */
{
    Real pixelsOtherHeight;
    Real pixelsMyHeight;
    Real pixelsOtherHeadspace;
    Real extra;

    pixelsOtherHeight = *(--(*stack));
    pixelsMyHeight = *(--(*stack));
    pixelsOtherHeadspace = *(--(*stack));
    extra = pixelsMyHeight - pixelsOtherHeight;
    *((*stack)++) = floor(pixelsOtherHeadspace - (extra * 0.5) + 0.25);
}


_FSDoRRHS1(stack)
Real **stack;
/*  An RRHS1 function takes three arguments from the execution stack and returns a
    whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are pixelsOtherHeadspace, pixelsMyHeight, pixelsOtherHeight.  The
    value of pixelsOtherHeadspace is reduced by half the difference between pixels
    myHeight and pixelsOtherHeight. The result is rounded up to the next whole
    number and pushed onto the stack.  */
{
    Real pixelsOtherHeight;
    Real pixelsMyHeight;
    Real pixelsOtherHeadspace;
    Real extra;

    pixelsOtherHeight = *(--(*stack));
    pixelsMyHeight = *(--(*stack));
    pixelsOtherHeadspace = *(--(*stack));
    extra = pixelsMyHeight - pixelsOtherHeight;
    *((*stack)++) = floor(pixelsOtherHeadspace - (extra * 0.5) + 0.75);
}


_FSDoBZON(stack)
Real **stack;
/*  A BZON function takes two arguments from the execution stack and returns a
    whole number of pixels.  The two arguments (in the order pushed onto the
    stack) are fpixelsSelf and fpixelsOther.
    If the rounded sum of fpixelsSelf and fpixelsOther is less than or equal
    to a threshold of 10, the rounded sum is divided by two rounding up the
    result if necessary to the next whole number. 
    Otherwise, the fpixelsSelf is rounded to the nearest whole number. */
{
    Real threshold;
    Real fpixelsSelf;
    Real fpixelsOther;
    Real total, pixels;

    threshold = 10.0;
    fpixelsOther = *(--(*stack));
    fpixelsSelf = *(--(*stack));
    total = floor(fpixelsSelf + fpixelsOther + 0.5);
    if (total > threshold)
	pixels = floor(fpixelsSelf + 0.5);
    else
	pixels = floor((total * 0.5) + 0.75);
    *((*stack)++) = pixels;
}


_FSDoBZON1(stack)
Real **stack;
/*  A BZON1 function takes three arguments from the execution stack and returns
    a whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are fpixelsSelf, fpixelsOther and threshold.
    If the rounded sum of fpixelsSelf and fpixelsOther is less than or equal
    to the threshold, the rounded sum is divided by two rounding up the result
    if necessary to the next whole number. 
    Otherwise, the fpixelsSelf is rounded to the nearest whole number. */
{
    Real threshold;
    Real fpixelsSelf;
    Real fpixelsOther;
    Real total, pixels;

    threshold = *(--(*stack));
    fpixelsOther = *(--(*stack));
    fpixelsSelf = *(--(*stack));
    total = floor(fpixelsSelf + fpixelsOther + 0.5);
    if (total > threshold)
	pixels = floor(fpixelsSelf + 0.5);
    else
	pixels = floor((total * 0.5) + 0.75);
    *((*stack)++) = pixels;
}


_FSDoLZON(stack)
Real **stack;
/*  A LZON function takes two arguments from the execution stack and returns a
    whole number of pixels.  The two arguments (in the order pushed onto the
    stack) are fpixelsSelf and fpixelsOther.
    If the rounded sum of fpixelsSelf and fpixelsOther is less than or equal
    to a threshold of 10, the rounded sum is divided by two rounding down the
    result if necessary to the next whole number. 
    Otherwise, the fpixelsSelf is rounded to the nearest whole number. */
{
    Real threshold;
    Real fpixelsSelf;
    Real fpixelsOther;
    Real total, pixels;

    threshold = 10.0;
    fpixelsOther = *(--(*stack));
    fpixelsSelf = *(--(*stack));
    total = floor(fpixelsSelf + fpixelsOther + 0.5);
    if (total > threshold)
	pixels = floor(fpixelsSelf + 0.5);
    else
	pixels = floor((total * 0.5) + 0.25);
    *((*stack)++) = pixels;
}


_FSDoLZON1(stack)
Real **stack;
/*  A LZON1 function takes three arguments from the execution stack and returns
    a whole number of pixels.  The three arguments (in the order pushed onto the
    stack) are fpixelsSelf, fpixelsOther and threshold.
    If the rounded sum of fpixelsSelf and fpixelsOther is less than or equal
    to the threshold, the rounded sum is divided by two rounding down the result
    if necessary to the next whole number. 
    Otherwise, the fpixelsSelf is rounded to the nearest whole number. */
{
    Real threshold;
    Real fpixelsSelf;
    Real fpixelsOther;
    Real total, pixels;

    threshold = *(--(*stack));
    fpixelsOther = *(--(*stack));
    fpixelsSelf = *(--(*stack));
    total = floor(fpixelsSelf + fpixelsOther + 0.5);
    if (total > threshold)
	pixels = floor(fpixelsSelf + 0.5);
    else
	pixels = floor((total * 0.5) + 0.25);
    *((*stack)++) = pixels;
}


_FSDoCFFLB(stack)
Real **stack;
/*  A CFFLB function takes five arguments from the execution stack and returns a
    whole number of pixels.  The five arguments (in the order pushed onto the
    stack) are threshold, fpixelsFirstLB, fpixelsFirstRB, fpixelsSecondLB,
    fpixelsSecondRB.
    If the sum of the left and right side bearings of the first character is
    less than the specified threshold, CFFLB carries out a special pixel
    budgeting process for the left and right side bearings of the first and
    second characters. The process ensures that the sum of the left and right
    side bearings of the first character has the same parity as the sum of the
    left and right side bearings of the second character. If these sums are both
    odd, pixels are allocated to the left and right side bearings of each
    character in a manner that tends to allocate the extra pixel to the left side
    bearings.
    CFFLB returns the number of pixels allocated to the left side bearing of the
    first character. */
{
    Real threshold;
    Real fpixelsFirstLB;
    Real fpixelsFirstRB;
    Real fpixelsSecondLB;
    Real fpixelsSecondRB;
    Real sum, firstSum, secondSum;
    Real pixelsSum, pixelsFirstSum;
    Real pixelsFirstLB;

    fpixelsSecondRB = *(--(*stack));
    fpixelsSecondLB = *(--(*stack));
    fpixelsFirstRB = *(--(*stack));
    fpixelsFirstLB = *(--(*stack));
    threshold = *(--(*stack));

    firstSum = fpixelsFirstLB + fpixelsFirstRB;
    secondSum = fpixelsSecondLB + fpixelsSecondRB;
    if (firstSum > threshold)
	pixelsFirstLB = floor(fpixelsFirstLB + 0.5);
    else
    {
	sum = firstSum + secondSum;
	pixelsSum = floor((sum * 0.5) + 0.5) * 2.0; /* Round to nearest even number of pixels */
	if (pixelsSum < 0.5)
	{
	    pixelsFirstLB = 0.0;
	}
	else
	{
	    pixelsFirstSum = floor((firstSum * pixelsSum / sum) + 0.5);
	    if ((Int16)pixelsFirstSum & 0x1)	/* pixelsFirstSum odd? */
		pixelsFirstLB = floor(fpixelsFirstLB * pixelsFirstSum / firstSum + 1.0);
	    else
		pixelsFirstLB = floor(fpixelsFirstLB * pixelsFirstSum / firstSum + 0.5);
	}
    }
    *((*stack)++) = pixelsFirstLB;
}


_FSDoCFFRB(stack)
Real **stack;
/*  A CFFRB function takes five arguments from the execution stack and returns a
    whole number of pixels.  The five arguments (in the order pushed onto the
    stack) are threshold, fpixelsFirstLB, fpixelsFirstRB, fpixelsSecondLB,
    fpixelsSecondRB.
    If the sum of the left and right side bearings of the first character is
    less than the specified threshold, CFFRB carries out a special pixel
    budgeting process for the left and right side bearings of the first and
    second characters. The process ensures that the sum of the left and right
    side bearings of the first character has the same parity as the sum of the
    left and right side bearings of the second character. If these sums are both
    odd, pixels are allocated to the left and right side bearings of each
    character in a manner that tends to allocate the extra pixel to the left side
    bearings.
    CFFRB returns the number of pixels allocated to the right side bearing of the
    first character. */
{
    Real threshold;
    Real fpixelsFirstLB;
    Real fpixelsFirstRB;
    Real fpixelsSecondLB;
    Real fpixelsSecondRB;
    Real sum, firstSum, secondSum;
    Real pixelsSum, pixelsFirstSum;
    Real pixelsFirstLB, pixelsFirstRB;

    fpixelsSecondRB = *(--(*stack));
    fpixelsSecondLB = *(--(*stack));
    fpixelsFirstRB = *(--(*stack));
    fpixelsFirstLB = *(--(*stack));
    threshold = *(--(*stack));

    firstSum = fpixelsFirstLB + fpixelsFirstRB;
    secondSum = fpixelsSecondLB + fpixelsSecondRB;
    if (firstSum > threshold)
	pixelsFirstRB = floor(fpixelsFirstRB + 0.5);
    else
    {
	sum = firstSum + secondSum;
	pixelsSum = floor((sum * 0.5) + 0.5) * 2.0; /* Round to nearest even number of pixels */
	if (pixelsSum < 0.5)
	{
	    pixelsFirstRB = 0.0;
	}
	else
	{
	    pixelsFirstSum = floor((firstSum * pixelsSum / sum) + 0.5);
	    if ((Int16)pixelsFirstSum & 0x1)	/* pixelsFirstSum odd? */
		pixelsFirstLB = floor(fpixelsFirstLB * pixelsFirstSum / firstSum + 1.0);
	    else
		pixelsFirstLB = floor(fpixelsFirstLB * pixelsFirstSum / firstSum + 0.5);
	    pixelsFirstRB = pixelsFirstSum - pixelsFirstLB;
	}
    }
    *((*stack)++) = pixelsFirstRB;
}


_FSDoCFSLB(stack)
Real **stack;
/*  A CFSLB function takes five arguments from the execution stack and returns a
    whole number of pixels.  The five arguments (in the order pushed onto the
    stack) are threshold, fpixelsFirstLB, fpixelsFirstRB, fpixelsSecondLB,
    fpixelsSecondRB.
    If the sum of the left and right side bearings of the first character is
    less than the specified threshold, CFSLB carries out a special pixel
    budgeting process for the left and right side bearings of the first and
    second characters. The process ensures that the sum of the left and right
    side bearings of the first character has the same parity as the sum of the
    left and right side bearings of the second character. If these sums are both
    odd, pixels are allocated to the left and right side bearings of each
    character in a manner that tends to allocate the extra pixel to the left side
    bearings.
    CFSLB returns the number of pixels allocated to the left side bearing of the
    second character. */
{
    Real threshold;
    Real fpixelsFirstLB;
    Real fpixelsFirstRB;
    Real fpixelsSecondLB;
    Real fpixelsSecondRB;
    Real sum, firstSum, secondSum;
    Real pixelsSum, pixelsFirstSum, pixelsSecondSum;
    Real pixelsSecondLB;

    fpixelsSecondRB = *(--(*stack));
    fpixelsSecondLB = *(--(*stack));
    fpixelsFirstRB = *(--(*stack));
    fpixelsFirstLB = *(--(*stack));
    threshold = *(--(*stack));

    firstSum = fpixelsFirstLB + fpixelsFirstRB;
    secondSum = fpixelsSecondLB + fpixelsSecondRB;
    if (firstSum > threshold)
	pixelsSecondLB = floor(fpixelsSecondLB + 0.5);
    else
    {
	sum = firstSum + secondSum;
	pixelsSum = floor((sum * 0.5) + 0.5) * 2.0; /* Round to nearest even number of pixels */
	if (pixelsSum < 0.5)
	{
	    pixelsSecondLB = 0.0;
	}
	else
	{
	    pixelsFirstSum = floor((firstSum * pixelsSum / sum) + 0.5);
	    pixelsSecondSum = pixelsSum - pixelsFirstSum;
	    if ((Int16)pixelsSecondSum & 0x1)	/* pixelsSecondSum odd? */
		pixelsSecondLB = floor(fpixelsSecondLB * pixelsSecondSum / secondSum + 1.0);
	    else
		pixelsSecondLB = floor(fpixelsSecondLB * pixelsSecondSum / secondSum + 0.5);
	}
    }
    *((*stack)++) = pixelsSecondLB;
}


_FSDoCFSRB(stack)
Real **stack;
/*  A CFSRB function takes five arguments from the execution stack and returns a
    whole number of pixels.  The five arguments (in the order pushed onto the
    stack) are threshold, fpixelsFirstLB, fpixelsFirstRB, fpixelsSecondLB,
    fpixelsSecondRB.
    If the sum of the left and right side bearings of the first character is
    less than the specified threshold, CFSRB carries out a special pixel
    budgeting process for the left and right side bearings of the first and
    second characters. The process ensures that the sum of the left and right
    side bearings of the first character has the same parity as the sum of the
    left and right side bearings of the second character. If these sums are both
    odd, pixels are allocated to the left and right side bearings of each
    character in a manner that tends to allocate the extra pixel to the left side
    bearings.
    CFSRB returns the number of pixels allocated to the right side bearing of the
    second character. */
{
    Real threshold;
    Real fpixelsFirstLB;
    Real fpixelsFirstRB;
    Real fpixelsSecondLB;
    Real fpixelsSecondRB;
    Real sum, firstSum, secondSum;
    Real pixelsSum, pixelsFirstSum, pixelsSecondSum;
    Real pixelsSecondLB, pixelsSecondRB;

    fpixelsSecondRB = *(--(*stack));
    fpixelsSecondLB = *(--(*stack));
    fpixelsFirstRB = *(--(*stack));
    fpixelsFirstLB = *(--(*stack));
    threshold = *(--(*stack));

    firstSum = fpixelsFirstLB + fpixelsFirstRB;
    secondSum = fpixelsSecondLB + fpixelsSecondRB;
    if (firstSum > threshold)
	pixelsSecondRB = floor(fpixelsSecondRB + 0.5);
    else
    {
	sum = firstSum + secondSum;
	pixelsSum = floor((sum * 0.5) + 0.5) * 2.0; /* Round to nearest even number of pixels */
	if (pixelsSum < 0.5)
	{
	    pixelsSecondRB = 0.0;
	}
	else
	{
	    pixelsFirstSum = floor((firstSum * pixelsSum / sum) + 0.5);
	    pixelsSecondSum = pixelsSum - pixelsFirstSum;
	    if ((Int16)pixelsSecondSum & 0x1)	/* pixelsSecondSum odd? */
		pixelsSecondLB = floor(fpixelsSecondLB * pixelsSecondSum / secondSum + 1.0);
	    else
		pixelsSecondLB = floor(fpixelsSecondLB * pixelsSecondSum / secondSum + 0.5);
	    pixelsSecondRB = pixelsSecondSum - pixelsSecondLB;
	}
    }
    *((*stack)++) = pixelsSecondRB;
}


_FSDoFix(stack)
Real **stack;
/*  A FIX function takes one argument from the execution stack, rounds it down to
    the next whole number and pushes the result back onto the stack.  */
{
    Real arg1;

    arg1 = *(--(*stack));
    *((*stack)++) = floor(arg1);
}


_FSDoFixR(stack)
Real **stack;
/*  A FIXR function takes one argument from the execution stack, rounds it to the
    nearest whole number and pushes the result back onto the stack.  */
{
    Real arg1;

    arg1 = *(--(*stack));
    *((*stack)++) = floor(arg1 + 0.5);
}


_FSDoAdd(stack)
Real **stack;
/*  An addition function takes two arguments from the execution stack, adds them
    together and pushes the result back onto the stack.  */
{
    Real arg1, arg2;

    arg2 = *(--(*stack));
    arg1 = *(--(*stack));
    *((*stack)++) = arg1 + arg2;
}


_FSDoSub(stack)
Real **stack;
/*  A subtraction function takes two arguments from the execution stack, subtracts
    the top of the stack from the next value and pushes the result back onto the
    stack.  */
{
    Real arg1, arg2;

    arg2 = *(--(*stack));
    arg1 = *(--(*stack));
    *((*stack)++) = arg1 - arg2;
}


_FSDoMul(stack)
Real **stack;
/*  A multiplication function takes two arguments from the execution stack,
    multiplies them together and pushes the result back onto the stack.  */
{
    Real arg1, arg2;

    arg2 = *(--(*stack));
    arg1 = *(--(*stack));
    *((*stack)++) = arg1 * arg2;
}


_FSDoDiv(stack)
Real **stack;
/*  A division function takes two arguments from the execution stack, divides
    the top of the stack into the next value and pushes the result back onto the
    stack.  */
{
    Real arg1, arg2;

    arg2 = *(--(*stack));
    arg1 = *(--(*stack));
    *((*stack)++) = arg1 / arg2;
}


/*ARGSUSED*/
_FSDoPrint(stack)
Real **stack;
/*  A PRINT function has no effect on the execution stack.  */
{
}

_FSDoXHtAdj (xhtAdj, stack)
Real   xhtAdj;
Real **stack;
/*  An xhtAdj function takes no arguments from the execution stack,
    and pushes the value onto the stack. */
{
    *((*stack)++) = xhtAdj;
}
