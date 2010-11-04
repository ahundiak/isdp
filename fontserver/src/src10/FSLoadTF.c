/* $RCSfile: fsloadtf.c $$Revision: 1.3 $$Date: 1991/02/28 17:50:08 $ Copyright (c) 1990 Intergraph Corp. */


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


/**************************** F S L o a d T F . c ****************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 0)  25-Nov-85  mike yudis

 1)  05-Dec-85  mby	Version 2.1 update. Added 'layoutSize' to
			_FSLoadXInfo & _FSWriteFontHeader

 2)  15-Jan-86  mby	Added optional char-id word to character directory

 3)  22-Jan-86  mby	Version 2.2 update. Added 'wordSpaceWidth' to
			_FSLoadXInfo & _FSWriteFontHeader

 4)   5-May-86  mby	Version 2.3 update. 'compr_font_2.3.h" is now the
			name of the "include" file

 5)   7-Jan-87  mby	include file name = comp2_3.h

 6)  27-Apr-87  mby	Fix bug reading & writing 2 word kerning pair recs

 7)   1-May-87  mby	Add 'O2' outline data record (outline data > 64K words)

 *****************************************************************************

    This module is used to access information in a Bitstream Compressed
    Outline file.

    The entry points into this module are '_FSCFTLoad', '_FSCFTUnload',
    _FSCFTLoadInfo, _FSCFTLoadKernPrs, _FSCFTLoadKernTrks, _FSCFTLoadCharDirs,
    and _FSCFTLoadOutlData.

    The procedure '_FSCFTLoad' is responsible for building the font information
    structure. It is assumed that a structure of the type 'TFStruct' has
    been declared in the calling module (see 'FSTypeface.h').
    A pointer to this structure is passed as an argument to the function.
    Memory for the kerning pairs, kerning tracks, character directories, and
    outline data is allocated by this function. Pointers to these are stored
    within the font structure. '_FSCFTLoad' returns FS_NO_ERROR if the font
    loads properly, or an error if it is not a compressed outline.

    The procedure '_FSCFTLoadInfo' loads the general font information
    section of a compressed outline into a structure of type 'TFInfo'.
    The block header for this section is loaded into a structure of type
    'TFBlockHeader'. Pointers to these structure are passed as arguments to
    the function. '_FSCFTLoadInfo' returns FS_NO_ERROR if the font loads
    properly, or an error if it is not a compressed outline.

    The structures 'TFStruct', 'TFBlockHeader', 'TFInfo',
    TFKernPair', 'TFKernTrack', and 'TFCharInfo' are
    defined in the file '../hfiles/FSTypeface.h'

 ****************************************************************************/


#include <stdio.h>
#include <ctype.h>
#include <memory.h>
#include <string.h>
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSTFCache.h"
#include "../hfiles/FSCrypt.h"
#include "../hfiles/FSLoadTF.h"


#define	SIZE_BH	sizeof(TFBlockHeader)	/* # bytes in block header record */



Int  _FSCFTLoad(
    FILE	*fontStr,	/* font stream pointer */
    TFStruct	*cmfont)	/* ptr to font data descriptor */

/*  _FSCFTLoad is responsible for initializing a font data structure.
 *  It assumes that the font file has been opened, and that 'fontStr' is
 *  its stream pointer. Also, 'cmfont' points to a structure of the type
 *  'TFStruct' which has been declared in the calling module.
 *  Note:  this is an entry point into this Module.
 *  Called by:  Another module
 *  Returns:	FS_NO_ERROR if font looks OK, else an error if it's not a
 *		compressed font or cannot load it.
 */
{
    int rval;

    if ((rval = _FSTFCheck(fontStr)) != FS_NO_ERROR)
	return (rval);

    if ((rval = _FSLoadInfo (fontStr, cmfont)) != FS_NO_ERROR)
	return (rval);
    if ((rval = _FSBlockHSLoad (fontStr, cmfont)) != FS_NO_ERROR)
	return (rval);
    if ((rval = _FSMemoryAlloc (cmfont)) != FS_NO_ERROR)
	return (rval);
    if (((rval = _FSLoadKernPrs (fontStr, cmfont)) != FS_NO_ERROR) ||
	((rval = _FSLoadKernTrks (fontStr, cmfont)) != FS_NO_ERROR) ||
	((rval = _FSLoadCharDirs (fontStr, cmfont)) != FS_NO_ERROR) ||
	((rval = _FSLoadOutlData (fontStr, cmfont)) != FS_NO_ERROR))
    {
	_FSCFTUnload (cmfont);
    }

    return (FS_NO_ERROR);
}




