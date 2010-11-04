/* $RCSfile: fsmkfnt.c $$Revision: 1.3 $$Date: 1991/02/28 17:50:15 $ Copyright (c) 1990 Intergraph Corp. */

#include <math.h>
#include <string.h>
#include <memory.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSUtil.h"
#include "../hfiles/FSFont.h"
#include "../hfiles/FSMakeFont.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSOutl.h"
#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSBmapCach.h"
#include "../hfiles/FSOutlCach.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSTFCache.h"
#include "../hfiles/FSCharMap.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSNewFont.h"
#include "../hfiles/FSOutlCach.h"
#include "../hfiles/FSKern.h"
#include "../hfiles/FSGenCache.h"
#include "../hfiles/FSPixCache.h"


/***** GLOBALS *****/
extern int FSdebug;

FileRef		*_FSTypefaceRef = NULL;		/* tf reference */
char		*_FSTypefaceName = NULL;	/* tf file passed to FSNewFont */
TFStruct	*_FSTypefacePtr = NULL;		/* tf struct cache pointer */
Real		_FSLinesPerEm = 0.0;		/* vertical # scan lines per emsq. */
Real		_FSResFactor = 0.0;		/* apparent resolution factor */
Real		_FSAspectRatio = 0.0;		/* aspect ratio (default = 1.0) */
Real		_FSRotAngle = 0.0;		/* rot. angle in degrees (ccw = +) */
Real		_FSOblAngle = 0.0;		/* obl. angle in degrees (ccw = +) */
FileRef		*_FSCharMapRef = NULL;		/* char map reference */
char		*_FSCharMapName = NULL;		/* char map passed to FSNewFont */
CharMapStruct	*_FSCharMapPtr = NULL;		/* char map cache pointer */
Int32		_FSFlags = 0;			/* fontSpec flags */
Boolean		_FSAllBitmaps = FALSE;		/* T: all chars stored as bitmaps */
Boolean		_FSAllRLE = FALSE;		/* T: all chars stored as RLE */
Boolean		_FSOutlFlag = FALSE;		/* T: making outline font */
Boolean		_FSThicken = FALSE;		/* T: thicken bmap font by one pxl */
Boolean		_FSBogusMode = FALSE;		/* T: plaid data to be ignored */
Boolean		_FSOutl3D = FALSE;		/* T: 3D outlines in font */
Boolean		_FSDemandFlag = FALSE;		/* T: create chars only when needed */
Boolean		_FSIntWidthsFlag = FALSE;	/* T: round all set widths */
Boolean		_FSAddCharacters = FALSE;	/* T: Add chars to font if not already there*/
Boolean		_FSNoPolys = FALSE;		/* T: no fillable polygons in font */
Boolean		_FSClipLeft = FALSE;		/* T: Clip min x at left of emsq. */
Boolean		_FSClipRight = FALSE;		/* T: Clip max x at right of emsq. */
Boolean		_FSClipBottom = FALSE;		/* T: Clip min y at bottom of emsq. */
Boolean		_FSClipTop = FALSE;		/* T: Clip max y at top of emsqu. */
Boolean		_FSKerningFlag = FALSE;		/* T: create kern table */
Real		_FSLinesPerEmX = 0.0;		/* horizontal # pixels per em space */
Real		_FSPointSizeX = 0.0;		/* x-point size (72.3 pts per inch) */
Real		_FSPointSizeY = 0.0;		/* y-point size (72.3 pts per inch) */
Real		_FSResH = 0.0;			/* output device resolution, horiz. */
Real		_FSResV = 0.0;			/* output device resolution, vert. */
Boolean		_FSSqueezeLeft = FALSE;		/* T: Squeeze min x into left of emsq. */
Boolean		_FSSqueezeRight = FALSE;	/* T: Squeeze max x into right of emsq. */
Boolean		_FSSqueezeBottom = FALSE;	/* T: Squeeze min y into bottom of emsq. */
Boolean		_FSSqueezeTop = FALSE;		/* T: Squeeze max y into top of emsq. */
SubsetList	_FSSubset = { 0 };		/* Subset of char map */
Boolean		_FSSWFixed = FALSE;		/* T: set width constrained */
Real		_FSXHgtAdj = 0.0;		/* x height adjustment */


/***** STATIC VARIABLES *****/

static uInt32	lastTFTag;		/* file tag of last typeface used */
static Real	lastLinesPerEm = 0.0;
static Real	lastLinesPerEmX = 0.0;



