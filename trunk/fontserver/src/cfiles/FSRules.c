/* $RCSfile: fsrules.c $$Revision: 1.4 $$Date: 1992/10/25 09:56:21 $ Copyright (c) 1990 Intergraph Corp. */


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


/***************************************************************************

    This module contains the logic for handling bitmap refinement rules.

 ***************************************************************************/


/****************************** F S R u l e s . c **************************
 ********************* R E V I S I O N   H I S T O R Y *********************

 1)  12-Nov-86  jsc	Installed automatic cache clearing mechanism to clear the
			cache and retry pixel allocation in case of cache overflow

 2)  14-Nov-86  jsc	Eliminated swap_ufix16() and swap_double() in favor of
			in-line code in _FSMakeEdgeList().

			Eliminated unpack_prop_flag(), unpack_level_flag(),
			unpack_cont_flag(), unpack_fn_flag() and unpack_min() in
			favor of masks defined in mkbm.h to extract packed fields.

 3)  27-Nov-86  jsc	_FSGetPixels() corrected to ensure correct interdimensional
			scaling for P and T items.

 4)  30-Dec-86  jsc	Added nominal scale factors for x and y to arg list
			of _FSSetupTrans().

			Nominal x scale used for pixel allocation and cache selection

 5)  22-Mar-87  jsc	_FSMakeYTransList() updated to correct definition of
			vertical position referenced to top of emsquare.

 6)   7-Apr-87  mby	fixed bugs in 'make_x_trans_table': 1) compound X trans
			table should never be overwritten. 2) store real #s in
			comp_x_pixel_tbl (which must be declared float).

 7)   8-Apr-87  mby	In _FSGetPixels() change root zone rounding from .495 to .499

 8)   7-May-87  mby	In _FSMakePathMask(), fix bug that occurs when 3 or more
			zones are on the same level (change 'if' to 'while')

 8)  13-May-87  mby	Fix error in transformation functions when
			pointSizeX != pointSizeY

 ****************************************************************************/


#include "../hfiles/import.h"
#include <math.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSMakeFont.h"



/** Some of the following arrays are not declared as static due to their **/
/** large size (static variables are stored as initialized data) **/

static	TFStruct *cfontp;	/* pointer to compr font structure */
static	Real	angleRot;	/* rotation angle in degrees (clockwise)   */
static	Real	angleObl;	/* obliquing angle in degrees (clockwise)  */
static	Real	outlres;	/* font outline resl/em in outline units */
static	uInt16	*pFirstRec;	/* ptr to first outline data record in font */
static	Real	hPixPerORU;	/* horizontal pixels per outline resolution unit */
static	Real	vPixPerORU;	/* vertical pixels per outline resolution unit */
static	Real	xPixPerORU;	/* x pixels per outline resolution unit */
static	Real	pointSizeX;	/* x point size */
static	Real	pointSizeY;	/* y point size */
static	Real	xDistortion;	/* = pointSizeX / pointSizeY */
static	Real	pixInchHor;	/* horizontal pixels per inch */
static	Real	pixInchVer;	/* vertical pixels per inch */
static	Real	sinrot, cosrot;	/* sine, cosine of rotation angle */
static	Real	tanobl;		/* tangent of obliquing angle */
static	Boolean	cacheOverflow;	/* Cache overflow flag */
static	Boolean	xZoneDataValid; /* true if x zone data valid */
static	Boolean	yZoneDataValid; /* true if y zone data valid */
static	Real	xPixelsPerEm;	/* Number of pixels per em in char x dimension */
static	Real	yPixelsPerEm;	/* Number of pixels per em in char y dimension */
static	uInt16	rootCharNo;	/* Root character number */
static	uInt16	charNo;		/* Current character or sub-character number */
static	Real	xScaleNom, yScaleNom; /* x and y nominal scale factors */
static	Real	xScale, yScale; /* x and y scale factors */
static	Real	xPos, yPos;	/* x and y offsets */
	Real	_FSEdges[MAX_ZONES_PER_DIM] = { 0 };
	Int16	_FSPixels[MAX_ZONES_PER_DIM] = { 0 };
static	Boolean	swFixed;	/* True if set width constrained */
static	Real	xHtAdj;		/* x-height adj factor (always 1.0) */


/* Storage for transformation data  for current character */
static	Int16	noXXTransforms;	/* No transforms for computing x from x */
static	Int16	noXYTransforms;	/* No transforms for computing x from y */
	Real	_FSXORUs[MAX_ZONES_PER_DIM] = { 0.0 };	/* Original x coord list */
	Int16	_FSXPixels[MAX_ZONES_PER_DIM] = { 0 };	/* Transformed x coord list */
	Real	_FSXMultTbl[MAX_ZONES_PER_DIM] = { 0.0 }; /* Transformation multiplier */
	Real	_FSXOffsetTbl[MAX_ZONES_PER_DIM] = { 0.0 }; /* Transformation offset */
static	Real	xxMult;	/* coeff of x for computing x from x and y */
static	Real	xyMult;	/* coeff of y for computing x from x and y */
static	Real	xOffset;	/* constant for computing x from x and y   */

static	Int16	noYXTransforms;	/* No transforms for computing y from x */
static	Int16	noYYTransforms;	/* No transforms for computing y from y */
	Real	_FSYORUs[MAX_ZONES_PER_DIM] = { 0.0 };	/* Original x coord list */
	Int16	_FSYPixels[MAX_ZONES_PER_DIM] = { 0 };	/* Transformed x coord list */
	Real	_FSYMultTbl[MAX_ZONES_PER_DIM] = { 0.0 }; /* Transformation multiplier */
	Real	_FSYOffsetTbl[MAX_ZONES_PER_DIM] = { 0.0 }; /* Transformation offset */
static	Real	yxMult;	/* coeff of x for computing y from x and y */
static	Real	yyMult;	/* coeff of x for computing y from x and y */
static	Real	yOffset;	/* constant for computing y from x and y   */

/* Compound character transformation data */
static	Int16	noCompXEdges;
	Real	_FSCompXEdgeTbl[MAX_ZONES_PER_COMP_DIM] = { 0.0 };
	Real	_FSCompXPixelTbl[MAX_ZONES_PER_COMP_DIM] = { 0.0 };



void _FSInitTrans(cfont, charNr, pSizeX, pSizeY, resHor, resVer,
		 rotAngle, oblAngle)
TFStruct *cfont;	/* ptr to compressed font structure */
Int32	charNr;		/* Root character number offset */
Real	pSizeX;		/* x pointsize */
Real	pSizeY;		/* y pointsize */
Real	resHor;		/* horizontal pixels per inch */
Real	resVer;		/* vertical pixels per inch */
Real	rotAngle;	/* rotation angle in degrees (clockwise) */
Real	oblAngle;	/* obliquing angle in degrees (clockwise) */
/* Called before start of reading root character */
/* Initializes transformation data for current character. */
/* Clears cache if any parameter has changed to invalidate cached data */
{
    Real	x, y;
    void	_FSReinitCache();	/* Inits cache if pixel/em changes */


    cfontp = cfont;
    rootCharNo = charNr;
    outlres = (Real) cfont->info.reslPerEm;
    pointSizeX = pSizeX;
    pointSizeY = pSizeY;
    xDistortion = pointSizeX / pointSizeY;
    pixInchHor = resHor;
    pixInchVer = resVer;
    angleRot = rotAngle;
    angleObl = oblAngle;
    hPixPerORU = pointSizeY * pixInchHor / (PTPERINCH * outlres);	/* this is NOT a bug */
    vPixPerORU = pointSizeY * pixInchVer / (PTPERINCH * outlres);
    sinrot = sin(angleRot * PI / 180.);
    cosrot = cos(angleRot * PI / 180.);
    tanobl = tan(angleObl * PI / 180.);
    x = pixInchHor * cosrot;
    y = pixInchVer * sinrot;
    xPixPerORU = (pointSizeX / (PTPERINCH * outlres)) * sqrt(x * x + y * y);
    noCompXEdges = 0;

    _FSReinitCache (pSizeX, pSizeY, resHor, resVer, rotAngle, oblAngle);
}


