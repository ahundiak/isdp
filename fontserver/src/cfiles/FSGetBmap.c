/* $RCSfile: fsgtbmp.c $$Revision: 1.1 $$Date: 1990/07/02 16:06:44 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include <stdio.h>
#include <memory.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSBmapCach.h"
#include "../hfiles/FSSize.h"
#include "../hfiles/FSAlloc.h"


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetBmapHeader (bmap, header)				*/
/*									*/
/*	  BmapNode	**bmap;		- bitmap font id		*/
/*	  BmapHeader	*header;	- contains general information	*/
/*					  about the font and locations	*/
/*					  of the other sections in the	*/
/*					  font.				*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns the header for the font.				*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the font ID is invalid.		*/
/*									*/
/************************************************************************/

int FSGetBmapHeader (bmap, header)
BmapNode	**bmap;
BmapHeader	*header;
{
    int	rval, shared;

    shared = _FSSharedFont (bmap);
    _GCLockSem (shared);

    rval = FS_NO_ERROR;
    if (_FSBmapFont (bmap))
    {
	_FSBmapLockHeader (bmap);
	memcpy (header, _FSBmapHeader (bmap), sizeof (BmapHeader));
	_FSBmapUnlockHeader (bmap);
    }
    else
	rval = FS_INVALID_FONT;

    _GCUnlockSem (shared);
    return (rval);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetBmapInfo (bmap, info)				*/
/*									*/
/*	  BmapNode	**bmap;		- bitmap font id		*/
/*	  BmapInfo	*info;		- information about the font	*/
/*					  as a whole.			*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns a structure containing information pertaining to the	*/
/*	  font as a whole, such as the bodysize and the kerning tracks.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the font ID is invalid.		*/
/*									*/
/************************************************************************/

int FSGetBmapInfo (bmap, info)
BmapNode	**bmap;
BmapInfo	*info;
{
    if (_FSBmapFont (bmap))
	return (_FSGetFontInfo (bmap, info));
    else
	return (FS_INVALID_FONT);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetBmapKernTable (bmap, kernTable, numKerns)		*/
/*									*/
/*	  BmapNode	**bmap;		- bitmap font id		*/
/*	  KernPair	**kernTable;	- list of the kerning pairs	*/
/*					  for the font.			*/
/*	  int		*numKerns;	- number of pairs in table	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns the kerning pair table, which consists of character	*/
/*	  pairs and their corresponding spacing adjustments.		*/
/*	  If kernTable is NULL, then no data is returned except for the	*/
/*	  number of kern pairs.  If *kernTable is NULL, then the memory	*/
/*	  for kernTable is allocated using malloc.  If *kernTable is	*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the kern table is simply copied to *kernTable.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the font ID is invalid.		*/
/*									*/
/************************************************************************/

int FSGetBmapKernTable (bmap, kernTable, numKerns)
BmapNode	**bmap;
BmapKernPair	**kernTable;
int		*numKerns;
{
    if (_FSBmapFont (bmap))
	return (_FSGetFontKernTable (bmap, kernTable, numKerns));
    else
	return (FS_INVALID_FONT);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetBmapLigTable (bmap, ligTable, numLigs)		*/
/*									*/
/*	  BmapNode	**bmap;		- bitmap font id		*/
/*	  BmapLigature	**ligTable;	- table of ligatures		*/
/*	  int		*numLigs;	- number of ligatures in table	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns a list of available ligature characters in the font.	*/
/*	  If ligTable is NULL, then no data is returned except for the	*/
/*	  number of ligatures.  If *ligTable is NULL, then the memory	*/
/*	  for ligTable is allocated using malloc.  If *ligTable is	*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the lig table is simply copied to *ligTable.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the font ID is invalid.		*/
/*									*/
/************************************************************************/

int FSGetBmapLigTable (bmap, ligTable, numLigs)
BmapNode	**bmap;
BmapLigature	**ligTable;
int		*numLigs;
{
    if (_FSBmapFont (bmap))
	return (_FSGetFontLigTable (bmap, ligTable, numLigs));
    else
	return (FS_INVALID_FONT);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetBmapCharInfo (bmap, character, info)			*/
/*									*/
/*	  BmapNode	**bmap;		- bitmap font id		*/
/*	  CharId	character;	- get information about THIS	*/
/*					  character.			*/
/*	  BmapCharInfo *info;		- structure that contains	*/
/*					  info on the character.	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns a structure which contains information pertaining	*/
/*	  to the given character, such as the set width or bitmap size.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if					*/
/*		- the font ID is invalid				*/
/*		- the character does not exist				*/
/*									*/
/************************************************************************/

int FSGetBmapCharInfo (bmap, character, charInfo)
BmapNode	**bmap;
CharId		character;
BmapCharInfo	*charInfo;
{
    int			rval, shared;
    BmapCharNode	**charNode;

    shared = _FSSharedFont (bmap);
    _GCLockSem (shared);

    rval = FS_NO_ERROR;
    if (_FSBmapFont (bmap))
    {
	if ((charNode = _FSBmapCharNode (bmap, &character, FALSE)) != NULL)
	{
	    _FSBmapGetChar (bmap, charNode, character);

	    _FSBmapLockCharInfo (charNode);
	    memcpy (charInfo, _FSBmapCharInfo (charNode),
		    sizeof (BmapCharInfo));
	    _FSBmapUnlockCharInfo (charNode);
	}
	else
	    rval = FS_INVALID_CHAR;
    }
    else
	rval = FS_INVALID_FONT;

    _GCUnlockSem (shared);
    return (rval);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetBmapAllCharInfo (bmap, charInfo, numChars)		*/
/*									*/
/*	  BmapNode	**bmap;		- bitmap font id		*/
/*	  BmapCharInfo	**charInfo;	- array that contains		*/
/*					  info on all characters.	*/
/*	  int		*numChars;	- number of chars in table	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns an array of structures which contain information	*/
/*	  pertaining to all the characters in the font.			*/
/*	  If charInfo is NULL, then no data is returned except for the	*/
/*	  number of characters.  If *charInfo is NULL, then the memory	*/
/*	  for charInfo is allocated using malloc.  If *charInfo is	*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the character info is simply copied to		*/
/*	  *charInfo.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if					*/
/*		- the font ID is invalid				*/
/*									*/
/************************************************************************/

int FSGetBmapAllCharInfo (bmap, charInfo, numChars)
BmapNode	**bmap;
BmapCharInfo	**charInfo;
int		*numChars;
{
    int			rval, shared;
    CharId		character;
    BmapCharNode	**thisChar;
    BmapCharInfo	*charTable;

    shared = _FSSharedFont (bmap);
    _GCLockSem (shared);

    rval = FS_NO_ERROR;
    if (_FSBmapFont (bmap))
    {
	*numChars = (*bmap)->numChar;
	if (charInfo != NULL)
	{
	    if (*charInfo == NULL)
		*charInfo = (BmapCharInfo *) _FSMalloc (*numChars *
							sizeof (BmapCharInfo));

	    for (thisChar = _FSBmapFirstChar (bmap, &character),
		 charTable = *charInfo; thisChar != NULL;
		 thisChar = _FSBmapNextChar (bmap, &character))
	    {
		_FSBmapGetChar (bmap, thisChar, character);

		_FSBmapLockCharInfo (thisChar);
		memcpy (charTable, _FSBmapCharInfo (thisChar),
			sizeof (BmapCharInfo));
		_FSBmapUnlockCharInfo (thisChar);
		charTable++;
	    }
	}
    }
    else
	rval = FS_INVALID_FONT;

    _GCUnlockSem (shared);
    return (rval);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetBmapBitmap (bmap, character, bitmap, size)		*/
/*									*/
/*	  BmapNode	**bmap;		- bitmap font id		*/
/*	  CharId	character;	- get bitmap for THIS character	*/
/*	  BmapBitmap	**bitmap;	- bitmap of the character	*/
/*	  int		*size;		- size of bitmap (bytes)	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns the bitmap of the character, in the format in which	*/
/*	  it is stored (bitmap, RLE8, RLE16).				*/
/*	  If bitmap is NULL, then no data is returned except for the	*/
/*	  size of the bitmap.  If *bitmap is NULL, then the memory	*/
/*	  for bitmap is allocated using malloc.  If *bitmap is		*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the bitmap data is simply copied to *bitmap.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if					*/
/*		- the font ID is invalid				*/
/*		- the character does not exist				*/
/*									*/
/************************************************************************/

int FSGetBmapBitmap (bmap, character, bitmap, size)
BmapNode	**bmap;
CharId		character;
BmapBitmap	**bitmap;
int		*size;
{
    int			rval, shared;
    BmapCharNode	**charNode;
    BmapCharInfo	*charInfo;

    shared = _FSSharedFont (bmap);
    _GCLockSem (shared);

    rval = FS_NO_ERROR;
    if (_FSBmapFont (bmap))
    {
	if ((charNode = _FSBmapCharNode (bmap, &character, FALSE)) != NULL)
	{
	    _FSBmapGetChar (bmap, charNode, character);

	    _FSBmapLockCharInfo (charNode);
	    _FSBmapLockCharBitmap (charNode);
	    charInfo = _FSBmapCharInfo (charNode);

	    *size = charInfo->nMap;
	    if (bitmap != NULL)
	    {
		if (*bitmap == NULL)
		    *bitmap = (BmapBitmap *) _FSMalloc (*size *
							sizeof (BmapBitmap));

		memcpy (*bitmap, _FSBmapCharBitmap (charNode),
			*size * sizeof (BmapBitmap));
	    }

	    _FSBmapUnlockCharInfo (charNode);
	    _FSBmapUnlockCharBitmap (charNode);
	}
	else
	    rval = FS_INVALID_CHAR;
    }
    else
	rval = FS_INVALID_FONT;

    _GCUnlockSem (shared);
    return (rval);
}
