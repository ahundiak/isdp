/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
/*
**	NAME:							netshmem.h
**	AUTHORS:						Grace Oliver
**	CREATION DATE:					1/94
**	ABSTRACT:	Shared Memory definitions
**	
**	REVISION HISTORY:
*/

#define SHARED_MEMORY				"SHARED_MEMORY"
#define SHARED_MEMORY_SIZE			(sizeof(SHARED_MEMORY)-1)
#define SHARED_MEMORY_SPEC			"0x%x"

#if defined(clipper) || defined(__clipper__)
#define SHARED_MEMORY_MIN      0x50000
#define SHARED_MEMORY_MAX      0x400000
#define SHARED_MEMORY_DEFAULT  0x200000
#endif
#if defined(__sunx)
#define SHARED_MEMORY_MIN      0x50000
#define SHARED_MEMORY_MAX      0x100000
#define SHARED_MEMORY_DEFAULT  0x100000
#endif
#if defined(__Sol2__)
#define SHARED_MEMORY_MIN      0x50000
#define SHARED_MEMORY_MAX      0x200000
#define SHARED_MEMORY_DEFAULT  0x200000
#endif
#if defined(Soli) || defined(__i386)
#define SHARED_MEMORY_MIN      0x50000
#define SHARED_MEMORY_MAX      0x100000
#define SHARED_MEMORY_DEFAULT  0x100000
#endif
#if defined(sco)
#define SHARED_MEMORY_MIN      0x50000
#define SHARED_MEMORY_MAX      0x400000
#define SHARED_MEMORY_DEFAULT  0x200000
#endif
#if defined(__hpux__)
#define SHARED_MEMORY_MIN      0x50000
#define SHARED_MEMORY_MAX      0x200000
#define SHARED_MEMORY_DEFAULT  0x200000
#endif
#if defined(WIN32) || defined(DOS)
#define SHARED_MEMORY_MIN      0x50000
#define SHARED_MEMORY_MAX      0x400000
#define SHARED_MEMORY_DEFAULT  0x200000
#endif