Int  _FSCFTUnload (TFStruct *cmfont)

/*  _FSCFTUnload deallocates memory that has been allocated for the
 *  compressed font read in by _FSCFTLoad().
 *  Called by:  Another module
 *  Returns:	FS_NO_ERROR
 */
{
    if (cmfont->memory != NULL)
	_FSFree (cmfont->memory);
    cmfont->memory = NULL;

    return (FS_NO_ERROR);
}




Int  _FSLoadBlockHeader(fontStr, blockHdr)
FILE		*fontStr;	/* font stream pointer	*/
TFBlockHeader	*blockHdr;	/* ptr to block header data descriptor */

/*  _FSLoadBlockHeader loads a block header into the data structure.
 *  'blockHdr' is a pointer to a structure of type 'TFBlockHeader'.
 *  The index into the file is assumed to be properly positioned.
 *  Called by:  _FSCFTLoadXXX, _FSLoadInfo, _FSBlockHSLoad
 */
{
    char	buff[SIZE_BH];	/* buffer for storing font header */
    uInt16	*buffS;
    int		rval;

    if ((rval = _FSReadChk (fontStr, buff, SIZE_BH)) != FS_NO_ERROR)
	return (rval);
    buffS = (uInt16 *)buff;
    blockHdr->blockId[0] = buff[0];
    blockHdr->blockId[1] = buff[1];
    blockHdr->nrDataWds = buffS[1];
    blockHdr->recSize = buffS[2];
    blockHdr->nrRecs = buffS[3];

    return (FS_NO_ERROR);
}




Int  _FSBlockHSLoad(
FILE		*fontStr,	/* font stream pointer	*/
TFStruct	*cmfont)	/* ptr to font data descriptor */

/*  _FSBlockHSLoad loads the block headers for the kerning pairs, kerning
 *  tracks, character directories, and outline data into the data structure,
 *  pointed to by 'cmfont'. The font information in 'cmfont->info' is
 *  assumed to be already present, otherwise there is no way of locating
 *  the other sections.
 *  Called by:  _FSCFTLoad
 */
{
    int	rval;

    if ((rval = _FSLoadKernPrHdr (fontStr, &cmfont->info,
				 &cmfont->kernPairHdr)) != FS_NO_ERROR)
	return (rval);

    if ((rval = _FSLoadKernTrkHdr (fontStr, &cmfont->info,
				  &cmfont->kernTrackHdr)) != FS_NO_ERROR)
	return (rval);

    if ((rval = _FSLoadCharDirHdr (fontStr, &cmfont->info,
				  &cmfont->charDirHdr)) != FS_NO_ERROR)
	return (rval);

    if ((rval = _FSLoadOutlDataHdr (fontStr, &cmfont->info,
				   &cmfont->outlinesHdr)) != FS_NO_ERROR)
	return (rval);

    return (FS_NO_ERROR);
}




Int  _FSLoadInfoHdr (fontStr, infoHdr)
FILE		*fontStr;	/* font stream pointer */
TFBlockHeader	*infoHdr;	/* ptr to block header data descriptor */
{
    int	rval;

    fseek(fontStr, 0L, 0);
    if ((rval = _FSLoadBlockHeader (fontStr, infoHdr)) != FS_NO_ERROR)
	return (rval);

    return (FS_NO_ERROR);
}




Int  _FSCFTLoadInfo(FILE *fontStr, TFBlockHeader *infoHdr, TFInfo *info)

