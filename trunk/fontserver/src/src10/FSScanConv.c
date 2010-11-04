/* $RCSfile: fsscncnv.c $$Revision: 1.3 $$Date: 1991/02/28 17:51:28 $ Copyright (c) 1990 Intergraph Corp. */


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


/*********************** F S S c a n C o n v e r t . c ***********************
 ********************** R E V I S I O N   H I S T O R Y **********************

 1)  30-Dec-86  jsc	_FSCharScanConvert() modified to calculate adjusted
			scale factors and offsets based on extents of root
			character relative to the edges of the character cell,
			and imported width if enabled.

 2)  20-Feb-87  mby	Implemented clip left right top bottom (edges of em-
			square). Removed expand_raster_width. Relocated call to
			_FSNewSubchar(). Deallocates arc to vector array memory.

 3)  19-Mar-87  mby	Rounds widths down if real value =  integer + 0.5

 4)   9-Apr-87  mby	Changed parameters for calling this module so that
			no parameters are passed as external globals.

 5)  14-Apr-87  tpl	Call _FSReportError if cannot _FSMalloc() bitmap.

 6)  22-Apr-87  mby	Change outline-filling algorithm to get rid of gaps in
			lines with slope < 1 by scanning in both dimensions (up
			to ~75 lpm). Changes to _FSProcVect() and
			_FSConvertLists().

 7)  14-May-87  mby	Change _FSConvertLists() to preserve white space
			continuity

 8)  18-May-87  mby	New threshold of .05 pixels.
			Force raster height, width to nonzero to keep bitmaps
			from vanishing.
			Round obliquing, rotation angles to nearest .1 degree

 9)  ??-Oct-87  rdw	Added ability to create outline fonts.
     (Intergraph)

 *****************************************************************************

    This module takes a character in a typeface and constructs
    a bitmap or outlines, which is attached to the characters.

    The entry point into this module is _FSCharScanConvert().

 ****************************************************************************/

#include <math.h>
#include <memory.h>
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSMakeFont.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSOutl.h"
#include "../hfiles/FSBmapCach.h"
#include "../hfiles/FSOutlCach.h"
#include "../hfiles/FSGenCache.h"
#include "../hfiles/FSSize.h"
#include "../hfiles/FSPolyFill.h"
#include "../hfiles/FSPixCache.h"
#include "../hfiles/FSLoadTF.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSOutlCach.h"
#include "../hfiles/FSGetRec.h"
#include "../hfiles/FSConvert.h"
#include "../hfiles/FSScanConv.h"

/* this should be defined as a compilation argument */
/* #define  CONVERTDBG */	/* prints gobs of debugging data */

/***** DEFINITIONS *****/

/* Tokens returned by _FSGetCompToken() */
#define	SNAFU		-1
#define	VECT		1
#define	ARC		2
#define	STARTCRV	3
#define	ENDCRV		4
#define	ENDCHAR		5
#define	ENDFILE		6
#define	SETSCALE	7
#define	SETORIG		8
#define	DOCHAR		9
#define	IGNORE		10
#define	XZONE		11
#define	YZONE		12
#define	PITEM		13
#define	FITEM		14
#define	CONST		15
#define	OPCODE		16
#define	TITEM		17
#define	X_MIN_EXTENT	18
#define	X_MAX_EXTENT	19
#define	Y_MIN_EXTENT	20
#define	Y_MAX_EXTENT	21

#define	ISPACE	4000
#define	VSPACE	2000
#define	PSPACE	16


typedef union
{
    IntElem		*intc;		/* free space pointer for intercepts */
    OutlVertex		*vert;		/* free space pointer for vertices */
    Outl3DVertex	*vert3D;	/* free space pointer for 3D vertices */
} FreeSpace;


/***** STATIC VARIABLES *****/

static	Int32	bslOffY;	/* baseline (y=0) offset for scan conversion */
static	Int32	bslOffX;	/* left s.b. (x=0) offset for scan conversion */
static	BmapExt	bmapExtent;	/* structure with 4 character extents */
static	TFStruct *cfontp;	/* pointer to compr font structure */
static	Int32	freeSpace;	/* amount of space available for intercepts */
static	Int32	freePSize;	/* amount of space available for poly sizes */
static	Int32	freeVert;	/* amount of space available for vertices */
static	Boolean	incremFormat;	/* T = incremental;  F = absolute */
static	Int32	nbrScanlX;	/* max # lines to scan convert any character */
static	Int32	nbrScanlY;	/* max # lines to scan convert any character */
static	Real	outlres;	/* font outline resl/em in outline units */
static	uInt16	*pFirstRec;	/* ptr to first outline data record in font */
static	uInt16	*pLastRec;	/* ptr following end of outline data in font */
static	uInt16	*pThisRec;	/* outline data "program counter" */
static	Boolean	scanInX;	/* X-dimension scan conversion switch */
static	Int	subcharCount;	/* # of character components (DOCHAR) */
static	IntElem	**yslist[DCHRCT]; /* array of pointers to arrays of
				     lists of x-intercepts on y-scan lines */
static	IntElem	**xslist[DCHRCT]; /* ... for lists of y-intercepts on x-scan lines */

static	FontCharNode **charNode; /* handle to bmap or outl char node */
static	Boolean	outlFlag;	/* T iff making an outline font */
static	OutlCharInfo *outlInfo;	/* pointer to outline char info */
static	BmapCharInfo *bmapInfo;	/* pointer to bitmap char info */
static	Boolean	thicken;	/* T: thicken characters by one pixel */
static	Boolean	outl3D;		/* T: create 3D outlines */
static	Boolean	allBitmaps;	/* T: store char data as bitmaps */
static	Boolean	allRLE;		/* T: store char data as run-length */
static	Boolean	intWidths;	/* T: round set widths to integer */
static	OutlPolySize *pSizePtr;	/* free space ptr for poly sizes */
static	FreeSpace fsPtr;	/* free space ptr for intercepts or vertices */

static	Int32	threshBlack = 3277; /* threshold for dropping a thin stroke */
static	Int32	threshWhite = 3277; /* threshold for ignoring white space */
				    /* .05 pixel threshold (.05 * 65536) */
static	char	*allocList[128];	/* list of _FSMalloced pointers */
static	Int	allocCount;		/* how many _FSMalloced pointers */


void	_FSAddScanList();	/* add element to scan conversion list */


Boolean  _FSCharScanConvert (compc)
CompCharDesc	*compc;

