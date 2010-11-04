/* $RCSfile: fspxcch.c $$Revision: 1.3 $$Date: 1991/02/28 17:51:04 $ Copyright (c) 1990 Intergraph Corp. */


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


/************************* F S P i x C a c h e . c *************************
 ********************* R E V I S I O N   H I S T O R Y *********************

 1)  02-Apr-86  mby	Added _FSReinitCache()

 2)  15-Apr-86  jsc	Added mechanism to keep list of character numbers with
			zone data in cache. The list is updated as characters
			are added to the cache. The list is used to clear the
			unrounded and rounded pixel values of cached characters

 3)  12-Nov-86  jsc	_FSCacheData() changed from void to boolean.
			_FSPutCacheData() changed to abandon loading data if
			cache overflow occurs.

 4)  28-Nov-86  jsc	_FSCacheFPixels() modified to set cached pixels of
			zone to -1 to ensure recalculation.

 5)  03-Apr-87  mby	_FSCacheFPixels() modified to store a value of 0 if the
			argument is negative.

 ***************************************************************************

   This is the mechanism for caching zone data and the rounded and unrounded
   pixel values associated with each zone.

 *****************************************************************************/

#include <math.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSMakeFont.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSGetRec.h"
#include "../hfiles/FSPixCache.h"



static Int	cacheNumChars;		/* number of chars allocated */
static Int16	*cacheXOffsets = NULL;	/* Offset to first zone in X dimension */
static Int16	*cacheNumXZones = NULL;	/* Number of zones in X dimension */
static Real	cacheXScale;		/* Current X dimension scale factor for scaled cache */
static Real	cacheXPixPerEm;		/* Current pixels per em in X dimension */
static Int16	*cacheYOffsets = NULL;	/* Offset to first zone in Y dimension */
static Int16	*cacheNumYZones = NULL;	/* Number of zones in Y dimension */
static Real	cacheYScale;		/* Current Y dimension scale factor for scaled cache */
static Real	cacheYPixPerEm;		/* Current pixels per em in Y dimension */
static Int16	nextCacheOffset;	/* Offset to next empty character */

static Int16	putCacheDimension;	/* Current dimension being written to cache */
static Int16	putCacheCharNum;	/* Current character being written to cache */
static Int16	putCacheZoneNum;	/* Current zone number */

static uInt16	*cacheCharXList = NULL;	/* List of char numbers with X zone data in cache */
static Int16	cacheNumXChars;		/* Number of characters with X zone data in cache */
static uInt16	*cacheCharYList = NULL;	/* List of char numbers with Y zone data in cache */
static Int16	cacheNumYChars;		/* Number of characters with Y zone data in cache */

/** The following arrays are not declared as static due to their large size **/
/** (static variables are stored as initialized data) **/

Int32	_FSFromCache[MAX_CACHE_ZONES] = { 0 };	/* Start coordinate of zone */
Int32	_FSToCache[MAX_CACHE_ZONES] = { 0 };	/* End coordinate of zone */
uInt16	_FSFlagsCache[MAX_CACHE_ZONES] = { 0 };	/* Zone flags as follows... */
					/*   Bit 15:     Propagate flag (parent zone) */
					/*   Bit 14:     Level flag */
					/*   Bit 13:     Continue flag */
					/*   Bits 12-11: Function flags */
					/*   Bits 7-0:   Minimum number of pixels */
uInt16	*_FSFuncCache[MAX_CACHE_ZONES] = { NULL };	/* Pointer to constraint function */
Int16	_FSPixelsCache[MAX_CACHE_ZONES] = { 0 };	/* Rounded number of pixels at full scale */
Int16	_FSScaledPixelsCache[MAX_CACHE_ZONES] = { 0 };	/* Rounded number of pixels at cache[XY]Scale */
Real32	_FSFPixelsCache[MAX_CACHE_ZONES] = { 0 };	/* Unrounded number of pixels at full scale */
Real32	_FSScaledFPixelsCache[MAX_CACHE_ZONES] = { 0 };	/* Unrounded number of pixels at cache[XY]Scale */


