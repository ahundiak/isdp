#include <assert.h>
#include <stdio.h>
#include <alloca.h>
#include "blockpvt.h"

#define  ZEROALLOC  1  /* QUICK FIX TO GET BEHAVIOR LIKE 3X PACKAGE */

/* set this flag is to enable a few extra sanity checks (normally off for speed
   reasons) */

int blk__checks = 0;

/* forward references */

static FCD   *FCD_alloc ();
static void   FCD_release ();
static FCD   *newFCD ();
static CHUNK *holdalloc ();


/*****************************************************************************/
/* When compiled with DEBUG defined, code is generated that attempts to      */
/* detect corruptions of blkalloc's data caused by a user program writing to */
/* memory locations outside of those allocated.  It will also validate the   */
/* pointers handed to blkrealloc and blkfree.  When an error is detected,    */
/* the SIGTRAP signal will be raised to stop execution under the control of  */
/* a debugger.  Without a debugger, the error causes program termination.    */
/* This will NOT detect corruptions caused by bugs within this package (the  */
/* SANITY compile option is provided for this purpose).  The supplimentary   */
/* file blkdebug.c contains the verification code for this mode.             */
/*****************************************************************************/

#ifdef DEBUG
static int blkalloc_cnt   = 0;
static int blkfree_cnt    = 0;
static int blkrealloc_cnt = 0;
static int blkcalloc_cnt  = 0;
static int growblk_cnt    = 0;
static int memtrap_cnt    = 0;

extern void blkdebug_reset ();
extern void blkdebug_setup ();
extern void blkdebug_check ();
#endif

/*****************************************************************************/
/* When compiled with SANITY defined, code is generated that runs sanity     */
/* checks against internal data structures in an effort to verify that the   */
/* algorithms are functioning correctly.  When an error is detected, the     */
/* SIGIOT signal will be raised due to an assertion failure.  Under debugger */
/* control, execution will stop.  Without a debugger, the error causes       */
/* program termination and a core dump.  The supplimentary file blksanity.c  */
/* contains the verification code for this mode.                             */
/*****************************************************************************/

#ifdef SANITY
extern void mverify ();
extern void pverify ();
extern void fverify ();
extern void hverify ();

static void sanity_checks (blk)

BLOCK *blk;
{
  assert (blk->magic == BLOCKMAGIC);
  mverify (blk);
  pverify (blk);
  fverify (blk);
  hverify (blk);  
}
#endif


static int extra_checks (blk, ptr)

BLOCK *blk;
char  *ptr;
{
  CMD *curr = blk->memory;

  while (curr)
    if (ptr < curr->addr)
      curr = curr->left;
    else if (ptr >= curr->addr + curr->size)
      curr = curr->right;
    else return 1;
  return 0;
}

/* rebalances when right subtree shrinks; returns 1 if new tree smaller */

static int balance_r (pp)

CMD **pp;
{
  CMD *p = *pp, *p1, *p2;

  switch (p->bal) {
    case R: p->bal = B; return 1;
    case B: p->bal = L; return 0;
    case L: break;
  }
  p1 = p->left;
  p2 = p1->right;

  /* rotate double LR */

  if (p1->bal == R) {
    *pp = p2;
    p1->right = p2->left;
    p->left   = p2->right;
    p2->left  = p1;
    p2->right = p;
    p->bal  = (p2->bal == L ? R : B);
    p1->bal = (p2->bal == R ? L : B);
    p2->bal = B;
    return 1;
  }

  /* rotate single LL */

  *pp = p1;
  p->left   = p1->right;
  p1->right = p;
  if (p1->bal == L) {
    p->bal = p1->bal = B;
    return 1;
  }
  p->bal  = L;
  p1->bal = R;
  return 0;
}

/* rebalances when left subtree shrinks; returns 1 if new tree smaller */

static int balance_l (pp)

CMD **pp;
{
  CMD *p = *pp, *p1, *p2;

  switch (p->bal) {
    case L: p->bal = B; return 1;
    case B: p->bal = R; return 0;
    case R: break;
  }
  p1 = p->right;
  p2 = p1->left;

  /* rotate double RL */

  if (p1->bal == L) {
    *pp = p2;
    p->right  = p2->left;
    p1->left  = p2->right;
    p2->left  = p;
    p2->right = p1;
    p->bal  = (p2->bal == R ? L : B);
    p1->bal = (p2->bal == L ? R : B);
    p2->bal = B;
    return 1;
  }

  /* rotate single RR */

  *pp = p1;
  p->right = p1->left;
  p1->left = p;
  if (p1->bal == R) {
    p->bal = p1->bal = B;
    return 1;
  }
  p->bal  = R;
  p1->bal = L;
  return 0;
}

static CMD *target;   /* target for insert or delete */

static int tree_insert (rootp)

CMD **rootp;
{
  CMD *root = *rootp;

  /* empty root:  then resulting tree is the new node! */

  if (!root) {
    *rootp = target;
    return 1;
  }

  /* insert into left subtree? */

  if (target->addr < root->addr)
    return tree_insert (&root->left) ? !balance_r (rootp) : 0;

  /* insert into right subtree? */

  return tree_insert (&root->right) ? !balance_l (rootp) : 0;
}

static int descend (rootp)

CMD **rootp;
{
  CMD *root = *rootp;

  if (root->right)
    return descend (&root->right) ? balance_r (rootp) : 0;

  *rootp      = root->left;
  root->left  = target->left;
  root->right = target->right;
  root->bal   = target->bal;
  target      = root;
  return 1;
}


static int tree_delete (rootp)

CMD **rootp;
{
  CMD *root = *rootp;

  if (target->addr < root->addr)
    return tree_delete (&root->left) ? balance_l (rootp) : 0;

  if (target->addr > root->addr)
    return tree_delete (&root->right) ? balance_r (rootp) : 0;

  if (!root->left) {
    *rootp = root->right;
    return 1;
  }

  if (!root->right) {
    *rootp = root->left;
    return 1;
  }

  if (descend (&root->left)) {
    *rootp = target;
    return balance_l (rootp);
  }
  *rootp = target;
  return 0;
}

static void addCMD (blk, prev, new)

BLOCK *blk;
CMD   *prev;
CMD   *new;
{
  CMD *next = prev->next;

  /* insert into the linked list */

  (new->next = next)->prev = (new->prev = prev)->next = new;

  /* insert into the AVL tree */

  new->left  = 0;
  new->right = 0;
  new->bal   = B;
  target     = new;
  tree_insert (&blk->memory);
}


static void removeCMD (blk, del)

