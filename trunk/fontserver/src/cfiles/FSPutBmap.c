/* $RCSfile: fsptbmp.c $$Revision: 1.2 $$Date: 1992/10/25 09:56:19 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include <memory.h>
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSBmapCach.h"
#include "../hfiles/FSSize.h"


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSPutBmapHeader (bmap, header)				*/
/*									*/
/*	  BmapId	bmap;		- bitmap font			*/
/*	  BmapHeader	*header;	- contains general information	*/
/*					  about the font and locations	*/
/*					  of the other sections in the	*/
/*					  font.				*/
/*									*/
/*	DESCRIPTION							*/
/*	  Replaces the header for the font.				*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the font ID is invalid.		*/
/*									*/
/************************************************************************/

int	FSPutBmapHeader (bmap, header)
BmapId		bmap;
BmapHeader	*header;
{
    int	rval;

    rval = FS_NO_ERROR;
    if (_FSBmapFont (bmap) && !_FSSharedFont (bmap))
    {
	_FSBmapLockHeader (bmap);
	memcpy (_FSBmapHeader (bmap), header, sizeof (BmapHeader));
	_FSBmapUnlockHeader (bmap);
    }
    else
	rval = FS_INVALID_FONT;

    return (rval);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSPutBmapInfo (bmap, info)				*/
/*									*/
/*	  BmapId	bmap;		- bitmap font			*/
/*	  BmapInfo	*info;		- information about the font	*/
/*					  as a whole.			*/
/*									*/
/*	DESCRIPTION							*/
/*	  Replaces the structure containing information pertaining to	*/
/*	  the font as a whole, such as the bodysize and the kerning	*/
/*	  tracks.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the font ID is invalid.		*/
/*									*/
/************************************************************************/

int	FSPutBmapInfo (bmap, info)
BmapId		bmap;
BmapInfo	*info;
{
    int	rval;

    rval = FS_NO_ERROR;
    if (_FSBmapFont (bmap) && !_FSSharedFont (bmap))
    {
	_FSBmapLockInfo (bmap);
	memcpy (_FSBmapInfo (bmap), info, sizeof (BmapInfo));
	_FSBmapUnlockInfo (bmap);
    }
    else
	rval = FS_INVALID_FONT;

    return (rval);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSPutBmapKernTable (bmap, kernTable, numPairs)		*/
/*									*/
/*	  BmapId	bmap;		- bitmap font			*/
/*	  KernPair	*kernTable;	- list of the kerning pairs	*/
/*					  for the font.			*/
/*	  int		numPairs;	- number of kerning pairs in	*/
/*					  table				*/
/*									*/
/*	DESCRIPTION							*/
/*	  Defines the entire kerning pair table, which consists of	*/
/*	  character pairs and their corresponding spacing adjustments.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the font ID is invalid.		*/
/*									*/
/************************************************************************/

int	FSPutBmapKernTable (bmap, kernTable, numPairs)
BmapId		bmap;
BmapKernPair	*kernTable;
int		numPairs;
{
    int			rval;
    BmapKernPair	*kernPtr;
    int			_FSComparePair ();

    rval = FS_NO_ERROR;
    if (_FSBmapFont (bmap) && !_FSSharedFont (bmap))
    {
	_FSBmapNewKernPairs (bmap, kernTable, numPairs);

	/** Make sure the table is sorted **/
	_FSBmapLockKernPairs (bmap);
	kernPtr = _FSBmapKernPairs (bmap);
	qsort (kernPtr, numPairs, sizeof (BmapKernPair), _FSComparePair);
	_FSBmapUnlockKernPairs (bmap);
    }
    else
	rval = FS_INVALID_FONT;

    return (rval);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSPutBmapLigTable (bmap, ligTable, numLigs)		*/
/*									*/
/*	  BmapId	bmap;		- bitmap font			*/
/*	  Ligature	*ligTable;	- table of ligatures		*/
/*	  int		numLigs;	- number of ligature in table	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Defines the entire ligature table for the font.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the font ID is invalid.		*/
/*									*/
/************************************************************************/

/*ARGSUSED*/
int	FSPutBmapLigTable (bmap, ligTable, numLigs)
BmapId		bmap;
BmapLigature	*ligTable;
int		numLigs;
{
    /** Not implemented yet **/

    return (FS_NO_ERROR);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSPutBmapCharInfo (bmap, character, info)			*/
/*									*/
/*	  BmapId	bmap;		- bitmap font			*/
/*	  CharId	character;	- get information about THIS	*/
/*					  character.			*/
/*	  BmapCharInfo *info;		- structure that contains	*/
/*					  info on the character.	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Replaces/adds/deletes a character directory entry.  If NULL	*/
/*	  is passed in charInfo, the specified character is deleted.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if					*/
/*		- the font ID is invalid				*/
/*									*/
/************************************************************************/

int	FSPutBmapCharInfo (bmap, character, charInfo)
BmapId		bmap;
CharId		character;
BmapCharInfo	*charInfo;
{
    int			rval;
    BmapCharNode	**charNode;
    BmapCharInfo	*newCharInfo;

    rval = FS_NO_ERROR;
    if (_FSBmapFont (bmap) && !_FSSharedFont (bmap))
    {
	if ((charNode = _FSBmapCharNode (bmap, &character, FALSE)) == NULL)
	{
	    if (charInfo != NULL)	/* create a new character */
	    {
		charNode = _FSBmapNewDirRec (bmap, character);
		_FSBmapLockCharInfo (charNode);
		newCharInfo = _FSBmapCharInfo (charNode);
		memcpy (newCharInfo, charInfo, sizeof (BmapCharInfo));
		_FSBmapUnlockCharInfo (charNode);
	    }
	}
	else	/* character already exists */
	{
	    if (charInfo == NULL)	/* delete the existing character */
	    {
		_FSBmapDeleteChar (bmap, character);
	    }
	    else	/* replace the existing char info */
	    {
		_FSBmapLockCharInfo (charNode);
		newCharInfo = _FSBmapCharInfo (charNode);
		memcpy (newCharInfo, charInfo, sizeof (BmapCharInfo));

		_FSBmapUnlockCharInfo (charNode);
	    }
	}
    }
    else
	rval = FS_INVALID_FONT;

    return (rval);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSPutBmapBitmap (bmap, character, bitmap, size)		*/
/*									*/
/*	  BmapId	bmap;		- bitmap font			*/
/*	  CharId	character;	- get bitmap for THIS character	*/
/*	  BmapBitmap	*bitmap;	- bitmap of the character	*/
/*	  int		size;		- size of bitmap		*/
/*									*/
/*	DESCRIPTION							*/
/*	  Replaces the bitmap data of the character.  A character	*/
/*	  directory entry for the character must already exist.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if					*/
/*		- the font ID is invalid				*/
/*		- the character does not exist				*/
/*									*/
/************************************************************************/

int	FSPutBmapBitmap (bmap, character, bitmap, size)
BmapId		bmap;
CharId		character;
BmapBitmap	*bitmap;
int		size;
{
    int			rval;
    BmapCharNode	**charNode;
    BmapCharInfo	*charInfo;
    BmapBitmap		**newBitmap;

    rval = FS_NO_ERROR;
    if (_FSBmapFont (bmap) && !_FSSharedFont (bmap))
    {
	if ((charNode = _FSBmapCharNode (bmap, &character, FALSE)) != NULL)
	{
	    _FSBmapGetChar (bmap, charNode, character);

	    _FSBmapLockCharInfo (charNode);
	    charInfo = _FSBmapCharInfo (charNode);
	    size = BMAP_BMAP_SIZE (size);
	    charInfo->nMap = size;
	    newBitmap = _FSBmapNewMap (charNode, BMAP_BMAP_SIZE (size));
	    memcpy (*newBitmap, bitmap, size);
	    _FSBmapUnlockCharInfo (charNode);
	}
	else
	    rval = FS_INVALID_CHAR;
    }
    else
	rval = FS_INVALID_FONT;

    return (rval);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSUpdateBmapFont (bmap)					*/
/*									*/
/*	  BmapId	bmap;		- bitmap font			*/
/*									*/
/*	DESCRIPTION							*/
/*	  Updates the character directory and header of a bitmap font	*/
/*	  after modifications have been made to it (e.g., characters	*/
/*	  and/or bitmaps have been added/deleted/changed).		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if					*/
/*		- the font ID is invalid				*/
/*									*/
/************************************************************************/

int	FSUpdateBmapFont (bmap)
BmapId	bmap;
{
    int	rval;

    rval = FS_NO_ERROR;
    if (_FSBmapFont (bmap) && !_FSSharedFont (bmap))
	_FSUpdateFont (bmap);
    else
	rval = FS_INVALID_FONT;

    return (rval);
}
