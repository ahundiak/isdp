/* $RCSfile: fsbmpcch.c $$Revision: 1.3 $$Date: 1991/02/28 13:34:36 $ Copyright (c) 1990 Intergraph Corp. */


/**************************** B M A P C A C H . C ***************************/

/** The following routines provide access to bitmap fonts. **/


#include "../hfiles/import.h"
#include <string.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSFont.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSBmapCach.h"
#include "../hfiles/FSGenCache.h"


Char8	_FSBmapMagic[] = "FSBF";	/* bitmap font magic number	*/
Char8	_FSBmapFmtVersn[] = "V2.2";	/* current bitmap font version	*/



/* This function returns TRUE iff the specified font is a bitmap font.	*/

Int _FSBmapFont (bmapNode)
BmapNode	**bmapNode;
{
    return ((*bmapNode)->type == 0x50414D42);	/* "BMAP" */
}



/* This function sets the type of the specified font to a bitmap font.	*/

Int _FSBmapSetType (bmapNode)
BmapNode	**bmapNode;
{
    (*bmapNode)->type = 0x50414D42;	/* "BMAP" */
    return (FS_NO_ERROR);
}



/****************
* Bitmap Header *
****************/


/* This routine initializes some of the members of the header of the	*/
/* specified font.							*/

Int _FSBmapAutosetHeader (bmapNode)
BmapNode	**bmapNode;
{
    BmapHeader	*header;
    Char8	date[12], copyrightNotice[80];
    Int16	year, month, day, hour, minute, second;

    void	_FSDateStamp ();
    void	_FSIproTodaysDate ();
    Int32	_FSIproClockHigh32 ();


    _FSBmapLockHeader (bmapNode);
    header = _FSBmapHeader (bmapNode);

    strncpy ((char *)header->magic, (char *)_FSBmapMagic, 4);
    strncpy ((char *)header->fmtVersn, (char *)_FSBmapFmtVersn, 4);

    _FSDateStamp (date);
    strncpy ((char *)header->mfgDate, (char *)date, 10);
    header->mfgDate[9] = '\0';

    header->timeStamp = _FSIproClockHigh32 ();

    _FSIproTodaysDate (&year, &month, &day, &hour, &minute, &second);
    sprintf ((char *)copyrightNotice,
	     "(c) Copyright Bitstream Inc. %d. All rights reserved", year);
    strncpy ((char *)header->copyrt, (char *)copyrightNotice, 34);
    header->copyrt[33] = '\0';

    memset (header->reserved, 0, 32);

    _FSBmapUnlockHeader (bmapNode);

    return (FS_NO_ERROR);
}



/*******************
* Bitmap Char Info *
*******************/


/* This function returns a pointer to the character info structure of	*/
/* the specified character node.  The character node handle should be	*/
/* locked before calling this function.					*/

BmapCharInfo *_FSBmapCharInfo (charNode)
BmapCharNode	**charNode;
{
    return (&(*charNode)->data);
}



/* This routine locks the bitmap handle for the specified character	*/
/* node.								*/

Int _FSBmapLockCharBitmap (charNode)
BmapCharNode	**charNode;
{
    _GCLock ((*charNode)->bits);
    return (FS_NO_ERROR);
}



/* This routine unlocks the bitmap handle for the specified character	*/
/* node.								*/

Int _FSBmapUnlockCharBitmap (charNode)
BmapCharNode	**charNode;
{
    _GCUnlock ((*charNode)->bits);
    return (FS_NO_ERROR);
}



/* This function returns a pointer to the bitmap data of the specified	*/
/* character node.  This bitmap handle should be locked before calling	*/
/* this function.							*/

BmapBitmap *_FSBmapCharBitmap (charNode)
BmapCharNode	**charNode;
{
    return (*(*charNode)->bits);
}



/****************************
* Bitmap Character Creation *
****************************/


/* This function allocates a new character node for the specified	*/
/* character, which must already be in the character table for the	*/
/* font.  The new character node handle is returned.			*/

BmapCharNode **_FSBmapNewDirRec (bmapNode, character)
BmapNode	**bmapNode;
CharId		character;
{
    BmapCharNode	**charNode;

    charNode = _FSBmapCharNode (bmapNode, &character, FALSE);

    /** Allocate the PURGEABLE character node **/
    charNode = (BmapCharNode **) _GCRealloc (charNode, sizeof (BmapCharNode));
    _FSAssert (charNode != NULL);

    /** Allocate a PURGED bitmap **/
    /** NOTE: An empty bitmap handle means either the bitmap has been	**/
    /**  purged or this character has no bitmap				**/
    (*charNode)->bits = (BmapBitmap **) _GCAlloc (-1);
    _FSAssert ((*charNode)->bits != NULL);

    memset (&(*charNode)->data, 0, sizeof (BmapCharInfo));
    (*charNode)->data.charId = character;

    return (charNode);
}



/* This function allocates a new bitmap of the specified size for the	*/
/* specified character node.  The handle to the bitmap is returned.	*/

BmapBitmap **_FSBmapNewMap (charNode, size)
BmapCharNode	**charNode;
Int32		size;
{
    if (size == 0)
	size = -1;	/* Allocate an empty (purged) bitmap */

    /** Reallocate new bitmap **/
    (*charNode)->bits = (BmapBitmap **) _GCRealloc
				((*charNode)->bits, size * sizeof (BmapBitmap));
    _FSAssert ((*charNode)->bits != NULL);

    return ((*charNode)->bits);
}



