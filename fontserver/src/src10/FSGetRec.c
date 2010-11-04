/* $RCSfile: fsgetrec.c $$Revision: 1.2 $$Date: 1991/02/28 16:09:05 $ Copyright (c) 1990 Intergraph Corp. */


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


/************************** G E T R E C . C **********************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 1)  12-Dec-85  jsc	Added new record types to getrec to handle 4 types of
			function items: P item (type 16), F item (type 17),
			Constant item (type 18) and Operation item (type 19).

			Also changed definition of beta result for x and y
			zones (types 14 and 15) to accomodate two bit function
			flag and larger field for minimum pixel value.

			check_outlines() updated to handle the new types.

 2)  10-Jan-86  jsc	Removed function 'check_outlines'

 3)   1-May-86  jsc	T item handling added.
			_FSIsCTItem() function added.

 4)   6-Sep-86  jsc	Types of second and third arguments of _FSIsCConstItem()
			changed from uInt32 to Int32.

 5)  11-Oct-86  jsc	Field extraction expressions in _FSGetRec() updated to
			ensure casting to uInt32 in setting of state variable.

			static variable min name changed to mini to avoid name
			clash.

 *****************************************************************************

    Routines for unpacking compressed outline data (with plaid)

 ****************************************************************************/

#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSGetRec.h"


static uInt32  state[2];  /* Determines internal state of _FSGetRec channel n
    Bits 31-24  Bits 23-16   Bits 15-8    Bits 7-0
       00         00            00           00       Nothing to do
       01         00            00        MS 4 bits   Xmax extent data
       02         00            00        MS 4 bits   Ymax extent data
       03         00            00        No values   Outline hierarchy data
       04    No X zones     No Y zones    F size      Plaid zone data (16 bit edge values)
       05    No X zones     No Y zones    F size      Plaid zone data (32 bit edge values) */

static uInt16	repeatActive[2], retCount[2], retOffset[2];
static Int32	currentX[2], currentY[2];
static uInt16	*pXEdges[2], *pYEdges[2];
static uInt32	savedState;
static uInt16	savedRepeatActive, savedRetCount, savedRetOffset;
static Int32	savedCurrentX, savedCurrentY;
static uInt16	*savedPXEdges, *savedPYEdges;
static Int32	accMantissa, accExponent;
static Int16	accDecPtRead, accSign, accTermRead;

void _FSInitRecState(n)
uInt16 n;
/* Initializes _FSGetRec state for channel n */
{
    state[n] = 0;
    repeatActive[n] = 0;	/* Clear call stack */
    currentX[n] = currentY[n] = 0;
}

int _FSSaveRecState(n)
uInt16 n;
/* Saves _FSGetRec state for channel n */
{
    savedState = state[n];
    savedRepeatActive = repeatActive[n];
    savedRetCount = retCount[n];
    savedRetOffset = retOffset[n];
    savedCurrentX = currentX[n];
    savedCurrentY = currentY[n];
    savedPXEdges = pXEdges[n];
    savedPYEdges = pYEdges[n];
}

int _FSRestoreRecState(n)
uInt16 n;
/* Restores _FSGetRec state for channel n */
{
    state[n] = savedState;
    repeatActive[n] = savedRepeatActive;
    retCount[n] = savedRetCount;
    retOffset[n] = savedRetOffset;
    currentX[n] = savedCurrentX;
    currentY[n] = savedCurrentY;
    pXEdges[n] = savedPXEdges;
    pYEdges[n] = savedPYEdges;
}

void _FSGetRec(
    uInt16 n,		/* Environment number */
    uInt16 **record,	/* Current record in character data */
    uInt16 *dataOrigin,	/* First data record in character data */
    Int16  *type,	/* Returned record type */
    Int32  *x,		/* Returned value x */
    Int32  *y,		/* Returned value y */
    Int32  *beta)	/* Returned value beta */