BLOCK *blk;
CMD   *del;
{
  /* remove from the linked list */

  (del->prev->next = del->next)->prev = del->prev;

  /* remove from the AVL tree */

  target = del;
  tree_delete (&blk->memory);
}

static CMD *findCMD (blk, addr, size)

BLOCK *blk;
char  *addr;
uint   size;
{
  CMD *curr = blk->memory;

  while (1) {
    if (addr + size <= curr->addr)
      if (curr->left)
        curr = curr->left;
      else return curr;
    else if (addr >= curr->addr + curr->size)
      if (curr->right)
        curr = curr->right;
      else return curr;
    else return 0;
  }
}

static int fcdindex (uint size)
{
  int ndx = 0;

  while (size >>= 1)
    ndx++;
  return ndx;
}


static void add_to_index (blk, theFCD)

BLOCK *blk;
FCD   *theFCD;
{
  int ndx = fcdindex (theFCD->size);

  /* insert into the bucket */

  if (blk->fcdindex[ndx]) {
    theFCD->prev_x = (theFCD->next_x = blk->fcdindex[ndx])->prev_x;
    theFCD->next_x->prev_x = theFCD->prev_x->next_x = theFCD;
  }
  else blk->fcdindex[ndx] = theFCD->prev_x = theFCD->next_x = theFCD;
}


static void del_from_index (blk, theFCD)

BLOCK *blk;
FCD   *theFCD;
{
  int ndx = fcdindex (theFCD->size);

  /* check for deleting the bucket head */

  if (blk->fcdindex[ndx] == theFCD)
    if ((blk->fcdindex[ndx] = theFCD->next_x) == theFCD)
      blk->fcdindex[ndx] = 0;

  /* remove from the bucket */

  (theFCD->prev_x->next_x = theFCD->next_x)->prev_x = theFCD->prev_x;
}

static void physical_install (blk, page, prev, new)

BLOCK *blk;
PAGE  *page;
FCD   *prev;
FCD   *new;
{
  FCD *next = prev->next;

  /* insert new FCD into queue */

  (new->next = next)->prev = (new->prev = prev)->next = new;
  add_to_index (blk, new);

  /* update page information */

  if (!INSTORE (new)) {
    if (!page->first || new->addr <= page->first->addr)
      page->first = new;
    if (!page->last || new->addr >= page->last->addr)
      page->last = new;
    page->alloc++;
  }
}


static void physical_remove (blk, page, theFCD)

BLOCK *blk;
PAGE  *page;
FCD   *theFCD;
{
  /* remove FCD from the queue */

  (theFCD->prev->next = theFCD->next)->prev = theFCD->prev;
  del_from_index (blk, theFCD);

  /* update page information */

  if (!INSTORE (theFCD)) {
    if (!--page->alloc)
      page->first = page->last = 0;
    else {
      if (theFCD == page->first) {
        page->first = theFCD->next;
        while (INSTORE (page->first)) page->first = page->first->next;
      }
      if (theFCD == page->last) {
        page->last = theFCD->prev;
        while (INSTORE (page->last)) page->last = page->last->prev;
      }
    }
  }
}

static FCD *shift (blk, from, to)

BLOCK *blk;
PAGE  *from;
PAGE  *to;
{
  FCD  *avail;
  FCD  *new;
  PAGE *adjacent;
  int   dir = (from > to ? 1 : -1);

  /* get available FCD from destination page */

  to->avail = (avail = to->avail)->next;

  /* shift FCDs from adjacent pages until an available FCD on the origin
     page is obtained */

  while (from != to) {

    /* Locate an FCD that can be stolen by shifting it to an adjacent page.
       This FCD is either the first or last member of the page (depending on
       the shift direction). */

    adjacent = &to[dir];
    new      = (dir > 0 ? adjacent->first : adjacent->last);

    /* move the FCD we are stealing to the adjacent page */

    avail->addr = new->addr;
    avail->size = new->size;
    physical_remove (blk, adjacent, new);
    physical_install (blk, to, new->prev, avail);

    /* since we just changed the address of this FCD, pointers to it need
       to be updated! */

    if (blk->fhead == new)
      blk->fhead = avail;
    avail->addr->myFCD = avail;

    /* the FCD we have just stolen is now available but additional shifting
       may be needed for distances of more than one page */

    avail = new;
    to   += dir;
  }

  return avail;
}

static void create_page (page, type, chunk, size)

PAGE  *page;
int    type;
CHUNK *chunk;
uint   size;
{
  page->type  = type;
  page->alloc = 0;
  page->first = page->last = 0;

  if (page->header = chunk) {
    FCD *theFCD = (FCD *)((char *)chunk + HEADSZ);
    int  cnt    = (size - HEADSZ) / sizeof (FCD);

    page->capacity = cnt;
    page->avail    = theFCD;
    while (--cnt)
      theFCD = theFCD->next = theFCD + 1;
    theFCD->next = 0;
  }
  else {
    page->capacity = 0;
    page->avail    = 0;
  }
}

static PAGE *page_lookup (blk, addr)

BLOCK *blk;
CHUNK *addr;
{
  int limit = !blk->pagemap[0].alloc;
  int low   = limit;
  int high  = blk->p_curr - 1;
  int mid;

  do {
       if (blk->pagemap[mid = (low + high) / 2].first->addr > addr)
         high = mid - 1;
       else low = mid + 1;
  } while (low <= high);

  return &blk->pagemap[high < limit ? limit : high];
}

static CHUNK *pagealloc (blk, typeptr, sizeptr)

