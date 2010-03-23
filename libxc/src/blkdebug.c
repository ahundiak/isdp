#ifndef  DEBUG
#define  DEBUG
#endif

#include <signal.h>
#include <stdio.h>
#include "blockpvt.h"

static void mkchksum (void *chksum, void *ptr, uint size)
{
  int *start  = (int *)ptr;
  int *stop   = (int *)((char *)ptr + size);
  int  result = ~0;

  *(int *)chksum = 0;
  for (; start < stop; result ^= *start++);
  *(int *)chksum = result;
}


static int verifychksum (void *chksum, void *ptr, uint size)
{
  int *start = (int *)ptr;
  int *stop  = (int *)((char *)ptr + size);
  int  result;

  result = (chksum < (void *)start || chksum >= (void *)stop ? ~0 ^ *(int *)chksum : ~0);
  for (; start < stop; result ^= *start++);
  return !result;
}

static void abort1 (char *text, void *addr, uint size, char *name, int cnt)
{
  printf ("Overwrite detected:  %s  -  ", text);
  if (addr)
    printf ("0x%.8x (%d bytes)\n", addr, size);
  else printf ("[address indeterminate]\n");
  printf ("\n*** Error detected on entry to %s after %d calls\n", name, cnt);
  fflush (stdout);
  signal (SIGTRAP, SIG_IGN);
  kill (getpid (), SIGTRAP);
  exit (1);
}


static void abort2 (addr, name, cnt)

char *addr;
char *name;
int   cnt;
{
  printf ("Bad pointer handed to %s:  0x%.8x\n", name, addr);
  printf ("\n*** Error detected on entry to %s after %d calls\n", name, cnt);
  fflush (stdout);
  signal (SIGTRAP, SIG_IGN);
  kill (getpid (), SIGTRAP);
  exit (1);
}

void blkdebug_setup (blk)

BLOCK *blk;
{
  int    size;
  char  *ptr;
  CMD   *cmd;
  CHUNK *chunk;
  CHUNK *snap;

  if (!blk->debug_on)
    return;

  /* increase the size of the snapshot region if we have less than INC_MARGIN
     words available */

  size = (char *)blk->snap_last - (char *)blk->snap_start;
  if (allocsz (blk->snap_start, 0) - size < INC_MARGIN * HEADSZ) {
    uint newsize = allocsz (blk->snap_start, 0) + SNAP_INC * HEADSZ;

    if (!(ptr = blkrealloc (blk, blk->snap_start, newsize))) {
      printf ("blkdebug_setup:  no memory to continue!  Debug disabled.\n");
      blk->debug_on = 0;
      return;
    }
    blk->snap_start = (CHUNK *)ptr;
  }

  /* take snapshot of all chunk headers */

  for (cmd = blk->memory; cmd->left; cmd = cmd->left);
  (snap = blk->snap_start)->next = chunk = NEXTHEAD (&cmd[1]);
  while (chunk->next != (CHUNK *)BUSY) {
    *++snap = *chunk;
    if (STAT (chunk) == FREE) {
      mkchksum (++snap, chunk->myFCD, sizeof (FCD));
      chunk = (CHUNK *)((char *)chunk + chunk->myFCD->size);
    }
    else chunk = (CHUNK *)SET (chunk->next, FREE);
  }
  *++snap        = *chunk;
  blk->snap_last = snap + 1;

  /* calculate checksums for important data */

  { uint psize = (blk->p_curr + blk->p_avail) * sizeof (PAGE);
    uint hsize = blk->maxsmall / ALIGNSZ * sizeof (HOLDB *);
    uint ssize = (char *)blk->snap_last - (char *)blk->snap_start;

    mkchksum (&blk->p_chksum, blk->pagemap, psize);
    mkchksum (&blk->h_chksum, blk->small, hsize);
    mkchksum (&blk->s_chksum, blk->snap_start, ssize);
    mkchksum (&blk->b_chksum, blk, BLOCKSZ);
  }

  /* calculate checksums for each configured memory descriptors */

  cmd = blk->memory;
  do {
       mkchksum (&cmd->chksum, cmd, sizeof (*cmd));
  } while ((cmd = cmd->next) != blk->memory);

  /* calculate checksums for each holding block header */

  { HOLDB *hold;
    int    index;

    for (index = 0; (uint)index < blk->maxsmall / ALIGNSZ; index++) {
      if (!(hold = blk->small[index]))
        continue;
      do {
           mkchksum (&hold->chksum, hold, sizeof (*hold));
      } while ((hold = hold->next) != blk->small[index]);
    }
  }

  /* set main entry flag */

  blk->mainentry = 1;
}

static int valid_head_addr (BLOCK *blk, HOLDB *hold, void *addr)
{
  char *start  = (char *)NEXTHEAD (&hold[1]);
  int   offset = (char *)addr - start;

  if (offset >= 0 && offset < (int)hold->csize * (int)blk->numsmall)
    return !(offset % (int)hold->csize);
  return 0;
}


