
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


#include <stdio.h>
#include <malloc.h>
#include <ctype.h>
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSLoadTF.h"


#define	SIZE_BH	sizeof(TFBlockHeader)	/* # bytes in block header record */


Int  _FSCFTWrite(fontStr, cmfont)
FILE		*fontStr;	/* font stream pointer */
TFStruct	*cmfont;	/* ptr to font data descriptor */

/*  _FSCFTWrite is responsible for writing a font data structure to a file.
 *  It assumes that the file has been opened, and that 'fontStr' is
 *  its stream pointer. Also, 'cmfont' points to a structure of the type
 *  'TFStruct' which has been declared in the calling module.
 *  Note:  this is an entry point into this Module.
 *  Called by:  Another module
 *  Returns:	FS_NO_ERROR if font is written, else an error if it cannot
 *		cannot be written.
 */
{
    int stat;

    if ((stat = _FSWriteInfo (fontStr, cmfont)) != FS_NO_ERROR)
	return (stat);
    if ((stat = _FSWriteKernPrs (fontStr, cmfont)) != FS_NO_ERROR)
	goto ERR;
    if ((stat = _FSWriteKernTrks (fontStr, cmfont)) != FS_NO_ERROR)
	goto ERR;
    if ((stat = _FSWriteCharDirs (fontStr, cmfont)) != FS_NO_ERROR)
	goto ERR;
    if ((stat = _FSWriteOutlData (fontStr, cmfont)) != FS_NO_ERROR)
ERR:	return (stat);

    return (FS_NO_ERROR);	/* all is OK */
}




Int  _FSWriteBlockHeader(fontStr, blockHdr)
FILE		*fontStr;	/* font stream pointer	*/
TFBlockHeader	*blockHdr;	/* ptr to block header data descriptor */

/*  _FSWriteBlockHeader loads a block header into the data structure.
 *  'blockHdr' is a pointer to a structure of type 'TFBlockHeader'.
 *  The index into the file is assumed to be properly positioned.
 *  Called by:  _FSCFTWriteXXX, _FSWriteInfo, _FSBlockHSWrite
 */
{
    char	buff[SIZE_BH];	/* buffer for storing font header */
    uInt16	*buffS;
    int		stat;

    buffS = (uInt16 *)buff;
    buff[0] = blockHdr->blockId[0];
    buff[1] = blockHdr->blockId[1];
    buffS[1] = blockHdr->nrDataWds;
    buffS[2] = blockHdr->recSize;
    buffS[3] = blockHdr->nrRecs;

    if ((stat = _FSWriteChk (fontStr, buff, SIZE_BH)) != FS_NO_ERROR)
	return (stat);

    return (FS_NO_ERROR);
}




static  Int  _FSWriteInfo(fontStr, cmfont)
FILE		*fontStr;	/* font stream pointer	*/
TFStruct	*cmfont;	/* ptr to font data descriptor */

/*  _FSWriteInfo is responsible for reading the header record into the
 *  font data structure, pointed to by 'cmfont->info'.
 *  Called by:  _FSCFTWrite
 *  Returns:	FS_NO_ERROR if font looks OK, else an error if it's not a
 *		compressed font or cannot load it
 */
{
    int	stat;

    if ((stat = _FSWriteBlockHeader (fontStr, &cmfont->infoHdr)) != FS_NO_ERROR)
	return (stat);
    return (_FSWriteXInfo (fontStr, &cmfont->infoHdr, &cmfont->info));
}




static  Int  _FSWriteXInfo(fontStr, infoHdr, info)
FILE		*fontStr;	/* font stream pointer	*/
TFBlockHeader	*infoHdr;	/* ptr to font info blk header structure */
TFInfo		*info;		/* ptr to font information structure */