void _FSSetupTrans(noChar, scaleXNom, scaleYNom, scaleX, scaleY,
		   posX, posY, compc)
uInt16	noChar;
Real	scaleXNom;
Real	scaleYNom;
Real	scaleX;
Real	scaleY;
Real	posX;
Real	posY;
CompCharDesc *compc;	/* scan conversion parameters */
/* Called by _FSCharScanConvert() at the start of the first curve in	*/
/* the outline data for the root character and all subcharacters.	*/
/* Sets up transformation data for specified scale factors and offsets	*/
/* in both x and y using current values of point size in x and y,	*/
/* horiz. and vertical resolution, rotation angle and obliquing angle.	*/
{
    Int16   direction;

    _FSClosePutCacheData();	/* Terminate reading zone data */

    charNo = noChar;
    xScaleNom = scaleXNom;
    yScaleNom = scaleYNom;
    xScale = scaleX;
    yScale = scaleY;
    xPos = posX;
    yPos = posY;
    xHtAdj = compc->xHtAdj;
    swFixed = compc->swFixed;

    if (compc->bogusMode)	/* Ignore plaid data? */
    {
	xZoneDataValid = FALSE;
	_FSSetupXXYTrans();

	yZoneDataValid = FALSE;
	_FSSetupYXYTrans();
    }
    else if (angleRot == 0.0)
    {
	xPixelsPerEm = pointSizeX * pixInchHor / PTPERINCH;
	yPixelsPerEm = pointSizeY * pixInchVer / PTPERINCH;

	yZoneDataValid = TRUE;
	if (angleObl == 0.0)
	{
	    xZoneDataValid = TRUE;
	    direction = 1;
	    _FSSetupXXTrans(direction);
	}
	else
	{
	    xZoneDataValid = FALSE;
	    _FSSetupXXYTrans();
	}

	direction = 1;
	_FSSetupYYTrans(direction);
    }
    else if (((angleRot + angleObl) == 0.0) || ((angleRot + angleObl) == 360.0))
    {
	xPixelsPerEm = pointSizeX * pixInchHor / PTPERINCH;
	yPixelsPerEm = pointSizeY * pixInchVer / PTPERINCH;

	xZoneDataValid = TRUE;
	direction = 1;
	_FSSetupXXTrans(direction);

	yZoneDataValid = FALSE;
	_FSSetupYXYTrans();
    }
    else if (angleRot == 90.0)
    {
	xPixelsPerEm = pointSizeX * pixInchVer / PTPERINCH;
	yPixelsPerEm = pointSizeY * pixInchHor / PTPERINCH;

	yZoneDataValid = TRUE;
	direction = 1;
	_FSSetupXYTrans(direction);

	if (angleObl == 0.0)
	{
	    xZoneDataValid = TRUE;
	    direction = -1;
	    _FSSetupYXTrans(direction);
	}
	else
	{
	    xZoneDataValid = FALSE;
	    _FSSetupYXYTrans();
	}
    }
    else if ((angleRot + angleObl) == 90.0)
    {
	xPixelsPerEm = pointSizeX * pixInchVer / PTPERINCH;
	yPixelsPerEm = pointSizeY * pixInchHor / PTPERINCH;

	yZoneDataValid = FALSE;
	_FSSetupXXYTrans();

	xZoneDataValid = TRUE;
	direction = -1;
	_FSSetupYXTrans(direction);
    }
    else if (angleRot == 180.0)
    {
	xPixelsPerEm = pointSizeX * pixInchHor / PTPERINCH;
	yPixelsPerEm = pointSizeY * pixInchVer / PTPERINCH;

	yZoneDataValid = TRUE;
	if (angleObl == 0.0)
	{
	    xZoneDataValid = TRUE;
	    direction = -1;
	    _FSSetupXXTrans(direction);
	}
	else
	{
	    xZoneDataValid = FALSE;
	    _FSSetupXXYTrans();
	}

	direction = -1;
	_FSSetupYYTrans(direction);
    }
    else if ((angleRot + angleObl) == 180.0)
    {
	xPixelsPerEm = pointSizeX * pixInchHor / PTPERINCH;
	yPixelsPerEm = pointSizeY * pixInchVer / PTPERINCH;

	xZoneDataValid = TRUE;
	direction = -1;
	_FSSetupXXTrans(direction);

	yZoneDataValid = FALSE;
	_FSSetupYXYTrans();
    }
    else if (angleRot == 270.0)
    {
	xPixelsPerEm = pointSizeX * pixInchVer / PTPERINCH;
	yPixelsPerEm = pointSizeY * pixInchHor / PTPERINCH;

	yZoneDataValid = TRUE;
	direction = -1;
	_FSSetupXYTrans(direction);

	if (angleObl == 0.0)
	{
	    xZoneDataValid = TRUE;
	    direction = 1;
	    _FSSetupYXTrans(direction);
	}
	else
	{
	    xZoneDataValid = FALSE;
	    _FSSetupYXYTrans();
	}
    }
    else if ((angleRot + angleObl) == 270.0)
    {
	xPixelsPerEm = pointSizeX * pixInchVer / PTPERINCH;
	yPixelsPerEm = pointSizeY * pixInchHor / PTPERINCH;

	yZoneDataValid = FALSE;
	_FSSetupXXYTrans();

	xZoneDataValid = TRUE;
	direction = 1;
	_FSSetupYXTrans(direction);
    }
    else
    {
	xZoneDataValid = FALSE;
	_FSSetupXXYTrans();

	yZoneDataValid = FALSE;
	_FSSetupYXYTrans();
    }
}


_FSSetupXXTrans(direction)
Int16	direction;
/* Called by _FSSetupTrans() to set up zoned transformation for x as a
   function of x only.
   Direction may be positive (+1) or negative (-1). */
{
    Int16   n;
    Boolean _FSAllocPixels();

    if (!_FSAllocPixels(charNo, X_DIMENSION))
    {
	if (!_FSAllocPixels(charNo, X_DIMENSION))
	{
	    _FSSetupXXYTrans();
	    return;
	}
    }
    _FSMakeEdgeList(charNo, X_DIMENSION, xScaleNom, &n);
    _FSMakeXTransList (n, direction, _FSXORUs, _FSXPixels);
    _FSMakeTransTable (xPixelsPerEm, xScale, xPos, direction, _FSXORUs,
		       _FSXPixels,  n, _FSXMultTbl, _FSXOffsetTbl,
		       &noXXTransforms);
    noXYTransforms = -1;
}


