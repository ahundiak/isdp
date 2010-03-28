/* $RCSfile: fssym.c $$Revision: 1.1 $$Date: 1990/07/02 16:07:07 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include <stdio.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSBmapCach.h"
#include "../hfiles/FSGenCache.h"
#include "../hfiles/FSNewFont.h"
#include "../hfiles/FSConvert.h"

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSWriteSymbolFile (font, fileName)			*/
/*									*/
/*	  BmapId	font;		- bitmap font to write		*/
/*	  char		*fileName;	- font file name		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine writes out an Intergraph symbol file.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the specified font is not a bitmap font		*/
/*		- the specified file cannot be opened			*/
/*		- the font doesn't exist				*/
/*		- the font falls outside the Environ V symbol file	*/
/*		  restrictions.						*/
/*									*/
/************************************************************************/

int FSWriteSymbolFile (font, fileName)
BmapId	*font;
char	*fileName;
{
    int			i, minChar, numChar, totalSize, totalBmapSize;
    int			bmapSize, totalBmapOffset, rval, shared;
    uInt16		bmapOffset;
    uInt8		index[256], data;
    uInt8		width, height, rWid, rHgt, hOff, vOff;
    CharId		character;
    char		ptr2[65536];
    FILE		*file;
    BmapHeader	 	*header;
    BmapInfo	 	*info;
    BmapCharNode	**thisChar;
    BmapCharInfo 	*charInfo;
    BmapBitmap		*ptr, *wPtr;
    BmapCharDir		*charDir;

    rval = FS_NO_ERROR;

    shared = _FSSharedFont ((FontNode **)font); // XXX - Possible bad pointer being passed?
    _GCLockSem (shared);

    /** Make sure it is a bitmap font **/
    // XXX - Possible bad pointers?  I had to cast "font" in several places here.
    if (_FSBmapFont ((BmapNode **)font))
    {
	_FSBmapLockHeader ((FontNode **)font);
	_FSBmapLockInfo ((FontNode **)font);
	_FSBmapLockCharDir ((FontNode **)font);
	header = _FSBmapHeader (font);
	info = _FSBmapInfo (font);
	charDir = _FSBmapCharDir (font);

	/** Lock all the chars, since they will be accessed several times **/
	for (thisChar = _FSBmapFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSBmapNextChar (font, &character))
	{
	    _FSBmapGetChar ((FontNode **)font, thisChar, character);
	    _FSBmapLockCharInfo (thisChar);
	}

	/** Make sure the font conforms to symbol table standards **/

	/** The largest font height is 255 **/
	if ((uInt) ROUND (info->bodySize) >= 256)
	{
INVALID:
	    rval = FS_INVALID_SYMBOL_FILE;
	    goto DONE;
	}

	/** The font can only have 255 characters with indices up to 255 **/
	minChar = charDir->minChar;
	numChar = charDir->numChar;
	if ((numChar > 255) || ((numChar + minChar) > 256))
	    goto INVALID;

	/** The largest bitmap offset can only be 64K (since they are 16 bits) **/
	/** The largest bitmap dimensions can be 255 x 255 **/
	/** The vertical or horizontal offset range is -128 to 127 **/
	/** The largest width can be 255 **/
	totalBmapSize = bmapSize = 0;
	for (thisChar = _FSBmapFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSBmapNextChar (font, &character))
	{
	    charInfo = _FSBmapCharInfo (thisChar);
	    if ((charInfo->rWid >= 256) || (charInfo->rHgt >= 256) ||
		(charInfo->hOff < -128) || (charInfo->hOff >= 128) ||
		(charInfo->vOff < -128) || (charInfo->vOff >= 128) ||
		((uInt) ROUND (charInfo->setWid) >= 256))
		goto INVALID;

	    bmapSize = LONGWORD (((charInfo->rWid + 7) >> 3) * charInfo->rHgt);
	    totalBmapSize += bmapSize;
	}

	/** Check bitmap offset of last character **/
	if (totalBmapSize - bmapSize > 65535)
	    goto INVALID;

	/** Try to open the file **/
	if ((file = fopen (fileName, "w")) == NULL)
	{
	    rval = FS_FILE_NOT_WRITTEN;
	    goto DONE;
	}

	/** First comes the magic number **/
	fwrite ("FONT", 4, 1, file);

	/** Then the size of the symbol table **/
	numChar = header->nbrDirRec;
	totalSize =	sizeof (int) +			/* Bitmap offset */
		    (256 * sizeof (Char8)) +		/* Header indices */
		    (8 * numChar) +			/* Symbol headers */
		    totalBmapSize;			/* Bitmaps */
	totalSize = LONGWORD (totalSize);	/* Pad to multiple of four */
	fwrite (&totalSize, sizeof (int), 1, file);

	/** The bitmap offset **/
	totalBmapOffset = 260 + (8 * numChar);
	fwrite (&totalBmapOffset, sizeof (int), 1, file);

	/** The header indices **/
	for (i = 0; i < 256; i++)
	    index[i] = 0;

	data = 1;
	for (thisChar = _FSBmapFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSBmapNextChar (font, &character))
	{
	    charInfo = _FSBmapCharInfo (thisChar);
	    index[charInfo->charId] = data++;
	}

	fwrite (index, sizeof (uInt8), 256, file);

	/** The symbol headers **/
	bmapOffset = 0;
	height = (uInt8) (info->bodySize + 0.5);
	for (thisChar = _FSBmapFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSBmapNextChar (font, &character))
	{
	    charInfo = _FSBmapCharInfo (thisChar);
	    fwrite (&bmapOffset, sizeof (uInt16), 1, file);
	    rWid = (uInt8) charInfo->rWid;
	    fwrite (&rWid, sizeof (uInt8), 1, file);
	    rHgt = (uInt8) charInfo->rHgt;
	    fwrite (&rHgt, sizeof (uInt8), 1, file);
	    hOff = (uInt8) charInfo->hOff;
	    fwrite (&hOff, sizeof (Int8), 1, file);
	    vOff = (Int8) (info->bodySize - info->descent + 0.5) -
		   charInfo->vOff - charInfo->rHgt;
	    fwrite (&vOff, sizeof (Int8), 1, file);
	    width = (uInt8) (charInfo->setWid + 0.5);
	    fwrite (&width, sizeof (uInt8), 1, file);
	    fwrite (&height, sizeof (uInt8), 1, file);

	    bmapOffset += LONGWORD (((charInfo->rWid + 7) >> 3) * charInfo->rHgt);
	}

	/** Write the bitmaps, converting them, if necessary **/
	for (thisChar = _FSBmapFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSBmapNextChar (font, &character))
	{
	    charInfo = _FSBmapCharInfo (thisChar);
	    bmapSize = LONGWORD (((charInfo->rWid + 7) >> 3) * charInfo->rHgt);
	    _FSBmapLockCharBitmap (thisChar);
	    wPtr = ptr = _FSBmapCharBitmap (thisChar);
	    switch (charInfo->flags & FS_USED_FLAG_BITS)
	    {
		case FS_REAL_BITMAP:
		    break;

		case FS_RUNLENGTH_8:
		    wPtr = (BmapBitmap *) ptr2;
		     _FSConvertRLE8 (ptr, (uInt8 *)ptr2, charInfo->rWid, charInfo->rHgt);
		    break;

		case FS_RUNLENGTH_16:
		    wPtr = (BmapBitmap *) ptr2;
		    _FSConvertRLE16 ((Int16 *)ptr, (BmapBitmap *)ptr2, charInfo->rWid, charInfo->rHgt);
		    break;

		default:
		    break;
	    }
	    fwrite (wPtr, sizeof (BmapBitmap), bmapSize, file);
	    _FSBmapUnlockCharBitmap (thisChar);
	}

	fclose (file);

DONE:
	/** Unlock all the characters **/
	for (thisChar = _FSBmapFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSBmapNextChar (font, &character))
	    _FSBmapUnlockCharInfo (thisChar);

	_FSBmapUnlockHeader ((FontNode **)font);
	_FSBmapUnlockInfo ((FontNode **)font);
	_FSBmapUnlockCharDir ((FontNode **)font);
    }
    else
	rval = FS_INVALID_FONT;

    _GCUnlockSem (shared);

    return (rval);
}