/*  _FSCFTLoadInfo loads the font information block header and the font
 *  font information section. It assumes that the font file has been opened,
 *  and that 'fontStr' is its stream pointer. 'infoHdr' and 'info' point
 *  to structures which which have been declared in the calling module.
 *  Note:  this is an entry point into this Module.
 *  Called by:  Another module
 *  FILE		*fontStr;	font stream pointer
 *  TFBlockHeader	*infoHdr;	ptr to block header data descriptor
 *  TFInfo		*info;		ptr to font information data descriptor
 *  Returns:	FS_NO_ERROR if font looks OK, else an error if it's not a
 *		compressed font or cannot load it
 */
{
    int	rval;

    if ((rval = _FSTFCheck(fontStr)) != FS_NO_ERROR)
	return (rval);

    if ((rval = _FSLoadInfoHdr (fontStr, infoHdr)) != FS_NO_ERROR)
	return (rval);
    if ((rval = _FSLoadXInfo (fontStr, infoHdr, info)) != FS_NO_ERROR)
	return (rval);

    return (FS_NO_ERROR);	/* all is OK */
}





Int  _FSLoadInfo(
FILE		*fontStr,	/* font stream pointer	*/
TFStruct	*cmfont)	/* ptr to font data descriptor */

/*  _FSLoadInfo is responsible for reading the header record into the
 *  font data structure, pointed to by 'cmfont->info'.
 *  Called by:  _FSCFTLoad
 *  Returns:	FS_NO_ERROR if font looks OK, else an error if it's not a
 *		compressed font or cannot load it
 */
{
    int	rval;

    if ((rval = _FSLoadInfoHdr (fontStr, &cmfont->infoHdr)) != FS_NO_ERROR)
	return (rval);
    return (_FSLoadXInfo (fontStr, &cmfont->infoHdr, &cmfont->info));
}




Int  _FSLoadXInfo(
FILE		*fontStr,	/* font stream pointer	*/
TFBlockHeader	*infoHdr,	/* ptr to font info blk header structure */
TFInfo		*info)		/* ptr to font information structure */

/*  _FSLoadXInfo does the nitty-gritty of loading the font information
 *  section into the data structure 'info'
 *  Called by:  _FSLoadInfo,  _FSCFTLoadInfo
 *  Returns:	FS_NO_ERROR if font looks OK, else an error if it's not a
 *		compressed font or cannot load it
 */
{
    char	buff[sizeof(TFInfo)];	/* buffer for storing font header */
    char	*buffp;
    Int16	fmnr;		/* font format code */
    Int32	sizeInfo;	/* # bytes of font information */
    int		rval;


   /*  Format C2.3 has a font information section
    *    either 142 or 143 words long. The longer field includes a 16-bit
    *    customer number field at the end.
    *  Format C1.0 is the absolute format. Don't worry about it.
    *  INGR: Format C2.32 has a few added fields and is exactly 256 words
    *    (512 bytes) long.  */

    sizeInfo = infoHdr->nrDataWds * 2;
    fseek(fontStr, SIZE_BH, 0);
    if ((rval = _FSReadChk (fontStr, buff, sizeInfo)) != FS_NO_ERROR)
	return (rval);
    buffp = buff;

    memcpy(info->outlFmtNr, buffp, 8);
    buffp += 8;
    fmnr = 100 * (info->outlFmtNr[1] - '0') + 10 * (info->outlFmtNr[3] - '0');
    if (isdigit (info->outlFmtNr[4]))
	fmnr += (info->outlFmtNr[4] - '0');

    memcpy(info->srcFontId, buffp, 4);
    buffp += 4;
    memcpy (&info->srcFontVrsn, buffp, 2);
    buffp += 2;
    memcpy(info->srcFontName, buffp, 70);
    buffp += 70;
    memcpy(info->mfgDate, buffp, 10);
    buffp += 10;
    memcpy(info->layoutName, buffp, 70);
    buffp += 70;
    if (fmnr >= 232)
    {
	memcpy (&info->layoutNumber, buffp, 2);
	buffp += 2;
    }
    else
	info->layoutNumber = 0;
    memcpy(info->cpyrtNotice, buffp, 74);
    buffp += 74;
    memcpy (&info->timeStamp, buffp, 4);
    buffp += 4;
    memcpy (&info->reslPerEm, buffp, 2);
    buffp += 2;
    memcpy (&info->flag1, buffp, 2);
    buffp += 2;
    memcpy (&info->flag2, buffp, 2);
    buffp += 2;
    memcpy (&info->extentXMin, buffp, 4);
    buffp += 4;
    memcpy (&info->extentXMax, buffp, 4);
    buffp += 4;
    memcpy (&info->extentYMin, buffp, 4);
    buffp += 4;
    memcpy (&info->extentYMax, buffp, 4);
    buffp += 4;
    memcpy (&info->offsKernPrs, buffp, 4);
    buffp += 4;
    memcpy (&info->offsKernTrks, buffp, 4);
    buffp += 4;
    if (fmnr >= 232)
    {
	memcpy (&info->offsLigTable, buffp, 4);
	buffp += 4;
    }
    else
	info->offsLigTable = 0;
    memcpy (&info->offsCharDir, buffp, 4);
    buffp += 4;
    memcpy (&info->offsOutlData, buffp, 4);
    buffp += 4;
    if ((info->offsKernPrs > 1000000) || (info->offsKernTrks > 1000000) ||
	(info->offsCharDir > 1000000) || (info->offsOutlData > 1000000))
    {
	return (FS_INVALID_TF_FILE);
    }
    if (fmnr == 100)	/* format "C1.0" */
    {
	info->layoutSize = 0xFFFF;  /* see '_FSLoadCharDirs'    */
	info->wordSpaceWidth = 0;
	info->custNumber = 0;
    }
    else if (fmnr >= 230)	/* format "C2.3" or greater */
    {
	memcpy (&info->layoutSize, buffp, 2);
	buffp += 2;
	memcpy (&info->wordSpaceWidth, buffp, 2);
	buffp += 2;
	memcpy (&info->custNumber, buffp, 2);
	buffp += 2;
    }
    if (fmnr >= 232)
    {
	memcpy(info->custNotice, buffp, 100);
	buffp += 100;
    }
    else
	memset (info->custNotice, '\0', 100);
    memcpy (&info->revNumber, buffp, 2);
    buffp += 2;
    if (fmnr >= 232)
    {
	memcpy (&info->userId, buffp, 4);
	buffp += 4;
	memcpy (&info->userData, buffp, 4);
	buffp += 4;
	memcpy (info->reserved, buffp, 110);
	buffp += 110;
    }
    else
    {
	info->userId = info->userData = 0;
	memset (info->reserved, '\0', 110);
    }

    return(FS_NO_ERROR);
}