/* _FSGetRec fetches the next logical step from compressed outline data.	*/
/* Sets *type to indicate type of step read.				*/
/*   -1: erroneous step read.						*/
/*    0: end of character or call while repeat active.			*/
/*    1: move to (*x, *y).						*/
/*    2: vector to (*x, *y).						*/
/*    3: horizontal vector to (*x, *y).					*/
/*    4: vertical vector to (*x, *y).					*/
/*    5: arc to (*x, *y) with bulge factor *beta.			*/
/*    6: set scale factors to *x, *y (units of 1/65536).		*/
/*    7: set origin to (*x, *y).					*/
/*    8: set x min extent (*x).						*/
/*    9: set x max extent (*x).						*/
/*   10: set y min extent (*y).						*/
/*   11: set y max extent (*y).						*/
/*   12: do char (*x).							*/
/*   13: hierarchy value (*x).						*/
/*   14: plaid x zone data. *x is starting coord, *y is ending coord,	*/
/*	 *beta is P, L, C, function flags and minimum pixels:		*/
/*	     Bits 31-16   Not used					*/
/*	     Bit  15      P flag					*/
/*	     Bit  14      L flag					*/
/*	     Bit  13      C flag					*/
/*	     Bits 12-11   Function flag:				*/
/*			      0: No function items			*/
/*			      1: 1 function item follows		*/
/*			      2: Not used				*/
/*			      3: 2 or more function items follow	*/
/*				 terminated by an op item with		*/
/*				 termination flag on			*/
/*	     Bits 10-8    Not used					*/
/*	     Bits  7-0    Minumum value					*/
/*   15: plaid y zone data. *x is starting coord, *y is ending coord,	*/
/*       *beta is P, L, C, function flags and minimum pixels:		*/
/*	     Bits 31-16   Not used					*/
/*	     Bit  15      P flag					*/
/*	     Bit  14      L flag					*/
/*	     Bit  13      C flag					*/
/*	     Bits 12-11   Function flag:				*/
/*			      0: No function items			*/
/*			      1: 1 function item follows		*/
/*			      2: Not used				*/
/*			      3: 2 or more function items follow	*/
/*				 terminated by an op item with		*/
/*				 termination flag on			*/
/*	     Bits 10-8    Not used					*/
/*	     Bits  7-0    Minumum value					*/
/*   16: P item. *x is character number, *y is dim * 256 + zone no	*/
/*   17: F item. *x is character number, *y is dim * 256 + zone no	*/
/*   18: Const item. *x is value, *y is decimal exponent		*/
/*   19: Op item. *x is op code:					*/
/*	     0: NOP function						*/
/*	     1: ADD function						*/
/*	     2: SUB function						*/
/*	     3: MUL function						*/
/*	     4: DIV function						*/
/*	     5: PRINT function						*/
/*	     6: FIXR function (round to nearest integer)		*/
/*	     7: FIX function (round to next lowest integer)		*/
/*	     8: CO function						*/
/*	     9: CF function						*/
/*	    10: RRFS function						*/
/*	    11: RRHS function						*/
/*	    12: RRFS1 function						*/
/*	    13: RRHS1 function						*/
/*	    14: BZON function						*/
/*	    15: BZON1 function						*/
/*	    16: LZON function						*/
/*	    17: LZON1 function						*/
/*	    18: CFFLB function						*/
/*	    19: CFFRB function						*/
/*	    20: CFSLB function						*/
/*	    21: CFSRB function						*/
/*	    22: XHT_ADJ function					*/
/*									*/
/*   for all op codes, *beta indicates if last item in function:	*/
/*	     Bits 31-1    Not used					*/
/*	     Bit   0      Termination flag:				*/
/*			      0: Not last function item			*/
/*			      1: Last function item			*/
/*   20: T item. *x is character number, *y is dim * 256 + zone no	*/
{
    uInt32	*statePtr;
    Int32	*currentXPtr, *currentYPtr;
    uInt16	**pXEdgesPtr, **pYEdgesPtr;
    uInt16	firstWord, secondWord, thirdWord, fourthWord;
    uInt16	charNum, dim, zoneNum, from, to, plc, opCode, fsize, mini;
    uInt16	termFlag;
    Int32	xinc, yinc;

    Int16	_FSIsCZone();
    Int16	_FSIsCPItem(), _FSIsCFItem(), _FSIsCTItem();
    Int16	_FSIsCConstItem(), _FSIsCOpItem();


    /** Pointers to frequently used variables **/
    statePtr = &state[n];
    currentXPtr = &currentX[n];
    currentYPtr = &currentY[n];
    pXEdgesPtr = &pXEdges[n];
    pYEdgesPtr = &pYEdges[n];

Again:
    if (*statePtr)	/* Outstanding data to read */
    {
	if ((*statePtr & 0xff000000) == 0x01000000)  /* X extent data */
	{
	    *type = 9;
	    *x = (((Int32)*statePtr) << 28 >> 12) + **record;
	    *statePtr = 0;
	    _FSNextStep(record, dataOrigin, n, 1);
	    return;
	}
	if ((*statePtr & 0xff000000) == 0x02000000)  /* Y extent data */
	{
	    *type = 11;
	    *y = (((Int32)*statePtr) << 28 >> 12) + **record;
	    *statePtr = 0;
	    _FSNextStep(record, dataOrigin, n, 1);
	    return;
	}
	if ((*statePtr & 0xff000000) == 0x03000000)  /* Outline hierarchy values */
	{
	    *x = (Int32)(**record);
	    (*record)++;
	    (*statePtr)--;
	    if ((*statePtr & 0x000000ff) == 0)
		*statePtr = 0;
	    *type = 13;
	    return;
	}
	if ((*statePtr & 0xfc000000) == 0x04000000)   /* Plaid zone data */
	{
	    fsize = *statePtr & 0x000000ff;
	    if (fsize)	/* Function items */
	    {
		termFlag = 0;
		if (_FSIsCPItem(record, &charNum, &dim, &zoneNum))
		{
		    *x = charNum;
		    *y = (dim << 8) + zoneNum;
		    *type = 16;
		}
		else if (_FSIsCFItem(record, &charNum, &dim, &zoneNum))
		{
		    *x = charNum;
		    *y = (dim << 8) + zoneNum;
		    *type = 17;
		}
		else if (_FSIsCConstItem(record, x, y))
		{
		    *type = 18;
		}
		else if (_FSIsCOpItem(record, &opCode, &termFlag))
		{
		    *x = opCode;
		    *beta = termFlag;
		    *type = 19;
		}
		else if (_FSIsCTItem(record, &charNum, &dim, &zoneNum))
		{
		    *x = charNum;
		    *y = (dim << 8) + zoneNum;
		    *type = 20;
		}
		else
		{
		    _FSAssert (FALSE);
		    *type = -1;
		}
		if (fsize < 3)
		    (*statePtr)--;
		if (termFlag)
		    *statePtr = *statePtr & 0xffffff00;
		if ((*statePtr & 0x00ffffff) == 0)
		    *statePtr = 0;
		return;
	    }
	    if (*statePtr & 0x00ff0000)	/* x zones */
	    {
		if (_FSIsCZone(record, &from, &to, &plc, &mini, &fsize))
		{
		    if (*statePtr & 0x01000000)	/* 32 bit edge values? */
		    {
			*x = ((Int32)(*pXEdgesPtr)[from << 1]) << 16;
			*x += (*pXEdgesPtr)[(from << 1) + 1];
			*y = ((Int32)(*pXEdgesPtr)[to << 1]) << 16;
			*y += (*pXEdgesPtr)[(to << 1) + 1];
		    }
		    else
		    {
			*x = ((Int32)(*pXEdgesPtr)[from]) << 16 >> 16;
			*y = ((Int32)(*pXEdgesPtr)[to]) << 16 >> 16;
		    }
		    *beta = (plc << 13) + (fsize << 11) + mini;
		    *type = 14;
		}
		else
		{
		    _FSAssert (FALSE);
		    *type = -1;
		}
		*statePtr = *statePtr - 0x00010000 + fsize;
		if ((*statePtr & 0x00ffffff) == 0)
		    *statePtr = 0;
		return;
	    }
	    if (*statePtr & 0x0000ff00)	/* y zones */
	    {
		if (_FSIsCZone(record, &from, &to, &plc, &mini, &fsize))
		{
		    if (*statePtr & 0x01000000)	/* 32 bit edge values? */
		    {
			*x = ((Int32)(*pYEdgesPtr)[from << 1]) << 16;
			*x += (*pYEdgesPtr)[(from << 1) + 1];
			*y = ((Int32)(*pYEdgesPtr)[to << 1]) << 16;
			*y += (*pYEdgesPtr)[(to << 1) + 1];
		    }
		    else
		    {
			*x = ((Int32)(*pYEdgesPtr)[from]) << 16 >> 16;
			*y = ((Int32)(*pYEdgesPtr)[to]) << 16 >> 16;
		    }
		    *beta = (plc << 13) + (fsize << 11) + mini;
		    *type = 15;
		}
		else
		{
		    _FSAssert (FALSE);
		    *type = -1;
		}
		*statePtr = *statePtr - 0x00000100 + fsize;
		if ((*statePtr & 0x00ffffff) == 0)
		    *statePtr = 0;
		return;
	    }
	}
	_FSAssert (FALSE);
    }
    firstWord = **record;
    if ((firstWord & 0xc000) == 0)	/* Horizontal vector code */
    {
	*type = 3;
	xinc = ((Int32)(firstWord & 0x3fff)) << 18 >> 18;
	*currentXPtr += xinc;
	*x = *currentXPtr;
	*y = *currentYPtr;
	*beta = 0;
	_FSNextStep(record, dataOrigin, n, 1);
	return;
    }
    else if ((firstWord & 0xc000) == 0x4000)	/* Vertical vector code */
    {
	*type = 4;
	*x = *currentXPtr;
	yinc = ((Int32)(firstWord & 0x3fff)) << 18 >> 18;
	*currentYPtr += yinc;
	*y = *currentYPtr;
	*beta = 0;
	_FSNextStep(record, dataOrigin, n, 1);
	return;
    }
    else if ((firstWord & 0xc000) == 0x8000)	/* Short vector code */
    {
	*type = 2;
	xinc = ((Int32)(firstWord & 0x3fff)) << 18 >> 18;
	*currentXPtr += xinc;
	*x = *currentXPtr;
	secondWord = *(*record + 1);
	yinc = ((Int32)(secondWord)) << 16 >> 16;
	*currentYPtr += yinc;
	*y = *currentYPtr;
	*beta = 0;
	_FSNextStep(record, dataOrigin, n, 2);
	return;
    }
    else if ((firstWord & 0xff00) == 0xe000)	/* Long vector code */
    {
	*type = 2;
	secondWord = *(*record + 1);
	xinc = (((Int32)firstWord) >> 4 << 28 >> 12) + secondWord;
	*currentXPtr += xinc;
	*x = *currentXPtr;
	thirdWord = *(*record + 2);
	yinc = (((Int32)firstWord)  << 28 >> 12) + thirdWord;
	*currentYPtr += yinc;
	*y = *currentYPtr;
	*beta = 0;
	_FSNextStep(record, dataOrigin, n, 3);
	return;
    }
    else if ((firstWord & 0xe000) == 0xc000)	/* Short arc code */
    {
	*type = 5;
	secondWord = *(*record + 1);
	xinc = (((Int32)firstWord) << 22 >> 22);
	*currentXPtr += xinc;
	*x = *currentXPtr;
	yinc = (((Int32)secondWord)  << 22 >> 22);
	*currentYPtr += yinc;
	*y = *currentYPtr;
	*beta = ((((Int32)firstWord) >> 10 << 16) + secondWord) >> 10 << 23;
	_FSNextStep(record, dataOrigin, n, 2);
	return;
    }
    else if ((firstWord & 0xff00) == 0xe100)	/* Long arc code */
    {
	*type = 5;
	secondWord = *(*record + 1);
	xinc = (((Int32)firstWord) >> 4 << 28 >> 12) + secondWord;
	*currentXPtr += xinc;
	*x = *currentXPtr;
	thirdWord = *(*record + 2);
	yinc = (((Int32)firstWord)  << 28 >> 12) + thirdWord;
	*currentYPtr += yinc;
	*y = *currentYPtr;
	fourthWord = *(*record + 3);
	*beta = ((Int32)fourthWord) << 16;
	_FSNextStep(record, dataOrigin, n, 4);
	return;
    }
    else if ((firstWord & 0xff00) == 0xf000)	/* Move code */
    {
	*type = 1;
	secondWord = *(*record + 1);
	*currentXPtr = (((Int32)firstWord) >> 4 << 28 >> 12) + secondWord;
	*x = *currentXPtr;
	thirdWord = *(*record + 2);
	*currentYPtr = (((Int32)firstWord)  << 28 >> 12) + thirdWord;
	*y = *currentYPtr;
	*beta = 0;
	_FSNextStep(record, dataOrigin, n, 3);
	return;
    }
    else if ((firstWord & 0xff00) == 0xf100)	/* End outline code */
    {
	*record += 1;
	goto Again;
    }
    else if ((firstWord & 0xff00) == 0xe200)	/* Call code */
    {
	if (repeatActive[n])	/* Call code during repeat */
	{
	    *type = 0;
	    return;
	}
	else
	{
	    retCount[n] = firstWord & 0x00ff;	/* Initialize step count */
	    if (retCount[n] == 0)		/* Ignore if step count = 0 */
	    {
		*record += 2;
		goto Again;
	    }
    /*TPL*/ retOffset[n] = (uInt32)(*record - dataOrigin) + 2; /* Save return address */
	    *record = dataOrigin + (*(*record + 1));	/* Set next address */
	    repeatActive[n] = 1;
	    goto Again;
	}
    }
    else if ((firstWord & 0xff00) == 0xe300)	/* End char code  */
    {
	*type = 0;
	_FSNextStep(record, dataOrigin, n, 1);
	return;
    }
    else if ((firstWord & 0xff00) == 0xf200)	/* Set position code */
    {
	*type = 7;
	secondWord = *(*record + 1);
	*x = (((Int32)firstWord) >> 4 << 28 >> 12) + secondWord;
	thirdWord = *(*record + 2);
	*y = (((Int32)firstWord)  << 28 >> 12) + thirdWord;
	_FSNextStep(record, dataOrigin, n, 3);
	return;
    }
    else if ((firstWord & 0xff00) == 0xf300)	/* Set scale factors code */
    {
	*type = 6;
	secondWord = *(*record + 1);
	*x = (((Int32)secondWord) << 16 >> 12);
	thirdWord = *(*record + 2);
	*y = (((Int32)thirdWord)  << 16 >> 12);
	_FSNextStep(record, dataOrigin, n, 3);
	return;
    }
    else if ((firstWord & 0xff00) == 0xf400)	/* Do char code */
    {
	*type = 12;
	secondWord = *(*record + 1);
	*x = secondWord;
	_FSNextStep(record, dataOrigin, n, 2);
	return;
    }
    else if ((firstWord & 0xff00) == 0xf500)	/* X extents code */
    {
	*type = 8;
	secondWord = *(*record + 1);
	*x = (((Int32)firstWord) >> 4 << 28 >> 12) + secondWord;
	*statePtr = 0x01000000 + (firstWord & 0x000f);
	*record += 2;
	return;
    }
    else if ((firstWord & 0xff00) == 0xf600)	/* Y extents code */
    {
	*type = 10;
	secondWord = *(*record + 1);
	*y = (((Int32)firstWord) >> 4 << 28 >> 12) + secondWord;
	*statePtr = 0x02000000 + (firstWord & 0x000f);
	*record += 2;
	return;
    }
    else if ((firstWord & 0xff00) == 0xf700)	/* Plaid edge values code */
    {
	*pXEdgesPtr = *record += 1;	/* Set pointer to x edges */
	*pYEdgesPtr = *record		/* Set prec to y edges */
	    += (firstWord & 0x00f0) >> 4;
	*record += firstWord & 0x000f;	/* Move to zone data */
    
	if ((**record & 0xff00) == 0xf800)
	{
	    *statePtr = 0x04000000
		+ ((uInt32)(**record & 0x00f0) << 12)
		+ ((**record & 0x000f) << 8);
	    (*record)++;
	    if ((*statePtr & 0x00ffffff) == 0)
		*statePtr = 0;
	    goto Again;
	}
	else if (**record == 0xfff2)
	{
	    (*record)++;
	    *statePtr = 0x04000000
		+ ((uInt32)((**record & 0xff00) + (**record & 0x00ff)) << 8);
	    (*record)++;
	    if ((*statePtr & 0x00ffffff) == 0)
		*statePtr = 0;
	    goto Again;
	}
	else
	{
	    _FSAssert (FALSE);
	    goto Error;
	}
    }
    else if ((firstWord & 0xff00) == 0xfa00)	/* Long plaid edge vals code */
    {
	*pXEdgesPtr = *record += 1;	/* Set pointer to x edges */
	*pYEdgesPtr = *record		/* Set prec to y edges */
	    += (firstWord & 0x00f0) >> 3;
	*record += (firstWord & 0x000f) << 1;	/* Move to zone data */
    
	if ((**record & 0xff00) == 0xf800)
	{
	    *statePtr = 0x05000000
		+ ((uInt32)(**record & 0x00f0) << 12)
		+ ((**record & 0x000f) << 8);
	    (*record)++;
	    if ((*statePtr & 0x00ffffff) == 0)
		*statePtr = 0;
	    goto Again;
	}
	else if (**record == 0xfff2)
	{
	    (*record)++;
	    *statePtr = 0x05000000
		+ ((uInt32)((**record & 0xff00) + (**record & 0x00ff)) << 8);
	    (*record)++;
	    if ((*statePtr & 0x00ffffff) == 0)
		*statePtr = 0;
	    goto Again;
	}
	else
	{
	    _FSAssert (FALSE);
	    goto Error;
	}
    }
    else if ((firstWord & 0xffff) == 0xfff0)	/* Plaid edge values code */
    {
	secondWord = *(*record + 1);
	*pXEdgesPtr = *record += 2;	/* Set pointer to x edges */
	*pYEdgesPtr = *record		/* Set prec to y edges */
	    += (secondWord & 0xff00) >> 8;
	*record += secondWord & 0x00ff;	/* Move to zone data */
    
	if ((**record & 0xff00) == 0xf800)
	{
	    *statePtr = 0x04000000
		+ ((uInt32)(**record & 0x00f0) << 12)
		+ ((**record & 0x000f) << 8);
	    (*record)++;
	    if ((*statePtr & 0x00ffffff) == 0)
		*statePtr = 0;
	    goto Again;
	}
	else if (**record == 0xfff2)
	{
	    (*record)++;
	    *statePtr = 0x04000000
		+ ((uInt32)((**record & 0xff00) + (**record & 0x00ff)) << 8);
	    (*record)++;
	    if ((*statePtr & 0x00ffffff) == 0)
		*statePtr = 0;
	    goto Again;
	}
	else
	{
	    _FSAssert (FALSE);
	    goto Error;
	}
    }
    else if ((firstWord & 0xffff) == 0xfff1)	/* Long plaid edge vals code */
    {
	secondWord = *(*record + 1);
	*pXEdgesPtr = *record += 2;	/* Set pointer to x edges */
	*pYEdgesPtr = *record		/* Set prec to y edges */
	    += (secondWord & 0xff00) >> 8;
	*record += secondWord & 0x00ff;	/* Move to zone data */
    
	if ((**record & 0xff00) == 0xf800)
	{
	    *statePtr = 0x05000000
		+ ((uInt32)(**record & 0x00f0) << 12)
		+ ((**record & 0x000f) << 8);
	    (*record)++;
	    if ((*statePtr & 0x00ffffff) == 0)
		*statePtr = 0;
	    goto Again;
	}
	else if (**record == 0xfff2)
	{
	    (*record)++;
	    *statePtr = 0x05000000
		+ ((uInt32)((**record & 0xff00) + (**record & 0x00ff)) << 8);
	    (*record)++;
	    if ((*statePtr & 0x00ffffff) == 0)
		*statePtr = 0;
	    goto Again;
	}
	else
	{
	    _FSAssert (FALSE);
	    goto Error;
	}
    }
    else if ((firstWord & 0xff00) == 0xf900)	/* Hierarchy values code */
    {
	*statePtr = 0x03000000 + (firstWord & 0x00ff);
	(*record)++;
	if ((*statePtr & 0x00ffffff) == 0)
	    *statePtr = 0;
	goto Again;
    }
    _FSAssert (FALSE);

Error:
    *type = -1;
    _FSNextStep(record, dataOrigin, n, 1);
}


