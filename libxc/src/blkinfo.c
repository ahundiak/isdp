#include <alloca.h>
#include "blockpvt.h"

#define  K       1024
#define  M     (K * K)

#define HINFO struct holdinfo
HINFO {
        int count;
        int numfree;
        int numbusy;
        int spacefree;
        int spacebusy;
        int spacetotal;
};

#define CINFO struct chunkinfo
CINFO {
        int numfree;
        int numbusy;
        int spacefree;
        int spacebusy;
        int spacetotal;
};

#define PINFO struct pageinfo
PINFO {
        char *addr;
        int   type;
        int   numfree;
        int   numbusy;
        int   spacefree;
        int   spacebusy;
        int   spacetotal;
};

static CINFO  cinfo[12];
static HINFO *hinfo;
static PINFO *pinfo;
static int    headspace;

static char  *labels[] = { "   <=100    ",
                           ">100  - 200 ",
                           ">200  - 500 ",
                           ">500  - 1K  ",
                           ">1K   - 2K  ",
                           ">2K   - 5K  ",
                           ">5K   - 10K ",
                           ">10K  - 20K ",
                           ">20K  - 50K ",
                           ">50K  - 100K",
                           ">100K - 1M  ",
                           "     >1M    "  };

static int syschunk (blk, chunk)

BLOCK *blk;
CHUNK *chunk;
{
  int index;

  /* is this chunk the one containing the block or the pagemap? */

  if (chunk == (CHUNK *)blk || (char *)chunk + HEADSZ == (char *)blk->pagemap)
    return 1;

  /* does this chunk contain a page? */

  for (index = 1; (uint)index < blk->p_curr + blk->p_avail; index++)
    if (chunk == blk->pagemap[index].header)
      return 1;

  /* DEBUG mode:  is this chunk the snapshot? */

#ifdef DEBUG
  if ((char *)chunk + HEADSZ == (char *)blk->snap_start)
    return 1;
#endif

  return 0;
}

static int chunkindex (size)
{
  if (size <= 100)   return 0;
  if (size <= 200)   return 1;
  if (size <= 500)   return 2;
  if (size <= 1*K)   return 3;
  if (size <= 2*K)   return 4;
  if (size <= 5*K)   return 5;
  if (size <= 10*K)  return 6;
  if (size <= 20*K)  return 7;
  if (size <= 50*K)  return 8;
  if (size <= 100*K) return 9;
  if (size <= 1*M)   return 10;
  return 11;
}

static void get_chunk_info (blk)

BLOCK *blk;
{
  CHUNK *chunk;
  HOLDB *holdblk;
  int    tsize = 0;
  int    usize;
  int    index;

  { CMD *first = blk->memory;

    while (first->left)
      first = first->left;
    chunk = NEXTHEAD (&first[1]);
  }

  for (; chunk->next != (CHUNK *)BUSY; chunk= (CHUNK *)((char *)chunk + tsize))
    switch (STAT (chunk)) {

      case FREE:
        tsize      = chunk->myFCD->size;
        headspace += HEADSZ;
        if (syschunk (blk, chunk)) break;
        index = chunkindex (usize = tsize - HEADSZ);
        cinfo[index].numfree++;
        cinfo[index].spacefree  += usize;
        cinfo[index].spacetotal += usize;
        break;

      case BUSY:
        tsize      = (char *)SET (chunk->next, FREE) - (char *)chunk;
        headspace += HEADSZ;
        if (syschunk (blk, chunk)) break;
        index = chunkindex (usize = tsize - HEADSZ);
        cinfo[index].numbusy++;
        cinfo[index].spacebusy  += usize;
        cinfo[index].spacetotal += usize;
        break;

      case HOLE:
        tsize      = (char *)SET (chunk->next, FREE) - (char *)chunk;
        headspace += HEADSZ;
        break;

      case HOLD:
        tsize      = (char *)SET (chunk->next, FREE) - (char *)chunk;
        headspace += HOLDSZ + blk->numsmall * HEADSZ;
        holdblk    = (HOLDB *)chunk;
        index      = holdblk->csize / ALIGNSZ - 1;
        hinfo[index].count++;
        hinfo[index].numfree += blk->numsmall - holdblk->busy;
        hinfo[index].numbusy += holdblk->busy;
        break;
    }

  for (index = 0; (uint)index < blk->maxsmall / ALIGNSZ; index++) {
    usize = ALIGNSZ * (index + 1) - HEADSZ;
    hinfo[index].spacefree   = hinfo[index].numfree * usize;
    hinfo[index].spacebusy   = hinfo[index].numbusy * usize;
    hinfo[index].spacetotal  = hinfo[index].spacefree +
                               hinfo[index].spacebusy;
  }
}

