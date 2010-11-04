/* $RCSfile: fsalloc.c $$Revision: 1.1 $$Date: 1990/07/02 16:06:30 $ Copyright (c) 1990 Intergraph Corp. */

/*****************************************************************************
*									     *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*			       Patent Pending				     *
*									     *
*	 These programs are the sole property of Bitstream Inc. and	     *
*	   contain its proprietary and confidential information.	     *
*									     *
*	Modified extensively by Intergraph Corp., Huntsville, AL	     *
*									     *
*****************************************************************************/


/*************************** F S A L L O C . C *******************************

   Routines to allocate and deallocate memory 

 ****************************************************************************/

#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSAlloc.h"
#include "../hfiles/FS.h"


#define	ALLOCSIZE	16384

static	char	*allocBuf = NULL;	/* pointer to storage area */
static	char	*allocPtr;		/* next free position */
static	uInt32	mem = 0;		/* amount of free space */


Int _FSInitAlloc (void)
/* routine to initialize dynamic memory
 *
 * NOTE: this routine should only be called once at the start of the 
 * the program. it gets the maximum amount of memory that it will need
 * from the sustem (_FSMalloc).
 */
{
    void	_FSIproMemoryInit ();

    mem = ALLOCSIZE;
    allocBuf = _FSMalloc (mem);
    _FSAssert (allocBuf != NULL);

    allocPtr = allocBuf;	/* beginning of storage area */

    return (FS_NO_ERROR);
}


uInt32 _FSAllocCount ()  /* returns total available free space */
{
    return (mem);
}


void _FSFreeAlloc ()
{
    if (allocBuf)
	_FSFree (allocBuf);
}


char *_FSAlloc (uInt32 n)	/* return pointer to n bytes */
{
    n = DOUBLE (n);		/* assign on 64-bit boundaries */
    if (n <= mem)		/* if enough mem left */
    {
	allocPtr += n;		/* pt to next block*/
	mem -= n;
	return (allocPtr - n);	/* return ptr to block */
    }
    else	/* not enough memory in pool; _FSMalloc instead */
	return (_FSMalloc (n));
}


Int _FSDealloc (p)	/* free memory from p */
char	*p;		/* pointer to block of mem to be freed */
{
    if ((p < allocBuf) || (p > allocPtr))	/* Kosher ptr? */
    {
	if (p != NULL)
	    _FSFree (p);	/* must have been _FSMalloced, so free it */
	else
	    return (FALSE);
    }
    else
    {
	mem += (uInt32) (allocPtr - p);
	allocPtr = p;		/* recover space */
    }
    return (TRUE);
}