BLOCK *blk;
int   *typeptr;
uint  *sizeptr;
{
  FCD   *theFCD;
  CHUNK *pchunk = 0;
  char  *newpage = 0;
  uint   psize = 0;
  int    type = 0;

search:
  if (theFCD = blk->fhead)
    do {
         uint  size;
         char *start = (char *)theFCD->addr + HEADSZ;
         char *end   = (char *)theFCD->addr + theFCD->size;
         char *bnd   = (char *)ALIGN (start, PAGESZ);

         if (bnd + PAGESZ <= end) {
           type    = 'P';
           psize   = PAGESZ;
           pchunk  = theFCD->addr;
           newpage = bnd;
           goto great;
         }

         size = MIN (PAGESZ, end - start);
         if (size > psize && size >= MINPGSIZE * sizeof (FCD)) {
           type    = 'N';
           psize   = size;
           pchunk  = theFCD->addr;
           newpage = start;
         }

    } while ((theFCD = theFCD->next) != blk->fhead);

  /* since we did not get the best kind of page, at least give the user's
     memory function a chance to give us enough space to do so */

  if (blk->mem_fn &&
        blk->mem_fn (blk, MINGROW (CHUNKSZ (PAGESZ) + PAGESZ), 1) == MAL_RETRY)
    goto search;
  if (!type)
    return 0;

  /* otherwise we have to make do with what we found */

great:
  {
    FCD   *availFCD;
    CHUNK *chunk1 = (CHUNK *)(newpage - HEADSZ);
    CHUNK *chunk2 = (CHUNK *)((char *)chunk1 + CHUNKSZ (psize));
    CHUNK *chunk3 = (CHUNK *)((char *)pchunk + pchunk->myFCD->size);

    if ((char *)chunk1 - (char *)pchunk >= MINCHUNK) {
      availFCD = 0;
      del_from_index (blk, pchunk->myFCD);
      pchunk->myFCD->size = (char *)chunk1 - (char *)pchunk;
      add_to_index (blk, pchunk->myFCD);
    }
    else {
      availFCD = pchunk->myFCD;
      chunk1   = pchunk;
    }

    if ((char *)chunk3 - (char *)chunk2 >= MINCHUNK)
      if (availFCD) {
        del_from_index (blk, availFCD);
        (availFCD->addr = chunk2)->myFCD = availFCD;
        availFCD->size  = (char *)chunk3 - (char*)chunk2;
        add_to_index (blk, availFCD);
      }
      else newFCD (blk, chunk2, (char *)chunk3 - (char *)chunk2);
    else {
      chunk2 = chunk3;
      if (availFCD)
        FCD_release (blk, (PAGE *)0, availFCD);
    }

    (pchunk = chunk1)->next = SET (chunk2, BUSY);
  }

  /* return info to the caller */

  *typeptr = type;
  *sizeptr = CHUNKSZ (psize);
  return pchunk;
}

static void pagefree (blk, page)

BLOCK *blk;
PAGE  *page;
{
  /* the logical page and one other must always be retained! */

  if (blk->p_curr > 2 && page->type != 'L') {
    PAGE  save;
    PAGE *temp = &blk->pagemap[blk->p_curr--];

    /* save a copy of the page being freed and then adjust the pagemap */

    save = page[0];
    while (++page < temp)
      page[-1] = page[0];

    /* hold physical pages in reserve at the end of the pagemap */

    if (save.type == 'P') {
      page[-1] = save;
      blk->p_avail++;
    }

    /* free the space allocated to other types */

    else {
      uint size = (char *)SET (save.header->next, FREE) - (char *)save.header;
      newFCD (blk, save.header, size);
      if (blk->p_avail)
        page[-1] = blk->pagemap[blk->p_curr + blk->p_avail];
    }
  }
}

static int stretch_logical (blk)

BLOCK *blk;
{
  PAGE   temp;
  HOLDB *hold;
  CHUNK *biggest = 0;
  FCD   *theFCD;
  int    index;
  int    size = 0;

  /* find the largest free chunk that exists */

  if (theFCD = blk->fhead)
    do {
         if (theFCD->size > size) {
           size    = theFCD->size;
           biggest = theFCD->addr;
         }
    } while ((theFCD = theFCD->next) != blk->fhead);

  /* see if we can do any better using a holding block */

  index = blk->maxsmall / ALIGNSZ - 1;
  while (1)
    if (!blk->small || (hold = blk->small[index])->csize <= (uint)size) {
      if (size < CHUNKSZ (sizeof (FCD)))
        return 0;
      FCD_release (blk, (PAGE *)0, biggest->myFCD);
      biggest->next = SET ((char *)biggest + size, BUSY);
      break;
    }
    else if (hold->freeq) {
      if ((size = hold->csize) < CHUNKSZ (sizeof (FCD)))
        return 0;
      biggest = holdalloc (blk, size);
      break;
    }

  /* now we have found a chunk we can use */

  create_page (&temp, 'L', biggest, size);
  temp.avail[temp.capacity - 1].next = blk->pagemap[0].avail;
  blk->pagemap[0].avail              = temp.avail;
  blk->pagemap[0].capacity          += temp.capacity;
  return 1;
}

static int physical_split (blk, page)

BLOCK *blk;
PAGE  *page;
{
  PAGE   new;
  PAGE  *temp;
  CHUNK *pchunk;
  uint   size;
  int    type;

  /* see if there is a page already available first */

  if (blk->p_avail) {
    new = blk->pagemap[blk->p_curr];
    blk->p_avail--;
  }
  else {

    /* enlarge the pagemap if required */

    { int needspace = (blk->p_curr + 1) * sizeof (PAGE);
      int pageno    = page - blk->pagemap;

      if (needspace > allocsz (temp = blk->pagemap, 0))
        if (!(blk->pagemap = (PAGE *)blkrealloc (blk, temp, needspace))) {
          blk->pagemap = temp;
          return 0;
        }
        else page = blk->pagemap + pageno;
    }

    /* get a new page */

    if (!(pchunk = pagealloc (blk, &type, &size)))
      return 0;
    create_page (&new, type, pchunk, size);
  }

  /* insert the new page we just obtained into the pagemap so that it follows
     the one being split */

  temp = &blk->pagemap[blk->p_curr++];
  while (--temp > page)
    temp[1] = temp[0];
  temp[1] = new;

  /* move FCDs from the full page onto the new one such that FCDs are
     available on both pages.  if we were splitting the logical page try
     to move all of them */

  { FCD *theFCD;
    int  numtomove = MIN (page[0].alloc, page[1].capacity) / 2U;

    if (page[0].type == 'L' && page[0].alloc < page[1].capacity)
      numtomove = page[0].alloc;
    while (numtomove--) {
      theFCD = shift (blk, page, page + 1);
      theFCD->next = page->avail;
      page->avail  = theFCD;
    }
  }

  /* return success */

  return 1;
}

static int splitpage (blk, page)