void get_page_info (blk)

BLOCK *blk;
{
  PAGE *page;
  int   index;

  for (page = blk->pagemap, index = 0; (uint)index < blk->p_curr; index++, page++) {
    pinfo[index].addr       = (char *)page->header + HEADSZ;
    pinfo[index].type       = page->type;
    pinfo[index].numfree    = page->capacity - page->alloc;
    pinfo[index].numbusy    = page->alloc;
    pinfo[index].spacefree  = pinfo[index].numfree * sizeof (FCD);
    pinfo[index].spacebusy  = pinfo[index].numbusy * sizeof (FCD);
    pinfo[index].spacetotal = page->capacity * sizeof (FCD);
  }
}

int blkinfo (blk)

BLOCK *blk;
{
  int totals[7];
  int index;
  int chunkspace = 0;
  int holdspace  = 0;
  int grandtotal = 0;
  int pagespace  = 0;
  int rpagespace = 0;
  int CMDspace   = 0;
  int nsm        = blk->maxsmall / ALIGNSZ;

  if (blk->magic != BLOCKMAGIC) {
    printf ("Bad block magic number!\n");
    return -1;
  }

  pinfo = (PINFO *)alloca (blk->p_curr * sizeof (PINFO));
  if (blk->maxsmall) {
    hinfo = (HINFO *)alloca (index = nsm * sizeof (HINFO));
    memset (hinfo, 0, index);
  }
  memset (cinfo, 0, sizeof (cinfo));
  headspace = HEADSZ;                  /* start with EOB marker */

  get_chunk_info (blk);
  get_page_info (blk);

  /* print configured memory information */

  { CMD *mem;
    CMD *first = blk->memory;

    while (first->left)
      first = first->left;
    mem = first;

    printf ("CONFIGURED MEMORY\n\n     address range            size\n");
    printf ("-----------------------------------\n");
    do {
         printf ("0x%.8x - 0x%.8x  %10d\n", mem->addr,
                                         mem->addr + mem->size - 1, mem->size);
         grandtotal += mem->size;
         CMDspace   += sizeof (CMD);
    } while ((mem = mem->next) != first);
    printf ("%25c-------------------------\n", ' ');
    printf ("%35d bytes total\n\n\n\n\n", grandtotal);
  }

  /***********************************/
  /* print holding block information */
  /***********************************/

  if (blk->maxsmall) {
    printf ("HOLDING BLOCKS (chunks <= %d bytes)\n\n", blk->maxsmall - HEADSZ);
    printf ("chunk size  number of  number of  number of  space in  space in  total\n");
    printf (" (bytes)    hold blks    busy       free       busy      free    space\n");
    printf ("-----------------------------------------------------------------------\n");

    for (index = 0; index < 7; index++)
      totals[index] = 0;
    for (index = 0; index < nsm; index++) {
      printf ("%6d%12d%11d%11d%11d%10d%9d\n", ALIGNSZ * (index + 1) - HEADSZ,
               hinfo[index].count, hinfo[index].numbusy, hinfo[index].numfree,
               hinfo[index].spacebusy, hinfo[index].spacefree,
               hinfo[index].spacetotal);
      totals[0] += hinfo[index].count;
      totals[1] += hinfo[index].numbusy;
      totals[2] += hinfo[index].numfree;
      totals[3] += hinfo[index].spacebusy;
      totals[4] += hinfo[index].spacefree;
      totals[5] += hinfo[index].spacetotal;
    }
    holdspace = totals[5];

    printf ("-----------------------------------------------------------------------\n");
    printf ("TOTALS%12d%11d%11d%11d%10d%9d\n\n\n\n\n", totals[0], totals[1],
                                   totals[2], totals[3], totals[4], totals[5]);
  }

  /***************************/
  /* print chunk information */
  /***************************/

  printf ("REGULAR CHUNKS\n\n");
  printf ("              number of  number of  space in  space in    total\n");
  printf (" size range     busy       free       busy      free      space\n");
  printf ("-----------------------------------------------------------------\n");

  for (index = 0; index < 7; index++)
    totals[index] = 0;
  for (index = 0; index < 12; index++) {
    printf ("%s%8d%11d%12d%10d%11d\n", labels[index],
             cinfo[index].numbusy, cinfo[index].numfree,
             cinfo[index].spacebusy, cinfo[index].spacefree,
             cinfo[index].spacetotal);
    totals[0] += cinfo[index].numbusy;
    totals[1] += cinfo[index].numfree;
    totals[2] += cinfo[index].spacebusy;
    totals[3] += cinfo[index].spacefree;
    totals[4] += cinfo[index].spacetotal;
  }
  chunkspace = totals[4];

  printf ("-----------------------------------------------------------------\n");
  printf ("TOTALS %13d%11d%12d%10d%11d\n\n\n\n\n", totals[0], totals[1],
                                              totals[2], totals[3], totals[4]);

  /**************************/
  /* print page information */
  /**************************/

  printf ("PAGES (FCD storage)\n\n");
  printf (" page                    FCDs  FCDs   space in  space in  total\n");
  printf ("number   address   type  used  avail    used     avail    space\n");
  printf ("----------------------------------------------------------------\n");

  for (index = 0; index < 7; index++)
    totals[index] = 0;
  for (index = 0; (uint)index < blk->p_curr; index++) {
    if (pinfo[index].type != 'L')
      printf ("%4d   0x%.8X    %c%6d%7d%9d%10d%9d\n", index,
              pinfo[index].addr, pinfo[index].type, pinfo[index].numbusy,
              pinfo[index].numfree, pinfo[index].spacebusy,
              pinfo[index].spacefree, pinfo[index].spacetotal);
    else
      printf ("%4d       --        %c%6d%7d%9d%10d%9d\n", index,
              pinfo[index].type, pinfo[index].numbusy,
              pinfo[index].numfree, pinfo[index].spacebusy,
              pinfo[index].spacefree, pinfo[index].spacetotal);
    totals[0] += pinfo[index].numbusy;
    totals[1] += pinfo[index].numfree;
    totals[2] += pinfo[index].spacebusy;
    totals[3] += pinfo[index].spacefree;
    totals[4] += pinfo[index].spacetotal;
  }
  pagespace  = totals[4] - pinfo[0].spacetotal;
  rpagespace = blk->p_avail * PAGESZ;

  printf ("----------------------------------------------------------------\n");
  printf ("TOTALS   %19d%7d%9d%10d%9d\n\n\n\n\n", totals[0], totals[1],
                                              totals[2], totals[3], totals[4]);

  /*****************************/
  /* print summary information */
  /*****************************/

  { int miscspace, alignspace;

    miscspace  = allocsz ((char *)blk + HEADSZ, 0) + allocsz (blk->pagemap, 0);
#ifdef DEBUG
    miscspace += allocsz (blk->snap_start, 0);
#endif
    alignspace = grandtotal - chunkspace - holdspace - headspace - pagespace
                                         - rpagespace - CMDspace - miscspace;

    printf ("SUMMARY\n\n");
    printf ("holding blocks = %8d\n", holdspace);
    printf ("regular chunks = %8d\n", chunkspace);
    printf ("headers        = %8d\n", headspace);
    printf ("pages in use   = %8d\n", pagespace);
    printf ("reserved pages = %8d\n", rpagespace);
    printf ("CMDs           = %8d\n", CMDspace);
    printf ("other data     = %8d\n", miscspace);
    printf ("alignment      = %8d\n", alignspace);
    printf ("                ------------------------\n");
    printf ("                 %8d bytes total\n", grandtotal);
  }

  return 0;
}
