/* $RCSfile: fsio.c $$Revision: 1.3 $$Date: 1992/10/25 09:56:17 $ Copyright (c) 1990 Intergraph Corp. */

#include <stdio.h>
#include <string.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSUtil.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSFont.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSOutl.h"
#include "../hfiles/FSCharMap.h"


/************************************************************************/
/*									*/
/*	   The routines in this file exist because of the alignment	*/
/*	problems between different machines.  Some require that	shorts	*/
/*	lie on even byte boundaries, or that longs should lie on long	*/
/*	boundaries (addresses divisible by 4), etc.  This creates	*/
/*	problems with structures in that the size of the same structure	*/
/*	will vary from machine to machine depending on how it gets	*/
/*	'padded' to preserve alignment.					*/
/*									*/
/*	   To solve this problem,  we decided to write routines that	*/
/*	would handle the reading and writing of structures to files.	*/
/*	Rather than simply writing out a chunk of memory that is the	*/
/*	size of the structure, the individual members of the structure	*/
/*	are written out one by one so that there is no padding in the	*/
/*	file.  Similarly, the structures are read member by member.	*/
/*	As long as the file I/O goes through these routines, there	*/
/*	should be no problem with alignment from machine to machine.	*/
/*									*/
/************************************************************************/

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSReadThing (file, thing, version)			*/
/*									*/
/*	  FILE	*file;		- file to read from			*/
/*	  Thing	*thing;		- structure to be read			*/
/*	  int	version;	- version number of file		*/
/*				  (e.g., v2.2 == 22)			*/
/*									*/
/*	DESCRIPTION							*/
/*	  These read routines will read the desired structures from	*/
/*	  a file.							*/
/*									*/
/*	  It is assumed that the file pointer points to the beginning	*/
/*	  of one of the structures in it.  These routines simply read, 	*/
/*	  they do no positioning.  Also, there sould be no blank space	*/
/*	  between members of the structures.				*/
/*									*/
/*	  There are currently routines to read the following types	*/
/*	  of font independent structures:				*/
/*			FontInfo					*/
/*			FontKernPair					*/
/*			FontLigature					*/
/*									*/
/*	  And the following font dependent structures:			*/
/*			BmapHeader					*/
/*			BmapCharInfo					*/
/*			BmapBitmap					*/
/*			OutlHeader					*/
/*			OutlCharInfo					*/
/*			OutlPolySize					*/
/*			OutlVertex					*/
/*			Outl3DVertex					*/
/*									*/
/*	RETURN VALUE							*/
/*	  If the routine reads the correct amount of information,	*/
/*	  i.e., it didn't run into the end of the file while trying	*/
/*	  to read the structure, it returns FS_NO_ERROR.  If, however,	*/
/*	  it did run into problems while reading, it will return	*/
/*	  FS_ERROR.							*/
/*									*/
/************************************************************************/


/******************************
* Font independent structures *
******************************/