Int  _FSLoadKernPrHdr (
FILE		*fontStr,	/* font stream pointer */
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*kernPairHdr)	/* ptr to block header data descriptor */
{
    int	rval;

    if (info->offsKernPrs != 0)
    {
	fseek(fontStr, info->offsKernPrs * 2, 0);
	if ((rval = _FSLoadBlockHeader (fontStr, kernPairHdr)) != FS_NO_ERROR)
	    return (rval);
    }
    else
	kernPairHdr->nrRecs = kernPairHdr->nrDataWds = 0;

    return (FS_NO_ERROR);
}




Int  _FSCFTLoadKernPrs(
FILE		*fontStr,	/* font stream pointer	*/
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*kernPairHdr,	/* ptr to kern pair block header */
TFKernPair	**kernPair)	/* ptr to ptr to kern pair array */

/*  _FSCFTLoadKernPrs reads the kerning pairs & header from the font and
 *  puts them into an array of data structures.
 *  Called by:  Another module.
 */
{
    int	rval;

    if ((rval = _FSLoadKernPrHdr (fontStr, info, kernPairHdr)) != FS_NO_ERROR)
	return (rval);
    if ((*kernPair = (TFKernPair *) _FSMalloc
			(kernPairHdr->nrRecs * sizeof (TFKernPair))) == NULL)
	return (FS_CANT_ALLOC);

    return (_FSLoadXKernPrs (fontStr, info, kernPairHdr, *kernPair));
}




Int  _FSLoadKernPrs(
FILE		*fontStr,	/* font stream pointer	*/
TFStruct	*cmfont)	/* ptr to font data descriptor */

/*  _FSLoadKernPrs reads the kerning pairs from the font and puts them into
 *  an array of data structures. A pointer to these is in the font data
 *  structure (cmfont->kernPair).
 *  Called by:  _FSCFTLoad
 */
{
    return (_FSLoadXKernPrs (fontStr, &cmfont->info,
			     &cmfont->kernPairHdr, cmfont->kernPair));
}




