/* $Id: VDmem.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include / VDmem.h
 *
 * Description:
 *	VDS memory allocation header file
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDmem.h,v $
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
 * Revision 1.7  1996/04/26  02:03:20  pinnacle
 * Replaced: include/VDmem.h for:  by v240_int for vds.240
 *
 * Revision 1.6  1996/04/18  23:07:28  pinnacle
 * Replaced: include/VDmem.h for:  by v240_int for vds.240
 *
 * Revision 1.5  1996/02/04  15:49:10  pinnacle
 * Replaced: include/VDmem.h for:  by azuurhou for vds.240
 *
 * Revision 1.4  1996/02/01  18:10:28  pinnacle
 * Replaced: include/VDmem.h for:  by azuurhou for vds.240
 *
 * Revision 1.3  1995/08/23  21:49:36  pinnacle
 * Replaced: include/VDmem.h for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/08/23  20:37:52  pinnacle
 * Replaced: include/VDmem.h for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/08/16  21:00:04  pinnacle
 * Created: include/VDmem.h by tlbriggs for vds.240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	08/16/95   tlb		creation
 *	08/23/95   tlb		Change REALLOC, CALLOC to functions,
 *				Add runtime ifdef for memory allocation
 *	08/23/95   tlb		Remove extra argument to VD_free
 *	04/12/96   tlb		Add new functions to support log file
 *				Add allocation function for arraries
 *	04/25/96   tlb		Fix LOOPFREE to check for NULL ptr
 *				Add _CheckAlloc
 *
 *************************************************************************/
#ifndef vdmem_include
#	define vdmem_include 1

#ifndef	OM_D_ERRORDEF
#	include	"OMerrordef.h"
#endif

#include	<standards.h>
#include	<stdlib.h>		/* malloc prototypes */
#include	"msdef.h"
#include 	"igrtypedef.h"
#include 	"igr.h"
#include	"bstypes.h"
#include	"bsdbg.h"

/* Bspmath prototypes -
 * 	included here since BSpmath prototypes is not ion the include
 *		directory list
 */
extern void 	BSinit20 	__((void));
extern IGRchar *BSdbgalloc 	__((IGRint n));
extern IGRchar *BSdbgralloc 	__((IGRchar *ptr, IGRint n));
extern void 	BSdbgfree 	__((IGRchar *ptr));
extern void 	BSpoisonmem 	__((IGRint n));
extern void 	BSpoisonstk 	__((IGRint n));
extern void 	BSlockmem 	__((IGRint n));
extern void 	BSchkmemo 	__((void));
extern void 	BSchkmem1 	__((IGRchar *ptr));
extern void 	BSchklmem 	__((void));
extern IGRint 	BSmemclean 	__((void));

extern IGRboolean BSfreecv __((BSrc *, struct IGRbsp_curve *));
extern IGRboolean BSfreesf __((BSrc *, struct IGRbsp_surface *));


/* BS memory allocation globals */
extern int			BSdbglev;
extern short			BSalloczero;
extern short			BSfreezero;
extern int			BSlmemnumb;
extern char *			BSlmemptr;
extern struct BSlsalloc		BSlist_al;

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
#ifndef VD_RUNTIME

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
 * Array allocation functions 
 *	arrays of form type[nrow][len]
 */

#    define _MALLOC_ARR( nrow, type, len)				\
	( type (*) [len]) VD_malloc ( (nrow) * (len) * sizeof( type ),	\
							 __LINE__, __FILE__ )

#    define _REALLOC_ARR( ptr, nrow, type, len)				\
	( type (*) [len]) VD_realloc ( (char *)ptr, 			\
				      (nrow) * (len) * sizeof( type ), 	\
							__LINE__, __FILE__ )

#    define _CALLOC_ARR( nrow, type, len)				\
	( type (*) [len]) VD_calloc ( (nrow) * (len) * sizeof( type ),	\
							 __LINE__, __FILE__ )

/*
 * Deallocation functions
 */
#    define _FREE(ptr) 							\
	if (ptr) {							\
		VD_free ((char *) ptr , __LINE__, __FILE__ );		\
		ptr = NULL;						\
		}

#    define _FREECV( bsrc, ptr )					\
	if (ptr) {							\
		BSfreecv( (bsrc), (ptr) );				\
		ptr = NULL;						\
		}

#    define _FREESF( bsrc, ptr )					\
	if (ptr) {							\
		BSfreesf( (bsrc), (ptr) );				\
		ptr = NULL;						\
		}
#else
#    define _MALLOC( nelem, type) 					\
	( type *) malloc ( (unsigned) (nelem) * sizeof( type ) )