/* _FSCharScanConvert -- Scan conversion routine for 1 character
 * Input:
 *   compc -- pointer to structure containing scan conversion parameters.
 * Output:
 *   compc->fontNode -- a new character is generated for this font.
 * Returns:
 *   TRUE if valid result is returned, FALSE if error
 * Called from:
 *   main module
 */
{
    Real	arcSplTol;	/* arc splitting tolerance in outline units */
    Int32	charNr;		/* character offset */
    CharId	charId;		/* character id */
    ArcType	coord;		/* arc data type, endpoint + bulge factor */
    uInt16	curCharNo;	/* current char number */
    Int16	curveCount;	/* curve count within character or subchar */
    Int32	from, to;	/* zone start and end coordinates */
    uInt16	flags;		/* zone flags */
    uInt16	*pfunct;	/* zone constraint functions */
    Int16	ii, jj;		/* temps */
    Int32	m1=0, m2=0, m3, m4;	/* temps */
    Real	q1, q2;		/* temps */
    Int16	stackCount;	/* depth of stack (0 to DCHRCT) */
    StackFrame	stack[DCHRCT];	/* for nested DOCHARS */
    StackFrame	*pstack;	/* pointer to a stack frame */
    VectorData	*vectr;		/* pointer to arc splitting output (vectors) */
    Int32	vectorCount;	/* # of vectors created by arc splitting */
    Int32	x1, y1,
		x2=0, y2=0;	/* coordinate pairs in RU space */
    Real	x1p, y1p, x2p, y2p; /* coordinate pairs in pixel space */
    Int32	x1pI, x2pI=0;	/* x coords, integer, rounded values */
    Int32	y1pI, y2pI=0;	/* y coords, integer, rounded values */
    Real64	setWidth;	/* calculated set width of character */
    Boolean	rval;

    Real	leftLimit;	/* Left limit of character cell */
    Real	rightLimit;	/* Right limit of character cell */
    Real	bottomLimit;	/* Bottom limit of character cell */
    Real	topLimit;	/* Top limit of character cell */

    Real	leftLimitAdj;   /* Adjusted position of root char left limit */
    Real	rightLimitAdj;  /* Adjusted position of root char right limit */
    Real	bottomLimitAdj; /* Adjusted position of root char bottom limit */
    Real	topLimitAdj;    /* Adjusted position of root char top limit */

    Real	reqdWidth;	/* Required width for character */
    
    IntElem	initFreeSpace[ISPACE];	/* initial free space for intercepts */

    Boolean	_FSArcToVects(); /* converts arc to vectors by splitting */
    Boolean	_FSConvertLists(); /* turns scan conversion list into bitmap */
    Real	_FSDoRealXTrans(); /* used for set width calculations */
    void	_FSDoXYTrans();	/* scale, xlate, rotate, oblique xforms on points */
    void	_FSInitRecState(); /* initialize _FSGetRec variables */
    void	_FSInitTrans();	/* initialize character xform data */
    void	_FSNewSubchar(); /* allocate list pointers for new sub-character */
    Real	_FSNormObl();	/* normalize obliquing angle, -90 to 90 */
    Real	_FSNormRot();	/* normalize rotation angle, 0 to 360 */
    void	_FSProcVect();	/* find x-intercepts for a vector crossing y-scan lines */
    void	_FSSetupTrans(); /* setup transformation data  */


    cfontp = compc->compf;
    charNr = compc->chOff;
    charId = compc->charId;
    bslOffX = compc->bslOffX;
    nbrScanlX = 2 * bslOffX;
    bslOffY = compc->bslOffY;
    nbrScanlY = 2 * bslOffY;
    scanInX = compc->scanX;
    outlres = (Real) cfontp->info.reslPerEm;
    compc->rotAngle = floor(10. * compc->rotAngle + 0.5) / 10.;
    compc->oblAngle = floor(10. * compc->oblAngle + 0.5) / 10.;
    outlFlag = compc->outlFlag;
    thicken = compc->thicken;
    outl3D = compc->outl3D;
    allBitmaps = compc->allBitmaps;
    allRLE = compc->allRLE;
    intWidths = compc->intWidths;

    _FSInitTrans(cfontp, charNr,
		 (Real) compc->pointSizeX, (Real) compc->pointSizeY,
		 (Real) compc->resHor, (Real) compc->resVer,
		 (Real) _FSNormRot (compc->rotAngle),
		 (Real) _FSNormObl (compc->oblAngle));

    if (cfontp->info.outlFmtNr[1] == '2')
	incremFormat = TRUE;
    else
	incremFormat = FALSE;

    bmapExtent.xMin = 1000000000;
    bmapExtent.xMax = -1000000000;
    bmapExtent.yMin = 1000000000;
    bmapExtent.yMax = -1000000000;

    leftLimitAdj = leftLimit = 0.0;
    rightLimitAdj = rightLimit = (Real) cfontp->charDir[charNr].setWidth;
    bottomLimitAdj = bottomLimit = EM_BOT * (outlres / 8640.0);
    topLimitAdj = topLimit = EM_TOP * (outlres / 8640.0);
    reqdWidth = rightLimit;

    allocCount = 0;
    subcharCount = 0;

    if (outlFlag)
    {
	/* create char node for the new character */
	charNode = (FontCharNode **) _FSOutlNewDirRec (compc->fontNode, charId);
	_GCSetPurge (charNode, TRUE);

	_FSOutlLockCharInfo (charNode);
	_FSOutlLockCharPSize ((OutlCharNode **)charNode);
	_FSOutlLockCharVert ((OutlCharNode **)charNode);
	outlInfo = _FSOutlCharInfo (charNode);

	freePSize = PSPACE;
	_FSOutlNewPSize (charNode, freePSize);
	pSizePtr = _FSOutlCharPSize (charNode) - 1;

	freeVert = VSPACE;
	if (outl3D)
	    _FSOutlNew3DVert (charNode, freeVert);
	else
	    _FSOutlNewVert (charNode, freeVert);
	fsPtr.vert = _FSOutlCharVert (charNode);

	outlInfo->xMin = outlInfo->yMin = 10e38;
	outlInfo->xMax = outlInfo->yMax = -10e38;
	outlInfo->nPSize = 0;
	outlInfo->nVert = 0;
    }
    else
    {
	/* create char node for the new character */
	charNode = (FontCharNode **) _FSBmapNewDirRec (compc->fontNode, charId);
	_GCSetPurge (charNode, TRUE);

	_FSBmapLockCharInfo (charNode);
	_FSBmapLockCharBitmap ((BmapCharNode **)charNode);
	bmapInfo = _FSBmapCharInfo (charNode);

	freeSpace = ISPACE;
	fsPtr.intc = initFreeSpace;
    }

    _FSInitRecState (0);	/* initialize _FSGetRec variables */

    /** Initialize the stack **/
    stackCount = 0;
    pstack = stack;
    stack[0].xOff = 0.;
    stack[0].yOff = 0.;
    stack[0].xScale = stack[0].xScaleNom = 1.;
    stack[0].yScale = stack[0].yScaleNom = 1.;
    stack[1].xOff = 0.;
    stack[1].yOff = 0.;
    stack[1].xScale = stack[1].xScaleNom = 1.;
    stack[1].yScale = stack[1].yScaleNom = 1.;

    _FSOpenPutCacheData();	/* Prepare to read zone data */
    curveCount = 0;		/* Initialize curve count */
    curCharNo = charNr;

    /** The following loop processes 1 entire character, including
	DOCHARs and CALLs, if any.
	_FSGetCompToken() grabs tokens until the final (unnested) ENDCHAR
	token is found; then a 'goto' exits the loop (since a 'break' exits
	the switch statement).
	_FSGetCompToken() should never normally encounter an end of file.  **/

    pFirstRec = cfontp->outlines;
    pLastRec = pFirstRec + _FSOutlDataSize (&cfontp->outlinesHdr);
    pThisRec = pFirstRec + cfontp->charDir[charNr].outlineOffs;

    /** Outline resolution units per pixel, h & v **/
    q1 = outlres * PTPERINCH / (compc->resHor * compc->pointSizeX);
    q2 = outlres * PTPERINCH / (compc->resVer * compc->pointSizeY);
    arcSplTol = .3 / compc->resFactor * MIN(q1, q2);	/* error < .3 pixel */

    while ((ii = _FSGetCompToken (&coord)) != ENDFILE)
    {
	switch (ii)
	{
	    case VECT:	/* get X,Y coordinates */

		x1 = x2;	/* straight line from (x1, y1) to (x2, y2) */
		y1 = y2;	/*  in relative-unit space */
		x1p = x2p;	/* (x1p, y1p) & (x2p, y2p) in pixel space */
		y1p = y2p;
		x1pI = x2pI;	/* (xpI, ypI) -- int values in pixel space */
		y1pI = y2pI;
		x2 = coord.xx;	/* (X,Y)  raw value */
		y2 = coord.yy;

		/* (X,Y) transformed to pixel coordinates */
		_FSDoXYTrans ((Real)x2, (Real)y2, &x2p, &y2p);
		x2pI = ROUND (x2p);	/* x pixel value rounded to integer */
		y2pI = ROUND (y2p);	/* y pixel value rounded to integer */

		/** if y1pI = y2pI and x1pI = x2pI, then no scan line
		    intercepts the vector in either dimension **/
		if (scanInX)
		{
		    if ((y1pI != y2pI) || (x1pI != x2pI) || outlFlag)
		    {
			_FSProcVect (x1p, y1p, x2p, y2p, x1pI, x2pI,
				     y1pI, y2pI);

			if (compc->noPolys && !outlFlag)
			    _FSProcVect (x1p, y1p, x2p, y2p,
					 x1pI, x2pI, y1pI, y2pI);
		    }
		}
		else	/* if y1pI = y2pI then no scan line intercepts the */
		{	/*  vector in the y-dimension. Ignore x-scan lines   */
		    if (y1pI != y2pI)
		    {
			_FSProcVect (x1p, y1p, x2p, y2p, x1pI, x2pI,
				     y1pI, y2pI);

			if (compc->noPolys && !outlFlag)
			    _FSProcVect (x1p, y1p, x2p, y2p,
					 x1pI, x2pI, y1pI, y2pI);
		    }
		}
		break;

	    case ARC:	/* get X,Y coordinates */

		x1 = x2;	/* arc from (x1, y1) to (x2, y2) */
		y1 = y2;	/*  in relative-unit space */
		x1p = x2p;	/* (x1p, y1p) & (x2p, y2p) in pixel space */
		y1p = y2p;
		x1pI = x2pI;	/* (xpI, ypI) -- integer values in pixel space */
		y1pI = y2pI;
		x2 = coord.xx;	/* (X,Y)  raw value */
		y2 = coord.yy;

		/** _FSArcToVects() takes an arc and approximates the arc by
		    splitting it into a sufficiently large number of vectors.
		    They are returned in an array pointed to by 'vectr'. The
		    number of vectors is returned in 'vectorCount'. The
		    vectors are then transformed to pixel coordinates in the
		    usual way. **/

		rval = _FSArcToVects(x1, y1, x2, y2, coord.bugFat,
				     arcSplTol, &vectr, &vectorCount);
		_FSAssert (rval);

		vectr[0].xx = x1p;
		vectr[0].yy = y1p;
		m2 = y1pI;
		m1 = x1pI;
		for (jj = 1;  jj <= vectorCount;  jj++)
		{
		    _FSDoXYTrans (vectr[jj].xx, vectr[jj].yy,
				  &vectr[jj].xx, &vectr[jj].yy);
		    m4 = m2;
		    m3 = m1;
		    m2 = ROUND (vectr[jj].yy);
		    m1 = ROUND (vectr[jj].xx);
		    if (scanInX)
		    {
			if ((m2 != m4) || (m1 != m3) || outlFlag)
			{
			    _FSProcVect (vectr[jj-1].xx, vectr[jj-1].yy,
					 vectr[jj].xx, vectr[jj].yy,
					 m3, m1, m4, m2);

			    if (compc->noPolys && !outlFlag)
				_FSProcVect (vectr[jj-1].xx, vectr[jj-1].yy,
					     vectr[jj].xx, vectr[jj].yy,
					     m3, m1, m4, m2);
			}
		    }
		    else
		    {
			if (m2 != m4)
			{
			    _FSProcVect (vectr[jj-1].xx, vectr[jj-1].yy,
					 vectr[jj].xx, vectr[jj].yy,
					 m3, m1, m4, m2);

			    if (compc->noPolys && !outlFlag)
				_FSProcVect (vectr[jj-1].xx, vectr[jj-1].yy,
					     vectr[jj].xx, vectr[jj].yy,
					     m3, m1, m4, m2);
			}
		    }
		}
		x2p = vectr[vectorCount].xx;
		y2p = vectr[vectorCount].yy;
		y2pI = m2;
		x2pI = m1;
		_FSDealloc ((char *)vectr);

		break;

	    case STARTCRV:    /* initialize to start coordinate */

		/* Set up transformation data */
		curveCount++;		/* Increment curve count */
		if (curveCount == 1)	/* First curve in outline data? */
		{
		    _FSNewSubchar();
		    _FSSetupTrans(curCharNo,
				  pstack->xScaleNom, pstack->yScaleNom,
				  pstack->xScale, pstack->yScale,
				  pstack->xOff, pstack->yOff, compc);
		}
		x2 = coord.xx;	/* (X,Y)  raw value */
		y2 = coord.yy;

		/* (X,Y) transformed to pixel coordinates */
		_FSDoXYTrans ((Real)x2, (Real)y2, &x2p, &y2p);
		y2pI = ROUND (y2p);
		x2pI = ROUND (x2p);

		/** Update the outline info if making an outline font **/
		if (outlFlag)
		{
		    OutlPolySize *oldPSize;

		    if (freePSize == 0)
		    {
			freePSize = PSPACE;
			oldPSize = _FSOutlCharPSize (charNode);

			_FSOutlNewPSize (charNode,
					 outlInfo->nPSize + freePSize);

			pSizePtr = _FSOutlCharPSize (charNode) +
				   (pSizePtr - oldPSize);
		    }
		    freePSize--;
		    outlInfo->nPSize++;
		    pSizePtr++;		/* starts out at -1 */
		    *pSizePtr = 0;
		    _FSProcVect (0.0, 0.0, x2p, y2p, 0, 0, x2pI, y2pI);
		}
		break;

	    case ENDCRV:	/* obsolete, so just get next token */
		break;

	    /** Set new scaling factors in x, y. Put values on stack; does not
		take effect until the next DO CHAR **/
	    case SETSCALE:

		q1 = (Real)coord.xx / 65536;
		pstack[1].xScale = pstack->xScale * q1;
		pstack[1].xScaleNom = pstack->xScaleNom * q1;
		q1 = (Real)coord.yy / 65536;
		pstack[1].yScale =  pstack->yScale * q1;
		pstack[1].yScaleNom = pstack->yScaleNom * q1;

		break;

	    /** Set new origin offsets in x, y. Put values on stack; does not
		take effect until the next DO CHAR **/
	    case SETORIG:	/* set new origin offset */

		pstack[1].xOff = pstack->xOff + pstack->xScale * coord.xx;
		pstack[1].yOff = pstack->yOff + pstack->yScale * coord.yy; 

		break;

	    case DOCHAR:

	    /** Push old values of x and y scaling and offsets onto a stack.
		Set up new stack frame for next DOCHAR **/

		pstack->pc = pThisRec;   /* save pointer to outline data */
		stackCount++;
		_FSAssert (stackCount < DCHRCT);	/* stack overflow? */

		pstack++;
		pstack[1].xOff = pstack->xOff;
		pstack[1].yOff = pstack->yOff;
		pstack[1].xScale = pstack->xScale;
		pstack[1].xScaleNom = pstack->xScaleNom;
		pstack[1].yScale = pstack->yScale;
		pstack[1].yScaleNom = pstack->yScaleNom;

		/* Set new pointer to outline data */
		pThisRec = cfontp->charDir[coord.xx].outlineOffs + pFirstRec;

		_FSOpenPutCacheData();	/* prepare to read zone data  */
		curveCount = 0;		/* init curve count for sub-character */
		curCharNo = coord.xx;	/* new character offset number */

		break;

	    case ENDCHAR:	/* end character, OR pop stack frame */

		if (stackCount == 0)	/* if nothing to pop, char is done */
		    goto DONE;
		else	/* get old values back from the stack */
		{
		    stackCount--;
		    pstack--;
		    pstack[1].xOff = pstack->xOff;
		    pstack[1].yOff = pstack->yOff;
		    pstack[1].xScale = pstack->xScale;
		    pstack[1].xScaleNom = pstack->xScaleNom;
		    pstack[1].yScale = pstack->yScale;
		    pstack[1].yScaleNom = pstack->yScaleNom;
		    pThisRec = pstack->pc;
		}

		break;

	    case XZONE:	/* X zone; save data */

		from = coord.xx;
		to = coord.yy;
		flags = coord.bugFat;
		pfunct = pThisRec;
		_FSPutCacheData(curCharNo, X_DIMENSION, from, to, flags,
				pfunct);
		break;

	    case YZONE:	/* Y zone; save data  */

		from = coord.xx;
		to = coord.yy;
		flags = coord.bugFat;
		pfunct = pThisRec;
		_FSPutCacheData(curCharNo, Y_DIMENSION, from, to, flags,
				pfunct);
		break;

	    case PITEM:		/* P item; ignore */
		break;

	    case FITEM:		/* F item;  ignore */
		break;

	    case CONST:		/* Constant item; ignore */
		break;

	    case OPCODE:	/* Op code; ignore */
		break;

	    case TITEM:		/* T item; ignore */
		break;

	    case X_MIN_EXTENT:

		if (compc->squeeze.left && (coord.xx < leftLimit) &&
		    stackCount == 0)
		{
		    leftLimitAdj = coord.xx;
		    stack[0].xScale = stack[1].xScale = 
				reqdWidth / (rightLimitAdj - leftLimitAdj);
		    stack[0].xOff = stack[1].xOff = 
				(leftLimit - leftLimitAdj) * stack[0].xScale;
		}

		break;

	    case X_MAX_EXTENT:

		if (compc->squeeze.right && (coord.xx > rightLimit) &&
		    stackCount == 0)
		{
		    rightLimitAdj = coord.xx;
		    stack[0].xScale = stack[1].xScale = 
				reqdWidth / (rightLimitAdj - leftLimitAdj);
		    stack[0].xOff = stack[1].xOff = 
				(leftLimit - leftLimitAdj) * stack[0].xScale;
		}

		break;

	    case Y_MIN_EXTENT:

		if (compc->squeeze.bottom && (coord.yy < bottomLimit) &&
		    stackCount == 0)
		{
		    bottomLimitAdj = coord.yy;
		}

		q1 = bottomLimit / bottomLimitAdj;
		if (q1 < stack[0].yScale)
		    stack[0].yScale = stack[1].yScale = q1;

		break;

	    case Y_MAX_EXTENT:

		if (compc->squeeze.top && (coord.yy > topLimit) &&
		    stackCount == 0)
		{
		    topLimitAdj = coord.yy;
		}
		q1 = topLimit / topLimitAdj;
		if (q1 < stack[0].yScale)
		{
		    stack[0].yScale = stack[1].yScale = q1;
		}

		break;

	    case IGNORE:	/* just get next token */
		break;

	    default:	/* snafu */

		_FSAssert (FALSE);	/* illegal code */
		return (FALSE);
	}
    }	/* end  WHILE ((ii = _FSGetCompToken(...) ...  */

DONE:	/* done with character */

    setWidth = (Real64) _FSDoRealXTrans
		((Real) (stack[0].xOff + rightLimitAdj * stack[0].xScale));
    if (intWidths)
	setWidth = floor (ROUND (setWidth));

    if (outlFlag)
    {
	OutlPolySize	**pSize;
	OutlVertex	**vert;

	/** Realloc the data to the proper size **/
	pSize = _FSOutlNewPSize (charNode, outlInfo->nPSize);
	if (outl3D)
	    vert = (OutlVertex **) _FSOutlNew3DVert (charNode, outlInfo->nVert);
	else
	    vert = _FSOutlNewVert (charNode, outlInfo->nVert);

	/** Make the data purgeable **/
	_GCSetPurge (pSize, TRUE);
	_GCSetPurge (vert, TRUE);

	outlInfo->setWid = setWidth;

	if (outlInfo->yMax < outlInfo->yMin)
	{
	    outlInfo->xMin = outlInfo->yMin =
	    outlInfo->xMax = outlInfo->yMax = 0.0;
	}

	_FSOutlUnlockCharInfo (charNode);
	_FSOutlUnlockCharPSize ((OutlCharNode **)charNode);
	_FSOutlUnlockCharVert ((OutlCharNode **)charNode);
    }
    else
    {
	bmapInfo->setWid = setWidth;

	if (bmapExtent.yMax < bmapExtent.yMin)
	{
	    /* no extents; must be a space character */
	    bmapExtent.xMax = 0;
	    bmapExtent.xMin = 0;
	    bmapExtent.yMax = 0;
	    bmapExtent.yMin = 0;
	}
	else
	{
	    if (thicken)
	    {
		bmapExtent.xMax++;
		bmapExtent.yMin--;
	    }
	    
	    /* Clip the character extents, if clipping is in effect */
	    if (compc->clip.right && (bmapExtent.xMax > bmapInfo->setWid))
		bmapExtent.xMax = bmapInfo->setWid;
	    if (compc->clip.left && (bmapExtent.xMin < 0))
		bmapExtent.xMin = 0;
	    if (compc->clip.bottom || compc->clip.top)
	    {
		/* m1 = # lines above baseline; m2 = # lines below baseline */
		m2 = floor ((Real)-EM_BOT / EM_TOTAL * compc->linesPerEm + 0.5);
		m1 = (Int32)(floor (compc->linesPerEm + .499)) - m2;
	    }
	    if (compc->clip.top && (bmapExtent.yMax > m1))
		bmapExtent.yMax = m1;
	    if (compc->clip.bottom && (bmapExtent.yMin < -m2))
		bmapExtent.yMin = -m2;

	    /** If raster width or height is zero, increase each extent
		by one to prevent rectangles < 1 pixel wide from vanishing **/
	    if (bmapExtent.xMin == bmapExtent.xMax)
	    {
		bmapExtent.xMin--;
		bmapExtent.xMax++;
	    }
	    if (bmapExtent.yMin == bmapExtent.yMax)
	    {
		bmapExtent.yMin--;
		bmapExtent.yMax++;
	    }
	}
	bmapInfo->rWid = bmapExtent.xMax - bmapExtent.xMin;
	bmapInfo->rHgt = bmapExtent.yMax - bmapExtent.yMin;
	bmapInfo->hOff = bmapExtent.xMin;
	bmapInfo->vOff = bmapExtent.yMin;

	rval = _FSConvertLists ();
	_FSAssert (rval);

	_FSBmapUnlockCharInfo (charNode);
	_FSBmapUnlockCharBitmap ((BmapCharNode **)charNode);
    }

    /* free all the memory that was used */
    for (ii = allocCount; ii-- > 0;)
	_FSDealloc (allocList[ii]);	/* _FSDealloc calls _FSFree */

    return (TRUE);
}