int _FSReadFontInfo (FILE *file, FontInfo *info, int version)
{
    int numItems = 0;

    numItems += fread (&(info->typeface[0]), sizeof(Char8), 15, file);
    numItems += fread (&(info->bodySize), sizeof(Real64), 1, file);
    numItems += fread (&(info->resFactor), sizeof(Real64), 1, file);
    numItems += fread (&(info->aspect), sizeof(Real64), 1, file);
    numItems += fread (&(info->rotation), sizeof(Real64), 1, file);
    numItems += fread (&(info->slant), sizeof(Real64), 1, file);

    /** Versions below 2.2 have char map ids **/
    /** Versions 2.2 and up have char map file names **/
    if (version >= 22)
	numItems += fread (&(info->charMap[0]), sizeof(Char8), 15, file);
    else
    {
	FileRef		cmRef;
	CharMapId	*charMapId;

	numItems += fread (&charMapId, sizeof(CharMapId), 1, file) + 14;

	/** Convert the char map id into a char map file name, if possible **/
	if (_FSGetCharMapRef ((char *)charMapId, &cmRef) == FS_NO_ERROR)
	{
	    int		length;
	    char	*ptr;

	    ptr = _FSGetBaseName (cmRef.fileName, _FSCMExtension, &length);
	    strncpy ((char *)info->charMap, ptr, length);
	}
	else
	    strcpy ((char *)info->charMap, "???");
    }

    numItems += fread (&(info->flags), sizeof(Int32), 1, file);
    numItems += fread (&(info->ascent), sizeof(Real64), 1, file);
    numItems += fread (&(info->descent), sizeof(Real64), 1, file);
    numItems += fread (&(info->minExtent), sizeof(Real64), 1, file);
    numItems += fread (&(info->maxExtent), sizeof(Real64), 1, file);
    numItems += fread (&(info->track[0]), sizeof(Real64), 4, file);
    numItems += fread (&(info->rotationSin), sizeof(Real64), 1, file);
    numItems += fread (&(info->rotationCos), sizeof(Real64), 1, file);
    numItems += fread (&(info->drawDir), sizeof(Int16), 1, file);
    numItems += fread (&(info->missingChar), sizeof(CharId), 1, file);
    numItems += fread (&(info->fontFlags), sizeof(Int32), 1, file);

    if (numItems == 49)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

/*ARGSUSED*/
int _FSReadFontKernPair (FILE *file, FontKernPair *kernPair, int version)
{
    int	numItems = 0;

    numItems += fread (&(kernPair->char1), sizeof(Char16), 1, file);
    numItems += fread (&(kernPair->char2), sizeof(Char16), 1, file);
    numItems += fread (&(kernPair->kern), sizeof(Real64), 1, file);

    if (numItems == 3)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

/*ARGSUSED*/
int _FSReadFontLigature (file, lig, version)
FILE		*file;
FontLigature	*lig;
int		version;
{
    int	numItems = 0;

    numItems += fread (&(lig->char1), sizeof(Char16), 1, file);
    numItems += fread (&(lig->char2), sizeof(Char16), 1, file);
    numItems += fread (&(lig->char3), sizeof(Char16), 1, file);
    numItems += fread (&(lig->lig), sizeof(Char16), 1, file);

    if (numItems == 4)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}



/*************************
* Bitmap font structures *
*************************/

int _FSReadBmapHeader (FILE *file, BmapHeader *hdr)
{
    int	numItems = 0;

    numItems += fread (&(hdr->magic[0]), sizeof(Char8), 4, file);
    numItems += fread (&(hdr->fmtVersn[0]), sizeof(Char8), 4, file);
    numItems += fread (&(hdr->tfId[0]), sizeof(Char8), 4, file);
    numItems += fread (&(hdr->tfName[0]), sizeof(Char8), 70, file);
    numItems += fread (&(hdr->tfFile[0]), sizeof(Char8), 128, file);
    numItems += fread (&(hdr->tfRev), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->layoutNumber), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->mfgDate[0]), sizeof(Char8), 10, file);
    numItems += fread (&(hdr->timeStamp), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->copyrt[0]), sizeof(Char8), 34, file);
    numItems += fread (&(hdr->startGenSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesGenSec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->startKernSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesKernRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->nbrKernRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->startLigSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesLigRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->nbrLigRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->startDirSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesDirRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->nbrDirRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->startMapSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesMapSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->reserved[0]), sizeof(Char8), 32, file);

    if (numItems == 302)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

