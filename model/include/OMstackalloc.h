
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* OMstackalloc.h - declarations for stack allocation routines          */
/*                                                                      */
/* Paul L. Hammond   February 27, 1986                                  */
/*                                                                      */
/* Revisions :                                                          */
/*  June 2, 1986 - completely revised.  OM_stack_dealloc must be called */
/*  June 3, 1986 - fixed bug in dealloc.  Changed name of routine.      */
/*  July 21, 1986- reverted to OM_malloc, OM_dealloc                    */ 
/*                                                                      */
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#define OM_stack_alloc(size) malloc(size)
 /* Returns maximally alligned pointer */

#define OM_stack_dealloc(p) free(p)
 /* parameter must point to space allocated by OM_stack_alloc */

/* end OMstackalloc.h */

/*
These declarations cause problems on the SGI.

extern char *malloc( int size);
extern void free( char *p );
*/