void  _FSProcVect (xf1, yf1, xf2, yf2, xi1, xi2, yi1, yi2)
Real	xf1, yf1, xf2, yf2;
Int32	xi1, xi2, yi1, yi2;

/*  _FSProcVect -- Fills x and y line intercept lists
 *  Input arguments:
 *    xf1, yf1 -- 1st endpoint of line segment (in pixel space)
 *    xf2, yf2 -- 2nd endpoint of line segment
 *    xi1, yi1 -- 1st endpoint of line segment (rounded to integer)
 *    xi2, yi2 -- 2nd endpoint of line segment
 *  Output arguments:  fsPtr modified
 *  Called from:  _FSCharScanConvert
 *
 *  From a line segment in pixel coordinate space the intersections in x are
 *  calculated at half-integer y values for the y-intercept list, and the
 *  intersections in y are calculated at half-integer x values for the
 *  x-intercept list. The intersections in y are stored in linked lists sorted
 *  by x- or y-position. 'fsPtr' points to a pool of free memory used by the
 *  linked lists.
 *  Data type IntElem defined in source file FSPolyFill.h
 *  Globals used: 'yslist', 'xslist', 'freeSpace', 'subcharCount',
 *	bmapExtent, scanInX
 */
{
    /* making an outline font or bitmap font? */
    if (outlFlag)
    {
	OutlVertex	*oldVert;	/* old vertex ptr */
	OutlVertex	*fsp2;		/* free space ptr for vertices */
	Outl3DVertex	*fsp3;		/* free space ptr for 3D vertices */

	/* check for free space */
	if (freeVert == 0)
	{
	    freeVert = VSPACE;
	    oldVert = _FSOutlCharVert (charNode);

	    if (outl3D)
		_FSOutlNew3DVert (charNode, outlInfo->nVert + freeVert);
	    else
		_FSOutlNewVert (charNode, outlInfo->nVert + freeVert);

	    fsPtr.vert = _FSOutlCharVert (charNode) +
			 (fsPtr.vert - oldVert);
	}

	if (outl3D)
	{
	    fsp3 = (Outl3DVertex *) fsPtr.vert3D++;
	    fsp3->x = xf2;
	    fsp3->y = yf2;
	    fsp3->z = 0.0;
	}
	else
	{
	    fsp2 = (OutlVertex *) fsPtr.vert++;
	    fsp2->x = xf2;
	    fsp2->y = yf2;
	}
	freeVert--;

	outlInfo->nVert++;
	(*pSizePtr)++;

	outlInfo->xMin = MIN (outlInfo->xMin, xf2);
	outlInfo->yMin = MIN (outlInfo->yMin, yf2);
	outlInfo->xMax = MAX (outlInfo->xMax, xf2);
	outlInfo->yMax = MAX (outlInfo->yMax, yf2);
    }
    else
    {
	int	ii;		/* temp */
	IntElem	*fsp1;		/* free space pointer for intercepts */
	int	howManyY;	/* # of intercepts at y = n + 1/2  */
	int	howManyX;	/* # of intercepts at x = n + 1/2  */
	Real	q1, q2;		/* temps */
	Int16	yStart;		/* for each vector, lowest y-scan line */
	Int16	xStart;		/* for each vector, leftmost x-scan line */
	Int16	yScanIndex;	/* index for yscan */
	Int16	xScanIndex;	/* index for xscan */


	if (yi1 <= yi2)
	{
	    howManyY = yi2 - yi1;
	    yStart = yi1;
	}
	else
	{
	    howManyY = yi1 - yi2;
	    yStart = yi2;
	}

	if (xi1 <= xi2)
	{
	    howManyX = xi2 - xi1;
	    xStart = xi1;
	}
	else
	{
	    howManyX = xi1 - xi2;
	    xStart = xi2;
	}

	/* Update the character extents */
	if (bmapExtent.yMin > yStart)
	    bmapExtent.yMin = yStart;
	if (bmapExtent.yMax < yStart + howManyY)
	    bmapExtent.yMax = yStart + howManyY;
	if (bmapExtent.xMin > xStart)
	    bmapExtent.xMin = xStart;
	if (bmapExtent.xMax < xStart + howManyX)
	    bmapExtent.xMax = xStart + howManyX;

	if (!scanInX)
	    howManyX = 0;	/* this will skip all scan conversion in X */
	fsp1 = fsPtr.intc;

	/** Line segment goes from (xf1, yf1) to (xf2, yf2).
	    (xi1, yi1) and (xi2, yi2) are these endpoints rounded to integers
	    alphaY is the slope of the line; alphaX is the inverse slope
	    xcept and ycept are not really explainable in words, but are derived
	    from the equations for a line:  x = (1/s)(y - y1) + x1  and
	    y = s(x - x1) + y1,  (s = slope, (x1, y1) is a point on the line)
	    alphaXi, alphaYi, xceptInt, yceptInt are fixed point numbers: the
	    16 high-order bits are for the integer and the 16 low-order bits are
	    for the fraction **/

	q1 = xf2 - xf1;
	q2 = yf2 - yf1;
	if (howManyY)
	{
	    Real	alphaX;		/* step for computing x-intercepts */
	    Int32	alphaXi;	/* fix vrsn of alphaX, 16 frac bits */
	    Real	xcept;		/* x-intercept */
	    Int32	xceptInt;	/* fix x-intercept, 16 frac bits */
	    IntElem	**yscan;	/* ptr to lists of x-intercepts */

	    yscan = yslist[subcharCount - 1];	/* lists for current subchar */
	    alphaX = q1 / q2;			/* inverse slope of line */
	    alphaXi = floor (65536. * alphaX + 0.5);
	    xcept = xf1 + alphaX * (((Real) yStart - .5) - yf1);
	    xceptInt = floor (65536. * xcept + 0.5);

	    /* Start from the lowest scan line; go to the highest */
	    yScanIndex = yStart + bslOffY;
	    for (ii = 0;  ii < howManyY;  ii++, yScanIndex++)
	    {
		/* Make sure there is enough free space; alloc more if needed */
		if (freeSpace == 0)
		{
		    freeSpace = MAX (ISPACE, howManyY - ii);
		    fsp1 = (IntElem *) _FSMalloc (freeSpace * sizeof(IntElem));
		    allocList[allocCount++] = (char *) fsp1;
		}
		xceptInt += alphaXi;	/* intercept pt: (xceptInt, yScanIndex + 0.5) */
		fsp1->intc = xceptInt;
		_FSAddScanList (fsp1, yscan, yScanIndex);
		fsp1++;
		freeSpace--;
	    }
	}

	if (howManyX)
	{
	    Real	alphaY;		/* step for computing y-intercepts */
	    Int32	alphaYi;	/* fix vrsn of alphaY, 16 frac bits */
	    Real	ycept;		/* y-intercept */
	    Int32	yceptInt;	/* fix y-intercept, 16 frac bits */
	    IntElem	**xscan;	/* ptr to lists of y-intercepts */

	    xscan = xslist[subcharCount - 1];
	    alphaY = q2 / q1;	/* slope of line */
	    alphaYi = floor (65536. * alphaY + 0.5);
	    ycept = yf1 + alphaY * (((Real) xStart - .5) - xf1);
	    yceptInt = floor (65536. * ycept + 0.5);
	    xScanIndex = xStart + bslOffX;
	    for (ii = 0;  ii < howManyX;  ii++, xScanIndex++)
	    {
		/* Make sure there is enough free space; alloc more if needed */
		if (freeSpace == 0)
		{
		    freeSpace = MAX (ISPACE, howManyX - ii);
		    fsp1 = (IntElem *) _FSMalloc (freeSpace * sizeof(IntElem));
		    allocList[allocCount++] = (char *) fsp1;
		}
		yceptInt += alphaYi;	/* intercept pt: (yceptInt, xScanIndex + 0.5) */
		fsp1->intc = yceptInt;
		_FSAddScanList (fsp1, xscan, xScanIndex);
		fsp1++;
		freeSpace--;
	    }
	}
	fsPtr.intc = fsp1;	/* update free space pointer */
    }
}


