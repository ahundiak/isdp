/* $RCSfile: fsfntcch.c $$Revision: 1.4 $$Date: 1991/08/21 13:12:28 $ Copyright (c) 1990 Intergraph Corp. */


/************************ F O N T C A C H . C *******************************/

/** The following routines provide access to all types of fonts. **/

#define M_PI            3.14159265358979323846

#include <math.h>
#include <memory.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSFont.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSGenCache.h"
#include "../hfiles/FSCharMap.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSNewFont.h"



/*******
* Font *
*******/


/* This routine locks a font handle.  It should be called before	*/
/* dereferencing the handle.						*/

Int _FSFontLockFont (fontNode)
FontNode	**fontNode;
{
    _GCLock (fontNode);
    return (FS_NO_ERROR);
}



/* This routine unlocks a font handle.					*/

Int _FSFontUnlockFont (fontNode)
FontNode	**fontNode;
{
    _GCUnlock (fontNode);
    return (FS_NO_ERROR);
}



/*********
* Header *
*********/


/* This routine locks the header handle of the specified font.		*/

Int _FSFontLockHeader (fontNode)
FontNode	**fontNode;
{
    _GCLock ((*fontNode)->header);
    return (FS_NO_ERROR);
}



/* This routine unlocks the header handle of the specified font.	*/

Int _FSFontUnlockHeader (fontNode)
FontNode	**fontNode;
{
    _GCUnlock ((*fontNode)->header);
    return (FS_NO_ERROR);
}



/* This function returns a pointer to the header structure of the	*/
/* specified font.  The header handle should be locked before calling	*/
/* this function.							*/

FontHeader *_FSFontHeader (fontNode)
FontNode	**fontNode;
{
    return (*(*fontNode)->header);
}



/***************
* General Info *
***************/


/* This routine locks the info handle of the specified font.		*/

Int _FSFontLockInfo (FontNode **fontNode)
{
    _GCLock ((*fontNode)->info);
    return (FS_NO_ERROR);
}



/* This routine unlocks the info handle of the specified font.		*/

Int _FSFontUnlockInfo (FontNode **fontNode)
{
    _GCUnlock ((*fontNode)->info);
    return (FS_NO_ERROR);
}



/* This function returns a pointer to the info structure of the		*/
/* specified font.  The info handle should be locked before calling	*/
/* this function.							*/

FontInfo *_FSFontInfo (fontNode)
FontNode	**fontNode;
{
    return (*(*fontNode)->info);
}



/* This routine initializes some of the members of the info structure	*/
/* of the specified font.						*/

Int _FSFontAutosetInfo (FontInfo *info)
{
    info->rotationSin = (Real64) sin (info->rotation * M_PI / 180.0);

    info->rotationCos = (Real64) cos (info->rotation * M_PI / 180.0);

    return (FS_NO_ERROR);
}



/******************
* Kern Pair Table *
******************/


/* This routine locks the kern pair table handle of the specified font.	*/

Int _FSFontLockKernPairs (FontNode **fontNode)
{
    _GCLock ((*fontNode)->kernPair);
    return (FS_NO_ERROR);
}



/* This routine unlocks the kern pair table handle of the specified	*/
/* font.								*/

Int _FSFontUnlockKernPairs (FontNode **fontNode)
{
    _GCUnlock ((*fontNode)->kernPair);
    return (FS_NO_ERROR);
}



/* This function returns a pointer to the kern pair table of the	*/
/* specified font.  The kern pair table handle should be locked before	*/
/* calling this function.						*/

FontKernPair *_FSFontKernPairs (fontNode)
FontNode	**fontNode;
{
    return (*(*fontNode)->kernPair);
}



/* This is a recursive function that is used by _FSFontKernValue to	*/
/* search the sorted kern pair table for an entry containing the two	*/
/* specified characters.  The kern value is returned.			*/

static Real64 _FSKernPairSearch (begin, end, char1, char2)
FontKernPair	*begin, *end;
CharId		char1, char2;
{
    FontKernPair	*middle;

    /** Binary search for the kern pair **/
    middle = begin + (end - begin) / 2;
    if ((char1 == middle->char1) && (char2 == middle->char2))
	return (middle->kern);
    else if (begin == middle)
	return (0.0);
    else if (_FSComparePairChar (char1, char2,
				 middle->char1, middle->char2) < 0)
	return (_FSKernPairSearch (begin, middle, char1, char2));
    else
	return (_FSKernPairSearch (middle, end, char1, char2));
}


