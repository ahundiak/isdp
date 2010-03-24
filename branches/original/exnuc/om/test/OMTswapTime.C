#include  <stdio.h>
#include  "OMobjectcomm.h"
#include  <assert.h>

#define	OM45	1


#define  PBLOCK       (BLOCK *)0
#define  CBLOCK       (BLOCK *)1
#define  MAL_ABORT         0
#define  MAL_RETRY         1
#define  MAL_DFLT     (int (*)())0


#ifdef clipper
#define  ALIGNSZ           8  /* address alignment (must be a multiple of 4) */
#define  PAGESZ         4096  /* size of a page (ALIGNSZ multiple assumed)   */
#define  BLOCKSZ        4096  /* minimum amount of memory to obtain from sys */
#else
#define  ALIGNSZ           4
#define  PAGESZ         2048
#define  BLOCKSZ        2048
#endif

#define  MINPGFCDS        10         /* number of FCDs on smallest "page"    */
#define  NUMSMALL         10         /* number of small chunks per hold blk  */
#define  MAXSMALL         64         /* bytes in largest small w/o header    */
#define  NSM      (MAXSMALL/ALIGNSZ) /* number of hold block chains needed   */
#define  MINPGALIGN  (PAGESZ / 4)    /* smallest aligned page fraction       */
#define  MINBLOCK    (3 * PAGESZ)    /* smallest definable block             */
#define  MINCHUNK    (2 * ALIGNSZ)   /* smallest chunk including its header  */
#define  BS_INC            5         /* size increment for BStack            */
#define  BLOCKMAGIC   0x426c6b21     /* 4-character ascii for "Blk!"         */

#define  FREE              0
#define  BUSY              1
#define  HOLD              2
#define  HOLE              3

#define  ALIGN(x,f)   (((uint)(x) + (f) - 1) / (f) * (f))
#define  TRUNC(x,f)   ((uint)(x) / (f) * (f))
#define  STAT(x)      ((uint)(x)->next & 3)
#define  SET(x,s)     (CHUNK *)((uint)(x) & ~3 | (s))
#define  HOLDSZ       ALIGN (sizeof (HOLDB), ALIGNSZ)

#define  INSTORE(f) \
\
  (blk->store != NULL && (f) >= blk->store && (f) < &blk->store[blk->s_curr])

#define  uint   unsigned int
#define  ushort unsigned short
#define  uchar  unsigned char
#define  FCD    struct fdesc
#define  PAGE   struct pdesc
#define  FPAGE  struct fpage
#define  BLOCK  struct block
#define  HOLDB  struct hold
#define  CHUNK  union  chunk

union  chunk {
               CHUNK  *next;     /* pointer to the next chunk   (if busy)    */
               FCD    *myFCD;    /* pointer to this chunk's FCD (if free)    */
             };

struct hold  {
               uchar   stat;     /* chunk status bits --> = HOLD             */
               uchar   hsize;    /* holdblk size divided by ALIGNSZ          */
               uchar   csize;    /* size of the chunks contained herein      */
               uchar   busy;     /* number of busy chunks herein             */
               CHUNK  *free;     /* linked free queue                        */
               HOLDB  *next;     /* pointer to next holding block in chain   */
               HOLDB  *prev;     /* pointer to previous hold block in chain  */
             };

struct fdesc {
               CHUNK  *addr;     /* address of this free chunk               */
               uint    size;     /* size in bytes of the free chunk          */
               FCD    *next;     /* pointer to next free chunk descriptor    */
               FCD    *prev;     /* pointer to prev free chunk descriptor    */
             };

struct pdesc {
               CHUNK  *header;   /* pointer to this page's chunk header      */
               char   *paddr;    /* physical starting address of the page    */
               FCD    *first;    /* pointer to first FCD on this page        */
               FCD    *last;     /* pointer to last FCD on this page         */
               FCD    *avail;    /* head of free FCD list for this page      */
               ushort  psize;    /* capacity of this page in FCDs            */
               ushort  class;    /* type of this page (1, 2, or 3)           */
             };

struct fpage {
               CHUNK  *head;      /* pointer to header of chunk page is in   */
               FPAGE  *next;      /* pointer to the next free page           */
             };