_FSSetupXYTrans(direction)
Int16	direction;
/* Called by _FSSetupTrans() to set up zoned transformation for x as a
   function of y only.
   Direction may be positive (+1) or negative (-1). */
{
    Int16	n;
    Boolean	_FSAllocPixels();

    if (!_FSAllocPixels(charNo, Y_DIMENSION))
    {
	if (!_FSAllocPixels(charNo, Y_DIMENSION))
	{
	    _FSSetupXXYTrans();
	    return;
	}
    }
    _FSMakeEdgeList(charNo, Y_DIMENSION, yScale, &n);
    _FSMakeYTransList (n, direction, _FSXORUs, _FSXPixels);
    _FSMakeTransTable (yPixelsPerEm, yScale, yPos, direction, _FSXORUs,
		       _FSXPixels,  n, _FSXMultTbl, _FSXOffsetTbl,
		       &noXYTransforms);
    noXXTransforms = -1;
}


_FSSetupXXYTrans()
/* Called by _FSSetupTrans() to set up general transformation for x as a
   function of both x and y. */
{
    xxMult = cosrot * xDistortion * xScale * hPixPerORU;
    xyMult = (sinrot + cosrot * tanobl) * yScale * hPixPerORU;
    xOffset = (xPos * cosrot + yPos * (sinrot + cosrot * tanobl)) * hPixPerORU;
    noXXTransforms = -1;
    noXYTransforms = -1;
}


_FSSetupYXTrans(direction)
Int16	direction;
/* Called by _FSSetupTrans() to set up zoned transformation for y as a
   function of x only.
   Direction may be positive (+1) or negative (-1). */
{
    Int16	n;
    Boolean	_FSAllocPixels();

    if (!_FSAllocPixels(charNo, X_DIMENSION))
    {
	if (!_FSAllocPixels(charNo, X_DIMENSION))
	{
	    _FSSetupYXYTrans();
	    return;
	}
    }
    _FSMakeEdgeList(charNo, X_DIMENSION, xScaleNom, &n);
    _FSMakeXTransList (n, direction, _FSYORUs, _FSYPixels);
    _FSMakeTransTable (xPixelsPerEm, xScale, xPos, direction, _FSYORUs,
		       _FSYPixels, n, _FSYMultTbl, _FSYOffsetTbl,
		       &noYXTransforms);
    noYYTransforms = -1;
}


_FSSetupYYTrans(direction)
Int16	direction;
/* Called by _FSSetupTrans() to set up zoned transformation for y as a
   function of y only.
   Direction may be positive (+1) or negative (-1). */
{
    Int16	n;
    Boolean	_FSAllocPixels();

    if (!_FSAllocPixels(charNo, Y_DIMENSION))
    {
	if (!_FSAllocPixels(charNo, Y_DIMENSION))
	{
	    _FSSetupYXYTrans();
	    return;
	}
    }
    _FSMakeEdgeList(charNo, Y_DIMENSION, yScale, &n);
    _FSMakeYTransList (n, direction, _FSYORUs, _FSYPixels);
    _FSMakeTransTable (yPixelsPerEm, yScale, yPos, direction, _FSYORUs,
		       _FSYPixels, n, _FSYMultTbl, _FSYOffsetTbl,
		       &noYYTransforms);
    noYXTransforms = -1;
}


_FSSetupYXYTrans()
/* Called by _FSSetupTrans() to set up general transformation for y as a
   function of both x and y. */
{
    yxMult = -sinrot * xDistortion * xScale * vPixPerORU;
    yyMult = (cosrot - sinrot * tanobl) * yScale * vPixPerORU;
    yOffset = (yPos * (cosrot - sinrot * tanobl) - xPos * sinrot) * vPixPerORU;
    noYXTransforms = -1;
    noYYTransforms = -1;
}


Boolean _FSAllocPixels(charNum, dimension)
uInt16	charNum;	/* Character number */
Int16	dimension;	/* Dimension */
/* Called by _FSSetup...Trans to compute and cache the pixel allocations for
   all zones in the specified dimension of the specified character.
   Returns TRUE if sufficient cache capacity to complete pixel allocation.
   If cache overflow occurs, the cache is cleared together with the cache
   overflow flag and FALSE is returned. */
{
    Int32	to, from;
    uInt16	flags;
    uInt16	*pfunct;
    Real	scale, baseORUs, basePixels;
    Real	fpixelsInZone;
    Int16	pixelsAvailable, pixelsInZone;
    Int32	orusInZone, orusAvailable;
    Int32	queue[32];
    Int16	queuePut, queueGet;
    Int16	i, noZones;
    Int16	moreZones;
    Int16	_FSGetPixels();
    Boolean	_FSCacheData();

    cacheOverflow = FALSE;	/* Initialize cache overflow flag */
    if (!_FSCacheData(charNum, dimension, cfontp, pFirstRec)) /* Ensure data in cache */
    {
	_FSInitCache(xPixelsPerEm, yPixelsPerEm);	/* Clear cache */
	return(FALSE);	/* Indicate pixel allocation not done */
    }

    _FSGetCacheNoZones(charNum, dimension, &noZones);
    if (noZones == 0)	/* No zone data in this dimension? */
	return(TRUE);

    /* Compute pixels in top level zone */
    _FSGetCacheData(charNum, dimension, 0, &from, &to, &flags, &pfunct);
    orusInZone = to - from;
    if (dimension == X_DIMENSION)
    {
	scale = xScaleNom;
	basePixels = xPixelsPerEm * xScale;
    }
    else
    {
	scale = yScale;
	basePixels = yPixelsPerEm * yScale;
    }
    baseORUs = outlres;
    fpixelsInZone = (orusInZone / baseORUs) * basePixels;
    _FSCacheFPixels(charNum, dimension, 0, fpixelsInZone, scale);
    pixelsInZone = _FSGetPixels(charNum, dimension, 0, scale);
    if (cacheOverflow)
    {
	_FSInitCache(xPixelsPerEm, yPixelsPerEm);
	cacheOverflow = FALSE;
	return(FALSE);
    }

    if (noZones == 1)	/* No child zone data in this dimension? */
	return(TRUE);

    queuePut = queueGet = 0;	/* Set up empty queue */
    queue[queuePut++] = orusInZone;
    queue[queuePut++] = pixelsInZone;
    i = 1;
    while (queueGet < queuePut)	/* Queue not yet empty? */
    {
	orusAvailable = queue[queueGet++];
	pixelsAvailable = queue[queueGet++];
	moreZones = 1;	/* Assume at least one zone */
	while (moreZones)
	{
	    _FSGetCacheData(charNum, dimension, i, &from, &to, &flags, &pfunct);
	    orusInZone = to - from;
	    if ((flags & MASK_L_FLAG) &&
		((dimension == Y_DIMENSION) || swFixed))	/* New level? */
	    {
		basePixels = (Real)pixelsAvailable;
		baseORUs = (Real)orusAvailable;
	    }
	    if (orusInZone == 0.0)
		fpixelsInZone = 0.0;
	    else
		fpixelsInZone = (orusInZone / baseORUs) * basePixels;
	    _FSCacheFPixels(charNum, dimension, i, fpixelsInZone, scale);
	    pixelsInZone = _FSGetPixels(charNum, dimension, i, scale);
	    if (cacheOverflow)	/* Cache overflow? */
	    {
		_FSInitCache(xPixelsPerEm, yPixelsPerEm);
		cacheOverflow = FALSE;
		return(FALSE);
	    }
	    orusAvailable -= orusInZone;
	    pixelsAvailable -= pixelsInZone;
	    if (flags & MASK_P_FLAG)	/* Parent zone? */
	    {
		queue[queuePut++] = orusInZone;
		queue[queuePut++] = pixelsInZone;
	    }
	    moreZones = flags & MASK_C_FLAG;
	    i++;
	}
    }
    _FSAssert (i == noZones);

    return(TRUE);
}