void _FSNextStep(uInt16 **record, uInt16 *dataOrigin, uInt16 n, Int16 wordCount)
/* Updates *record to point to next record. */
/* n = number of words in current record */
/* Tracks repeat subroutine and inserts return when appropriate. */
{
    if (repeatActive[n])	/* Repeat sequence active */
    {
	if (--retCount[n] == 0)	/* Step count now zero */
	{
	    repeatActive[n] = 0;
	    *record = retOffset[n] + dataOrigin;  /* Restore return address */
	    return;
	}
    }
    *record += wordCount;
}

Int16 _FSIsCZone(record, pfrom, pto, pplc, pmin, pfsize)
uInt16 **record;
uInt16 *pfrom;
uInt16 *pto;
uInt16 *pplc;
uInt16 *pmin;
uInt16 *pfsize;
/* Interprets the record at *record as a plaid zone definition		*/
/* Unpacks from edge number into *pfrom					*/
/* Unpacks to edge number into *pto					*/
/* Unpacks prop, level and cont flags into *pplc			*/
/* Unpacks min into *pmin						*/
/* Unpacks function size into *pfsize					*/
/* Always returns true because any binary value is interpretable as a	*/
/* plaid zone definition						*/
{
    uInt16 word;
    
    word = **record;
    if ((word & 0xf000) != 0xf000)
    {
	*pfrom = word >> 12;
	*pto = (word >> 8) & 0x000f;
	*pplc = (word >> 5) & 0x0007;
	*pfsize = (word >> 3) & 0x0003;
	*pmin = word & 0x0007;
	(*record)++;
    }
    else 
    {
	*pplc = (word >> 9) & 0x0007;
	*pfsize = (word >> 7) & 0x0003;
	*pmin = word & 0x007f;
	(*record)++;
	word = **record;
	*pfrom = word >> 8;
	*pto = word & 0x00ff;
	(*record)++;
    }
    return(1);
}


