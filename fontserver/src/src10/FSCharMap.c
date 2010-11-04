/* $RCSfile: fschrmp.c $$Revision: 1.3 $$Date: 1992/10/25 09:56:01 $ Copyright (c) 1990 Intergraph Corp. */

#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <string.h>
#include <ftw.h>
#include <memory.h>
#include <stdlib.h>
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSUtil.h"
#include "../hfiles/FSCharMap.h"

extern int FSdebug;

CharMapStruct	_FSCharMapCache[CM_CACHE_SIZE] = { 0 };
CharMapEntry	_FSCharMapTable[MAX_CHARMAP + 1] = { 0 };

char	_FSCMPathVar[] = CM_PATH_VAR;	/* cm search path env variable	*/
char	_FSCMDefPath[] = CM_PATH;	/* cm default path		*/
char	_FSCMExtension[] = CM_EXT;	/* char map file extension	*/

static int	CharMapTime;	/* current char map LRU time */

int _FSAllocCharMap ();


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSInitCharMap ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine initializes the character mapping table.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero.							*/
/*									*/
/************************************************************************/

int _FSInitCharMap (void)
{
    CharMapEntry	*tablePtr, *tableEnd;
    CharMapStruct	*cPtr, *cEnd;

    /** Initialize the char map id/file cross reference table **/
    tableEnd = &_FSCharMapTable[MAX_CHARMAP + 1];
    for (tablePtr = _FSCharMapTable; tablePtr < tableEnd; tablePtr++)
	tablePtr->refCount = 0;		/* this means empty table entry */

    /** Initialize the char map cache **/
    cEnd = &_FSCharMapCache[CM_CACHE_SIZE];
    for (cPtr = _FSCharMapCache; cPtr < cEnd; cPtr++)
	cPtr->flags = 0;	/* empty cache slot (FS_CM_USED not set) */
    CharMapTime = 0;

    ftw (CM_PATH, _FSAllocCharMap, 1);

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDisposeCharMap ()					*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine frees the memory allocated for the character	*/
/*	  mapping table.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  FS_NO_ERROR							*/
/*									*/
/************************************************************************/

int _FSDisposeCharMap (void)
{
    CharMapEntry	*tablePtr, *tableEnd;
    CharMapStruct	*cPtr, *cEnd;

    /** Deallocate the char map id/file xref table **/
    tableEnd = &_FSCharMapTable[MAX_CHARMAP + 1];
    for (tablePtr = _FSCharMapTable; tablePtr < tableEnd; tablePtr++)
    {
	if (tablePtr->fileName != NULL)
	    _FSFree (tablePtr->fileName);
    }

    /** Deallocate the char map cache **/
    cEnd = &_FSCharMapCache[CM_CACHE_SIZE];
    for (cPtr = _FSCharMapCache; cPtr < cEnd; cPtr++)
    {
	if (cPtr->flags & FS_CM_USED)
	    _FSFree (cPtr->charId);
    }

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSDefCharMap (charMapSpec, missingChar, flags, charMapId)	*/
/*									*/
/*	  CharMapSpec	*charMapSpec;	- character map specification	*/
/*	  Char16	missingChar;	- missing character (-1 = none)	*/
/*	  Int32		flags;		- flags				*/
/*	  CharMapId	*charMapId;	- character map id returned	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine defines the specified character mapping and	*/
/*	  returns a unique character map ID to be passed to FSNewFont.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if one of the following occurs:			*/
/*		- memory cannot be allocated in the char. map table	*/
/*									*/
/************************************************************************/

int FSDefCharMap (charMapSpec, missingChar, flags, charMapId)
CharMapSpec	*charMapSpec;
Char16		missingChar;
Int32		flags;
CharMapId	*charMapId;
{
    int		numChar, rval, cachePtr;
    CharMapSpec	*charMapPtr;

    /** How many characters in this char map? **/
    for (charMapPtr = charMapSpec;
	 charMapPtr->charId != (CharId) -1; charMapPtr++);
    numChar = charMapPtr - charMapSpec;

    /** Put it in the cache and lock it, since it has no file yet **/
    if ((rval = _FSCacheCharMap (charMapSpec, numChar, missingChar,
				 (Int32) (flags | FS_CM_LOCKED), 0,
				 (CharMapStruct **)&cachePtr)) != FS_NO_ERROR)
	return (rval);

    /** Add it to the char map id/file xref table **/
    return (_FSAddCharMapId (charMapId, (int) (flags & FS_CHARMAP_ID), NULL, (CharMapStruct *)cachePtr));
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSAllocCharMap (fileName, status, mode)			*/
/*									*/
/*	  char		*fileName;	- name of char map file		*/
/*	  struct stat	*status;	- file status structure		*/
/*	  int		mode;		- mode of file			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine is passed to Unix function ftw() for setting up	*/
/*	  the char map id/file xref table for all the char. map files	*/
/*	  in the standard char. map directory.				*/
/*									*/
/*	RETURN VALUE							*/
/*	  FS_NO_ERROR							*/
/*									*/
/************************************************************************/

/*ARGSUSED*/
int _FSAllocCharMap (fileName, status, mode)
char		*fileName;
struct stat	*status;	/* never referenced */
int		mode;
{
    CharMapId	charMapId;

    if (mode == FTW_F)		/* is it a normal readable file? */
	FSReadCharMapFile (fileName, &charMapId);

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSGetCharMapRef (charMap, cmRef)				*/
/*									*/
/*	  char		*charMap;	- char map file name or id	*/
/*	  FileRef	*cmRef;		- char map reference		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns a reference structure for the specified	*/
/*	  char map.  The reference can then be passed to		*/
/*	  _FSGetCharMap in order to load it into the cache.  The	*/
/*	  reference structure is defined as follows:			*/
/*									*/
/*	  type	FileRef		description				*/
/*	  ----	----------	-----------				*/
/*	   0	.fileName	full path of char map file		*/
/*		.tag		char map file tag			*/
/*	   1	.fileName	zero length string			*/
/*		.tag		char map id				*/
/*									*/
/*	  Notice that charMap may be either a file name or a char map	*/
/*	  id.								*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occurs:			*/
/*		- invalid char map file					*/
/*		- invalid char map id					*/
/*									*/
/************************************************************************/

int _FSGetCharMapRef (char *charMap, FileRef *cmRef)
{
    char		*cmFile;
    CharMapId		charMapId;
    CharMapEntry	*tablePtr;

    /** Using char map id? **/
    charMapId = (int) charMap;
    if ((charMapId >= -1) && (charMapId < MAX_CHARMAP))
    {
	tablePtr = &_FSCharMapTable[charMapId + 1];
	if (tablePtr->refCount > 0)		/* is it used? */
	{
	    if (tablePtr->fileName != NULL)	/* is it from a file? */
		charMap = tablePtr->fileName;
	    else
	    {
		cmRef->tag = charMapId;
		cmRef->fileName[0] = '\0';
		return (FS_NO_ERROR);
	    }
	}
	else
	    return (FS_INVALID_CHAR_MAP);
    }

    /** Find the char map file **/
    cmFile = _FSFindFile (charMap, _FSCMExtension, _FSCMPathVar, _FSCMDefPath);
    if (cmFile == NULL)
	return (FS_FILE_NOT_FOUND);

    cmRef->tag = _FSGetFileTag (cmFile);
    strcpy (cmRef->fileName, cmFile);

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSGetCharMap (cmRef, cachePtr)				*/
/*									*/
/*	  FileRef	*cmRef;		- char map reference		*/
/*	  CharMapStruct	**cachePtr;	- char map cache ptr		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine loads the specified char map into the char map	*/
/*	  cache, returning the cache pointer.  cmRef is the char map	*/
/*	  reference returned by _FSGetCharMapRef().			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occurs:			*/
/*		- invalid char map file					*/
/*									*/
/************************************************************************/

int _FSGetCharMap (FileRef *cmRef, CharMapStruct **cachePtr)
{
    int			rval;
    CharMapEntry	*tablePtr;

    rval = FS_NO_ERROR;

    /** Using char map id? **/
    if (cmRef->fileName[0] == '\0')
    {
	tablePtr = &_FSCharMapTable[cmRef->tag + 1];
	if (tablePtr->refCount > 0)	/* is it in use? */
	{
	    if (tablePtr->cachePtr == NULL)	/* must be from a file */
		rval = _FSCacheCharMapFile ((FileRef *)tablePtr->fileName, cachePtr);
	    else
		*cachePtr = tablePtr->cachePtr;
	}
	else
	    rval = FS_INVALID_CHAR_MAP;
    }
    else
	rval = _FSCacheCharMapFile (cmRef, cachePtr);

    return (rval);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSCacheCharMapFile (cmRef, cachePtr)			*/
/*									*/
/*	  FileRef	*cmRef;		- cm ref type 0 only		*/
/*	  CharMapStruct	**cachePtr;	- char map cache ptr		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine loads the specified char map file into the cache	*/
/*	  if it is not already there.  The cache pointer is returned.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occurs:			*/
/*		- the file cannot be read				*/
/*		- the file is not a char map file			*/
/*									*/
/************************************************************************/

int _FSCacheCharMapFile (cmRef, cachePtr)
FileRef		*cmRef;
CharMapStruct	**cachePtr;
{
    int			rval;
    FILE		*file;
    CharMapStruct	*cPtr, *cEnd;
    CharMapHeader	header;
    CharMapSpec		*charMapPtr;

    /** See if the char map is already in the cache **/
    cEnd = &_FSCharMapCache[CM_CACHE_SIZE];
    for (cPtr = _FSCharMapCache; cPtr < cEnd; cPtr++)
	if ((cPtr->flags & FS_CM_USED) && (cPtr->tag == cmRef->tag))
	{
	    cPtr->timeStamp = CharMapTime++;	/* update timestamp */
	    *cachePtr = cPtr;			/* return cache pointer */
	    return (FS_NO_ERROR);
	}

    /** Read in the char map **/
    if ((file = fopen (cmRef->fileName, "r")) == NULL)
	return (FS_FILE_NOT_FOUND);

    if ((_FSReadCharMapHeader (file, &header) == FS_NO_ERROR) &&
	(header.magic == CHARMAP_MAGIC))
    {
	charMapPtr = (CharMapSpec *) _FSAlloc
				(header.numChar * sizeof (CharMapSpec));

	if (_FSReadCharMapChars (file, charMapPtr, header.numChar) ==
	    FS_NO_ERROR)
	{
	    rval = _FSCacheCharMap (charMapPtr, header.numChar,
				    header.missingChar, (Int32) header.flags,
				    cmRef->tag, cachePtr);
	}
	else
	    rval = FS_INVALID_CM_FILE;

	_FSDealloc ((char *)charMapPtr);
    }
    else
	rval = FS_INVALID_CM_FILE;

    fclose (file);

    return (rval);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  static int _FS???Compare (char1, char2)			*/
/*									*/
/*	  CharMapSpec	char1;		- first character pair		*/
/*	  CharMapSpec	char2;		- second character pair		*/
/*									*/
/*	DESCRIPTION							*/
/*	  The following 2 routines return a value specifying the order	*/
/*	  of two CharMapSpec types in terms of the charId or the bsNbr	*/
/*	  field.  They are passed to the qsort routine.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  -1 if char1->??? <  char2->???				*/
/*	   1 if char1->??? >  char2->???				*/
/*	   0 if char1->??? == char2->???				*/
/*									*/
/************************************************************************/

static int  _FSCharIdCompare (char1, char2)
CharMapSpec	*char1;
CharMapSpec	*char2;
{
    if (char1->charId < char2->charId)
	return (-1);
    else if (char1->charId > char2->charId)
	return (1);
    else
	return (0);
}


static int  _FSBsNbrCompare (char1, char2)
CharMapSpec	*char1;
CharMapSpec	*char2;
{
    if (char1->bsNbr < char2->bsNbr)
	return (-1);
    else if (char1->bsNbr > char2->bsNbr)
	return (1);
    else
	return (0);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSCacheCharMap (charMapSpec, numChar,			*/
/*				      missingChar, flags,		*/
/*				      tag, cachePtr)			*/
/*									*/
/*	  CharMapSpec	charMapSpec[];	- char map specification	*/
/*	  int		numChar;	- number of characters in spec	*/
/*	  CharId	missingChar;	- missing character id		*/
/*	  Int32		flags;		- char map flags		*/
/*	  uInt32	tag;		- file tag			*/
/*	  CharMapStruct	**cachePtr;	- char map cache pointer	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine loads the specified char map into the cache.	*/
/*	  The cache pointer is returned in *cachePtr.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  FS_NO_ERROR							*/
/*									*/
/************************************************************************/

int _FSCacheCharMap (CharMapSpec *charMapSpec, int numChar, CharId missingChar,
    Int32 flags, uInt32 tag, CharMapStruct **cachePtr)
{
    uInt32		minTime;
    CharMapStruct	*cPtr, *cEnd, *minSlot = NULL;

    /** Look for least recently used char map to kick out **/
    minTime = 0xFFFFFFFF;
    cEnd = &_FSCharMapCache[CM_CACHE_SIZE];
    for (cPtr = _FSCharMapCache; cPtr < cEnd; cPtr++)
    {
	if (!(cPtr->flags & FS_CM_USED))	/* empty cache slot? */
	    goto Found;

	if (cPtr->timeStamp < minTime)
	{
	    minTime = cPtr->timeStamp;
	    minSlot = cPtr;
	}
    }
    cPtr = minSlot;

    /** Release the old char map **/
    _FSFree (cPtr->charId);

Found:
    /** Store the char map **/
    cPtr->numChar = numChar;
    cPtr->missingChar = missingChar;
    cPtr->flags = flags | FS_CM_USED;
    cPtr->tag = tag;
    cPtr->timeStamp = CharMapTime++;
    cPtr->charId = (CharMapSpec *) _FSMalloc
				(numChar * 2 * sizeof (CharMapSpec));
    cPtr->bsNbr = cPtr->charId + numChar;

    /** Copy the two tables and sort them **/
    memcpy (cPtr->charId, charMapSpec, numChar * sizeof (CharMapSpec));
    memcpy (cPtr->bsNbr, charMapSpec, numChar * sizeof (CharMapSpec));
    qsort (cPtr->charId, numChar, sizeof (CharMapSpec),
        (int (*) (const void *, const void *))_FSBsNbrCompare);
    qsort (cPtr->bsNbr, numChar, sizeof (CharMapSpec),
        (int (*) (const void *, const void *))_FSCharIdCompare);

    *cachePtr = cPtr;

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSReadCharMapFile (fileName, charMapId)			*/
/*									*/
/*	  char		*fileName;	- name of char map file		*/
/*	  CharMapId	*charMapId;	- char map id returned		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine reads the specified character mapping file	*/
/*	  and returns the char map id.  This routine is OBSOLETE.	*/
/*	  It does not load the char map data into the cache.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if one of the following occurs:			*/
/*		- bad character mapping file				*/
/*		- memory cannot be allocated in the char. map table	*/
/*									*/
/************************************************************************/

Int FSReadCharMapFile (fileName, charMapId)
char		*fileName;
CharMapId	*charMapId;
{
    int			rval;
    FileRef		cmRef;
    CharMapHeader	header;
    FILE		*file;

    if (FSdebug) printf(">>> FSReadCharMapFile %s\n",fileName);

    /** Get the full path name of the file **/
    if ((rval = _FSGetCharMapRef (fileName, &cmRef)) != FS_NO_ERROR)
	return (rval);

    if ((file = fopen (cmRef.fileName, "r")) == NULL)
	return (FS_FILE_NOT_FOUND);

    if ((_FSReadCharMapHeader (file, &header) == FS_NO_ERROR) &&
	(header.magic == CHARMAP_MAGIC))
    {
	/** Add the char map to the id/file xref table **/
	if ((rval = _FSAddCharMapId (&header.charMapId,
				     header.flags & FS_CHARMAP_ID,
				     cmRef.fileName, NULL)) == FS_NO_ERROR)
	    *charMapId = header.charMapId;
    }
    else
	rval = FS_INVALID_CM_FILE;

    fclose (file);

    return (rval);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSWriteCharMapFile (charMapId, fileName)			*/
/*									*/
/*	  CharMapId	*charMapId;	- char map id			*/
/*	  char		*fileName;	- name of char map file		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine writes the specified character mapping to a	*/
/*	  char map file.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if one of the following occurs:			*/
/*		- invalid character mapping				*/
/*		- the file cannot be written				*/
/*									*/
/************************************************************************/

Int FSWriteCharMapFile (charMapId, fileName)
CharMapId	charMapId;
char		*fileName;
{
    int			rval;
    char		*pathName;
    CharMapHeader	header;
    CharMapEntry	*tablePtr;
    CharMapStruct	*cPtr;
    FILE		*file;

    if ((charMapId < -1) || (charMapId >= MAX_CHARMAP))
	return (FS_INVALID_CHAR_MAP);

    tablePtr = &_FSCharMapTable[charMapId + 1];
    if (tablePtr->refCount == 0)	/* does it exist? */
	return (FS_INVALID_CHAR_MAP);

    if ((tablePtr->cachePtr == NULL) &&
	((rval = _FSGetCharMap ((FileRef*)(tablePtr->fileName),
			&tablePtr->cachePtr)) != FS_NO_ERROR))
	return (rval);

    pathName = _FSGetFileFullPath (fileName);
    if ((file = fopen (pathName, "w")) == NULL)
	return (FS_FILE_NOT_WRITTEN);

    cPtr = tablePtr->cachePtr;
    header.magic = CHARMAP_MAGIC;
    header.charMapId = charMapId;
    header.numChar = cPtr->numChar;
    header.missingChar = cPtr->missingChar;
    header.flags = cPtr->flags & 0xFFFF;	/* get rid of internal flags */
    memset (header.pad, 0, 14);

    if ((rval = _FSWriteCharMapHeader (file, &header)) == FS_NO_ERROR)
    {
	rval = _FSWriteCharMapChars (file, cPtr->charId, cPtr->numChar);

	if (rval == FS_NO_ERROR)
	{
	    /** Replace the old file name with the new one **/
	    if (tablePtr->fileName != NULL)
		_FSFree (tablePtr->fileName);
	    tablePtr->fileName = (char *) _FSMalloc (strlen (pathName) + 1);
	    strcpy (tablePtr->fileName, pathName);

	    cPtr->tag = _FSGetFileTag (pathName);
	    cPtr->flags &= ~FS_CM_LOCKED;	/* unlock it */
	}
    }

    fclose (file);
    return (rval);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int FSDeleteCharMap (charMapId)				*/
/*									*/
/*	  CharMapId	charMapId;	- char map id			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine deletes the specified character mapping from	*/
/*	  memory.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if one of the following occurs:			*/
/*		- invalid character mapping				*/
/*									*/
/************************************************************************/

int FSDeleteCharMap (charMapId)
CharMapId	charMapId;
{
    CharMapEntry	*tablePtr;

    if ((charMapId < -1) || (charMapId >= MAX_CHARMAP))
	return (FS_INVALID_CHAR_MAP);

    tablePtr = &_FSCharMapTable[charMapId + 1];
    if (tablePtr->refCount == 0)
	return (FS_INVALID_CHAR_MAP);

    /** Delete the char map only if refCount goes to zero **/
    if (--tablePtr->refCount == 0)
    {
	if (tablePtr->fileName != NULL)
	    _FSFree (tablePtr->fileName);
	tablePtr->fileName = NULL;

	if (tablePtr->cachePtr != NULL)
	    tablePtr->cachePtr->flags &= ~FS_CM_LOCKED;	/* unlock it */
    }

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSAddCharMapId (charMapId, useId, fileName,		*/
/*				      cachePtr)				*/
/*									*/
/*	  CharMapId	*charMapId;	- ptr to char map id		*/
/*	  int		useId;		- T: use specified id		*/
/*	  char		*fileName;	- name of char map file		*/
/*	  CharMapStruct	*cachePtr;	- char map cache ptr		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine adds the specified character mapping to the	*/
/*	  id/file xref table.  If the useId flag is not set, the first	*/
/*	  unoccupied char map slot is filled and the char map id is	*/
/*	  returned.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero if one of the following occurs:			*/
/*		- the specified character mapping id is invalid		*/
/*									*/
/************************************************************************/

int _FSAddCharMapId (charMapId, useId, fileName, cachePtr)
CharMapId	*charMapId;
int		useId;
char		*fileName;
CharMapStruct	*cachePtr;
{
    uInt32		tag =0;
    CharMapEntry	*tablePtr, *tableEnd;

    if (fileName != NULL)
	tag = _FSGetFileTag (fileName);

    if (useId)
    {
	/** Check validity of char map id **/
	if ((*charMapId < -1) || (*charMapId >= MAX_CHARMAP))
	    return (FS_INVALID_CHAR_MAP);

	tablePtr = &_FSCharMapTable[*charMapId + 1];
	if (tablePtr->refCount > 0)
	{
	    /** If this char map has already been added, increment ref count **/
	    if ((tag == tablePtr->tag) && (tag != 0))
		goto InitEntry;
	    else	/* same char map id for 2 different char maps */
		return (FS_INVALID_CHAR_MAP);
	}
    }
    else
    {
	/** Look for empty space in char map table **/
	tableEnd = &_FSCharMapTable[MAX_CHARMAP + 1];
	for (tablePtr = _FSCharMapTable; tablePtr < tableEnd; tablePtr++)
	    if (tablePtr->refCount == 0)	/* free entry? */
	    {
		*charMapId = tablePtr - _FSCharMapTable - 1;
		goto Allocate;
	    }

	return (FS_CANT_ALLOC);
    }

Allocate:
    /** Copy the file name if possible **/
    if (fileName != NULL)
    {
	tablePtr->fileName = (char *) _FSMalloc (strlen (fileName) + 1);
	strcpy (tablePtr->fileName, fileName);
    }
    else
	tablePtr->fileName = NULL;

InitEntry:
    tablePtr->refCount++;
    tablePtr->cachePtr = cachePtr;

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  Char16 _FSCharMapBsNbr (cmCachePtr, charId)			*/
/*									*/
/*	  CharMapStruct	*cmCachePtr;	- char map cache pointer	*/
/*	  CharId	charId;		- char id to search for		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the Bitstream number corresponding to	*/
/*	  the specified character id in the specified character map.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Bitstream number, or (Char16) -1 if it is not found.		*/
/*									*/
/************************************************************************/

static Char16 _FSCharMapBsNbrSearch (begin, end, charId)
CharMapSpec	*begin;
CharMapSpec	*end;
CharId		charId;
{
    CharMapSpec	*middle;

    /** Binary search the table sorted by charId **/
    middle = begin + (end - begin) / 2;
    if (charId == middle->charId)
	return (middle->bsNbr);
    else if (begin == middle)
	return ((Char16) -1);
    else if (charId < middle->charId)
	return (_FSCharMapBsNbrSearch (begin, middle, charId));
    else
	return (_FSCharMapBsNbrSearch (middle, end, charId));
}


Char16 _FSCharMapBsNbr (cmCachePtr, charId)
CharMapStruct	*cmCachePtr;
CharId		charId;
{
    if (cmCachePtr->flags & FS_ALL_CHARS)
	return ((Char16) charId);	/* one-to-one mapping */
    else
    {
	return (_FSCharMapBsNbrSearch (cmCachePtr->bsNbr,
				       &cmCachePtr->bsNbr[cmCachePtr->numChar],
				       charId));
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  Char16 _FSCharMapCharId (cmCachePtr, bsNbr)			*/
/*									*/
/*	  CharMapStruct	*cmCachePtr;	- char map cache pointer	*/
/*	  Char16	bsNbr;		- bs nbr to search for		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the character id corresponding to	*/
/*	  the specified Bitstream number in the specified character map.*/
/*									*/
/*	RETURN VALUE							*/
/*	  Bitstream number, or (Char16) -1 if it is not found.		*/
/*									*/
/************************************************************************/

static Char16 _FSCharMapCharIdSearch (begin, end, bsNbr)
CharMapSpec	*begin;
CharMapSpec	*end;
Char16		bsNbr;
{
    CharMapSpec	*middle;

    /** Binary search the table sorted by bsNbr **/
    middle = begin + (end - begin) / 2;
    if (bsNbr == middle->bsNbr)
	return (middle->charId);
    else if (begin == middle)
	return ((Char16) -1);
    else if (bsNbr < middle->bsNbr)
	return (_FSCharMapCharIdSearch (begin, middle, bsNbr));
    else
	return (_FSCharMapCharIdSearch (middle, end, bsNbr));
}


CharId _FSCharMapCharId (cmCachePtr, bsNbr)
CharMapStruct	*cmCachePtr;
Char16		bsNbr;
{
    if (cmCachePtr->flags & FS_ALL_CHARS)
	return ((CharId) bsNbr);	/* one-to-one mapping */
    else
    {
	return (_FSCharMapCharIdSearch (cmCachePtr->charId,
			&cmCachePtr->charId[cmCachePtr->numChar], bsNbr));
    }
}



/************************************************************************/
/*									*/
/*	FILE FORMAT FOR CHARACTER MAPPING FILES				*/
/*									*/
/*	OFFSET	SIZE		VALUE					*/
/*	0	4		magic number				*/
/*	4	4		character mapping ID			*/
/*	8	4		number of character pairs		*/
/*	12	2		missing character id			*/
/*	14	4		miscellaneous flags			*/
/*	18	14		reserved				*/
/*	32	4 * (# pairs)	character pairs (char ID, bs ID)	*/
/*									*/
/************************************************************************/


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  static int _FSReadCharMapHeader (file, header)		*/
/*	  static int _FSWriteCharMapHeader (file, header)		*/
/*									*/
/*	  FILE		*file;		- char. map file descriptor	*/
/*	  CharMapHeader	*header;	- char. map header		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine reads/writes the header of a character mapping	*/
/*	  file.								*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occurs:			*/
/*		- An error occurred while reading/writing the file	*/
/*									*/
/************************************************************************/

int _FSReadCharMapHeader (file, header)
FILE		*file;
CharMapHeader	*header;
{
    int numItems;
    
    numItems = fread (&(header->magic), sizeof (Int32), 1, file);
    numItems += fread (&(header->charMapId), sizeof (CharMapId), 1, file);
    numItems += fread (&(header->numChar), sizeof (Int32), 1, file);
    numItems += fread (&(header->missingChar), sizeof (Char16), 1, file);
    numItems += fread (&(header->flags), sizeof (Int32), 1, file);
    numItems += fread (&(header->pad[0]), sizeof (char), 14, file);
    
    if (numItems == 19)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}


int _FSWriteCharMapHeader (file, header)
FILE		*file;
CharMapHeader	*header;
{
    int numItems;
    
    numItems = fwrite (&(header->magic), sizeof (Int32), 1, file);
    numItems += fwrite (&(header->charMapId), sizeof (CharMapId), 1, file);
    numItems += fwrite (&(header->numChar), sizeof (Int32), 1, file);
    numItems += fwrite (&(header->missingChar), sizeof (Char16), 1, file);
    numItems += fwrite (&(header->flags), sizeof (Int32), 1, file);
    numItems += fwrite (&(header->pad[0]), sizeof (char), 14, file);
    
    if (numItems == 19)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  static int _FSReadCharMapChars (file, charMap, numChar)	*/
/*	  static int _FSWriteCharMapChars (file, charMap, numChar)	*/
/*									*/
/*	  FILE		*file;		- char. map file descriptor	*/
/*	  CharMapSpec	*charMap;	- char. map			*/
/*	  int		numChar;	- number of characters in map	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine reads/writes the character pairs of a character	*/
/*	  mapping file.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occurs:			*/
/*		- An error occurred while reading/writing the file	*/
/*									*/
/************************************************************************/

int _FSReadCharMapChars (file, charMap, numChar)
FILE		*file;
CharMapSpec	*charMap;
int		numChar;
{
    int numItems;
    
    /** Just read it in, since CharMapSpec structs are already packed **/
    numItems = fread (charMap, sizeof (CharMapSpec), numChar, file);
		      
    if (numItems == numChar)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}


int _FSWriteCharMapChars (file, charMap, numChar)
FILE		*file;
CharMapSpec	*charMap;
int		numChar;
{
    int numItems;
    
    /** Just write it out, since CharMapSpec structs are already packed **/
    numItems = fwrite (charMap, sizeof (CharMapSpec), numChar, file);
		      
    if (numItems == numChar)
	return (FS_NO_ERROR);
    else
	return (FS_ERROR);
}