/* This routine releases the memory occupied by the specified character	*/
/* in the specified font.						*/

Int _FSBmapDeleteChar (bmapNode, character)
BmapNode	**bmapNode;
CharId		character;
{
    BmapCharNode	***charNodePtr, **charNode;

    charNodePtr = _FSBmapCharDirEntry (&(*bmapNode)->charDir, character);
    charNode = *charNodePtr;
    *charNodePtr = NULL;

    if (*charNode != NULL)	/* is this character purged? */
	_GCRelease ((*charNode)->bits);
    _GCRelease (charNode);

    (*bmapNode)->numChar--;

    return (FS_NO_ERROR);
}



/***********************
* Bitmap Font Creation *
***********************/


/* This function allocates memory for a new bitmap font.  Memory for	*/
/* the header and info structures is also allocated.  The handle to the	*/
/* font is returned.							*/

BmapNode **_FSBmapCreateBmap ()
{
    BmapNode	**bmapNode;

    /* allocate UNPURGEABLE font node */
    bmapNode = (BmapNode **) _FSFontCreate ();
    _FSAssert (bmapNode != NULL);

    _FSBmapLockFont (bmapNode);

    /* allocate UNPURGEABLE header node */
    (*bmapNode)->header = (FontHeader **) _GCAlloc (sizeof (BmapHeader));
    _FSAssert ((*bmapNode)->header != NULL);

    /* allocate UNPURGEABLE info node */
    (*bmapNode)->info = (BmapInfo **) _GCAlloc (sizeof (BmapInfo));
    _FSAssert ((*bmapNode)->info != NULL);

    /* initialize the font type */
    _FSBmapSetType (bmapNode);

    _FSBmapUnlockFont (bmapNode);
    return (bmapNode);
}



/* This routine releases the memory occupied by the specified font.	*/

Int _FSBmapFree (bmapNode)
BmapNode	**bmapNode;	/* ptr to font control structure */
{
    CharId		character;
    BmapCharNode	**thisChar, **nextChar;

    /* free the char nodes & bitmaps */
    for (thisChar = _FSBmapFirstChar (bmapNode, &character); thisChar != NULL;
	 thisChar = nextChar)
    {
	nextChar = _FSBmapNextChar (bmapNode, &character);
	if (*thisChar != NULL)	/* is this char purged? */
	    _GCRelease ((*thisChar)->bits);
	_GCRelease (thisChar);
    }

    /* free the font node */
    _FSFontFree (bmapNode);

    return (FS_NO_ERROR);
}




/* This routine updates the section of the character node structure	*/
/* that is used when the font is written to a file.  It is called	*/
/* only when the font is written to a file.				*/

Int _FSBmapHierarchicalUpdate (bmapNode)
BmapNode	**bmapNode;
{
    uInt32		bmapOffset;
    CharId		character;
    BmapCharNode	**charNode;
    BmapHeader		*header;
    BmapCharInfo	*charInfo;

    _FSBmapLockHeader (bmapNode);
    header = _FSBmapHeader (bmapNode);

    /* update character section, creating all uncreated characters */
    bmapOffset = 0;
    for (charNode = _FSBmapFirstChar (bmapNode, &character); charNode != NULL;
	 charNode = _FSBmapNextChar (bmapNode, &character))
    {
	_FSBmapGetChar (bmapNode, charNode, character);

	_FSBmapLockCharInfo (charNode);
	charInfo = _FSBmapCharInfo (charNode);

	charInfo->sMap = bmapOffset;
	bmapOffset += charInfo->nMap;

	_FSBmapUnlockCharInfo (charNode);
    }
    header->bytesMapSec = bmapOffset;

    _FSBmapUnlockHeader (bmapNode);

    return (FS_NO_ERROR);
}



/* This routine updates the section of the header structure		*/
/* that is used when the font is written to a file.  It is called	*/
/* before the font is written to a file.				*/

Int _FSBmapUpdateHeader (bmapNode)
BmapNode	**bmapNode;
{
    BmapHeader		*header;

    _FSBmapLockHeader (bmapNode);
    header = _FSBmapHeader (bmapNode);

    header->nbrKernRec = (*bmapNode)->numKernPair;
    header->nbrDirRec = (*bmapNode)->numChar;

    _FSBmapUnlockHeader (bmapNode);

    return (FS_NO_ERROR);
}



/****************/
/* Font purging */
/****************/

/* This function returns TRUE iff the specified character node is	*/
/* purgeable.								*/

Int _FSBmapPurgeableChar (charNode)
BmapCharNode	**charNode;
{
    /** A character is purgeable iff it is not already purged and no	**/
    /** part of it is currently locked					**/

    return ((*charNode != NULL) && !_GCLocked (charNode) &&
	    !_GCLocked ((*charNode)->bits));
}



/* This routine purges the specified character node iff it is		*/
/* purgeable.  The memory occupied by the bitmap of the character is	*/
/* released and may later be reallocated if the character is needed for	*/
/* drawing or if the font is written to a file.				*/

Int _FSBmapPurgeChar (charNode)
BmapCharNode	**charNode;
{
    int	size;

    /** Purge the char iff it is purgeable **/
    if (_FSBmapPurgeableChar (charNode))
    {
	size = (*charNode)->data.nMap + sizeof (BmapCharInfo);

	_GCRelease ((*charNode)->bits);
	_GCPurge (charNode);
    }
    else
	size = 0;

    return (size);
}