Int16 _FSGetPixels(charNum, dimension, zoneNo, scale)
uInt16	charNum;	/* Character number */
Int16	dimension;	/* Dimension */
Int16	zoneNo;	/* Zone number */
Real	scale;	/* Scale factor */
/* Called by _FSAllocPixels(), _FSGetPixels() and _FSGetFPixels() to calculate the
   integral number of pixels allocated to the specified zone in the specified
   dimension of the specified character.
   Returns the number of pixels allocated.
   Sets cacheOverflow TRUE if cache overflow occurs. */
{
    Int16	pixls, minPixels;
    uInt16	newCharNo;
    Int16	newDimension, newZoneNo;
    Real	*stackPointer;
    Real	fpixels, constant;
    Real	stack[10];
    Int32	from, to;
    Int32	x, y;
    uInt16	flags, fnFlag, dimensionFlag, opCode, termFlag;
    uInt16	*pfunct;
    Int16	_FSIsCPItem(), _FSIsCFItem(), _FSIsCTItem();
    Int16	_FSIsCConstItem(), _FSIsCOpItem();
    Real	_FSGetFPixels();
    Real	_FSGetTPixels();
    Boolean	_FSCacheData();
    Boolean	_FSCachedPixels();


    /* Check if pixels previously calculated for specified zone */
    if (_FSCachedPixels(charNum, dimension, zoneNo, scale, &pixls))
	return(pixls);

    /* Ensure that zone data is in the cache */
    if (!_FSCacheData(charNum, dimension, cfontp, pFirstRec))
    {
	cacheOverflow = TRUE;
	return(0);
    }

    _FSGetCacheData(charNum, dimension, zoneNo, &from, &to, &flags, &pfunct);
    fnFlag = flags & MASK_FN_FLAG;
    if (fnFlag == 0)	/* No constraint function? */
    {
	/* Get Real value for pixels */
	fpixels = _FSGetFPixels(charNum, dimension, zoneNo, scale);
	if (zoneNo != 0)	/* Not root zone? */
	{
	    pixls = fpixels + 0.5;	/* Round to nearest whole number of pixels */
	}
	else
	{
	    pixls = fpixels + 0.499;	/* Prefer to round down for root zone */
	}
    }
    else
    {
	stackPointer = stack;	/* Initialize function execution stack ptr */
	while(fnFlag)
	{
	    if (fnFlag == FN_ONE_ITEM)	/* One item in constraint function? */
		fnFlag = 0;		/* Exit after one cycle */

	    if (_FSIsCPItem(&pfunct, &newCharNo, &dimensionFlag, &newZoneNo)) /* P item? */
	    {
		if (dimensionFlag)	/* Zone refers to other dimension? */
		{
		    if (dimension == X_DIMENSION)	/* This dimension is X? */
		    {
			newDimension = Y_DIMENSION;	/* Other dimension must be Y */
			if (yZoneDataValid)		/* Plaid valid in other dimension? */
			{
			    pixls = _FSGetPixels(newCharNo, newDimension, newZoneNo, yScale);
			    pixls = (pixls * xPixelsPerEm * xScaleNom) /
				    (yPixelsPerEm * yScale) + 0.5;
			}
			else
			{
			    _FSGetCacheData(newCharNo, newDimension, newZoneNo,
					    &from, &to, &flags, &pfunct);
			    pixls = ((to - from) * xPixelsPerEm * xScaleNom /
				     outlres) + 0.5;
			}
		    }
		    else	/* This dimension is Y? */
		    {
			newDimension = X_DIMENSION;	/* Other dimension must be X */
			if (xZoneDataValid)		/* Plaid valid in other dimension? */
			{
			    pixls = _FSGetPixels(newCharNo, newDimension,
						 newZoneNo, xScaleNom);
			    pixls = (pixls * yPixelsPerEm * yScale) /
				    (xPixelsPerEm * xScaleNom) + 0.5;
			}
			else	/* Plaid not valid in other dimension? */
			{
			    _FSGetCacheData(newCharNo, newDimension, newZoneNo,
					    &from, &to, &flags, &pfunct);
			    pixls = ((to - from) * yPixelsPerEm * yScale /
				     outlres) + 0.5;
			}
		    }
		}
		else	/* Zone refers to this dimension? */
		{
		    pixls = _FSGetPixels(newCharNo, dimension, newZoneNo,
					 scale);
		}
		if (cacheOverflow)		/* Cache overflow? */
		    return(0);

		*(stackPointer++) = pixls;	/* Push rounded pixels onto execution stack */
		continue;
	    }
    
	    else if (_FSIsCFItem(&pfunct, &newCharNo, &dimensionFlag,
				 &newZoneNo)) /* F item? */
	    {
		if (dimensionFlag)	/* Zone refers to other dimension? */
		{
		    if (dimension == X_DIMENSION)	/* This dimension is X? */
		    {
			newDimension = Y_DIMENSION;	/* Other dimension must be Y */
			if (yZoneDataValid)		/* Plaid data valid in other dimension? */
			{
			    fpixels = _FSGetFPixels(newCharNo, newDimension,
						    newZoneNo, yScale);
			    fpixels = fpixels * xPixelsPerEm * xScaleNom /
				      (yPixelsPerEm * yScale);
			}
			else	/* Plaid data not valid in other dimension? */
			{
			    _FSGetCacheData(newCharNo, newDimension, newZoneNo,
					    &from, &to, &flags, &pfunct);
			    fpixels = ((to - from) * xPixelsPerEm * xScaleNom) / outlres;
			}
		    }
		    else	/* This dimension is Y? */
		    {
			newDimension = X_DIMENSION;	/* Other dimension must be X */
			if (xZoneDataValid)		/* Plaid data valid in other dimension? */
			{
			    fpixels = _FSGetFPixels(newCharNo, newDimension,
						    newZoneNo, yScale);
			    fpixels = fpixels * yPixelsPerEm * yScale /
				      (xPixelsPerEm * xScaleNom);
			}
			else	/* Plaid data not valid in other dimension? */
			{
			    _FSGetCacheData(newCharNo, newDimension, newZoneNo,
					    &from, &to, &flags, &pfunct);
			    fpixels = ((to - from) * yPixelsPerEm * yScale) /
				      outlres;
			}
		    }
		}
		else	/* Zone refers to this dimension? */
		{
		    fpixels = _FSGetFPixels(newCharNo, dimension, newZoneNo,
					    scale);
		}
		if (cacheOverflow)		/* Cache overflow? */
		    return(0);

		*(stackPointer++) = fpixels;	/* Push unrounded pixels onto stack */
		continue;
	    }
    
	    else if (_FSIsCTItem(&pfunct, &newCharNo, &dimensionFlag,
				 &newZoneNo)) /* T item? */
	    {
		if (dimensionFlag)	/* Zone refers to other dimension? */
		{
		    if (dimension == X_DIMENSION)	/* This dimension is X? */
		    {
			newDimension = Y_DIMENSION;	/* Other dimension must be Y */
			if (yZoneDataValid)		/* Plaid data valid in other dimension? */
			{
			    fpixels = _FSGetTPixels(newCharNo, newDimension,
						    newZoneNo, yScale);
			    fpixels = (fpixels * xPixelsPerEm * xScaleNom) /
				      (yPixelsPerEm * yScale);
			}
			else	/* Plaid data not valid in other dimension? */
			{
			    _FSGetCacheData(newCharNo, newDimension, newZoneNo,
					    &from, &to, &flags, &pfunct);
			    fpixels = (to - from) * xPixelsPerEm * xScaleNom /
				      outlres;
			}
		    }
		    else	/* This dimension is Y? */
		    {
			newDimension = X_DIMENSION;	/* Other dimension must be X */
			if (xZoneDataValid)		/* Plaid data valid in other dimension? */
			{
			    fpixels = _FSGetTPixels(newCharNo, newDimension,
						    newZoneNo, xScaleNom);
			    fpixels = (fpixels * yPixelsPerEm * yScale) /
				      (xPixelsPerEm * xScaleNom);
			}
			else
			{
			    _FSGetCacheData(newCharNo, newDimension, newZoneNo,
					    &from, &to, &flags, &pfunct);
			    fpixels = (to - from) * yPixelsPerEm * yScale /
				      outlres;
			}
		    }
		}
		else	/* Zone refers to this dimension? */
		{
		    fpixels = _FSGetTPixels(newCharNo, dimension, newZoneNo,
					    scale);
		}
		if (cacheOverflow)		/* Cache overflow? */
		    return(0);

		*(stackPointer++) = fpixels;	/* Push unrounded pixels onto execution stack */
		continue;
	    }
    
	    else if (_FSIsCConstItem(&pfunct, &x, &y))	/* Constant item? */
	    {
		if (y == 0) constant = (Real)x;
		else if (y == -1) constant = x * 0.1;
		else if (y == -2) constant = x * 0.01;
		else if (y == -3) constant = x * 0.001;
		else if (y == -4) constant = x * 0.0001;
		else if (y == -5) constant = x * 0.00001;
		else if (y == -6) constant = x * 0.000001;
		else
		{
		    /** Error **/
		    constant = 0.0;
		}
		*(stackPointer++) = constant;	/* Push constant onto stack */
		continue;
	    }
    
	    else if (_FSIsCOpItem(&pfunct, &opCode, &termFlag)) /* Operator item? */
	    {
		if (termFlag)		/* Terminating operator? */
		    fnFlag = 0;	/* Exit after this cycle */

		switch (opCode)
		{
		    case 0:				/* NOP operator? */
			continue;

		    case 1:				/* ADD operator? */
			_FSDoAdd(&stackPointer);
			continue;

		    case 2:				/* SUB operator? */
			_FSDoSub(&stackPointer);
			continue;
    
		    case 3:				/* MUL operator? */
			_FSDoMul(&stackPointer);
			continue;

		    case 4:				/* DIV operator? */
			_FSDoDiv(&stackPointer);
			continue;

		    case 5:				/* PRINT operator? */
			_FSDoPrint(&stackPointer);
			continue;
    
		    case 6:				/* FIXR operator? */
			_FSDoFixR(&stackPointer);
			continue;

		    case 7:				/* FIX operator */
			_FSDoFix(&stackPointer);
			continue;
    
		    case 8:				/* CO operator? */
			_FSDoCO(&stackPointer);
			continue;
    
		    case 9:				/* CF operator? */
			_FSDoCF(&stackPointer);
			continue;
    
		    case 10:				/* RRFS operator? */
			_FSDoRRFS(&stackPointer);
			continue;
    
		    case 11:				/* RRHS operator? */
			_FSDoRRHS(&stackPointer);
			continue;
    
		    case 12:				/* RRFS1 operator? */
			_FSDoRRFS1(&stackPointer);
			continue;
    
		    case 13:				/* RRHS1 operator? */
			_FSDoRRHS1(&stackPointer);
			continue;
    
		    case 14:				/* BZON operator? */
			_FSDoBZON(&stackPointer);
			continue;
    
		    case 15:				/* BZON1 operator? */
			_FSDoBZON1(&stackPointer);
			continue;	
    
		    case 16:				/* LZON operator? */
			_FSDoLZON(&stackPointer);
			continue;
    
		    case 17:				/* LZON1 operator? */
			_FSDoLZON1(&stackPointer);
			continue;
    
		    case 18:				/* CFFLB operator? */
			_FSDoCFFLB(&stackPointer);
			continue;
    
		    case 19:				/* CFFRB operator? */
			_FSDoCFFRB(&stackPointer);
			continue;
    
		    case 20:				/* CFSLB operator? */
			_FSDoCFSLB(&stackPointer);
			continue;
    
		    case 21:				/* CFSRB operator? */
			_FSDoCFSRB(&stackPointer);
			continue;
    
		    case 22:				/* XHTADJ operator? */
			_FSDoXHtAdj(xHtAdj, &stackPointer);
			continue;
    
		    default:
			_FSAssert (FALSE);
			continue;
		}
	    }
	    else
	    {
		_FSAssert (FALSE);
	    }
	}
	pixls = *(--stackPointer) + 0.5;	/* Pop top of stack for result */
	_FSAssert (stackPointer == stack);	/* Stack now empty? */
    }
    minPixels = flags & MASK_MIN;
    if (pixls < minPixels)	/* Result less than minimum? */
	pixls = minPixels;	/* Use minimum for result */

    _FSCachePixels(charNum, dimension, zoneNo, pixls, scale);	/* Cache pixels */
    return(pixls);
}