/* This routine makes a font and returns the font node handle in	*/
/* *fontNode.  The parameters for making the font are specified by the	*/
/* huge list of globals above.						*/

int _FSMakeFont (FontNode ***fontNode)
{
    Int		rval;
    Boolean	tfChanged;

    BmapNode	**_FSCreateBmapFont();
    OutlNode	**_FSCreateOutlFont();


    if (_FSLinesPerEm < 5.5)
	_FSBogusMode = TRUE;	/* plaid screws up very small fonts */

    /** Cache the typeface **/
    if ((rval = _FSGetTF (_FSTypefaceRef, &_FSTypefacePtr)) != FS_NO_ERROR)
	return (rval);

    /** Cache the char map **/
    if ((rval = _FSGetCharMap (_FSCharMapRef, &_FSCharMapPtr)) != FS_NO_ERROR)
	return (rval);

    /** Load the typeface if necessary **/
    tfChanged = (_FSTypefaceRef->tag != lastTFTag);
    if (tfChanged)
	_FSNewCache (_FSTypefacePtr->charDirHdr.nrRecs);

    /** Reinit the pixel cache only if something changed **/
    if (tfChanged || (_FSLinesPerEm != lastLinesPerEm) ||
	(_FSLinesPerEmX != lastLinesPerEmX))
	_FSInitCache (_FSLinesPerEmX, _FSLinesPerEm);

    lastTFTag = _FSTypefaceRef->tag;
    lastLinesPerEm = _FSLinesPerEm;
    lastLinesPerEmX = _FSLinesPerEmX;

    if (_FSTypefacePtr->info.outlFmtNr[1] == '1')
	_FSBogusMode = TRUE;	/* skip cache searching if absolute format */

    _FSNoPolys = _FSTypefacePtr->info.flag2 & FS_NOPOLYS;

    if (*fontNode == NULL)	/* empty font node handle? */
    {
	if (_FSOutlFlag)	/* the only place this flag is looked at! */
	{
	    if ((*fontNode = _FSCreateOutlFont ()) == NULL)
		return (FS_CANT_ALLOC);

	    _FSOutlAutosetHeader (*fontNode);
	}
	else
	{
	    if ((*fontNode = _FSCreateBmapFont ()) == NULL)
		return (FS_CANT_ALLOC);

	    _FSBmapAutosetHeader (*fontNode);
	}

	_FSSetGenericStuff (*fontNode);
    }

    if ((rval = _FSConvertToFont (*fontNode)) != FS_NO_ERROR)
	return (rval);

    if ((rval = _FSUpdateFont (*fontNode)) != FS_NO_ERROR)
	return (rval);

    return (FS_NO_ERROR);
}



/* This routine deletes the specified font. */

int _FSUnmakeFont (FontNode **fontNode)
{
    if (_FSBmapFont (fontNode))		/* bitmap font? */
    {
	_FSBmapFree (fontNode);
    }
    else if (_FSOutlFont (fontNode))	/* outline font? */
    {
	_FSOutlFree (fontNode);
    }
    else
	return (FS_INVALID_FONT);

    return (FS_NO_ERROR);
}



/* This routine initializes the MakeFont module.  Many of the above	*/
/* globals are initilized to default values.				*/

Int _FSEnterMF (void)
{
    /** Create the font cache **/
    _GCEnter ();

    /** Initialize the fontware globals that never change **/
    _FSClipLeft = FALSE;
    _FSClipRight = FALSE;
    _FSClipBottom = FALSE;
    _FSClipTop = FALSE;
    _FSSqueezeLeft = FALSE;
    _FSSqueezeRight = FALSE;
    _FSSqueezeBottom = FALSE;
    _FSSqueezeTop = FALSE;
    _FSSWFixed = TRUE;
    _FSXHgtAdj = 1.0;

    /** This is arbitrary **/
    _FSResH = _FSResV = 100.0;

    lastTFTag = 0;
    lastLinesPerEm = lastLinesPerEmX = 0.0;

    return (FS_NO_ERROR);
}



/* This routine deallocates memory used by the MakeFont module.		*/

Int _FSExitMF (void)
{
    _FSDeleteCache ();
    _GCExit ();

    return (FS_NO_ERROR);
}



/* This routine initializes the generic parts of a font: the modes,	*/
/* regeneration information, kerning pair table, and font info		*/
/* structure.								*/