void  _FSAddScanList (freeSp, scan, scanIndex)
IntElem	*freeSp;
IntElem	**scan;
Int16	scanIndex;

/*  _FSAddScanList -- puts freeSp into a linked list. The list is sorted in
 *	in ascending order by freeSp->intc
 *  Input arguments:
 *    freeSp -- free space pointer
 *    scan -- ptr to lists of x- or y-intercepts
 *    scanIndex -- index for scan
 *  Output arguments:
 *  Called from:  _FSProcVect
 */
{
    IntElem	*ex1, *ex2;


    ex1 = scan[scanIndex];
    if (ex1 == NULL)	/* null list */
    {
	freeSp->intNext = NULL;	/* create 1st list element */
	scan[scanIndex] = freeSp;
    }
    else if (freeSp->intc <= ex1->intc)	/* insert new value into the */
    {
	/* 1st position */
	freeSp->intNext = ex1;
	scan[scanIndex] = freeSp;
    }
    else	/* insert new x-value into the list */
    {
	while (TRUE)	/* loop until find a larger x in the */
	{		/* list or until reach end of list */
	    ex2 = ex1->intNext;
	    if (ex2 == NULL)
	    {
		freeSp->intNext = NULL;
		ex1->intNext = freeSp;
		break;
	    }
	    else if (freeSp->intc <= ex2->intc)
	    {
		freeSp->intNext = ex2;
		ex1->intNext = freeSp;
		break;
	    }
	    else
		ex1 = ex2;
	}
    }
}