void _FSNewCache (int numChars)

/* Called by main to initialize cache to empty condition before first use
   and after change of font */
{
    int		size;
    Int16	*ptr;

    /** Allocate memory for character dependent arrays **/
    cacheNumChars = numChars;
    size = numChars * sizeof (Int16) * 6;

    if (cacheXOffsets == NULL)
	ptr = (Int16 *) _FSMalloc (size);
    else
	ptr = (Int16 *) _FSRealloc (cacheXOffsets, size);

    cacheXOffsets = ptr;	/* this one always points to start of mem */
    ptr += numChars;
    cacheNumXZones = ptr;
    ptr += numChars;
    cacheYOffsets = ptr;
    ptr += numChars;
    cacheNumYZones = ptr;
    ptr += numChars;
    cacheCharXList = (uInt16 *) ptr;
    ptr += numChars;
    cacheCharYList = (uInt16 *) ptr;
}


void _FSDeleteCache (void)
{
    /** Free the arrays if they were allocated **/
    if (cacheXOffsets != NULL)
	_FSFree (cacheXOffsets);

    cacheXOffsets = NULL;
}


void _FSInitCache (Real pixemX, Real pixemY)

/* Called by main to initialize cache to empty condition before first use
   and after change of font */
{
    Int16 i;

    cacheNumXChars = 0;	/* Clear list of chars with X zones in cache */
    cacheNumYChars = 0;	/* Clear list of chars with Y zones in cache */
    nextCacheOffset = 0;	/* Start at beginning of cache */
    for (i = 0; i < cacheNumChars; i++)
    {
	/* Mark character X & Y zone data not in cache */
	cacheXOffsets[i] = cacheYOffsets[i] = -1;
    }
    cacheXPixPerEm = pixemX;		/* Set main cache scale */
    cacheYPixPerEm = pixemY;
    cacheXScale = 1.0;		/* Reset scaled cache scale */
    cacheYScale = 1.0;
    _FSOpenPutCacheData();
}