/*ARGSUSED*/
int _FSReadBmapCharInfo (FILE *file, BmapCharInfo *info, int version)
{
    int	numItems = 0;

    numItems += fread (&(info->charId), sizeof(Char16), 1, file);
    numItems += fread (&(info->setWid), sizeof(Real64), 1, file);
    numItems += fread (&(info->hOff), sizeof(Int16), 1, file);
    numItems += fread (&(info->vOff), sizeof(Int16), 1, file);
    numItems += fread (&(info->rWid), sizeof(uInt16), 1, file);
    numItems += fread (&(info->rHgt), sizeof(uInt16), 1, file);
    numItems += fread (&(info->sMap), sizeof(uInt32), 1, file);
    numItems += fread (&(info->nMap), sizeof(uInt32), 1, file);
    numItems += fread (&(info->flags), sizeof(Int16), 1, file);

    if (numItems == 9)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

/*ARGSUSED*/
int _FSReadBmapBitmap (file, bitmap, size, version)
FILE		*file;
BmapBitmap	*bitmap;
int		size;
int		version;
{
    int	numItems = 0;

    numItems += fread (bitmap, sizeof(BmapBitmap), size, file);

    if (numItems == size)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}



/**************************
* Outline font structures *
**************************/

int _FSReadOutlHeader (FILE *file, OutlHeader *hdr)
{
    int	numItems = 0;

    numItems += fread (&(hdr->magic[0]), sizeof(Char8), 4, file);
    numItems += fread (&(hdr->fmtVersn[0]), sizeof(Char8), 4, file);
    numItems += fread (&(hdr->tfId[0]), sizeof(Char8), 4, file);
    numItems += fread (&(hdr->tfName[0]), sizeof(Char8), 70, file);
    numItems += fread (&(hdr->tfFile[0]), sizeof(Char8), 128, file);
    numItems += fread (&(hdr->tfRev), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->layoutNumber), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->mfgDate[0]), sizeof(Char8), 10, file);
    numItems += fread (&(hdr->timeStamp), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->copyrt[0]), sizeof(Char8), 34, file);
    numItems += fread (&(hdr->startGenSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesGenSec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->startKernSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesKernRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->nbrKernRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->startLigSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesLigRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->nbrLigRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->startDirSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesDirRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->nbrDirRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->startPSizeSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesPSizeRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->nbrPSizeRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->startVertSec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->bytesVertRec), sizeof(Int16), 1, file);
    numItems += fread (&(hdr->nbrVertRec), sizeof(Int32), 1, file);
    numItems += fread (&(hdr->reserved[0]), sizeof(Char8), 32, file);

    if (numItems == 306)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

/*ARGSUSED*/
int _FSReadOutlCharInfo (FILE *file, OutlCharInfo *info, int version)
{
    int	numItems = 0;

    numItems += fread (&(info->charId), sizeof(Int16), 1, file);
    numItems += fread (&(info->setWid), sizeof(Real64), 1, file);
    numItems += fread (&(info->xMin), sizeof(Real64), 1, file);
    numItems += fread (&(info->yMin), sizeof(Real64), 1, file);
    numItems += fread (&(info->xMax), sizeof(Real64), 1, file);
    numItems += fread (&(info->yMax), sizeof(Real64), 1, file);
    numItems += fread (&(info->sPSize), sizeof(uInt32), 1, file);
    numItems += fread (&(info->nPSize), sizeof(uInt16), 1, file);
    numItems += fread (&(info->sVert), sizeof(uInt32), 1, file);
    numItems += fread (&(info->nVert), sizeof(uInt16), 1, file);
    numItems += fread (&(info->flags), sizeof(Int16), 1, file);

    if (numItems == 11)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

/*ARGSUSED*/
int _FSReadOutlPolySize (FILE *file, OutlPolySize *pSize, int count, int version)
{
    int	numItems = 0;

    numItems += fread (pSize, sizeof(Int32), count, file);

    if (numItems == count)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

/*ARGSUSED*/
int _FSReadOutlVertex (FILE *file, OutlVertex *vert, int count, int version)
{
    int	numItems = 0;

    numItems += fread (vert, 2 * sizeof(Real64), count, file);

    if (numItems == count)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

/*ARGSUSED*/
int _FSReadOutl3DVertex (FILE *file, Outl3DVertex *vert, int count, int version)
{
    int	numItems = 0;

    numItems += fread (vert, 3 * sizeof(Real64), count, file);

    if (numItems == count)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSWriteThing (file, thing)				*/
/*									*/
/*	  FILE	*file;		- file to write to			*/
/*	  Thing	*thing		- structure to be written		*/
/*									*/
/*	DESCRIPTION							*/
/*	  In order to write out packed structures (without padding	*/
/*	  for alignment's sake), these routines write out the members	*/
/*	  of structures one by one.					*/
/*									*/
/*	  It is assumed that the file is pointing to where the		*/
/*	  structure should be placed.  These routines simply write, 	*/
/*	  they do no positioning.					*/
/*									*/
/*	  There are currently routines to write the following types	*/
/*	  of font independent structures:				*/
/*			FontInfo					*/
/*			FontKernPair					*/
/*			FontLigature					*/
/*									*/
/*	  And the following font dependent structures:			*/
/*			BmapHeader					*/
/*			BmapCharInfo					*/
/*			BmapBitmap					*/
/*			OutlHeader					*/
/*			OutlCharInfo					*/
/*			OutlPolySize					*/
/*			OutlVertex					*/
/*			Outl3DVertex					*/
/*									*/
/*	RETURN VALUE							*/
/*	  When a structure is successfully written, FS_NO_ERROR is	*/
/*	  returned.  Otherwise, FS_ERROR gets sent back.		*/
/*									*/
/************************************************************************/


/******************************
* Font independent structures *
******************************/

int _FSWriteFontInfo (FILE *file, FontInfo *info)
{
    int	numItems = 0;

    numItems += fwrite (&(info->typeface[0]), sizeof(Char8), 15, file);
    numItems += fwrite (&(info->bodySize), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->resFactor), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->aspect), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->rotation), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->slant), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->charMap[0]), sizeof(Char8), 15, file);
    numItems += fwrite (&(info->flags), sizeof(Int32), 1, file);
    numItems += fwrite (&(info->ascent), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->descent), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->minExtent), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->maxExtent), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->track[0]), sizeof(Real64), 4, file);
    numItems += fwrite (&(info->rotationSin), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->rotationCos), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->drawDir), sizeof(Int16), 1, file);
    numItems += fwrite (&(info->missingChar), sizeof(CharId), 1, file);
    numItems += fwrite (&(info->fontFlags), sizeof(Int32), 1, file);

    if (numItems == 49)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

