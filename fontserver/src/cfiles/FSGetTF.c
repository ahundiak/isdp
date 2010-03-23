/* $RCSfile: fsgettf.c $$Revision: 1.4 $$Date: 1992/10/25 09:56:15 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include <sys/types.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSUtil.h"
#include "../hfiles/FSCharMap.h"
#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSTFCache.h"
#include "../hfiles/FSAlloc.h"


FILE	*_FSOpenTFFile ();


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetTFInfo (typeface, info)				*/
/*									*/
/*	  char		*typeface;	- typeface to interrogate	*/
/*	  TFInfo	*info;		- returned information		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine reads in the font header for the specified	*/
/*	  typeface.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the typeface is invalid.		*/
/*									*/
/************************************************************************/

int FSGetTFInfo (typeface, info)
char	*typeface;
TFInfo	*info;
{
    FILE		*file;
    TFBlockHeader	bHdr;

    if ((file = _FSOpenTFFile (typeface)) == NULL)
	return (FS_INVALID_TF_FILE);

    _FSCFTLoadInfo (file, &bHdr, info);	/* Get the information */

    fclose (file);

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetTFKernTable (typeface, charMap, threshold,		*/
/*				kernTable, numKerns)			*/
/*									*/
/*	  char		*typeface;	- typeface to interrogate	*/
/*	  char		*charMap;	- character mapping		*/
/*	  int		threshold;	- minimum kern you care		*/
/*					  about				*/
/*	  TFKernPair	**kernTable;	- contains all the kerning	*/
/*					  pairs for the typeface	*/
/*	  int		*numKerns;	- number of pairs in table	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Returns all of the kerning pairs whose kern is greater	*/
/*	  than or equal to threshold.					*/
/*	  If kernTable is NULL, then no data is returned except for the	*/
/*	  number of kern pairs.  If *kernTable is NULL, then the memory	*/
/*	  for kernTable is allocated using malloc.  If *kernTable is	*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the kern table is simply copied to *kernTable.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  A non-zero value is returned if typeface is invalid.		*/
/*									*/
/************************************************************************/

int FSGetTFKernTable (typeface, charMap, threshold, kernTable, numKerns)
char		*typeface;
char		*charMap;
int		threshold;
TFKernPair	**kernTable;
int		*numKerns;
{
    int			rval;
    FileRef		cmRef;
    FILE		*file;
    Char16		bsNbr1, bsNbr2;
    CharId		char1, char2;
    TFInfo		info;
    TFBlockHeader	infoHdr, kernHdr, dirHdr;
    TFKernPair		*kernPair, *kernPtr, *kernPtr2, *kernEnd;
    TFCharInfo		*charDir;
    CharMapStruct	*cmPtr;

    if ((file = _FSOpenTFFile (typeface)) == NULL)
	return (FS_INVALID_TF_FILE);

    /** Cache the char map **/
    if (((rval = _FSGetCharMapRef (charMap, &cmRef)) != FS_NO_ERROR) ||
	((rval = _FSGetCharMap (&cmRef, &cmPtr)) != FS_NO_ERROR))
	return (rval);

    _FSCFTLoadInfo (file, &infoHdr, &info);
    _FSCFTLoadKernPrs (file, &info, &kernHdr, &kernPair);

    if (kernHdr.nrRecs == 0)
	*numKerns = 0;
    else
    {
	_FSCFTLoadCharDirs (file, &info, &dirHdr, &charDir);

	/** Find the kerns that are greater than or equal to the threshold **/
	kernEnd = &kernPair[kernHdr.nrRecs];
	for (kernPtr = kernPtr2 = kernPair; kernPtr < kernEnd; kernPtr++)
	{
	    bsNbr1 = charDir[kernPtr->char1].charId;
	    bsNbr2 = charDir[kernPtr->char2].charId;

	    if ((ABS (kernPtr->adjustment) >= threshold) &&
		((char1 = _FSCharMapCharId (cmPtr, bsNbr1)) != (CharId) -1) &&
		((char2 = _FSCharMapCharId (cmPtr, bsNbr2)) != (CharId) -1))
	    {
		kernPtr2->char1 = char1;
		kernPtr2->char2 = char2;
		kernPtr2->adjustment = kernPtr->adjustment;
		kernPtr2++;
	    }
	}

	*numKerns = kernPtr2 - kernPair;

	_FSFree (charDir);	/* free mem. allocated by _FSCFTLoadCharDirs */
    }

    /** Reallocate, copy, or free the kern pairs depending on kernTable **/
    if (kernTable != NULL)
    {
	if (*kernTable == NULL)
	    *kernTable = (TFKernPair *) _FSRealloc (kernPair,
					*numKerns * sizeof (TFKernPair));
	else
	{
	    memcpy (*kernTable, kernPair, *numKerns * sizeof (TFKernPair));
	    _FSFree (kernPair);
	}
    }
    else
	_FSFree (kernPair);

    fclose (file);

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetTFKernTrack (typeface, kernTracks, numTracks)	*/
/*									*/
/*	  char		*typeface;	- typeface to interrogate	*/
/*	  TFKernTrack	**kernTracks;	- kerning track table		*/
/*	  int		*numTracks;	- number of tracks in table	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns all the kerning tracks available in the	*/
/*	  specified typeface.  The memory for kernTracks is allocated	*/
/*	  using malloc.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  A non-zero value is returned if typeface is invalid.		*/
/*									*/
/************************************************************************/

int FSGetTFKernTrack (typeface, kernTracks, numTracks)
char		*typeface;
TFKernTrack	**kernTracks;
int		*numTracks;
{
    FILE		*file;
    TFInfo		info;
    TFBlockHeader	bHdr;

    if ((file = _FSOpenTFFile (typeface)) == NULL)
	return (FS_INVALID_TF_FILE);

    _FSCFTLoadInfo (file, &bHdr, &info);

    if (kernTracks != NULL)
	_FSCFTLoadKernTrks (file, &info, &bHdr, kernTracks);
    else
	_FSLoadKernTrkHdr (file, &info, &bHdr);

    *numTracks = bHdr.nrRecs;

    fclose (file);

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetTFLigTable (typeface, charMap, ligTable, numLigs)	*/
/*									*/
/*	  char		*typeface;	- typeface to interrogate	*/
/*	  char		*charMap;	- character mapping		*/
/*	  TFLigature	**ligTable;	- ligature characters in	*/
/*					  the typeface.			*/
/*	  int		*numLigs;	- number of ligatures in table	*/
/*									*/
/*	DESCRIPTION							*/
/*	  There are no ligatures in the Bitstream typefaces yet,	*/
/*	  so this routine basically does nothing.			*/
/*	  If ligTable is NULL, then no data is returned except for the	*/
/*	  number of ligatures.  If *ligTable is NULL, then the memory	*/
/*	  for ligTable is allocated using malloc.  If *ligTable is	*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the lig table is simply copied to *ligTable.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  A non-zero value is returned if typeface is invalid.		*/
/*									*/
/************************************************************************/

/*ARGSUSED*/
int FSGetTFLigTable (typeface, charMap, ligTable, numLigs)
char		*typeface;
char		*charMap;
TFLigature	**ligTable;
int		*numLigs;
{
    FILE		*file;

    if ((file = _FSOpenTFFile (typeface)) == NULL)
	return (FS_INVALID_TF_FILE);

    if ((ligTable != NULL) && (*ligTable == NULL))
	*ligTable = (TFLigature *) _FSMalloc (0);

    *numLigs = 0;

    fclose (file);

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetTFCharDir (typeface, charMap, charDir, numChars)	*/
/*									*/
/*	  char		*typeface;	- typeface to interrogate	*/
/*	  char		*charMap;	- character mapping		*/
/*	  TFCharInfo	**charDir;	- table of character info	*/
/*	  int		*numChars;	- number of chars in table	*/
/*									*/
/*	DESCRIPTION							*/
/*	  Copies the list of character directory entries for the	*/
/*	  typeface into charDir[].					*/
/*	  If charDir is NULL, then no data is returned except for the	*/
/*	  number of characters.  If *charDir is NULL, then the memory	*/
/*	  for charDir is allocated using malloc.  If *charDir is	*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the char dir is simply copied to *charDir.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if and only if the typeface is invalid.		*/
/*									*/
/************************************************************************/

int FSGetTFCharDir (typeface, charMap, charDir, numChars)
char		*typeface;
char		*charMap;
TFCharInfo	**charDir;
int		*numChars;
{
    int			allChars, rval;
    FileRef		cmRef;
    FILE		*file;
    CharId		charId;
    TFInfo		info;
    TFBlockHeader	infoHdr, dirHdr;
    TFCharInfo		*charData, *charPtr, *charPtr2, *charEnd;
    CharMapStruct	*cmPtr;

    if ((file = _FSOpenTFFile (typeface)) == NULL)
	return (FS_INVALID_TF_FILE);

    /** Cache the char map **/
    if (((rval = _FSGetCharMapRef (charMap, &cmRef)) != FS_NO_ERROR) ||
	((rval = _FSGetCharMap (&cmRef, &cmPtr)) != FS_NO_ERROR))
	return (rval);

    _FSCFTLoadInfo (file, &infoHdr, &info);

    allChars = cmPtr->flags & FS_ALL_CHARS;
    if (allChars && (charDir == NULL))
	_FSLoadCharDirHdr (file, &info, &dirHdr);	/* for speed */
    else
	_FSCFTLoadCharDirs (file, &info, &dirHdr, &charData);

    if (allChars)	/* special case for speed */
	*numChars = dirHdr.nrRecs;
    else
    {
	charEnd = &charData[dirHdr.nrRecs];
	for (charPtr = charPtr2 = charData; charPtr < charEnd; charPtr++)
	{
	    charId = _FSCharMapCharId (cmPtr, charPtr->charId);
	    if (charId != (CharId) -1)
	    {
		charPtr2->setWidth = charPtr->setWidth;
		charPtr2->outlineOffs = charPtr->outlineOffs;
		charPtr2->charId = charId;
		charPtr2++;
	    }
	}

	*numChars = charPtr2 - charData;
    }

    /** Reallocate the memory allocated by _FSCFTLoadCharDirs **/
    if (charDir != NULL)
    {
	if (*charDir == NULL)
	    *charDir = (TFCharInfo *) _FSRealloc (charData,
					*numChars * sizeof (TFCharInfo));
	else
	{
	    memcpy (*charDir, charData, *numChars * sizeof (TFCharInfo));
	    _FSFree (charData);
	}
    }
    else if (!allChars)
	_FSFree (charData);

    fclose (file);

    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSGetTFOutlines (typeface, outlines, size)		*/
/*									*/
/*	  char		*typeface;	- typeface to interrogate	*/
/*	  TFOutlines	**outlines;	- outline data			*/
/*	  int		*size;		- size of outline data		*/
/*									*/
/*	DESCRIPTION							*/
/*	  Copies the outline data for the font.				*/
/*	  If outlines is NULL, then no data is returned except for the	*/
/*	  size of the data.  If *outlines is NULL, then the memory	*/
/*	  for outlines is allocated using malloc.  If *outlines is	*/
/*	  not NULL, it is assumed that the memory has already been	*/
/*	  allocated and the data is simply copied to *outlines.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  A non-zero value is returned if the typeface is invalid.	*/
/*									*/
/************************************************************************/

int FSGetTFOutlines (typeface, outlines, size)
char		*typeface;
TFOutlines	**outlines;
int		*size;
{
    FILE		*file;
    TFInfo		info;
    TFBlockHeader	bHdr;
    TFOutlines		*outlineData;

    if ((file = _FSOpenTFFile (typeface)) == NULL)
	return (FS_INVALID_TF_FILE);

    _FSCFTLoadInfo (file, &bHdr, &info);

    if (outlines != NULL)
    {
	_FSCFTLoadOutlData (file, &info, &bHdr, &outlineData);
	if (*outlines == NULL)
	    *outlines = outlineData;
	else
	{
	    memcpy (*outlines, outlineData, _FSOutlDataSize (&bHdr));
	    _FSFree (outlineData);
	}
    }
    else
	_FSLoadOutlDataHdr (file, &info, &bHdr);

    *size = _FSOutlDataSize (&bHdr);

    fclose (file);

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSGetTypefaces (typeface, count)				*/
/*									*/
/*	  char	**typeface[15];	- ptr to array ptr of typeface names	*/
/*	  int	*count;		- how many typefaces			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns all available typefaces in the current	*/
/*	  typeface search path.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  FS_NO_ERROR							*/
/*									*/
/************************************************************************/

typedef struct _FSName
{
    char		*name;
    struct _FSName	*next;
} FSName;

int FSGetTypefaces (typeface, count)
char	(**typeface)[15];
int	*count;
{
    int			defPathSearched;
    char		*pathPtr, *pathEnd, chr, (*tfPtr)[15], fullPath[512];
    FILE		*file;
    DIR			*dir;
    struct dirent	*dirEntry;
    FSName		*tfNames;	/* linked list of tf names	*/
    FSName		**tfNamePtr;	/* add next tf name here	*/
    static char		pathSep = ':';

    tfNames = NULL;
    tfNamePtr = &tfNames;

    pathPtr = getenv (_FSTFPathVar);
    for (defPathSearched = FALSE; !defPathSearched;)
    {
	if ((pathPtr == NULL) || (*pathPtr == '\0'))
	{
	    defPathSearched = TRUE;
	    pathPtr = _FSTFDefPath;
	}
	else if (*pathPtr == pathSep)
	    pathPtr++;

	if ((pathEnd = strchr (pathPtr, pathSep)) == NULL)
	    pathEnd = strchr (pathPtr, '\0');

	/** Prefix the path **/
	chr = *pathEnd;
	*pathEnd = '\0';

	if ((dir = opendir (pathPtr)) != NULL)
	{
	    /** Check every file in the directory **/
	    while ((dirEntry = readdir (dir)) != NULL)
	    {
		/** Construct the full path name of the file **/
		sprintf (fullPath, "%s/%s", pathPtr, dirEntry->d_name);
		if ((file = fopen (fullPath, "r")) != NULL)
		{
		    /** See if it is a typeface file **/
		    if (_FSTFCheck (file) == FS_NO_ERROR)
		    {
			int	length;
			char	*baseName;
			FSName	*newNamePtr;

			newNamePtr = (FSName *) _FSAlloc (sizeof (FSName));
			newNamePtr->next = *tfNamePtr;
			*tfNamePtr = newNamePtr;
			tfNamePtr = &newNamePtr->next;

			baseName = _FSGetBaseName (dirEntry->d_name,
						   _FSTFExtension, &length);
			newNamePtr->name = (char *) _FSAlloc (length + 1);
			memset (newNamePtr->name, 0, 15);
			strncpy (newNamePtr->name, baseName, MIN (length, 14));
		    }
		    fclose (file);
		}
	    }
	    closedir (dir);
	}
	*pathEnd = chr;
	pathPtr = pathEnd;
    }

    /** Count the typeface **/
    for (*count = 0, tfNamePtr = &tfNames; *tfNamePtr != NULL;
	 (*count)++, tfNamePtr = &(*tfNamePtr)->next);

    if (typeface != NULL)
    {
	/** Allocate the space for the array of typeface names **/
	if (*typeface == NULL)
	    *typeface = (char (*)[15]) _FSMalloc (*count * sizeof (char [15]));

	/** Copy the linked list into an array to be returned **/
	for (tfNamePtr = &tfNames, tfPtr = *typeface; *tfNamePtr != NULL;
	     tfNamePtr = &(*tfNamePtr)->next, tfPtr++)
	{
	    strcpy ((char *)tfPtr, (*tfNamePtr)->name);
	}
    }

    /** MUST deallocate names in reverse order (FSAlloc is used) (see below) **/
    _FSDeallocName (tfNames);

    return (FS_NO_ERROR);
}


_FSDeallocName (tfNamePtr)	/* recursively deallocate names */
FSName	*tfNamePtr;
{
    if (tfNamePtr->next != NULL)
	_FSDeallocName (tfNamePtr->next);

    _FSDealloc (tfNamePtr->name);
    _FSDealloc (tfNamePtr);
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FILE *_FSOpenTFFile (typeface)				*/
/*									*/
/*	  char	*typeface;	- Open a tf file.			*/
/*									*/
/*	DESCRIPTION							*/
/*	  Calls _FSFindFile to get the filename of the typeface, 	*/
/*	  and then opens that file.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  A file pointer to the typeface file.  If the typeface		*/
/*	  does not exist, this routine returns NULL.			*/
/*									*/
/************************************************************************/

FILE *_FSOpenTFFile (typeface)
char	*typeface;
{
    char	*name;

    name = _FSFindFile (typeface, _FSTFExtension, _FSTFPathVar, _FSTFDefPath);
    if (name != NULL)
	return (fopen (name, "r"));
    else
	return (NULL);
}