Int  _FSLoadXKernPrs(
FILE		*fontStr,	/* font stream pointer	*/
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*pairHdr,	/* ptr to kern pair block header */
TFKernPair	*kernPair)	/* ptr to kern pair array */

/*  _FSLoadXKernPrs reads the kerning pairs from the font and puts them into
 *  an array of data structures.
 *  Called by:  _FSLoadKernPrs, _FSCFTLoadKernPrs
 */
{
    TFKernPair	*kernPairPtr, *kernPairEnd;
    char	*buff;		/* buffer for storing font header */
    uInt8	*buffp;
    uInt16	*buffpS;
    Int32	sizePair;	/* # bytes of kerning pairs */
    int		rval;

    sizePair = pairHdr->nrDataWds * 2;
    if (sizePair == 0)
	return (FS_NO_ERROR);
    if ((buff = _FSAlloc (sizePair)) == NULL)
	return (FS_CANT_ALLOC);

    fseek(fontStr, info->offsKernPrs * 2 + SIZE_BH, 0);
    if ((rval = _FSReadChk (fontStr, buff, sizePair)) != FS_NO_ERROR)
	return (rval);
    buffp = (uInt8 *) buff;

    kernPairEnd = &kernPair[pairHdr->nrRecs];
    for (kernPairPtr = kernPair; kernPairPtr < kernPairEnd; kernPairPtr++)
    {
	if (pairHdr->recSize == 2)
	{
	    kernPairPtr->char1 = *buffp++;
	    kernPairPtr->char2 = *buffp++;
	}
	else
	{
	    buffpS = (uInt16 *) buffp;
	    kernPairPtr->char1 = *buffpS++;
	    kernPairPtr->char2 = *buffpS++;
	    buffp = (uInt8 *) buffpS;
	}
	buffpS = (uInt16 *) buffp;
	kernPairPtr->adjustment = *buffpS++;
	buffp = (uInt8 *) buffpS;
    }
    _FSDealloc (buff);

    return (FS_NO_ERROR);
}




Int  _FSLoadKernTrkHdr (
FILE		*fontStr,	/* font stream pointer */
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*kernTrackHdr)	/* ptr to block header data descriptor */
{
    int	rval;

    if (info->offsKernTrks != 0)
    {
	fseek(fontStr, info->offsKernTrks * 2, 0);
	if ((rval = _FSLoadBlockHeader (fontStr, kernTrackHdr)) != FS_NO_ERROR)
	    return (rval);
    }
    else
	kernTrackHdr->nrRecs = kernTrackHdr->nrDataWds = 0;

    return (FS_NO_ERROR);
}




Int  _FSCFTLoadKernTrks(
FILE		*fontStr,	/* font stream pointer	*/
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*kernTrackHdr,	/* ptr to kern track block header */
TFKernTrack	**kernTrack)	/* ptr to ptr to kern track array */

/*  _FSCFTLoadKernTrks reads the kerning tracks & header from the font and
 *  puts them into an array of data structures.
 *  Called by:  Another module.
 */
{
    int	rval;

    if ((rval = _FSLoadKernTrkHdr (fontStr, info, kernTrackHdr)) != FS_NO_ERROR)
	return (rval);
    if ((*kernTrack = (TFKernTrack *) _FSMalloc
			(kernTrackHdr->nrRecs * sizeof (TFKernTrack))) == NULL)
	return (FS_CANT_ALLOC);
    return (_FSLoadXKernTrks (fontStr, info, kernTrackHdr, *kernTrack));
}




Int  _FSLoadKernTrks(
FILE		*fontStr,	/* font stream pointer	*/
TFStruct	*cmfont)	/* ptr to font data descriptor */

/*  _FSLoadKernTrks reads the kerning tracks from the font and puts them into
 *  an array of data structures. A pointer to these is in the font data
 *  structure (cmfont->kernTrack).
 *  Called by:  _FSCFTLoad
 */
{
    return (_FSLoadXKernTrks (fontStr, &cmfont->info,
			      &cmfont->kernTrackHdr, cmfont->kernTrack));
}




Int  _FSLoadXKernTrks(
FILE		*fontStr,	/* font stream pointer	*/
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*trackHdr,	/* ptr to kern track block header */
TFKernTrack	*kernTrack)	/* ptr to kern track array */

