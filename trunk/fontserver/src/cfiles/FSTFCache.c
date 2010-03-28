/* $RCSfile: fstfcch.c $$Revision: 1.2 $$Date: 1991/02/28 17:51:58 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/import.h"
#include <stdio.h>
#include <string.h>
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSUtil.h"
#include "../hfiles/FSTypeface.h"
#include "../hfiles/FSLoadTF.h"
#include "../hfiles/FSTFCache.h"


char	_FSTFPathVar[] = TF_PATH_VAR;	/* tf search path env variable	*/
char	_FSTFDefPath[] = TF_PATH;	/* tf default path		*/
char	_FSTFExtension[] = TF_EXT;	/* typeface file extension	*/

TFEntry	_FSTFCache[TF_CACHE_SIZE] = { 0 };

static uInt32	TFTime = 0;	/* typeface cache time stamp */


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSInitTF ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine initializes the typeface cache.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero.							*/
/*									*/
/************************************************************************/

int _FSInitTF (void)
{
    TFEntry	*cPtr, *cEnd;

    /** Initialize the char map cache **/
    cEnd = &_FSTFCache[TF_CACHE_SIZE];
    for (cPtr = _FSTFCache; cPtr < cEnd; cPtr++)
	cPtr->flags = 0;	/* empty cache slot (FS_TF_USED not set) */
    TFTime = 0;

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSDisposeTF ()						*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine frees the memory allocated for the typeface	*/
/*	  cache.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  FS_NO_ERROR							*/
/*									*/
/************************************************************************/

int _FSDisposeTF (void)
{
    TFEntry	*cPtr, *cEnd;

    /** Deallocate the typeface cache **/
    cEnd = &_FSTFCache[TF_CACHE_SIZE];
    for (cPtr = _FSTFCache; cPtr < cEnd; cPtr++)
    {
	if (cPtr->flags & FS_TF_USED)
	    _FSCFTUnload (&cPtr->typeface);
    }

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSGetTFRef (typeface, tfRef)				*/
/*									*/
/*	  char		*typeface;	- typeface file name		*/
/*	  FileRef	*tfRef;		- typeface reference		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns a reference structure for the specified	*/
/*	  typeface.  The reference can then be passed to _FSGetTF in	*/
/*	  order to load it into the cache.  The reference structure is	*/
/*	  defined as follows:						*/
/*									*/
/*	  	FileRef		description				*/
/*	  	----------	-----------				*/
/*		.fileName	full path of typeface file		*/
/*		.tag		typeface file tag			*/
/*									*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occurs:			*/
/*		- invalid typeface file					*/
/*									*/
/************************************************************************/

int _FSGetTFRef (char *typeface, FileRef *tfRef)
{
    char	*tfFile;

    /** Find the typeface file **/
    tfFile = _FSFindFile (typeface, _FSTFExtension, _FSTFPathVar, _FSTFDefPath);
    if (tfFile == NULL)
	return (FS_FILE_NOT_FOUND);

    tfRef->tag = _FSGetFileTag (tfFile);
    strcpy (tfRef->fileName, tfFile);

    return (FS_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSGetTF (tfRef, cachePtr)				*/
/*									*/
/*	  FileRef	*tfRef;		- typeface reference		*/
/*	  TFStruct	**cachePtr;	- typeface struct ptr		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine loads the specified typeface into the typeface	*/
/*	  cache, returning the TFStruct pointer.  tfRef is the typeface	*/
/*	  reference returned by _FSGetTFRef().				*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occurs:			*/
/*		- invalid typeface file					*/
/*									*/
/************************************************************************/

int _FSGetTF (FileRef *tfRef, TFStruct **cachePtr)
{
    int		rval;
    uInt32	minTime;
    FILE	*file;
    TFEntry	*cPtr, *cEnd, *minSlot=NULL;

    rval = FS_NO_ERROR;

    /** See if the typeface is already in the cache **/
    cEnd = &_FSTFCache[TF_CACHE_SIZE];
    for (cPtr = _FSTFCache; cPtr < cEnd; cPtr++)
	if ((cPtr->flags & FS_TF_USED) && (cPtr->tag == tfRef->tag))
	    goto Done;

    /** Look for least recently used char map to kick out **/
    minTime = 0xFFFFFFFF;
    for (cPtr = _FSTFCache; cPtr < cEnd; cPtr++)
    {
	if (!(cPtr->flags & FS_TF_USED))	/* empty cache slot? */
	    goto Found;

	if (cPtr->timeStamp < minTime)
	{
	    minTime = cPtr->timeStamp;
	    minSlot = cPtr;
	}
    }
    cPtr = minSlot;

    /** Release the old typeface **/
    _FSCFTUnload (&cPtr->typeface);

Found:
    /** Load the new typeface **/
    if ((file = fopen (tfRef->fileName, "r")) == NULL)
	return (FS_FILE_NOT_FOUND);

    rval = _FSCFTLoad (file, &cPtr->typeface);
    fclose (file);

    if (rval == FS_NO_ERROR)
    {
	cPtr->flags = FS_TF_USED;
	cPtr->tag = tfRef->tag;

Done:	cPtr->timeStamp = TFTime++;
	*cachePtr = &cPtr->typeface;
    }

    return (rval);
}