Int _FSSetGenericStuff (FontNode **fontNode)
{
    int			i, allChars, length;
    char		*ptr;
    FontInfo		*info;
    FontModes		*modes;
    FontRegen		*regen;

    /** Kerning tracks & pairs **/
    if (_FSKerningFlag)
	_FSDoKernPairs ((FontNode *)fontNode, _FSTypefacePtr); // XXX - Possible bad pointer being passed?

    /** Set the modes to default values **/
    _FSFontLockModes (fontNode);
    modes = _FSFontModes (fontNode);
    modes->kernPair = TRUE;
    modes->kernTrack = 0;
    modes->ligature = FALSE;
    modes->extraWidth = 0.0;
    _FSFontUnlockModes (fontNode);

    /** Set the regeneration stuff **/
    _FSFontLockRegen (fontNode);
    regen = _FSFontRegen (fontNode);
    memcpy (&regen->sourceRef, _FSTypefaceRef, sizeof (FileRef));
    memcpy (&regen->cmRef, _FSCharMapRef, sizeof (FileRef));
    regen->howToRegen = CALL_NEWFONT;
    _FSFontUnlockRegen (fontNode);


    /** Initialize the font info structure **/

    _FSFontLockInfo (fontNode);
    info = _FSFontInfo (fontNode);
    memset (info, 0, sizeof (BmapInfo));

    ptr = _FSGetBaseName (_FSTypefaceRef->fileName, _FSTFExtension, &length);
    strncpy ((char *)info->typeface, ptr, length);

    info->bodySize = (Real64) _FSLinesPerEm;
    info->resFactor = _FSResFactor;
    info->aspect = _FSAspectRatio;
    info->rotation = _FSRotAngle;
    info->slant = _FSOblAngle;

    ptr = _FSGetBaseName (_FSCharMapRef->fileName, _FSCMExtension, &length);
    strncpy ((char *)info->charMap, ptr, length);

    info->flags = _FSFlags;
    info->descent = (Real64) -EM_BOT * _FSLinesPerEm / EM_TOTAL;
    info->ascent = _FSLinesPerEm - info->descent;
    info->minExtent = (Real64) _FSTypefacePtr->info.extentYMin /
		      _FSTypefacePtr->info.reslPerEm * _FSLinesPerEm;
    info->maxExtent = (Real64) _FSTypefacePtr->info.extentYMax /
		      _FSTypefacePtr->info.reslPerEm * _FSLinesPerEm;
    info->drawDir = FS_LEFT_TO_RIGHT;
    info->fontFlags |= (_FSNoPolys ? 0 : FS_FILLABLE_FONT);

    allChars = _FSCharMapPtr->flags & FS_ALL_CHARS;
    if (!allChars)
    {
	info->missingChar = _FSCharMapPtr->missingChar;
	info->fontFlags |= (_FSCharMapPtr->flags & FS_SIXTEEN_BIT) ?
			   FS_SIXTEEN_BIT_FONT : 0;
    }
    else
    {
	info->missingChar = (CharId) -1;
	for (i = 0; i < _FSTypefacePtr->charDirHdr.nrRecs; i++)
	{
	    if (_FSTypefacePtr->charDir[i].charId >= 256)
	    {
		info->fontFlags |= FS_SIXTEEN_BIT_FONT;
		break;
	    }
	}
    }

    _FSDoKernTracks ((FontNode *)fontNode, _FSTypefacePtr);

    _FSFontAutosetInfo (info);
    _FSFontUnlockInfo (fontNode);

    return (FS_NO_ERROR);
}



/* This routine creates a bitmap font and initializes the header.	*/

BmapNode **_FSCreateBmapFont ()

/*  Creates a bitmap font. Sets up the font header.
 *  Returns:  a handle to a bitmap font node
 *  Called from:  main
 */
{
    BmapNode	**bmapFont;
    BmapHeader	*header;


    bmapFont = _FSBmapCreateBmap ();

    _FSBmapLockHeader (bmapFont);
    header = _FSBmapHeader (bmapFont);

    memset (header, 0, sizeof (BmapHeader));

    strncpy((char *)header->tfId, (char *)_FSTypefacePtr->info.srcFontId, 4);
    strncpy((char *)header->tfName,(char *)_FSTypefacePtr->info.srcFontName,70);
    strncpy((char *)header->tfFile, (char *)_FSTypefaceName, 128);
    header->tfRev = _FSTypefacePtr->info.srcFontVrsn;
    header->layoutNumber = _FSTypefacePtr->info.layoutNumber;

    _FSBmapUnlockHeader (bmapFont);

    return (bmapFont);
}



