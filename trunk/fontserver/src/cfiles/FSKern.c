/* $RCSfile: fskern.c $$Revision: 1.3 $$Date: 1991/02/28 17:49:51 $ Copyright (c) 1990 Intergraph Corp. */


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


/***************************** K E R N I N G . C *****************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 0)   6-Mar-87  mby

 1)  20-May-87  mby	1) generates all kerning pairs from outline font or
			2) generates only those pairs from a kerning pair file


 *****************************************************************************

   Generates kerning pair and kerning track data for bitmap & outline fonts

 ****************************************************************************/

#include <stdlib.h>
#include "../hfiles/import.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSFont.h"
#include "../hfiles/FSCharMap.h"
#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSTFCache.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSMakeFont.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSKern.h"
#include "../hfiles/FSOutlCach.h"


/***** EXTERNAL GLOBAL VARIABLES *****/

extern	Boolean	_FSOutlFlag;		/* T: outline font */
extern	Real	_FSLinesPerEmX;		/* horizontal # pixels per em space */
extern	Real	_FSPointSizeY;		/* y-point size (72.3 pts per inch) */
extern	Real	_FSResH;		/* horiz output device resolution */
extern	CharMapStruct *_FSCharMapPtr;


Int  _FSDoKernTracks (FontNode *font, TFStruct *cmfont)

/* _FSDoKernTracks -- Adds kerning tracks to font
 *
 * Input arguments:
 *   font -- handle to font node
 *   cmfont -- ptr to compressed font data structure
 * Called from:
 *   another module
 */
{
    Real		trk0, trk1, trk2, trk3;	/* kerning track values */
    FontInfo		*info;

    _FSFontLockInfo ((FontNode **)font);
    info = _FSFontInfo (font);

    /* get kerning tracks */
    _FSTrackPix (cmfont, &trk0, &trk1, &trk2, &trk3);

    info->track[0] = (Real64) trk0;
    info->track[1] = (Real64) trk1;
    info->track[2] = (Real64) trk2;
    info->track[3] = (Real64) trk3;

    _FSFontUnlockInfo ((FontNode **)font);
    return (FS_NO_ERROR);
}


Int  _FSDoKernPairs (FontNode *font, TFStruct *cmfont)

/* _FSDoKernPairs -- Adds kerning pairs to font
 *
 * Input arguments:
 *   font -- ptr to font node
 *   cmfont -- ptr to compressed font data structure
 * Called from:
 *   another module
 */
{
    Int8		charList1[256];	/* char ids from 0 to 255; 0 = absent */
    Char16		*charList2;	/* char ids >= 256, unsorted */
    Real		kernValue, scale;
    FontKernPair	*kernPair;	/* table of kern pairs */
    FontKernPair	*kernPairPtr;	/* ptr into kern pair table */
    TFKernPair		*tfKernPtr;	/* ptr to typeface kern pairs */
    TFKernPair		*tfKernEnd;	/* ptr to end of typeface kern pairs */
    TFCharInfo		*charDir;	/* ptr to typeface char dir */
    Char16		bs1, bs2;	/* char ids from typeface */
    CharId		ch1, ch2;	/* mapped char ids */
    int			numTFPairs;	/* # of kern pairs in typeface */
    int			numKernPair;	/* # of kern pairs in table */
    int			rval, allChars;

    Int		_FSComparePair ();	/* compare two kern pairs */
    Boolean	_FSCharIdMatch ();	/* match kern pair char id to font */

    /* If there are no kerning pairs or char ids in typeface, then	*/
    /* can't do kerning pairs						*/
    if (!(cmfont->info.flag1 & FS_KERNPR) || !(cmfont->info.flag1 & FS_CHARID))
	return (FS_NO_ERROR);

    allChars = _FSCharMapPtr->flags & FS_ALL_CHARS;

    /* Load and store character ids from font */
    charList2 = NULL;
    if (!allChars)
	_FSReadCharMapBsNbrs (_FSCharMapPtr, charList1, &charList2);

    /* Allocate temporary storage for kern pair table */
    numTFPairs = cmfont->kernPairHdr.nrRecs;
    kernPair = (FontKernPair *) _FSAlloc (numTFPairs * sizeof (FontKernPair));

    charDir = cmfont->charDir;
    scale = (Real) _FSLinesPerEmX / cmfont->info.reslPerEm;

    kernPairPtr = kernPair;
    tfKernEnd = &cmfont->kernPair[numTFPairs];
    for (tfKernPtr = cmfont->kernPair; tfKernPtr < tfKernEnd; tfKernPtr++)
    {
	/* Add kern pair to table iff both chars are in the char map	*/
	/* of the font							*/

	bs1 = charDir[tfKernPtr->char1].charId;
	bs2 = charDir[tfKernPtr->char2].charId;
	if (allChars ||
	    (_FSCharIdMatch (bs1, charList1, charList2) &&
	     _FSCharIdMatch (bs2, charList1, charList2)))
	{
	    /* A match. Convert from relative units to pixels */
	    kernValue = (Real) tfKernPtr->adjustment * scale;

	    if (allChars)
	    {
		ch1 = bs1;
		ch2 = bs2;
	    }
	    else
	    {
		ch1 = _FSCharMapCharId (_FSCharMapPtr, bs1);
		ch2 = _FSCharMapCharId (_FSCharMapPtr, bs2);
	    }

	    kernPairPtr->char1 = ch1;
	    kernPairPtr->char2 = ch2;
	    kernPairPtr->kern = (Real64) kernValue;

	    kernPairPtr++;
	}
    }
    numKernPair = kernPairPtr - kernPair;

    /** Sort the table and add it to the font **/
    qsort (kernPair, numKernPair, sizeof (FontKernPair), _FSComparePair);
    rval = _FSFontNewKernPairs ((FontNode **)font, (FontKernPair **)kernPair, numKernPair); // XXX - Possible bug.  Wrong pointers?

    _FSDealloc ((char *)kernPair);
    if (charList2 != NULL)
	_FSDealloc ((char *)charList2);

    return (rval);
}


