#ifndef  _BLOCKPVT_H
#define  _BLOCKPVT_H

/* architecture dependent parameters */

#if defined(__clipper__) | defined(__sparc__) | defined(__mips__) | defined(__i386__)
#define  ALIGNSZ           8  /* address alignment (minimum value is 4)    */
#define  PAGESZ         4096  /* size of a page (ALIGNSZ multiple assumed) */
#define  MAXSHORT      65535  /* largest unsigned short                    */
#define  NPTRBITS         32  /* number of bits in a pointer               */
#endif

/* tunable parameters */

#define  MAXSMALL         64         /* default max hold block size         */
#define  NUMSMALL         25         /* default hold block capacity         */
#define  MINBEST       65536         /* smallest best-fit allocation        */
#define  MINPGSIZE        10         /* fewest mem-descriptors/page allowed */
#define  SNAP_INC        100         /* DEBUG mode:  snapshot increment     */
#define  INC_MARGIN       20         /* DEBUG mode:  snapshot margin        */

/* values for AVL tree balance factors */

#define  L           -1    /* tree is skewed to the left  */
#define  B            0    /* tree is balanced            */
#define  R            1    /* tree is skewed to the right */

/* other values */

#define  BLOCKMAGIC  0x426c6b21           /* 4-character ascii for "Blk!" */
#define  BLOCKSZ     sizeof (BLOCK)       /* size of block header         */
#define  HEADSZ      sizeof (CHUNK)       /* size of chunk header         */
#define  HOLDSZ      sizeof (HOLDB)       /* size of holding block header */
#define  MAXPGSIZE   (PAGESZ/sizeof(FCD)) /* number FCDs on largest page  */
#define  MINCHUNK    CHUNKSZ (1)          /* smallest chunk               */
#define  MINBLOCK    (3 * PAGESZ)         /* smallest block               */

/**********/
/* MACROS */
/**********/


/* align a value 'x' up to the next 'a'-sized boundary */

#define  ALIGN(x,a)     (((uint)(x) + (a) - 1) / (a) * (a))

/* align a value 'x' down to the next 'a'-sized boundary */

#define  TRUNC(x,a)     ((uint)(x) / (a) * (a))

/* align a location 'x' up to the nearest valid header location */

#define  NEXTHEAD(x) (CHUNK *)(ALIGN ((char *)(x) + HEADSZ, ALIGNSZ) - HEADSZ)

/* align a location 'x' down to the nearest valid header location */

#define  PREVHEAD(x) (CHUNK *)(TRUNC ((x), ALIGNSZ) - HEADSZ)

/* convert a user-requested size to a legal chunk size (includes the header) */

#define  CHUNKSZ(s)     ALIGN ((s) + HEADSZ, ALIGNSZ)

/* get the status of a chunk */

#define  STAT(x)        ((uint)(x)->next & 3)

/* set the status 's' in the header 'x' */

#define  SET(x,s)       (CHUNK *)((uint)(x) & ~3 | (s))

/* minimum growblk size needed for an 's'-sized chunk */

#define  MINGROW(s)  ((s) + CHUNKSZ (sizeof (CMD)) + ALIGNSZ)

/* check to see if an address is in the storage area */

#define  INSTORE(f) \
\
  (blk->store && (f) >= blk->store && (f) < &blk->store[blk->s_avail])

/* minimum and maximum of two values */

#define  MIN(x,y)  ((x) < (y) ? (x) : (y))
#define  MAX(x,y)  ((x) > (y) ? (x) : (y))

/*********/
/* TYPES */
/*********/
#if !defined(SYS_TYPES_H) && !defined(__sys_types_h)
typedef unsigned int   uint;
typedef unsigned short ushort;
#endif
typedef unsigned char  uchar;

/*****************************************************************************/
/* "Free Chunk Descriptors" describe the pieces of configured memory that    */
/* are available for allocation.  FCDs are kept in an address sorted doubly  */
/* linked list.  They reside physically in large chunks of memory called     */
/* "pages" and are indexed via the pagemap.                                  */
/*****************************************************************************/

#define  CHUNK  union chunk
#define  FCD    struct fcd
FCD {
      CHUNK *addr;    /* pointer to the chunk described     */
      uint   size;    /* size of the chunk described        */
      FCD   *next;    /* pointer to the next descriptor     */
      FCD   *prev;    /* pointer to the previous descriptor */
      FCD   *next_x;  /* next FCD in allocation index       */
      FCD   *prev_x;  /* previous FCD in allocation index   */
};

/*****************************************************************************/
/* "Configured Memory Descriptors" describe those address range(s) compri-   */
/* sing the configured memory.  CMDs are kept in an address sorted doubly    */
/* linked list as well as an AVL tree.  They reside physically at the start  */
/* of each disjoint piece of configured memory and are indexed via the AVL   */
/* tree.                                                                     */
/*****************************************************************************/

#define  CMD  struct cmd
CMD {
      char *addr;    /* pointer to the chunk described     */
      uint  size;    /* size of the chunk described        */
      CMD  *next;    /* pointer to the next descriptor     */
      CMD  *prev;    /* pointer to the previous descriptor */
      CMD  *left;    /* pointer to the left subtree        */
      CMD  *right;   /* pointer to the right subtree       */
      int   bal;     /* state of balance between subtrees  */

#ifdef DEBUG
      int   chksum;  /* checksum word for this descriptor  */
#endif
};