void  _FSReinitCache (pointsizeX, pointsizeY, resHor, resVer, arot, aobl)
Real	pointsizeX, pointsizeY;	/* x, y pointsizes */
Real	resHor, resVer;		/* resolution in x, y (dpi) */
Real	arot, aobl;		/* rotation & obliquing angles */

  /*  Initializes cache if pixels per em (calculated from x & y pointsize and
   *  resHor and resVer) changes in either dimension. Pixels per em is
   *  checked only in a dimension in which the zone data is valid.
   *  1) orthogonal rotation, no obliquing:  x & y
   *  2) orthogonal rotation, obliquing:  y-dimension of the character
   *  3) nonorthogonal rotation, (obliquing + rotation) is orthogonal (within
   *     < .01 degrees): */
{
    Real	qq, qqq;
    Real	rotplusobl;
    Real	xPem=0.0, 
		yPem=0.0;	/* character pixels per em in x, y dimensions */
    Boolean	xCheck, yCheck;

    qq = arot / 360.;
    arot -= floor(qq) * 360.;
    qq = aobl / 180.;
    aobl -= floor(qq) * 180.;
    if (aobl > 90.)  aobl -= 180.;
    rotplusobl = arot + aobl;
    qq = 90. * floor((rotplusobl / 90.) + 0.5);
    qqq = qq - rotplusobl;
    if ((ABS(qqq)) < .01)	/* threshold of .01 degree */
	rotplusobl = qq;

    if (arot == 0. || arot == 180.)	/* orthogonal rotation angle */
    {
	if (aobl == 0.)		/* no obliquing */
	{
	    xPem = pointsizeX * resHor / PTPERINCH;
	    yPem = pointsizeY * resVer / PTPERINCH;
	    xCheck = TRUE;
	    yCheck = TRUE;
	}
	else	/* with obliquing */
	{
	    xPem = pointsizeX * resHor / PTPERINCH;
	    yPem = pointsizeY * resVer / PTPERINCH;
	    xCheck = FALSE;
	    yCheck = TRUE;
	}
    }
    else if (arot == 90. || arot == 270.)	/* orthogonal rotation angle */
    {
	if (aobl == 0.)		/* no obliquing */
	{
	    xPem = pointsizeX * resVer / PTPERINCH;
	    yPem = pointsizeY * resHor / PTPERINCH;
	    xCheck = TRUE;
	    yCheck = TRUE;
	}
	else	/* with obliquing */
	{
	    xPem = pointsizeX * resVer / PTPERINCH;
	    yPem = pointsizeY * resHor / PTPERINCH;
	    xCheck = FALSE;
	    yCheck = TRUE;
	}
    }
    else	/* nonorthogonal rotation angle */
    {
	if (rotplusobl == 0. || rotplusobl == 180. || rotplusobl == 360.)
	{
	    xPem = pointsizeX * resHor / PTPERINCH;	/* obliquing cancels  */
	    yPem = pointsizeY * resVer / PTPERINCH;	/* rotation in an up- */
	    xCheck = TRUE;				/* down orientation   */
	    yCheck = FALSE;
	}
	else if (rotplusobl == 90.  ||  rotplusobl == 270.)
	{
	    xPem = pointsizeX * resVer / PTPERINCH;	/* obliquing cancels */
	    yPem = pointsizeY * resHor / PTPERINCH;	/* rotation in a     */
	    xCheck = TRUE;				/* left-right orientation   */
	    yCheck = FALSE;
	}
	else	/* obliquing does not cancel rotation */
	{	/* zone data cannot be used */
	    xCheck = FALSE;
	    yCheck = FALSE;
	}
    }

    if (xCheck)
    {
	if (ABS (xPem - cacheXPixPerEm) > .01)
	{
	    _FSClearXCache();		/* Clear cached data in X */
	    cacheXPixPerEm = xPem;	/* Update main cache scale */
	    cacheXScale = 1.0;		/* Reset scaled cache scale */
	}
    }
    if (yCheck)
    {
	if (ABS (yPem - cacheYPixPerEm) > .01)
	{
	    _FSClearYCache();		/* Clear cached data in y */
	    cacheYPixPerEm = yPem;	/* Update main cache scale */
	    cacheYScale = 1.0;		/* Reset scaled cache scale */
	}
    }

    return;
}


void _FSOpenPutCacheData(void)
/* Called by _FSCharScanConvert() to prepare cache to accept zone data with
   _FSPutCacheData() calls */
{
    putCacheDimension = -1;	/* Flag no dimension selected */
}





void _FSClosePutCacheData(void)
/* Called by _FSSetupTrans() to terminate input of zone data
   Also called by _FSPutCacheData() to terminate input of zone data in one
   dimension when change of dimension is detected */
{
    if (putCacheDimension == X_DIMENSION)
    {
	cacheXOffsets[putCacheCharNum] = nextCacheOffset;
	cacheNumXZones[putCacheCharNum] = putCacheZoneNum;
	nextCacheOffset += putCacheZoneNum;
	cacheCharXList[cacheNumXChars++] = putCacheCharNum;
    }
    else if (putCacheDimension == Y_DIMENSION)
    {
	cacheYOffsets[putCacheCharNum] = nextCacheOffset;
	cacheNumYZones[putCacheCharNum] = putCacheZoneNum;
	nextCacheOffset += putCacheZoneNum;
	cacheCharYList[cacheNumYChars++] = putCacheCharNum;
    }
}








void _FSPutCacheData(
    uInt16	charNum,	/* Character offset */
    Int16	dimension,	/* 0 if x zone, 1 if y zone */
    Int32	from,		/* zone start coordinate */
    Int32	to,		/* zone end coordinate */
    uInt16	flags,		/* zone flags */
    uInt16	*pfunct)	/* pointer to constraint function if any */