BLOCK *blk;
PAGE  *page;
{
  PAGE *oldpage;
  PAGE *newpage;
  FCD  *new;
  FCD  *theFCD;
  int   pagefail;

  /* if there are reserved pages, the store does not need to be initialized */

  if (blk->p_avail)
    return physical_split (blk, page);

  /* Initialize storage area for holding FCDs created during a physical page
     split.  Formula is based on a worst-case scenario of having to split
     every other page producing 5 FCDs each (actually the maximum is more
     like 3:  one from a growblk, one from pagealloc, and one from reallocing
     the pagemap).  This assumes that the user's memory function does not
     attempt to free up currently used space to satisfy the need. */

  blk->s_avail = (blk->p_curr + 1) / 2U * 5;
  blk->store   = (FCD *)alloca (blk->s_avail * sizeof (FCD));

  /* split the given page */

  pagefail = !physical_split (blk, page);

  /* Now take care of all FCDs that wound up in the storage area.  A size
     of zero identifies an FCD that was released after being placed on the
     store. */

  while (blk->s_curr)
    if ((theFCD = &blk->store[--blk->s_curr])->size) {

      /* try to allocate an FCD from the appropiate page and if successful,
         we install it in front of its copy in the store.  we have to bypass
         the normal FCD installer because with the store initialized it can
         allocate FCDs from the store and this does us no good since our job
         is to get them out of there!!  Note that during degraded operations
         (using the logical page, etc) it is possible for FCD_alloc to
         release the FCD we are attempting to remove from the store; this
         has happened if the size becomes zero and we must "unallocate" the
         new FCD in this case! */

      oldpage = page_lookup (blk, theFCD->addr);
      if (new = FCD_alloc (blk, oldpage, theFCD->addr, &newpage, pagefail)) {
        if (!(new->size = theFCD->size)) {
          new->next      = newpage->avail;
          newpage->avail = new;
          continue;
        }
        (new->addr = theFCD->addr)->myFCD = new;
        physical_install (blk, newpage, theFCD, new);
      }

      /* failure to allocate an FCD requires that we split another page.
         leave this FCD in the store (we will get back to it later). */

      else {
        blk->s_curr++;
        pagefail = !physical_split (blk, newpage);
        continue;
      }

      /* release this FCD since we are now finished with it */

      FCD_release (blk, oldpage, theFCD);
    }

  /* when we get here, we are all done.  free the store and return success
     or failure indication. */

  blk->store   = 0;
  blk->s_avail = 0;
  return pagefail;
}

static FCD *findFCD (page, addr)

PAGE  *page;
CHUNK *addr;
{
  CHUNK *mid = (CHUNK *)(((uint)page->first->addr + (uint)page->last->addr)/2);
  FCD   *fcd = (addr > mid ? page->last : page->first);

  /* search direction is chosen so as to minimize the number of FCDs we are
     likely to examine. */

  if (addr < fcd->addr) {
    for (fcd = fcd->prev; addr < fcd->addr; fcd = fcd->prev)
      if (fcd->addr >= fcd->next->addr) break;
  }
  else {
    for (fcd = fcd->next; addr > fcd->addr; fcd = fcd->next)
      if (fcd->addr <= fcd->prev->addr) break;
    fcd = fcd->prev;
  }

  return fcd;
}

static FCD *FCD_alloc (blk, page, addr, pageptr, force)

BLOCK *blk;
PAGE  *page;
char  *addr;
PAGE **pageptr;
int    force;
{
  PAGE *source;
  FCD  *theFCD;

  /* find the page if not supplied */

  if (!page)
    page = page_lookup (blk, (CHUNK *)addr);
  *pageptr = page;

  /* check first for an available FCD */

  if (theFCD = page->avail)
    page->avail = theFCD->next;
  else{

    /* failing that, we will attempt to obtain an FCD by shifting */

    PAGE *maxpage  = &blk->pagemap[blk->p_curr - 1];
    PAGE *minpage  = &blk->pagemap[1];
    int   distance = 0;
    int   maxdist  = MAX (maxpage - page, page - minpage);

    /* determine minimum shift distance needed */

    while (++distance <= maxdist) {
      if ((source = page + distance) <= maxpage && source->avail)
        goto doshift;
      if ((source = page - distance) >= minpage && source->avail)
        goto doshift;
    }

    /* if we got here then every single page (except the logical one) must be
       full.  If "force" is set, then we have no alternative except to use
       the logical page.  Since stretch_logical releases an FCD, it is worth
       checking for it before shifting! */

    if (!force)
      return 0;
    if ((source = &blk->pagemap[0])->avail || stretch_logical (blk)) {
      if (theFCD = page->avail) {
        page->avail = theFCD->next;
        return theFCD;
      }
      distance = page - source;

      /* check for boundary cases:  if the FCD we are allocating would be the
         first or last member of this page, one less shift is needed (provided
         the shift direction is appropiate) since it can be installed on an
         adjacent page. */

doshift:
      if (addr >= (char *)page->last->addr && page < source)
        *pageptr = ++page, distance--;
      if (addr <= (char *)page->first->addr && source < page)
        *pageptr = --page, distance--;

      /* we are not allowed to shift a distance greater than one unless "force"
         is set. */

      theFCD = (distance > 1 && !force ? 0 : shift (blk, page, source));
    }

    /* if we got here then all efforts to allocate an FCD have failed.  This
       means that nowhere is there a chunk of memory large enough to hold even
       a single FCD!!  In this case we will appropiate an existing FCD (which
       is describing a very small chunk of memory).  As a result, the memory
       it describes will become perminately "busy". */

    else {
      FCD_release (blk, page, theFCD = page->first);
      theFCD->addr->next = SET ((char *)theFCD->addr + theFCD->size, BUSY);
      page->avail = 0;
    }
  }

  /* all done! */

  return theFCD;
}

static void FCD_release (blk, page, theFCD)

BLOCK *blk;
PAGE  *page;
FCD   *theFCD;
{
  /* find the page if not supplied */

  if (!page)
    page = page_lookup (blk, theFCD->addr);

  /* remove the FCD from the queue */

  physical_remove (blk, page, theFCD);

  /* update any pointers to the FCD being released */

  if (blk->fhead == theFCD)
    blk->fhead = (theFCD->next == theFCD ? 0 : theFCD->next);

  /* make available for re-use */

  if (INSTORE (theFCD))
    theFCD->size = 0;
  else {
    theFCD->next = page->avail;
    page->avail  = theFCD;
  }

  /* can the page now be freed? */

  if (!page->alloc)
    pagefree (blk, page);
}

static FCD *newFCD (blk, addr, size)