Real  _FSGetFPixels(charNum, dimension, zoneNo, scale)
uInt16	charNum;	/* Character offset */
Int16	dimension;	/* 0 if x zone, 1 if y zone */
Int16	zoneNo;		/* Zone number */
Real	scale; 
/* Returns the number of Real ing pixels allocated to the specified zone in 
   the specified character.
   Sets cacheOverflow TRUE if cache overflow occurs. */
{
    Int32	from, to;
    uInt16	flags;
    uInt16	*pfunct;
    Int16	i;
    Int32	queue[32];
    Int16	queuePut, queueGet;
    Int32	orusInZone, orusAvailable;
    Real	baseORUs, basePixels;
    Real	fpixelsInZone;
    Int16	pixelsAvailable, pixelsInZone;
    Int16	moreZones;
    Boolean	_FSCachedFPixels();
    Real	_FSGetTPixels();
    Boolean	_FSCacheData();
    Boolean	pathMask[MAX_ZONES_PER_DIM];

    /* Check if fpixels previously calculated for specified zone */
    if (_FSCachedFPixels(charNum, dimension, zoneNo, scale, &fpixelsInZone))
    {
	return(fpixelsInZone);
    }

    /* Check if set width unconstrained */
    if (!swFixed && (dimension == X_DIMENSION))	/* Width unconstrained? */
    {
	return(_FSGetTPixels(charNum, dimension, zoneNo, scale));
    }

    /* Ensure that zone data is in the cache */
    if (!_FSCacheData(charNum, dimension, cfontp, pFirstRec))
    {
	cacheOverflow = TRUE;
	return(0.0);
    }

    /* Determine which zones need pixel values to be calculated */
    _FSMakePathMask(charNum, dimension, zoneNo, pathMask);

    /* Compute pixels in top level zone */
    _FSGetCacheData(charNum, dimension, 0, &from, &to, &flags, &pfunct);
    orusInZone = to - from;
    if (dimension == X_DIMENSION)
    {
	basePixels = xPixelsPerEm * xScale;
    }
    else
    {
	basePixels = yPixelsPerEm * yScale;
    }
    baseORUs = outlres;

    fpixelsInZone = (orusInZone / baseORUs) * basePixels;	/* Calculate Real ing pixels in root zone */

    if (zoneNo == 0)	/* Root zone is target zone? */
    {
	return(fpixelsInZone);	/* Return Real ing pixels in root zone */
    }
    pixelsInZone = _FSGetPixels(charNum, dimension, 0, scale);
    if (cacheOverflow)	/* Cache overflow? */
	return(0.0);

    queuePut = queueGet = 0;			/* Clear queue */
    queue[queuePut++] = orusInZone;		/* Add number of orus in top zone to queue */
    queue[queuePut++] = pixelsInZone;	/* Add number of pixels in top zone to queue */

    i = 1;
    while (queueGet < queuePut)	/* While queue not empty ... */
    {
	orusAvailable = queue[queueGet++];	/* Get number of orus available from queue */
	pixelsAvailable = queue[queueGet++];	/* Get number of pixels available from queue */
	moreZones = 1;				/* Assume at least one zone */
	while (moreZones)			/* For each daughter zone ... */
	{
	    _FSGetCacheData(charNum, dimension, i, &from, &to, &flags, &pfunct);
	    orusInZone = to - from;	/* Get number of orus in zone */
	    if (flags & MASK_L_FLAG)	/* New level in hierarchy? */
	    {
		basePixels = (Real)pixelsAvailable;
		baseORUs = (Real)orusAvailable;
	    }
	    if (orusInZone == 0.0)
		fpixelsInZone = 0.0;
	    else
		fpixelsInZone = (orusInZone / baseORUs) * basePixels;	/* Calculate Real ing pixels in zone */

	    if (i == zoneNo)	/* Target zone? */
	    {
		_FSCacheFPixels(charNum, dimension, i, fpixelsInZone, scale);	/* Save for possible future use */
		return(fpixelsInZone);	/* Return Real ing number of pixels in target zone */
	    }
	    if (pathMask[i])	/* This zone needs pixels calculated? */
	    {
		_FSCacheFPixels(charNum, dimension, i, fpixelsInZone, scale);	/* Save for possible future use */
		pixelsInZone = _FSGetPixels(charNum, dimension, i, scale);	/* Calculate number of pixels in zone */
		if (cacheOverflow)	/* Cache overflow? */
		    return(0.0);
		pixelsAvailable -= pixelsInZone;	/* Subtract from pixel budget */
	    }
	    orusAvailable -= orusInZone;	/* Subtract from oru budget */
	    if (flags & MASK_P_FLAG)		/* Parent zone? */
	    {
		queue[queuePut++] = orusInZone;	/* Add number of orus in zone to queue */
		queue[queuePut++] = pixelsInZone;	/* Add number of pixels in zone to queue */
	    }
	    moreZones = flags & MASK_C_FLAG; 
	    i++;
	}
    }
    /** Error **/
    return(0.0);
}