/* Called by _FSCharScanConvert() to add zone data to cache */
{
    Int16 offset;

    if (dimension == X_DIMENSION)
    {
	if (cacheXOffsets[charNum] >= 0)	/* Character already cached? */
	    return;
    }
    else
    {
	if (cacheYOffsets[charNum] >= 0)	/* Character already cached? */
	    return;
    }

    if (putCacheDimension == -2)	/* Cache previously filled? */
	return;

    if ((dimension != putCacheDimension) ||
	(charNum != putCacheCharNum))	/* New character or dimension? */
    {
	_FSClosePutCacheData();
	putCacheDimension = dimension;
	putCacheCharNum = charNum;
	putCacheZoneNum = 0;
    }

    offset = nextCacheOffset + putCacheZoneNum;
    if (offset >= MAX_CACHE_ZONES)	/* Cache full? */
    {
	putCacheDimension = -2;	/* Flag cache overflow */
	return;
    }

    _FSFromCache[offset] = from;	/* Copy from coordinate into cache */
    _FSToCache[offset] = to;		/* Copy to coordinate into cache */
    _FSFlagsCache[offset] = flags;	/* Copy P L C flags and MIN into cache */
    _FSFuncCache[offset] = pfunct;	/* Save pointer to constraint fn in cache */
    _FSPixelsCache[offset] = -1;	/* Mark pixels value not available */
    _FSScaledPixelsCache[offset] = -1;	/* Mark scaled pixels value not available */
    _FSFPixelsCache[offset] = -1.0;	/* Mark fpixels value not available */
    _FSScaledFPixelsCache[offset] = -1.0; /* Mark scaled fpixels value not available */
    putCacheZoneNum++;
}


Boolean _FSCacheData(charNum, dimension, cfont, pfirstRec)
uInt16		charNum;	/* Character offset */
Int16		dimension;	/* 0 if x zone, 1 if y zone */
TFStruct	*cfont;		/* pointer to compressed font data structure */
uInt16		*pfirstRec;	/* pointer to first record in font outline data */
/* Called by _FSGetPixels() and _FSGetFPixels() to ensure that zone data for the
   specified dimension of the specified character is present in the cache.
   If not, the appropriate zone data is read and added to the cache.
   returns TRUE if the requested data is in the cache on exit.
   returns FALSE if the requested data cannot be loaded into the cache. */
{
    uInt16 *prec;
    Int16 offset;
    Int16 type;
    Int32 from, to, beta;
    void _FSInitRecState();

    if (dimension == X_DIMENSION) /* X dimension? */
    {
	if (cacheXOffsets[charNum] >= 0) /* X zone data already in cache? */
	    return(TRUE);
	prec = cfont->outlines + cfont->charDir[charNum].outlineOffs;
	offset = nextCacheOffset;
	if (offset >= MAX_CACHE_ZONES)	/* Cache full? */
	{
	    putCacheDimension = -2;	/* Flag cache overflow */
	    return(FALSE);
	}

	_FSInitRecState(1);	/* Initialize _FSGetRec state read stream 1 */
	for (;;)
	{
	    _FSGetRec(1, &prec, pfirstRec, &type, &from, &to, &beta);
	    if (type == 14)	/* Plaid X zone data? */
	    {
		_FSFromCache[offset] = from;
		_FSToCache[offset] = to;
		_FSFlagsCache[offset] = beta;
		_FSFuncCache[offset] = prec;
		_FSPixelsCache[offset] = -1;
		_FSScaledPixelsCache[offset] = -1;
		_FSFPixelsCache[offset] = -1.0;
		_FSScaledFPixelsCache[offset] = -1.0;
		offset++;
		if (offset >= MAX_CACHE_ZONES)  /* Cache overflow? */
		{
		    return(FALSE);
		}
	    }
	    if (type == 0)	/* End of character? */
		break;
	    if (type == 1)	/* Start of outline data? */
		break;
	    if (type == 13)	/* Outline hierarchy data? */
		break;
	}
	cacheXOffsets[charNum] = nextCacheOffset;
	cacheNumXZones[charNum] = offset - nextCacheOffset;
	nextCacheOffset = offset;
	cacheCharXList[cacheNumXChars++] = charNum;
	return(TRUE);
    }
    else	/* Y dimension? */
    {
	if (cacheYOffsets[charNum] >= 0) /* Y zone data already in cache? */
	    return(TRUE);
	prec = cfont->outlines + cfont->charDir[charNum].outlineOffs;
	offset = nextCacheOffset;
	if (offset >= MAX_CACHE_ZONES)	/* Cache full? */
	{
	    putCacheDimension = -2;	/* Flag cache overflow */
	    return(FALSE);
	}

	_FSInitRecState(1);	/* Initialize _FSGetRec state read stream 1 */
	for (;;)
	{
	    _FSGetRec(1, &prec, pfirstRec, &type, &from, &to, &beta);
	    if (type == 15)	/* Plaid Y zone data? */
	    {
		_FSFromCache[offset] = from;
		_FSToCache[offset] = to;
		_FSFlagsCache[offset] = beta;
		_FSFuncCache[offset] = prec;
		_FSPixelsCache[offset] = -1;
		_FSScaledPixelsCache[offset] = -1;
		_FSFPixelsCache[offset] = -1.0;
		_FSScaledFPixelsCache[offset] = -1.0;
		offset++;
		if (offset >= MAX_CACHE_ZONES) /* Cache overflow? */
		{
		    return(FALSE);
		}
	    }
	    if (type == 0)	/* End of character? */
		break;
	    if (type == 1)	/* Start of outline data? */
		break;
	    if (type == 13)	/* Outline hierarchy data? */
		break;
	}
	cacheYOffsets[charNum] = nextCacheOffset;
	cacheNumYZones[charNum] = offset - nextCacheOffset;
	nextCacheOffset = offset;
	cacheCharYList[cacheNumYChars++] = charNum;
	return(TRUE);
    }
}


