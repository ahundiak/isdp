/* $Id: VDmem_ppl.h,v 1.2 2002/04/25 15:29:43 anand Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include / VDmem_ppl.h
 *
 * Description:
 *	VDS memory allocation header file (PPL Version)
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDmem_ppl.h,v $
 *	Revision 1.2  2002/04/25 15:29:43  anand
 *	When included in a PPL alone, was not compiling.  One had to
 *	insert the #if STDC __cplusplus stuff.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1996/06/21  21:55:38  pinnacle
 * Created: include/VDmem_ppl.h by v240_int for vds.240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	06/20/96   ah		creation
 *	04/25/02   Anand	Added #if STDC || cplusplus for prototyping.
 *
 *************************************************************************/
#ifndef vdmem_include
#	define vdmem_include 1

#ifndef	OM_D_ERRORDEF
#	include	"OMerrordef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* 
 * Turn VDS memory checking on/off
 *	VDS memory checking is always on if BS memory allocation is on 
 */
extern	int	VD_memIsOn	__(( void ));
extern	int	VD_memOn	__(( void ));
extern	int	VD_memOff	__(( void ));

/* 
 * Open/close memory log file
 *	Default is stdout
 */
extern	int	VD_memOpenFile	__(( char* name ));
extern	int	VD_memCloseFile	__(( void ));

/* 
 * Print VDS memory checking status
 */
extern	void 	VD_memReset 	__(( void ));
extern	void 	VD_memStatus 	__(( void ));
extern	void 	VD_memPrintPtrs	__(( void ));

/* 
 * VDS memory managment functions
 */
extern	char * 	VD_malloc 	__(( int size, int line, char* file ));
extern	char * 	VD_calloc 	__(( int size, int line, char* file ));
extern	char * 	VD_realloc 	__(( char * ptr,int size, int line,char* file));
extern	void 	VD_free 	__(( char * ptr, int line, char* file ));

/*  
 * VDS memory trace
 *	intially FALSE
 */
extern	int	VD_memTrace;		/* Set to trace _MALLOC/_FREE calls */

/* ========================================================================
 * Memory allocation
 */

/* 
 * Standard allocation functions
 */
#    define _MALLOC( nelem, type) 					\
	( type *) VD_malloc ( (nelem) * sizeof( type ) , __LINE__, __FILE__ )

#    define _REALLOC( ptr, nelem, type) 				\
 	( type *) VD_realloc ( (char *) ptr, (nelem) * sizeof( type ) , \
							__LINE__, __FILE__ )

#    define _CALLOC( nelem, type )  					\
	( type *) VD_calloc ( (nelem) * sizeof( type ) , __LINE__, __FILE__ )

/*
 * Deallocation functions
 */
#    define _FREE(ptr) 							\
	if (ptr) {							\
		VD_free ((char *) ptr , __LINE__, __FILE__ );		\
		ptr = NULL;						\
		}

#endif /* vdmem_include */
