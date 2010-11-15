/* Do not alter this SPC information: $Revision: 1.1.38.1 $ */
/*
**	NAME:							umsmem.h
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					7/94
**	ABSTRACT:		Use this macros instead of low-level system calls to alloc,
**					realloc or free memory.
**		
**	
**	REVISION HISTORY:
*/

#ifndef UMSMEM_H
#define UMSMEM_H

 
/*
**	INCLUDES
*/
#if defined(__clipper__) || defined(sun) || defined(SCO)
# include <malloc.h>
#elif defined(WIN32) || defined(WIN16)
# include <windows.h>
# include <windowsx.h>
#else
ERROR -- NO CODE
#endif

/*
**	DEFINES
*/
#if defined(__clipper__) || defined(sun) || defined(SCO)
# define GETMEMORY(size) malloc(size)
# define REALLOCMEMORY(ptr, size) realloc(ptr, size)
# define FREEMEMORY(ptr) free(ptr)
#elif defined(WIN32) || defined(WIN16)
# define GETMEMORY(size) GlobalAllocPtr(GMEM_MOVEABLE | GMEM_ZEROINIT, size)
# define REALLOCMEMORY(ptr, size) GlobalReAllocPtr(ptr, size, GMEM_MOVEABLE | GMEM_ZEROINIT)
# define FREEMEMORY(ptr) GlobalFreePtr(ptr)
#else
ERROR -- NO CODE
#endif

/*
**	TYPES
*/

/*
**	VARIABLES
*/

#endif /* UMSMEM_H */