BLOCK *blk;
CHUNK *addr;
uint   size;
{
  PAGE *page;
  FCD  *prev;
  FCD  *next;
  FCD  *new;

  /* take care of empty free queue case here */

  if (!blk->fhead) {
    new = blk->fhead = (page = &blk->pagemap[1])->avail;
    page->alloc++;
    page->avail = new->next;
    page->first = page->last   = new;
    new->prev   = new->next    = new;
    (new->addr  = addr)->myFCD = new;
    new->size   = size;
    add_to_index (blk, new);
    return new;
  }

  /* determine the page from which the new FCD should be allocated and the
     two FCDs between which the new one must be inserted. */

  page = page_lookup (blk, addr);
  next = (prev = findFCD (page, addr))->next;

  /* determine which of the possible coalescing situations applies in
     this case */

  { int situation = 0;

    if ((char *)prev->addr + prev->size == (char *)addr)
      situation += 1;
    if ((char *)addr + size == (char *)next->addr)
      situation += 2;

    /* perform any possible coalescing of FCDs (the header of a freed chunk
       is cleared to protect us from twits who free things twice) */

    switch (situation) {

      case 0: break;
      case 1: del_from_index (blk, prev);
              prev->size += size;
              add_to_index (blk, prev);
              addr->next  = 0;
              return prev;
      case 2: (next->addr = addr)->myFCD = next;
              del_from_index (blk, next);
              next->size += size;
              add_to_index (blk, next);
              return next;
      case 3: del_from_index (blk, prev);
              prev->size += size + next->size;
              add_to_index (blk, prev);
              FCD_release (blk, (PAGE *)0, next);
              addr->next = 0;
              return prev;
    }
  }

  /* if we got this far, the new FCD cannot be coalesced with any existing
     ones and hence a new FCD must be allocated.  An FCD from the store will
     be used should the normal allocation fail while the store is initialized
     (this condition indicates that a page split operation is currently in
     work and must complete before continuing).  the while loop doing the
     splitpage call is needed since it is concievable that the process of
     splitting could produce new FCDs in sufficient quantity to fill the page
     just acquired! */

  if (new = page->avail)
    page->avail = new->next;
  else if (new = FCD_alloc (blk, page, (char *)addr, &page, 0))
    prev = findFCD (page, addr);
  else if (blk->store) {
    assert (blk->s_curr < blk->s_avail);
    new = &blk->store[blk->s_curr++];
  }
  else {
    while (!(new = FCD_alloc (blk, (PAGE *)0, (char *)addr, &page, splitpage (blk, page))));
    prev = findFCD (page, addr);
  }

  /* finally install the FCD just acquired */

  (new->addr = addr)->myFCD = new;
  new->size  = size;
  physical_install (blk, page, prev, new);
  return new;
}

static FCD *findfirst (FCD *start, uint size)
{
  FCD *curr = start;

  do {
    if (curr->size >= size)
      return curr;
  } while ((curr = curr->next_x) != start);

  return 0;
}


static FCD *findbest (FCD *start, uint size)
{
  FCD  *curr   = start;
  FCD  *best   = 0;
  uint  bestsz = (uint)-1;

  do {
    if ((curr->size >= size) && (curr->size < bestsz))
      bestsz = (best = curr)->size;
  } while ((curr = curr->next_x) != start);

  return best;
}


static CHUNK *findspace (blk, size)

BLOCK *blk;
uint   size;
{
  CHUNK *thechunk;
  FCD   *theFCD;
  int    ndx;

  /* search for a FCD large enough */

retry:
  for (ndx = fcdindex (size); ndx < blk->ndxlimit; ndx++) {
    if (blk->fcdindex[ndx]) {
      if (theFCD = ((ndx < blk->ndxbest) ? findfirst : findbest)
                                                  (blk->fcdindex[ndx], size)) {
        thechunk = theFCD->addr;

        /* here, free space is left over at the end of the chunk */

        if (theFCD->size - size >= MINCHUNK) {
          blk->fhead     = theFCD;
          del_from_index (blk, theFCD);
          theFCD->size  -= size;
          add_to_index (blk, theFCD);
          (theFCD->addr= (CHUNK *)((char *)thechunk + size))->myFCD = theFCD;
          thechunk->next = SET (theFCD->addr, BUSY);
        }

        /* here, we are using the entire chunk */

        else {
          blk->fhead     = theFCD->next;
          thechunk->next = SET ((char *)thechunk + theFCD->size, BUSY);
          FCD_release (blk, (PAGE *)0, theFCD);
        }

        return thechunk;
      }
    }
  } while (ndx--);

  /* if we made it this far, not enough space remains in the block to satisfy
     the request.  the only way to obtain more memory is by enlarging the
     block */

  if (blk->mem_fn && blk->mem_fn (blk, MINGROW (size), 0))
    goto retry;
  return 0;
}

static CHUNK *holdalloc (blk, size)

BLOCK *blk;
uint   size;
{
  CHUNK *alloc;
  HOLDB *holdblk;
  int    holdindex;

  holdblk = blk->small[holdindex = size / ALIGNSZ - 1];
  if (!holdblk || !holdblk->freeq) {
    HOLDB *new;
    HOLDB *prev;
    HOLDB *next;
    uint   need = ALIGN (HOLDSZ, ALIGNSZ) + size * blk->numsmall;

    /* get a new holding block */

    if (!(new = (HOLDB *)findspace (blk, need)))
      return 0;
    if (!(next = holdblk))
      prev = next = new;
    else prev = next->prev;
    blk->small[holdindex] = holdblk = new;

    /* initialize the new holding block */

    new->header = SET (new->header, HOLD);
    new->csize  = size;
    new->busy   = 0;
    (new->next = next)->prev = (new->prev = prev)->next = new;

    /* initialize the holding block free queue */

    { CHUNK *temp = new->freeq = NEXTHEAD (&new[1]);
      int    cnt  = blk->numsmall;

      while (--cnt)
        temp = temp->next = (CHUNK *)((char *)temp + size);
      temp->next = 0;
    }
  }

  /* allocate a chunk from the holding block */

  holdblk->freeq = (alloc = holdblk->freeq)->next;
  alloc->next    = SET (holdblk, BUSY);
  holdblk->busy++;
  if (!holdblk->freeq)
    blk->small[holdindex] = holdblk->next;

  return alloc;
}

/*****************************************************************************/
/*									     */
/*  defineblk:  Initialize the area of memory beginning at "start" and       */
/*              containing "size" bytes so that it represents a block within */
/*              which memory may be managed via blkalloc.  NULL is returned  */
/*		if the requested size is less than the minimum block.  Upon  */
/*		success, a pointer to the block is returned (this may not be */
/*		the same as "start" due to alignment requirements).	     */
/*									     */
/*****************************************************************************/

BLOCK *defineblkopt (start, size, maxsmall, numsmall)