void _FSCachePixels(
    uInt16	charNum,	/* Character offset */
    Int16	dimension,	/* 0 if x zone, 1 if y zone */
    Int16	zoneNum,	/* Zone number */
    Int16	pixels,		/* Number of pixels */
    Real	scale)		/* Scale factor for dimension */
/* Called by _FSGetPixels() to save a rounded number of pixels for the specified
   zone in the specified dimension of the specified character. If the scale
   factor is 1.0, the data is saved in the main cache.  If the scale factor is
   not 1.0, the data is saved in the auxiliary cache.  All other rounded and
   unrounded pixel values in the specified dimension of the auxiliary cache
   are cleared if the non-unity scale factor has changed from the currently
   prevailing value (cacheXScale or cacheYScale).	*/
{
    Int16 offset;

    if (dimension == X_DIMENSION)
    {
	offset = cacheXOffsets[charNum];  
	if (offset >= 0)	/* Char/dim loaded? */
	{
	    if (scale == 1.0)
	    {
		_FSPixelsCache[offset + zoneNum] = pixels;
	    }
	    else if (scale == cacheXScale)
	    {
		_FSScaledPixelsCache[offset + zoneNum] = pixels;
	    }
	    else
	    {
		_FSClearScaledXCache();
		cacheXScale = scale;
		_FSScaledPixelsCache[offset + zoneNum] = pixels;
	    }
	}
	else
	{
	    _FSAssert (FALSE);
	}
    }
    else
    {
	offset = cacheYOffsets[charNum];
	if (offset >= 0)	/* Char/dim loaded? */
	{
	    if (scale == 1.0)
	    {
		_FSPixelsCache[offset + zoneNum] = pixels;
	    }
	    else if (scale == cacheYScale)
	    {
		_FSScaledPixelsCache[offset + zoneNum] = pixels;
	    }
	    else
	    {
		_FSClearScaledYCache();
		cacheYScale = scale;
		_FSScaledPixelsCache[offset + zoneNum] = pixels;
	    }
	}
	else
	{
	    _FSAssert (FALSE);
	}
    }
}


void _FSCacheFPixels(
    uInt16	charNum,	/* Character offset */
    Int16	dimension,	/* 0 if x zone, 1 if y zone */
    Int16	zoneNum,	/* Zone number */
    Real	fpixels,	/* Unrounded number of pixels */
    Real	scale)		/* Scale factor for dimension */