/* This function searches the kern pair table of the specified font for	*/
/* the specified character pair and returns the kern value.		*/

Real64 _FSFontKernValue (fontNode, char1, char2)
FontNode	**fontNode;
CharId		char1;
CharId		char2;
{
    Real64		kernAmount;
    FontKernPair	*kernTable;

    if ((*fontNode)->numKernPair == 0)
	return (0.0);

    _FSFontLockKernPairs (fontNode);
    kernTable = _FSFontKernPairs (fontNode);

    kernAmount = _FSKernPairSearch (kernTable,
				    &kernTable[(*fontNode)->numKernPair],
				    char1, char2);

    _FSFontUnlockKernPairs (fontNode);

    return (kernAmount);
}



/**************************
* Character Loop Routines *
**************************/


/* This function returns the character node and character value of the	*/
/* first character in the specified font.				*/

FontCharNode **_FSFontFirstChar (fontNode, character)
FontNode	**fontNode;
CharId		*character;
{
    (*fontNode)->currChar = -1;
    (*fontNode)->currCharNum = 0;
    return (_FSFontNextChar (fontNode, character));
}



/* This function returns the character node and character value of the	*/
/* next character in the specified font.				*/

FontCharNode **_FSFontNextChar (fontNode, character)
FontNode	**fontNode;
CharId		*character;
{
    FontNode		*fontPtr;
    FontCharNode	****table, ***tablePtr;

    /** I can dereference fontNode safely since no operation that would	**/
    /** compact memory (i.e., memory allocation) is being done		**/
    fontPtr = *fontNode;

    table = fontPtr->charDir.table;
    tablePtr = &(*table)[fontPtr->currChar];

    if (fontPtr->currCharNum < fontPtr->numChar)
    {
	do
	    tablePtr++;
	while (*tablePtr == NULL);

	fontPtr->currCharNum++;
	fontPtr->currChar = tablePtr - *table;
	*character = fontPtr->currChar + fontPtr->charDir.minChar;
	return (*tablePtr);
    }
    else
	return (NULL);
}



/*************
* Char Nodes *
*************/


/* This function returns a pointer to the character table entry for	*/
/* the specified character in the specified character directory.	*/

FontCharNode ***_FSFontCharDirEntry (charDir, character)
FontCharDir	*charDir;	/* must be locked */
CharId		character;
{
    if ((character < charDir->minChar) ||
	(character >= charDir->minChar + charDir->numChar))
	return (NULL);
    else
	return (&(*charDir->table)[character - charDir->minChar]);
}



/* This function returns a handle to the specified character in the	*/
/* specified font.  If the character does not exist, and missFlag is	*/
/* TRUE, a handle to the character designated as the missing character	*/
/* (if present) is returned; otherwise, NULL is returned.		*/

FontCharNode **_FSFontCharNode (
    FontNode            **fontNode,
    CharId		*character,	/* char to look for		*/
    Boolean		missFlag)	/* substitute missing char?	*/
{
    FontInfo		*info;
    FontCharDir		*charDir;
    FontCharNode	**charNode, ***charNodePtr;
    CharId		missingChar;

    _FSFontLockInfo (fontNode);
    _FSFontLockCharDir (fontNode);

    info = _FSFontInfo (fontNode);
    charDir = _FSFontCharDir (fontNode);

    _FSFontLockCharDirTable (fontNode);
    missingChar = info->missingChar;

    charNodePtr = _FSFontCharDirEntry (charDir, *character);
    if ((charNodePtr == NULL) &&
	(!missFlag || ((*character = missingChar) == (CharId) -1) ||
	((charNodePtr = _FSFontCharDirEntry (charDir, missingChar)) == NULL)))
	charNode = NULL;
    else
	charNode = *charNodePtr;

    _FSFontUnlockInfo (fontNode);
    _FSFontUnlockCharDir (fontNode);
    _FSFontUnlockCharDirTable (fontNode);

    return (charNode);
}



/* This routine locks the specified character info handle.		*/