Int16 _FSIsCPItem(record, pcharNum, pdim, pzoneNum)
uInt16 **record;
uInt16 *pcharNum;
uInt16 *pdim;
uInt16 *pzoneNum;
/* Tests if the data at *record is a plaid P item definition		*/
/* If so:								*/
/*   Unpacks the character number into *pcharNum			*/
/*   Unpacks the dimension flag into *pdim				*/
/*   Unpacks the zone number into *pzoneNum				*/
/*   Returns true							*/
/* If not, returns false						*/
{
    uInt16 word;

    word = **record;
    if ((word & 0xc000) == 0x0000)
    {
	*pcharNum = (word >> 5) & 0x01ff;
	*pdim = (word >> 4) & 0x0001;
	*pzoneNum = word & 0x000f;
	(*record)++;
	return(1);
    }
    else if ((word & 0xff00) == 0xf000)
    {
	*pzoneNum = word & 0x00ff;
	(*record)++;
	word = **record;
	*pcharNum = word >> 1;
	*pdim = word & 0x0001;
	(*record)++;
	return(1);
    }
    return(0);
}


Int16 _FSIsCFItem(record, pcharNum, pdim, pzoneNum)
uInt16 **record;
uInt16 *pcharNum;
uInt16 *pdim;
uInt16 *pzoneNum;
/* Tests if the data at *record is a plaid F item definition		*/
/* If so:								*/
/*   Unpacks the character number into *pcharNum			*/
/*   Unpacks the dimension flag into *pdim				*/
/*   Unpacks the zone number into *pzoneNum				*/
/*   Returns true							*/
/* If not, returns false						*/
{
    uInt16 word;

    word = **record;
    if ((word & 0xc000) == 0x4000)
    {
	*pcharNum = (word >> 5) & 0x01ff;
	*pdim = (word >> 4) & 0x0001;
	*pzoneNum = word & 0x000f;
	(*record)++;
	return(1);
    }
    else if ((word & 0xff00) == 0xf100)
    {
	*pzoneNum = word & 0x00ff;
	(*record)++;
	word = **record;
	*pcharNum = word >> 1;
	*pdim = word & 0x0001;
	(*record)++;
	return(1);
    }
    return(0);
}