int _FSWriteFontKernPair (FILE *file, FontKernPair *kernPair)
{
    int	numItems = 0;

    numItems += fwrite (&(kernPair->char1), sizeof(Char16), 1, file);
    numItems += fwrite (&(kernPair->char2), sizeof(Char16), 1, file);
    numItems += fwrite (&(kernPair->kern), sizeof(Real64), 1, file);

    if (numItems == 3)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

int _FSWriteFontLigature (file, lig)
FILE		*file;
FontLigature	*lig;
{
    int	numItems = 0;

    numItems += fwrite (&(lig->char1), sizeof(Char16), 1, file);
    numItems += fwrite (&(lig->char2), sizeof(Char16), 1, file);
    numItems += fwrite (&(lig->char3), sizeof(Char16), 1, file);
    numItems += fwrite (&(lig->lig), sizeof(Char16), 1, file);

    if (numItems == 4)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}



/*************************
* Bitmap font structures *
*************************/

int _FSWriteBmapHeader (FILE *file, BmapHeader *hdr)
{
    int	numItems = 0;

    numItems += fwrite (&(hdr->magic[0]), sizeof(Char8), 4, file);
    numItems += fwrite (&(hdr->fmtVersn[0]), sizeof(Char8), 4, file);
    numItems += fwrite (&(hdr->tfId[0]), sizeof(Char8), 4, file);
    numItems += fwrite (&(hdr->tfName[0]), sizeof(Char8), 70, file);
    numItems += fwrite (&(hdr->tfFile[0]), sizeof(Char8), 128, file);
    numItems += fwrite (&(hdr->tfRev), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->layoutNumber), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->mfgDate[0]), sizeof(Char8), 10, file);
    numItems += fwrite (&(hdr->timeStamp), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->copyrt[0]), sizeof(Char8), 34, file);
    numItems += fwrite (&(hdr->startGenSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesGenSec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->startKernSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesKernRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->nbrKernRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->startLigSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesLigRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->nbrLigRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->startDirSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesDirRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->nbrDirRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->startMapSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesMapSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->reserved[0]), sizeof(Char8), 32, file);

    if (numItems == 302)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

