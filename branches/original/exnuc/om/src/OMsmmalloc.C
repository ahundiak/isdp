#ifndef NT
#include <block.h>
#endif /* NT */

extern char *som_malloc();
extern char *som_realloc();
extern char *som_calloc();
extern void som_dealloc();

extern char *OM_Gp_sheapBase;    /* pointer to OM shared memory block */

/*****************************************************************************/
/*									     */
/*  som_sm_malloc:  Allocate "request" bytes from shared memory.	     */
/*									     */
/*****************************************************************************/

char *som_sm_malloc (request)

unsigned request;
{
/*  return blkalloc (OM_Gp_sheapBase, request);*/
    return((char *) som_malloc(request));
}


/*****************************************************************************/
/*									     */
/*  som_sm_dealloc:  Free a chunk of shared memory.			     */
/*									     */
/*****************************************************************************/

void som_sm_dealloc (ptr)

void *ptr;
{
/*  blkfree (OM_Gp_sheapBase, ptr);*/
  som_dealloc(ptr);
}


/*****************************************************************************/
/*									     */
/*  som_sm_realloc:  change the size of a chunk of shared memory.	     */
/*									     */
/*****************************************************************************/

char *som_sm_realloc (ptr, nbytes)

char    *ptr;
unsigned nbytes;
{
/*  return blkrealloc (OM_Gp_sheapBase, ptr, nbytes);*/
    return((char *) som_realloc(ptr, nbytes));
}


/*****************************************************************************/
/*									     */
/*  som_sm_calloc:  Allocate sufficient memory for an array of "nelem"       */
/*		    elements each "elsize" bytes in length from shared       */
/*		    memory.  The allocated memory is set to zero.	     */
/*                                                                           */
/*****************************************************************************/

char *som_sm_calloc (nelem, elsize)

unsigned nelem, elsize;
{
/*  return blkcalloc (OM_Gp_sheapBase, nelem * elsize);*/
    return((char *) som_calloc(nelem, elsize));
}