/*  _FSWriteXInfo does the nitty-gritty of loading the font information
 *  section into the data structure 'info'
 *  Called by:  _FSWriteInfo,  _FSCFTWriteInfo
 *  Returns:	FS_NO_ERROR if font looks OK, else an error if it's not a
 *		compressed font or cannot load it
 */
{
    char	buff[sizeof(TFInfo)];	/* buffer for storing font header */
    char	*buffp;
    Int16	fmnr;		/* font format code */
    Int32	sizeInfo;	/* # bytes of font information */
    int		stat;


   /*  Format C2.3 has a font information section
    *    either 142 or 143 words long. The longer field includes a 16-bit
    *    customer number field at the end.
    *  Format C1.0 is the absolute format. Don't worry about it.
    *  INGR: Format C2.32 has a few added fields and is exactly 256 words
    *    (512 bytes) long.  */

    sizeInfo = infoHdr->nrDataWds * 2;
    buffp = buff;

    memcpy (buffp, info->outlFmtNr, 8);
    buffp += 8;
    memcpy (buffp, info->srcFontId, 4);
    buffp += 4;
    memcpy (buffp, &info->srcFontVrsn, 2);
    buffp += 2;
    memcpy (buffp, info->srcFontName, 70);
    buffp += 70;
    memcpy (buffp, info->mfgDate, 10);
    buffp += 10;
    memcpy (buffp, info->layoutName, 70);
    buffp += 70;
    memcpy (buffp, &info->layoutNumber, 2);
    buffp += 2;
    memcpy (buffp, info->cpyrtNotice, 74);
    buffp += 74;
    memcpy (buffp, &info->timeStamp, 4);
    buffp += 4;
    memcpy (buffp, &info->reslPerEm, 2);
    buffp += 2;
    memcpy (buffp, &info->flag1, 2);
    buffp += 2;
    memcpy (buffp, &info->flag2, 2);
    buffp += 2;
    memcpy (buffp, &info->extentXMin, 4);
    buffp += 4;
    memcpy (buffp, &info->extentXMax, 4);
    buffp += 4;
    memcpy (buffp, &info->extentYMin, 4);
    buffp += 4;
    memcpy (buffp, &info->extentYMax, 4);
    buffp += 4;
    memcpy (buffp, &info->offsKernPrs, 4);
    buffp += 4;
    memcpy (buffp, &info->offsKernTrks, 4);
    buffp += 4;
    memcpy (buffp, &info->offsLigTable, 4);
    buffp += 4;
    memcpy (buffp, &info->offsCharDir, 4);
    buffp += 4;
    memcpy (buffp, &info->offsOutlData, 4);
    buffp += 4;
    memcpy (buffp, &info->layoutSize, 2);
    buffp += 2;
    memcpy (buffp, &info->wordSpaceWidth, 2);
    buffp += 2;
    memcpy (buffp, &info->custNumber, 2);
    buffp += 2;
    memcpy (buffp, info->custNotice, 100);
    buffp += 100;
    memcpy (buffp, &info->revNumber, 2);
    buffp += 2;
    memcpy (buffp, &info->userId, 4);
    buffp += 4;
    memcpy (buffp, &info->userData, 4);
    buffp += 4;
    memcpy (buffp, info->reserved, 110);
    buffp += 110;

    if ((stat = _FSWriteChk (fontStr, buff, buffp - buff)) != FS_NO_ERROR)
	return (stat);

    return(FS_NO_ERROR);
}




static  Int  _FSWriteKernPrs(fontStr, cmfont)
FILE		*fontStr;	/* font stream pointer	*/
TFStruct	*cmfont;	/* ptr to font data descriptor */

/*  _FSWriteKernPrs reads the kerning pairs from the font and puts them into
 *  an array of data structures. A pointer to these is in the font data
 *  structure (cmfont->kernPair).
 *  Called by:  _FSCFTWrite
 */
{
    int	stat;

    if ((stat = _FSWriteBlockHeader (fontStr, &cmfont->kernPairHdr)) != FS_NO_ERROR)
	return (stat);
    return (_FSWriteXKernPrs (fontStr, &cmfont->info,
			    &cmfont->kernPairHdr, cmfont->kernPair));
}




static  Int  _FSWriteXKernPrs(fontStr, info, pairHdr, kernPair)
FILE		*fontStr;	/* font stream pointer	*/
TFInfo		*info;		/* ptr to info */
TFBlockHeader	*pairHdr;	/* ptr to kern pair block header */
TFKernPair	*kernPair;	/* ptr to kern pair array */