struct block {
               CHUNK  *head;      /* the block header is in a busy chunk...  */
               long    magic;     /* magic number for a block                */
               char   *endblk;    /* address of first byte after this block  */
               char   *bgnblk;    /* address of first byte in this block     */
               CHUNK  *first;     /* pointer to the first chunk of block     */
               CHUNK  *last;      /* pointer to the last chunk of block      */
               HOLDB  *small[NSM];/* array of hold blk chains                */
               PAGE   *pagemap;   /* pointer to the page map for this block  */
               FCD    *fhead;     /* pointer to the head of the free list    */
               FCD    *lfree;     /* pointer to FCD of the last free chunk   */
               FCD    *store;     /* pointer to pending FCD storage area     */
               ushort  s_avail;   /* number FCDs available in storage area   */
               ushort  s_curr;    /* number FCDs currently in storage area   */
               FPAGE  *f_pages;   /* linked list of free pages               */
               ushort  p_avail;   /* number of free pages held in reserve    */
               ushort  p_curr;    /* number of pages currently in use        */
               int   (*mem_fn)(); /* function to be called when no memory    */
             };

/*****************************************************************************/
/*									     */
/*  memmap:  Print a listing of the chunk layout within the specified block. */
/*           This information includes the address and size of the chunk,    */
/*           its current status, the address of the chunk's header, the      */
/*           total size of the chunk including its header, and if the chunk  */
/*           is free, the address of its FCD and the next free pointer.      */
/*	     This routine is for debugging purposes and must be compiled     */
/*	     with the TEST switch.					     */
/*									     */
/*****************************************************************************/

static char *status[4] = { "FREE", "BUSY", "HOLD", "HOLE" };
static BLOCK  *pBlk      = NULL;      /* pointer to the primary block        */
static BLOCK  *cBlk      = NULL;      /* pointer to the current block        */

void memmap (blk)