_FSMakePathMask (charNum, dimension, zoneNo, mask)
uInt16	charNum;	/* Character number */
Int16	dimension;	/* 0 if x zone, 1 if y zone */
Int16	zoneNo;	/* Zone number */
Boolean	mask[];		/* mask[i] is true if pixel value required for zone i */
/* Finds a path from the root zone of the specified dimension of the specified
   character to the specified target zone.
   Each truth value in the updated mask array indicates if the number of pixels
   needs to be calculated for the corresponding zone in order to calculate
   the number of Real ing pixels in the target zone.
   The zone data for the specified dimension of the specified character is
   assumed to be in the cache. */
{
    Int16	i, j;
    uInt16	queuePut, queueGet;
    Int16	queue[32];
    Int16	zLink[MAX_ZONES_PER_DIM];
    Int16	prevZone;
    Int16	moreZones;
    Int32	from, to;
    uInt16	flags;
    uInt16	*pfunct;

    i = 0;	/* Start at root zone */
    queuePut = queueGet = 0;		/* Clear queue */
    queue[queuePut++] = -1;		/* Terminate reverse link chain */
    while (queueGet < queuePut)	/* More groups? */
    {
	prevZone = queue[queueGet++];	/* Get link to previous zone from queue */
	moreZones = 1;			/* Assume at least one zone */
	while (moreZones)		/* More zones in this group? */
	{
	    mask[i] = FALSE;		/* Initialize mask array element */
	    zLink[i] = prevZone;	/* Set up link to previous zone */
	    _FSGetCacheData(charNum, dimension, i, &from, &to, &flags, &pfunct);
	    if (i == zoneNo)		/* Target zone? */
	    {
		while ((flags & MASK_L_FLAG) == 0)  /* Same level as previous zone? */
		{
		    i--;	/* Back up one zone */
		    _FSGetCacheData(charNum, dimension, i, &from, &to, &flags,
				    &pfunct);
		}
		while ((j = zLink[i]) >= 0)
		{
		    mask[j] = TRUE;	/* Mark pixel allocation required */
		    _FSGetCacheData(charNum, dimension, j, &from, &to, &flags,
				    &pfunct);
		    if ((flags & MASK_P_FLAG) &&
			(((i - j) > 1) || ((flags & MASK_C_FLAG) == 0))) /* Zone j is parent? */
		    {
			while ((flags & MASK_L_FLAG) == 0) /* Same level as prev zone? */
			{
			    j--;	/* Back up one zone */
			    _FSGetCacheData(charNum, dimension, j, &from,
					    &to, &flags, &pfunct);
			}
		    }
		    i = j;
		}
		return;
	    }
	    if (flags & MASK_P_FLAG)	/* Parent zone? */
	    {
		queue[queuePut++] = i;	/* Queue link to this zone */
	    }
	    prevZone = i;	/* Save link to this zone */
	    moreZones = flags & MASK_C_FLAG; 
	    i++;		/* Next zone in sequence */
	}
    }
    _FSAssert (FALSE);
    return;
}


/*ARGSUSED*/
Real  _FSGetTPixels(charNum, dimension, zoneNo, scale)
uInt16	charNum;	/* Character offset */
Int16	dimension;	/* 0 if x zone, 1 if y zone */
Int16	zoneNo;		/* Zone number */
Real	scale; 
/* Returns the number of pixels allocated to the specified zone in the */
/* character whose root zone is at the specified character offset.  The rate of  */
/* exchange from outline resolution units to pixels is at the top level. */
{
    Int32	from, to;
    uInt16	flags;
    uInt16	*pfunct;
    Int32	orusInZone;
    Real	baseORUs, basePixels;
    Real	fpixelsInZone;
    Boolean	_FSCacheData();

    /* Ensure that zone data is in the cache */
    if (!_FSCacheData(charNum, dimension, cfontp, pFirstRec))
    {
	cacheOverflow = TRUE;
	return(0.0);
    }

    _FSGetCacheData(charNum, dimension, zoneNo, &from, &to, &flags, &pfunct);
    orusInZone = to - from;
    baseORUs = outlres;
    if (dimension == X_DIMENSION)
    {
	basePixels = xPixelsPerEm * xScaleNom;
    }
    else
    {
	basePixels = yPixelsPerEm * yScale;
    }
    fpixelsInZone = (orusInZone / baseORUs) * basePixels;
    return(fpixelsInZone);	/* Return number of pixels in target zone */
}


