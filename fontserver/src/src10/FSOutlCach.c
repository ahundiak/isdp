/* $RCSfile: fstlcch.c $$Revision: 1.3 $$Date: 1991/02/28 17:50:18 $ Copyright (c) 1990 Intergraph Corp. */


/**************************** O U T L C A C H. C ***************************/

/** The following routines provide access to outline fonts. **/

#include <string.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSFont.h"
#include "../hfiles/FSOutl.h"
#include "../hfiles/FSOutlCach.h"
#include "../hfiles/FSGenCache.h"


Char8	_FSOutlMagic[] = "FSOF";	/* outline font magic number	*/
Char8	_FSOutlFmtVersn[] = "V2.2";	/* current outline font version	*/


/* This function returns TRUE iff the specified font is a outline font.	*/

Int _FSOutlFont (OutlNode **outlNode)
{
    return ((*outlNode)->type == 0x4C54554F);	/* "OUTL" */
}



/* This function sets the type of the specified font to a outline font.	*/

Int _FSOutlSetType (outlNode)
OutlNode	**outlNode;
{
    (*outlNode)->type = 0x4C54554F;	/* "OUTL" */
    return (FS_NO_ERROR);
}



/*****************
* Outline Header *
*****************/


/* This routine initializes some of the members of the header of the	*/
/* specified font.							*/

Int _FSOutlAutosetHeader (OutlNode **outlNode)
{
    OutlHeader	*header;
    Char8	date[12], copyrightNotice[80];
    Int16	year, month, day, hour, minute, second;

    void	_FSDateStamp ();
    void	_FSIproTodaysDate ();
    Int32	_FSIproClockHigh32 ();


    _FSOutlLockHeader (outlNode);
    header = _FSOutlHeader (outlNode);

    strncpy ((char *)header->magic, (char *)_FSOutlMagic, 4);
    strncpy ((char *)header->fmtVersn, (char *)_FSOutlFmtVersn, 4);

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

    _FSOutlUnlockHeader (outlNode);

    return (FS_NO_ERROR);
}



/********************
* Outline Char Info *
********************/


/* This function returns a pointer to the character info structure of	*/
/* the specified character node.  The character node handle should be	*/
/* locked before calling this function.					*/

OutlCharInfo *_FSOutlCharInfo (charNode)
OutlCharNode	**charNode;
{
    return (&(*charNode)->data);
}



/* This routine locks the pSize handle for the specified character	*/
/* node.								*/

Int _FSOutlLockCharPSize (OutlCharNode **charNode)
{
    _GCLock ((*charNode)->pSize);
    return (FS_NO_ERROR);
}



/* This routine unlocks the pSize handle for the specified character	*/
/* node.								*/

Int _FSOutlUnlockCharPSize (OutlCharNode **charNode)
{
    _GCUnlock ((*charNode)->pSize);
    return (FS_NO_ERROR);
}



/* This function returns a pointer to the pSize data of the specified	*/
/* character node.  This pSize handle should be locked before calling	*/
/* this function.							*/

OutlPolySize *_FSOutlCharPSize (charNode)
OutlCharNode	**charNode;
{
    return (*(*charNode)->pSize);
}



/* This routine locks the vertex handle for the specified character	*/
/* node.								*/

Int _FSOutlLockCharVert (OutlCharNode **charNode)
{
    _GCLock ((*charNode)->vert);
    return (FS_NO_ERROR);
}



/* This routine unlocks the vertex handle for the specified character	*/
/* node.								*/

Int _FSOutlUnlockCharVert (OutlCharNode **charNode)
{
    _GCUnlock ((*charNode)->vert);
    return (FS_NO_ERROR);
}



/* This function returns a pointer to the vertex data of the specified	*/
/* character node.  This vertex handle should be locked before calling	*/
/* this function.							*/

OutlVertex *_FSOutlCharVert (charNode)
OutlCharNode	**charNode;
{
    return (*(*charNode)->vert);
}



/*****************************
* Outline Character Creation *
*****************************/


/* This function allocates a new character node for the specified	*/
/* character, which must already be in the character table for the	*/
/* font.  The new character node handle is returned.			*/

