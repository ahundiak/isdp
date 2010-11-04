/* $RCSfile: fsnwfnt.c $$Revision: 1.2 $$Date: 1991/02/28 17:50:51 $ Copyright (c) 1990 Intergraph Corp. */

#include <string.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSUtil.h"
#include "../hfiles/FSCharMap.h"
#include "../hfiles/FSTFCache.h"
#include "../hfiles/FSMakeFont.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSNewFont.h"
#include "../hfiles/FSBmapCach.h"
#include "../hfiles/FSGenCache.h"
#include "../hfiles/FSDaemon.h"
#include "../hfiles/FSOutl.h"
#include "../hfiles/FSOutlCach.h"

extern int FSdebug;

/** Globals for _FSMakeFont () **/
extern	FileRef	*_FSTypefaceRef;	/* tf reference */
extern	char	*_FSTypefaceName;	/* tf file name passed to FSNewFont */
extern	Real	_FSLinesPerEm;		/* vertical lines per em square */
extern	Real	_FSResFactor;		/* apparent resolution factor */
extern	Real	_FSAspectRatio;		/* aspect ratio (default = 1) */
extern	Real	_FSRotAngle;		/* rotation angle in degrees */
extern	Real	_FSOblAngle;		/* obliquing angle in degrees */
extern	FileRef	*_FSCharMapRef;		/* char map reference */
extern	char	*_FSCharMapName;	/* char map passed to FSNewFont */
extern	Int32	_FSFlags;		/* fontSpec flags */
extern	Boolean	_FSAllBitmaps;		/* T: all chars stored as bitmaps */
extern	Boolean	_FSAllRLE;		/* T: all chars stored as RLE */
extern	Boolean	_FSOutlFlag;		/* T: make an outline font */
extern	Boolean	_FSThicken;		/* T: thicken bitmaps by one pixel */
extern	Boolean	_FSBogusMode;		/* T: plaid data to be ignored */
extern	Boolean	_FSOutl3D;		/* T: 3D outlines in font */
extern	Boolean	_FSKerningFlag;		/* T: don't put kern pairs in font */
extern	Boolean	_FSDemandFlag;		/* T: create chars only when needed */
extern	Boolean	_FSIntWidthsFlag;	/* T: round all widths to integer */
extern	Boolean	_FSAddCharacters;	/* T: Add these chars to the font */
extern	Boolean	_FSClipLeft;		/* T: Clips min x at left of emsquare */
extern	Boolean	_FSClipRight;		/* T: Clips max x at right of emsquare */
extern	Boolean	_FSClipBottom;		/* T: Clips min y at bottom of emsquare */
extern	Boolean	_FSClipTop;		/* T: Clips max y at top of emsquare */
extern	Real	_FSLinesPerEmX;		/* horizontal "lines per em" */
extern	Real	_FSPointSizeX;		/* x-point size (72.3 pts per inch) */
extern	Real	_FSPointSizeY;		/* y-point size (72.3 pts per inch) */
extern	Real	_FSResH;		/* output device resolution, horiz. */
extern	Real	_FSResV;		/* output device resolution, vert. */
extern	Boolean	_FSSqueezeLeft;		/* T: Squeezes min x into left of emsquare */
extern	Boolean	_FSSqueezeRight;	/* T: Squeezes max x into right of emsquare */
extern	Boolean	_FSSqueezeBottom;	/* T: Squeezes min y into bottom of emsquare */
extern	Boolean	_FSSqueezeTop;		/* T: Squeezes max y into top of emsquare */
extern	SubsetList _FSSubset;		/* subset of char map */
extern	Boolean	_FSSWFixed;		/* T: set width constrained */
extern	Real	_FSXHgtAdj;		/* x height adjustment */

extern	int	_FSDaemon;		/* T: I am the daemon */

static FontNode	***_FSFontList;		/* this process' unshared font list */
static int	_FSNumFonts;		/* number of unshared fonts */
static int	_FSListSize;		/* how much space allocated for list */


#define	FS_USED_CHAR_MAX	32

static FontCharNode	**_FSUsedCharList[FS_USED_CHAR_MAX];
					/* chars that need updated times */
static int	_FSUsedChars;		/* how many chars in list */