_FSMakeEdgeList(charNum, dimension, scale, pn)
uInt16	charNum;
Int16	dimension;
Real	scale;
Int16 *pn;
/* Called by _FSSetup...Trans() to build a sorted list of zone edges and
   corresponding pixel allocations in _FSEdges[] and _FSPixels[].
   Sets *pn to number of edges generated (zero if no zone data) */
{
    Int16	noZones, i, j;
    Int32	from, to, maxEdge=0;
    uInt16	flags;
    uInt16	*pfunct;
    Boolean	flag;
    uInt16	tempUInt16;
    Real	tempReal  ;
    Boolean	_FSCachedPixels(), rval;

    /* Make list of zones and associated number of pixels */
    _FSGetCacheNoZones(charNum, dimension, &noZones);
    if (noZones == 0)	/* No zone data? */
    {
	*pn = 0;
	return;
    }
    j = 0;
    for (i = 0; i < noZones; i++)
    {
	_FSGetCacheData(charNum, dimension, i, &from, &to, &flags, &pfunct);
	if (i == 0)
	    maxEdge = to;
	if ((flags & MASK_P_FLAG) == 0)	/* Not parent zone? */
	{
	    _FSEdges[j] = from;
	    rval = _FSCachedPixels(charNum, dimension, i, scale, &_FSPixels[j]);
	    _FSAssert (rval);

	    if (to > maxEdge)
	    {
		maxEdge = to;
	    }
	    j++;
	    if ((j + 2) >= MAX_ZONES_PER_DIM)
	    {
		/** Error: too many zones **/
		j--;
	    }
	}
    }
    _FSEdges[j] = maxEdge;
    _FSPixels[j] = 0;
    j++;
    *pn = j;

    /* Sort zones into ascending order */
    flag = TRUE;
    while (flag)
    {
	flag = FALSE;
	for (i = 1; i < j; i++)
	{
	    if (_FSEdges[i] < _FSEdges[i - 1])
	    {
		tempReal   = _FSEdges[i];
		_FSEdges[i] = _FSEdges[i - 1];
		_FSEdges[i - 1] = tempReal  ;
		tempUInt16 = _FSPixels[i];
		_FSPixels[i] = _FSPixels[i - 1];
		_FSPixels[i - 1] = tempUInt16;
		flag = TRUE;
	    }
	}
	j--;
    }
}


_FSMakeXTransList(n, direction, a, b)
Int16	n;	/* Number of edges */
Int16	direction; /* +1 indicated increasing pixel values, -1 decreasing values */
Real	a[];	/* Generated list of edge coordinates in outline resolution units */
Int16	b[];	/* Corresponding list of coordinates in pixel space */
/* Called by _FSSetupXXTrans() and _FSSetupYYTrans() to generate a list of outline
   x coordinates and their corresponding transformed pixel coordinates from
   _FSEdges[] and _FSPixels[]. */
{
    Int16	i;
    Int16	position;
    Real	fposition;
    Real	compEdge;
    Real	_FSDoCompXTrans();

    if (n == 0)	/* No zone data? */
	return;	/* No transformation list needed */

    /* Calculate pixel coordinate of first edge */
    fposition = _FSDoCompXTrans(xPos);
    if (_FSEdges[0] >= 0.0)	/* First edge right of origin? */
    {
	fposition += _FSEdges[0] * xPixelsPerEm * xScale / outlres;
    }
    else	/* First edge left of origin? */
    {
	for (i = 1; i < n; i++)
	{
	    fposition -= _FSPixels[i - 1];
	    if (_FSEdges[i] >= 0.0)
		break;
	}
	if (i < n)	/* Positive edge value found */
	{
	    fposition += _FSEdges[i] * _FSPixels[i - 1] /
			 (_FSEdges[i] - _FSEdges[i - 1]);
	}
	else		/* Positive edge value not found */
	{
	    fposition += _FSEdges[n-1] * xPixelsPerEm * xScale / outlres;
	}
    }
    position = floor(fposition + 0.5);

    /* Assign absolute coordinates in pixel space and update compound trans table */
    for (i = 0; i < n; i++)
    {
	a[i] = _FSEdges[i];
	b[i] = direction * position;
	compEdge = _FSEdges[i] * xScale + xPos;
	if ((noCompXEdges == 0) ||	/* nothing in comp trans table? */
	    ((fposition >= _FSCompXPixelTbl[noCompXEdges - 1]) &&
	     (compEdge > _FSCompXEdgeTbl[noCompXEdges - 1])))
	{
	    _FSCompXEdgeTbl[noCompXEdges] = compEdge;
	    _FSCompXPixelTbl[noCompXEdges] = fposition;
	    noCompXEdges++;
	}
	fposition += _FSPixels[i];
	position += _FSPixels[i];
    }
}


_FSMakeYTransList(n, direction, a, b)
Int16	n;	/* Number of edges */
Int16	direction; /* +1 indicated increasing pixel values, -1 decreasing values */
Real	a[];	/* Generated list of edge coordinates in outline resolution units */
Int16	b[];	/* Corresponding list of coordinates in pixel space */
/* Called by _FSSetupXYTrans() and _FSSetupYYTrans() to generate a list of outline
   y coordinates and their corresponding transformed pixel coordinates from _FSEdges[]
   and _FSPixels[]. */
{
    Int16	i, orgI;
    Int16	j;
    Int16	pos, orgPos;
    Int16	bottom, top, thisEdge;
    Real	fpos;
    Real	bestEdge;

    if (n == 0)	/* No zone data? */
	return;	/* No transformation list needed */


    /* Look for bottom or top of emsquare in list of edges */
    bottom = floor(EM_BOT * (outlres / 8640) + 0.5);
    top = floor(EM_TOP * (outlres / 8640) + 0.5);
    for (i = 0; i < n; i++)
    {
	thisEdge = floor(_FSEdges[i] + 0.5);
	if ((j = thisEdge - bottom) == 0  ||  j == 1  ||  j == -1)
	{
	    fpos = (_FSEdges[i] * yScale + yPos) * yPixelsPerEm / outlres;
	    orgPos = floor(fpos + 0.5);
	    orgI = i;
	    goto finish;
	}
	if ((j = thisEdge - top) <= 1  &&  j >= -1)
	{
	    fpos = (bottom * yScale + yPos) * yPixelsPerEm / outlres;
	    orgPos = floor(fpos + 0.5);
	    orgPos += floor(yScale * yPixelsPerEm + 0.499);
	    orgI = i;
	    goto finish;
	}
    }

    /* If no edge at bottom or top, then look for edge nearest baseline */
    orgI = 0;
    bestEdge = fabs(_FSEdges[0]);
    for (i = 0; i < n; i++)
    {
	if (fabs(_FSEdges[i]) < bestEdge)
	{
	    bestEdge = fabs(_FSEdges[i]);
	    orgI = i;
	}
    }
    fpos = (_FSEdges[orgI] * yScale + yPos) * yPixelsPerEm / outlres;
    orgPos = floor(fpos + 0.5);

    /* Fill in pixel addresses for each edge */
    finish:
    pos = orgPos;
    for (i = orgI; i < n; i++)
    {
	a[i] = _FSEdges[i];
	b[i] = direction * pos;
	pos += _FSPixels[i];
    }
    pos = orgPos;
    for (i = orgI - 1; i >= 0; i--)
    {
	pos -= _FSPixels[i];
	a[i] = _FSEdges[i];
	b[i] = direction * pos;
    }
}


_FSMakeTransTable (pixelsPerEm, scale, pos, direction, orusTbl,
			   pixelsTbl, n, multTbl, offsetTbl, pnoTransforms)
Real	pixelsPerEm;	/* pixels per em */
Real	scale;		/* scale factor */
Real	pos;		/* position */
Int16	direction;	/* +1 indicated increasing pixel values, -1 decreasing values */
Real	orusTbl[];	/* table of oru values */
Int16	pixelsTbl[];	/* table of corresponding pixel values */
Int16	n;		/* number of entries in orus/pixels tables */
Real	multTbl[];	/* Transformation multiplier */
Real	offsetTbl[];	/* Transformation constants */
Int16	*pnoTransforms;	/* (output) number of multipliers/constants */

/* Called by _FSSetup...Trans() to generate interpolation function coefficients
   from list of zone edge values and their corresponding unrounded pixel values.
*/