#define	INT_PART	1	/* high word of 4-byte value on PDP11 type CPU */
#define	FRACT_PART	0	/* low word   ""  */

Boolean  _FSConvertLists ()

/*  _FSConvertLists -- Creates a bitmap from the scan-conversion lists
 *  Input arguments:
 *	None.
 *  Output arguments:
 *	Allocates memory for bitmap of charNode and creates the bitmap data as
 *	either bitmap or RLE.
 *  Called from:  _FSCharScanConvert
 *  Returns:  TRUE if all goes well
 *	FALSE if bitmap is too large or
 *	if on any scan line the number of intercepts is odd
 */
{
    BmapBitmap	*charBmap,	/* ptr to character bitmap */
		*bitmap,	/* ptr to temporary bitmap */
		**bmapHandle;	/* handle to bitmap */
    Int16	bit1, bit2;	/* 1st bit on, last bit on */
    IntElem	*ex1;		/* x-, y-intercept list elements */
    Int32	ii, jj, kk;	/* temps */
    Int16	offHor;		/* hor. offset to minimum bitmap (from origin) */
    Int16	rHgt, rWid;	/* raster height, width of character */
    Int32	sizeBmap;	/* size of bitmap in bytes */
    Int32	sizeRLE;	/* size of run-length data in bytes */
    Int32	theSize;
    char	*theData;
    Int32	theFlags;
    IntElem	**xscan;	/* pointer to array of lists of y-intercepts */
    IntElem	**yscan;	/* pointer to array of lists of x-intercepts */
    Int16	xleft;		/* leftmost raster column of bitmap character */
    Int16	ytop;		/* top raster row of bitmap character */
    Int32	zz, zz1, zz2;	/* temps */
    Int16	*zzs;		/* ptr to 32-bit word so it can be read as 2 16-bit words */
    Boolean	run16;		/* T: 16-bit run-length data */
    char	bmapRLE[100000]; /* run-length data */

    static Int32 onepix = 65536L;	/* 1.0 pixels */

    void	_FSConvertThresh(); /* decide which pixel to turn on, while attempting to preserve white space */
    void	_FSSetBits();	/* sets bits in a bitmap scan line */
    void	_FSSet1Bit();


    rWid = bmapInfo->rWid;
    rHgt = bmapInfo->rHgt;
    offHor = bmapInfo->hOff;
    sizeBmap = BMAP_BMAP_SIZE (((rWid + 7) >> 3) * rHgt);

    bmapInfo->flags = FS_REAL_BITMAP;	/* for now */
    bmapInfo->nMap = sizeBmap;

    if ((allBitmaps) || (sizeBmap == 0))
    {
	if ((bmapHandle = _FSBmapNewMap (charNode, sizeBmap)) == NULL)
	    return (FALSE);
	_GCSetPurge (bmapHandle, TRUE);

	if (sizeBmap == 0)
	    return (TRUE);

	bitmap = _FSBmapCharBitmap (charNode);
    }
    else
    {
	if ((bitmap = (BmapBitmap *) _FSAlloc (sizeBmap)) == NULL)
	    return (FALSE);
    }

    /** Clear the bitmap **/
    memset (bitmap, 0, sizeBmap);

    zzs = (Int16 *) (&zz);
    ytop = bmapExtent.yMax - 1 + bslOffY;	/* top bitmap scan line */
    for (jj = 0; jj < subcharCount; jj++)	/* for each sub-character */
    {
	yscan = yslist[jj];
	for (ii = 0; ii < rHgt; ii++)
	{
	    /* ex1 points to a list of x-intercepts for 1 y scan line */
	    ex1 = yscan[ytop - ii];
	    if (ex1 != 0)	/* if ex1 = 0, there's nothing in this row */
	    {
		/** The basic fill algorithm is that if the center of a pixel
		    is in the interior of the outline, that pixel is turned
		    on. Intercepts must come in pairs. Each one is a 32-bit
		    number with a 16-bit integer part and a 16-bit fractional
		    part, represented by zzs[INT_PART] and zzs[FRACT_PART].
		    If the first x- (y-) intercept is in the right (top) half
		    of the pixel, then the fractional part will be a negative
		    16-bit number. We don't want to include that pixel. If the
		    second x- (y-) intercept is in the left (bottom) half of the
		    pixel, then the fractional part will be a positive 16-bit
		    number. We don't want to include that pixel either. **/

		while (TRUE)	/* list is not null */
		{
		    zz = ex1->intc;	/* 1st intercept */
		    zz1 = zz;
		    bit1 = zzs[INT_PART];
		    if (zzs[FRACT_PART] < 0)
			bit1++;

		    ex1 = ex1->intNext;	/* Next list element */
		    _FSAssert (ex1 != 0);	/* odd # of intercepts? */

		    if (thicken)
			ex1->intc += onepix;

		    zz = ex1->intc;	/* 2nd intercept */
		    bit2 = zzs[INT_PART];
		    if (zzs[FRACT_PART] >= 0)
			bit2--;

		    if (bit2 >= bit1)	/* Is segment at least 1 pixel wide? */
		    {
			 if (bit1 < bmapExtent.xMin)	/* clipping */
				bit1 = bmapExtent.xMin;
			 if (bit2 >= bmapExtent.xMax)
				bit2 = bmapExtent.xMax - 1;
			 if (bit2 >= bit1)	/* This test IS necessary */
				_FSSetBits (bitmap, ii, rWid,
					    bit1 - offHor, bit2 - bit1 + 1);
		    }
		    else if (zz == zz1)	/* must be an IGDS font (yuk) */
		    {
			if ((bit1 >= bmapExtent.xMin) &&
			    (bit1 < bmapExtent.xMax))
			    _FSSet1Bit(bitmap, ii, bit1 - offHor, rWid);
			else if ((bit2 >= bmapExtent.xMin) &&
				 (bit2 < bmapExtent.xMax))
			    _FSSet1Bit(bitmap, ii, bit2 - offHor, rWid);
		    }
		    else
			/** If a thin stroke does not include the center of any
			    pixel, then if the stroke width is greater than
			    the threshold, one pixel is turned on anyway. **/
		    {
			 if (zz - zz1 > threshBlack)
			 {
			    _FSConvertThresh (yscan[ytop - ii], ex1, bitmap,
					      ii, X_DIMENSION);
			}
		    }

		    ex1 = ex1->intNext;
		    if (ex1 == 0)
			break;	/* at the end of each list */
		} /* end WHILE (TRUE) */
	    }
	} /* end  FOR (II = 0; II < RHGT; II++)  { */
    } /* end  FOR (JJ = 0; JJ < subcharCount; JJ++)  { */

    /** Now fill in the gaps by checking the xscan lists of y-intercepts.
	Ignore runs of > 1.0 pixel. If < 1.0 pixel add that pixel to the bmap */

    if (scanInX)
    {
	xleft = bmapExtent.xMin + bslOffX;		/* leftmost scan line */
	for (jj = 0; jj < subcharCount; jj++)	/* for each sub-character */
	{
	    xscan = xslist[jj];
	    for (ii = 0; ii < rWid; ii++)
	    {
		ex1 = xscan[xleft + ii];
		if (ex1 != 0)
		{
		    while (TRUE)
		    {
			if (thicken)  ex1->intc -= onepix;
			zz1 = ex1->intc;	/* 1st y-intercept */
			ex1 = ex1->intNext;
			_FSAssert (ex1 != 0);	/* odd # of intercepts? */

			zz2 = ex1->intc;	/* 2nd y-intercept */

			zz = zz1;
			bit1 = zzs[INT_PART];
			if (zzs[FRACT_PART] < 0)  bit1++;
			zz = zz2;
			bit2 = zzs[INT_PART];
			if (zzs[FRACT_PART] >= 0)  bit2--;

			if (thicken)
			{
			    if (bit1 < bmapExtent.yMin)    /* clipping */
				bit1 = bmapExtent.yMin;
			    if (bit2 >= bmapExtent.yMax)
				bit2 = bmapExtent.yMax - 1;
			    if (bit2 >= bit1)
			    {
				for (kk = bit1; kk <= bit2; kk++)
				    _FSSet1Bit(bitmap, bmapExtent.yMax - kk - 1,
					       ii, rWid);
			    }
			}
			else if (zz1 == zz2)	/* must be an old IGDS font */
			{
			    if ((bit1 >= bmapExtent.yMin) &&
				(bit1 < bmapExtent.yMax))
				_FSSet1Bit(bitmap, bmapExtent.yMax - bit1 - 1,
					   ii, rWid);
			    else if ((bit2 >= bmapExtent.yMin) &&
				     (bit2 < bmapExtent.yMax))
				_FSSet1Bit(bitmap, bmapExtent.yMax - bit2 - 1,
					   ii, rWid);
			}
			else if ((zz2 - zz1 < onepix) && (bit2 != bit1))
			{	/* run is < 1.0 pixel; does not cover pixel center */
			    if ((zz2 - zz1) > threshBlack)
			    {	/* run > threshold, so we can still use it */
				_FSConvertThresh (xscan[xleft + ii], ex1,
						  bitmap, ii, Y_DIMENSION);
			    }
			}

			ex1 = ex1->intNext;
			if (ex1 == 0)  break;
		    }
		}
	    }
	}
    }

    if (allBitmaps)
	return (TRUE);

    sizeRLE = _FSUnconvertRLE8 (bitmap, (uInt8 *)bmapRLE, rWid, rHgt);
    if (run16 = (sizeRLE < 0))
	sizeRLE = _FSUnconvertRLE16 (bitmap, (Int16 *)bmapRLE, rWid, rHgt);
    sizeRLE = BMAP_BMAP_SIZE (sizeRLE);

    if (allRLE || (sizeRLE < sizeBmap))
    {
	theSize = sizeRLE;
	theData = (char *) bmapRLE;
	theFlags = (run16 ? FS_RUNLENGTH_16 : FS_RUNLENGTH_8);
    }
    else
    {
	theSize = sizeBmap;
	theData = (char *) bitmap;
	theFlags = FS_REAL_BITMAP;
    }

    if ((bmapHandle = _FSBmapNewMap (charNode, theSize)) == NULL)
	return (FALSE);
    _GCSetPurge (bmapHandle, TRUE);

    charBmap = _FSBmapCharBitmap (charNode);
    memcpy (charBmap, theData, theSize);
    bmapInfo->flags = theFlags;
    bmapInfo->nMap = theSize;

    _FSDealloc ((char *)bitmap);

    return(TRUE);
}


