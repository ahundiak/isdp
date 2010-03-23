/* $RCSfile: fsdef.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:06 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _DEFINES
#define _DEFINES	0


#include "FSTypes.h"

#ifndef O_WRONLY
#include <fcntl.h>
#endif

#ifndef FILE
#include <stdio.h>
#endif


#ifndef NULL
#define NULL	0
#endif

#ifndef TRUE
#define TRUE	1
#define FALSE	0
#endif

#ifndef MIN
#define MIN(a,b)	( ((a) < (b)) ? (a) : (b) )
#define MAX(a,b)	( ((a) > (b)) ? (a) : (b) )
#endif

#ifndef ABS
#define ABS(a)		( ((a) < 0) ? (-(a)) : (a) )
#endif

#ifndef	ROUND
#define	ROUND(a)	( ((a) >= 0) ? ((a) + .5) : ((a) - .5) )
#endif

#define LONGWORD(p)	((p + 3) & (~0x03))
#define DOUBLE(p)	((p + 7) & (~0x07))
#define	ALIGN(p)	DOUBLE(p)


/** Assertion macro **/
#ifdef NDEBUG
#define	_FSAssert(EX)
#else
#define	_FSAssert(EX)	if (EX) ; else _FSAssertion ("EX", __FILE__, __LINE__);
#endif


#endif