{
    Real	prevORUs;
    Int16	prevPixels;
    Int16	i, k;

    if (n == 0)	/* No zone data? */
    {
	multTbl[0] = pixelsPerEm * scale * direction / outlres;
	offsetTbl[0] = pos * pixelsPerEm * direction / outlres;
	*pnoTransforms = 0;
	return;
    }

    _FSAssert (n >= 2);				/* n out of range? */
    _FSAssert (orusTbl[n - 1] >= orusTbl[0]);	/* negative range? */

    /* Generate coefficient table */
    multTbl[0] = pixelsPerEm * scale * direction / outlres;
    offsetTbl[0] = (Real)pixelsTbl[0] - (orusTbl[0] * multTbl[0]);
    prevORUs = orusTbl[0];
    prevPixels = pixelsTbl[0];
    k = 1;
    for (i = 1; i < n; i++)
    {
	if (orusTbl[i] > prevORUs)
	{
	    orusTbl[k] = orusTbl[i];
	    multTbl[k] = (Real)(pixelsTbl[i] - prevPixels) /
			 (orusTbl[i] - prevORUs);
	    offsetTbl[k] = (Real)pixelsTbl[i] - (orusTbl[i] * multTbl[k]);
	    prevORUs = orusTbl[i];
	    prevPixels = pixelsTbl[i];
	    k++;
	}
    }
    orusTbl[k] = orusTbl[n - 1];
    multTbl[k] = multTbl[0];
    offsetTbl[k] = (Real)pixelsTbl[n - 1] - (orusTbl[n - 1] * multTbl[0]);
    *pnoTransforms = k;
}


Real _FSDoXTrans (x, y)
Real	x, y;

/* Executes x transformation function. */
{
    Int16	i;

    if (noXXTransforms >= 0)	/* x is a function of x only? */
    {
	for (i = 0; i < noXXTransforms; i++)
	{
	    if (x <= _FSXORUs[i])
	    {
		return (x * _FSXMultTbl[i] + _FSXOffsetTbl[i]);
	    }
	}
	return (x * _FSXMultTbl[noXXTransforms] +
		_FSXOffsetTbl[noXXTransforms]);
    }

    if (noXYTransforms >= 0)	/* x is a function of y only? */
    {
	for (i = 0; i < noXYTransforms; i++)
	{
	    if (y <= _FSXORUs[i])
	    {
		return (y * _FSXMultTbl[i] + _FSXOffsetTbl[i]);
	    }
	}
	return (y * _FSXMultTbl[noXYTransforms] +
		_FSXOffsetTbl[noXYTransforms]);
    }

    return (x * xxMult + y * xyMult + xOffset);	/* x is a function of x and y? */
}


Real _FSDoYTrans (x, y)
Real	x, y;

/* Executes y transformation function. */
{
    Int16	i;

    if (noYYTransforms >= 0)	/* y is a function of y only? */
    {
	for (i = 0; i < noYYTransforms; i++)
	{
	    if (y <= _FSYORUs[i])
	    {
		return (y * _FSYMultTbl[i] + _FSYOffsetTbl[i]);
	    }
	}
	return (y * _FSYMultTbl[noYYTransforms] +
		_FSYOffsetTbl[noYYTransforms]);
    }

    if (noYXTransforms >= 0)	/* y is a function of x only? */
    {
	for (i = 0; i < noYXTransforms; i++)
	{
	    if (x <= _FSYORUs[i])
	    {
		return (x * _FSYMultTbl[i] + _FSYOffsetTbl[i]);
	    }
	}
	return (x * _FSYMultTbl[noYXTransforms] +
		_FSYOffsetTbl[noYXTransforms]);
    }

    return (x * yxMult + y * yyMult + yOffset);	/* y is a function of x and y? */
}


void  _FSDoXYTrans (x, y, xtr, ytr)
Real	x, y;		/* (x, y) input arguments */
Real	*xtr, *ytr;	/* output arguments */

/* Executes x and y transformation functions.   */
{
    Int16	i;

    if (noXXTransforms >= 0)	/* x is a function of x only? */
    {
	for (i = 0; i < noXXTransforms; i++)
	{
	    if (x <= _FSXORUs[i])
	    {
		*xtr = x * _FSXMultTbl[i] + _FSXOffsetTbl[i];
		break;
	    }
	}
	if (i == noXXTransforms)
	    *xtr = x * _FSXMultTbl[i] + _FSXOffsetTbl[i];
    }

    else if (noXYTransforms >= 0)	/* x is a function of y only? */
    {
	for (i = 0; i < noXYTransforms; i++)
	{
	    if (y <= _FSXORUs[i])
	    {
		*xtr = y * _FSXMultTbl[i] + _FSXOffsetTbl[i];
		break;
	    }
	}
	if (i == noXYTransforms)
	    *xtr = y * _FSXMultTbl[i] + _FSXOffsetTbl[i];
    }

    else
    {
	*xtr = x * xxMult + y * xyMult + xOffset;	/* x is a function of x and y. */
    }

    if (noYYTransforms >= 0)	/* y is a function of y only? */
    {
	for (i = 0; i < noYYTransforms; i++)
	{
	    if (y <= _FSYORUs[i])
	    {
		*ytr = y * _FSYMultTbl[i] + _FSYOffsetTbl[i];
		break;
	    }
	}
	if (i == noYYTransforms)
	    *ytr = y * _FSYMultTbl[i] + _FSYOffsetTbl[i];
    }

    else if (noYXTransforms >= 0)	/* y is a function of x only? */
    {
	for (i = 0; i < noYXTransforms; i++)
	{
	    if (x <= _FSYORUs[i])
	    {
		*ytr = x * _FSYMultTbl[i] + _FSYOffsetTbl[i];
		break;
	    }
	}
	if (i == noYXTransforms)
	    *ytr = x * _FSYMultTbl[i] + _FSYOffsetTbl[i];
    }

    else
    {
	*ytr = x * yxMult + y * yyMult + yOffset;	/* y is a function of x and y. */
    }

    return;
}


Real  _FSDoRealXTrans(x)
Real	x;
/* Transforms x coordinate in oru space into x coordinate in pixel space. */
{
    return (x * xPixPerORU);
}


Real  _FSDoCompXTrans(x)
Real	x;
/* Transforms x coordinate in oru space into x coordinate in pixel space.
   Used for x position calculations, and was previously used for set width
   calculations for bitmap fonts with integer widths */
{
    Int16	i;
    Real	newX;

    if (noCompXEdges != 0)
    {
	for (i = 0; i < noCompXEdges; i++)
	{
	    if (x <= _FSCompXEdgeTbl[i]) 
	    {
		if (i != 0)
		{
		    newX = _FSCompXPixelTbl[i-1] +
			(x - _FSCompXEdgeTbl[i-1]) /
			(_FSCompXEdgeTbl[i] - _FSCompXEdgeTbl[i-1]) *
			(_FSCompXPixelTbl[i] - _FSCompXPixelTbl[i-1]);
		    return(newX);
		}
		else
		{
		    newX = _FSCompXPixelTbl[0] - (_FSCompXEdgeTbl[0] - x) *
			xPixPerORU;
		    return(newX);
		}
	    }
	}
	newX = _FSCompXPixelTbl[noCompXEdges - 1] +
	    (x - _FSCompXEdgeTbl[noCompXEdges - 1]) * xPixPerORU;
	return(newX);
    }
    else
    {
	return(_FSDoRealXTrans (x));
    }
}
