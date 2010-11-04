/* $RCSfile: fsgtfnt.c $$Revision: 1.1 $$Date: 1990/07/02 16:06:45 $ Copyright (c) 1990 Intergraph Corp. */

#include <stdio.h>
#include <memory.h>
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSFont.h"
#include "../hfiles/FSNewFont.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSSize.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FSGenCache.h"


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSGetFontInfo (font, info)				*/
/*									*/
/*	  FontNode	**font;		- font id			*/
/*	  FontInfo	*info;		- information about the font	*/
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

int _FSGetFontInfo (FontNode **font, FontInfo *info)
{
    int	shared;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockInfo (font);
    memcpy (info, _FSFontInfo (font), sizeof (FontInfo));
    _FSFontUnlockInfo (font);

    _GCUnlockSem (shared);
    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSGetFontKernTable (font, kernTable, numKerns)		*/
/*									*/
/*	  FontNode	**font;		- font id			*/
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

int _FSGetFontKernTable (FontNode **font, FontKernPair **kernTable, int *numKerns)
{
    int	shared;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    _FSFontLockKernPairs (font);

    *numKerns = (*font)->numKernPair;
    if (kernTable != NULL)
    {
	if (*kernTable == NULL)
	    *kernTable = (FontKernPair *) _FSMalloc (*numKerns *
						     sizeof (FontKernPair));
	memcpy (*kernTable, _FSFontKernPairs (font),
		*numKerns * sizeof (FontKernPair));
    }

    _FSFontUnlockKernPairs (font);

    _GCUnlockSem (shared);
    return (FS_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  int _FSGetFontLigTable (font, ligTable, numLigs)		*/
/*									*/
/*	  FontNode	**font;		- font id			*/
/*	  FontLigature	**ligTable;	- table of ligatures		*/
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

int _FSGetFontLigTable (FontNode **font, FontLigature **ligTable, int *numLigs)
{
    int	shared;

    shared = _FSSharedFont (font);
    _GCLockSem (shared);

    *numLigs = 0;	/* there are no ligatures yet */
    if (ligTable != NULL)
    {
	if (*ligTable == NULL)
	    *ligTable = (FontLigature *) _FSMalloc (*numLigs *
						    sizeof (FontLigature));
    }

    _GCUnlockSem (shared);
    return (FS_NO_ERROR);
}