Int16 _FSIsCTItem(record, pcharNum, pdim, pzoneNum)
uInt16 **record;
uInt16 *pcharNum;
uInt16 *pdim;
uInt16 *pzoneNum;
/* Tests if the data at *record is a plaid T item definition		*/
/* If so:								*/
/*   Unpacks the character number into *pcharNum			*/
/*   Unpacks the dimension flag into *pdim				*/
/*   Unpacks the zone number into *pzoneNum				*/
/*   Returns true							*/
/* If not, returns false						*/
{
    uInt16 word;

    word = **record;
    if ((word & 0xff00) == 0xf200)
    {
	*pzoneNum = word & 0x00ff;
	(*record)++;
	word = **record;
	*pcharNum = word >> 1;
	*pdim = word & 0x0001;
	(*record)++;
	return(1);
    }
    return(0);
}


Int16 _FSIsCConstItem(record, pmantissa, pexponent)
uInt16 **record;
Int32   *pmantissa, *pexponent;
{
/* Tests if the data at *record is a plaid constant item definition	*/
/* If so, converts the decimal constant to binary and			*/
/*    Assigns the mantissa to *pmantissa				*/
/*    Assigns the exponent to *pexponent				*/
/*    Returns true							*/
/* If not, returns false						*/
    uInt16 word;
    
    word = **record;
    if ((word & 0xc000) == 0x8000)
    {
	_FSInitAcc();
	if ((word & 0xf000) == 0x8000)
	{
	    _FSAccDigit(word & 0x000f);
	    _FSAccDigit((word >> 4) & 0x000f);
	    _FSAccDigit((word >> 8) & 0x000f);
	    (*record)++;
	}
	else if ((word & 0xf000) == 0x9000)
	{
	    _FSAccDigit(word & 0x000f);
	    _FSAccDigit((word >> 4) & 0x000f);
	    _FSAccDigit((word >> 8) & 0x000f);
	    (*record)++;
	    word = **record;
	    _FSAccDigit(word & 0x000f);
	    _FSAccDigit((word >> 4) & 0x000f);
	    _FSAccDigit((word >> 8) & 0x000f);
	    _FSAccDigit((word >> 12) & 0x000f);
	    (*record)++;
	}
	else if ((word & 0xf000) == 0xa000)
	{
	    _FSAccDigit(word & 0x000f);
	    _FSAccDigit((word >> 4) & 0x000f);
	    _FSAccDigit((word >> 8) & 0x000f);
	    (*record)++;
	    word = **record;
	    _FSAccDigit(word & 0x000f);
	    _FSAccDigit((word >> 4) & 0x000f);
	    _FSAccDigit((word >> 8) & 0x000f);
	    _FSAccDigit((word >> 12) & 0x000f);
	    (*record)++;
	    word = **record;
	    _FSAccDigit(word & 0x000f);
	    _FSAccDigit((word >> 4) & 0x000f);
	    _FSAccDigit((word >> 8) & 0x000f);
	    _FSAccDigit((word >> 12) & 0x000f);
	    (*record)++;
	}
	else
	{
	    _FSAssert (FALSE);
	}
	*pmantissa = accMantissa * accSign;
	*pexponent = accExponent;
	return(1);
    }
    return(0);
}