/* Called by allocPixels() and _FSGetFPixels() to save an unrounded number of
   pixels for the specified zone in the specified dimension of the specified
   character. If the scale factor is 1.0, the data is saved in the main cache.
   If the scale factor is not 1.0, the data is saved in the auxiliary cache.
   All other rounded and unrounded pixel values in the specified dimension of
   the auxiliary cache are cleared if the non-unity scale factor has changed
   from the currently prevailing value (cacheXScale or cacheYScale). */
{
    Int16 offset;

    if (fpixels < 0.) fpixels = 0.;
    if (dimension == X_DIMENSION)
    {
	offset = cacheXOffsets[charNum];  
	if (offset >= 0)	/* Char/dim loaded? */
	{
	    if (scale == 1.0)
	    {
		_FSFPixelsCache[offset + zoneNum] = fpixels;
		_FSPixelsCache[offset + zoneNum] = -1;
	    }
	    else if (scale == cacheXScale)
	    {
		_FSScaledFPixelsCache[offset + zoneNum] = fpixels;
	    }
	    else
	    {
		_FSClearScaledXCache();
		cacheXScale = scale;
		_FSScaledFPixelsCache[offset + zoneNum] = fpixels;
		_FSScaledPixelsCache[offset + zoneNum] = -1;
	    }
	}
	else
	{
	    _FSAssert (FALSE);
	}
    }
    else
    {
	offset = cacheYOffsets[charNum];
	if (offset >= 0)	/* Char/dim loaded? */
	{
	    if (scale == 1.0)
	    {
		_FSFPixelsCache[offset + zoneNum] = fpixels;
		_FSPixelsCache[offset + zoneNum] = -1;
	    }
	    else if (scale == cacheYScale)
	    {
		_FSScaledFPixelsCache[offset + zoneNum] = fpixels;
	    }
	    else
	    {
		_FSClearScaledYCache();
		cacheYScale = scale;
		_FSScaledFPixelsCache[offset + zoneNum] = fpixels;
		_FSScaledPixelsCache[offset + zoneNum] = -1;
	    }
	}
	else
	{
	    _FSAssert (FALSE);
	}
    }
}


void _FSClearXCache(void)
/* Called by _FSReinitCache() to clear cached values of pixels and fpixels in
   X dimension.	*/
{
    Int16 i, offset, noZones, zoneNum;
    uInt16 charNum;

    for (i = 0; i < cacheNumXChars; i++)
    {
	charNum = cacheCharXList[i];	/* Get next char with X zone data in cache */ 
	offset = cacheXOffsets[charNum];
	if (offset >= 0)	/* Character cached? */
	{
	    noZones = cacheNumXZones[charNum];
	    for (zoneNum = 0; zoneNum < noZones; zoneNum++)
	    {
		_FSPixelsCache[offset + zoneNum] = -1;
		_FSFPixelsCache[offset + zoneNum] = -1.0;
	    }
	}
	else
	{
	    _FSAssert (FALSE);
	}
    }
}


void _FSClearYCache(void)
/* Called by _FSReinitCache() to clear cached values of pixels and fpixels in
   Y dimension.	*/
{
    Int16 i, offset, noZones, zoneNum;
    uInt16 charNum;

    for (i = 0; i < cacheNumYChars; i++)
    {
	charNum = cacheCharYList[i];	/* Get next char with Y zone data in cache */ 
	offset = cacheYOffsets[charNum];
	if (offset >= 0)	/* Character cached? */
	{
	    noZones = cacheNumYZones[charNum];
	    for (zoneNum = 0; zoneNum < noZones; zoneNum++)
	    {
		_FSPixelsCache[offset + zoneNum] = -1;
		_FSFPixelsCache[offset + zoneNum] = -1.0;
	    }
	}
	else
	{
	    _FSAssert (FALSE);
	}
    }
}