/*****************************************************************************/
/* "Chunks" are the chunks of memory themselves.  These can be free, busy,   */
/* holding blocks, or holes.  The status of the chunk is indicated by the    */
/* low-order two bits of the header (see defines below).  The header of a    */
/* free chunk points to the FCD that describes it; all other headers point   */
/* to the next chunk in configured memory.  A busy chunk with a null header  */
/* marks the end of configured memory.  Holding blocks are large chunks that */
/* have been subdivided into some number of small chunks allowing for rapid  */
/* servicing of small requests.  Holes identify sections of unconfigured     */
/* memory embedded within the configured memory.                             */
/*****************************************************************************/

CHUNK {
        CHUNK  *next;     /* pointer to the next chunk   (if busy) */
        FCD    *myFCD;    /* pointer to this chunk's FCD (if free) */
};

/* status values (low-order bits of header) */

#define  FREE  0
#define  BUSY  1
#define  HOLD  2
#define  HOLE  3

/*****************************************************************************/
/* "Page Descriptors" describe contiguous chunks of memory that are used for */
/* the storage of FCDs.  Pages come in three types:                          */
/*                                                                           */
/*      'P'  --  a physical machine page.  These are the best kind since     */
/*               paging is greatly reduced while searching the free list.    */
/*      'N'  --  a non-aligned chunk of memory large enough to hold at least */
/*               MINPGSIZE FCDs.                                           */
/*      'L'  --  a "logical" page consisting of an undetermined number of    */
/*               FCDs that may be physically scattered throughout the con-   */
/*               figured memory.  This kind of page is used only as a last   */
/*               resort should fragmentation become severe enough to prevent */
/*               usage of one of the other two types.  There is always       */
/*               exactly one logical page and its descriptor always occupies */
/*               index [0] in the pagemap.  No space is allocated to it      */
/*               unless necessary.                                           */
/*****************************************************************************/

#define  PAGE  struct pdesc
PAGE {
       CHUNK  *header;      /* header of the chunk containing this page */
       ushort  type;        /* the kind of page this is (see above)     */
       ushort  capacity;    /* the total number of FCDs it holds        */
       ushort  alloc;       /* the number of FCDs allocated             */
       FCD    *avail;       /* list of available FCDs                   */
       FCD    *first;       /* pointer to the first FCD on this page    */
       FCD    *last;        /* pointer to the last FCD on this page     */
};

/*****************************************************************************/
/* "Holding Blocks" are large chunks that have been subdivided into some     */
/* number of smaller chunks allowing for rapid servicing of small requests.  */
/* Both the number and size of these smaller chunks can be user configured   */
/* when the block is created.  Holding blocks are kept in a circular doubly  */
/* linked list for each size catagory such that any with free space appear   */
/* first.   The header of each busy chunk within the holding block points to */
/* the header of the holding block that contains it.  The free chunks are    */
/* linked in a one-way free queue.  No FCDs are required for the free chunks */
/* of a holding block!                                                       */
/*****************************************************************************/

#define  HOLDB  struct hold
HOLDB {
        CHUNK  *header;    /* this is the header of the chunk (marked hold) */
        ushort  csize;     /* the size (in bytes) of the chunks herein      */
        ushort  busy;      /* the number of chunks currently busy           */
        CHUNK  *freeq;     /* linked free queue                             */
        HOLDB  *next;      /* pointer to next holding block                 */
        HOLDB  *prev;      /* pointer to previous holding block             */

#ifdef DEBUG
        int     chksum;    /* checksum word for this header                 */
#endif
};

/*****************************************************************************/
/* "Blocks" represent the entirity of the configured memory.  All data       */
/* related to managing the configured memory is accessable via the block.    */
/* In addition, all such data (including the block itself) are within the    */
/* configured memory making this package suitable for the management of      */
/* memory shared among several processes (applications must provide the      */
/* appropiate concurrency control in this situation however).                */
/*****************************************************************************/

#define  BLOCK  struct block
BLOCK {
        CHUNK   *header;     /* the header of the chunk (marked busy)     */
        long     magic;      /* magic number for a block                  */
        FCD    **fcdindex;   /* allocation index for bucket best-fit      */
        HOLDB  **small;      /* pointer to array of hold blk chains       */
        PAGE    *pagemap;    /* pointer to the page map for this block    */
        CMD     *memory;     /* the configured memory (circular/ordered)  */
        FCD     *fhead;      /* roving free queue head (circular/ordered) */
        ushort   numsmall;   /* number small chunks per holding block     */
        ushort   maxsmall;   /* largest chunk to allocate from hold block */
        short    ndxbest;    /* allocation bucket to start using best-fit */
        short    ndxlimit;   /* number of allocation buckets in the index */
        FCD     *store;      /* pointer to pending FCD storage area       */
        ushort   s_avail;    /* number FCDs available in storage area     */
        ushort   s_curr;     /* number FCDs currently in storage area     */
        ushort   p_avail;    /* number of free pages held in reserve      */
        ushort   p_curr;     /* number of pages currently in use          */
        int    (*mem_fn)();  /* function to be called when no memory      */

#ifdef DEBUG
        short    debug_on;   /* non-zero enables debug checks             */
        short    mainentry;  /* zero during recursive calls               */
        int      b_chksum;   /* checksum word for this header             */
        int      p_chksum;   /* checksum word for the pagemap             */
        int      h_chksum;   /* checksum word for the holding block index */
        int      s_chksum;   /* checksum word for the snapshot            */
        CHUNK   *snap_start; /* start of snapshot region                  */
        CHUNK   *snap_last;  /* end of the used part of the snapshot      */
#endif
};


#include "block.h"
#endif