OutlCharNode **_FSOutlNewDirRec (outlNode, character)
OutlNode	**outlNode;
CharId		character;
{
    OutlCharNode	**charNode;

    charNode = _FSOutlCharNode (outlNode, &character, FALSE);

    /** Allocate the PURGEABLE character node **/
    charNode = (OutlCharNode **) _GCRealloc (charNode, sizeof (OutlCharNode));
    _FSAssert (charNode != NULL);

    /** Allocate PURGED poly sizes **/
    /** NOTE: An empty pSize handle means either the pSize has been	**/
    /**  purged or this character has no pSize				**/
    (*charNode)->pSize = (OutlPolySize **) _GCAlloc (-1);
    _FSAssert ((*charNode)->pSize != NULL);

    /** Allocate PURGED vertices **/
    /** NOTE: An empty vert handle means either the vert has been	**/
    /**  purged or this character has no vert				**/
    (*charNode)->vert = (OutlVertex **) _GCAlloc (-1);
    _FSAssert ((*charNode)->vert != NULL);

    memset (&(*charNode)->data, 0, sizeof (OutlCharInfo));
    (*charNode)->data.charId = character;

    return (charNode);
}



/* This function allocates a new pSize array of the specified size for	*/
/* the specified character node.  The handle to the array is returned.	*/

OutlPolySize **_FSOutlNewPSize (charNode, size)
OutlCharNode	**charNode;
Int32		size;
{
    /** Reallocate new poly sizes **/
    (*charNode)->pSize = (OutlPolySize **) _GCRealloc
			((*charNode)->pSize, size * sizeof (OutlPolySize));
    _FSAssert ((*charNode)->pSize != NULL);

    return ((*charNode)->pSize);
}



/* This function allocates a new vertex array of the specified size for	*/
/* the specified character node.  The handle to the array is returned.	*/

OutlVertex **_FSOutlNewVert (charNode, size)
OutlCharNode	**charNode;
Int32		size;
{
    if (size == 0)
	size = -1;	/* allocate an empty (purged) vert */

    /** Reallocate new vertices **/
    (*charNode)->vert = (OutlVertex **) _GCRealloc
				((*charNode)->vert, size * sizeof (OutlVertex));
    _FSAssert ((*charNode)->vert != NULL);

    return ((*charNode)->vert);
}



/* This function allocates a new 3D vertex array of the specified size	*/
/* for the specified character node.  The handle to the array is	*/
/* returned.								*/

Outl3DVertex **_FSOutlNew3DVert (charNode, size)
OutlCharNode	**charNode;
Int32	size;
{
    if (size == 0)
	size = -1;	/* allocate an empty (purged) vert */

    /** Reallocate new 3D vertices **/
    (*charNode)->vert = (OutlVertex **) _GCRealloc
			((*charNode)->vert, size * sizeof (Outl3DVertex));
    _FSAssert ((*charNode)->vert != NULL);

    return ((Outl3DVertex **) (*charNode)->vert);
}



/* This routine releases the memory occupied by the specified character	*/
/* in the specified font.						*/

Int _FSOutlDeleteChar (outlNode, character)
OutlNode	**outlNode;
CharId		character;
{
    OutlCharNode	***charNodePtr, **charNode;

    charNodePtr = _FSOutlCharDirEntry (&(*outlNode)->charDir, character);
    charNode = *charNodePtr;
    *charNodePtr = NULL;

    if (*charNode != NULL)	/* is it not purged? */
    {
	_GCRelease ((*charNode)->pSize);
	_GCRelease ((*charNode)->vert);
    }
    _GCRelease (charNode);

    (*outlNode)->numChar--;

    return (FS_NO_ERROR);
}



/************************
* Outline Font Creation *
************************/


/* This function allocates memory for a new outline font.  Memory for	*/
/* the header and info structures is also allocated.  The handle to the	*/
/* font is returned.							*/

OutlNode **_FSOutlCreateOutl ()
{
    OutlNode	**outlNode;

    /* allocate UNPURGEABLE font node */
    outlNode = (OutlNode **) _FSFontCreate ();
    _FSAssert (outlNode != NULL);

    _FSOutlLockFont (outlNode);

    /* allocate UNPURGEABLE header node */
    (*outlNode)->header = (FontHeader **) _GCAlloc (sizeof (OutlHeader));
    _FSAssert ((*outlNode)->header != NULL);

    /* allocate UNPURGEABLE info node */
    (*outlNode)->info = (OutlInfo **) _GCAlloc (sizeof (OutlInfo));
    _FSAssert ((*outlNode)->info != NULL);

    /* initialize the font type */
    _FSOutlSetType (outlNode);

    _FSOutlUnlockFont (outlNode);
    return (outlNode);
}



