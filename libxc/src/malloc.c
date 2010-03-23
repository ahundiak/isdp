#include <stdio.h>
#include "blockpvt.h"
#include "malloc.h"

#define  GRABSZ       (5*PAGESZ)    /* extra space to get at each growmalloc */
#define  BS_INC            5        /* size increment for BStack             */

extern int     brk  ();
extern char   *sbrk ();
extern char    edata;
extern int     blk__checks;

static BLOCK  *pblk      = 0;         /* pointer to the primary block        */
static BLOCK  *cblk      = 0;         /* pointer to the current block        */
static BLOCK **BStack    = 0;         /* stack of active blocks              */
static int     BSalloc   = 0;         /* number of slots allocated to BStack */
static int     BSnext    = 0;         /* next available slot in BStack       */
static int     maxfast   = MAXSMALL;  /* maximum size to alloc from holdblk  */
static int     numsmall  = NUMSMALL;  /* number of small chunks per holdblk  */
static int   (*ptrap) () = MAL_DFLT;  /* memory trap for malloc              */

#ifdef DEBUG
extern void blkdebug_setup ();

static int malloc_cnt  = 0;
static int free_cnt    = 0;
static int cfree_cnt   = 0;
static int realloc_cnt = 0;
static int calloc_cnt  = 0;
static int check_cnt   = 0;


void debug_check ()
{
  check_cnt++;
  blkdebug_check (pblk, 0, "debug_check", check_cnt);
}
#endif

/*****************************************************************************/
/*									     */
/*  growmalloc:  This is the trap routine for the primary block.  New memory */
/*		 is obtained from the system according to the requirements   */
/*		 of "size" (if possible) and added to the block.	     */
/*									     */
/*****************************************************************************/

static int growmalloc (blk, size)

BLOCK *blk;
uint   size;
{
  char *oldbrk, *newbrk;

  oldbrk = sbrk (0);
  newbrk = (char *)ALIGN (oldbrk + size + GRABSZ, PAGESZ);
  if (brk (newbrk) != -1) {
    growblk (blk, oldbrk, newbrk - oldbrk);
    return MAL_RETRY;
  }

  /* if that failed, try the minimum amount */

  newbrk = (char *)ALIGN (oldbrk + size, PAGESZ);
  if (brk (newbrk) == -1)
    return MAL_ABORT;
  growblk (blk, oldbrk, newbrk - oldbrk);
  return MAL_RETRY;
}


static int blkinit (request)

uint request;
{
  uint  nbytes;
  char *oldbrk, *newbrk;

  if ((nbytes = request + GRABSZ) < MINBLOCK)
    nbytes = MINBLOCK;

  oldbrk = sbrk (0);
  newbrk = (char *)ALIGN (oldbrk + nbytes, PAGESZ);
  if (brk (newbrk) == -1)
    return 0;
  if (cblk = pblk = defineblkopt (oldbrk, newbrk - oldbrk, maxfast, numsmall)){
    memtrap (pblk, growmalloc);
    return 1;
  }

  return 0;
}

/*****************************************************************************/
/*									     */
/*  setblk:  Make the specified block the current one (all memory allocated  */
/*           via malloc will now come from this block).  Zero is returned    */
/*	     on success, -1 if the given block is invalid.		     */
/*									     */
/*****************************************************************************/

int setblk (blk)

BLOCK *blk;
{
  /* check for special block values */

  switch ((int)blk) {
    case PBLOCK: blk = pblk; break;
    case CBLOCK: blk = cblk; break;
    default    : break;
  }

  /* make sure that we have been handed a valid block */

  if (blk && blk->magic != BLOCKMAGIC)
    return -1;

  /* enlarge the block stack if necessary to hold the additional pointer */

  if (BSnext >= BSalloc) {
    BLOCK *temp = cblk;
    cblk        = pblk;
    BStack      = realloc (BStack, (BSalloc += BS_INC) * sizeof (BLOCK *));
    if (temp)
      cblk = temp;
  }

  /* save the current block on the stack and make the given block the current
     one */

  BStack[BSnext++] = cblk;
  cblk             = blk;

  return 0;
}