#    define _REALLOC( ptr, nelem, type) 				\
 	( type *) realloc ( (char *) ptr, (unsigned) (nelem) * sizeof( type ))

#    define _CALLOC( nelem, type )  					\
	( type *) calloc ( (unsigned) (nelem) , (unsigned) sizeof( type ) )


#    define _MALLOC_ARR( nrow, type, len)				\
	( type (*) [len]) malloc ( (nrow) * (len) * sizeof( type ))

#    define _REALLOC_ARR( ptr, nrow, type, len)				\
	( type (*) [len]) realloc ( (char *)ptr, 			\
				(nrow) * (len) * sizeof( type ))

#    define _CALLOC_ARR( nrow, type, len)				\
	( type (*) [len]) calloc ( (nrow) * (len) * sizeof( type ))


#    define _FREE(ptr) 							\
	if (ptr) { free ((char *) ptr );  ptr = NULL; }

#    define _FREECV( bsrc, ptr )					\
	if (ptr) { BSfreecv( (bsrc), (ptr) ); ptr = NULL; }

#    define _FREESF( bsrc, ptr )					\
	if (ptr) { BSfreesf( (bsrc), (ptr) ); ptr = NULL; }
#endif

#define _LOOPFREE( array_of_pointer, count ) {				\
		int __i ;						\
		if (array_of_pointer) {					\
			for( __i = 0 ; __i < (count) ; __i = __i+1 ) {	\
				_FREE( (array_of_pointer)[__i] ) ;	\
			}						\
			_FREE( (array_of_pointer) ) ;			\
		}							\
	}


/* ----------------------------------
 * Memory allocation error checking
 */
#define _CheckMem(ptr, sts, msg, label ) 				\
	if (! ptr ) {							\
    		msg	= MSFAIL ;					\
    		sts	= OM_E_NODYNMEM ;				\
		printf ("Allocation failed at line %d of the file %s\n",\
						__LINE__,__FILE__);  	\
		goto label ;						\
		}

#define _CheckAlloc(ptr, name, sts, value, label )			\
	if (! ptr ) {							\
    		sts	= value ;					\
		printf ("Allocation of %s failed at line %d of the file %s\n",\
					name, __LINE__,__FILE__);  	\
		goto label ;						\
		}

/* =====================================================================
 * Memory allocation debugging
 */
#ifndef VD_RUNTIME
#	define _MEM_STATUS	 VD_memStatus()


#	define _CHK_PTR(ptr)						\
		if (BSdbglev == 20) {					\
			printf ("Checking pointer 0x%x....\n", ptr);	\
			BSchkmem1 ((char *) (ptr));			\
			}
#	define _CHK_ACTIVE						\
		if (BSdbglev == 20) {					\
		   	printf ("\nCheck active allocated memory...\n");\
			BSchkmemo();					\
			}
#	define _CHK_LOCK						\
		if (BSdbglev == 20) {					\
			printf ("\nCheck locked memory...\n");		\
			BSchklmem(); 					\
			}

#	define _CHK_ALLOC						\
		if (BSdbglev == 20) {					\
			printf ("\nMemory allocations ...\n");\
			BSmemclean();					\
			BSalloczero = BSfreezero = 0;			\
			}

#	define _MEM_INIT	BSinit20(); VD_memOn()

#	define _MEM_POISON						\
		{ printf ("\nPoisoning memory and stack...\n");		\
		UI_status ("Poisoning memory and stack...");		\
		BSpoisonmem(10000000); 					\
		BSpoisonstk(50000); 					\
		}
#	define _MEM_LOCK						\
		{printf ("\nPoisoning and locking memory...\n");	\
		UI_status ("Poisoning and locking memory...");		\
		BSlockmem(10000000); 					\
		}

#	define _MEM_CHK_ON						\
		{ printf ("Memory checking on...\n"); 			\
		UI_status ("Memory checking on"); 			\
		BSdbglev = 20;						\
		}
#	define _MEM_CHK_OFF						\
		{ printf ("Memory checking off...\n");			\
		UI_status ("Memory checking off"); 			\
		BSdbglev = 0;						\
		}
#else
#	define _MEM_STATUS
#	define _CHK_PTR(ptr)
#	define _CHK_ACTIVE
#	define _CHK_LOCK
#	define _CHK_ALLOC
#	define _MEM_INIT
#	define _MEM_POISON
#	define _MEM_LOCK
#	define _MEM_CHK_ON
#	define _MEM_CHK_OFF
#endif

#endif /* vdmem_include */