/*  _FSLoadXKernTrks reads the kerning tracks from the font and puts them into
 *  an array of data structures.
 *  Called by:	_FSLoadKernTrks, FSCFTLoadKernTrks
 */
{
    TFKernTrack	*kernTrackPtr, *kernTrackEnd;
    char	*buff;		/* buffer for storing font header */
    uInt16	*buffpS;
    Int16	*adjPtr;
    Int32	sizeTrack;	/* # bytes of kerning track data */
    int		rval;

    sizeTrack = trackHdr->nrDataWds * 2;
    if (sizeTrack == 0)
	return (FS_NO_ERROR);
    if ((buff = _FSAlloc (sizeTrack)) == NULL)
	return (FS_CANT_ALLOC);

    fseek(fontStr, info->offsKernTrks * 2 + SIZE_BH, 0);
    if ((rval = _FSReadChk (fontStr, buff, sizeTrack)) != FS_NO_ERROR)
	return (rval);
    buffpS = (uInt16 *)buff;

    kernTrackEnd = &kernTrack[trackHdr->nrRecs];
    for (kernTrackPtr = kernTrack; kernTrackPtr < kernTrackEnd;  kernTrackPtr++)
    {
	adjPtr = kernTrackPtr->trackAdj;

	kernTrackPtr->pointSize = *buffpS++;
	adjPtr[0] = *buffpS++;
	adjPtr[1] = adjPtr[2] =adjPtr[3] = 0;
	if (trackHdr->recSize >= 3)
	{
	    adjPtr[1] = *buffpS++;
	    if (trackHdr->recSize >= 4)
	    {
		adjPtr[2] = *buffpS++;
		if (trackHdr->recSize >= 5)
		    adjPtr[3] = *buffpS++;
	    }
	}
    }
    _FSDealloc (buff);

    return (FS_NO_ERROR);
}




Int  _FSLoadCharDirHdr (
FILE		*fontStr,	/* font stream pointer */
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*charDirHdr)	/* ptr to block header data descriptor */
{
    int	rval;

    if (info->offsCharDir != 0)
    {
	fseek(fontStr, info->offsCharDir * 2, 0);
	if ((rval = _FSLoadBlockHeader (fontStr, charDirHdr)) != FS_NO_ERROR)
	    return (rval);
    }
    else
	charDirHdr->nrRecs = charDirHdr->nrDataWds = 0;

    return (FS_NO_ERROR);
}




Int  _FSCFTLoadCharDirs(
FILE		*fontStr,	/* font stream pointer	*/
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*charDirHdr,	/* ptr to char dir block header */
TFCharInfo	**charDir)	/* ptr to ptr to char dir array */

/*  _FSCFTLoadCharDirs reads the char dirs & header from the font and
 *  puts them into an array of data structures.
 *  Called by:  Another module.
 */
{
    int	rval;

    if ((rval = _FSLoadCharDirHdr (fontStr, info, charDirHdr)) != FS_NO_ERROR)
	return (rval);
    if ((*charDir = (TFCharInfo *) _FSMalloc
			(charDirHdr->nrRecs * sizeof (TFCharInfo))) == NULL)
	return (FS_CANT_ALLOC);
    return (_FSLoadXCharDirs (fontStr, info, charDirHdr, *charDir));
}




Int  _FSLoadCharDirs(
FILE		*fontStr,	/* font stream pointer	*/
TFStruct	*cmfont)	/* ptr to font data descriptor */

/*  _FSLoadXCharDirs reads the character directories from the font and puts
 *  them into an array of data structures. A pointer to these is in the font
 *  data structure (cmfont->charDir).
 *  Called by:  _FSCFTLoad
 */
{
    return (_FSLoadXCharDirs (fontStr, &cmfont->info,
			      &cmfont->charDirHdr, cmfont->charDir));
}




Int  _FSLoadXCharDirs(
FILE		*fontStr,	/* font stream pointer	*/
TFInfo		*info,		/* ptr to info structure */
TFBlockHeader	*dirHdr,	/* ptr to char dir block header */
TFCharInfo	*charDir)	/* ptr to char dir array */