void _FSClearScaledXCache(void)
/* Called by _FSCachePixels() and _FSCacheFPixels() to clear scaled pixels and
   scaled fpixels cache in X dimension.	*/
{
    Int16 i, offset, noZones, zoneNum;
    uInt16 charNum;

    for (i = 0; i < cacheNumXChars; i++)
    {
	charNum = cacheCharXList[i];	/* Get next char with X zone data in cache */ 
	offset = cacheXOffsets[charNum];
	if (offset >= 0)	/* Character cached? */
	{
	    noZones = cacheNumXZones[charNum];
	    for (zoneNum = 0; zoneNum < noZones; zoneNum++)
	    {
		_FSScaledPixelsCache[offset + zoneNum] = -1;
		_FSScaledFPixelsCache[offset + zoneNum] = -1.0;
	    }
	}
	else
	{
	    _FSAssert (FALSE);
	}
    }
}


void _FSClearScaledYCache(void)
/* Called by _FSCachePixels() and _FSCacheFPixels() to clear scaled pixels and
   scaled fpixels cache in Y dimension.	*/
{
    Int16 i, offset, noZones, zoneNum;
    uInt16 charNum;

    for (i = 0; i < cacheNumYChars; i++)
    {
	charNum = cacheCharYList[i];	/* Get next char with Y zone data in cache */ 
	offset = cacheYOffsets[charNum];
	if (offset >= 0)	/* Character cached? */
	{
	    noZones = cacheNumYZones[charNum];
	    for (zoneNum = 0; zoneNum < noZones; zoneNum++)
	    {
		_FSScaledPixelsCache[offset + zoneNum] = -1;
		_FSScaledFPixelsCache[offset + zoneNum] = -1.0;
	    }
	}
	else
	{
	    _FSAssert (FALSE);
	}
    }
}


void _FSGetCacheNoZones(
    uInt16	charNum,	/* Character offset */
    Int16	dimension,	/* 0 if x zone, 1 if y zone */
    Int16	*pnoZones)
/* Called by _FSMakeEdgeList() and _FSAllocPixels() to get the number of zones
   in the specified dimension of the specified character. The zone data is
   assumed to be cached if it exists. If the specified character/dimension
   is not in the cache, it is concluded that no zone data exists.	*/
{
    if (dimension == X_DIMENSION)
    {
	if (cacheXOffsets[charNum] >= 0)
	{
	    *pnoZones = cacheNumXZones[charNum];
	    return;
	}
    }
    else
    {
	if (cacheYOffsets[charNum] >= 0)
	{
	    *pnoZones = cacheNumYZones[charNum];
	    return;
	}
    }

    /* Zone data for character/dimension not in cache */
    *pnoZones = 0;    /* Assume character/dimension has no zone data */
}


void _FSGetCacheData(
    uInt16	charNum,	/* Character offset */
    Int16	dimension,	/* 0 if x zone, 1 if y zone */
    Int16	zoneNum,	/* Zone number */
    Int32	*pfrom,
    Int32	*pto,
    uInt16	*pflags,
    uInt16	**ppfunct)
/* Called by _FSMakeEdgeList(), _FSAllocPixels(), _FSGetFPixels(), _FSGetPixels() and
   _FSMakePathMask() to extract all zone data for the specified zone in the specified
   dimension of the specified character. The zone data is assumed to be in the
   cache.	*/
{
    Int16 offset;

    if (dimension == X_DIMENSION)
    {
	if (cacheXOffsets[charNum] >= 0)
	{
	    if (zoneNum < cacheNumXZones[charNum])
	    {
		offset = cacheXOffsets[charNum] + zoneNum;
		*pfrom = _FSFromCache[offset];
		*pto = _FSToCache[offset];
		*pflags = _FSFlagsCache[offset];
		*ppfunct = _FSFuncCache[offset];
	    }
	    else
		_FSAssert (FALSE);
	}
	else
	    _FSAssert (FALSE);
    }
    else
    {
	if (cacheYOffsets[charNum] >= 0)
	{
	    if (zoneNum < cacheNumYZones[charNum])
	    {
		offset = cacheYOffsets[charNum] + zoneNum;
		*pfrom = _FSFromCache[offset];
		*pto = _FSToCache[offset];
		*pflags = _FSFlagsCache[offset];
		*ppfunct = _FSFuncCache[offset];
	    }
	    else
		_FSAssert (FALSE);
	}
	else
	    _FSAssert (FALSE);
    }
}


