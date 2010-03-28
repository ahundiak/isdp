/* $RCSfile: fsrdfnt.c $$Revision: 1.2 $$Date: 1991/02/28 17:51:12 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSOutl.h"
#include "../hfiles/FSBmapCach.h"
#include "../hfiles/FSOutlCach.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSIO.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSNewFont.h"
#include "../hfiles/FSMakeFont.h"
#include "../hfiles/FSGenCache.h"
#include "../hfiles/FSDaemon.h"
#include "../hfiles/FSReadFont.h"

extern	int	_FSDaemon;

extern	Char8	_FSBmapMagic[];
extern	Char8	_FSOutlMagic[];

FontNode	**_FSFindRFSharedFont ();


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSReadFontFile (fileName, font)				*/
/*									*/
/*	  char		*fileName;	- font file name		*/
/*	  FontNode	***font;	- font id returned		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine reads a bitmap or outline font file and brings	*/
/*	  the font online by putting it into the cache.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the specified file cannot be read			*/
/*		- memory cannot be allocated in the cache		*/
/*									*/
/************************************************************************/

int FSReadFontFile (fileName, font)
char		*fileName;
FontNode	***font;
{
    char	*fontPtr;
    int		rval, type, i, numChars, shared=0;
    uInt32	fontFileTag;
    CharId	*charIdTable, *charIdPtr, *charIdEnd;
    FontNode	**fontNode;
    FontModes	*modes;
    FontRegen	*regen;

    /** Read the file **/
    fontPtr = NULL;
    if ((rval = _FSReadFontFile (fileName, &fontPtr, &type)) != FS_NO_ERROR)
	goto Done;

    fontFileTag = 0;

    if (type == 0)	/* bitmap font */
    {
	BmapNode	**bmapFont;
	BmapHeader	*headerPtr, *header;
	BmapInfo	*infoPtr, *info;
	BmapKernPair	*kernPtr;
	BmapCharNode	**thisChar;
	BmapCharInfo 	*charDirPtr, *charInfo;
	BmapBitmap	**bitmap, *bitmaps;

	/** Initialize the pointers to each of the font file structures **/
	headerPtr = (BmapHeader *) fontPtr;
	infoPtr = (BmapInfo *) (fontPtr + headerPtr->startGenSec);
	charDirPtr = (BmapCharInfo *) (fontPtr + headerPtr->startDirSec);
	kernPtr = (BmapKernPair *) (fontPtr + headerPtr->startKernSec);
	bitmaps = (BmapBitmap *) (fontPtr + headerPtr->startMapSec);

#ifdef SHFONT
	shared = infoPtr->flags & FS_SHARED;
#else
	shared = FALSE;
#endif

	/** Initialize shared memory if necessary **/
	if (shared)
	    _FSShEnter ();

	if (shared && !_FSDaemon)
	{
	    rval = _FSDaemonReadFontFile (fileName, font);
	    goto Done;
	}

	if (_FSDaemon)
	{
	    fontFileTag = _FSGetFileTag (fileName);

	    /** See if the font exists in shared memory **/
	    fontNode = _FSFindRFSharedFont (fontFileTag);
	    if (fontNode != NULL)
	    {
		(*fontNode)->ownerCount++;
		*font = fontNode;
		goto Done;
	    }
	}

	bmapFont = _FSBmapCreateBmap ();
	*font = (FontNode **) bmapFont;

	_FSBmapLockHeader (bmapFont);
	_FSBmapLockInfo (bmapFont);
	header = _FSBmapHeader (bmapFont);
	info = _FSBmapInfo (bmapFont);
	numChars = headerPtr->nbrDirRec;

	memcpy (header, headerPtr, sizeof (BmapHeader));
	memcpy (info, infoPtr, sizeof (BmapInfo));

	/** Create the kern pair table **/
	_FSBmapNewKernPairs (bmapFont, (FontKernPair **)kernPtr, headerPtr->nbrKernRec); // XXX - Bad pointer being passed?

	/** Create the char dir table **/
	charIdTable = (CharId *) _FSAlloc (numChars * sizeof (CharId));
	charIdEnd = &charIdTable[numChars];
	for (charIdPtr = charIdTable; charIdPtr < charIdEnd; charIdPtr++)
	{
	    *charIdPtr = charDirPtr->charId;
	    charDirPtr++;
	}
	_FSBmapAppendCharDir ((FontNode **)bmapFont, charIdTable, numChars);
	_FSDealloc ((char *)charIdTable);
	charDirPtr -= numChars;

	/** Copy the char dirs & bitmaps **/
	for (i = 0; i < numChars; i++)
	{
	    thisChar = _FSBmapNewDirRec (bmapFont, charDirPtr->charId);

	    _FSBmapLockCharInfo (thisChar);
	    charInfo = _FSBmapCharInfo (thisChar);

	    memcpy (charInfo, charDirPtr, sizeof (BmapCharInfo));
	    charDirPtr++;

	    bitmap = _FSBmapNewMap (thisChar, charInfo->nMap);
	    memcpy (*bitmap, bitmaps, charInfo->nMap);
	    bitmaps += charInfo->nMap;

	    _FSBmapUnlockCharInfo (thisChar);
	}

	_FSUpdateFont (bmapFont);

	_FSBmapUnlockHeader (bmapFont);
	_FSBmapUnlockInfo (bmapFont);
    }
    else if (type == 1)
    {
	OutlNode	**outlFont;
	OutlHeader	*headerPtr, *header;
	OutlInfo	*infoPtr, *info;
	OutlKernPair	*kernPtr;
	OutlCharNode	**thisChar;
	OutlCharInfo	*charDirPtr, *charInfo;
	OutlPolySize	*pSizePtr, **pSize;
	OutlVertex	*vertPtr, **vert;
	Outl3DVertex	*vert3DPtr, **vert3D;

	/** Initialize the pointers to each of the font structures **/
	headerPtr = (OutlHeader *) fontPtr;
	infoPtr = (OutlInfo *) (fontPtr + headerPtr->startGenSec);
	charDirPtr = (OutlCharInfo *) (fontPtr + headerPtr->startDirSec);
	kernPtr = (OutlKernPair *) (fontPtr + headerPtr->startKernSec);
	pSizePtr = (OutlPolySize *) (fontPtr + headerPtr->startPSizeSec);
	vertPtr = (OutlVertex *) (fontPtr + headerPtr->startVertSec);
	vert3DPtr = (Outl3DVertex *) vertPtr;

#ifdef SHFONT
	shared = infoPtr->flags & FS_SHARED;
#else
	shared = FALSE;
#endif

	/** Initialize shared memory if necessary **/
	if (shared)
	    _FSShEnter ();

	if (shared && !_FSDaemon)
	{
	    rval = _FSDaemonReadFontFile (fileName, font);
	    goto Done;
	}

	if (_FSDaemon)
	{
	    fontFileTag = _FSGetFileTag (fileName);

	    /** See if the font exists in shared memory if **/
	    fontNode = _FSFindRFSharedFont (fontFileTag);
	    if (fontNode != NULL)
	    {
		(*fontNode)->ownerCount++;
		*font = fontNode;
		goto Done;
	    }
	}

	outlFont = _FSOutlCreateOutl ();
	*font = (FontNode **) outlFont;

	_FSOutlLockHeader (outlFont);
	_FSOutlLockInfo (outlFont);
	header = _FSOutlHeader (outlFont);
	info = _FSOutlInfo (outlFont);
	numChars = headerPtr->nbrDirRec;

	memcpy (header, headerPtr, sizeof (OutlHeader));
	memcpy (info, infoPtr, sizeof (OutlInfo));

	/** Create the kern pair table **/
	_FSOutlNewKernPairs (outlFont, (FontKernPair **)kernPtr, headerPtr->nbrKernRec); // XXX - Bad pointer being passed?

	/** Create the char dir table **/
	charIdTable = (CharId *) _FSAlloc (numChars * sizeof (CharId));
	charIdEnd = &charIdTable[numChars];
	for (charIdPtr = charIdTable; charIdPtr < charIdEnd; charIdPtr++)
	{
	    *charIdPtr = charDirPtr->charId;
	    charDirPtr++;
	}
	_FSOutlAppendCharDir (outlFont, charIdTable, numChars);
	_FSDealloc ((char *)charIdTable);
	charDirPtr -= numChars;

	/** Copy the char dirs, poly sizes, & vertices **/
	for (i = 0; i < numChars; i++)
	{
	    thisChar = _FSOutlNewDirRec (outlFont, charDirPtr->charId);

	    _FSOutlLockCharInfo (thisChar);
	    charInfo = _FSOutlCharInfo (thisChar);

	    memcpy (charInfo, charDirPtr, sizeof (OutlCharInfo));
	    charDirPtr++;

	    pSize = _FSOutlNewPSize (thisChar, charInfo->nPSize);
	    memcpy (*pSize, pSizePtr, charInfo->nPSize * sizeof (OutlPolySize));
	    pSizePtr += charInfo->nPSize;

	    if (infoPtr->flags & FS_3D)
	    {
		vert3D = _FSOutlNew3DVert (thisChar, charInfo->nVert);
		memcpy (*vert3D, vert3DPtr,
			charInfo->nVert * sizeof (Outl3DVertex));
		vert3DPtr += charInfo->nVert;
	    }
	    else
	    {
		vert = _FSOutlNewVert (thisChar, charInfo->nVert);
		memcpy (*vert, vertPtr, charInfo->nVert * sizeof (OutlVertex));
		vertPtr += charInfo->nVert;
	    }

	    _FSOutlUnlockCharInfo (thisChar);
	}

	_FSUpdateFont (outlFont);

	_FSOutlUnlockHeader (outlFont);
	_FSOutlUnlockInfo (outlFont);
    }

    fontNode = (FontNode **) *font;

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
    strcpy (regen->sourceRef.fileName, fileName);
    regen->sourceRef.tag = fontFileTag;
    regen->howToRegen = CALL_READFONT;
    _FSFontUnlockRegen (fontNode);

    if (_FSDaemon)
	_FSLinkSharedFont (fontNode);
    else
	(*fontNode)->ownerCount = 0;

    /** Add it to the unshared font list **/
    if (!shared)
	_FSAddUnsharedFont (fontNode);

Done:
    if (fontPtr != NULL)
	_FSDealloc (fontPtr);

    return (rval);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int *_FSReadFontFile (fileName, fontPtr, type)		*/
/*									*/
/*	  char		*fileName;	- bitstream font file name	*/
/*	  char		**fontPtr;	- pointer to font read in	*/
/*	  int		*type;		- font type (0=bmap, 1=outl)	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine opens a font file, determines the font type	*/
/*	  (bitmap or outline), and calls the appropriate routine to	*/
/*	  read it in.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if one of the following occurs:			*/
/*		- the specified file cannot be read			*/
/*		- the file is not a valid font file			*/
/*									*/
/************************************************************************/

int _FSReadFontFile (char *fileName, char **fontPtr, int *type)
{
    char magic[4];
    FILE *file;

    if ((file = fopen (fileName, "r")) == NULL)
	return (FS_FILE_NOT_FOUND);

    magic[0] = '\0';
    fread (magic, sizeof (char), 4, file);
    fseek (file, 0, 0);

    if (!strncmp (magic, (char *)_FSBmapMagic, 4))
    {
	*type = 0;
	return (_FSReadBmapFile (file, fontPtr));	/* bitmap file */
    }
    else if (!strncmp (magic, (char *)_FSOutlMagic, 4))
    {
	*type = 1;
	return (_FSReadOutlFile (file, fontPtr));	/* outline file */
    }
    else
	return (FS_INVALID_FONT_FILE);		/* invalid font file */
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int *_FSReadBmapFile (file, fontPtr)				*/
/*									*/
/*	  FILE		*file;		- bitmap file descriptor	*/
/*	  char		**fontPtr;	- pointer to font read in	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine allocates memory for a bitmap font file and	*/
/*	  reads it all in.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if one of the following occurs:			*/
/*		- the specified file cannot be read			*/
/*		- the file is not a valid font file			*/
/*									*/
/************************************************************************/

int _FSReadBmapFile (FILE *file, char **fontPtr)
{
    int		i, version;
    long	fSize;
    char	*fPtr;
    BmapHeader	fontHdr, *hdr;
    BmapKernPair *kernPair;
    BmapCharInfo *charDir;

    /** Read in the header **/
    if (_FSReadBmapHeader (file, &fontHdr) != FS_NO_ERROR)
    {
	fclose (file);
	return (FS_INVALID_FONT_FILE);
    }

    version = (fontHdr.fmtVersn[1] - '0') * 10 + (fontHdr.fmtVersn[3] - '0');

    /** Calculate the size of all the structures in the file **/
    fSize = sizeof (BmapHeader) + sizeof (BmapInfo) +
		(sizeof (BmapKernPair) * fontHdr.nbrKernRec) +
		(sizeof (BmapCharInfo) * fontHdr.nbrDirRec) +
		fontHdr.bytesMapSec;

    /** Allocate the space and read it in **/
    if ((fPtr = (char *) _FSAlloc (fSize)) == NULL)
    {
	fclose (file);
	return (FS_CANT_ALLOC);
    }
    *fontPtr = fPtr;

    fseek (file, 0, 0);			/* Go back to the beginning */
    hdr = (BmapHeader *) fPtr;

    /** Read in the header **/
    _FSReadBmapHeader (file, hdr);

    /** Next, the BmapInfo section **/
    fseek (file, hdr->startGenSec, 0);
    hdr->startGenSec = sizeof (BmapHeader);
    if (_FSReadBmapInfo (file, (FontInfo *)((char *)fPtr + hdr->startGenSec), version) !=
	FS_NO_ERROR)
    {
	fclose (file);
	return (FS_INVALID_FONT_FILE);
    }

    /** The kern table **/
    fseek (file, hdr->startKernSec, 0);
    hdr->startKernSec = hdr->startGenSec + sizeof (BmapInfo);
    kernPair = (BmapKernPair *)((char *)fPtr + hdr->startKernSec);
    for (i = 0; i < hdr->nbrKernRec; i++, kernPair++)	/* One by one */
    {
	if (_FSReadBmapKernPair (file, kernPair, version) != FS_NO_ERROR)
	{
	    fclose (file);
	    return (FS_INVALID_FONT_FILE);
	}
    }

    /** The character directory **/
    fseek (file, hdr->startDirSec, 0);
    hdr->startDirSec = hdr->startKernSec +
		       (hdr->nbrKernRec * sizeof (BmapKernPair));
    charDir = (BmapCharInfo *)((char *)fPtr + hdr->startDirSec);
    for (i = 0; i < hdr->nbrDirRec; i++,  charDir++)	/* One by one */
    {
	if (_FSReadBmapCharInfo (file, charDir, version) != FS_NO_ERROR)
	{
	    fclose (file);
	    return (FS_INVALID_FONT_FILE);
	}
    }

    /** The bitmap section **/
    fseek (file, hdr->startMapSec, 0);
    hdr->startMapSec = hdr->startDirSec +
		       (hdr->nbrDirRec * sizeof (BmapCharInfo));

    /** Read it in one big chunk **/
    if (fread ((char *)fPtr + hdr->startMapSec, sizeof (Char8),
	       hdr->bytesMapSec, file) != hdr->bytesMapSec)
    {
	fclose (file);
	return (FS_INVALID_FONT_FILE);
    }

    fclose (file);

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int *_FSReadOutlFile (file, fontPtr)				*/
/*									*/
/*	  FILE		*file;		- outline font file descriptor	*/
/*	  char		**fontPtr;	- pointer to font read in	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine allocates memory for an outline font and reads	*/
/*	  it all in.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if one of the following occurs:			*/
/*		- the specified file cannot be read			*/
/*		- the file is not a valid font file			*/
/*									*/
/************************************************************************/

int _FSReadOutlFile (FILE *file, char **fontPtr)
{
    int		i, rval, version;
    long	fSize;
    char	*fPtr;
    OutlHeader	fontHdr, *hdr;
    OutlInfo	fontInfo;
    OutlKernPair *kernPair;
    OutlCharInfo *charDir;

    /** Read in the header **/
    if (_FSReadOutlHeader (file, &fontHdr) != FS_NO_ERROR)
    {
	fclose (file);
	return (FS_INVALID_FONT_FILE);
    }

    version = (fontHdr.fmtVersn[1] - '0') * 10 + (fontHdr.fmtVersn[3] - '0');

    /** Read in the general info section **/
    if (_FSReadOutlInfo (file, &fontInfo, version) != FS_NO_ERROR)
    {
	fclose (file);
	return (FS_INVALID_FONT_FILE);
    }

    /** Calculate the size of all the structures in the file **/
    fSize = sizeof (OutlHeader) + sizeof (OutlInfo) +
		(sizeof (OutlKernPair) * fontHdr.nbrKernRec) +
		(sizeof (OutlCharInfo) * fontHdr.nbrDirRec) +
		(sizeof (OutlPolySize) * fontHdr.nbrPSizeRec);

    if (fontInfo.flags & FS_3D)
	fSize += (sizeof (Outl3DVertex) * fontHdr.nbrVertRec);
    else
	fSize += (sizeof (OutlVertex) * fontHdr.nbrVertRec);

    /** Allocate the space and read it in **/
    if ((fPtr = (char *) _FSAlloc (fSize)) == NULL)
    {
	fclose (file);
	return (FS_CANT_ALLOC);
    }
    *fontPtr = fPtr;

    fseek (file, 0, 0);			/* Go back to the beginning */
    hdr = (OutlHeader *) fPtr;

    /** Read in the header **/
    _FSReadOutlHeader (file, hdr);

    /** Next, the OutlInfo section **/
    fseek (file, hdr->startGenSec, 0);
    hdr->startGenSec = sizeof (OutlHeader);
    if (_FSReadOutlInfo (file, (FontInfo *)((char *)fPtr + hdr->startGenSec), version) !=
	FS_NO_ERROR)
    {
	fclose (file);
	return (FS_INVALID_FONT_FILE);
    }

    /** The kern table **/
    fseek (file, hdr->startKernSec, 0);
    hdr->startKernSec = hdr->startGenSec + sizeof (OutlInfo);
    kernPair = (OutlKernPair *)((char *)fPtr + hdr->startKernSec);
    for (i = 0; i < hdr->nbrKernRec; i++, kernPair++)	/* One by one */
    {
	if (_FSReadOutlKernPair (file, kernPair, version) != FS_NO_ERROR)
	{
	    fclose (file);
	    return (FS_INVALID_FONT_FILE);
	}
    }

    /** The character directory **/
    fseek (file, hdr->startDirSec, 0);
    hdr->startDirSec = hdr->startKernSec +
		       (hdr->nbrKernRec * sizeof (OutlKernPair));
    charDir = (OutlCharInfo *)((char *)fPtr + hdr->startDirSec);
    for (i = 0; i < hdr->nbrDirRec; i++,  charDir++)	/* One by one */
    {
	if (_FSReadOutlCharInfo (file, charDir, version) != FS_NO_ERROR)
	{
	    fclose (file);
	    return (FS_INVALID_FONT_FILE);
	}
    }

    /** The poly size section **/
    fseek (file, hdr->startPSizeSec, 0);
    hdr->startPSizeSec = hdr->startDirSec +
		       (hdr->nbrDirRec * sizeof (OutlCharInfo));
    if (_FSReadOutlPolySize (file, (OutlPolySize * )(fPtr + hdr->startPSizeSec),
			     hdr->nbrPSizeRec, version))
    {
	fclose (file);
	return (FS_INVALID_FONT_FILE);
    }

    /** The vertex section **/
    fseek (file, hdr->startVertSec, 0);
    hdr->startVertSec = hdr->startPSizeSec +
		       (hdr->nbrPSizeRec * sizeof (OutlPolySize));
    if (fontInfo.flags & FS_3D)
	rval = _FSReadOutl3DVertex (file, (Outl3DVertex *)(fPtr + hdr->startVertSec),
				    hdr->nbrVertRec, version);
    else
	rval = _FSReadOutlVertex (file, (OutlVertex *)(fPtr + hdr->startVertSec),
				  hdr->nbrVertRec, version);
    if (rval)
    {
	fclose (file);
	return (FS_INVALID_FONT_FILE);
    }

    fclose (file);

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  static FontNode **_FSFindRFSharedFont (tag)			*/
/*									*/
/*	  uInt32	tag;		- font file tag			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the shared font (if any) that matches	*/
/*	  the given font file tag.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  Font id	- font that matches the specifications		*/
/*	  NULL		- no matching font was found			*/
/*									*/
/************************************************************************/

FontNode **_FSFindRFSharedFont (tag)
uInt32	tag;
{
#ifdef SHFONT

    int		howToRegen;
    uInt32	fontTag;
    FontNode	**thisFont, **fontNode;
    FontRegen	*regen;

    fontNode = NULL;
    for (thisFont = (FontNode **) _GCGetSharedValue (0); thisFont != NULL;
	 thisFont = (*thisFont)->next)
    {
	_FSFontLockRegen (thisFont);
	regen = _FSFontRegen (thisFont);
	fontTag = regen->sourceRef.tag;
	howToRegen = regen->howToRegen;
	_FSFontUnlockRegen (thisFont);

	if ((fontTag == tag) && (howToRegen == CALL_READFONT))
	{
	    fontNode = thisFont;
	    break;
	}
    }

    return (fontNode);

#endif
}
