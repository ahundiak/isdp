/* $RCSfile: fsgttl.c $$Revision: 1.1 $$Date: 1990/07/02 16:06:46 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include <stdio.h>
#include <memory.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSOutl.h"
#include "../hfiles/FSOutlCach.h"
#include "../hfiles/FSSize.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSGetFont.h"
#include "../hfiles/FSNewFont.h"
#include "../hfiles/FSGenCache.h"


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetOutlHeader (outl, header)				*/
/*									*/
/*	  OutlNode	**outl;		- outline font id		*/
/*	  OutlHeader	*header;	- contains general information	*/
/*					  about the font and locations	*/
/*					  of the other sections in the	*/
/*					  font.				*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns the header for the outline font.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the font ID is invalid.		*/
/*									*/
/************************************************************************/

int FSGetOutlHeader (outl, header)
OutlNode	**outl;
OutlHeader	*header;
{
    int	rval, shared;

    shared = _FSSharedFont (outl);
    _GCLockSem (shared);

    rval = FS_NO_ERROR;
    if (_FSOutlFont (outl))
    {
	_FSOutlLockHeader (outl);
	memcpy (header, _FSOutlHeader (outl), sizeof (OutlHeader));
	_FSOutlUnlockHeader (outl);
    }
    else
	rval = FS_INVALID_FONT;

    _GCUnlockSem (shared);
    return (rval);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetOutlInfo (outl, info)				*/
/*									*/
/*	  OutlNode	**outl;		- outline font id		*/
/*	  OutlInfo	*info;		- information about the font	*/
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

int FSGetOutlInfo (outl, info)
OutlNode	**outl;
OutlInfo	*info;
{
    if (_FSOutlFont (outl))
	return (_FSGetFontInfo (outl, info));
    else
	return (FS_INVALID_FONT);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetOutlKernTable (outl, kernTable, numKerns)		*/
/*									*/
/*	  OutlNode	**outl;		- outline font id		*/
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

int FSGetOutlKernTable (outl, kernTable, numKerns)
OutlNode	**outl;
OutlKernPair	**kernTable;
int		*numKerns;
{
    if (_FSOutlFont (outl))
	return (_FSGetFontKernTable (outl, kernTable, numKerns));
    else
	return (FS_INVALID_FONT);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetOutlLigTable (outl, ligTable, numLigs)		*/
/*									*/
/*	  OutlNode	**outl;		- outline font id		*/
/*	  Ligature	**ligTable;	- table of ligatures		*/
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

int FSGetOutlLigTable (outl, ligTable, numLigs)
OutlNode	**outl;
OutlLigature	**ligTable;
int		*numLigs;
{
    if (_FSOutlFont (outl))
	return (_FSGetFontLigTable (outl, ligTable, numLigs));
    else
	return (FS_INVALID_FONT);
}

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetOutlCharInfo (outl, character, info)			*/
/*									*/
/*	  OutlNode	**outl;		- outline font id		*/
/*	  CharId	character;	- get information about THIS	*/
/*					  character.			*/
/*	  OutlCharInfo *info;		- structure that contains	*/
/*					  info on the character		*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns a structure which contains information pertaining	*/
/*	  to the given character.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if					*/
/*		- the font ID is invalid				*/
/*		- the character does not exist				*/
/*									*/
/************************************************************************/

int FSGetOutlCharInfo (outl, character, charInfo)
OutlNode	**outl;
CharId		character;
OutlCharInfo	*charInfo;
{
    int			rval, shared;
    OutlCharNode	**charNode;

    shared = _FSSharedFont (outl);
    _GCLockSem (shared);

    rval = FS_NO_ERROR;
    if (_FSOutlFont (outl))
    {
	if ((charNode = _FSOutlCharNode (outl, &character, FALSE)) != NULL)
	{
	    _FSOutlGetChar (outl, charNode, character);

	    _FSOutlLockCharInfo (charNode);
	    memcpy (charInfo, _FSOutlCharInfo (charNode),
		    sizeof (OutlCharInfo));
	    _FSOutlUnlockCharInfo (charNode);
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
/*	  int FSGetOutlAllCharInfo (outl, info, numChars)		*/
/*									*/
/*	  OutlNode	**outl;		- outline font id		*/
/*	  OutlCharInfo	**charInfo;	- array that contains		*/
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

int FSGetOutlAllCharInfo (outl, charInfo, numChars)
OutlNode	**outl;
OutlCharInfo	**charInfo;
int		*numChars;
{
    int			rval, shared;
    CharId		character;
    OutlCharNode	**thisChar;
    OutlCharInfo	*charTable;

    shared = _FSSharedFont (outl);
    _GCLockSem (shared);

    rval = FS_NO_ERROR;
    if (_FSOutlFont (outl))
    {
	*numChars = (*outl)->numChar;
	if (charInfo != NULL)
	{
	    if (*charInfo == NULL)
		*charInfo = (OutlCharInfo *) _FSMalloc (*numChars *
							sizeof (OutlCharInfo));

	    for (thisChar = _FSOutlFirstChar (outl, &character),
		 charTable = *charInfo; thisChar != NULL;
		 thisChar = _FSOutlNextChar (outl, &character))
	    {
		_FSOutlGetChar (outl, thisChar, character);

		_FSOutlLockCharInfo (thisChar);
		memcpy (charTable, _FSOutlCharInfo (thisChar),
			sizeof (OutlCharInfo));
		_FSOutlUnlockCharInfo (thisChar);
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
/*	  int FSGetOutlPolySizes (outl, character, pSize, numPSizes)	*/
/*									*/
/*	  OutlNode	**outl;		- outline font id		*/
/*	  CharId	character;	- get pSizes for THIS character	*/
/*	  OutlPolySize	**pSize;	- poly size array for the char	*/
/*	  int		*numPSizes;	- number of poly sizes		*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns the polygon size array for the character.		*/
/*	  If pSize is NULL, then no data is returned except for the	*/
/*	  number of poly sizes.  If *pSize is NULL, then the memory	*/
/*	  for pSize is allocated using malloc.  If *pSize is		*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the poly size data is simply copied to *pSize.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if					*/
/*		- the font ID is invalid				*/
/*		- the character does not exist				*/
/*									*/
/************************************************************************/

int FSGetOutlPolySizes (outl, character, pSize, numPSizes)
OutlNode	**outl;
CharId		character;
OutlPolySize	**pSize;
int		*numPSizes;
{
    int			rval, shared;
    OutlCharNode	**charNode;
    OutlCharInfo	*charInfo;

    shared = _FSSharedFont (outl);
    _GCLockSem (shared);

    rval = FS_NO_ERROR;
    if (_FSOutlFont (outl))
    {
	if ((charNode = _FSOutlCharNode (outl, &character, FALSE)) != NULL)
	{
	    _FSOutlGetChar (outl, charNode, character);

	    _FSOutlLockCharInfo (charNode);
	    _FSOutlLockCharPSize (charNode);
	    charInfo = _FSOutlCharInfo (charNode);

	    *numPSizes = charInfo->nPSize;
	    if (pSize != NULL)
	    {
		if (*pSize == NULL)
		    *pSize = (OutlPolySize *) _FSMalloc (*numPSizes *
							 sizeof (OutlPolySize));

		memcpy (*pSize, _FSOutlCharPSize (charNode),
			*numPSizes * sizeof (OutlPolySize));
	    }

	    _FSOutlUnlockCharInfo (charNode);
	    _FSOutlUnlockCharPSize (charNode);
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
/*	  int FSGetOutlVertices (outl, character, vert, numVerts)	*/
/*									*/
/*	  OutlNode	**outl;		- outline font id		*/
/*	  CharId	character;	- get vertices for THIS char	*/
/*	  OutlVertex	**vert;		- vertices for the character	*/
/*	  int		*numVerts;	- number of vertices in table	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns the vertices for the character.			*/
/*	  If vert is NULL, then no data is returned except for the	*/
/*	  number of vertices.  If *vert is NULL, then the memory	*/
/*	  for vert is allocated using malloc.  If *vert is		*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the vertex data is simply copied to *vert.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if					*/
/*		- the font ID is invalid				*/
/*		- the character does not exist				*/
/*									*/
/************************************************************************/

int FSGetOutlVertices (outl, character, vert, numVerts)
OutlNode	**outl;
CharId		character;
OutlVertex	**vert;
int		*numVerts;
{
    int			rval, shared;
    OutlCharNode	**charNode;
    OutlCharInfo	*charInfo;

    shared = _FSSharedFont (outl);
    _GCLockSem (shared);

    rval = FS_NO_ERROR;
    if (_FSOutlFont (outl))
    {
	if ((charNode = _FSOutlCharNode (outl, &character, FALSE)) != NULL)
	{
	    _FSOutlGetChar (outl, charNode, character);

	    _FSOutlLockCharInfo (charNode);
	    _FSOutlLockCharVert (charNode);
	    charInfo = _FSOutlCharInfo (charNode);

	    *numVerts = charInfo->nVert;
	    if (vert != NULL)
	    {
		if (*vert == NULL)
		    *vert = (OutlVertex *) _FSMalloc (*numVerts *
						      sizeof (OutlVertex));

		memcpy (*vert, _FSOutlCharVert (charNode),
			*numVerts * sizeof (OutlVertex));
	    }

	    _FSOutlUnlockCharInfo (charNode);
	    _FSOutlUnlockCharVert (charNode);
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
/*	  int FSGetOutl3DVertices (outl, character, vert, numVerts)	*/
/*									*/
/*	  OutlNode	**outl;		- outline font id		*/
/*	  CharId	character;	- get vertices for THIS char	*/
/*	  Outl3DVertex	**vert;		- 3D vertices for the character	*/
/*	  int		*numVerts;	- number of vertices in table	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns the 3D vertices for the character.			*/
/*	  If vert is NULL, then no data is returned except for the	*/
/*	  number of vertices.  If *vert is NULL, then the memory	*/
/*	  for vert is allocated using malloc.  If *vert is		*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the vertex data is simply copied to *vert.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if					*/
/*		- the font ID is invalid				*/
/*		- the character does not exist				*/
/*									*/
/************************************************************************/

int FSGetOutl3DVertices (outl, character, vert, numVerts)
OutlNode	**outl;
CharId		character;
Outl3DVertex	**vert;
int		*numVerts;
{
    int			rval, shared;
    OutlCharNode	**charNode;
    OutlCharInfo	*charInfo;

    shared = _FSSharedFont (outl);
    _GCLockSem (shared);

    rval = FS_NO_ERROR;
    if (_FSOutlFont (outl))
    {
	if ((charNode = _FSOutlCharNode (outl, &character, FALSE)) != NULL)
	{
	    _FSOutlGetChar (outl, charNode, character);

	    _FSOutlLockCharInfo (charNode);
	    _FSOutlLockCharVert (charNode);
	    charInfo = _FSOutlCharInfo (charNode);

	    *numVerts = charInfo->nVert;
	    if (vert != NULL)
	    {
		if (*vert == NULL)
		    *vert = (Outl3DVertex *) _FSMalloc (*numVerts *
							sizeof (Outl3DVertex));

		memcpy (*vert, _FSOutlCharVert (charNode),
			*numVerts * sizeof (Outl3DVertex));
	    }

	    _FSOutlUnlockCharInfo (charNode);
	    _FSOutlUnlockCharVert (charNode);
	}
	else
	    rval = FS_INVALID_CHAR;
    }
    else
	rval = FS_INVALID_FONT;

    _GCUnlockSem (shared);
    return (rval);
}