int		_FSPurgeSome ();
FontNode	**_FSFindNFSharedFont ();



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSEnterNF (flags)						*/
/*									*/
/*	  uInt32	flags;	- miscellaneous flags			*/
/*				  Bit 0 => I am the daemon		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine initializes this part of the Font Server.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

int _FSEnterNF (uInt32 flags)
{
    _FSDaemon = flags & 0x1;

    /** Initialize the unshared font list **/
    _FSNumFonts = _FSListSize = 0;
    _FSFontList = (FontNode ***) _FSMalloc (0);

    /** Initialize the used character list **/
    _FSUsedChars = 0;

    _FSEnterMF ();

    if (_FSDaemon)
	_FSShEnter ();
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSExitNF ()							*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine de-initializes this part of the Font Server.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

int _FSExitNF (void)
{
    int	i;

    /** Delete all this process' unshared fonts **/
    for (i = 0; i < _FSListSize; i++)
    {
	if (_FSFontList[i] != NULL)
	    FSDeleteFont (_FSFontList[i]);
    }
    _FSFree (_FSFontList);

    _FSShExit ();
    _FSExitMF ();
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSShEnter ()							*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine makes sure the shared memory and associated	*/
/*	  structures are initialized.  It should be called at the	*/
/*	  beginning of any public routine that could be the first	*/
/*	  one called (such as FSNewFont, FSReadFont).			*/
/*	  This is not done in FSEnter() because the application might	*/
/*	  not be using shared fonts.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

int _FSShEnter (void)
{
    int	rval;

    rval = FS_NO_ERROR;

    if (!_GCShInited ())
    {
	if (_FSDaemon)	/* the daemon creates the shared memory */
	{
	    rval = _GCShEnter (TRUE);
	    if (rval == FS_NO_ERROR)
	    {
		_GCSetMemory (TRUE);

		/** Set the shared memory purge routine **/
		_GCSetPurgeFunc (_FSPurgeSome);
	    }
	}
	else	/* the client connects with the daemon */
	{
	    rval = _FSDaemonInit ();
	    if (rval == FS_NO_ERROR)
	    {
		rval = _GCShEnter (FALSE);
		if (rval == FS_NO_ERROR)
		{
		    _GCSetMemory (FALSE);

		    /** Send the FSEnter command to the daemon **/
		    _FSDaemonEnter ();
		}
	    }
	}
    }

    return (rval);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSShExit ()							*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine de-initializes the shared memory if it was	*/
/*	  initialized by _FSShEnter().					*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _FSShExit (void)
{
    if (_GCShInited ())
    {
	_FSDaemonExit ();
	_GCShExit ();
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSNewFont (fontSpec, rangeSpec, font)				*/
/*									*/
/*	  FontSpec	*fontSpec;	- font specification		*/
/*	  RangeSpec	*rangeSpec;	- range specification		*/
/*	  FontNode	***font;	- font id returned		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine creates a new bitmap or outline font with the	*/
/*	  characteristics specified in fontSpec.  Only the given	*/
/*	  range(s) of characters are created.  The font id is returned.	*/
/*	  If RangeSpec is NULL, all characters in the specified		*/
/*	  character mapping are created.				*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the specified typeface does not exist			*/
/*		- the specified char map does not exist			*/
/*		- the memory cannot be allocated for the font		*/
/*		- the font cannot be generated				*/
/*									*/
/************************************************************************/