/*  _FSWriteXKernPrs writes the kerning pairs to a file.
 *  Called by:  _FSWriteKernPrs
 */
{
    char	*buff;
    uInt8	*buffp;
    uInt16	*buffpS;
    Int16	ii;
    int		stat;

    if ((buff = (char *) _FSMalloc (pairHdr->nrDataWds * 2)) == NULL)
	return (FS_CANT_ALLOC);

    buffp = (uInt8 *) buff;
    for (ii = 0; ii < pairHdr->nrRecs; ii++)
    {
        if (pairHdr->recSize == 2)
        {
            *buffp++ = (uInt8) kernPair[ii].char1;
            *buffp++ = (uInt8) kernPair[ii].char2;
            buffpS = (uInt16 *) buffp;
        }
        else
        {
            buffpS = (uInt16 *) buffp;
            *buffpS++ = kernPair[ii].char1;
            *buffpS++ = kernPair[ii].char2;
        }
        *buffpS++ = kernPair[ii].adjustment;
        buffp = (uInt8 *) buffpS;
    }

    if ((stat = _FSWriteChk (fontStr, buff,
			    pairHdr->nrDataWds * 2)) != FS_NO_ERROR)
        return (stat);

    _FSFree (buff);

    return (FS_NO_ERROR);
}




static  Int  _FSWriteKernTrks(fontStr, cmfont)
FILE		*fontStr;	/* font stream pointer	*/
TFStruct	*cmfont;	/* ptr to font data descriptor */

/*  _FSWriteKernTrks reads the kerning tracks from the font and puts them into
 *  an array of data structures. A pointer to these is in the font data
 *  structure (cmfont->kernTrack).
 *  Called by:  _FSCFTWrite
 */
{
    int	stat;

    if ((stat = _FSWriteBlockHeader (fontStr, &cmfont->kernTrackHdr)) != FS_NO_ERROR)
	return (stat);
    return (_FSWriteXKernTrks (fontStr, &cmfont->info,
			      &cmfont->kernTrackHdr, cmfont->kernTrack));
}




static  Int  _FSWriteXKernTrks(fontStr, info, trackHdr, kernTrack)
FILE		*fontStr;	/* font stream pointer	*/
TFInfo		*info;		/* ptr to info */
TFBlockHeader	*trackHdr;	/* ptr to kern track block header */
TFKernTrack	*kernTrack;	/* ptr to kern track array */

/*  _FSWriteXKernTrks writes the kerning tracks to a file.
 *  Called by:	_FSWriteKernTrks
 */
{
    char	*buff;		/* buffer for storing font header */
    uInt16	*buffpS;
    Int16	ii;
    int		stat;

    if ((buff = (char *) _FSMalloc (trackHdr->nrDataWds * 2)) == NULL)
	return (FS_CANT_ALLOC);

    buffpS = (uInt16 *) buff;
    for (ii = 0; ii < trackHdr->nrRecs; ii++)
    {
        *buffpS++ = kernTrack[ii].pointSize;
        *buffpS++ = kernTrack[ii].trackAdj[0];
        if (trackHdr->recSize >= 3)
        {
            *buffpS++ = kernTrack[ii].trackAdj[1];
            if (trackHdr->recSize == 4)
                *buffpS++ = kernTrack[ii].trackAdj[2];
        }
    }

    if ((stat = _FSWriteChk (fontStr, buff,
			    trackHdr->nrDataWds * 2)) != FS_NO_ERROR)
	return (stat);

    _FSFree(buff);

    return (FS_NO_ERROR);
}




static  Int  _FSWriteCharDirs(fontStr, cmfont)
FILE		*fontStr;	/* font stream pointer	*/
TFStruct	*cmfont;	/* ptr to font data descriptor */

/*  _FSWriteXCharDirs reads the character directories from the font and puts
 *  them into an array of data structures. A pointer to these is in the font
 *  data structure (cmfont->charDir).
 *  Called by:  _FSCFTWrite
 */
{
    int	stat;

    if ((stat = _FSWriteBlockHeader (fontStr, &cmfont->charDirHdr)) != FS_NO_ERROR)
	return (stat);
    return (_FSWriteXCharDirs (fontStr, &cmfont->info,
			      &cmfont->charDirHdr, cmfont->charDir));
}




static  Int  _FSWriteXCharDirs(fontStr, info, dirHdr, charDir)
FILE		*fontStr;	/* font stream pointer	*/
TFInfo		*info;		/* ptr to info structure */
TFBlockHeader	*dirHdr;	/* ptr to char dir block header */
TFCharInfo	*charDir;	/* ptr to char dir array */