/*  _FSLoadCharDirs reads the character directories from the font and puts
 *  them into an array of data structures.
 *  Called by:  _FSLoadCharDirs, _FSCFTLoadCharDirs
 */
{
    TFCharInfo	*charDirPtr, *charDirEnd;
    char	*buff;		/* buffer for storing font header */
    uInt16	*buffpS;
    Int32	sizeDir;	/* # bytes in character directories */
    int		rval;

    if (info->layoutSize == 0xFFFF)   /* If not already defined */
	info->layoutSize = dirHdr->nrRecs;

    sizeDir = dirHdr->nrDataWds * 2;
    if ((buff = _FSAlloc (sizeDir)) == NULL)
	return (FS_CANT_ALLOC);

    fseek(fontStr, info->offsCharDir * 2 + SIZE_BH, 0);
    if ((rval = _FSReadChk (fontStr, buff, sizeDir)) != FS_NO_ERROR)
	return (rval);
    buffpS = (uInt16 *) buff;

    charDirEnd = &charDir[dirHdr->nrRecs];
    for (charDirPtr = charDir; charDirPtr < charDirEnd;  charDirPtr++)
    {
	charDirPtr->setWidth = *buffpS++;
	if (!(info->flag1 & FS_CHARID))   /* no char ID word */
	{
	    if (dirHdr->recSize == 2)
	    {
		charDirPtr->outlineOffs = (uInt32) *buffpS; buffpS++;
	    }
	    else	/* record size = 3 words */
	    {
		memcpy (&charDirPtr->outlineOffs, buffpS, 4);
		buffpS += 2;
	    }
	    charDirPtr->charId = 0;
	}
	else	/* char ID is last word in character directory record */
	{
	    if (dirHdr->recSize == 3)
	    {
		charDirPtr->outlineOffs = (uInt32) *buffpS; buffpS++;
		charDirPtr->charId = *buffpS; buffpS++;
	    }
	    else	/* record size = 4 words */
	    {
		memcpy (&charDirPtr->outlineOffs, buffpS, 4);
		buffpS += 2;
		charDirPtr->charId = *buffpS; buffpS++;
	    }
	}
    }
    _FSDealloc (buff);

    return (FS_NO_ERROR);
}




Int  _FSLoadOutlDataHdr (
FILE		*fontStr,	/* font stream pointer */
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*outlDataHdr)	/* ptr to block header data descriptor */
{
    int	rval;

    if (info->offsOutlData != 0)
    {
	fseek(fontStr, info->offsOutlData * 2, 0);
	if ((rval = _FSLoadBlockHeader (fontStr, outlDataHdr)) != FS_NO_ERROR)
	    return (rval);
    }
    else
	outlDataHdr->nrRecs = outlDataHdr->nrDataWds = 0;

    return (FS_NO_ERROR);
}




Int  _FSOutlDataSize (
TFBlockHeader	*outlDataHdr)	/* ptr to outlines block header */
{
    if (strncmp ((char *)outlDataHdr->blockId, "O2", 2) == 0)   /* > 64K wds? */
	return ((outlDataHdr->recSize << 16) + outlDataHdr->nrDataWds);
    else
	return (outlDataHdr->nrDataWds);	/* the usual */
}



Int  _FSCFTLoadOutlData(
FILE		*fontStr,	/* font stream pointer	*/
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*outlDataHdr,	/* ptr to outlines block header */
TFOutlines	**outlData)	/* ptr to ptr to outlines */

/*  _FSCFTLoadOutlData reads the outlines & header from the font.
 *  Called by:  Another module.
 */
{
    int	rval;

    if ((rval = _FSLoadOutlDataHdr (fontStr, info, outlDataHdr)) != FS_NO_ERROR)
	return (rval);
    if ((*outlData = (TFOutlines *) _FSMalloc
		(_FSOutlDataSize (outlDataHdr) * sizeof (TFOutlines))) == NULL)
	return (FS_CANT_ALLOC);
    return (_FSLoadXOutlData (fontStr, info, outlDataHdr, *outlData));
}




Int  _FSLoadOutlData(
FILE		*fontStr,	/* font stream pointer	*/
TFStruct	*cmfont)	/* ptr to font data descriptor */

/*  _FSLoadOutlData reads the outline data block from the font and puts the
 *  data in an array. A pointer to the data is in the font data structure
 *  (cmfont->outlines).
 *  Called by:  _FSCFTLoad
 */
{
    return (_FSLoadXOutlData (fontStr, &cmfont->info,
			      &cmfont->outlinesHdr, cmfont->outlines));
}