Int16 _FSIsCOpItem(record, opCode, lastItem)
uInt16 **record;
uInt16 *opCode;
uInt16 *lastItem;
/* Tests if the data at *record is a plaid operator item definition	*/
/* If so:								*/
/*    Unpacks the operator code into *opCode				*/
/*    Unpacks the last item flag into *lastItem				*/
/*    Returns true							*/
/* If not, returns false						*/
{
    uInt16 word;

    word = **record;
    if ((word & 0xe000) == 0xc000)
    {
	*lastItem = (word >> 12) & 0x0001;
	*opCode = word & 0x0fff;
	(*record)++;
	return(1);
    }
    return(0);
}


int _FSInitAcc(void)
/* Initializes the decimal to binary conversion accumulator		*/
{
    accMantissa = 0;
    accExponent = 0;
    accDecPtRead = 0;
    accSign = 1;
    accTermRead = 0;
}


int _FSAccDigit(uInt16 digit)
/* Accumulates the digit into the decimal to binary conversion accumulator */
{
    if (digit < 0xa)
    {
	accMantissa = accMantissa * 10 + digit;
	if (accDecPtRead)
	    accExponent--;
    }
    else if (digit == 0xa)
	accTermRead = 1;
    else if (digit == 0xb)
    {
	_FSAssert (!accDecPtRead);
	accDecPtRead = 1;
    }
    else if (digit == 0xc)
    {
	accSign = -1;
    }
    else
    {
	_FSAssert (FALSE);
    }
}