int _FSWriteBmapCharInfo (FILE *file, BmapCharInfo *info)
{
    int	numItems = 0;

    numItems += fwrite (&(info->charId), sizeof(Char16), 1, file);
    numItems += fwrite (&(info->setWid), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->hOff), sizeof(Int16), 1, file);
    numItems += fwrite (&(info->vOff), sizeof(Int16), 1, file);
    numItems += fwrite (&(info->rWid), sizeof(uInt16), 1, file);
    numItems += fwrite (&(info->rHgt), sizeof(uInt16), 1, file);
    numItems += fwrite (&(info->sMap), sizeof(uInt32), 1, file);
    numItems += fwrite (&(info->nMap), sizeof(uInt32), 1, file);
    numItems += fwrite (&(info->flags), sizeof(Int16), 1, file);

    if (numItems == 9)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

int _FSWriteBmapBitmap (FILE *file, BmapBitmap *bitmap, int size)
{
    int	numItems = 0;

    numItems += fwrite (bitmap, sizeof(BmapBitmap), size, file);

    if (numItems == size)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}



/**************************
* Outline font structures *
**************************/

int _FSWriteOutlHeader (FILE *file, OutlHeader *hdr)
{
    int	numItems = 0;

    numItems += fwrite (&(hdr->magic[0]), sizeof(Char8), 4, file);
    numItems += fwrite (&(hdr->fmtVersn[0]), sizeof(Char8), 4, file);
    numItems += fwrite (&(hdr->tfId[0]), sizeof(Char8), 4, file);
    numItems += fwrite (&(hdr->tfName[0]), sizeof(Char8), 70, file);
    numItems += fwrite (&(hdr->tfFile[0]), sizeof(Char8), 128, file);
    numItems += fwrite (&(hdr->tfRev), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->layoutNumber), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->mfgDate[0]), sizeof(Char8), 10, file);
    numItems += fwrite (&(hdr->timeStamp), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->copyrt[0]), sizeof(Char8), 34, file);
    numItems += fwrite (&(hdr->startGenSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesGenSec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->startKernSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesKernRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->nbrKernRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->startLigSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesLigRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->nbrLigRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->startDirSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesDirRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->nbrDirRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->startPSizeSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesPSizeRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->nbrPSizeRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->startVertSec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->bytesVertRec), sizeof(Int16), 1, file);
    numItems += fwrite (&(hdr->nbrVertRec), sizeof(Int32), 1, file);
    numItems += fwrite (&(hdr->reserved[0]), sizeof(Char8), 32, file);

    if (numItems == 306)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

int _FSWriteOutlCharInfo (FILE *file, OutlCharInfo *info)
{
    int	numItems = 0;

    numItems += fwrite (&(info->charId), sizeof(Int16), 1, file);
    numItems += fwrite (&(info->setWid), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->xMin), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->yMin), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->xMax), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->yMax), sizeof(Real64), 1, file);
    numItems += fwrite (&(info->sPSize), sizeof(uInt32), 1, file);
    numItems += fwrite (&(info->nPSize), sizeof(uInt16), 1, file);
    numItems += fwrite (&(info->sVert), sizeof(uInt32), 1, file);
    numItems += fwrite (&(info->nVert), sizeof(uInt16), 1, file);
    numItems += fwrite (&(info->flags), sizeof(Int16), 1, file);

    if (numItems == 11)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

int _FSWriteOutlPolySize (FILE *file, OutlPolySize *pSize, int count)
{
    int	numItems = 0;

    numItems += fwrite (pSize, sizeof(Int32), count, file);

    if (numItems == count)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

int _FSWriteOutlVertex (FILE *file, OutlVertex *vert, int count)
{
    int	numItems = 0;

    numItems += fwrite (vert, 2 * sizeof(Real64), count, file);

    if (numItems == count)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}

int _FSWriteOutl3DVertex (FILE *file, Outl3DVertex *vert, int count)
{
    int	numItems = 0;

    numItems += fwrite (vert, 3 * sizeof(Real64), count, file);

    if (numItems == count)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}