Int  _FSLoadXOutlData(
FILE		*fontStr,	/* font stream pointer	*/
TFInfo		*info,		/* ptr to info */
TFBlockHeader	*outlinesHdr,	/* ptr to outlines block header */
TFOutlines	*outlines)	/* ptr to outlines */

/*  _FSLoadXOutlData reads the outline data block from the font and puts the
 *  data in an array.
 *  Called by:  _FSLoadOutlData, _FSCFTLoadOutlData
 */
{
    Int32	outlinesSize;	/* number of words of outline data to xfer */
    int		rval;

    outlinesSize = _FSOutlDataSize (outlinesHdr);

    fseek(fontStr, info->offsOutlData * 2 + SIZE_BH, 0);
    if ((rval = _FSReadChk (fontStr, (char *)outlines, outlinesSize * 2)) !=
	FS_NO_ERROR)
	return (rval);

    _FSDecryptBuff ((Int16 *) outlines, outlinesSize);	/* Decrypt the data */

    return (FS_NO_ERROR);
}





Int _FSReadChk (
FILE	*str,		/* stream pointer */
char	*buffer,	/* buffer for read() */
Int32	count)		/* # bytes read */

/*  _FSReadChk verifies that the number of bytes read from a file is the same
 *  as the number requested.
 *  Returns FS_INVALID_TF_FILE if the number of bytes read != the number
 *    of bytes requested
 *  Called by:	_FSLoadBlockHeader, _FSLoadXInfo, _FSLoadXKernPrs,
 *		_FSLoadXKernTrks, _FSLoadXCharDirs, _FSLoadXOutlData,
 *		_FSTFCheck
 */
{
    if (fread (buffer, 1, count, str) != count)
	return (FS_INVALID_TF_FILE);

    return (FS_NO_ERROR);
}



Int  _FSTFCheck (FILE *fontStr)
{
    char	buff[8];
    int		rval;

    fseek (fontStr, SIZE_BH, 0);
    if ((rval = _FSReadChk (fontStr, buff, 8)) != FS_NO_ERROR)
	return (rval);

    if ((strncmp (buff, "C2.", 3) != 0) && (strncmp (buff, "C1.0", 4) != 0))
	return (FS_INVALID_TF_FILE);

    return (FS_NO_ERROR);
}






Int  _FSMemoryAlloc(
TFStruct	*cmfont)	/* ptr to font data descriptor */

/*  _FSMemoryAlloc take a pointer to a compressed font structure 'cmfont'
 *    Memory is allocated for kerning pairs, kerning tracks, character
 *    directories, and outline data with '_FSMalloc'. The font information
 *    section and all the block headers must already be resident in the
 *    font data structure for this to work.
 *  Called by:  _FSCFTLoad
 */
{
    Int32	memSize, outlinesSize;

    outlinesSize = _FSOutlDataSize (&cmfont->outlinesHdr);

    memSize =	LONGWORD (cmfont->kernPairHdr.nrRecs * sizeof (TFKernPair)) +
		LONGWORD (cmfont->kernTrackHdr.nrRecs * sizeof (TFKernTrack)) +
		LONGWORD (cmfont->charDirHdr.nrRecs * sizeof (TFCharInfo)) +
		LONGWORD (outlinesSize * sizeof (Int16));

    if ((cmfont->memory = (char *) _FSMalloc (memSize)) == NULL)
	return (FS_CANT_ALLOC);

    cmfont->kernPair = (TFKernPair *) (cmfont->memory);
    cmfont->kernTrack = (TFKernTrack *) ((char *)cmfont->kernPair +
		LONGWORD (cmfont->kernPairHdr.nrRecs * sizeof(TFKernPair)));
    cmfont->charDir = (TFCharInfo *) ((char *)cmfont->kernTrack +
		LONGWORD (cmfont->kernTrackHdr.nrRecs * sizeof(TFKernTrack)));
    cmfont->outlines = (uInt16 *) ((char *)cmfont->charDir +
		LONGWORD (cmfont->charDirHdr.nrRecs * sizeof(TFCharInfo)));
	
    return (FS_NO_ERROR);
}