void *start;
uint  size;
uint  maxsmall;
uint  numsmall;
{
  BLOCK *blk;
  CHUNK *chunk1, *chunk2, *chunk3, *chunk4, *chunk5;
  CMD   *myCMD;
  int    nsm;

  /* verify the minimum block requirement */

  if (size < MINBLOCK)
    return 0;

  /* determine where the block header is */

  myCMD = (CMD *)ALIGN (start, ALIGNSZ);
  blk   = (BLOCK *)NEXTHEAD (&myCMD[1]);

  /* initialize allocation index which is used for our bucket-based best-fit
     allocation strategy */

  blk->ndxbest  = fcdindex (MINBEST);
  blk->ndxlimit = NPTRBITS;
  blk->fcdindex = (FCD **)((char *)blk + BLOCKSZ);
  for (nsm = blk->ndxlimit; nsm--; blk->fcdindex[nsm] = 0);

  /* initialize holding block stuff:  if either maxsmall or numsmall is zero,
     the use of holding blocks is disabled.  holding block index is made one
     larger than needed to save time calculating indicies. */

  if (maxsmall && numsmall) {
    if ((maxsmall = CHUNKSZ (maxsmall)) > MAXSHORT)
      maxsmall = TRUNC (MAXSHORT, ALIGNSZ);
    if (numsmall > MAXSHORT)
      numsmall = MAXSHORT;
    nsm = (blk->maxsmall = maxsmall) / ALIGNSZ;
    blk->numsmall = numsmall;
    blk->small    = (HOLDB **)&blk->fcdindex[blk->ndxlimit];
    chunk1        = NEXTHEAD (&blk->small[nsm]);
    while (nsm)
      blk->small[--nsm] = 0;
  }
  else {
    blk->small    = 0;
    blk->maxsmall = blk->numsmall = 0;
    chunk1        = NEXTHEAD (&blk->fcdindex[blk->ndxlimit]);
  }

  /* subdivide the remaining space */

  chunk2 = (CHUNK *)((char *)chunk1 + CHUNKSZ (2 * sizeof (PAGE)));
  chunk3 = (CHUNK *)(ALIGN (chunk2, PAGESZ) - HEADSZ);
  chunk4 = (CHUNK *)((char *)chunk3 + CHUNKSZ (PAGESZ));
  chunk5 = PREVHEAD ((char *)start + size);

  /* initialize the pagemap */

  blk->pagemap = (PAGE *)((char *)chunk1 + HEADSZ);
  blk->p_curr  = 2;
  create_page (&blk->pagemap[0], 'L', (CHUNK *)0, 0);
  create_page (&blk->pagemap[1], 'P', chunk3, (char *)chunk4 - (char *)chunk3);

  /* set up configured memory */

  myCMD->addr = start;
  myCMD->size = size;
  myCMD->next = myCMD->prev  = myCMD;
  myCMD->left = myCMD->right = 0;
  myCMD->bal  = B;
  blk->memory = myCMD;

  /* set up linkages (the chunk headers) and the free list */

  blk->fhead  = 0;
  blk->header = SET (chunk1, BUSY);

  if ((size = (char *)chunk3 - (char *)chunk2) >= MINCHUNK) {
    chunk1->next = SET (chunk2, BUSY);
    newFCD (blk, chunk2, size);
  }
  else chunk1->next = SET (chunk3, BUSY);

  chunk3->next = SET (chunk4, BUSY);
  if ((size = (char *)chunk5 - (char *)chunk4) >= MINCHUNK) {
    newFCD (blk, chunk4, size);
    chunk5->next  = SET (0, BUSY);
  }
  else chunk4->next = SET (0, BUSY);

  /* initialize the rest of the block header */

  blk->magic   = BLOCKMAGIC;
  blk->store   = 0;
  blk->s_avail = blk->s_curr = 0;
  blk->p_avail = 0;
  blk->mem_fn  = MAL_DFLT;

  /* DEBUG mode initialization */

#ifdef DEBUG
  blk->mainentry  = 0;
  blk->debug_on   = 1;
  blk->snap_start = 0;
  blk->snap_last  = 0;
  blkdebug_setup (blk);
#endif

  /* check for environment var to turn on error checking */

  { char *val;

    if ((val = (char *)getenv ("BLKCHECKS")) && strcmp (val, "0"))
      blk__checks = 1;
  }

  /* return the block */

  return blk;
}


BLOCK *defineblk (start, size)

void *start;
uint  size;
{
  return defineblkopt (start, size, MAXSMALL, NUMSMALL);
}

/*****************************************************************************/
/*									     */
/*  growblk:  Increase the size of the specified block by attaching the area */
/*	      of memory beginning at "addr" and containing "size" bytes.     */
/*	      The additional space is assumed to have been legimately        */
/*	      obtained.  The new memory cannot overlay any existing portion  */
/*	      of the block.  Zero is returned on success, -1 on error.       */
/*									     */
/*****************************************************************************/

int growblk (blk, addr, size)

BLOCK *blk;
void  *addr;
uint   size;
{
  CMD   *prev;
  CMD   *next;
  CMD   *new;
  CHUNK *chunk1;
  CHUNK *chunk2;

  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  growblk_cnt++;
  if (blk->mainentry) {
    blkdebug_check (blk, 0, "growblk", growblk_cnt);
    trapreturn (blkdebug_setup, blk);
  }
#endif

  /* SANITY mode:  arrange for sanity checks when done */

#ifdef SANITY
  if (!blk->store)
    trapreturn (sanity_checks, blk);
#endif

  /* verify minimal size and magic number */

  if (size < MINGROW (MINCHUNK) || blk->magic != BLOCKMAGIC)
    return -1;

  /* check for overlap error */

  if (!(prev = findCMD (blk, addr, size)))
    return -1;

  /* get previous and next configured memory descriptors */

  if (addr < (void *)prev->addr)
    prev = (next = prev)->prev;
  else next = prev->next;

  /*-------------------------------------------------------------------------*/
  /* CASE 1:  The new memory is contiguous with two sections of configured   */
  /*          memory thereby filling a "hole".                               */
  /*-------------------------------------------------------------------------*/

  if (addr == prev->addr + prev->size)
    if ((char *)addr + size == next->addr) {
      chunk1 = PREVHEAD (addr);
      chunk2 = SET (chunk1->next, FREE);
      prev->size += size + next->size;
      removeCMD (blk, next);
    }

  /*-------------------------------------------------------------------------*/
  /* CASE 2:  The new memory is contiguous with the end of a section of      */
  /*          configured memory.  There may or may not be a section of       */
  /*          configured memory following the new.                           */
  /*-------------------------------------------------------------------------*/

    else {
      chunk1 = PREVHEAD (addr);
      chunk2 = PREVHEAD ((char *)addr + size);
      chunk2->next = chunk1->next;
      prev->size  += size;
    }

  /*-------------------------------------------------------------------------*/
  /* CASE 3:  The new memory is contiguous with the start of a section of    */
  /*          configured memory.  There may or may not be a section of       */
  /*          configured memory prior to the new.                            */
  /*-------------------------------------------------------------------------*/

  else if ((char *)addr + size == next->addr) {
    new    = (CMD *)ALIGN (addr, ALIGNSZ);
    chunk1 = NEXTHEAD (&new[1]);
    chunk2 = NEXTHEAD (&next[1]);

    new->addr = addr;
    new->size = size + next->size;
    addCMD (blk, prev, new);
    removeCMD (blk, next);

    if ((void *)prev->addr < addr)
      (PREVHEAD (prev->addr + prev->size))->next = SET (chunk1, HOLE);
  }

  /*-------------------------------------------------------------------------*/
  /* CASE 4:  The new memory is not contiguous with any other sections of    */
  /*          configured memory.  This will either create a new "hole" or    */
  /*          split an existing "hole" into two parts.                       */
  /*-------------------------------------------------------------------------*/

  else {
    new    = (CMD *)ALIGN (addr, ALIGNSZ);
    chunk1 = NEXTHEAD (&new[1]);
    chunk2 = PREVHEAD ((char *)addr + size);

    if ((void *)prev->addr < addr)
      (PREVHEAD (prev->addr + prev->size))->next = SET (chunk1, HOLE);
    if ((void *)next->addr > addr)
      chunk2->next = SET (NEXTHEAD (&next[1]), HOLE);
    else chunk2->next = SET (0, BUSY);
    new->addr = addr;
    new->size = size;
    addCMD (blk, prev, new);
  }

  /* all done so add a free chunk descriptor for the new memory and return */

  blk->fhead = newFCD (blk, chunk1, (char *)chunk2 - (char *)chunk1);
  return 0;
}