/* This routine creates an outline font and initializes the header.	*/

OutlNode **_FSCreateOutlFont ()

/*  Creates an outline font. Sets up the font header.
 *  Returns:  a handle to an outline font node
 *  Called from:  main
 */
{
    OutlNode	**outlFont;
    OutlHeader	*header;


    outlFont = _FSOutlCreateOutl ();

    _FSOutlLockHeader (outlFont);
    header = _FSOutlHeader (outlFont);

    memset (header, 0, sizeof (OutlHeader));

    strncpy ((char *)header->tfId, (char *)_FSTypefacePtr->info.srcFontId, 4);
    strncpy ((char *)header->tfName, (char *)_FSTypefacePtr->info.srcFontName, 70);
    strncpy ((char *)header->tfFile, (char *)_FSTypefaceName, 128);
    header->tfRev = _FSTypefacePtr->info.srcFontVrsn;
    header->layoutNumber = _FSTypefacePtr->info.layoutNumber;

    _FSOutlUnlockHeader (outlFont);

    return (outlFont);
}



/* This routine updates sections of the header that depend on parts of	*/
/* the font that were calculated as the font was being created.		*/

Int  _FSUpdateFont (
FontNode **fontNode)	/* handle to font node */
{
    if (_FSBmapFont (fontNode))
	_FSBmapUpdateHeader (fontNode);
    else
	_FSOutlUpdateHeader (fontNode);

    return (FS_NO_ERROR);
}


Int  _FSConvertToFont (FontNode **fontNode)

