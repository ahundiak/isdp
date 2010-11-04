/* $RCSfile: fsenter.c $$Revision: 1.1 $$Date: 1990/07/02 16:06:40 $ Copyright (c) 1990 Intergraph Corp. */

#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FS.h"
#include "../hfiles/FSGenCache.h"
#include "../hfiles/FSInterpro.h"
#include "../hfiles/FSTFCache.h"
#include "../hfiles/FSNewFont.h"
#include "../hfiles/FSCharMap.h"
#include "../hfiles/FSEnter.h"

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSEnter (flags)						*/
/*									*/
/*	  uInt32	flags;		- flags				*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine initializes the Font Server.  It must be called	*/
/*	  before any other FS routine is called.			*/
/*									*/
/*	  Bit 0 of the flags means I am the Font Server daemon.		*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- the required memory could not be allocated		*/
/*		- FSEnter has already been called			*/
/*									*/
/************************************************************************/

// igestartup.I flags = 0

int FSdebug = 0;

Int FSEnter (uInt32 flags)
{
  if (FSdebug) printf(">>> FSEnter %d\n",flags);

    _FSIproMemoryInit ();

    /** Initialize the temporary memory allocation stuff **/
    _FSInitAlloc ();

    /** Initialize the typeface cache **/
    _FSInitTF ();

    /** Initialize the character mappings **/
    _FSInitCharMap ();

    _FSEnterNF (flags);

    return (FS_NO_ERROR);
}




/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  FSExit ()							*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine uninitializes the Font Server.  It is the	*/
/*	  complement of FSEnter.  It may never need to be called.	*/
/*									*/
/*	RETURN VALUE							*/
/*	  Non-zero iff one of the following occur:			*/
/*		- FSEnter has not been called				*/
/*									*/
/************************************************************************/

Int FSExit ()
{
  if (FSdebug) printf(">>> FSExit\n");

    _FSExitNF ();

    /** Dispose of all the character mappings **/
    _FSDisposeCharMap ();

    /** Dispose of the typeface cache **/
    _FSDisposeTF ();

    /** Dispose of the temporary memory allocation stuff **/
    _FSFreeAlloc ();

    return (FS_NO_ERROR);
}