void  _FSConvertThresh (ex1, ex2, bmap, scanline, dimension)
IntElem		*ex1, *ex2;	/* beginning of list; match element */
BmapBitmap	*bmap;		/* bitmap pointer */
Int32		scanline;	/* scan line in bitmap (0 = top) */
Int		dimension;	/* 0=X, 1=Y */
{
    IntElem	*ex1This, *ex2This;	/* current list pair */
    IntElem	*ex1Prev, *ex2Prev;	/* previous list pair (or 0) */
    IntElem	*ex1Next, *ex2Next;	/* n*ext list pair (or 0) */
    Int32	bitSet;	/* set this bit in bitmap if > 0  */
    Int32	bit, row;	/* bit, row in character bitmap */
    Int32	firstChoice;	/* best bit to set by ctr of gravity */
    Int32	secondChoice;	/* next-best bit */
    Boolean	secondOn;	/* use or don't use secondChoice */
    Int32	nn;
    Int32	prevEdge;	/* right edge of prev list pair */
    Int32	nextEdge;	/* left edge of next list pair */
    Int32	whitesp;	/* length of whitespace */
    Int32	zz, zz1, zz2;	/* temps */
    Int16	*zzs;	/* ptr to 32-bit word so it can be read as 2 16-bit words */

    void	_FSSet1Bit();	/* sets one bit  */


    ex1Prev = ex2Prev = 0;
    ex1This = ex1;
    zzs = (Int16 *)(&zz);
    prevEdge = -10000;
    nextEdge = 10000;
    bitSet = -10000;
    while (TRUE)
    {
	_FSAssert (ex1This != 0);

	ex2This = ex1This->intNext;
	_FSAssert (ex2This != 0);

	if (ex2 != ex2This)
	{
	    ex1Prev = ex1This;
	    ex2Prev = ex2This;
	    ex1This = ex2This->intNext;
	}
	else
	{
	    ex1Next = ex2This->intNext;
	    if (ex1Next != 0)
	    {
		ex2Next = ex1Next->intNext;
		if (ex2Next == 0)
		    ex1Next = 0;
	    }
	    if (ex1Prev != 0)
	    {
		whitesp = ex1This->intc - ex2Prev->intc;
		if (whitesp > threshWhite)
		    prevEdge = (ex2Prev->intc - 32768L) >> 16;
		else
		    ex1Prev = 0;
	    }
	    if (ex1Next != 0)
	    {
		whitesp = ex1Next->intc - ex2This->intc;
		if (whitesp > threshWhite)
		    nextEdge = (ex1Next->intc + 32768L) >> 16;
		else
		    ex1Next = 0;
	    }
	    zz1 = ex1This->intc;
	    zz2 = ex2This->intc;
	    _FSAssert (((zz = zz2 - zz1) >= threshBlack) && (zz <= 65536L));

	    zz = (zz1 + zz2) / 2;
	    firstChoice = zzs[INT_PART];
	    if ((prevEdge < (firstChoice - 1)) &&
		(nextEdge > (firstChoice + 1)))
	    {
		bitSet = firstChoice;
		break;
	    }

	    /* if stroke is split between 2 pixels, and at < 4:1 ratio */
	    nn = ((Int32)(ex2This->intc -
			  ((ex2This->intc + 32768L) & 0xFFFF0000))  <<  16) /
		  (ex2This->intc - ex1This->intc);
	    if ((nn >= 13107) && (nn <= 52429))   /* 20%, 80% of 65536 */
		secondOn = TRUE;
	    else
		secondOn = FALSE;

	    if (secondOn)
	    {
		if (zzs[FRACT_PART] >= 0)
		    secondChoice = firstChoice - 1;
		else
		    secondChoice = firstChoice + 1;
		if ((prevEdge < (secondChoice - 1)) &&
		    (nextEdge > (secondChoice + 1)))
		{
		    bitSet = secondChoice;
		    break;
		}
	    }

	    break;
	}
    }

    if (bitSet != -10000)
    {
	if (dimension == X_DIMENSION)
	{
	    bitSet -= bmapExtent.xMin;
	    if ((bitSet >= 0) && (bitSet < bmapInfo->rWid))
		_FSSet1Bit (bmap, scanline, bitSet, bmapInfo->rWid);
	}
	else
	{
	    bit = scanline;
	    row = bmapExtent.yMax - 1 - bitSet;
	    if ((row >= 0) && (row < bmapInfo->rHgt))
		_FSSet1Bit (bmap, row, bit, bmapInfo->rWid);
	}
    }
    return;
}
	