/*****************************************************************************/
/*									     */
/*  allocsz:  Determine the amount of space allocated to the chunk given by  */
/*	      "ptr".  The value of "incall" determines whether or not the    */
/*	      space used by the chunk's header is included in this amount    */
/*	      (if the value is 0, the header is not included).		     */
/*									     */
/*****************************************************************************/

uint allocsz (ptr, incall)

void *ptr;
int   incall;
{
  uint   size;
  CHUNK *thechunk;

  if (!ptr)
    return 0;

  thechunk = (CHUNK *)((char *)ptr - HEADSZ);
  if (STAT (thechunk) != BUSY)
    return 0;

  if (thechunk->next > thechunk)
    size = (char *)SET (thechunk->next, FREE) - (char *)thechunk;
  else size = ((HOLDB *)SET (thechunk->next, FREE))->csize;

  return incall ? size : size - HEADSZ;
}

/*****************************************************************************/
/*									     */
/*  memtrap:  Set the memory trap for block "blk" to the function given by   */
/*	      "fn".  The previous trap is returned unless the given block is */
/*            invalid in which case -1 is returned.			     */
/*									     */
/*****************************************************************************/

int (*memtrap (blk, fn)) ()

BLOCK *blk;
int  (*fn) ();
{
  int (*temp) ();

  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  memtrap_cnt++;
  if (blk->mainentry) {
    blkdebug_check (blk, 0, "memtrap", memtrap_cnt);
    trapreturn (blkdebug_setup, blk);
  }
#endif

  /* verify validity of the given block */

  if (blk->magic != BLOCKMAGIC)
    return (int (*)())-1;

  /* set the trap specified */

  temp        = blk->mem_fn;
  blk->mem_fn = fn;
  return temp;
}

/*****************************************************************************/
/*									     */
/*  blkalloc:  Allocate "request" bytes from the given block.  The actual    */
/*	       amount of memory allocated may be adjusted upward according   */
/*	       to alignment requirements.  The memory allocated will be      */
/*	       properly aligned for any use.  A pointer to the allocated     */
/*	       memory is returned unless the request cannot be satisfied in  */
/*	       which case NULL is returned.				     */
/*									     */
/*****************************************************************************/

char *blkalloc (blk, nbytes)

BLOCK *blk;
uint   nbytes;
{
  CHUNK *alloc;

  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  blkalloc_cnt++;
  if (blk->mainentry) {
    blkdebug_check (blk, 0, "blkalloc", blkalloc_cnt);
    trapreturn (blkdebug_setup, blk);
  }
#endif

  /* SANITY mode:  arrange for sanity checks when done */

#ifdef SANITY
  if (!blk->store)
    trapreturn (sanity_checks, blk);
#endif

  /* if ZEROALLOC is defined, a request for zero bytes actually allocates */

#ifdef ZEROALLOC
  if (!nbytes)
    nbytes = 1;
#endif

  /* check for bad block and zero-sized request */

  if (blk->magic != BLOCKMAGIC || !nbytes)
    return 0;

  /* adjust the requested number of bytes up to an appropiate chunk size */

  nbytes = CHUNKSZ (nbytes);

  /* allocate the memory if possible */

  if (alloc = (nbytes <= blk->maxsmall ? holdalloc : findspace) (blk, nbytes))
    return (char *)alloc + HEADSZ;
  else return 0;
}

/*****************************************************************************/
/*									     */
/*  blkfree:  Free the chunk associated with the given pointer.  It is       */
/*	      assumed that the given pointer corresponds to the start of the */
/*	      data area of a chunk within the given block.  Blkfree returns  */
/*	      -1 on error; 0 otherwise.					     */
/*									     */
/*****************************************************************************/

int blkfree (blk, ptr)

