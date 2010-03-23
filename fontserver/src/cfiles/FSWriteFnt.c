/* $RCSfile: fswrtfnt.c $$Revision: 1.1 $$Date: 1990/07/02 16:07:10 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include <stdio.h>
#include <memory.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSOutl.h"
#include "../hfiles/FSFont.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSBmapCach.h"
#include "../hfiles/FSOutlCach.h"
#include "../hfiles/FSIO.h"


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSWriteFontFile (font, fileName)				*/
/*									*/
/*	  FontNode	**font;		- font to write			*/
/*	  char		*fileName;	- font file name		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine writes a Font Server font file.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the specified file cannot be opened			*/
/*		- the font doesn't exist				*/
/*									*/
/************************************************************************/

int FSWriteFontFile (font, fileName)
FontNode	**font;
char		*fileName;
{
    int		i, rval, shared;
    FILE	*file;
    CharId	character;
    FontHeader	*fontHdr;
    FontInfo	*info;

    /** Do a little validity checking **/
    if (!_FSBmapFont (font) && !_FSOutlFont (font))
	return (FS_INVALID_FONT);

    if ((file = fopen (fileName, "w")) == NULL)
	return (FS_FILE_NOT_WRITTEN);

    rval = FS_NO_ERROR;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockHeader (font);
    _FSFontLockInfo (font);
    fontHdr = _FSFontHeader (font);
    info = _FSFontInfo (font);

    if (_FSBmapFont (font))	/* bitmap font? */
    {
	BmapHeader	header;
	BmapCharNode	**thisChar;
	BmapCharInfo 	*charInfo;
	BmapBitmap	*bmap;
	BmapKernPair	*kernInfo;

	/** Update the bitmap offsets of all the characters **/
	_FSBmapHierarchicalUpdate (font);

	/** Write the header.  The offsets will be wrong,
	    but we write the header again after we're through. **/
	memcpy (&header, fontHdr, sizeof (BmapHeader));
	_FSWriteBmapHeader (file, &header);

	/** Write the BmapInfo section **/
	header.startGenSec = ftell (file);
	_FSWriteBmapInfo (file, info);
	header.bytesGenSec = ftell (file) - header.startGenSec;

	/** Write the KernPairs **/
	header.startKernSec = ftell (file);
	_FSBmapLockKernPairs (font);
	for (kernInfo = _FSBmapKernPairs (font), i = 0; i < header.nbrKernRec;
	     i++, kernInfo++)
	    _FSWriteBmapKernPair (file, kernInfo);
	_FSBmapUnlockKernPairs (font);
	if (header.nbrKernRec > 0)
	    header.bytesKernRec = (ftell (file) - header.startKernSec) /
				  header.nbrKernRec;

	/** Lock all characters, since they will be accessed several times **/
	for (thisChar = _FSBmapFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSBmapNextChar (font, &character))
	{
	    _FSBmapGetChar (font, thisChar, character);
	    _FSBmapLockCharInfo (thisChar);
	}

	/** Write the character directory **/
	header.startDirSec = ftell (file);
	for (thisChar = _FSBmapFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSBmapNextChar (font, &character))
	{
	    charInfo = _FSBmapCharInfo (thisChar);
	    _FSWriteBmapCharInfo (file, charInfo);
	}
	if (header.nbrDirRec > 0)
	    header.bytesDirRec = (ftell (file) - header.startDirSec) /
				 header.nbrDirRec;

	/** Write the bitmaps **/
	header.startMapSec = ftell (file);
	for (i = 0, thisChar = _FSBmapFirstChar (font, &character);
	     thisChar != NULL;
	     i++, thisChar = _FSBmapNextChar (font, &character))
	{
	    _FSBmapLockCharBitmap (thisChar);
	    charInfo = _FSBmapCharInfo (thisChar);
	    bmap = _FSBmapCharBitmap (thisChar);
	    _FSWriteBmapBitmap (file, bmap, charInfo->nMap);
	    _FSBmapUnlockCharBitmap (thisChar);
	}

	/** Unlock the characters **/
	for (thisChar = _FSBmapFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSBmapNextChar (font, &character))
	    _FSBmapUnlockCharInfo (thisChar);

	/* Write out the corrected font header, with right offsets */
	fseek (file, 0, 0);
	_FSWriteBmapHeader (file, &header);
    }
    else if (_FSOutlFont (font))		/* outline font? */
    {
	OutlHeader	header;
	OutlKernPair	*kernInfo;
	OutlCharNode	**thisChar;
	OutlCharInfo	*charInfo;
	OutlPolySize	*pSize;
	OutlVertex	*vert;

	/** Update the pSize & vertex offsets of all the characters **/
	_FSOutlHierarchicalUpdate (font);

	/** Write the header.  The offsets will be wrong,
	    but we write the header again after we're through. **/
	memcpy (&header, fontHdr, sizeof (OutlHeader));
	_FSWriteOutlHeader (file, &header);

	/** Write the OutlInfo section **/
	header.startGenSec = ftell (file);
	_FSWriteOutlInfo (file, info);
	header.bytesGenSec = ftell (file) - header.startGenSec;

	/** Write the KernPairs **/
	header.startKernSec = ftell (file);
	_FSOutlLockKernPairs (font);
	for (kernInfo = _FSOutlKernPairs (font), i = 0; i < header.nbrKernRec;
	     i++, kernInfo++)
	    _FSWriteOutlKernPair (file, kernInfo);
	_FSOutlUnlockKernPairs (font);
	if (header.nbrKernRec > 0)
	    header.bytesKernRec = (ftell (file) - header.startKernSec) /
				  header.nbrKernRec;

	/** Lock all characters, since they will be accessed several times **/
	for (thisChar = _FSOutlFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSOutlNextChar (font, &character))
	{
	    _FSOutlGetChar (font, thisChar, character);
	    _FSOutlLockCharInfo (thisChar);
	}

	/** Write the character directory **/
	header.startDirSec = ftell (file);
	for (thisChar = _FSOutlFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSOutlNextChar (font, &character))
	{
	    charInfo = _FSOutlCharInfo (thisChar);
	    _FSWriteOutlCharInfo (file, charInfo);
	}
	if (header.nbrDirRec > 0)
	    header.bytesDirRec = (ftell (file) - header.startDirSec) /
				 header.nbrDirRec;

	/** Write the poly sizes **/
	header.startPSizeSec = ftell (file);
	for (thisChar = _FSOutlFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSOutlNextChar (font, &character))
	{
	    _FSOutlLockCharPSize (thisChar);
	    charInfo = _FSOutlCharInfo (thisChar);
	    pSize = _FSOutlCharPSize (thisChar);
	    _FSWriteOutlPolySize (file, pSize, charInfo->nPSize);
	    _FSOutlUnlockCharPSize (thisChar);
	}
	if (header.nbrPSizeRec > 0)
	    header.bytesPSizeRec = (ftell (file) - header.startPSizeSec) /
				   header.nbrPSizeRec;

	/** Write the vertices **/
	header.startVertSec = ftell (file);
	for (thisChar = _FSOutlFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSOutlNextChar (font, &character))
	{
	    _FSOutlLockCharVert (thisChar);
	    charInfo = _FSOutlCharInfo (thisChar);
	    vert = _FSOutlCharVert (thisChar);
	    if (info->flags & FS_3D)
		_FSWriteOutl3DVertex (file, vert, charInfo->nVert);
	    else
		_FSWriteOutlVertex (file, vert, charInfo->nVert);
	    _FSOutlUnlockCharVert (thisChar);
	}
	if (header.nbrVertRec > 0)
	    header.bytesVertRec = (ftell (file) - header.startVertSec) /
				  header.nbrVertRec;

	/** Unlock the characters **/
	for (thisChar = _FSOutlFirstChar (font, &character); thisChar != NULL;
	     thisChar = _FSOutlNextChar (font, &character))
	    _FSOutlUnlockCharInfo (thisChar);

	/* Write out the corrected font header, with right offsets */
	fseek (file, 0, 0);
	_FSWriteOutlHeader (file, &header);
    }
    else
	rval = FS_INVALID_FONT;

    _FSFontUnlockHeader (font);
    _FSFontUnlockInfo (font);

    _GCUnlockSem (shared);

    fclose (file);

    return (rval);
}