Int  _FSGetCompToken (
    ArcType	*coord)	/* arc data type, endpoint + bulge factor */

/*  Reads compressed outline data records using _FSGetRec()
 *  Returns data in 'coord'
 */
{
    Int16	ptype;
    Int32	x, y, beta;


    if (pThisRec >= pLastRec)
	return(ENDFILE);

    _FSAssert (incremFormat);

    if (incremFormat)	/* incremental format */
	_FSGetRec(0, &pThisRec, pFirstRec, &ptype, &x, &y, &beta);

    coord->xx = x;
    coord->yy = y;
    coord->bugFat = beta;
    switch (ptype)
    {
	case 0:
	    return (ENDCHAR);
	case 1:
	    return (STARTCRV);
	case 2:
	case 3:
	case 4:
	    return (VECT);
	case 5:
	    return (ARC);
	case 6:
	    return (SETSCALE);
	case 7:
	    return (SETORIG);
	case 8:
	    return (X_MIN_EXTENT);
	case 9:
	    return (X_MAX_EXTENT);
	case 10:
	    return (Y_MIN_EXTENT);
	case 11:
	    return (Y_MAX_EXTENT);
	case 12:
	    return (DOCHAR);
	case 13:	/* hierarchy data */
	    return (IGNORE);
	case 14:
	    return (XZONE);
	case 15:
	    return (YZONE);
	case 16:
	    return (PITEM);
	case 17:
	    return (FITEM);
	case 18:
	    return (CONST);
	case 19:
	    return (OPCODE);
	case 20:
	    return (TITEM);
	default:
	    return (SNAFU);
    }
}