BLOCK *blk;
void  *ptr;
{
  CHUNK *tofree;

  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  blkfree_cnt++;
  if (blk->mainentry) {
    blkdebug_check (blk, ptr, "blkfree", blkfree_cnt);
    trapreturn (blkdebug_setup, blk);
  }
#endif

  /* SANITY mode:  arrange for sanity checks when done */

#ifdef SANITY
  if (!blk->store)
    trapreturn (sanity_checks, blk);
#endif

  /* a null pointer has special treatment so that it may be used as a logical
     "pointer to a zero-sized object" */

  if (!ptr)
    return 0;

  /* check for errors */

  if (blk->magic != BLOCKMAGIC)
    return -1;
  if (blk__checks && !extra_checks (blk, ptr)) {
    fprintf (stderr, "Pointer (0x%.8x) out of domain:  cannot free.\n", ptr);
    return -1;
  }
  tofree = (CHUNK *)((char *)ptr - HEADSZ);
  if (STAT (tofree) != BUSY) {
    if (blk__checks)
      fprintf (stderr, "Pointer (0x%.8x) is free/reserved:  cannot free.\n", ptr);
    return -1;
  }

  /* if the "next" pointer points forward the chunk is a normal one */

  if (tofree->next > tofree)
    newFCD (blk, tofree, (char *)SET (tofree->next, FREE) - (char *)tofree);

  /* otherwise it is a member of a holding block */

  else {
    HOLDB *holdblk   = (HOLDB *)SET (tofree->next, FREE);
    int    holdindex = holdblk->csize / ALIGNSZ - 1;

    /* if all the chunks within this holding block are now free, the holding
       block itself is freed */

    if (!--holdblk->busy) {
      (holdblk->next->prev = holdblk->prev)->next = holdblk->next;
      if (blk->small[holdindex] == holdblk)
        if ((blk->small[holdindex] = holdblk->next) == holdblk)
          blk->small[holdindex] = 0;
      newFCD (blk, (CHUNK *)holdblk,
                        (char *)SET (holdblk->header, FREE) - (char *)holdblk);
    }

    /* otherwise we free only the chunk:  the holding block chains must be
       maintained so that all holding blocks with free space exist at the
       front of the chain! */

    else {
      if (!holdblk->freeq) {
        HOLDB *next = blk->small[holdindex];
        HOLDB *prev = next->prev;

        if (holdblk != prev && holdblk != next) {
          (holdblk->next->prev = holdblk->prev)->next = holdblk->next;
          (holdblk->prev = prev)->next = (holdblk->next = next)->prev =holdblk;
        }
        blk->small[holdindex] = holdblk;
      }
      tofree->next   = holdblk->freeq;
      holdblk->freeq = tofree;
    }
  }

  return 0;
}

/*****************************************************************************/
/*									     */
/*  blkrealloc:  modify the size of the chunk corresponding to "ptr" to be   */
/*		 "nbytes" in length.  The data within the chunk is preserved.*/
/*		 The size of the chunk is changed without moving the data if */
/*		 this is possible.  A chunk being made smaller is guaranteed */
/*		 not to move.  If "nbytes" is zero, the chunk is automati-   */
/*		 cally freed and 0 is returned.  A pointer to the resized    */
/*		 chunk is returned on success (0 otherwise).                 */
/*									     */
/*****************************************************************************/

char *blkrealloc (blk, ptr, nbytes)

BLOCK *blk;
void  *ptr;
uint   nbytes;
{
  CHUNK *thechunk;
  CHUNK *nextchunk;
  FCD   *availFCD;
  uint   newsize;
  uint   orgsize;
  uint   availsize;

  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  blkrealloc_cnt++;
  if (blk->mainentry) {
    blkdebug_check (blk, ptr, "blkrealloc", blkrealloc_cnt);
    trapreturn (blkdebug_setup, blk);
  }
#endif

  /* check for the special case of reallocing a null pointer */

  if (!ptr)
    return blkalloc (blk, nbytes);

  /* check for errors */

  if (blk->magic != BLOCKMAGIC)
    return 0;
  if (blk__checks && !extra_checks (blk, ptr)) {
    fprintf (stderr, "Pointer (0x%.8x) out of domain:  cannot realloc.\n",ptr);
    return 0;
  }
  thechunk = (CHUNK *)((char *)ptr - HEADSZ);
  if (STAT (thechunk) != BUSY) {
    if (blk__checks)
      fprintf (stderr, "Pointer (0x%.8x) is free/reserved:  cannot realloc.\n", ptr);
    return 0;
  }

  /* check for resizing to zero */

#ifdef ZEROALLOC
  if (!nbytes)
    nbytes = 1;
#else
  if (!nbytes) {
    blkfree (blk, ptr);
    return 0;
  }
#endif

  /* SANITY mode:  arrange for sanity checks when done */

#ifdef SANITY
  if (!blk->store)
    trapreturn (sanity_checks, blk);
#endif

  /* adjust the requested number of bytes up to an appropiate chunk size */

  newsize = CHUNKSZ (nbytes);

  /* check to see if the chunk being resized is in a holding block */

  if (thechunk->next < thechunk) {
    HOLDB *holdblk = (HOLDB *)SET (thechunk->next, FREE);

    if (newsize <= (orgsize = holdblk->csize))
      return ptr;
    else goto punt;
  }

  /* determine the current size of this chunk */

  nextchunk = SET (thechunk->next, FREE);
  availsize = orgsize = (char *)nextchunk - (char *)thechunk;

  /* absorb any free space that may follow the chunk */

  if (STAT (nextchunk) == FREE) {
    availsize += (availFCD = nextchunk->myFCD)->size;
    nextchunk  = (CHUNK *)((char *)thechunk + availsize);
  }
  else availFCD = 0;

  /* if there is insufficient room, we have to get the space via blkalloc and
     copy the data there */

  if (newsize > availsize) {
    char *temp;

punt:
    if (temp = blkalloc (blk, nbytes)) {
      blkfree (blk, ptr);
      memcpy (temp, ptr, orgsize - HEADSZ);
    }
    return temp;
  }

  /* a new chunk must be created if enough room is left over to do so */

  else if (availsize - newsize >= MINCHUNK) {
    CHUNK *newchunk = (CHUNK *)((char *)thechunk + newsize);

    thechunk->next = SET (newchunk, BUSY);
    if (availFCD) {
      del_from_index (blk, availFCD);
      (availFCD->addr = newchunk)->myFCD = availFCD;
      availFCD->size = availsize - newsize;
      add_to_index (blk, availFCD);
    }
    else newFCD (blk, newchunk, availsize - newsize);
  }

  /* here, we are using the entire available space */

  else {
    thechunk->next = SET (nextchunk, BUSY);
    if (availFCD)
      FCD_release (blk, (PAGE *)0, availFCD);
  }

  return ptr;
}

/*****************************************************************************/
/*									     */
/*  blkcalloc:  Allocate "nbytes" bytes from the given block.  The allocated */
/*		memory is set to zero.  A pointer to the allocated memory is */
/*		returned unless the request could not be satisfied in which  */
/*		case NULL is returned.					     */
/*                                                                           */
/*****************************************************************************/

char *blkcalloc (blk, nbytes)

BLOCK *blk;
uint   nbytes;
{
  char *ptr;

  /* DEBUG mode:  verify all data */

#ifdef DEBUG
  blkcalloc_cnt++;
  if (blk->mainentry) {
    blkdebug_check (blk, 0, "blkcalloc", blkcalloc_cnt);
    trapreturn (blkdebug_setup, blk);
  }
#endif

  /* if ZEROALLOC is defined, a request for zero bytes actually allocates */

#ifdef ZEROALLOC
  if (!nbytes)
    nbytes = 1;
#endif

  if (ptr = blkalloc (blk, nbytes))
    memset (ptr, '\0', allocsz (ptr, 0));
  return ptr;
}