/*  _FSWriteCharDirs writes the character directories to a file.
 *  Called by:  _FSWriteCharDirs
 */
{
    char	*buff;		/* buffer for storing font header */
    uInt16	*buffpS;
    Int16	ii;
    int		stat;

    if ((buff = (char *) _FSMalloc (dirHdr->nrDataWds * 2)) == NULL)
	return (FS_CANT_ALLOC);

    buffpS = (uInt16 *) buff;
    for (ii = 0; ii < dirHdr->nrRecs;  ii++)
    {
	*buffpS++ = charDir[ii].setWidth;
	if ((info->flag1 & FS_CHARID) == 0)	/* no char ID word */
	{
	    if (dirHdr->recSize == 2)
		*buffpS++ = (Int16) charDir[ii].outlineOffs;
	    else	/* record size = 3 words */
	    {
		memcpy (buffpS, charDir[ii].outlineOffs, 4);
		buffpS += 2;
	    }
	}
	else	/* char ID is last word in character directory record */
	{
	    if (dirHdr->recSize == 3)
	    {
		*buffpS++ = (Int16) charDir[ii].outlineOffs;
		*buffpS++ = charDir[ii].charId;
	    }
	    else	/* record size = 4 words */
	    {
		memcpy (buffpS, &charDir[ii].outlineOffs, 4);
		buffpS += 2;
		*buffpS++ = charDir[ii].charId;
	    }
	}
    }

    if ((stat = _FSWriteChk (fontStr, buff,
			    dirHdr->nrDataWds * 2)) != FS_NO_ERROR)
	return (stat);

    _FSFree (buff);

    return (FS_NO_ERROR);
}




static  Int  _FSWriteOutlData(fontStr, cmfont)
FILE		*fontStr;	/* font stream pointer	*/
TFStruct	*cmfont;	/* ptr to font data descriptor */

/*  _FSWriteOutlData reads the outline data block from the font and puts the
 *  data in an array. A pointer to the data is in the font data structure
 *  (cmfont->outlines).
 *  Called by:  _FSCFTWrite
 */
{
    int	stat;

    if ((stat = _FSWriteBlockHeader (fontStr, &cmfont->outlinesHdr)) != FS_NO_ERROR)
	return (stat);
    return (_FSWriteXOutlData (fontStr, &cmfont->info,
			      &cmfont->outlinesHdr, cmfont->outlines));
}




static  Int  _FSWriteXOutlData(fontStr, info, outlinesHdr, outlines)
FILE		*fontStr;	/* font stream pointer	*/
TFInfo		*info;		/* ptr to info */
TFBlockHeader	*outlinesHdr;	/* ptr to outlines block header */
TFOutlines	*outlines;	/* ptr to outlines */

/*  _FSWriteXOutlData reads the outline data block from the font and puts the
 *  data in an array.
 *  Called by:  _FSWriteOutlData, _FSCFTWriteOutlData
 */
{
    char	*buff;
    Int32	size;	/* number of words of outline data to xfer */
    int		stat;

    if (strncmp (outlinesHdr->blockId, "O2", 2) == 0)   /* > 64K wds? */
	size = (outlinesHdr->recSize << 16) + outlinesHdr->nrDataWds;
    else
	size = outlinesHdr->nrDataWds;	/* the usual */

    if ((buff = (char *) _FSMalloc (size * 2)) == NULL)
	return (FS_CANT_ALLOC);

    memcpy (buff, outlines, size * 2);
    _FSEncryptBuff (outlines, size);	/* Encrypt the data */

    if ((stat = _FSWriteChk (fontStr, outlines, size * 2)) != FS_NO_ERROR)
	return (stat);

    _FSFree (buff);

    return (FS_NO_ERROR);
}





static  Int  _FSWriteChk(str, buffer, count)
FILE	*str;		/* stream pointer */
char	*buffer;	/* buffer for read() */
Int32	count;		/* # bytes read */

/*  _FSWriteChk verifies that the number of bytes written to a file is the same
 *  as the number requested.
 *  Returns FS_FILE_NOT_WRITTEN if the number of bytes written != the number
 *    of bytes requested
 *  Called by:	_FSWriteBlockHeader, _FSWriteXInfo, _FSWriteXKernPrs,
 *		_FSWriteXKernTrks, _FSWriteXCharDirs, _FSWriteXOutlData
 */
{
    if (fwrite (buffer, 1, count, str) != count)
	return (FS_FILE_NOT_WRITTEN);

    return (FS_NO_ERROR);
}