/* Procedure to read an entire typeface and convert the appropriate chars into
 *   bitmaps or outlines. '_FSCharScanConvert' does the conversion for each
 *   character.
 *
 * Input argument:
 *    fontNode - handle to font node
 * Returns:
 *    TRUE if all characters are successfully scan converted, else FALSE
 */
{
    int		isBmapFont;	/* T: bmap font; else outline font */
    int		i;		/* loop index */
    int		charCount;	/* total # of chars to make */
    int		allChars;	/* T: all chars in typeface */
    CharId	*charIdTable;	/* table of character ids */
    uInt16	*charOffTable;	/* table of character offsets */
    Int16	numChar;	/* number of characters in char map */
    CompCharDesc compChar;	/* structure of character attributes */
    Int32	m1, m2, m3, m4;
    Int32	tmp;
    Real	cornerMax, maxPointSize;

    Boolean	_FSCharScanConvert();


    isBmapFont = _FSBmapFont (fontNode);

    /** Set up the compChar structure **/

    compChar.compf = _FSTypefacePtr;
    compChar.linesPerEm = _FSLinesPerEm;
    compChar.resFactor = _FSResFactor;
    compChar.pointSizeY = _FSPointSizeY;
    compChar.pointSizeX = _FSPointSizeX;
    compChar.resHor = _FSResH;
    compChar.resVer = _FSResV;
    compChar.rotAngle = -_FSRotAngle;	/* the rest of fontware wants */
    compChar.oblAngle = -_FSOblAngle;	/* clockwise positive angles  */
    compChar.clip.left = _FSClipLeft;
    compChar.clip.right = _FSClipRight;
    compChar.clip.top = _FSClipTop;
    compChar.clip.bottom = _FSClipBottom;
    compChar.squeeze.left = _FSSqueezeLeft;
    compChar.squeeze.right = _FSSqueezeRight;
    compChar.squeeze.top = _FSSqueezeTop;
    compChar.squeeze.bottom = _FSSqueezeBottom;
    compChar.swFixed = _FSSWFixed;
    compChar.bogusMode = _FSBogusMode;
    compChar.xHtAdj = _FSXHgtAdj;
    compChar.outlFlag = !isBmapFont;
    compChar.thicken = _FSThicken;
    compChar.noPolys = _FSNoPolys;
    compChar.outl3D = _FSOutl3D;
    compChar.allBitmaps = _FSAllBitmaps;
    compChar.allRLE = _FSAllRLE;
    compChar.intWidths = _FSIntWidthsFlag;

    /* Maximum distance to character envelope boundary in ORU's */
    maxPointSize = MAX (_FSPointSizeX, _FSPointSizeY);
    m1 = _FSTypefacePtr->info.extentXMin;
    m2 = _FSTypefacePtr->info.extentXMax;
    m3 = _FSTypefacePtr->info.extentYMin;
    m4 = _FSTypefacePtr->info.extentYMax;
    tmp = MAX (m1*m1 + m3*m3, m1*m1 + m4*m4);
    cornerMax = sqrt ((double)MAX (tmp, MAX (m2*m2 + m3*m3, m2*m2 + m4*m4)));
    compChar.bslOffX = (Int32)(cornerMax * _FSResH * maxPointSize /
			(PTPERINCH * _FSTypefacePtr->info.reslPerEm) + 3.0);
    compChar.bslOffY = (Int32)(cornerMax * _FSResV * maxPointSize /
			(PTPERINCH * _FSTypefacePtr->info.reslPerEm) + 3.0);

    if (!isBmapFont || _FSThicken || _FSNoPolys ||
	((_FSLinesPerEm * _FSLinesPerEmX) <= 5600.))    /*  74.8 ^ 2  */
	compChar.scanX = TRUE;
    else
	compChar.scanX = FALSE;


    allChars = _FSCharMapPtr->flags & FS_ALL_CHARS;
    if (_FSSubset.flag)
	numChar = _FSSubset.count;		/* # chars in subset */
    else if (allChars)
	numChar = _FSTypefacePtr->info.layoutSize;	/* # chars in tf */
    else
	numChar = _FSCharMapPtr->numChar;	/* # chars in char map */

    /** Allocate the char id & char offset tables **/
    charIdTable = (CharId *) _FSAlloc (numChar * sizeof (CharId));
    charOffTable = (uInt16 *) _FSAlloc (numChar * sizeof (uInt16));

    /** Construct the tables **/
    charCount = 0;
    for (i = 0; i < numChar; i++)
    {
	CharId	charId;
	Int16	chOff;

	if (_FSSubset.flag)
	{
	    charId = _FSSubset.list[i];
	    chOff = _FSSearchCharOff (_FSCharMapBsNbr (_FSCharMapPtr, charId));
	}
	else
	{
	    if (allChars)
	    {
		charId = _FSTypefacePtr->charDir[i].charId;
		chOff = i;
	    }
	    else
	    {
		charId = _FSCharMapPtr->charId[i].charId;
		chOff = _FSSearchCharOff (_FSCharMapPtr->charId[i].bsNbr);
	    }
	}

	if (chOff != -1)
	{
	    charIdTable[charCount] = charId;
	    charOffTable[charCount] = chOff;
	    charCount++;
	}
    }

    /** Add the chars to the char directory table if necessary **/
    if (_FSAddCharacters)
	_FSFontAppendCharDir (fontNode, charIdTable, charCount);

    /** Create the characters if the demand flag is FALSE **/
    if (!_FSDemandFlag)
    {
	CharId		*charIdPtr, *charIdEnd;
	uInt16		*charOffPtr;
	FontCharNode	**thisChar;

	compChar.fontNode = fontNode;

	charIdEnd = &charIdTable[charCount];
	for (charIdPtr = charIdTable, charOffPtr = charOffTable;
	     charIdPtr < charIdEnd; charIdPtr++, charOffPtr++)
	{
	    thisChar = _FSFontCharNode (fontNode, charIdPtr, FALSE);
	    if ((thisChar != NULL) && (*thisChar == NULL))
	    {
		/** Create the character **/
		compChar.chOff = *charOffPtr;
		compChar.charId = *charIdPtr;
		_FSCharScanConvert (&compChar);

		/** Initialize the character's timestamp **/
		_FSUpdateCharTime (fontNode, thisChar);
	    }
	}
    }

    _FSDealloc ((char *)charOffTable);
    _FSDealloc ((char *)charIdTable);

    return (FS_NO_ERROR);
}



Int  _FSSearchCharOff (Char16 bsNbr)

/*  _FSSearchCharOff -- returns a character offset number.
 *  Input argument:  bsNbr is a Bitstream number.
 *  Returns:	offset of character into typeface character table. Set to
 *		-1 if no match found for a character id number.
 */
{
    TFCharInfo	*charPtr, *charStart, *charEnd;

    if (bsNbr == (Char16) -1)
	return (-1);

    charStart = _FSTypefacePtr->charDir;
    charEnd = &_FSTypefacePtr->charDir[_FSTypefacePtr->info.layoutSize];
    for (charPtr = charStart; charPtr < charEnd; charPtr++)
    {
	if (bsNbr == charPtr->charId)
	    return (charPtr - charStart);
    }
    return (-1);
}