Boolean  _FSCharIdMatch (char1, charList1, charList2)
Char16	char1;
Int8	*charList1;
Char16	*charList2;

/* _FSCharIdMatch -- Takes a character id and returns TRUE if char id is in
 *	either charList1 or charList2.
 * Input arguments:
 *   char1 -- character id
 *   charList1 -- quick lookup if char1 < 256
 *   charList2 -- do linear search of this array if char1 >= 256
 * Returns:
 *   TRUE  or FALSE
 */
{
    Int	ii;
    Int	nn;

    if (char1 < 256)
    {
	if (charList1[char1] == 0)
	    return (FALSE);
    }
    else
    {
	nn = *charList2++;	/* how many in charList2 */
	for (ii = 1; ii <= nn; ii++)
	{
	    if (char1 == *charList2++)
		break;
	}

	if (ii == nn+1)
	    return (FALSE);
    }

    return (TRUE);
}


Int  _FSReadCharMapBsNbrs (CharMapStruct *cPtr, Int8 *charList1, Char16 **charList2)

/* _FSReadCharMapBsNbrs -- returns all Bitstream ids in specified char map.
 * Input argument:
 *   cPtr -- character mapping cache pointer
 * Output argument:
 *   charList1 -- array that stores bs nbrs (0-255)
 *   charList2 -- ptr to array that stores bs nbrs (> 255)
 *		  charList2[0] = how many ids in charList2
 */
{
    Int			i, count;
    Char16		bsNbr;
    CharMapSpec		*bsNbrPtr, *bsNbrEnd;

    for (i = 0; i < 256; i++)
	charList1[i] = FALSE;

    *charList2 = (Char16 *) _FSAlloc ((cPtr->numChar + 1) * sizeof (Char16));

    count = 0;
    bsNbrEnd = &cPtr->bsNbr[cPtr->numChar];
    for (bsNbrPtr = cPtr->bsNbr; bsNbrPtr < bsNbrEnd; bsNbrPtr++)
    {
	bsNbr = bsNbrPtr->bsNbr;
	if (bsNbr < 256)
	    charList1[bsNbr] = TRUE;
	else
	    (*charList2)[++count] = bsNbr;
    }
    (*charList2)[0] = count;

    return (FS_NO_ERROR);
}


Int  _FSTrackPix (TFStruct *cmfont, Real *track1, Real *track2, Real *track3, Real *track4)

