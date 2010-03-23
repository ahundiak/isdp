#include <assert.h>
#include "blockpvt.h"

/*****************************************************************************/
/*									     */
/*  memmap:  Print a listing of the chunk layout within the specified block. */
/*           This information includes the address and size of the chunk,    */
/*           its current status, the address of the chunk's header, the      */
/*           total size of the chunk including its header, and if the chunk  */
/*           is free, the address of its FCD and the next free pointer.      */
/*									     */
/*****************************************************************************/

static char *status[4] = { "FREE", "BUSY", "HOLD", "HOLE" };

void memmap (blk)

BLOCK *blk;
{
  CHUNK *chunk;       /* this is the chunk we are printing info about    */
  uint   size;        /* the size of the chunk not including the header  */

  printf ("                               header       total      FCD\n");
  printf ("  address      size    status  address      size     address    next free\n");
  printf ("--------------------------------------------------------------------------\n\n");

  if (!blk || blk->magic != BLOCKMAGIC)
    return;

  { CMD *mem = blk->memory;

    while (mem->left)
      mem = mem->left;
    chunk = NEXTHEAD (&mem[1]);
  }

  while (chunk->next != (CHUNK *)BUSY) {
    if (STAT (chunk) == FREE)
      size = chunk->myFCD->size;
    else size = (char *)SET (chunk->next, FREE) - (char *)chunk;

    printf ("  %.8X %10u   %s   %.8X %10u", (char *)chunk + HEADSZ,
                                            size - HEADSZ,
                                            status[STAT (chunk)], chunk, size);

    switch (STAT (chunk)) {
      case HOLD: { HOLDB *holdblk = (HOLDB *)chunk;
                   CHUNK *small   = NEXTHEAD (&holdblk[1]);
                   int    index   = blk->numsmall;

                   printf ("\n");
                   for (; index > 0; index--) {
                     printf ("  %.8X %10u   %s   %.8X %10u\n",
                                   (char *)small  + HEADSZ,
                                   holdblk->csize - HEADSZ,
                                   status[STAT (small)], small,holdblk->csize);
                     small = (CHUNK *)((char *)small + holdblk->csize);
                   }
                 }
                 break;
      case FREE: printf ("   %.8X   %.8X\n", chunk->myFCD,
                                                     chunk->myFCD->next->addr);
                 break;
      case BUSY:
      case HOLE: printf ("\n");
    }

    chunk = (CHUNK *)((char *)chunk + size);
  }
}

/* configured memory sanity checks */

static int tree_verify (root)

CMD *root;
{
  int ldepth, rdepth;

  /* verify left subtree */

  if (root->left) {
    assert (root->left->addr < root->addr);
    ldepth = tree_verify (root->left);
  }
  else ldepth = 0;

  /* verify right subtree */

  if (root->right) {
    assert (root->right->addr > root->addr);
    rdepth = tree_verify (root->right);
  }
  else rdepth = 0;

  /* check balance */

  if (ldepth > rdepth) {
    assert (ldepth - rdepth == 1);
    assert (root->bal == L);
    return ldepth + 1;
  }
  if (rdepth > ldepth) {
    assert (rdepth - ldepth == 1);
    assert (root->bal == R);
    return rdepth + 1;
  }
  assert (root->bal == B);
  return ldepth + 1;
}


void mverify (blk)

BLOCK *blk;
{
  CMD *curr;
  CMD *first = blk->memory;

  /* verify the AVL tree */

  tree_verify (first);

  /* verify the linked list */

  while (first->left)
    first = first->left;
  curr = first;
  do {

    /* verify connectivity */

    assert (curr == curr->next->prev);
    assert (curr == curr->prev->next);

    /* verify order */

    if (curr->next == first)
      assert (curr->addr >= curr->next->addr);
    else assert (curr->addr <= curr->next->addr);

  } while ((curr = curr->next) != first);
}

/* pagemap sanity checks */

void pverify (blk)

BLOCK *blk;
{
  PAGE *page;
  PAGE *lastpage;
  PAGE *firstpage;
  FCD  *availFCD;
  int   availcnt;

  lastpage = &blk->pagemap[blk->p_curr - 1];
  if (!(firstpage = blk->pagemap)->alloc)
    firstpage++;
  for (page = firstpage; page <= lastpage; page++) {

    /* verify connectivity */

    if (page->alloc) {
      if (page > firstpage)
        assert (page[0].first->prev == page[-1].last);
      else assert (page[0].first->prev == lastpage->last);

      if (page < lastpage)
        assert (page[0].last->next == page[1].first);
      else assert (page[0].last->next == firstpage->first);
    }
    else assert (!page[0].first && !page[0].last);

    /* verify the avail list */

    availcnt = 0;
    availFCD = page->avail;
    for (; availFCD; availcnt++, availFCD = availFCD->next) {

      /* loop test (will detect if "availFCD" points into the free queue) */

      assert (availcnt < page->capacity);

      /* range test (does not apply to the logical page) */

      if (page->type != 'L') {
        assert (availFCD > (FCD *)page->header);
        assert (availFCD < (FCD *)page->header + page->capacity);
      }
    }

    assert (page->capacity == availcnt + page->alloc);
  }
}

/* free queue sanity checks */

void fverify (blk)

BLOCK *blk;
{
  FCD *curr;
  FCD *lfree = blk->pagemap[blk->p_curr - 1].last;

  if (!(curr = blk->fhead))
    return;
  do {
    assert (STAT (curr) == FREE);

    /* verify connectivity */

    assert (curr == curr->next->prev);
    assert (curr == curr->prev->next);

    /* verify order */

    assert ((char *)curr->addr + curr->size > (char *)curr->addr);
    if (curr == lfree)
      assert ((char *)curr->addr + curr->size > (char *)curr->next->addr);
    else
      assert ((char *)curr->addr + curr->size < (char *)curr->next->addr);

  } while ((curr = curr->next) != blk->fhead);
}

/* holding block sanity checks */

void hverify (blk)

BLOCK *blk;
{
  HOLDB *curr;
  int    index;
  int    flag;

  for (index = 0; index < blk->maxsmall / ALIGNSZ; index++) {
    if (!(curr = blk->small[index]))
      continue;
    flag = !curr->freeq;
    do {
      uint hsize = ALIGN (HOLDSZ, ALIGNSZ) + blk->numsmall * curr->csize;

      /* check the header */

      assert (curr->csize  == (index + 1) * ALIGNSZ);
      assert (curr->busy   <= blk->numsmall);
      assert (curr->header == SET ((char *)curr + hsize, HOLD));

      /* verify connectivity */

      assert (curr == curr->next->prev);
      assert (curr == curr->prev->next);

      /* verify the free queue & chunk headers */

      { int    count = 0;
        CHUNK *chunk;

        for (chunk = curr->freeq; chunk; chunk = chunk->next) {
          assert (STAT (chunk) == FREE);
          assert (++count <= blk->numsmall);
          assert ((char *)chunk > (char *)curr);
          assert ((char *)chunk - (char *)curr < hsize);
        }
        assert (curr->busy == blk->numsmall - count);

        chunk = NEXTHEAD (&curr[1]);
        for (count = 0; count < blk->numsmall; count++) {
          if (STAT (chunk) == BUSY)
            assert (chunk->next == SET (curr, BUSY));
          chunk = (CHUNK *)((char *)chunk + curr->csize);
        }
      }

      /* verify order (all holding blocks with free space must come first) */

      if (flag)
        assert (!curr->freeq);
      else flag = !curr->freeq;

    } while ((curr = curr->next) != blk->small[index]);
  }
}