BLOCK *blk;
{
  CHUNK *chunk;       /* this is the chunk we are printing info about    */
  uint   size;        /* the size of the chunk not including the header  */

  /* check for special block values */

  switch ((long)blk) {
    case (long)PBLOCK: blk = pBlk;
                       break;
    case (long)CBLOCK: blk = cBlk;
    default          : break;
  }

  printf ("                               header       total      FCD\n");
  printf ("  address      size    status  address      size     address    next free\n");
  printf ("--------------------------------------------------------------------------\n\n");

  if (blk == NULL || blk->magic != BLOCKMAGIC)
    return;

  chunk = blk->first;
  while (chunk != blk->last) {

    switch (STAT (chunk)) {
      case FREE: size = chunk->myFCD->size;                break;
      case HOLD: size = ((HOLDB *)chunk)->hsize * ALIGNSZ; break;
      case BUSY:
      case HOLE: size = (char *)SET (chunk->next, FREE) - (char *)chunk;
    }

    printf ("  %.8X %10u   %s   %.8X %10u", (char *)chunk + ALIGNSZ,
                                            size - ALIGNSZ,
                                            status[STAT (chunk)], chunk, size);

    switch (STAT (chunk)) {
      case HOLD: { HOLDB *holdblk = (HOLDB *)chunk;
                   CHUNK *small   = (CHUNK *)((char *)holdblk + HOLDSZ);
                   int    index   = NUMSMALL;

                   printf ("\n");
                   for (; index > 0; index--) {
                     printf ("  %.8X %10u   %s   %.8X %10u\n",
                                   (char *)small  + ALIGNSZ,
                                   holdblk->csize - ALIGNSZ,
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

void chkBlkAdr (addr, blk)

char		*addr;

BLOCK *blk;
{
  CHUNK *chunk;       /* this is the chunk we are printing info about    */
  uint   size;        /* the size of the chunk not including the header  */

  /* check for special block values */

  switch ((long)blk) {
    case (long)PBLOCK: blk = pBlk;
                       break;
    case (long)CBLOCK: blk = cBlk;
    default          : break;
  }

  if (blk == NULL || blk->magic != BLOCKMAGIC)
  {
    printf ("BAD BLK(!)\n");
    return;
  }

  chunk = blk->first;
  while (chunk != blk->last) {

    switch (STAT (chunk)) {
      case FREE: size = chunk->myFCD->size;                break;
      case HOLD: size = ((HOLDB *)chunk)->hsize * ALIGNSZ; break;
      case BUSY:
      case HOLE: size = (char *)SET (chunk->next, FREE) - (char *)chunk;
    }
    if (addr > ((char *)chunk) && addr < ((char *)chunk + size))
    {
      switch (STAT (chunk)) 
      {
      case HOLD: { HOLDB *holdblk = (HOLDB *)chunk;
                   CHUNK *small   = (CHUNK *)((char *)holdblk + HOLDSZ);
                   int    index   = NUMSMALL;

                   for (; index > 0; index--) 
                   {
                     if (addr > ((char *)small) &&
                         addr < ((char *)small + holdblk->csize))
                     {
                       if (addr == ((char *)small + ALIGNSZ)) return;
                       else 
                       {
                         printf (" addr (%x) found IN a HOLD BLOCK\n", addr);
                         return;
                       }
                     }
                     small = (CHUNK *)((char *)small + holdblk->csize);
                   }
                 }
                 break;
      case FREE: printf (" addr (%x) found in/on FCD: %.8X\n", addr,
                 chunk->myFCD);
                 break;
      case BUSY: if (addr == ((char *)chunk + ALIGNSZ)) break;
                 printf (" addr (%x) found IN a BUSY block (%x)\n",
                 addr, ((char *)chunk));
                 break;
      case HOLE: printf (" addr (%x) found in/on HOLE: %.8X\n", addr,
                 ((char *)chunk));
                 break;
      }
      return;
    }

    chunk = (CHUNK *)((char *)chunk + size);
  }
}

void fverify (blk)

BLOCK *blk;
{
  FCD *curr;

  /* check for special block values */

  switch ((long)blk) {
    case (long)PBLOCK: blk = pBlk;
                       break;
    case (long)CBLOCK: blk = cBlk;
    default          : break;
  }
  if (blk == NULL)
    return;
  assert (blk->magic == BLOCKMAGIC);

  if ((curr = blk->fhead) == NULL)
    return;
  do {
    assert (STAT (curr) == FREE);

    /* verify connectivity */

    assert (curr == curr->next->prev);
    assert (curr == curr->prev->next);

    /* verify order */

    if (curr == blk->lfree)
      assert (curr->addr >= curr->next->addr);
    else assert (curr->addr <= curr->next->addr);

  } while ((curr = curr->next) != blk->fhead);
}

void hverify (blk)

BLOCK *blk;
{
  HOLDB *curr;
  int    index;
  int    flag;

  /* check for special block values */

  switch ((long)blk) {
    case (long)PBLOCK: blk = pBlk;
                       break;
    case (long)CBLOCK: blk = cBlk;
    default          : break;
  }
  if (blk == NULL)
    return;
  assert (blk->magic == BLOCKMAGIC);

  for (index = 0; index < NSM; index++) {
    if ((curr = blk->small[index]) == NULL)
      continue;
    flag = curr->free == NULL;
    do {

      /* check the header */

      assert (STAT ((CHUNK *)curr) == HOLD);
      assert (curr->busy  <= NUMSMALL);
      assert (curr->csize <= MAXSMALL + ALIGNSZ);
      assert (curr->hsize <  curr->csize * NUMSMALL + HOLDSZ + MINCHUNK);

      /* verify connectivity */

      assert (curr == curr->next->prev);
      assert (curr == curr->prev->next);

      /* verify the free list & chunk headers */

      { int    count = 0;
        CHUNK *chunk;

        for (chunk = curr->free; chunk != NULL; chunk = chunk->next) {
          assert (STAT (chunk) == FREE);
          assert (++count <= NUMSMALL);
          assert ((char *)chunk > (char *)curr);
          assert ((char *)chunk - (char *)curr < ALIGNSZ * curr->hsize);
        }

        chunk = (CHUNK *)((char *)curr + HOLDSZ); 
        for (count = 0; count < NUMSMALL; count++) {
          if (STAT (chunk) == BUSY)
            assert (chunk->next == SET (curr, BUSY));
          chunk = (CHUNK *)((char *)chunk + curr->csize);
        }
      }

      /* verify order */

      if (flag)
        assert (curr->free == NULL);
      else flag = curr->free == NULL;

    } while ((curr = curr->next) != blk->small[index]);
  }
}

void pverify (blk)

BLOCK *blk;
{
  PAGE *page;
  PAGE *lastpage;
  FCD  *availFCD;
  int   availcnt;

  /* check for special block values */

  switch ((long)blk) {
    case (long)PBLOCK: blk = pBlk;
                       break;
    case (long)CBLOCK: blk = cBlk;
    default          : break;
  }
  if (blk == NULL)
    return;
  assert (blk->magic == BLOCKMAGIC);

  lastpage = &(page = blk->pagemap)[blk->p_curr - 1];
  for (;page <= lastpage; page++) {

    /* verify connectivity */

    if (page > blk->pagemap)
      assert (page[0].first->prev == page[-1].last);
    else assert (page[0].first->prev == lastpage->last);

    if (page < lastpage)
      assert (page[0].last->next == page[1].first);
    else assert (page[0].last->next == blk->pagemap->first);

    /* verify the avail list */

    availcnt = 0;
    availFCD = page->avail;
    for (; availFCD != NULL; availcnt++, availFCD = availFCD->next) {

      /* loop test (will detect if "availFCD" points into the free queue) */

      assert (availcnt < page->psize);

      /* range test */

      assert (availFCD >= (FCD *)page->paddr);
      assert (availFCD <  (FCD *)page->paddr + page->psize);
    }    
  }
}

extern	char	*optarg;

int ST_f_verbose = 0;
int ST_f_Verbose = 0;
int ST_Gi_netNeg = 0;
int ST_Gi_netPos = 0;
int ST_f_verbErr = 0;
int ST_i_varyAmt = 0;
int ST_f_showWrStats = 0;
int ST_f_readOnly = 0;
int ST_f_noMod=    0;
int ST_f_debug=    0;
int ST_f_measureMsg =    0;
int ST_f_doRandom =    0;

static  char  filename[132];
static  char  osname[132];
static  char  osclass[32];
char  *ST_profile = filename;
char  *ST_osname = osname;
char  *ST_osclass = osclass;
main(argc,argv)
int     argc;
char    *argv[];

{
  int           sts, ii;
  OM_S_OBJID    STcontrol;
  OM_S_MESSAGE  STmasterControl;
  char          option, *tptr, *dotptr;
  int           specProfile =       0;
  int           specOS =            0;
  int           showWrStats =       0;
  
  strcpy (osclass, "OMFiledOS");
  strcpy (osname, "OMTswapTime.os");
  strcpy (filename, "STproFile.d");
  while (EOF != (option = getopt (argc,argv,"f:mrdNRFtvVea:o:")))
  {
    switch (option)
    {
    case 'm':
      ST_f_measureMsg = 1;
      break;
    case 'r':
      ST_f_doRandom = 1;
      break;
    case 'd':
      ST_f_debug = 1;
      break;
    case 'N':
      ST_f_noMod = 1;
      break;
    case 'R':
      ST_f_readOnly = 1;
      break;
    case 'F':
      ST_f_showWrStats = 1;
      break;
    case 'o':
      specOS = 1;
      strcpy (osname, optarg);
      break;
    case 'a':
      ST_i_varyAmt = atoi (optarg);
      break;
    case 'f':
      specProfile = 1;
      strcpy(filename, optarg);
      break;
    case 't':
      strcpy (osclass, "OMTransOS");
      break;
    case 'v':
      ST_f_verbose = 1;
      break;
    case 'V':
      ST_f_Verbose = 1;
      break;
    case 'e':
      ST_f_verbErr = 1;
      break;
    case '?':
    default:
      printf ("usage: -f <profilename> -t [transient OS] -a varyAmt\n");
      printf ("       -v verbose  -V INIT verbose -e verbose error\n");
      printf ("       -o osname\n");
      printf ("       -N [noModify OS] -R [readOnly OS]\n");
      printf ("       -F show write OS stats\n");
      printf ("       -m [measure msg send] -r [do truly random]\n");
      exit ();
    }
  }
  
  if (specProfile && !specOS)
  {
    strcpy (osname, filename);
    tptr = strrchr (osname, '/');
    if (! (dotptr = strrchr (osname, '.'))) strcat (osname, ".os");
    else if (dotptr > tptr) strcpy (dotptr, ".os");
    else strcat (osname, ".os");
    if (!tptr) tptr = osname;
    if (ii = strlen (tptr) > 14) osname[14] = NULL;
  }
  
  printf ("Initializing\n");
  sts = om$runtime_init();
  if (!(sts&1))
  {
    printf (" error in om$runtime_init : %x \n", sts );
    om$report_error(sts = sts);
    exit();
  }
  printf ("constructing control message\n");
  sts = om$make_message (classname = "STmaster",
                          methodname = "control",
                          p_msg = &STmasterControl);
  if (!(1&(sts)))
  {
    printf ("error in STmaster construction of control msg\n");
    om$report_error (sts = sts);
    exit ();
  }
  printf ("construct STmaster object in TransOS0\n");
#ifdef	OM45
  sts = om$construct (classname = "STmaster",
                      p_objid = &STcontrol,
                      osnum = OM_Gw_TransOSnum_0,
                      msg = &STmasterControl);
#else
  sts = om$construct (classname = "STmaster",
                      p_objid = &STcontrol,
                      osnum = OM_Gw_TransOSnum_0,
                      msg = STmasterControl);
#endif

  if (!(1&(sts)))
  {
    printf ("error in STmaster construction or control msg\n");
    om$report_error (sts = sts);
  }
  exit ();
}