/* _FSTrackPix -- calculates track kerning adjustment in pixels
 *
 * Input argument:
 *   cmfont -- ptr to compressed font data structure
 * Output arguments:
 *   track1, track2, track3, track4 -- font tracking adjustments
 * Notes:
 *   When it is necessary to extrapolate a value, we assume that the track
 *   kerning adjustments are linear functions of the point size, with
 *   adjustment = 0 <==> point size 12.
 */
{
    TFKernTrack	*kernTrack;	/* pointer to kern tracks */
    Int		numTracks;	/* number of kern tracks */
    Int		ii;		/* temp */
    Real	q, q1;		/* temps */
    Real	lowBound;	/* smallest point size in track table */
    Real	uppBound;	/* biggest point size in track table */
    Real	yPoint;		/* y point size */
    Real	slope1;		/* slope of track 1 adjustment vs. point size */
    Real	slope2;		/* slope of track 2 adjustment vs. point size */
    Real	slope3;		/* slope of track 3 adjustment vs. point size */
    Real	slope4;		/* slope of track 4 adjustment vs. point size */
    Real	trk1Adj=0.0;	/* track 1 adjustment in 1/100 points */
    Real	trk2Adj=0.0;	/* track 2 adjustment in 1/100 points */
    Real	trk3Adj=0.0;	/* track 3 adjustment in 1/100 points */
    Real	trk4Adj=0.0;	/* track 4 adjustment in 1/100 points */

    kernTrack = cmfont->kernTrack;
    numTracks = cmfont->kernTrackHdr.nrRecs;

    lowBound = (Real) kernTrack[0].pointSize;
    uppBound = (Real) kernTrack[numTracks - 1].pointSize;
    yPoint = (Real) _FSPointSizeY;

    /* Does point size fall within the point size table? */
    if ((yPoint >= lowBound) && (yPoint <= uppBound))
    {
	for (ii = 0;  ii < numTracks;  ii++)
	{
	    if ((Real)kernTrack[ii].pointSize == yPoint)
	    {
		/* There is an exact match for point size */
		/* Get the track adjustments from the table */
		trk1Adj = (Real) kernTrack[ii].trackAdj[0];
		trk2Adj = (Real) kernTrack[ii].trackAdj[1];
		trk3Adj = (Real) kernTrack[ii].trackAdj[2];
		trk4Adj = (Real) kernTrack[ii].trackAdj[3];
		break;
	    }

	    if ((Real)kernTrack[ii].pointSize > yPoint)
	    {
		/* The track adjustments should be interpolated */
		q = (Real)(kernTrack[ii].pointSize - kernTrack[ii-1].pointSize);
		q1 = yPoint - kernTrack[ii].pointSize;
		if (q > 0)
		{
		    slope1 = (Real)(kernTrack[ii].trackAdj[0] -
				    kernTrack[ii-1].trackAdj[0]) / q;
		    slope2 = (Real)(kernTrack[ii].trackAdj[1] -
				    kernTrack[ii-1].trackAdj[1]) / q;
		    slope3 = (Real)(kernTrack[ii].trackAdj[2] -
				    kernTrack[ii-1].trackAdj[2]) / q;
		    slope4 = (Real)(kernTrack[ii].trackAdj[3] -
				    kernTrack[ii-1].trackAdj[3]) / q;
		    trk1Adj = kernTrack[ii].trackAdj[0] + (q1 * slope1);
		    trk2Adj = kernTrack[ii].trackAdj[1] + (q1 * slope2);
		    trk3Adj = kernTrack[ii].trackAdj[2] + (q1 * slope3);
		    trk4Adj = kernTrack[ii].trackAdj[3] + (q1 * slope4);
		}
		else
		    slope1 = slope2 = slope3 = slope4 = 0.;

		break;
	    }
	}
    }
    else	/* The track adjustments should be extrapolated */
    {
	q = uppBound - lowBound;
	if (q > 0)
	{
	    slope1 = (Real)(kernTrack[numTracks - 1].trackAdj[0] -
			    kernTrack[0].trackAdj[0]) / q;
	    slope2 = (Real)(kernTrack[numTracks - 1].trackAdj[1] -
			    kernTrack[0].trackAdj[1]) / q;
	    slope3 = (Real)(kernTrack[numTracks - 1].trackAdj[2] -
			    kernTrack[0].trackAdj[2]) / q;
	    slope4 = (Real)(kernTrack[numTracks - 1].trackAdj[3] -
			    kernTrack[0].trackAdj[3]) / q;
	}
	else
	    slope1 = slope2 = slope3 = slope4 = 0.;

	trk1Adj = kernTrack[0].trackAdj[0] + (yPoint - lowBound) * slope1;
	trk2Adj = kernTrack[0].trackAdj[1] + (yPoint - lowBound) * slope2;
	trk3Adj = kernTrack[0].trackAdj[2] + (yPoint - lowBound) * slope3;
	trk4Adj = kernTrack[0].trackAdj[3] + (yPoint - lowBound) * slope4;
    }

    /* Convert 100ths of points to pixels in x-dimension. */
    q = .01 * _FSResH / PTPERINCH;

    if (cmfont->info.flag1 & FS_KTRCK1)
	*track1 = (Real) (trk1Adj * q);
    else
	*track1 = 0.0;

    if (cmfont->info.flag1 & FS_KTRCK2)
	*track2 = (Real) (trk2Adj * q);
    else
	*track2 = 0.0;

    if (cmfont->info.flag1 & FS_KTRCK3)
	*track3 = (Real) (trk3Adj * q);
    else
	*track3 = 0.0;

    if (cmfont->info.flag2 & FS_KTRCK4)
	*track4 = (Real) (trk4Adj * q);
    else
	*track4 = 0.0;

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSGetKernPairValue (font, char1, char2, kernValue)		*/
/*									*/
/*	  FontNode	**font;		- font identifier		*/
/*	  CharId	char1;		- character identifier 1	*/
/*	  CharId	char2;		- character identifier 2	*/
/*	  Real64	*kernValue;	- kern value			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the kern value of the specified pair of	*/
/*	  characters using the given font.  The kern value is returned	*/
/*	  in kernValue.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Always zero.							*/
/*									*/
/************************************************************************/

int FSGetKernPairValue (font, char1, char2, kernValue)
FontNode	**font;
CharId		char1, char2;
Real64		*kernValue;
{
    _FSFontLockKernPairs (font);
    *kernValue = _FSFontKernValue (font, char1, char2);
    _FSFontUnlockKernPairs (font);

    return (FS_NO_ERROR);
}