int FSNewFont (fontSpec, rangeSpec, font)
FontSpec	*fontSpec;
RangeSpec	*rangeSpec;
FontNode	***font;
{
    int		rval, shared, genChars, newFont;
    FileRef	tfRef, cmRef;
    FontNode	**fontNode;

    if (FSdebug) printf(">>> FSNewFont\n");
    
    rval = FS_NO_ERROR;

#ifdef SHFONT
    shared = fontSpec->flags & FS_SHARED;
#else
    shared = FALSE;
#endif

    if (shared)
	if ((rval = _FSShEnter ()) != FS_NO_ERROR)
	    return (rval);

    _FSSubset.list = NULL;

    if (shared && !_FSDaemon)
	rval = _FSDaemonNewFont (fontSpec, rangeSpec, (FontNode *)font); // XXX - Bad pointer passed in original code?
    else
    {
	/** Get the typeface reference **/
	if ((rval = _FSGetTFRef (fontSpec->typeface, &tfRef)) != FS_NO_ERROR)
	    return (rval);

	/** Get the char map reference **/
	if ((rval = _FSGetCharMapRef (fontSpec->charMap,
				      &cmRef)) != FS_NO_ERROR)
	    return (rval);

	if (rangeSpec != NULL)
	{
	    _FSSubset.flag = TRUE;
	    _FSMakeSubset (rangeSpec, &_FSSubset);
	}
	else
	    _FSSubset.flag = FALSE;

	newFont = TRUE;
	if (_FSDaemon)
	{
	    /** Look for the font in shared memory **/
	    fontNode = _FSFindNFSharedFont (fontSpec, &_FSSubset, &tfRef,
					    &cmRef, &genChars);
	    if (fontNode != NULL)
	    {
		(*fontNode)->ownerCount++;
		*font = fontNode;
		newFont = FALSE;
		if (!genChars)
		    goto Done;
	    }
	}
	else
	    fontNode = NULL;

	/** Initialize the important _FSMakeFont() globals **/
	_FSInitGlobals (&tfRef, fontSpec->typeface, fontSpec->bodySize,
			fontSpec->resFactor, fontSpec->aspect,
			fontSpec->rotation, fontSpec->slant,
			&cmRef, fontSpec->charMap, fontSpec->flags);
	_FSAddCharacters = TRUE;

	/** Make the font **/
	rval = _FSMakeFont (&fontNode);

	if (newFont && (rval == FS_NO_ERROR))
	{
	    *font = fontNode;

	    if (_FSDaemon)
	    {
		/** Insert the font into the shared linked list **/
		_FSLinkSharedFont (fontNode);
	    }
	}
    }

Done:
    if (_FSSubset.list != NULL)
	_FSFree (_FSSubset.list);

    if (!shared)
	_FSAddUnsharedFont (fontNode);

    return (rval);
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSAppendFont (fontNode, rangeSpec)				*/
/*									*/
/*	  FontNode	**fontNode;	- font id			*/
/*	  RangeSpec	*rangeSpec;	- range specification		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine appends the specified range(s) of characters	*/
/*	  to the already existing font.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the memory cannot be allocated			*/
/*		- the characters cannot be generated			*/
/*									*/
/************************************************************************/

int FSAppendFont (fontNode, rangeSpec)
FontNode	**fontNode;
RangeSpec	*rangeSpec;
{
    int		rval, shared;
    FontInfo	*info;
    FontRegen	*regen;

    /** Lock the shared memory semaphore if necessary **/
    shared = _FSSharedFont (fontNode);

    if (shared && !_FSDaemon)
	rval = _FSDaemonAppendFont (fontNode, rangeSpec);
    else
    {
	_FSFontLockRegen (fontNode);
	regen = _FSFontRegen (fontNode);

	if (regen->howToRegen != CALL_NEWFONT)
	{
	    rval = FS_INVALID_FONT;
	}
	else
	{
	    _FSFontLockInfo (fontNode);
	    info = _FSFontInfo (fontNode);

	    /** Initialize fontware globals **/
	    _FSInitGlobals (&regen->sourceRef, NULL, info->bodySize,
			    info->resFactor, info->aspect, info->rotation,
			    info->slant, &regen->cmRef, (char *)info->charMap,
			    info->flags);
	    _FSAddCharacters = TRUE;

	    _FSSubset.list = NULL;
	    if (rangeSpec != NULL)
	    {
		_FSSubset.flag = TRUE;
		_FSMakeSubset (rangeSpec, &_FSSubset);
	    }
	    else
		_FSSubset.flag = FALSE;

	    rval = _FSMakeFont (&fontNode);

	    if (_FSSubset.list != NULL)
		_FSFree (_FSSubset.list);

	    _FSFontUnlockInfo (fontNode);
	}

	_FSFontUnlockRegen (fontNode);
    }

    return (rval);
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSAppendChar (fontNode, character)				*/
/*									*/
/*	  FontNode	**fontNode;	- font id			*/
/*	  CharId	character;	- character id			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine appends the specified character to the already	*/
/*	  existing font.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the memory cannot be allocated			*/
/*		- the character cannot be generated			*/
/*									*/
/************************************************************************/

int _FSAppendChar (FontNode **fontNode, CharId character)
{
    int		rval, shared;
    FontInfo	*info;
    FontRegen	*regen;

    /** Lock the shared memory semaphore if necessary **/
    shared = _FSSharedFont (fontNode);

    if (shared && !_FSDaemon)
	rval = _FSDaemonAppendChar (fontNode, character);
    else
    {
	_FSFontLockRegen (fontNode);
	regen = _FSFontRegen (fontNode);

	if (regen->howToRegen == CALL_READFONT)
	{
	    rval = FS_NO_ERROR;	/* not implemented yet */
	}
	else
	{
	    _FSFontLockInfo (fontNode);
	    info = _FSFontInfo (fontNode);

	    /** Initialize fontware globals **/
	    _FSInitGlobals (&regen->sourceRef, NULL, info->bodySize,
			    info->resFactor, info->aspect, info->rotation,
			    info->slant, &regen->cmRef, (char *)info->charMap,
			    info->flags);
	    _FSDemandFlag = FALSE;
	    _FSAddCharacters = FALSE;

	    _FSSubset.flag = TRUE;
	    _FSSubset.list = &character;
	    _FSSubset.count = 1;

	    rval = _FSMakeFont (&fontNode);

	    _FSFontUnlockInfo (fontNode);
	}

	_FSFontUnlockRegen (fontNode);
    }

    return (rval);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSInitGlobals (tfRef, tfName, bodySize, resFactor,	*/
/*			      aspect, rotation, slant, cmRef,		*/
/*			      cmName, flags)				*/
/*									*/
/*	  FileRef	*tfRef;		- typeface reference		*/
/*	  char		*tfName;	- typeface name			*/
/*	  Real64	bodySize;	- bodysize			*/
/*	  Real64	resFactor;	- apparent resolution factor	*/
/*	  Real64	aspect;		- aspect ratio			*/
/*	  Real64	rotation;	- rotation			*/
/*	  Real64	slant;		- slant				*/
/*	  FileRef	*cmRef;		- char map reference 		*/
/*	  char		*cmName;	- char map name			*/
/*	  Int32		flags;		- flags				*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine initializes the important fontware globals.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Zero.								*/
/*									*/
/************************************************************************/

int _FSInitGlobals (
    FileRef	*tfRef,
    char	*tfName,
    Real64	bodySize,
    Real64	resFactor,
    Real64	aspect,
    Real64	rotation,
    Real64	slant,
    FileRef	*cmRef,
    char	*cmName,
    Int32	flags)
{
    /** Initialize the pertinent _FSMakeFont() globals **/
    _FSTypefaceRef = tfRef;
    _FSTypefaceName = tfName;
    _FSLinesPerEm = bodySize;
    _FSResFactor = resFactor;
    _FSAspectRatio = aspect;
    _FSLinesPerEmX = _FSLinesPerEm * _FSAspectRatio;
    _FSRotAngle = rotation;
    _FSOblAngle = slant;
    _FSCharMapRef = cmRef;
    _FSCharMapName = cmName;
    _FSFlags = flags;

    _FSAllBitmaps = flags & FS_ALL_BITMAPS;
    _FSAllRLE = flags & FS_ALL_RLE;
    _FSBogusMode = flags & FS_NO_PLAID;
    _FSKerningFlag = !(flags & FS_NO_KERN);
    _FSOutlFlag = flags & FS_OUTLINE;
    _FSThicken = flags & FS_THICKEN;
    _FSOutl3D = flags & FS_3D;
    _FSDemandFlag = flags & FS_DEMAND;
    _FSIntWidthsFlag = flags & FS_INT_WIDTHS;

    _FSPointSizeY = _FSLinesPerEm * PTPERINCH / _FSResV;
    _FSPointSizeX = _FSLinesPerEmX * PTPERINCH / _FSResH;

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSMakeSubset (rangeSpec, subset)				*/
/*									*/
/*	  RangeSpec	*rangeSpec;	- range specification		*/
/*	  SubsetList	*subset;	- subset			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine creates an array of subset characters, which	*/
/*	  must contain the character index of every character that is	*/
/*	  to be generated by fontware.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  Zero.								*/
/*									*/
/************************************************************************/

int _FSMakeSubset (RangeSpec *rangeSpec, SubsetList *subset)
{
    int		numChar;
    char	*table, *tPtr, *tEnd;
    CharId	minChar, maxChar, chStart, chEnd, *sPtr;
    RangeSpec	*rPtr;

    subset->count = 0;
    if (rangeSpec[0].start == 0xFFFF)
    {
	subset->list = NULL;
	return (FS_NO_ERROR);
    }

    /** Find character range, so space can be allocated for a table **/
    minChar = 0xFFFF;
    maxChar = 0;
    for (rPtr = rangeSpec; rPtr->start != 0xFFFF; rPtr++)
    {
	minChar = MIN (minChar, rPtr->start);
	maxChar = MAX (maxChar, rPtr->start + rPtr->count);
    }

    numChar = maxChar - minChar;
    subset->list = (CharId *) _FSMalloc (numChar * sizeof (CharId));

    table = (char *) _FSAlloc (numChar * sizeof (char));
    memset (table, FALSE, numChar);

    /** Fill in the table **/
    for (rPtr = rangeSpec; rPtr->start != 0xFFFF; rPtr++)
    {
	chStart = rPtr->start - minChar;
	chEnd = chStart + rPtr->count;
	for (tPtr = &table[chStart], tEnd = &table[chEnd]; tPtr < tEnd; tPtr++)
	    *tPtr = TRUE;
    }

    /** Write the character values to the subset list **/
    sPtr = subset->list;
    for (tPtr = table, tEnd = &table[numChar]; tPtr < tEnd; tPtr++)
	if (*tPtr)
	    *sPtr++ = (CharId) (tPtr - table) + minChar;
    subset->count = sPtr - subset->list;

    _FSDealloc (table);

    subset->list = (CharId *) _FSRealloc (subset->list,
					  subset->count * sizeof (CharId));

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSDeleteFont (fontNode)					*/
/*									*/
/*	  FontNode	**fontNode;	- font id			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine deletes the specified font.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the specified font does not exist			*/
/*									*/
/************************************************************************/

int FSDeleteFont (FontNode **fontNode)
{
    int	i, owners, rval, shared, unmake;

    if (FSdebug) printf(">>> FSDeleteFont\n");
    
    rval = FS_NO_ERROR;

    shared = _FSSharedFont (fontNode);
    unmake = !shared;

    if (shared)
    {
	if (!_FSDaemon)
	    rval = _FSDaemonDeleteFont (fontNode);
	else
	{
	    /** Decrement the number of processes that own the font **/
	    owners = --(*fontNode)->ownerCount;
	    if (owners == 0)
	    {
		/** Leave the font untouched so that another process	**/
		/** (or next invocation of same process) can use it.	**/
		/** Since (owners == 0), the font purging routine may	**/
		/** delete it.  It will call FSDeleteFont again with	**/
		/** (owners == -1) (below).				**/
	    }
	    else if (owners == -1)	/* font is being purged */
	    {
		FontNode	***thisFont, **fontList;

		fontList = (FontNode **) _GCGetSharedValue (0);
		for (thisFont = &fontList; *thisFont != fontNode;
		     thisFont = &(**thisFont)->next);
		*thisFont = (**thisFont)->next;
		_GCSetSharedValue (0, (long) fontList);
		unmake = TRUE;
	    }
	}
    }
    else
    {
	/** Delete it from the list of unshared fonts **/
	for (i = 0; i < _FSListSize; i++)
	{
	    if (_FSFontList[i] == fontNode)
	    {
		_FSFontList[i] = NULL;
		_FSNumFonts--;
		break;
	    }
	}
    }

    if (unmake)
	rval = _FSUnmakeFont (fontNode);

    return (rval);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSAddUnsharedFont (fontNode)				*/
/*									*/
/*	  FontNode	**fontNode;	- new font to add to list	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine adds the specified font to the private list of	*/
/*	  unshared fonts.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _FSAddUnsharedFont (FontNode **fontNode)
{
    int		i, listSize;

    /** Add it to this process' private unshared font list **/
    _FSNumFonts++;
    listSize = ((_FSNumFonts + 15) / 16) * 16;
    if (listSize > _FSListSize)
    {
	_FSFontList = (FontNode ***) _FSRealloc
			(_FSFontList, listSize * sizeof (FontNode **));

	/** Clear the new part of the list **/
	for (i = _FSListSize; i < listSize; i++)
	    _FSFontList[i] = NULL;
	_FSListSize = listSize;
    }

    /** Find a place to put the font into the list **/
    for (i = 0; i < _FSListSize; i++)
    {
	if (_FSFontList[i] == NULL)
	{
	    _FSFontList[i] = fontNode;
	    break;
	}
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSSharedFont (fontNode)					*/
/*									*/
/*	  FontNode	**fontNode;	- font node			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns TRUE iff the specified font is a shared	*/
/*	  font.								*/
/*									*/
/*	RETURN VALUE							*/
/*	  TRUE	- fontNode is shared.					*/
/*	  FALSE	- fontNode is not shared.				*/
/*									*/
/************************************************************************/

int _FSSharedFont (FontNode **fontNode)
{
#ifdef SHFONT
    return (_GCSharedAddr (fontNode));
#else
    return (FALSE);
#endif
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSUpdateCharTime (fontNode, charNode)			*/
/*									*/
/*	  FontNode	**fontNode;	- font node			*/
/*	  FontCharNode	**charNode;	- char node			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine logs the specified character as needing its	*/
/*	  timestamp updated.  It may not be updated until some time	*/
/*	  later.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

int _FSUpdateCharTime (FontNode **fontNode, FontCharNode **charNode)
{
    static uInt32	lastTime = 0;

    if (_FSDaemon)
    {
	uInt32	timeStamp;

	if (*charNode != NULL)	/* make sure it has not been purged */
	{
	    timeStamp = _GCGetSharedValue (1);
	    (*charNode)->timeStamp = timeStamp++;
	    _GCSetSharedValue (1, timeStamp);
	}
    }
    else if (_FSSharedFont (fontNode))
    {
	uInt32	thisTime;

	_FSUsedCharList[_FSUsedChars++] = charNode;
	thisTime = time (NULL);
	if ((_FSUsedChars == FS_USED_CHAR_MAX) || (thisTime - lastTime > 1))
	{
	    _FSDaemonUsedChars (_FSUsedCharList, _FSUsedChars);
	    _FSUsedChars = 0;
	    lastTime = thisTime;
	}
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSLinkSharedFont (fontNode)				*/
/*									*/
/*	  FontNode	**fontNode;	- new font to add to list	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine adds the specified font to the linked list of	*/
/*	  shared fonts in shared memory.				*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

void _FSLinkSharedFont (FontNode **fontNode)
{
    FontNode	**fontList;

    (*fontNode)->ownerCount = 1;

    /** Add it to the font list in shared memory **/
    fontList = (FontNode **) _GCGetSharedValue (0);
    (*fontNode)->next = fontList;
    fontList = fontNode;
    _GCSetSharedValue (0, (long) fontList);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  static FontNode **_FSFindNFSharedFont (fontSpec, subset,	*/
/*						 tfRef, cmRef,		*/
/*						 genChars)		*/
/*									*/
/*	  FontSpec	*fontSpec;	- font specification		*/
/*	  SubsetList	*subset;	- subset of char map		*/
/*	  FileRef	*tfRef;		- typeface reference		*/
/*	  FileRef	*cmRef;		- char map reference		*/
/*	  int		*genChars;	- T: need to generate chars	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the shared font (if any) that matches	*/
/*	  the given font specification.					*/
/*	  If (*genChars == TRUE), need to generate some or all the	*/
/*	  characters in the font.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  Font id	- font that matches the specifications		*/
/*	  NULL		- no matching font was found			*/
/*									*/
/************************************************************************/

FontNode **_FSFindNFSharedFont (fontSpec, subset, tfRef, cmRef, genChars)
FontSpec	*fontSpec;
SubsetList	*subset;
FileRef		*tfRef;
FileRef		*cmRef;
int		*genChars;
{
#ifdef SHFONT

    FontNode	**thisFont;

    for (thisFont = (FontNode **) _GCGetSharedValue (0); thisFont != NULL;
	 thisFont = (*thisFont)->next)
    {
	if (_FSFontMatch (thisFont, fontSpec, subset, tfRef, cmRef, genChars))
	    return (thisFont);
    }
    return (NULL);

#endif
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  static _FSFontMatch (fontNode, fontSpec, subset, tfRef,	*/
/*			       cmRef, genChars)				*/
/*									*/
/*	  FontNode	**fontNode;	- font id			*/
/*	  FontSpec	*fontSpec;	- font specification		*/
/*	  SubsetList	*subset;	- subset of char map		*/
/*	  FileRef	*tfRef;		- typeface reference		*/
/*	  FileRef	*cmRef;		- char map reference		*/
/*	  int		*genChars;	- need to generate some chars	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns TRUE iff the specified font matches	*/
/*	  the given font specification.					*/
/*	  If fontNode is NULL, only the tags are compared.  Otherwise,	*/
/*	  the font specifications, char map references, and tags	*/
/*	  are all compared.						*/
/*	  If (*genChars == TRUE), need to generate some or all the	*/
/*	  characters in the font.					*/
/*									*/
/*	  Matching criteria:						*/
/*		- bodySize, resFactor, aspect, rotation, &		*/
/*		  slant must be within a certain tolerance		*/
/*		- fontSpec->flags must be equal except for		*/
/*		  the FS_DEMAND flag					*/
/*		- if subset->flag is TRUE:				*/
/*			- the subset of characters must be		*/
/*			  exactly the same				*/
/*		- the typeface tags must be equal			*/
/*		- the char map tags must be equal			*/
/*									*/
/*	RETURN VALUE							*/
/*	  TRUE	- it matches						*/
/*	  FALSE	- it doesn't match					*/
/*									*/
/************************************************************************/

int _FSFontMatch (FontNode **fontNode, FontSpec *fontSpec, SubsetList *subset,
        FileRef *tfRef, FileRef *cmRef, int *genChars)
{
#ifdef SHFONT

    int		match;
    double	bsDiff, rfDiff, asDiff, roDiff, slDiff;
    FontInfo	*info;
    FontRegen	*regen;

    _FSFontLockInfo (fontNode);
    info = _FSFontInfo (fontNode);
    _FSFontLockRegen (fontNode);
    regen = _FSFontRegen (fontNode);

    bsDiff = fontSpec->bodySize - info->bodySize;
    bsDiff = ABS (bsDiff);
    rfDiff = fontSpec->resFactor - info->resFactor;
    rfDiff = ABS (rfDiff);
    asDiff = fontSpec->aspect - info->aspect;
    asDiff = ABS (asDiff);
    roDiff = fontSpec->rotation - info->rotation;
    roDiff = ABS (roDiff);
    slDiff = fontSpec->slant - info->slant;
    slDiff = ABS (slDiff);

    match = (bsDiff < 0.05) && (rfDiff < 0.1) && (asDiff < 0.05) &&
	    (roDiff < 0.01) && (slDiff < 0.1) &&
	    (tfRef->tag == regen->sourceRef.tag) &&
	    (cmRef->tag == regen->cmRef.tag) &&
	    ((fontSpec->flags & ~FS_DEMAND) == (info->flags & ~FS_DEMAND));

    /** If the needed font's FS_DEMAND flag is not set, but the found	**/
    /** font's flag IS set, need to make sure all the chars are made.	**/
    *genChars = !(fontSpec->flags & FS_DEMAND) && (info->flags & FS_DEMAND);

    /** See if the specified subset exactly matches the chars in the font **/
    if (match && (subset->flag))
    {
	CharId		*cPtr, *cEnd, character;
	Boolean		*flags, *fPtr, *fEnd;	/* flag for each subset char */
	FontCharNode	**charNode;

	flags = (Boolean *) _FSAlloc (subset->count * sizeof (Boolean));
	memset (flags, 0, subset->count * sizeof (Boolean));

	cEnd = &subset->list[subset->count];
	for (charNode = _FSFontFirstChar (fontNode, &character);
	     charNode != NULL;
	     charNode = _FSFontNextChar (fontNode, &character))
	{
	    /** Find the character in the subset list and set its flag **/
	    for (cPtr = subset->list; cPtr < cEnd; cPtr++)
	    {
		if (*cPtr == character)
		{
		    flags[cPtr - subset->list] = TRUE;
		    break;
		}
	    }

	    if (cPtr == cEnd)	/* couldn't find the char in the subset? */
	    {
		match = FALSE;
		break;
	    }
	}

	if (match)
	{
	    /** Make sure all the subset characters were found in the font **/
	    fEnd = &flags[subset->count];
	    for (fPtr = flags; fPtr < fEnd; fPtr++)
		if (!*fPtr)
		{
		    match = FALSE;
		    break;
		}
	}

	_FSDealloc ((char *)flags);
    }

    _FSFontUnlockInfo (fontNode);
    _FSFontUnlockRegen (fontNode);
    return (match);

#endif
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSPurgeSome (size)						*/
/*									*/
/*	  int	size;	- how much memory to purge			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine attempts to purge the specified amount of memory	*/
/*	  from fonts existing in shared memory.				*/
/*									*/
/*	RETURN VALUE							*/
/*	  TRUE	- some memory was purged.				*/
/*	  FALSE	- can't purge any more memory.				*/
/*									*/
/************************************************************************/

#define	MAX_PURGE	16	/* how many chars to purge at a time */

int _FSPurgeSome (size)
int	size;		/* purge this much */
{
#ifdef SHFONT

    int			bmap, purged, pCount, total, purgeable, maxCount;
    int			maxTime, timeStamp, oldMaxTime, *tPtr, *tEnd, *bPtr;
    int			timeList[MAX_PURGE], bmapList[MAX_PURGE], filled, aTime;
    CharId		character;
    FontNode		**fontNode;
    FontCharNode	**charNode, **purgeList[MAX_PURGE];
    FontCharNode	***cPtr, ***cEnd, ***cStop;

    tEnd = &timeList[MAX_PURGE];

    purged = 0;
    filled = FALSE;
    do
    {
	pCount = total = maxTime = 0;
	tPtr = timeList;
	bPtr = bmapList;
	cPtr = purgeList;

	/** Look at every char in every font and find the 'MAX_PURGE'	**/
	/** oldest characters to purge					**/

	/** For every shared font **/
	for (fontNode = (FontNode **) _GCGetSharedValue (0);
	     fontNode != NULL; fontNode = (*fontNode)->next)
	{
	    bmap = _FSBmapFont (fontNode);

	    /** If font has no owners, it can be deleted **/
	    if ((*fontNode)->ownerCount == 0)
	    {
		FSDeleteFont (fontNode);
		purged = 1;
		goto Done;
	    }

	    /** For every char in each font **/
	    for (charNode = _FSFontFirstChar (fontNode, &character);
		 charNode != NULL;
		 charNode = _FSFontNextChar (fontNode, &character))
	    {
		total++;

		timeStamp = (*charNode)->timeStamp;
		if (bmap)
		    purgeable = _FSBmapPurgeableChar ((BmapCharNode **)charNode);
                else
		    purgeable = _FSOutlPurgeableChar ((OutlCharNode **)charNode);

		if (purgeable)
		{
		    if (!filled)
		    {
			/** Fill the array with the 1st 'MAX_PURGE' chars **/
			*tPtr++ = timeStamp;
			*bPtr++ = bmap;
			*cPtr++ = charNode;
			pCount++;
			maxTime = MAX (maxTime, timeStamp);
			filled = (pCount == MAX_PURGE);
		    }
		    else
		    {
			/** Replace a char in the array with a new char	**/
			/** if its time is less than the max time of	**/
			/** chars in the array				**/

			if (timeStamp < maxTime)
			{
			    oldMaxTime = maxTime;
			    maxTime = timeStamp;
			    for (tPtr = timeList, cPtr = purgeList,
				 bPtr = bmapList; tPtr < tEnd;
				 tPtr++, bPtr++, cPtr++)
			    {
				aTime = *tPtr;
				if (aTime == oldMaxTime)
				{
				    *tPtr = timeStamp;
				    *bPtr = bmap;
				    *cPtr = charNode;
				}
				else	/* recalculate new max time **/
				    maxTime = MAX (maxTime, aTime);
			    }
			}
		    }
		}
	    }
	}

	/** Don't purge more than 5% of total chars, if possible **/
	maxCount = MIN (pCount, total / 20);

	cEnd = &purgeList[maxCount];	/* try to stop here */
	cStop = &purgeList[pCount];	/* must stop here */

	for (cPtr = purgeList, bPtr = bmapList; (cPtr < cEnd) ||
	     ((purged < size) && (cPtr < cStop)); cPtr++, bPtr++)
	{
	    if (*bPtr)
		purged += _FSBmapPurgeChar ((BmapCharNode **)*cPtr);
	    else
		purged += _FSOutlPurgeChar ((OutlCharNode **)*cPtr);
	}
    } while ((purged < size) && (pCount > 0));

Done:
    return (purged > 0);

#endif
}
