/* $RCSfile: fsutil.c $$Revision: 1.2 $$Date: 1991/02/28 17:52:02 $ Copyright (c) 1990 Intergraph Corp. */


/*****************************************************************************
*									     *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*				Patent Pending				     *
*									     *
*	These programs are the sole property of Bitstream Inc. and	     *
*	  contain its proprietary and confidential information.		     *
*									     *
*	Modified extensively by Intergraph Corp., Huntsville, AL	     *
*									     *
*****************************************************************************/


/******************************** U T I L . C ********************************

    This module contains some utility functions.

 ****************************************************************************/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <malloc.h>
#include <string.h>
#include <memory.h>
#include <unistd.h>
#include <stdlib.h>
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSUtil.h"



Int32  _FSIPow (base, exponent)
Int32	base;
Int32	exponent;

/*  _FSIPow (base, exponent)
 *
 *  Arguments:
 *    base - base
 *    exponent  - exponent
 *  Returns:  the value of 'base' raised to the power 'exp'
 *    'base' and 'exp' must be long integers
 */
{
    Int32	j, k;

    for (k = 1, j = 0; j < exponent; j++)
	k *= base;
    return (k);
}



void _FSDateStamp (string)
Char8	*string;
{
    Char8		*asciiMonth;
    Char8		asciiDay[8];
    Int16		year, month, day, hour, minute, second;
    static Char8	months[12][3] = { "Jan", "Feb", "Mar", "Apr", "May",
					  "Jun", "Jul", "Aug", "Sep", "Oct",
					  "Nov", "Dec" };

    void	_FSIproTodaysDate();

    _FSIproTodaysDate (&year, &month, &day, &hour, &minute, &second);
    asciiMonth = months[month - 1];
    sprintf ((char *)asciiDay, "%.2d", day);
    sprintf ((char *)string, "%-2.2s %-3.3s %2d ",
	     asciiDay, asciiMonth, year - 1900);

    return;
}



/** _FSMalloc(), _FSRealloc() & _FSFree() are replacements for malloc(),
    realloc(), and free() due to the stupidity of libmalloc for returning
    NULL when 0 is passed in. **/

/** NOTE: If the MEM_DEBUG switch is turned on, malloc (3C) must be
    used.  Do not use malloc (3X)! **/

char *_FSMalloc (size)
uInt32	size;
{
    if (size == 0)
	size = 1;

#ifdef MEM_DEBUG
    printf ("%d+\n", DOUBLE (size));	/* this assumes aligned with double */
#endif

    return ((char *) malloc (size));
}


char *_FSRealloc (ptr, size)
char *ptr;
uInt32	size;
{
    if (size == 0)
	size = 1;

#ifdef MEM_DEBUG
    printf ("%d-  %d+\n", (char *) (*(((int *) ptr) - 2) & ~1) - ptr,
	    DOUBLE (size));
#endif

    return ((char *) realloc (ptr, size));
}