Boolean _FSCachedPixels(charNum, dimension, zoneNum, scale, ppixels)
uInt16	charNum;	/* Character offset */
Int16	dimension;	/* 0 if x zone, 1 if y zone */
Int16	zoneNum;	/* Zone number */
Real	scale;		/* Scale factor */
Int16	*ppixels;
/* Called by _FSMakeEdgeList() and _FSGetPixels() to get cached value of
   rounded pixels for the specified zone in the specified dimension of the
   specified character. A returned value of false indicates that no value
   is in the cache.	*/
{
    Int16 offset;
    Int16 pixels;

    if (dimension == X_DIMENSION)
    {
	offset = cacheXOffsets[charNum];
	if (offset >= 0)	/* Character in offset table? */
	{
	    if (scale == 1.0)
	    {
		pixels = _FSPixelsCache[offset + zoneNum];
		if (pixels >= 0)	/* Pixels cached for zone? */
		{
		    *ppixels = pixels;
		    return(1);
		}
	    }
	    else if (scale == cacheXScale)
	    {
		pixels = _FSScaledPixelsCache[offset + zoneNum];
		if (pixels >= 0)	/* Scaled pixels cached for zone? */
		{
		    *ppixels = pixels;
		    return(1);
		}
	    }
	}
    }
    else
    {
	offset = cacheYOffsets[charNum];
	if (offset >= 0)	/* Character in offset table? */
	{
	    if (scale == 1.0)
	    {
		pixels = _FSPixelsCache[offset + zoneNum];
		if (pixels >= 0)	/* Pixels cached for zone? */
		{
		    *ppixels = pixels;
		    return(1);
		}
	    }
	    else if (scale == cacheYScale)
	    {
		pixels = _FSScaledPixelsCache[offset + zoneNum];
		if (pixels >= 0)	/* Scaled pixels cached for zone? */
		{
		    *ppixels = pixels;
		    return(1);
		}
	    }
	}
    }

    *ppixels = 0;	/* zone not in cache; returns 0 pixels */
    return(0);
}


Boolean _FSCachedFPixels(charNum, dimension, zoneNum, scale, pfpixels)
uInt16	charNum;	/* Character offset */
Int16	dimension;	/* 0 if x zone, 1 if y zone */
Int16	zoneNum;	/* Zone number */
Real	scale;		/* Scale factor */
Real	*pfpixels;
/* Called by _FSGetFPixels() to get cached value of unrounded pixels for the
   specified zone in the specified dimension of the specified character.
   A returned value of false indicates that no value is in the cache.	*/
{
    Int16 offset;
    Real fpixels;

    if (dimension == X_DIMENSION)
    {
	offset = cacheXOffsets[charNum];
	if (offset >= 0)	/* Character in offset table? */
	{
	    if (scale == 1.0)
	    {
		fpixels = _FSFPixelsCache[offset + zoneNum];
		if (fpixels >= 0.0)	/* Pixels cached for zone? */
		{
		    *pfpixels = fpixels;
		    return(1);
		}
	    }
	    else if (scale == cacheXScale)
	    {
		fpixels = _FSScaledFPixelsCache[offset + zoneNum];
		if (fpixels >= 0.0)	/* Scaled pixels cached for zone? */
		{
		    *pfpixels = fpixels;
		    return(1);
		}
	    }
	}
    }
    else
    {
	offset = cacheYOffsets[charNum];
	if (offset >= 0)	/* Character in offset table? */
	{
	    if (scale == 1.0)
	    {
		fpixels = _FSFPixelsCache[offset + zoneNum];
		if (fpixels >= 0.0)	/* Pixels cached for zone? */
	    {
		    *pfpixels = fpixels;
		    return(1);
		}
	    }
	    else if (scale == cacheYScale)
	    {
		fpixels = _FSScaledFPixelsCache[offset + zoneNum];
		if (fpixels >= 0.0)	/* Scaled pixels cached for zone? */
		{
		    *pfpixels = fpixels;
		    return(1);
		}
	    }
	}
    }
    *pfpixels = 0.;	/* zone not in cache; returns 0. pixels */
    return(0);
}