Int _FSFontLockCharInfo (charNode)
FontCharNode	**charNode;	/* handle to xxxxCharNode */
{
    _GCLock (charNode);
    return (FS_NO_ERROR);
}



/* This routine unlocks the specified character info handle.		*/

Int _FSFontUnlockCharInfo (charNode)
FontCharNode	**charNode;	/* handle to xxxxCharNode */
{
    _GCUnlock (charNode);
    return (FS_NO_ERROR);
}



/* This function ensures that the character data (bitmap data or	*/
/* outline data) for the specified character node is present.  It is	*/
/* called whenever a character is needed (e.g., for drawing), since the	*/
/* character may have been purged or may not have been created yet.	*/

Int _FSFontGetChar (FontNode **fontNode, FontCharNode **charNode, CharId character)
{
    if (*charNode == NULL)	/* is it purged? */
	_FSAppendChar (fontNode, character);

    /** Update the character's LRU timestamp **/
    _FSUpdateCharTime (fontNode, charNode);

    return (FS_NO_ERROR);
}



/**************
* Online Info *
**************/


/* This function returns a pointer to the modes section of a font node.	*/
/* The font handle should be locked before calling this function.	*/

FontModes *_FSFontModes (fontNode)
FontNode	**fontNode;
{
    return (&(*fontNode)->modes);
}



/* This function returns a pointer to the regeneration section of a	*/
/* font node.  The font handle should be locked before calling this	*/
/* function.								*/

FontRegen *_FSFontRegen (fontNode)
FontNode	**fontNode;
{
    return (&(*fontNode)->regen);
}



/* This function returns a pointer to the character directory of a	*/
/* font node.  The font handle should be locked before calling this	*/
/* function.								*/

FontCharDir *_FSFontCharDir (fontNode)
FontNode	**fontNode;
{
    return (&(*fontNode)->charDir);
}



/* This routine locks the character table handle of the specified font.	*/

Int _FSFontLockCharDirTable (FontNode **fontNode)
{
    _GCLock ((*fontNode)->charDir.table);
    return (FS_NO_ERROR);
}



/* This routine unlocks the character table handle of the specified	*/
/* font.								*/

Int _FSFontUnlockCharDirTable (FontNode **fontNode)
{
    _GCUnlock ((*fontNode)->charDir.table);
    return (FS_NO_ERROR);
}



/* This function returns a pointer to the character table of a		*/
/* font node.  The character directory handle should be locked before	*/
/* calling this function.						*/

FontCharNode ***_FSFontCharDirTable (fontNode)
FontNode	**fontNode;
{
    return (*(*fontNode)->charDir.table);
}



/***************************
* Kern Pair Table Creation *
***************************/


/* This function compares the two specified kern pairs.			*/

Int _FSComparePair (pair1, pair2)
FontKernPair	*pair1;
FontKernPair	*pair2;
{
    return (_FSComparePairChar (pair1->char1, pair1->char2,
			       pair2->char1, pair2->char2));
}


/* This function compares the two specified kern pairs.			*/

Int _FSComparePairChar (CharId char11, CharId char12, CharId char21, CharId char22)
{
    if (char11 < char21)
	return (-1);
    else if (char11 > char21)
	return (1);
    else if (char12 < char22)
	return (-1);
    else if (char12 > char22)
	return (1);
    else
	return (0);
}


/* This routine allocates memory for the kern pair table of the		*/
/* specified size for the specified font.  The specified kern pair	*/
/* table (already sorted) is copied into the new memory.		*/

Int _FSFontNewKernPairs (FontNode **fontNode, FontKernPair **kernPair, Int numPair)
{
    FontKernPair	**kernTable;

    /** Allocate the UNPURGEABLE kern pair table **/
    kernTable = (FontKernPair **) _GCAlloc (numPair * sizeof (FontKernPair));
    _FSAssert (kernTable != NULL);

    (*fontNode)->numKernPair = numPair;

    /** Copy the table (it is assumed to be already sorted) **/
    memcpy (*kernTable, kernPair, numPair * sizeof (FontKernPair));

    _GCRelease ((*fontNode)->kernPair);
    (*fontNode)->kernPair = kernTable;

    return (FS_NO_ERROR);
}



/****************
* Font Creation *
****************/