/* This routine releases the memory occupied by the specified font.	*/

Int _FSOutlFree (
OutlNode	**outlNode)	/* ptr to font control structure */
{
    CharId		character;
    OutlCharNode	**thisChar, **nextChar;

    /* free the char nodes, poly sizes, & vertices */
    for (thisChar = _FSOutlFirstChar (outlNode, &character); thisChar != NULL;
	 thisChar = nextChar)
    {
	nextChar = _FSOutlNextChar (outlNode, &character);
	if (*thisChar != NULL)	/* is this char purged? */
	{
	    _GCRelease ((*thisChar)->pSize);
	    _GCRelease ((*thisChar)->vert);
	}
	_GCRelease (thisChar);
    }

    /* free the font node */
    _FSFontFree (outlNode);

    return (FS_NO_ERROR);
}




/* This routine updates the section of the character node structure	*/
/* that is used when the font is written to a file.  It is called	*/
/* only when the font is written to a file.				*/

Int _FSOutlHierarchicalUpdate (OutlNode **outlNode)
{
    uInt32		pSizeOffset, vertOffset;
    CharId		character;
    OutlCharNode	**charNode;
    OutlHeader		*header;
    OutlCharInfo	*charInfo;

    _FSOutlLockHeader (outlNode);
    header = _FSOutlHeader (outlNode);

    /* update character section, creating all uncreated characters */
    pSizeOffset = vertOffset = 0;
    for (charNode = _FSOutlFirstChar (outlNode, &character); charNode != NULL;
	 charNode = _FSOutlNextChar (outlNode, &character))
    {
	_FSOutlGetChar (outlNode, charNode, character);

	_FSOutlLockCharInfo (charNode);
	charInfo = _FSOutlCharInfo (charNode);

	charInfo->sPSize = pSizeOffset;
	charInfo->sVert = vertOffset;
	pSizeOffset += charInfo->nPSize;
	vertOffset += charInfo->nVert;

	_FSOutlUnlockCharInfo (charNode);
    }
    header->nbrPSizeRec = pSizeOffset;
    header->nbrVertRec = vertOffset;

    _FSOutlUnlockHeader (outlNode);

    return (FS_NO_ERROR);
}



/* This routine updates the section of the header structure		*/
/* that is used when the font is written to a file.  It is called	*/
/* before the font is written to a file.				*/

Int _FSOutlUpdateHeader (OutlNode **outlNode)
{
    OutlHeader		*header;

    _FSOutlLockHeader (outlNode);
    header = _FSOutlHeader (outlNode);

    header->nbrKernRec = (*outlNode)->numKernPair;
    header->nbrDirRec = (*outlNode)->numChar;

    _FSOutlUnlockHeader (outlNode);

    return (FS_NO_ERROR);
}



/****************/
/* Font purging */
/****************/

/* This function returns TRUE iff the specified character node is	*/
/* purgeable.								*/

Int _FSOutlPurgeableChar (OutlCharNode **charNode)
{
    /** a character is purgeable iff it is not already purged and no	**/
    /** part of it is currently locked					**/

    return ((*charNode != NULL) && !_GCLocked (charNode) &&
	    !_GCLocked ((*charNode)->pSize) && !_GCLocked ((*charNode)->vert));
}



/* This routine purges the specified character node iff it is		*/
/* purgeable.  The memory occupied by the pSize and vertex arrays of	*/
/* the character is released and may later be reallocated if the	*/
/* character is needed for drawing or if the font is written to a file.	*/

Int _FSOutlPurgeChar (OutlCharNode **charNode)
{
    int	size;

    /** Purge the char iff it is purgeable **/
    if (_FSOutlPurgeableChar (charNode))
    {
	size = (*charNode)->data.nPSize + (*charNode)->data.nVert +
	       sizeof (BmapCharInfo);

	_GCRelease ((*charNode)->pSize);
	_GCRelease ((*charNode)->vert);
	_GCPurge (charNode);
    }
    else
	size = 0;

    return (size);
}