/*****************************************************************************/
/*									     */
/*  resetblk:  Reset the current block to what it was before the last call   */
/*             to setblk.  Return 0 for success, -1 if there is no previous  */
/*             block.							     */
/*									     */
/*****************************************************************************/

int resetblk ()
{
  if (BSnext == 0)
    return -1;

  cblk = BStack[--BSnext];
  return 0;
}

/*****************************************************************************/
/*									     */
/*  settrap:  Arrange to have the function pointed to by "func" called when  */
/*	      malloc cannot satisfy a request.  The previous trap function   */
/*	      is returned.						     */
/*									     */
/*****************************************************************************/

int (*settrap (func)) ()

int (*func) ();
{
  int (*temp) ();

  temp  = ptrap;
  ptrap = func;
  return temp;
}

/*****************************************************************************/
/*									     */
/*  malloc:  Allocate "request" bytes from the current block.  The actual    */
/*           amount of memory allocated may be adjusted upward according to  */
/*           alignment requirements.  The memory allocated will be properly  */
/*           aligned for any use.  A pointer to the allocated memory is      */
/*           returned unless the request cannot be satisfied in which case   */
/*           0 is returned.						     */
/*									     */
/*****************************************************************************/

void *malloc (request)

uint request;
{
  char *ptr;

  /* if the current block is null, we need to initialize the primary block */

  if (!cblk && !blkinit (request))
    goto error;

  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  malloc_cnt++;
  if (cblk == pblk) {
    blkdebug_check (pblk, 0, "malloc", malloc_cnt);
    trapreturn (blkdebug_setup, pblk);
  }
#endif

  if (ptr = blkalloc (cblk, request))
    return ptr;

error:
  if (ptrap != MAL_DFLT)
    ptrap ();
  return 0;
}

/*****************************************************************************/
/*									     */
/*  free:  Free the chunk associated with the given pointer.  It is assumed  */
/*         that the given pointer corresponds to the start of the data area  */
/*         of a chunk.  Free does not return any value.                      */
/*									     */
/*****************************************************************************/

void free (ptr)

char *ptr;
{
  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  free_cnt++;
  if (cblk == pblk) {
    blkdebug_check (pblk, ptr, "free", free_cnt);
    trapreturn (blkdebug_setup, pblk);
  }
#endif

  if (ptr)
    if (ptr >= &edata && ptr < sbrk (0))
      blkfree (cblk, ptr);
    else if (blk__checks)
      fprintf (stderr, "Pointer (0x%.8x) out of domain:  cannot free.\n", ptr);
}


void cfree (ptr)

char *ptr;
{
  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  cfree_cnt++;
  if (cblk == pblk) {
    blkdebug_check (pblk, ptr, "cfree", cfree_cnt);
    trapreturn (blkdebug_setup, pblk);
  }
#endif
  if (ptr)
    if (ptr >= &edata && ptr < sbrk (0))
      blkfree (cblk, ptr);
    else if (blk__checks)
      fprintf (stderr, "Pointer (0x%.8x) out of domain:  cannot free.\n", ptr);
}

/*****************************************************************************/
/*									     */
/*  realloc:  modify the size of the chunk corresponding to "ptr" to be      */
/*            "nbytes" in length.  The data within the chunk is preserved.   */
/*            The size of the chunk is changed without moving the data if    */
/*            this is possible.  A chunk being made smaller is guaranteed    */
/*	      not to move.  If "nbytes" is zero, the chunk is automatically  */
/*            freed and NULL is returned.  A pointer to the resized chunk is */
/*            returned otherwise.                                            */
/*									     */
/*****************************************************************************/

void *realloc (ptr, nbytes)