void _FSFree (ptr)
char *ptr;
{
#ifdef MEM_DEBUG
    printf ("%d-\n", (char *) (*(((int *) ptr) - 2) & ~1) - ptr);
#endif

    free (ptr);
    return;
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSMemCopy (to, from, count)					*/
/*									*/
/*	  char	*to;	- source					*/
/*	  char	*from;	- destination					*/
/*	  int	count;	- how many bytes to copy			*/
/*									*/
/*	DESCRIPTION							*/
/*	  _FSMemCopy is equivalent to memcpy except that overlapping of	*/
/*	  the source and destination regions IS allowed.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

int _FSMemCopy (char *to, char *from, int count)
{
    char	*endTo, *endFrom;

    endFrom = from + count;
    if (to < from)
    {
	while (from < endFrom)
	    *to++ = *from++;
    }
    else
    {
	endTo = to + count;
	while (--endFrom >= from)
	    *(--endTo) = *endFrom;
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  uInt32 _FSGetFileTag (fileName)				*/
/*									*/
/*	  char	*fileName;		- the file			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns a tag that is unique to the specified	*/
/*	  file.								*/
/*									*/
/*	NOTES								*/
/*	  The stat() system call cannot be used because it makes the	*/
/*	  stat structure in <fcntl.h> lose its cookies.			*/
/*									*/
/*	  Do not use this routine in a tight loop!  It takes time to	*/
/*	  do the system call.						*/
/*									*/
/*	RETURN VALUE							*/
/*	  A unique tag.  The upper 16 bits contain the device number,	*/
/*	  and the lower 16 bits contain the inode number.		*/
/*	  0 is returned if the file cannot be stat-ed.			*/
/*									*/
/************************************************************************/

uInt32 _FSGetFileTag (fileName)
char	*fileName;
{
    int		fileDesc;
    struct stat	fStat;

    if ((fileDesc = open (fileName, O_RDONLY)) == -1)
	return (0);
    else
    {
	fstat (fileDesc, &fStat);
	close (fileDesc);
	return ((((uInt32) fStat.st_dev) << 16) + fStat.st_ino);
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  char *_FSGetFileFullPath (fileName)				*/
/*									*/
/*	  char	*fileName;		- the file name			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine converts a file name to a full path name.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Full path name (statically declared).				*/
/*									*/
/************************************************************************/

char *_FSGetFileFullPath (fileName)
char	*fileName;
{
    char	*pwd;
    static char	pathName[512];

    /** Convert the file name into a full path if not already **/
    if (fileName[0] != '/')
    {
	pwd = getenv ("PWD");
	sprintf (pathName, "%s/%s", pwd, fileName);
    }
    else
	strcpy (pathName, fileName);

    return (pathName);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  char *_FSFindThisFile (fullName, ext)				*/
/*									*/
/*	  char	*fullName;	- full file name (with or without	*/
/*				  extension)				*/
/*	  char	*ext;		- file name extension (e.g., ".tf")	*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine attempts to find the specified file, which is	*/
/*	  assumed to be a full path name.  If it can't find it, it	*/
/*	  appends the specified extension and tries again.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  TRUE	- file was found					*/
/*	  FALSE	- file not found					*/
/*									*/
/************************************************************************/

static int _FSFindThisFile (fullName, ext)
char	*fullName;
char	*ext;
{
    char	*dot;

    if (!access (fullName, 04))
	return (TRUE);
    else
    {
	if (((dot = strrchr (fullName, '.')) == NULL) || strcmp (dot, ext))
	{
	    strcat (fullName, ext);
	    if (!access (fullName, 04))
		return (TRUE);
	}
    }
    return (FALSE);
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  char *_FSFindFile (fileName, ext, pathVar, defPath)		*/
/*									*/
/*	  char	*fileName;	- full or partial file name (with	*/
/*				  or without extension)			*/
/*	  char	*ext;		- file name extension (e.g., ".tf")	*/
/*	  char	*pathVar;	- name of search path env variable	*/
/*	  char	*defPath;	- default search path			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine attempts to find the specified file.  It uses	*/
/*	  the contents of the specified environment variable to obtain	*/
/*	  a list of paths to search.  It uses the specified default	*/
/*	  search path last.  These steps are performed in order to find	*/
/*	  the file:							*/
/*		1. If out of paths, return FALSE.			*/
/*		2. If fileName does not specify full path, prefix	*/
/*		   current path to fileName.				*/
/*		3. If file exists, goto 7.				*/
/*		4. If fileName already has extension, goto 1.		*/
/*		5. Append extension to fileName.			*/
/*		6. If file does not exist, goto 1.			*/
/*		7. Copy full file name and return TRUE.			*/
/*									*/
/*	RETURN VALUE							*/
/*	  Full file name (statically declared).				*/
/*									*/
/************************************************************************/

char *_FSFindFile (fileName, ext, pathVar, defPath)
char	*fileName;
char	*ext;
char	*pathVar;
char	*defPath;
{
    int		defPathSearched;
    char	*pathPtr, *pathEnd, chr;
    static char pathSep = ':';
    static char	fullName[512];

    /** Is it a full pathname? **/
    if (fileName[0] == '/')
    {
	strcpy (fullName, fileName);
	if (_FSFindThisFile (fullName, ext))
	    return (fullName);
	else
	    return (NULL);
    }

    pathPtr = getenv (pathVar);
    for (defPathSearched = FALSE; !defPathSearched;)
    {
	if ((pathPtr == NULL) || (*pathPtr == '\0'))
	{
	    defPathSearched = TRUE;
	    pathPtr = defPath;
	}
	else if (*pathPtr == pathSep)
	    pathPtr++;

	if ((pathEnd = strchr (pathPtr, pathSep)) == NULL)
	    pathEnd = strchr (pathPtr, '\0');

	/** Prefix the path **/
	chr = *pathEnd;
	*pathEnd = '\0';
	sprintf (fullName, "%s/%s", pathPtr, fileName);
	*pathEnd = chr;

	if (_FSFindThisFile (fullName, ext))
	    return (fullName);

	pathPtr = pathEnd;
    }
    return (NULL);
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  char *_FSGetBaseName (fileName, ext, length)			*/
/*									*/
/*	  char	*fileName;	- file name				*/
/*	  char	*ext;		- extension				*/
/*	  int	*length;	- length of base name			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine returns the base name of the specified file	*/
/*	  name, which is the file name without the extension.  It	*/
/*	  returns the pointer to the start of the base name, and its	*/
/*	  length is returned in *length.				*/
/*									*/
/*	RETURN VALUE							*/
/*	  pointer to base name						*/
/*									*/
/************************************************************************/

char *_FSGetBaseName (fileName, ext, length)
char	*fileName;
char	*ext;
int	*length;
{
    char	*slash, *dot;

    if ((slash = strrchr (fileName, '/')) == NULL)
	slash = fileName;
    else
	slash++;

    *length = strlen (slash);
    if (((dot = strrchr (fileName, '.')) != NULL) && !strcmp (dot, ext))
	*length -= strlen (ext);

    return (slash);
}



#ifndef	NDEBUG

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSAssertion (expr, file, line)				*/
/*									*/
/*	  char	*expr;		- expression				*/
/*	  char	*file;		- file name				*/
/*	  int	line;		- line number				*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine is used by the _FSAssert macro defined in	*/
/*	  FSDef.h.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None.								*/
/*									*/
/************************************************************************/

_FSAssertion (expr, file, line)
char	*expr;
char	*file;
int	line;
{
    printf ("Assertion failure: (%s) in \"%s\" at line %d\n", expr, file, line);
    kill (getpid (), 3);	/* make a core file */
}

#endif