void  _FSNewSubchar ()

/** Allocate memory for scan conversion pointers
    A character is compounded of 1 or more subcharacters.
    This routine is called by _FSCharScanConvert (STARTCRV) at the
    beginning of every character or subcharacter **/
{
    Int		jj;
    IntElem	**scanlist;	/* ptr to lists of x-intercepts */


    if (!outlFlag)
    {
	scanlist = (IntElem **) _FSAlloc (nbrScanlY * sizeof (IntElem *));
	allocList[allocCount++] = (char *) scanlist;
	yslist[subcharCount] = scanlist;
	for (jj = 0; jj < nbrScanlY; jj++)	/* initialize lists to 0 */
	    scanlist[jj] = 0;

	if (scanInX)
	{
	    scanlist = (IntElem **) _FSAlloc (nbrScanlX * sizeof (IntElem *));
	    allocList[allocCount++] = (char *) scanlist;
	    xslist[subcharCount] = scanlist;
	    for (jj = 0;  jj < nbrScanlX;  jj++)	/* initialize lists to 0 */
		scanlist[jj] = 0;
	}
    }
    subcharCount++;

    return;
}



Real  _FSNormRot (angle)
Real	angle;

/*  Normalizes rotation angle to a value between 0 and 360 degrees */
{
    while (TRUE)
    {
	if (angle < 0.)
	    angle += 360.;
	else if (angle >= 360.)
	    angle -= 360.;
	else  break;
    }
    return (angle);
}



Real  _FSNormObl (angle)
Real	angle;

/*  First normalizes obliquing angle to a value between -90 and 90 degrees */
/*  Then clamps absolute values of greater than 85 degrees */
{
    while (TRUE)
    {
	if (angle <= -90.)
	    angle += 180.;
	else if (angle > 90.)
	    angle -= 180.;
	else  break;
    }
    if (angle > 85.)  angle = 85.;
    if (angle < -85.)  angle = -85.;
    return (angle);
}