static int valid_free_addr (blk, addr)

BLOCK *blk;
CHUNK *addr;
{
  CHUNK *chunk;
  CHUNK *snap;

  chunk = (snap = blk->snap_start)->next;
  do {
       snap++;
       switch (STAT (snap)) {
         case FREE: chunk = (CHUNK *)((char *)chunk + snap->myFCD->size);
                    snap++;
                    break;
         case HOLD: if (valid_head_addr (blk, (HOLDB *)chunk, addr))
                      return addr->next == (CHUNK *)SET (chunk, BUSY);
                    chunk = (CHUNK *)SET (snap->next, FREE);
                    break;
         case BUSY: if (addr == chunk)
                      return 1;
         default  : chunk = (CHUNK *)SET (snap->next, FREE);
                    break;
       }
  } while (snap->next != (CHUNK *)BUSY);

  return 0;
}

void blkdebug_check (blk, check, name, call)

BLOCK *blk;
char  *check;
char  *name;
int    call;
{
  CHUNK *chunk;
  CHUNK *snap;
  CMD   *cmd;

  if (!blk->debug_on)
    return;

  /* clear main entry flag */

  blk->mainentry = 0;

  /* verify checksums on important data */

  { uint psize = (blk->p_curr + blk->p_avail) * sizeof (PAGE);
    uint hsize = blk->maxsmall / ALIGNSZ * sizeof (HOLDB *);
    uint ssize = (char *)blk->snap_last - (char *)blk->snap_start;

    if (!verifychksum (&blk->b_chksum, blk, BLOCKSZ))
      abort1 ("block header", blk, BLOCKSZ, name, call);
    else if (!verifychksum (&blk->p_chksum, blk->pagemap, psize))
      abort1 ("pagemap", blk->pagemap, psize, name, call);
    else if (!verifychksum (&blk->h_chksum, blk->small, hsize))
      abort1 ("holding block index", blk->small, hsize, name, call);
    else if (!verifychksum (&blk->s_chksum, blk->snap_start, ssize))
      abort1 ("debug snapshot data", blk->snap_start, ssize, name, call);
    else goto okay;

    return;
  }

  /* verify checksums on the configured memory descriptors */

okay:
  cmd = blk->memory;
  do {
       if (!verifychksum (&cmd->chksum, cmd, sizeof (*cmd))) {
         abort1 ("configured memory descriptor", cmd, sizeof (*cmd), name,call);
         return;
       }
  } while ((cmd = cmd->next) != blk->memory);

  /* verify the holding blocks */

  { HOLDB *hold;
    int    index;
    int    cnt;

    for (index = 0; (uint)index < blk->maxsmall / ALIGNSZ; index++) {
      if (!(hold = blk->small[index]))
        continue;
      do {
           /* check the header */

           if (!verifychksum (&hold->chksum, hold, sizeof (*hold))) {
             abort1 ("holding block header", hold, sizeof (*hold), name, call);
             return;
           }

           /* check the headers of each small chunk */

           chunk = NEXTHEAD (&hold[1]);
           cnt = blk->numsmall;
           for (; cnt; cnt--, chunk = (CHUNK *)((char *)chunk + hold->csize)) {
             switch (STAT (chunk)) {
               case BUSY:
                 if (chunk->next == (CHUNK *)SET (hold, BUSY))
                   continue;
                 break;
               case FREE:
                 if (!chunk->next || valid_head_addr (blk, hold, chunk->next))
                   continue;
               default:
                 break;
             }
             abort1 ("chunk header", chunk, sizeof (*chunk), name, call);
             return;
           }

           /* check the free queue */

           if (cnt = blk->numsmall - hold->busy) {
             chunk = hold->freeq;
             while (cnt--) {
               if (STAT (chunk) != FREE)
                 goto error;
               if (!chunk->next)
                 break;
               chunk = chunk->next;
             }
             if (cnt) {
error:         abort1 ("holding block free queue", chunk, sizeof (*chunk),
                                                                   name, call);
               return;
             }
           }

      } while ((hold = hold->next) != blk->small[index]);
    }
  }

  /* check the chunk headers by comparing them to the snapshot */

  chunk = (snap = blk->snap_start)->next;
  do {
       snap++;
       if (snap->next != chunk->next) {
         abort1 ("chunk header", chunk, sizeof (CHUNK), name, call);
         return;
       }
       if (STAT (snap) != FREE)
         chunk = (CHUNK *)SET (chunk->next, FREE);
       else {
         if (!verifychksum (++snap, chunk->myFCD, sizeof (FCD))) {
           abort1 ("free chunk descriptor", chunk->myFCD, sizeof (FCD),
                                                                    name, call);
           return;
         }
         chunk = (CHUNK *)((char *)chunk + chunk->myFCD->size);
       }
  } while (snap->next != (CHUNK *)BUSY);

  /* check for a valid free address */

  if (check && !valid_free_addr (blk, (CHUNK *)(check - HEADSZ)))
    abort2 (check, name, call);
}