char *ptr;
uint  nbytes;
{
  /* if the current block is null, we need to initialize the primary block */

  if (!cblk && !blkinit (nbytes))
    goto error;

  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  realloc_cnt++;
  if (cblk == pblk) {
    blkdebug_check (pblk, ptr, "realloc", realloc_cnt);
    trapreturn (blkdebug_setup, pblk);
  }
#endif

  if (!ptr || ptr >= &edata && ptr < sbrk (0)) {
    if ((ptr = blkrealloc (cblk, ptr, nbytes)) || !nbytes)
      return ptr;
  }
  else if (blk__checks)
    fprintf (stderr, "Pointer (0x%.8x) out of domain:  cannot realloc.\n", ptr);

error:
  if (ptrap != MAL_DFLT)
    ptrap ();
  return 0;
}

/*****************************************************************************/
/*									     */
/*  calloc:  Allocate sufficient memory for an array of "nelem" elements     */
/*           each "elsize" bytes in length.  The allocated memory is set to  */
/*           zero.  A pointer to the allocated memory is returned unless the */
/*           request could not be satisfied in which case NULL is returned   */
/*                                                                           */
/*****************************************************************************/

void *calloc (nelem, elsize)

uint nelem, elsize;
{
  char *ptr;
  uint  nbytes = nelem * elsize;

  /* if the current block is null, we need to initialize the primary block */

  if (!cblk && !blkinit (nbytes))
    goto error;

  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  calloc_cnt++;
  if (cblk == pblk) {
    blkdebug_check (pblk, 0, "calloc", calloc_cnt);
    trapreturn (blkdebug_setup, pblk);
  }
#endif

  if (ptr = blkcalloc (cblk, nbytes))
    return ptr;

error:
  if (ptrap != MAL_DFLT)
    ptrap ();
  return 0;
}

void malldump ()
{
  if (!cblk && !blkinit (0))
    return;
  blkinfo (cblk);
}

/*****************************************************************************/
/*									     */
/*  mallopt & mallinfo:  These routines are provided for compatability with  */
/*                       programs written to use the malloc(3X) package.     */
/*									     */
/*****************************************************************************/

struct mallinfo mallinfo ()
{
  struct mallinfo  info;
  CHUNK           *chunk;
  HOLDB           *holdblk;
  int              size = 0;

  memset (&info, '\0', sizeof (info));

  { CMD *first = cblk->memory;

    while (first->left)
      first = first->left;
    chunk = NEXTHEAD (&first[1]);
  }
  while (chunk->next != (CHUNK *)BUSY) {
    switch (STAT (chunk)) {

      case FREE: size           = chunk->myFCD->size;
                 info.arena    += size;
                 info.fordblks += size;
                 info.ordblks++;
                 break;

      case BUSY: size = (char *)SET (chunk->next, FREE) - (char *)chunk;
                 info.arena    += size;
                 info.uordblks += size;
                 info.ordblks++;
                 break;

      case HOLD: size = (char *)SET (chunk->next, FREE) - (char *)chunk;
                 holdblk       = (HOLDB *)chunk;
                 info.arena   += size;
                 info.hblkhd  += ALIGN (HOLDSZ, ALIGNSZ);
                 info.usmblks += holdblk->busy * holdblk->csize;
                 info.fsmblks += (cblk->numsmall - holdblk->busy) * holdblk->csize;
                 info.hblks++;
                 break;

      case HOLE: size        = (char *)SET (chunk->next, FREE) - (char *)chunk;
                 info.arena += HEADSZ;
                 break;
    }

    chunk = (CHUNK *)((char *)chunk + size);
  }

  info.smblks  = info.hblks * cblk->numsmall;
  return info;
}


int mallopt (cmd, value)

int cmd;
int value;
{
  if (pblk)
    return -1;

  switch (cmd) {
    case M_MXFAST: maxfast  = value; break;
    case M_NLBLKS: numsmall = value;
    case M_GRAIN :
    case M_KEEP  : break;
    default      : return -1;
  }
  return 0;
}