/* This function allocates memory for a new font.  It allocates the	*/
/* memory for the font node, an empty kern pair table, and an empty	*/
/* character table.  The font node is initialized.  The font node	*/
/* handle is returned.							*/

FontNode **_FSFontCreate ()
{
    FontNode	**fontNode;

    /* allocate UNPURGEABLE font node */
    fontNode = (FontNode **) _GCAlloc (sizeof (FontNode));
    _FSAssert (fontNode != NULL);

    /* allocate an empty kern pair table */
    (*fontNode)->kernPair = (FontKernPair **) _GCAlloc (-1);
    _FSAssert ((*fontNode)->kernPair != NULL);

    /* allocate an empty char dir table */
    (*fontNode)->charDir.table = (FontCharNode ****) _GCAlloc (-1);
    _FSAssert ((*fontNode)->charDir.table != NULL);

    /* initialize anything else */
    (*fontNode)->charDir.minChar = 0;
    (*fontNode)->charDir.numChar = 0;
    (*fontNode)->numKernPair = 0;
    (*fontNode)->numLigature = 0;
    (*fontNode)->numChar = 0;

    return (fontNode);
}



/* This releases the memory occupied by the header, info, character	*/
/* table, kern pair table, and font node of the specified font.		*/

Int _FSFontFree (fontNode)
FontNode	**fontNode;
{
    /* free header, info, char dir table, & kern table */
    _GCRelease ((*fontNode)->header);
    _GCRelease ((*fontNode)->info);
    _GCRelease ((*fontNode)->charDir.table);
    _GCRelease ((*fontNode)->kernPair);

    _GCRelease (fontNode);

    return (FS_NO_ERROR);
}



/* This routine adds the specified characters into the character	*/
/* directory for the specified font.  This should be done before the	*/
/* routine that allocate space for a new character are called.		*/

Int _FSFontAppendCharDir (FontNode **fontNode, CharId *characters, int numChars)
{
    FontCharNode	***table, ***tablePtr;
    FontCharDir		*charDir;
    CharId		minChar, maxChar, *charPtr, *charEnd;
    Int			numChar;

    minChar = 0xFFFF;
    maxChar = 0;
    for (charPtr = characters, charEnd = &characters[numChars];
	 charPtr < charEnd; charPtr++)
    {
	minChar = MIN (minChar, *charPtr);
	maxChar = MAX (maxChar, *charPtr);
    }

    _FSFontLockCharDir (fontNode);
    charDir = _FSFontCharDir (fontNode);

    /** Need to reallocate the table? **/
    if ((minChar < charDir->minChar) ||
	(maxChar >= (charDir->minChar + charDir->numChar)))
    {
	int		minOffset, maxOffset;
	FontCharNode	****theTable, ***tableEnd;

	minOffset = charDir->minChar - minChar;
	maxOffset = maxChar - (charDir->minChar + charDir->numChar - 1);
	numChar = charDir->numChar + minOffset + maxOffset;
	numChar = MAX (numChar, charDir->numChar);
	minOffset = MAX (minOffset, 0);

	theTable = (FontCharNode ****) _GCAlloc (numChar *
						 sizeof (FontCharNode **));
	_FSAssert (theTable != NULL);

	/** Clear the table **/
	for (tablePtr = *theTable, tableEnd = &(*theTable)[numChar];
	     tablePtr < tableEnd; tablePtr++)
	    *tablePtr = NULL;

	memcpy (*theTable + minOffset, *(charDir->table), charDir->numChar);
	_GCRelease (charDir->table);
	charDir->table = theTable;
	charDir->minChar = minChar;
	charDir->numChar = numChar;
    }

    _FSFontLockCharDirTable (fontNode);
    table = _FSFontCharDirTable (fontNode);

    /** Fill in the new entries in the table **/
    for (charPtr = characters, charEnd = &characters[numChars];
	 charPtr < charEnd; charPtr++)
    {
	tablePtr = &table[*charPtr - minChar];
	if (*tablePtr == NULL)
	{
	    *tablePtr = (FontCharNode **) _GCAlloc (-1);
	    (*fontNode)->numChar++;
	}
    }

    _FSFontUnlockCharDirTable (fontNode);
    _FSFontUnlockCharDir (fontNode);

    return (FS_NO_ERROR);
}
