/* $RCSfile: fsalloc.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:01 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _ALLOC
#define	_ALLOC	0

#include "FSTypes.h"


/** Substitutes for malloc, realloc, & free **/
extern	char	*_FSMalloc ();
extern	char	*_FSRealloc ();
extern	void	_FSFree ();


/** Temporary memory allocation routines **/
extern	void	_FSFreeAlloc ();
extern	char	*_FSAlloc ();


#endif
